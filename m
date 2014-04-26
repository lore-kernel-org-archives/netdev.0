From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next 2/4] net: core: Add a UID range to fib rules.
Date: Sat, 26 Apr 2014 13:48:23 +0900
Message-ID: <1398487705-13430-3-git-send-email-lorenzo@google.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net, jpa@google.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56919 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaDZEsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:48:52 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so3480784pdj.4
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 21:48:51 -0700 (PDT)
In-Reply-To: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/fib_rules.h        |  6 ++++-
 include/net/flow.h             |  5 ++++
 include/uapi/linux/fib_rules.h |  2 ++
 net/core/fib_rules.c           | 53 ++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 63 insertions(+), 3 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index e584de1..cb4470d 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -28,6 +28,8 @@ struct fib_rule {
 	int			suppress_prefixlen;
 	char			iifname[IFNAMSIZ];
 	char			oifname[IFNAMSIZ];
+	kuid_t			uid_start;
+	kuid_t			uid_end;
 	struct rcu_head		rcu;
 };
 
@@ -88,7 +90,9 @@ struct fib_rules_ops {
 	[FRA_TABLE]     = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_PREFIXLEN] = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_IFGROUP] = { .type = NLA_U32 }, \
-	[FRA_GOTO]	= { .type = NLA_U32 }
+	[FRA_GOTO]	= { .type = NLA_U32 }, \
+	[FRA_UID_START]	= { .type = NLA_U32 }, \
+	[FRA_UID_END]	= { .type = NLA_U32 }
 
 static inline void fib_rule_get(struct fib_rule *rule)
 {
diff --git a/include/net/flow.h b/include/net/flow.h
index 84044af..9828829 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -10,6 +10,7 @@
 #include <linux/socket.h>
 #include <linux/in6.h>
 #include <linux/atomic.h>
+#include <linux/uidgid.h>
 
 /*
  * ifindex generation is per-net namespace, and loopback is
@@ -30,6 +31,7 @@ struct flowi_common {
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
 	__u32	flowic_secid;
+	kuid_t	flowic_uid;
 };
 
 union flowi_uli {
@@ -66,6 +68,7 @@ struct flowi4 {
 #define flowi4_proto		__fl_common.flowic_proto
 #define flowi4_flags		__fl_common.flowic_flags
 #define flowi4_secid		__fl_common.flowic_secid
+#define flowi4_uid		__fl_common.flowic_uid
 
 	/* (saddr,daddr) must be grouped, same order as in IP header */
 	__be32			saddr;
@@ -122,6 +125,7 @@ struct flowi6 {
 #define flowi6_proto		__fl_common.flowic_proto
 #define flowi6_flags		__fl_common.flowic_flags
 #define flowi6_secid		__fl_common.flowic_secid
+#define flowi6_uid		__fl_common.flowic_uid
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
 	__be32			flowlabel;
@@ -185,6 +189,7 @@ struct flowi {
 #define flowi_proto	u.__fl_common.flowic_proto
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
+#define flowi_uid	u.__fl_common.flowic_uid
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 2b82d7e..743e300 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -49,6 +49,8 @@ enum {
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
+	FRA_UID_START,	/* UID range */
+	FRA_UID_END,
 	__FRA_MAX
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 185c341..5cbcdfd 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -31,6 +31,8 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->pref = pref;
 	r->table = table;
 	r->flags = flags;
+	r->uid_start = INVALID_UID;
+	r->uid_end = INVALID_UID;
 	r->fr_net = hold_net(ops->fro_net);
 
 	r->suppress_prefixlen = -1;
@@ -182,6 +184,23 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 }
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
 
+static inline kuid_t fib_nl_uid(struct nlattr *nla)
+{
+	return make_kuid(current_user_ns(), nla_get_u32(nla));
+}
+
+static int nla_put_uid(struct sk_buff *skb, int idx, kuid_t uid)
+{
+	return nla_put_u32(skb, idx, from_kuid_munged(current_user_ns(), uid));
+}
+
+static int fib_uid_range_match(struct flowi *fl, struct fib_rule *rule)
+{
+	return (!uid_valid(rule->uid_start) && !uid_valid(rule->uid_end)) ||
+	       (uid_gte(fl->flowi_uid, rule->uid_start) &&
+		uid_lte(fl->flowi_uid, rule->uid_end));
+}
+
 static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 			  struct flowi *fl, int flags)
 {
@@ -196,6 +215,9 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if ((rule->mark ^ fl->flowi_mark) & rule->mark_mask)
 		goto out;
 
+	if (!fib_uid_range_match(fl, rule))
+		goto out;
+
 	ret = ops->match(rule, fl, flags);
 out:
 	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
@@ -378,6 +400,19 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	} else if (rule->action == FR_ACT_GOTO)
 		goto errout_free;
 
+	/* UID start and end must either both be valid or both unspecified. */
+	rule->uid_start = rule->uid_end = INVALID_UID;
+	if (tb[FRA_UID_START] || tb[FRA_UID_END]) {
+		if (tb[FRA_UID_START] && tb[FRA_UID_END]) {
+			rule->uid_start = fib_nl_uid(tb[FRA_UID_START]);
+			rule->uid_end = fib_nl_uid(tb[FRA_UID_END]);
+		}
+		if (!uid_valid(rule->uid_start) ||
+		    !uid_valid(rule->uid_end) ||
+		    !uid_lte(rule->uid_start, rule->uid_end))
+		goto errout_free;
+	}
+
 	err = ops->configure(rule, skb, frh, tb);
 	if (err < 0)
 		goto errout_free;
@@ -484,6 +519,14 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		    (rule->mark_mask != nla_get_u32(tb[FRA_FWMASK])))
 			continue;
 
+		if (tb[FRA_UID_START] &&
+		    !uid_eq(rule->uid_start, fib_nl_uid(tb[FRA_UID_START])))
+			continue;
+
+		if (tb[FRA_UID_END] &&
+		    !uid_eq(rule->uid_end, fib_nl_uid(tb[FRA_UID_END])))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -542,7 +585,9 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(4) /* FRA_SUPPRESS_PREFIXLEN */
 			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
-			 + nla_total_size(4); /* FRA_FWMASK */
+			 + nla_total_size(4) /* FRA_FWMASK */
+			 + nla_total_size(4) /* FRA_UID_START */
+			 + nla_total_size(4); /* FRA_UID_END */
 
 	if (ops->nlmsg_payload)
 		payload += ops->nlmsg_payload(rule);
@@ -598,7 +643,11 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    ((rule->mark_mask || rule->mark) &&
 	     nla_put_u32(skb, FRA_FWMASK, rule->mark_mask)) ||
 	    (rule->target &&
-	     nla_put_u32(skb, FRA_GOTO, rule->target)))
+	     nla_put_u32(skb, FRA_GOTO, rule->target)) ||
+	    (uid_valid(rule->uid_start) &&
+	     nla_put_uid(skb, FRA_UID_START, rule->uid_start)) ||
+	    (uid_valid(rule->uid_end) &&
+	     nla_put_uid(skb, FRA_UID_END, rule->uid_end)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
-- 
1.9.1.423.g4596e3a
