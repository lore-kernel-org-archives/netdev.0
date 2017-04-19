From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 14:36:45 +0200
Message-ID: <20170419123645.GB3357@nanopsycho.orion>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36248 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762363AbdDSMgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 08:36:48 -0400
Received: by mail-wm0-f65.google.com with SMTP id q125so4743697wmd.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 05:36:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 19, 2017 at 01:57:29PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>When you dump hundreds of thousands of actions, getting only 32 per
>dump batch even when the socket buffer and memory allocations allow
>is inefficient.
>
>With this change, the user will get as many as possibly fitting
>within the given constraints available to the kernel.
>
>A new top level TLV space is introduced. An attribute
>TCAA_ACT_FLAGS is used to carry the flags indicating the user
>is capable of processing these large dumps. Older user space which
>doesnt set this flag doesnt get the large (than 32) batches.
>The kernel uses the TCAA_ACT_COUNT attribute to tell the user how many
>actions are put in a single batch. As such user space app knows how long
>to iterate (independent of the type of action being dumped)
>instead of hardcoded maximum of 32.
>
>Some results dumping 1.5M actions, first unpatched tc which the
>kernel doesnt help:
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
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++++--
> net/sched/act_api.c            | 43 ++++++++++++++++++++++++++++++++----------
> 3 files changed, 53 insertions(+), 12 deletions(-)
>
>diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>index cce0613..c7080ec 100644
>--- a/include/uapi/linux/rtnetlink.h
>+++ b/include/uapi/linux/rtnetlink.h
>@@ -674,10 +674,27 @@ struct tcamsg {
> 	unsigned char	tca__pad1;
> 	unsigned short	tca__pad2;
> };
>+
>+enum {
>+	TCAA_UNSPEC,
>+	TCAA_ACT_TAB,
>+	TCAA_ACT_FLAGS,
>+	TCAA_ACT_COUNT,
>+	__TCAA_MAX
>+};
>+
>+#define TCAA_MAX (__TCAA_MAX - 1)
> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>-#define TCAA_MAX 1
>+#define TCA_ACT_TAB TCAA_ACT_TAB

This is mess. What does "TCAA" stand for?
I suggest some more meaningful naming of the enum items and define
TCA_ACT_TAB and TCAA_MAX to the new values in order to maintain UAPI
Also, please put X_MAX = __X_MAX - 1 into enum


>+/* tcamsg flags stored in attribute TCAA_ACT_FLAGS
>+ *
>+ * ACT_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>+ * actions in a dump. All dump responses will contain the number of actions
>+ * being dumped stored in for user app's consumption in TCAA_ACT_COUNT
>+ *
>+ */
>+#define ACT_LARGE_DUMP_ON		(1 << 0) 

Use "BIT(0)"

Also use the same prefix as for the enum.

+ you can have each potential flag as a separate u8 attribute. That is the
clearest approach and easily extendable. That's how we do it in devlink
for example.


> 
> /* New extended info filters for IFLA_EXT_MASK */
> #define RTEXT_FILTER_VF		(1 << 0)
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index 82b1d48..45e1cf7 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -83,6 +83,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 			   struct netlink_callback *cb)
> {
> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>+	unsigned short act_flags = cb->args[2];
> 	struct nlattr *nest;
> 
> 	spin_lock_bh(&hinfo->lock);
>@@ -111,14 +112,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 			}
> 			nla_nest_end(skb, nest);
> 			n_i++;
>-			if (n_i >= TCA_ACT_MAX_PRIO)
>+			if (!(act_flags & ACT_LARGE_DUMP_ON) &&
>+			    n_i >= TCA_ACT_MAX_PRIO)
> 				goto done;
> 		}
> 	}
> done:
> 	spin_unlock_bh(&hinfo->lock);
>-	if (n_i)
>+	if (n_i) {
> 		cb->args[0] += n_i;
>+		if (act_flags & ACT_LARGE_DUMP_ON)
>+			cb->args[1] = n_i;
>+	}
> 	return n_i;
> 
> nla_put_failure:
>@@ -993,11 +998,15 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
> 	return tcf_add_notify(net, n, &actions, portid);
> }
> 
>+static const struct nla_policy tcaa_policy[TCAA_MAX + 1] = {
>+	[TCAA_ACT_FLAGS]      = { .type = NLA_U32 },
>+};
>+
> static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 			 struct netlink_ext_ack *extack)
> {
> 	struct net *net = sock_net(skb->sk);
>-	struct nlattr *tca[TCA_ACT_MAX + 1];
>+	struct nlattr *tca[TCAA_MAX + 1];

This is certainly wrong.


> 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
> 	int ret = 0, ovr = 0;
> 
>@@ -1005,7 +1014,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 	    !netlink_capable(skb, CAP_NET_ADMIN))
> 		return -EPERM;
> 
>-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
>+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, tcaa_policy,

This is certainly wrong.


> 			  extack);
> 	if (ret < 0)
> 		return ret;
>@@ -1046,16 +1055,12 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
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
>@@ -1081,9 +1086,18 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
> 	struct nlattr *nest;
> 	struct tc_action_ops *a_o;
> 	int ret = 0;
>+	struct nlattr *tcaa[TCAA_MAX + 1];
> 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
>-	struct nlattr *kind = find_dump_kind(cb->nlh);
>+	struct nlattr *kind = NULL;
>+	u32 act_flags = 0;
>+
>+	ret = nlmsg_parse(cb->nlh, sizeof(struct tcamsg), tcaa, TCAA_MAX,
>+			  tcaa_policy, NULL);
>+	if (ret < 0)
>+		return ret;
>+
> 
>+	kind = find_dump_kind(tcaa);
> 	if (kind == NULL) {
> 		pr_info("tc_dump_action: action bad kind\n");
> 		return 0;
>@@ -1093,10 +1107,16 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
> 	if (a_o == NULL)
> 		return 0;
> 
>+	if (tcaa[TCAA_ACT_FLAGS])
>+		act_flags = nla_get_u32(tcaa[TCAA_ACT_FLAGS]);
>+
> 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
> 			cb->nlh->nlmsg_type, sizeof(*t), 0);
> 	if (!nlh)
> 		goto out_module_put;
>+
>+	cb->args[2] = act_flags;
>+
> 	t = nlmsg_data(nlh);
> 	t->tca_family = AF_UNSPEC;
> 	t->tca__pad1 = 0;
>@@ -1113,6 +1133,9 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
> 	if (ret > 0) {
> 		nla_nest_end(skb, nest);
> 		ret = skb->len;
>+		if (nla_put_u32(skb, TCAA_ACT_COUNT, cb->args[1]))
>+			goto out_module_put;
>+		cb->args[1] = 0;

Why you need to zero this?


> 	} else
> 		nlmsg_trim(skb, b);
> 
>-- 
>1.9.1
>
