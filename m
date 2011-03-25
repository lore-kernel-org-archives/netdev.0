From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Fix nexthop caching wrt. scoping.
Date: Thu, 24 Mar 2011 18:14:18 -0700 (PDT)
Message-ID: <20110324.181418.108774945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933828Ab1CYBNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 21:13:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Move the scope value out of the fib alias entries and into fib_info,
so that we always use the correct scope when recomputing the nexthop
cached source address.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    6 +++---
 net/ipv4/fib_lookup.h    |    3 +--
 net/ipv4/fib_semantics.c |   15 ++++++++-------
 net/ipv4/fib_trie.c      |   12 ++++--------
 4 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index cd92b92..e5d66ec 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -51,7 +51,6 @@ struct fib_nh {
 	struct fib_info		*nh_parent;
 	unsigned		nh_flags;
 	unsigned char		nh_scope;
-	unsigned char		nh_cfg_scope;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			nh_weight;
 	int			nh_power;
@@ -75,9 +74,10 @@ struct fib_info {
 	struct net		*fib_net;
 	int			fib_treeref;
 	atomic_t		fib_clntref;
-	int			fib_dead;
 	unsigned		fib_flags;
-	int			fib_protocol;
+	unsigned char		fib_dead;
+	unsigned char		fib_protocol;
+	unsigned char		fib_scope;
 	__be32			fib_prefsrc;
 	u32			fib_priority;
 	u32			*fib_metrics;
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 4ec3238..af0f14a 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -10,7 +10,6 @@ struct fib_alias {
 	struct fib_info		*fa_info;
 	u8			fa_tos;
 	u8			fa_type;
-	u8			fa_scope;
 	u8			fa_state;
 	struct rcu_head		rcu;
 };
@@ -29,7 +28,7 @@ extern void fib_release_info(struct fib_info *);
 extern struct fib_info *fib_create_info(struct fib_config *cfg);
 extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			 u32 tb_id, u8 type, u8 scope, __be32 dst,
+			 u32 tb_id, u8 type, __be32 dst,
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 2d4bebc..641a5a2 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -222,7 +222,7 @@ static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 	unsigned int mask = (fib_info_hash_size - 1);
 	unsigned int val = fi->fib_nhs;
 
-	val ^= fi->fib_protocol;
+	val ^= (fi->fib_protocol << 8) | fi->fib_scope;
 	val ^= (__force u32)fi->fib_prefsrc;
 	val ^= fi->fib_priority;
 	for_nexthops(fi) {
@@ -248,6 +248,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 		if (fi->fib_nhs != nfi->fib_nhs)
 			continue;
 		if (nfi->fib_protocol == fi->fib_protocol &&
+		    nfi->fib_scope == fi->fib_scope &&
 		    nfi->fib_prefsrc == fi->fib_prefsrc &&
 		    nfi->fib_priority == fi->fib_priority &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
@@ -328,7 +329,7 @@ void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		goto errout;
 
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
-			    fa->fa_type, fa->fa_scope, key, dst_len,
+			    fa->fa_type, key, dst_len,
 			    fa->fa_tos, fa->fa_info, nlm_flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in fib_nlmsg_size() */
@@ -699,7 +700,7 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
 {
 	nh->nh_saddr = inet_select_addr(nh->nh_dev,
 					nh->nh_gw,
-					nh->nh_cfg_scope);
+					nh->nh_parent->fib_scope);
 	nh->nh_saddr_genid = atomic_read(&net->ipv4.dev_addr_genid);
 
 	return nh->nh_saddr;
@@ -763,6 +764,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 	fi->fib_net = hold_net(net);
 	fi->fib_protocol = cfg->fc_protocol;
+	fi->fib_scope = cfg->fc_scope;
 	fi->fib_flags = cfg->fc_flags;
 	fi->fib_priority = cfg->fc_priority;
 	fi->fib_prefsrc = cfg->fc_prefsrc;
@@ -864,7 +866,6 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	change_nexthops(fi) {
-		nexthop_nh->nh_cfg_scope = cfg->fc_scope;
 		fib_info_update_nh_saddr(net, nexthop_nh);
 	} endfor_nexthops(fi)
 
@@ -914,7 +915,7 @@ failure:
 }
 
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos,
+		  u32 tb_id, u8 type, __be32 dst, int dst_len, u8 tos,
 		  struct fib_info *fi, unsigned int flags)
 {
 	struct nlmsghdr *nlh;
@@ -936,7 +937,7 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 	NLA_PUT_U32(skb, RTA_TABLE, tb_id);
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
-	rtm->rtm_scope = scope;
+	rtm->rtm_scope = fi->fib_scope;
 	rtm->rtm_protocol = fi->fib_protocol;
 
 	if (rtm->rtm_dst_len)
@@ -1092,7 +1093,7 @@ void fib_select_default(struct fib_result *res)
 	list_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_info *next_fi = fa->fa_info;
 
-		if (fa->fa_scope != res->scope ||
+		if (next_fi->fib_scope != res->scope ||
 		    fa->fa_type != RTN_UNICAST)
 			continue;
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ac87a49..90a3ff6 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1245,7 +1245,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
 			if (fa->fa_type == cfg->fc_type &&
-			    fa->fa_scope == cfg->fc_scope &&
 			    fa->fa_info == fi) {
 				fa_match = fa;
 				break;
@@ -1271,7 +1270,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_tos = fa->fa_tos;
 			new_fa->fa_info = fi;
 			new_fa->fa_type = cfg->fc_type;
-			new_fa->fa_scope = cfg->fc_scope;
 			state = fa->fa_state;
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 
@@ -1308,7 +1306,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
 	new_fa->fa_type = cfg->fc_type;
-	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
 	/*
 	 * Insert new entry to the list.
@@ -1362,7 +1359,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 
 			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
 				continue;
-			if (fa->fa_scope < flp->flowi4_scope)
+			if (fa->fa_info->fib_scope < flp->flowi4_scope)
 				continue;
 			fib_alias_accessed(fa);
 			err = fib_props[fa->fa_type].error;
@@ -1388,7 +1385,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 				res->prefixlen = plen;
 				res->nh_sel = nhsel;
 				res->type = fa->fa_type;
-				res->scope = fa->fa_scope;
+				res->scope = fa->fa_info->fib_scope;
 				res->fi = fi;
 				res->table = tb;
 				res->fa_head = &li->falh;
@@ -1664,7 +1661,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 
 		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
 		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
-		     fa->fa_scope == cfg->fc_scope) &&
+		     fa->fa_info->fib_scope == cfg->fc_scope) &&
 		    (!cfg->fc_prefsrc ||
 		     fi->fib_prefsrc == cfg->fc_prefsrc) &&
 		    (!cfg->fc_protocol ||
@@ -1863,7 +1860,6 @@ static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 				  RTM_NEWROUTE,
 				  tb->tb_id,
 				  fa->fa_type,
-				  fa->fa_scope,
 				  xkey,
 				  plen,
 				  fa->fa_tos,
@@ -2384,7 +2380,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 				seq_indent(seq, iter->depth+1);
 				seq_printf(seq, "  /%d %s %s", li->plen,
 					   rtn_scope(buf1, sizeof(buf1),
-						     fa->fa_scope),
+						     fa->fa_info->fib_scope),
 					   rtn_type(buf2, sizeof(buf2),
 						    fa->fa_type));
 				if (fa->fa_tos)
-- 
1.7.4.1

