From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Elide fib_validate_source() completely when possible.
Date: Fri, 29 Jun 2012 02:05:52 -0700 (PDT)
Message-ID: <20120629.020552.2190372012516348013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab2F2JFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 05:05:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B21D9584C9A
	for <netdev@vger.kernel.org>; Fri, 29 Jun 2012 02:05:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If rpfilter is off (or the SKB has an IPSEC path) and there are not
tclassid users, we don't have to do anything at all when
fib_validate_source() is invoked besides setting the itag to zero.

We monitor tclassid uses with a counter (modified only under RTNL and
marked __read_mostly) and we protect the fib_validate_source() real
work with a test against this counter and whether rpfilter is to be
done.

Having a way to know whether we need no tclassid processing or not
also opens the door for future optimized rpfilter algorithms that do
not perform full FIB lookups.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/fib_rules.h  |    1 +
 include/net/ip_fib.h     |    5 +++++
 net/core/fib_rules.c     |    4 ++++
 net/ipv4/fib_frontend.c  |   32 ++++++++++++++++++++++++--------
 net/ipv4/fib_rules.c     |   16 +++++++++++++++-
 net/ipv4/fib_semantics.c |   10 ++++++++++
 6 files changed, 59 insertions(+), 9 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 075f1e3..e361f48 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -52,6 +52,7 @@ struct fib_rules_ops {
 					     struct sk_buff *,
 					     struct fib_rule_hdr *,
 					     struct nlattr **);
+	void			(*delete)(struct fib_rule *);
 	int			(*compare)(struct fib_rule *,
 					   struct fib_rule_hdr *,
 					   struct nlattr **);
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 619f68a..3dc7c96 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -235,6 +235,11 @@ extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			       u8 tos, int oif, struct net_device *dev,
 			       struct in_device *idev, u32 *itag);
 extern void fib_select_default(struct fib_result *res);
+#ifdef CONFIG_IP_ROUTE_CLASSID
+extern int fib_num_tclassid_users;
+#else
+#define fib_num_tclassid_users 0
+#endif
 
 /* Exported by fib_semantics.c */
 extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 72cceb7..ab7db83 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -151,6 +151,8 @@ static void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 
 	list_for_each_entry_safe(rule, tmp, &ops->rules_list, list) {
 		list_del_rcu(&rule->list);
+		if (ops->delete)
+			ops->delete(rule);
 		fib_rule_put(rule);
 	}
 }
@@ -499,6 +501,8 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).pid);
+		if (ops->delete)
+			ops->delete(rule);
 		fib_rule_put(rule);
 		flush_route_cache(ops);
 		rules_ops_put(ops);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c84cff5..ae528d1 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -31,6 +31,7 @@
 #include <linux/if_addr.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
+#include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -217,6 +218,10 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	return inet_select_addr(dev, ip_hdr(skb)->saddr, scope);
 }
 
+#ifdef CONFIG_IP_ROUTE_CLASSID
+int fib_num_tclassid_users __read_mostly;
+#endif
+
 /* Given (packet source, input interface) and optional (dst, oif, tos):
  * - (main) check, that source is valid i.e. not broadcast or our local
  *   address.
@@ -225,11 +230,11 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
  * - check, that packet arrived from expected physical interface.
  * called with rcu_read_lock()
  */
-int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
-			int oif, struct net_device *dev, struct in_device *idev,
-			u32 *itag)
+static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
+				 u8 tos, int oif, struct net_device *dev,
+				 int rpf, struct in_device *idev, u32 *itag)
 {
-	int ret, no_addr, rpf, accept_local;
+	int ret, no_addr, accept_local;
 	struct fib_result res;
 	struct flowi4 fl4;
 	struct net *net;
@@ -242,12 +247,9 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 
-	no_addr = rpf = accept_local = 0;
+	no_addr = accept_local = 0;
 	no_addr = idev->ifa_list == NULL;
 
-	/* Ignore rp_filter for packets protected by IPsec. */
-	rpf = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
-
 	accept_local = IN_DEV_ACCEPT_LOCAL(idev);
 	fl4.flowi4_mark = IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
 
@@ -303,6 +305,20 @@ e_rpf:
 	return -EXDEV;
 }
 
+/* Ignore rp_filter for packets protected by IPsec. */
+int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
+			u8 tos, int oif, struct net_device *dev,
+			struct in_device *idev, u32 *itag)
+{
+	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
+
+	if (!r && !fib_num_tclassid_users) {
+		*itag = 0;
+		return 0;
+	}
+	return __fib_validate_source(skb, src, dst, tos, oif, dev, r, idev, itag);
+}
+
 static inline __be32 sk_extract_addr(struct sockaddr *addr)
 {
 	return ((struct sockaddr_in *) addr)->sin_addr.s_addr;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 2d043f7..b23fd95 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -169,8 +169,11 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
-	if (tb[FRA_FLOW])
+	if (tb[FRA_FLOW]) {
 		rule4->tclassid = nla_get_u32(tb[FRA_FLOW]);
+		if (rule4->tclassid)
+			fib_num_tclassid_users++;
+	}
 #endif
 
 	rule4->src_len = frh->src_len;
@@ -184,6 +187,16 @@ errout:
 	return err;
 }
 
+static void fib4_rule_delete(struct fib_rule *rule)
+{
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
+
+	if (rule4->tclassid)
+		fib_num_tclassid_users--;
+#endif
+}
+
 static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
 			     struct nlattr **tb)
 {
@@ -256,6 +269,7 @@ static const struct fib_rules_ops __net_initdata fib4_rules_ops_template = {
 	.action		= fib4_rule_action,
 	.match		= fib4_rule_match,
 	.configure	= fib4_rule_configure,
+	.delete		= fib4_rule_delete,
 	.compare	= fib4_rule_compare,
 	.fill		= fib4_rule_fill,
 	.default_pref	= fib_default_rule_pref,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 415f823..c46c20b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -163,6 +163,12 @@ void free_fib_info(struct fib_info *fi)
 		return;
 	}
 	fib_info_cnt--;
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	change_nexthops(fi) {
+		if (nexthop_nh->nh_tclassid)
+			fib_num_tclassid_users--;
+	} endfor_nexthops(fi);
+#endif
 	call_rcu(&fi->rcu, free_fib_info_rcu);
 }
 
@@ -421,6 +427,8 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
 			nexthop_nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
+			if (nexthop_nh->nh_tclassid)
+				fib_num_tclassid_users++;
 #endif
 		}
 
@@ -815,6 +823,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		nh->nh_flags = cfg->fc_flags;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		nh->nh_tclassid = cfg->fc_flow;
+		if (nh->nh_tclassid)
+			fib_num_tclassid_users++;
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		nh->nh_weight = 1;
-- 
1.7.10
