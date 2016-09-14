From: Vincent Bernat <vincent@bernat.im>
Subject: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 14:40:25 +0200
Message-ID: <20160914124025.13417-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:57196 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932584AbcINMqS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 08:46:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a user wants to assign a routing table to a group of incoming
interfaces, the current solutions are:

 - one IP rule for each interface (scalability problems)
 - use of fwmark and devgroup matcher (don't work with internal route
   lookups, used for example by RPF)
 - use of VRF devices (more complex)

Each interface can be assigned to a numeric group using IFLA_GROUP. This
commit enables a user to reference such a group into an IP rule. Here is
an example of output of iproute2:

    $ ip rule show
    0:      from all lookup local
    32764:  from all iifgroup 2 lookup 2
    32765:  from all iifgroup 1 lookup 1
    32766:  from all lookup main
    32767:  from all lookup default

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 include/net/fib_rules.h        |  6 ++++-
 include/uapi/linux/fib_rules.h |  2 ++
 net/core/fib_rules.c           | 57 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 63 insertions(+), 2 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 456e4a6006ab..a96b186ccd02 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -28,6 +28,8 @@ struct fib_rule {
 	u32			pref;
 	int			suppress_ifgroup;
 	int			suppress_prefixlen;
+	int			iifgroup;
+	int			oifgroup;
 	char			iifname[IFNAMSIZ];
 	char			oifname[IFNAMSIZ];
 	struct rcu_head		rcu;
@@ -92,7 +94,9 @@ struct fib_rules_ops {
 	[FRA_SUPPRESS_PREFIXLEN] = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_IFGROUP] = { .type = NLA_U32 }, \
 	[FRA_GOTO]	= { .type = NLA_U32 }, \
-	[FRA_L3MDEV]	= { .type = NLA_U8 }
+	[FRA_L3MDEV]	= { .type = NLA_U8 }, \
+	[FRA_IIFGROUP] = { .type = NLA_U32 }, \
+	[FRA_OIFGROUP] = { .type = NLA_U32 }
 
 static inline void fib_rule_get(struct fib_rule *rule)
 {
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 14404b3ebb89..0bf5a5e94d9a 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -51,6 +51,8 @@ enum {
 	FRA_OIFNAME,
 	FRA_PAD,
 	FRA_L3MDEV,	/* iif or oif is l3mdev goto its table */
+	FRA_IIFGROUP,	/* interface group */
+	FRA_OIFGROUP,
 	__FRA_MAX
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index be4629c344a6..f8ed6ba85c72 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -37,6 +37,9 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->suppress_prefixlen = -1;
 	r->suppress_ifgroup = -1;
 
+	r->iifgroup = -1;
+	r->oifgroup = -1;
+
 	/* The lock is not required here, the list in unreacheable
 	 * at the moment this function is called */
 	list_add_tail(&r->list, &ops->rules_list);
@@ -193,6 +196,30 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if (rule->l3mdev && !l3mdev_fib_rule_match(rule->fr_net, fl, arg))
 		goto out;
 
+	if (rule->iifgroup != -1) {
+		struct net_device *dev;
+
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(rule->fr_net, fl->flowi_iif);
+		if (!dev || dev->group != rule->iifgroup) {
+			rcu_read_unlock();
+			goto out;
+		}
+		rcu_read_unlock();
+	}
+
+	if (rule->oifgroup != -1) {
+		struct net_device *dev;
+
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(rule->fr_net, fl->flowi_oif);
+		if (!dev || dev->group != rule->oifgroup) {
+			rcu_read_unlock();
+			goto out;
+		}
+		rcu_read_unlock();
+	}
+
 	ret = ops->match(rule, fl, flags);
 out:
 	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
@@ -305,6 +332,12 @@ static int rule_exists(struct fib_rules_ops *ops, struct fib_rule_hdr *frh,
 		if (r->l3mdev != rule->l3mdev)
 			continue;
 
+		if (r->iifgroup != rule->iifgroup)
+			continue;
+
+		if (r->oifgroup != rule->oifgroup)
+			continue;
+
 		if (!ops->compare(r, frh, tb))
 			continue;
 		return 1;
@@ -391,6 +424,16 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 			goto errout_free;
 	}
 
+	if (tb[FRA_IIFGROUP])
+		rule->iifgroup = nla_get_u32(tb[FRA_IIFGROUP]);
+	else
+		rule->iifgroup = -1;
+
+	if (tb[FRA_OIFGROUP])
+		rule->oifgroup = nla_get_u32(tb[FRA_OIFGROUP]);
+	else
+		rule->oifgroup = -1;
+
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
@@ -552,6 +595,14 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 		    (rule->l3mdev != nla_get_u8(tb[FRA_L3MDEV])))
 			continue;
 
+		if (tb[FRA_IIFGROUP] &&
+		    (rule->iifgroup != nla_get_u32(tb[FRA_IIFGROUP])))
+			continue;
+
+		if (tb[FRA_OIFGROUP] &&
+		    (rule->oifgroup != nla_get_u32(tb[FRA_OIFGROUP])))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -679,7 +730,11 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    (rule->tun_id &&
 	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id, FRA_PAD)) ||
 	    (rule->l3mdev &&
-	     nla_put_u8(skb, FRA_L3MDEV, rule->l3mdev)))
+	     nla_put_u8(skb, FRA_L3MDEV, rule->l3mdev)) ||
+	    ((rule->iifgroup != -1) &&
+	     nla_put_u32(skb, FRA_IIFGROUP, rule->iifgroup)) ||
+	    ((rule->oifgroup != -1) &&
+	     nla_put_u32(skb, FRA_OIFGROUP, rule->oifgroup)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
-- 
2.9.3
