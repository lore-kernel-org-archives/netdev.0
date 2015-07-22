From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 2/2] ipv4: consider TOS in fib_select_default
Date: Wed, 22 Jul 2015 10:43:23 +0300
Message-ID: <1437551003-25537-3-git-send-email-ja@ssi.bg>
References: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38475 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756048AbbGVHoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 03:44:25 -0400
In-Reply-To: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_select_default considers alternative routes only when
res->fi is for the first alias in res->fa_head. In the
common case this can happen only when the initial lookup
matches the first alias with highest TOS value. This
prevents the alternative routes to require specific TOS.

This patch solves the problem as follows:

- routes that require specific TOS should be returned by
fib_select_default only when TOS matches, as already done
in fib_table_lookup. This rule implies that depending on the
TOS we can have many different lists of alternative gateways
and we have to keep the last used gateway (fa_default) in first
alias for the TOS instead of using single tb_default value.

- as the aliases are ordered by many keys (TOS desc,
fib_priority asc), we restrict the possible results to
routes with matching TOS and lowest metric (fib_priority)
and routes that match any TOS, again with lowest metric.

For example, packet with TOS 8 can not use gw3 (not lowest
metric), gw4 (different TOS) and gw6 (not lowest metric),
all other gateways can be used:

tos 8 via gw1 metric 2 <--- res->fa_head and res->fi
tos 8 via gw2 metric 2
tos 8 via gw3 metric 3
tos 4 via gw4
tos 0 via gw5
tos 0 via gw6 metric 1

Reported-by: Hagen Paul Pfeifer <hagen@jauu.net>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_fib.h     |  3 +--
 net/ipv4/fib_lookup.h    |  1 +
 net/ipv4/fib_semantics.c | 36 +++++++++++++++++++++++++-----------
 net/ipv4/fib_trie.c      |  3 ++-
 net/ipv4/route.c         |  2 +-
 5 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 49c142b..5fa643b 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -183,7 +183,6 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 struct fib_table {
 	struct hlist_node	tb_hlist;
 	u32			tb_id;
-	int			tb_default;
 	int			tb_num_default;
 	struct rcu_head		rcu;
 	unsigned long 		*tb_data;
@@ -290,7 +289,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb);
 int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			u8 tos, int oif, struct net_device *dev,
 			struct in_device *idev, u32 *itag);
-void fib_select_default(struct fib_result *res);
+void fib_select_default(const struct flowi4 *flp, struct fib_result *res);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 static inline int fib_num_tclassid_users(struct net *net)
 {
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index c6211ed..9c02920 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -13,6 +13,7 @@ struct fib_alias {
 	u8			fa_state;
 	u8			fa_slen;
 	u32			tb_id;
+	s16			fa_default;
 	struct rcu_head		rcu;
 };
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e107958..3a06586 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1202,28 +1202,40 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
 }
 
 /* Must be invoked inside of an RCU protected region.  */
-void fib_select_default(struct fib_result *res)
+void fib_select_default(const struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_info *fi = NULL, *last_resort = NULL;
 	struct hlist_head *fa_head = res->fa_head;
 	struct fib_table *tb = res->table;
 	u8 slen = 32 - res->prefixlen;
 	int order = -1, last_idx = -1;
-	struct fib_alias *fa;
+	struct fib_alias *fa, *fa1 = NULL;
+	u32 last_prio = res->fi->fib_priority;
+	u8 last_tos = 0;
 
 	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_info *next_fi = fa->fa_info;
 
 		if (fa->fa_slen != slen)
 			continue;
+		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
+			continue;
 		if (fa->tb_id != tb->tb_id)
 			continue;
+		if (next_fi->fib_priority > last_prio &&
+		    fa->fa_tos == last_tos) {
+			if (last_tos)
+				continue;
+			break;
+		}
+		if (next_fi->fib_flags & RTNH_F_DEAD)
+			continue;
+		last_tos = fa->fa_tos;
+		last_prio = next_fi->fib_priority;
+
 		if (next_fi->fib_scope != res->scope ||
 		    fa->fa_type != RTN_UNICAST)
 			continue;
-
-		if (next_fi->fib_priority > res->fi->fib_priority)
-			break;
 		if (!next_fi->fib_nh[0].nh_gw ||
 		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
 			continue;
@@ -1233,10 +1245,11 @@ void fib_select_default(struct fib_result *res)
 		if (!fi) {
 			if (next_fi != res->fi)
 				break;
+			fa1 = fa;
 		} else if (!fib_detect_death(fi, order, &last_resort,
-					     &last_idx, tb->tb_default)) {
+					     &last_idx, fa1->fa_default)) {
 			fib_result_assign(res, fi);
-			tb->tb_default = order;
+			fa1->fa_default = order;
 			goto out;
 		}
 		fi = next_fi;
@@ -1244,20 +1257,21 @@ void fib_select_default(struct fib_result *res)
 	}
 
 	if (order <= 0 || !fi) {
-		tb->tb_default = -1;
+		if (fa1)
+			fa1->fa_default = -1;
 		goto out;
 	}
 
 	if (!fib_detect_death(fi, order, &last_resort, &last_idx,
-				tb->tb_default)) {
+			      fa1->fa_default)) {
 		fib_result_assign(res, fi);
-		tb->tb_default = order;
+		fa1->fa_default = order;
 		goto out;
 	}
 
 	if (last_idx >= 0)
 		fib_result_assign(res, last_resort);
-	tb->tb_default = last_idx;
+	fa1->fa_default = last_idx;
 out:
 	return;
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 15d3261..81797e0 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1171,6 +1171,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
 			new_fa->tb_id = tb->tb_id;
+			new_fa->fa_default = -1;
 
 			err = switchdev_fib_ipv4_add(key, plen, fi,
 						     new_fa->fa_tos,
@@ -1222,6 +1223,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_state = 0;
 	new_fa->fa_slen = slen;
 	new_fa->tb_id = tb->tb_id;
+	new_fa->fa_default = -1;
 
 	/* (Optionally) offload fib entry to switch hardware. */
 	err = switchdev_fib_ipv4_add(key, plen, fi, tos, cfg->fc_type,
@@ -1990,7 +1992,6 @@ struct fib_table *fib_trie_table(u32 id, struct fib_table *alias)
 		return NULL;
 
 	tb->tb_id = id;
-	tb->tb_default = -1;
 	tb->tb_num_default = 0;
 	tb->tb_data = (alias ? alias->__data : tb->__data);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d0362a2..e681b85 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2176,7 +2176,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	if (!res.prefixlen &&
 	    res.table->tb_num_default > 1 &&
 	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
-		fib_select_default(&res);
+		fib_select_default(fl4, &res);
 
 	if (!fl4->saddr)
 		fl4->saddr = FIB_RES_PREFSRC(net, res);
-- 
1.9.3
