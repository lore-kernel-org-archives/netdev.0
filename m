From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Sun, 11 Jun 2017 16:13:03 +0200
Message-ID: <20170611141303.GC1896@nanopsycho.orion>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33344 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdFKONG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:13:06 -0400
Received: by mail-wr0-f195.google.com with SMTP id v104so16609837wrb.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 07:13:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1497182026-11594-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jun 11, 2017 at 01:53:45PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>When you dump hundreds of thousands of actions, getting only 32 per
>dump batch even when the socket buffer and memory allocations allow
>is inefficient.
>
>With this change, the user will get as many as possibly fitting
>within the given constraints available to the kernel.
>
>The top level action TLV space is extended. An attribute
>TCA_ROOT_FLAGS is used to carry flags; flag TCA_FLAG_LARGE_DUMP_ON
>is set by the user indicating the user is capable of processing
>these large dumps. Older user space which doesnt set this flag
>doesnt get the large (than 32) batches.
>The kernel uses the TCA_ROOT_COUNT attribute to tell the user how many
>actions are put in a single batch. As such user space app knows how long
>to iterate (independent of the type of action being dumped)
>instead of hardcoded maximum of 32 thus maintaining backward compat.
>
>Some results dumping 1.5M actions below:
>first an unpatched tc which doesnt understand these features...
>
>prompt$ time -p tc actions ls action gact | grep index | wc -l
>1500000
>real 1388.43
>user 2.07
>sys 1386.79
>
>Now lets see a patched tc which sets the correct flags when requesting
>a dump:
>
>prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
>1500000
>real 178.13
>user 2.02
>sys 176.96
>
>That is about 8x performance improvement for tc app which sets its
>receive buffer to about 32K.
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> include/uapi/linux/rtnetlink.h | 22 +++++++++++++++++--
> net/sched/act_api.c            | 50 +++++++++++++++++++++++++++++++++---------
> 2 files changed, 60 insertions(+), 12 deletions(-)
>
>diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>index 8f07957..7d2030f 100644
>--- a/include/uapi/linux/rtnetlink.h
>+++ b/include/uapi/linux/rtnetlink.h
>@@ -693,10 +693,28 @@ struct tcamsg {
> 	unsigned char	tca__pad1;
> 	unsigned short	tca__pad2;
> };
>+
>+enum {
>+	TCA_ROOT_UNSPEC,
>+	TCA_ROOT_TAB,
>+#define TCA_ACT_TAB TCA_ROOT_TAB
>+#define TCAA_MAX TCA_ROOT_TAB
>+	TCA_ROOT_FLAGS,
>+	TCA_ROOT_COUNT,
>+	__TCA_ROOT_MAX,
>+#define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
>+};
>+
> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>-#define TCAA_MAX 1
>+/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
>+ *
>+ * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>+ * actions in a dump. All dump responses will contain the number of actions
>+ * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
>+ *
>+ */
>+#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
> 
> /* New extended info filters for IFLA_EXT_MASK */
> #define RTEXT_FILTER_VF		(1 << 0)
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index 400eb6e..935dc19 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -110,6 +110,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 			   struct netlink_callback *cb)
> {
> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>+	u32 act_flags = cb->args[2];
> 	struct nlattr *nest;
> 
> 	spin_lock_bh(&hinfo->lock);
>@@ -138,14 +139,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 			}
> 			nla_nest_end(skb, nest);
> 			n_i++;
>-			if (n_i >= TCA_ACT_MAX_PRIO)
>+			if (!(act_flags & TCA_FLAG_LARGE_DUMP_ON) &&
>+			    n_i >= TCA_ACT_MAX_PRIO)
> 				goto done;
> 		}
> 	}
> done:
> 	spin_unlock_bh(&hinfo->lock);
>-	if (n_i)
>+	if (n_i) {
> 		cb->args[0] += n_i;
>+		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
>+			cb->args[1] = n_i;
>+	}
> 	return n_i;
> 
> nla_put_failure:
>@@ -1068,11 +1073,17 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
> 	return tcf_add_notify(net, n, &actions, portid);
> }
> 
>+static u32 allowed_flags = TCA_FLAG_LARGE_DUMP_ON;

An empty line would be nice. Also, since this is outside a function, some
context prefix would be nice:
static u32 tcaa_root_flags_allowed = TCA_FLAG_LARGE_DUMP_ON;


>+static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
>+	[TCA_ROOT_FLAGS] = { .type = NLA_FLAG_BITS,
>+			     .validation_data = &allowed_flags },
>+};
>+
> static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 			 struct netlink_ext_ack *extack)
> {
> 	struct net *net = sock_net(skb->sk);
>-	struct nlattr *tca[TCAA_MAX + 1];
>+	struct nlattr *tca[TCA_ROOT_MAX + 1];
> 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
> 	int ret = 0, ovr = 0;
> 
>@@ -1080,7 +1091,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 	    !netlink_capable(skb, CAP_NET_ADMIN))
> 		return -EPERM;
> 
>-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
>+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ROOT_MAX, NULL,
> 			  extack);
> 	if (ret < 0)
> 		return ret;
>@@ -1121,16 +1132,12 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 	return ret;
> }
> 
>-static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
>+static struct nlattr *find_dump_kind(struct nlattr **nla)
> {
> 	struct nlattr *tb1, *tb2[TCA_ACT_MAX + 1];
> 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
>-	struct nlattr *nla[TCAA_MAX + 1];
> 	struct nlattr *kind;
> 
>-	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX,
>-			NULL, NULL) < 0)
>-		return NULL;
> 	tb1 = nla[TCA_ACT_TAB];
> 	if (tb1 == NULL)
> 		return NULL;
>@@ -1157,8 +1164,18 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
> 	struct tc_action_ops *a_o;
> 	int ret = 0;
> 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
>-	struct nlattr *kind = find_dump_kind(cb->nlh);
>+	struct __nla_bit_flags select_flags;
>+	struct nlattr *count_attr = NULL;
>+	struct nlattr *tb[TCA_ROOT_MAX + 1];
>+	struct nlattr *kind = NULL;
>+	u32 act_count = 0;
>+
>+	ret = nlmsg_parse(cb->nlh, sizeof(struct tcamsg), tb, TCA_ROOT_MAX,
>+			  tcaa_policy, NULL);
>+	if (ret < 0)
>+		return ret;
> 
>+	kind = find_dump_kind(tb);
> 	if (kind == NULL) {
> 		pr_info("tc_dump_action: action bad kind\n");
> 		return 0;
>@@ -1168,14 +1185,24 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
> 	if (a_o == NULL)
> 		return 0;
> 
>+	if (tb[TCA_ROOT_FLAGS])
>+		nla_memcpy(&select_flags, tb[TCA_ROOT_FLAGS],
>+			   sizeof(select_flags));

Please introduce a helper for this attr type in patch 1:

u32 select_flags;

select_flags = nla_get_flag_bits_values(tb[TCA_ROOT_FLAGS])


>+
> 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
> 			cb->nlh->nlmsg_type, sizeof(*t), 0);
> 	if (!nlh)
> 		goto out_module_put;
>+
>+	cb->args[2] = select_flags.nla_flag_values;
> 	t = nlmsg_data(nlh);
> 	t->tca_family = AF_UNSPEC;
> 	t->tca__pad1 = 0;
> 	t->tca__pad2 = 0;
>+	count_attr = nla_reserve(skb, TCA_ROOT_COUNT, sizeof(u32));
>+	if (!count_attr)
>+		goto out_module_put;
>+
> 
> 	nest = nla_nest_start(skb, TCA_ACT_TAB);
> 	if (nest == NULL)
>@@ -1188,6 +1215,9 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
> 	if (ret > 0) {
> 		nla_nest_end(skb, nest);
> 		ret = skb->len;
>+		act_count = cb->args[1];
>+		memcpy(nla_data(count_attr), &act_count, sizeof(u32));
>+		cb->args[1] = 0;
> 	} else
> 		nlmsg_trim(skb, b);
> 
>-- 
>1.9.1
>
