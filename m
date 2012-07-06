From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Avoid overhead when no custom FIB rules are
 installed.
Date: Thu, 05 Jul 2012 22:31:42 -0700 (PDT)
Message-ID: <20120705.223142.2236039770560842377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab2GFFbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 01:31:44 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1A39C584F0E
	for <netdev@vger.kernel.org>; Thu,  5 Jul 2012 22:31:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If the user hasn't actually installed any custom rules, or fiddled
with the default ones, don't go through the whole FIB rules layer.

It's just pure overhead.

Instead do what we do with CONFIG_IP_MULTIPLE_TABLES disabled, check
the individual tables by hand, one by one.

Also, move fib_num_tclassid_users into the ipv4 network namespace.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |   36 ++++++++++++++++++++++++++++++++----
 include/net/netns/ipv4.h |    8 ++++++++
 net/ipv4/fib_frontend.c  |   27 ++++++++++++++++++++++-----
 net/ipv4/fib_rules.c     |   12 ++++++++----
 net/ipv4/fib_semantics.c |    6 +++---
 5 files changed, 73 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3dc7c96..539c672 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -220,11 +220,33 @@ extern void __net_exit fib4_rules_exit(struct net *net);
 extern u32 fib_rules_tclass(const struct fib_result *res);
 #endif
 
-extern int fib_lookup(struct net *n, struct flowi4 *flp, struct fib_result *res);
-
 extern struct fib_table *fib_new_table(struct net *net, u32 id);
 extern struct fib_table *fib_get_table(struct net *net, u32 id);
 
+extern int __fib_lookup(struct net *net, struct flowi4 *flp,
+			struct fib_result *res);
+
+static inline int fib_lookup(struct net *net, struct flowi4 *flp,
+			     struct fib_result *res)
+{
+	if (!net->ipv4.fib_has_custom_rules) {
+		if (net->ipv4.fib_local &&
+		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
+				      FIB_LOOKUP_NOREF))
+			return 0;
+		if (net->ipv4.fib_main &&
+		    !fib_table_lookup(net->ipv4.fib_main, flp, res,
+				      FIB_LOOKUP_NOREF))
+			return 0;
+		if (net->ipv4.fib_default &&
+		    !fib_table_lookup(net->ipv4.fib_default, flp, res,
+				      FIB_LOOKUP_NOREF))
+			return 0;
+		return -ENETUNREACH;
+	}
+	return __fib_lookup(net, flp, res);
+}
+
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 /* Exported by fib_frontend.c */
@@ -236,9 +258,15 @@ extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			       struct in_device *idev, u32 *itag);
 extern void fib_select_default(struct fib_result *res);
 #ifdef CONFIG_IP_ROUTE_CLASSID
-extern int fib_num_tclassid_users;
+static inline int fib_num_tclassid_users(struct net *net)
+{
+	return net->ipv4.fib_num_tclassid_users;
+}
 #else
-#define fib_num_tclassid_users 0
+static inline int fib_num_tclassid_users(struct net *net)
+{
+	return 0;
+}
 #endif
 
 /* Exported by fib_semantics.c */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 227f0cd..599e48f 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -11,6 +11,7 @@ struct ctl_table_header;
 struct ipv4_devconf;
 struct fib_rules_ops;
 struct hlist_head;
+struct fib_table;
 struct sock;
 
 struct netns_ipv4 {
@@ -24,6 +25,13 @@ struct netns_ipv4 {
 	struct ipv4_devconf	*devconf_dflt;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rules_ops	*rules_ops;
+	bool			fib_has_custom_rules;
+	struct fib_table	*fib_local;
+	struct fib_table	*fib_main;
+	struct fib_table	*fib_default;
+#endif
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	int			fib_num_tclassid_users;
 #endif
 	struct hlist_head	*fib_table_hash;
 	struct sock		*fibnl;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3e11ea2..81f8571 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -86,6 +86,24 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	tb = fib_trie_table(id);
 	if (!tb)
 		return NULL;
+
+	switch (id) {
+	case RT_TABLE_LOCAL:
+		net->ipv4.fib_local = tb;
+		break;
+
+	case RT_TABLE_MAIN:
+		net->ipv4.fib_main = tb;
+		break;
+
+	case RT_TABLE_DEFAULT:
+		net->ipv4.fib_default = tb;
+		break;
+
+	default:
+		break;
+	}
+
 	h = id & (FIB_TABLE_HASHSZ - 1);
 	hlist_add_head_rcu(&tb->tb_hlist, &net->ipv4.fib_table_hash[h]);
 	return tb;
@@ -218,10 +236,6 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	return inet_select_addr(dev, ip_hdr(skb)->saddr, scope);
 }
 
-#ifdef CONFIG_IP_ROUTE_CLASSID
-int fib_num_tclassid_users __read_mostly;
-#endif
-
 /* Given (packet source, input interface) and optional (dst, oif, tos):
  * - (main) check, that source is valid i.e. not broadcast or our local
  *   address.
@@ -312,7 +326,7 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 {
 	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
 
-	if (!r && !fib_num_tclassid_users) {
+	if (!r && !fib_num_tclassid_users(dev_net(dev))) {
 		*itag = 0;
 		return 0;
 	}
@@ -1134,6 +1148,9 @@ static int __net_init fib_net_init(struct net *net)
 {
 	int error;
 
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	net->ipv4.fib_num_tclassid_users = 0;
+#endif
 	error = ip_fib_net_init(net);
 	if (error < 0)
 		goto out;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index b23fd95..c06da93 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -54,7 +54,7 @@ u32 fib_rules_tclass(const struct fib_result *res)
 }
 #endif
 
-int fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
+int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_lookup_arg arg = {
 		.result = res,
@@ -67,7 +67,7 @@ int fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(fib_lookup);
+EXPORT_SYMBOL_GPL(__fib_lookup);
 
 static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 			    int flags, struct fib_lookup_arg *arg)
@@ -172,7 +172,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	if (tb[FRA_FLOW]) {
 		rule4->tclassid = nla_get_u32(tb[FRA_FLOW]);
 		if (rule4->tclassid)
-			fib_num_tclassid_users++;
+			net->ipv4.fib_num_tclassid_users++;
 	}
 #endif
 
@@ -182,6 +182,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule4->dstmask = inet_make_mask(rule4->dst_len);
 	rule4->tos = frh->tos;
 
+	net->ipv4.fib_has_custom_rules = true;
 	err = 0;
 errout:
 	return err;
@@ -189,12 +190,14 @@ errout:
 
 static void fib4_rule_delete(struct fib_rule *rule)
 {
+	struct net *net = rule->fr_net;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
 	if (rule4->tclassid)
-		fib_num_tclassid_users--;
+		net->ipv4.fib_num_tclassid_users--;
 #endif
+	net->ipv4.fib_has_custom_rules = true;
 }
 
 static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
@@ -309,6 +312,7 @@ int __net_init fib4_rules_init(struct net *net)
 	if (err < 0)
 		goto fail;
 	net->ipv4.rules_ops = ops;
+	net->ipv4.fib_has_custom_rules = false;
 	return 0;
 
 fail:
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c46c20b..ae301c8 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -166,7 +166,7 @@ void free_fib_info(struct fib_info *fi)
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_tclassid)
-			fib_num_tclassid_users--;
+			fi->fib_net->ipv4.fib_num_tclassid_users--;
 	} endfor_nexthops(fi);
 #endif
 	call_rcu(&fi->rcu, free_fib_info_rcu);
@@ -428,7 +428,7 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
 			nexthop_nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
 			if (nexthop_nh->nh_tclassid)
-				fib_num_tclassid_users++;
+				fi->fib_net->ipv4.fib_num_tclassid_users++;
 #endif
 		}
 
@@ -824,7 +824,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		nh->nh_tclassid = cfg->fc_flow;
 		if (nh->nh_tclassid)
-			fib_num_tclassid_users++;
+			fi->fib_net->ipv4.fib_num_tclassid_users++;
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		nh->nh_weight = 1;
-- 
1.7.10
