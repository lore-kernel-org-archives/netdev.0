From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/25] ipv4: Pass ipv4 flow objects into fib_lookup() paths.
Date: Sat, 12 Mar 2011 15:27:21 -0800 (PST)
Message-ID: <20110312.152721.102550555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37585
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756024Ab1CLX0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:26:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6FB1624C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:27:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To start doing these conversions, we need to add some temporary
flow4_* macros which will eventually go away when all the protocol
code paths are changed to work on AF specific flowi objects.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h       |    8 ++++++++
 include/net/ip_fib.h     |    6 +++---
 net/ipv4/fib_frontend.c  |    8 ++++----
 net/ipv4/fib_rules.c     |    6 +++---
 net/ipv4/fib_semantics.c |    2 +-
 net/ipv4/fib_trie.c      |   12 ++++++------
 net/ipv4/route.c         |    6 +++---
 7 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8139257..3e4630e 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -50,6 +50,14 @@ union flowi_uli {
 
 struct flowi4 {
 	struct flowi_common	__fl_common;
+#define flowi4_oif		__fl_common.flowic_oif
+#define flowi4_iif		__fl_common.flowic_iif
+#define flowi4_mark		__fl_common.flowic_mark
+#define flowi4_tos		__fl_common.flowic_tos
+#define flowi4_scope		__fl_common.flowic_scope
+#define flowi4_proto		__fl_common.flowic_proto
+#define flowi4_flags		__fl_common.flowic_flags
+#define flowi4_secid		__fl_common.flowic_secid
 	__be32			daddr;
 	__be32			saddr;
 	union flowi_uli		uli;
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index d948e23..a1a8580 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -155,7 +155,7 @@ struct fib_table {
 	unsigned char	tb_data[0];
 };
 
-extern int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
+extern int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			    struct fib_result *res, int fib_flags);
 extern int fib_table_insert(struct fib_table *, struct fib_config *);
 extern int fib_table_delete(struct fib_table *, struct fib_config *);
@@ -186,7 +186,7 @@ static inline struct fib_table *fib_new_table(struct net *net, u32 id)
 	return fib_get_table(net, id);
 }
 
-static inline int fib_lookup(struct net *net, const struct flowi *flp,
+static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 			     struct fib_result *res)
 {
 	struct fib_table *table;
@@ -209,7 +209,7 @@ extern void __net_exit fib4_rules_exit(struct net *net);
 extern u32 fib_rules_tclass(const struct fib_result *res);
 #endif
 
-extern int fib_lookup(struct net *n, struct flowi *flp, struct fib_result *res);
+extern int fib_lookup(struct net *n, struct flowi4 *flp, struct fib_result *res);
 
 extern struct fib_table *fib_new_table(struct net *net, u32 id);
 extern struct fib_table *fib_get_table(struct net *net, u32 id);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7610528..48125d5 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -158,7 +158,7 @@ static inline unsigned __inet_dev_addr_type(struct net *net,
 	if (local_table) {
 		ret = RTN_UNICAST;
 		rcu_read_lock();
-		if (!fib_table_lookup(local_table, &fl, &res, FIB_LOOKUP_NOREF)) {
+		if (!fib_table_lookup(local_table, &fl.u.ip4, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
 		}
@@ -222,7 +222,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		goto e_inval;
 
 	net = dev_net(dev);
-	if (fib_lookup(net, &fl, &res))
+	if (fib_lookup(net, &fl.u.ip4, &res))
 		goto last_resort;
 	if (res.type != RTN_UNICAST) {
 		if (res.type != RTN_LOCAL || !accept_local)
@@ -256,7 +256,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	fl.flowi_oif = dev->ifindex;
 
 	ret = 0;
-	if (fib_lookup(net, &fl, &res) == 0) {
+	if (fib_lookup(net, &fl.u.ip4, &res) == 0) {
 		if (res.type == RTN_UNICAST) {
 			*spec_dst = FIB_RES_PREFSRC(res);
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
@@ -813,7 +813,7 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 
 		frn->tb_id = tb->tb_id;
 		rcu_read_lock();
-		frn->err = fib_table_lookup(tb, &fl, &res, FIB_LOOKUP_NOREF);
+		frn->err = fib_table_lookup(tb, &fl.u.ip4, &res, FIB_LOOKUP_NOREF);
 
 		if (!frn->err) {
 			frn->prefixlen = res.prefixlen;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 3018efb..0c63c4a 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -53,7 +53,7 @@ u32 fib_rules_tclass(const struct fib_result *res)
 }
 #endif
 
-int fib_lookup(struct net *net, struct flowi *flp, struct fib_result *res)
+int fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_lookup_arg arg = {
 		.result = res,
@@ -61,7 +61,7 @@ int fib_lookup(struct net *net, struct flowi *flp, struct fib_result *res)
 	};
 	int err;
 
-	err = fib_rules_lookup(net->ipv4.rules_ops, flp, 0, &arg);
+	err = fib_rules_lookup(net->ipv4.rules_ops, flowi4_to_flowi(flp), 0, &arg);
 	res->r = arg.rule;
 
 	return err;
@@ -95,7 +95,7 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 	if (!tbl)
 		goto errout;
 
-	err = fib_table_lookup(tbl, flp, (struct fib_result *) arg->result, arg->flags);
+	err = fib_table_lookup(tbl, &flp->u.ip4, (struct fib_result *) arg->result, arg->flags);
 	if (err > 0)
 		err = -EAGAIN;
 errout:
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 79179ad..a721013 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -569,7 +569,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			/* It is not necessary, but requires a bit of thinking */
 			if (fl.fl4_scope < RT_SCOPE_LINK)
 				fl.fl4_scope = RT_SCOPE_LINK;
-			err = fib_lookup(net, &fl, &res);
+			err = fib_lookup(net, &fl.u.ip4, &res);
 			if (err) {
 				rcu_read_unlock();
 				return err;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d5ff80e..3d28a35 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1341,7 +1341,7 @@ err:
 
 /* should be called with rcu_read_lock */
 static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
-		      t_key key,  const struct flowi *flp,
+		      t_key key,  const struct flowi4 *flp,
 		      struct fib_result *res, int fib_flags)
 {
 	struct leaf_info *li;
@@ -1360,9 +1360,9 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 			struct fib_info *fi = fa->fa_info;
 			int nhsel, err;
 
-			if (fa->fa_tos && fa->fa_tos != flp->fl4_tos)
+			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
 				continue;
-			if (fa->fa_scope < flp->fl4_scope)
+			if (fa->fa_scope < flp->flowi4_scope)
 				continue;
 			fib_alias_accessed(fa);
 			err = fib_props[fa->fa_type].error;
@@ -1379,7 +1379,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 
 				if (nh->nh_flags & RTNH_F_DEAD)
 					continue;
-				if (flp->flowi_oif && flp->flowi_oif != nh->nh_oif)
+				if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
 					continue;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -1406,7 +1406,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 	return 1;
 }
 
-int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
+int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
@@ -1414,7 +1414,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 	struct rt_trie_node *n;
 	struct tnode *pn;
 	unsigned int pos, bits;
-	t_key key = ntohl(flp->fl4_dst);
+	t_key key = ntohl(flp->daddr);
 	unsigned int chopped_off;
 	t_key cindex = 0;
 	unsigned int current_prefix_length = KEYLENGTH;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c9aa4f9..027b4cc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1707,7 +1707,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 		};
 
 		rcu_read_lock();
-		if (fib_lookup(dev_net(rt->dst.dev), &fl, &res) == 0)
+		if (fib_lookup(dev_net(rt->dst.dev), &fl.u.ip4, &res) == 0)
 			src = FIB_RES_PREFSRC(res);
 		else
 			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
@@ -2125,7 +2125,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl.fl4_src = saddr;
 	fl.fl4_tos = tos;
 	fl.fl4_scope = RT_SCOPE_UNIVERSE;
-	err = fib_lookup(net, &fl, &res);
+	err = fib_lookup(net, &fl.u.ip4, &res);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			goto e_hostunreach;
@@ -2551,7 +2551,7 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		goto make_route;
 	}
 
-	if (fib_lookup(net, &fl, &res)) {
+	if (fib_lookup(net, &fl.u.ip4, &res)) {
 		res.fi = NULL;
 		if (oldflp->flowi_oif) {
 			/* Apparently, routing tables are wrong. Assume,
-- 
1.7.4.1

