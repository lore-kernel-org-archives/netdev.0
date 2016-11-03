From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v2 2/3] net: core: add UID to flows, rules, and routes
Date: Fri,  4 Nov 2016 02:23:42 +0900
Message-ID: <1478193823-60516-3-git-send-email-lorenzo@google.com>
References: <1478193823-60516-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33613 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759104AbcKCRX6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:23:58 -0400
Received: by mail-pf0-f181.google.com with SMTP id d2so35060497pfd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:23:57 -0700 (PDT)
In-Reply-To: <1478193823-60516-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Define a new FIB rule attributes, FRA_UID_RANGE, to describe a
  range of UIDs.
- Define a RTA_UID attribute for per-UID route lookups and dumps.
- Support passing these attributes to and from userspace via
  rtnetlink. The value INVALID_UID indicates no UID was
  specified.
- Add a UID field to the flow structures.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/fib_rules.h        |  9 ++++-
 include/net/flow.h             |  5 +++
 include/uapi/linux/fib_rules.h |  6 ++++
 include/uapi/linux/rtnetlink.h |  1 +
 net/core/fib_rules.c           | 74 ++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/fib_frontend.c        |  1 +
 net/ipv4/route.c               | 11 +++++++
 net/ipv6/route.c               |  7 ++++
 8 files changed, 111 insertions(+), 3 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 456e4a6..8dbfdf7 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -8,6 +8,11 @@
 #include <net/flow.h>
 #include <net/rtnetlink.h>
 
+struct fib_kuid_range {
+	kuid_t start;
+	kuid_t end;
+};
+
 struct fib_rule {
 	struct list_head	list;
 	int			iifindex;
@@ -30,6 +35,7 @@ struct fib_rule {
 	int			suppress_prefixlen;
 	char			iifname[IFNAMSIZ];
 	char			oifname[IFNAMSIZ];
+	struct fib_kuid_range	uid_range;
 	struct rcu_head		rcu;
 };
 
@@ -92,7 +98,8 @@ struct fib_rules_ops {
 	[FRA_SUPPRESS_PREFIXLEN] = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_IFGROUP] = { .type = NLA_U32 }, \
 	[FRA_GOTO]	= { .type = NLA_U32 }, \
-	[FRA_L3MDEV]	= { .type = NLA_U8 }
+	[FRA_L3MDEV]	= { .type = NLA_U8 }, \
+	[FRA_UID_RANGE]	= { .len = sizeof(struct fib_rule_uid_range) }
 
 static inline void fib_rule_get(struct fib_rule *rule)
 {
diff --git a/include/net/flow.h b/include/net/flow.h
index 035aa77..51373f3 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -11,6 +11,7 @@
 #include <linux/in6.h>
 #include <linux/atomic.h>
 #include <net/flow_dissector.h>
+#include <linux/uidgid.h>
 
 /*
  * ifindex generation is per-net namespace, and loopback is
@@ -37,6 +38,7 @@ struct flowi_common {
 #define FLOWI_FLAG_SKIP_NH_OIF		0x04
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
+	kuid_t  flowic_uid;
 };
 
 union flowi_uli {
@@ -74,6 +76,7 @@ struct flowi4 {
 #define flowi4_flags		__fl_common.flowic_flags
 #define flowi4_secid		__fl_common.flowic_secid
 #define flowi4_tun_key		__fl_common.flowic_tun_key
+#define flowi4_uid		__fl_common.flowic_uid
 
 	/* (saddr,daddr) must be grouped, same order as in IP header */
 	__be32			saddr;
@@ -131,6 +134,7 @@ struct flowi6 {
 #define flowi6_flags		__fl_common.flowic_flags
 #define flowi6_secid		__fl_common.flowic_secid
 #define flowi6_tun_key		__fl_common.flowic_tun_key
+#define flowi6_uid		__fl_common.flowic_uid
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
 	/* Note: flowi6_tos is encoded in flowlabel, too. */
@@ -176,6 +180,7 @@ struct flowi {
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
 #define flowi_tun_key	u.__fl_common.flowic_tun_key
+#define flowi_uid	u.__fl_common.flowic_uid
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 14404b3..bbf02a6 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -29,6 +29,11 @@ struct fib_rule_hdr {
 	__u32		flags;
 };
 
+struct fib_rule_uid_range {
+	__u32		start;
+	__u32		end;
+};
+
 enum {
 	FRA_UNSPEC,
 	FRA_DST,	/* destination address */
@@ -51,6 +56,7 @@ enum {
 	FRA_OIFNAME,
 	FRA_PAD,
 	FRA_L3MDEV,	/* iif or oif is l3mdev goto its table */
+	FRA_UID_RANGE,	/* UID range */
 	__FRA_MAX
 };
 
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 5a78be5..e14377f 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -318,6 +318,7 @@ enum rtattr_type_t {
 	RTA_ENCAP,
 	RTA_EXPIRES,
 	RTA_PAD,
+	RTA_UID,
 	__RTA_MAX
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index be4629c..5de436a 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -18,6 +18,11 @@
 #include <net/fib_rules.h>
 #include <net/ip_tunnels.h>
 
+static const struct fib_kuid_range fib_kuid_range_unset = {
+	KUIDT_INIT(0),
+	KUIDT_INIT(~0),
+};
+
 int fib_default_rule_add(struct fib_rules_ops *ops,
 			 u32 pref, u32 table, u32 flags)
 {
@@ -33,6 +38,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->table = table;
 	r->flags = flags;
 	r->fr_net = ops->fro_net;
+	r->uid_range = fib_kuid_range_unset;
 
 	r->suppress_prefixlen = -1;
 	r->suppress_ifgroup = -1;
@@ -172,6 +178,34 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 }
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
 
+static int uid_range_set(struct fib_kuid_range *range)
+{
+	return uid_valid(range->start) && uid_valid(range->end);
+}
+
+static struct fib_kuid_range nla_get_kuid_range(struct nlattr **tb)
+{
+	struct fib_rule_uid_range *in;
+	struct fib_kuid_range out;
+
+	in = (struct fib_rule_uid_range *)nla_data(tb[FRA_UID_RANGE]);
+
+	out.start = make_kuid(current_user_ns(), in->start);
+	out.end = make_kuid(current_user_ns(), in->end);
+
+	return out;
+}
+
+static int nla_put_uid_range(struct sk_buff *skb, struct fib_kuid_range *range)
+{
+	struct fib_rule_uid_range out = {
+		from_kuid_munged(current_user_ns(), range->start),
+		from_kuid_munged(current_user_ns(), range->end)
+	};
+
+	return nla_put(skb, FRA_UID_RANGE, sizeof(out), &out);
+}
+
 static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 			  struct flowi *fl, int flags,
 			  struct fib_lookup_arg *arg)
@@ -193,6 +227,10 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if (rule->l3mdev && !l3mdev_fib_rule_match(rule->fr_net, fl, arg))
 		goto out;
 
+	if (uid_lt(fl->flowi_uid, rule->uid_range.start) ||
+	    uid_gt(fl->flowi_uid, rule->uid_range.end))
+		goto out;
+
 	ret = ops->match(rule, fl, flags);
 out:
 	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
@@ -429,6 +467,21 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (rule->l3mdev && rule->table)
 		goto errout_free;
 
+	if (tb[FRA_UID_RANGE]) {
+		if (current_user_ns() != net->user_ns) {
+			err = -EPERM;
+			goto errout_free;
+		}
+
+		rule->uid_range = nla_get_kuid_range(tb);
+
+		if (!uid_range_set(&rule->uid_range) ||
+		    !uid_lte(rule->uid_range.start, rule->uid_range.end))
+			goto errout_free;
+	} else {
+		rule->uid_range = fib_kuid_range_unset;
+	}
+
 	if ((nlh->nlmsg_flags & NLM_F_EXCL) &&
 	    rule_exists(ops, frh, tb, rule)) {
 		err = -EEXIST;
@@ -497,6 +550,7 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *tmp;
 	struct nlattr *tb[FRA_MAX+1];
+	struct fib_kuid_range range;
 	int err = -EINVAL;
 
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
@@ -516,6 +570,14 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (err < 0)
 		goto errout;
 
+	if (tb[FRA_UID_RANGE]) {
+		range = nla_get_kuid_range(tb);
+		if (!uid_range_set(&range))
+			goto errout;
+	} else {
+		range = fib_kuid_range_unset;
+	}
+
 	list_for_each_entry(rule, &ops->rules_list, list) {
 		if (frh->action && (frh->action != rule->action))
 			continue;
@@ -552,6 +614,11 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 		    (rule->l3mdev != nla_get_u8(tb[FRA_L3MDEV])))
 			continue;
 
+		if (uid_range_set(&range) &&
+		    (!uid_eq(rule->uid_range.start, range.start) ||
+		     !uid_eq(rule->uid_range.end, range.end)))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -619,7 +686,8 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
 			 + nla_total_size(4) /* FRA_FWMASK */
-			 + nla_total_size_64bit(8); /* FRA_TUN_ID */
+			 + nla_total_size_64bit(8) /* FRA_TUN_ID */
+			 + nla_total_size(sizeof(struct fib_kuid_range));
 
 	if (ops->nlmsg_payload)
 		payload += ops->nlmsg_payload(rule);
@@ -679,7 +747,9 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    (rule->tun_id &&
 	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id, FRA_PAD)) ||
 	    (rule->l3mdev &&
-	     nla_put_u8(skb, FRA_L3MDEV, rule->l3mdev)))
+	     nla_put_u8(skb, FRA_L3MDEV, rule->l3mdev)) ||
+	    (uid_range_set(&rule->uid_range) &&
+	     nla_put_uid_range(skb, &rule->uid_range)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c3b8047..d93eea8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -610,6 +610,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_FLOW]		= { .type = NLA_U32 },
 	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
+	[RTA_UID]		= { .type = NLA_U32 },
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4392db8..92e59a6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2504,6 +2504,11 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	    nla_put_u32(skb, RTA_MARK, fl4->flowi4_mark))
 		goto nla_put_failure;
 
+	if (!uid_eq(fl4->flowi4_uid, INVALID_UID) &&
+	    nla_put_u32(skb, RTA_UID,
+			from_kuid_munged(current_user_ns(), fl4->flowi4_uid)))
+		goto nla_put_failure;
+
 	error = rt->dst.error;
 
 	if (rt_is_input_route(rt)) {
@@ -2556,6 +2561,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	int mark;
 	struct sk_buff *skb;
 	u32 table_id = RT_TABLE_MAIN;
+	kuid_t uid;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy);
 	if (err < 0)
@@ -2583,6 +2589,10 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	dst = tb[RTA_DST] ? nla_get_in_addr(tb[RTA_DST]) : 0;
 	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
 	mark = tb[RTA_MARK] ? nla_get_u32(tb[RTA_MARK]) : 0;
+	if (tb[RTA_UID])
+		uid = make_kuid(current_user_ns(), nla_get_u32(tb[RTA_UID]));
+	else
+		uid = (iif ? INVALID_UID : current_uid());
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = dst;
@@ -2590,6 +2600,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	fl4.flowi4_tos = rtm->rtm_tos;
 	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
 	fl4.flowi4_mark = mark;
+	fl4.flowi4_uid = uid;
 
 	if (iif) {
 		struct net_device *dev;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 947ed1d..fdb9c87 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2797,6 +2797,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
 	[RTA_EXPIRES]		= { .type = NLA_U32 },
+	[RTA_UID]		= { .type = NLA_U32 },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -3371,6 +3372,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (tb[RTA_MARK])
 		fl6.flowi6_mark = nla_get_u32(tb[RTA_MARK]);
 
+	if (tb[RTA_UID])
+		fl6.flowi6_uid = make_kuid(current_user_ns(),
+					   nla_get_u32(tb[RTA_UID]));
+	else
+		fl6.flowi6_uid = iif ? INVALID_UID : current_uid();
+
 	if (iif) {
 		struct net_device *dev;
 		int flags = 0;
-- 
2.8.0.rc3.226.g39d4020
