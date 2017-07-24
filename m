From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v11 3/4] net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Sun, 23 Jul 2017 21:35:45 -0400
Message-ID: <1500860146-26970-4-git-send-email-jhs@emojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        dsahern@gmail.com, eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36839 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751884AbdGXBgL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 21:36:11 -0400
Received: by mail-io0-f194.google.com with SMTP id j32so973773iod.3
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 18:36:11 -0700 (PDT)
In-Reply-To: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

When you dump hundreds of thousands of actions, getting only 32 per
dump batch even when the socket buffer and memory allocations allow
is inefficient.

With this change, the user will get as many as possibly fitting
within the given constraints available to the kernel.

The top level action TLV space is extended. An attribute
TCA_ROOT_FLAGS is used to carry flags; flag TCA_FLAG_LARGE_DUMP_ON
is set by the user indicating the user is capable of processing
these large dumps. Older user space which doesnt set this flag
doesnt get the large (than 32) batches.
The kernel uses the TCA_ROOT_COUNT attribute to tell the user how many
actions are put in a single batch. As such user space app knows how long
to iterate (independent of the type of action being dumped)
instead of hardcoded maximum of 32 thus maintaining backward compat.

Some results dumping 1.5M actions below:
first an unpatched tc which doesnt understand these features...

prompt$ time -p tc actions ls action gact | grep index | wc -l
1500000
real 1388.43
user 2.07
sys 1386.79

Now lets see a patched tc which sets the correct flags when requesting
a dump:

prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
1500000
real 178.13
user 2.02
sys 176.96

That is about 8x performance improvement for tc app which sets its
receive buffer to about 32K.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/netlink.h          | 12 +++++++++++
 include/uapi/linux/rtnetlink.h | 22 +++++++++++++++++--
 net/sched/act_api.c            | 48 +++++++++++++++++++++++++++++++++---------
 3 files changed, 70 insertions(+), 12 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index e33d1fb..87c0b15 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1207,6 +1207,18 @@ static inline struct in6_addr nla_get_in6_addr(const struct nlattr *nla)
 }
 
 /**
+ * nla_get_bitfield_32 - return payload of 32 bitfield attribute
+ * @nla: nla_bitfield_32 attribute
+ */
+static inline struct nla_bitfield_32 nla_get_bitfield_32(const struct nlattr *nla)
+{
+	struct nla_bitfield_32 tmp;
+
+	nla_memcpy(&tmp, nla, sizeof(tmp));
+	return tmp;
+}
+
+/**
  * nla_memdup - duplicate attribute memory (kmemdup)
  * @src: netlink attribute to duplicate from
  * @gfp: GFP mask
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index d148505..bfa80a6 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -683,10 +683,28 @@ struct tcamsg {
 	unsigned char	tca__pad1;
 	unsigned short	tca__pad2;
 };
+
+enum {
+	TCA_ROOT_UNSPEC,
+	TCA_ROOT_TAB,
+#define TCA_ACT_TAB TCA_ROOT_TAB
+#define TCAA_MAX TCA_ROOT_TAB
+	TCA_ROOT_FLAGS,
+	TCA_ROOT_COUNT,
+	__TCA_ROOT_MAX,
+#define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
+};
+
 #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
 #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
-#define TCAA_MAX 1
+/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
+ *
+ * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
+ * actions in a dump. All dump responses will contain the number of actions
+ * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
+ *
+ */
+#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
 
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 848370e..15d6c46 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -110,6 +110,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 			   struct netlink_callback *cb)
 {
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
+	u32 act_flags = cb->args[2];
 	struct nlattr *nest;
 
 	spin_lock_bh(&hinfo->lock);
@@ -138,14 +139,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 			}
 			nla_nest_end(skb, nest);
 			n_i++;
-			if (n_i >= TCA_ACT_MAX_PRIO)
+			if (!(act_flags & TCA_FLAG_LARGE_DUMP_ON) &&
+			    n_i >= TCA_ACT_MAX_PRIO)
 				goto done;
 		}
 	}
 done:
 	spin_unlock_bh(&hinfo->lock);
-	if (n_i)
+	if (n_i) {
 		cb->args[0] += n_i;
+		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
+			cb->args[1] = n_i;
+	}
 	return n_i;
 
 nla_put_failure:
@@ -1068,11 +1073,17 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 	return tcf_add_notify(net, n, &actions, portid);
 }
 
+static u32 tcaa_root_flags_allowed = TCA_FLAG_LARGE_DUMP_ON;
+static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
+	[TCA_ROOT_FLAGS] = { .type = NLA_BITFIELD_32,
+			     .validation_data = &tcaa_root_flags_allowed },
+};
+
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
-	struct nlattr *tca[TCAA_MAX + 1];
+	struct nlattr *tca[TCA_ROOT_MAX + 1];
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
@@ -1080,7 +1091,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ROOT_MAX, NULL,
 			  extack);
 	if (ret < 0)
 		return ret;
@@ -1121,16 +1132,12 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
 	return ret;
 }
 
-static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
+static struct nlattr *find_dump_kind(struct nlattr **nla)
 {
 	struct nlattr *tb1, *tb2[TCA_ACT_MAX + 1];
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
-	struct nlattr *nla[TCAA_MAX + 1];
 	struct nlattr *kind;
 
-	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX,
-			NULL, NULL) < 0)
-		return NULL;
 	tb1 = nla[TCA_ACT_TAB];
 	if (tb1 == NULL)
 		return NULL;
@@ -1157,8 +1164,18 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tc_action_ops *a_o;
 	int ret = 0;
 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
-	struct nlattr *kind = find_dump_kind(cb->nlh);
+	struct nla_bitfield_32 fb;
+	struct nlattr *count_attr = NULL;
+	struct nlattr *tb[TCA_ROOT_MAX + 1];
+	struct nlattr *kind = NULL;
+	u32 act_count = 0;
+
+	ret = nlmsg_parse(cb->nlh, sizeof(struct tcamsg), tb, TCA_ROOT_MAX,
+			  tcaa_policy, NULL);
+	if (ret < 0)
+		return ret;
 
+	kind = find_dump_kind(tb);
 	if (kind == NULL) {
 		pr_info("tc_dump_action: action bad kind\n");
 		return 0;
@@ -1168,14 +1185,22 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (a_o == NULL)
 		return 0;
 
+	if (tb[TCA_ROOT_FLAGS])
+		fb = nla_get_bitfield_32(tb[TCA_ROOT_FLAGS]);
+
 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
+
+	cb->args[2] = fb.nla_value;
 	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
+	count_attr = nla_reserve(skb, TCA_ROOT_COUNT, sizeof(u32));
+	if (!count_attr)
+		goto out_module_put;
 
 	nest = nla_nest_start(skb, TCA_ACT_TAB);
 	if (nest == NULL)
@@ -1188,6 +1213,9 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (ret > 0) {
 		nla_nest_end(skb, nest);
 		ret = skb->len;
+		act_count = cb->args[1];
+		memcpy(nla_data(count_attr), &act_count, sizeof(u32));
+		cb->args[1] = 0;
 	} else
 		nlmsg_trim(skb, b);
 
-- 
1.9.1
