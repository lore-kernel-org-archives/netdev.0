From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 1/2] net: Add l3mdev rule
Date: Mon,  6 Jun 2016 20:35:51 -0700
Message-ID: <1465270552-30925-2-git-send-email-dsa@cumulusnetworks.com>
References: <[PATCH net-next v4 0/2] net: vrf: Improve use of FIB rules>
 <1465270552-30925-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33033 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbcFGDgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 23:36:05 -0400
Received: by mail-pf0-f171.google.com with SMTP id y124so13597381pfy.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 20:36:05 -0700 (PDT)
In-Reply-To: <1465270552-30925-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, VRFs require 1 oif and 1 iif rule per address family per
VRF. As the number of VRF devices increases it brings scalability
issues with the increasing rule list. All of the VRF rules have the
same format with the exception of the specific table id to direct the
lookup. Since the table id is available from the oif or iif in the
loopup, the VRF rules can be consolidated to a single rule that pulls
the table from the VRF device.

This patch introduces a new rule attribute l3mdev. The l3mdev rule
means the table id used for the lookup is pulled from the L3 master
device (e.g., VRF) rather than being statically defined. With the
l3mdev rule all of the basic VRF FIB rules are reduced to 1 l3mdev
rule per address family (IPv4 and IPv6).

If an admin wishes to insert higher priority rules for specific VRFs
those rules will co-exist with the l3mdev rule. This capability means
current VRF scripts will co-exist with this new simpler implementation.

Currently, the rules list for both ipv4 and ipv6 look like this:
    $ ip  ru ls
    1000:       from all oif vrf1 lookup 1001
    1000:       from all iif vrf1 lookup 1001
    1000:       from all oif vrf2 lookup 1002
    1000:       from all iif vrf2 lookup 1002
    1000:       from all oif vrf3 lookup 1003
    1000:       from all iif vrf3 lookup 1003
    1000:       from all oif vrf4 lookup 1004
    1000:       from all iif vrf4 lookup 1004
    1000:       from all oif vrf5 lookup 1005
    1000:       from all iif vrf5 lookup 1005
    1000:       from all oif vrf6 lookup 1006
    1000:       from all iif vrf6 lookup 1006
    1000:       from all oif vrf7 lookup 1007
    1000:       from all iif vrf7 lookup 1007
    1000:       from all oif vrf8 lookup 1008
    1000:       from all iif vrf8 lookup 1008
    ...
    32765:      from all lookup local
    32766:      from all lookup main
    32767:      from all lookup default

With the l3mdev rule the list is just the following regardless of the
number of VRFs:
    $ ip ru ls
    1000:       from all lookup [l3mdev table]
    32765:      from all lookup local
    32766:      from all lookup main
    32767:      from all lookup default

(Note: the above pretty print of the rule is based on an iproute2
       prototype. Actual verbage may change)

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- no change to this patch

v3
- no change to this patch

v2
- if CONFIG_NET_L3_MASTER_DEV is not enabled changed the inline
  l3mdev_fib_rule_match function to return 1 rather than 0 allowing
  the compiler to completely drop the check:
     if (rule->l3mdev && !l3mdev_fib_rule_match())

- moved setting of tb_id down to its use fib4_rule_action which
  addresses Dave's comment about reverse xmas tree order. Same
  change for ipv6 version.

 include/net/fib_rules.h        | 24 ++++++++++++++++++++++--
 include/net/l3mdev.h           | 12 ++++++++++++
 include/uapi/linux/fib_rules.h |  1 +
 net/core/fib_rules.c           | 33 ++++++++++++++++++++++++++++-----
 net/ipv4/fib_rules.c           |  6 ++++--
 net/ipv6/fib6_rules.c          |  6 ++++--
 net/l3mdev/l3mdev.c            | 38 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 109 insertions(+), 11 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 59160de702b6..456e4a6006ab 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -17,7 +17,8 @@ struct fib_rule {
 	u32			flags;
 	u32			table;
 	u8			action;
-	/* 3 bytes hole, try to use */
+	u8			l3mdev;
+	/* 2 bytes hole, try to use */
 	u32			target;
 	__be64			tun_id;
 	struct fib_rule __rcu	*ctarget;
@@ -36,6 +37,7 @@ struct fib_lookup_arg {
 	void			*lookup_ptr;
 	void			*result;
 	struct fib_rule		*rule;
+	u32			table;
 	int			flags;
 #define FIB_LOOKUP_NOREF		1
 #define FIB_LOOKUP_IGNORE_LINKSTATE	2
@@ -89,7 +91,8 @@ struct fib_rules_ops {
 	[FRA_TABLE]     = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_PREFIXLEN] = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_IFGROUP] = { .type = NLA_U32 }, \
-	[FRA_GOTO]	= { .type = NLA_U32 }
+	[FRA_GOTO]	= { .type = NLA_U32 }, \
+	[FRA_L3MDEV]	= { .type = NLA_U8 }
 
 static inline void fib_rule_get(struct fib_rule *rule)
 {
@@ -102,6 +105,20 @@ static inline void fib_rule_put(struct fib_rule *rule)
 		kfree_rcu(rule, rcu);
 }
 
+#ifdef CONFIG_NET_L3_MASTER_DEV
+static inline u32 fib_rule_get_table(struct fib_rule *rule,
+				     struct fib_lookup_arg *arg)
+{
+	return rule->l3mdev ? arg->table : rule->table;
+}
+#else
+static inline u32 fib_rule_get_table(struct fib_rule *rule,
+				     struct fib_lookup_arg *arg)
+{
+	return rule->table;
+}
+#endif
+
 static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 {
 	if (nla[FRA_TABLE])
@@ -117,4 +134,7 @@ int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
 		     struct fib_lookup_arg *);
 int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
 			 u32 flags);
+
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh);
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh);
 #endif
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 374388dc01c8..34f33eb96a5e 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -11,6 +11,8 @@
 #ifndef _NET_L3MDEV_H_
 #define _NET_L3MDEV_H_
 
+#include <net/fib_rules.h>
+
 /**
  * struct l3mdev_ops - l3mdev operations
  *
@@ -41,6 +43,9 @@ struct l3mdev_ops {
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 
+int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
+			  struct fib_lookup_arg *arg);
+
 int l3mdev_master_ifindex_rcu(const struct net_device *dev);
 static inline int l3mdev_master_ifindex(struct net_device *dev)
 {
@@ -236,6 +241,13 @@ struct sk_buff *l3mdev_ip6_rcv(struct sk_buff *skb)
 {
 	return skb;
 }
+
+static inline
+int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
+			  struct fib_lookup_arg *arg)
+{
+	return 1;
+}
 #endif
 
 #endif /* _NET_L3MDEV_H_ */
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 620c8a5ddc00..14404b3ebb89 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -50,6 +50,7 @@ enum {
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
 	FRA_PAD,
+	FRA_L3MDEV,	/* iif or oif is l3mdev goto its table */
 	__FRA_MAX
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 840acebbb80c..98298b11f534 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -173,7 +173,8 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
 
 static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
-			  struct flowi *fl, int flags)
+			  struct flowi *fl, int flags,
+			  struct fib_lookup_arg *arg)
 {
 	int ret = 0;
 
@@ -189,6 +190,9 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if (rule->tun_id && (rule->tun_id != fl->flowi_tun_key.tun_id))
 		goto out;
 
+	if (rule->l3mdev && !l3mdev_fib_rule_match(rule->fr_net, fl, arg))
+		goto out;
+
 	ret = ops->match(rule, fl, flags);
 out:
 	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
@@ -204,7 +208,7 @@ int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
 
 	list_for_each_entry_rcu(rule, &ops->rules_list, list) {
 jumped:
-		if (!fib_rule_match(rule, ops, fl, flags))
+		if (!fib_rule_match(rule, ops, fl, flags, arg))
 			continue;
 
 		if (rule->action == FR_ACT_GOTO) {
@@ -265,7 +269,7 @@ static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
 	return err;
 }
 
-static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -336,6 +340,14 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (tb[FRA_TUN_ID])
 		rule->tun_id = nla_get_be64(tb[FRA_TUN_ID]);
 
+	if (tb[FRA_L3MDEV]) {
+#ifdef CONFIG_NET_L3_MASTER_DEV
+		rule->l3mdev = nla_get_u8(tb[FRA_L3MDEV]);
+		if (rule->l3mdev != 1)
+#endif
+			goto errout_free;
+	}
+
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
@@ -371,6 +383,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	} else if (rule->action == FR_ACT_GOTO)
 		goto errout_free;
 
+	if (rule->l3mdev && rule->table)
+		goto errout_free;
+
 	err = ops->configure(rule, skb, frh, tb);
 	if (err < 0)
 		goto errout_free;
@@ -424,8 +439,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rules_ops_put(ops);
 	return err;
 }
+EXPORT_SYMBOL_GPL(fib_nl_newrule);
 
-static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -483,6 +499,10 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		    (rule->tun_id != nla_get_be64(tb[FRA_TUN_ID])))
 			continue;
 
+		if (tb[FRA_L3MDEV] &&
+		    (rule->l3mdev != nla_get_u8(tb[FRA_L3MDEV])))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -536,6 +556,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rules_ops_put(ops);
 	return err;
 }
+EXPORT_SYMBOL_GPL(fib_nl_delrule);
 
 static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 					 struct fib_rule *rule)
@@ -607,7 +628,9 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    (rule->target &&
 	     nla_put_u32(skb, FRA_GOTO, rule->target)) ||
 	    (rule->tun_id &&
-	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id, FRA_PAD)))
+	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id, FRA_PAD)) ||
+	    (rule->l3mdev &&
+	     nla_put_u8(skb, FRA_L3MDEV, rule->l3mdev)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index f2bda9e89c61..6e9ea69e5f75 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -76,6 +76,7 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 {
 	int err = -EAGAIN;
 	struct fib_table *tbl;
+	u32 tb_id;
 
 	switch (rule->action) {
 	case FR_ACT_TO_TBL:
@@ -94,7 +95,8 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 
 	rcu_read_lock();
 
-	tbl = fib_get_table(rule->fr_net, rule->table);
+	tb_id = fib_rule_get_table(rule, arg);
+	tbl = fib_get_table(rule->fr_net, tb_id);
 	if (tbl)
 		err = fib_table_lookup(tbl, &flp->u.ip4,
 				       (struct fib_result *)arg->result,
@@ -180,7 +182,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	if (err)
 		goto errout;
 
-	if (rule->table == RT_TABLE_UNSPEC) {
+	if (rule->table == RT_TABLE_UNSPEC && !rule->l3mdev) {
 		if (rule->action == FR_ACT_TO_TBL) {
 			struct fib_table *table;
 
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index ed33abf57abd..5857c1fc8b67 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -67,6 +67,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	struct net *net = rule->fr_net;
 	pol_lookup_t lookup = arg->lookup_ptr;
 	int err = 0;
+	u32 tb_id;
 
 	switch (rule->action) {
 	case FR_ACT_TO_TBL:
@@ -86,7 +87,8 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto discard_pkt;
 	}
 
-	table = fib6_get_table(net, rule->table);
+	tb_id = fib_rule_get_table(rule, arg);
+	table = fib6_get_table(net, tb_id);
 	if (!table) {
 		err = -EAGAIN;
 		goto out;
@@ -199,7 +201,7 @@ static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
-	if (rule->action == FR_ACT_TO_TBL) {
+	if (rule->action == FR_ACT_TO_TBL && !rule->l3mdev) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
 
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 6651a78e100c..7da97809a7e8 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/netdevice.h>
+#include <net/fib_rules.h>
 #include <net/l3mdev.h>
 
 /**
@@ -160,3 +161,40 @@ int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4)
 	return rc;
 }
 EXPORT_SYMBOL_GPL(l3mdev_get_saddr);
+
+/**
+ *	l3mdev_fib_rule_match - Determine if flowi references an
+ *				L3 master device
+ *	@net: network namespace for device index lookup
+ *	@fl:  flow struct
+ */
+
+int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
+			  struct fib_lookup_arg *arg)
+{
+	struct net_device *dev;
+	int rc = 0;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, fl->flowi_oif);
+	if (dev && netif_is_l3_master(dev) &&
+	    dev->l3mdev_ops->l3mdev_fib_table) {
+		arg->table = dev->l3mdev_ops->l3mdev_fib_table(dev);
+		rc = 1;
+		goto out;
+	}
+
+	dev = dev_get_by_index_rcu(net, fl->flowi_iif);
+	if (dev && netif_is_l3_master(dev) &&
+	    dev->l3mdev_ops->l3mdev_fib_table) {
+		arg->table = dev->l3mdev_ops->l3mdev_fib_table(dev);
+		rc = 1;
+		goto out;
+	}
+
+out:
+	rcu_read_unlock();
+
+	return rc;
+}
-- 
2.1.4
