From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 10/17] fib_trie: Push rcu_read_lock/unlock to
 callers
Date: Wed, 31 Dec 2014 10:56:24 -0800
Message-ID: <20141231185624.3006.94.stgit@ahduyck-vm-fedora20>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbaLaS40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 13:56:26 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBVIuPES006261
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:56:26 -0500
Received: from [192.168.122.173] (ovpn-112-50.phx2.redhat.com [10.3.112.50])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBVIuPiE001450
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:56:25 -0500
In-Reply-To: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is to start cleaning up some of the rcu_read_lock/unlock
handling.  I realized while reviewing the code there are several spots that
I don't believe are being handled correctly or are masking warnings by
locally calling rcu_read_lock/unlock instead of calling them at the correct
level.

A common example is a call to fib_get_table followed by fib_table_lookup.
The rcu_read_lock/unlock ought to wrap both but there are several spots where
they were not wrapped.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/net/ip_fib.h    |   50 ++++++++++-------
 net/ipv4/fib_frontend.c |   27 +++++----
 net/ipv4/fib_rules.c    |   22 +++-----
 net/ipv4/fib_trie.c     |  137 +++++++++++++++++++++--------------------------
 4 files changed, 114 insertions(+), 122 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 09a819e..5bd120e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -222,16 +222,19 @@ static inline struct fib_table *fib_new_table(struct net *net, u32 id)
 static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 			     struct fib_result *res)
 {
-	struct fib_table *table;
+	int err = -ENETUNREACH;
+
+	rcu_read_lock();
+
+	if (!fib_table_lookup(fib_get_table(net, RT_TABLE_LOCAL), flp, res,
+			      FIB_LOOKUP_NOREF) ||
+	    !fib_table_lookup(fib_get_table(net, RT_TABLE_MAIN), flp, res,
+			      FIB_LOOKUP_NOREF))
+		err = 0;
 
-	table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
-		return 0;
+	rcu_read_unlock();
 
-	table = fib_get_table(net, RT_TABLE_MAIN);
-	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
-		return 0;
-	return -ENETUNREACH;
+	return err;
 }
 
 #else /* CONFIG_IP_MULTIPLE_TABLES */
@@ -247,20 +250,25 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 			     struct fib_result *res)
 {
 	if (!net->ipv4.fib_has_custom_rules) {
+		int err = -ENETUNREACH;
+
+		rcu_read_lock();
+
 		res->tclassid = 0;
-		if (net->ipv4.fib_local &&
-		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
-				      FIB_LOOKUP_NOREF))
-			return 0;
-		if (net->ipv4.fib_main &&
-		    !fib_table_lookup(net->ipv4.fib_main, flp, res,
-				      FIB_LOOKUP_NOREF))
-			return 0;
-		if (net->ipv4.fib_default &&
-		    !fib_table_lookup(net->ipv4.fib_default, flp, res,
-				      FIB_LOOKUP_NOREF))
-			return 0;
-		return -ENETUNREACH;
+		if ((net->ipv4.fib_local &&
+		     !fib_table_lookup(net->ipv4.fib_local, flp, res,
+				       FIB_LOOKUP_NOREF)) ||
+		    (net->ipv4.fib_main &&
+		     !fib_table_lookup(net->ipv4.fib_main, flp, res,
+				       FIB_LOOKUP_NOREF)) ||
+		    (net->ipv4.fib_default &&
+		     !fib_table_lookup(net->ipv4.fib_default, flp, res,
+				       FIB_LOOKUP_NOREF)))
+			err = 0;
+
+		rcu_read_unlock();
+
+		return err;
 	}
 	return __fib_lookup(net, flp, res);
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6689020..57be71d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -109,6 +109,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	return tb;
 }
 
+/* caller must hold either rtnl or rcu read lock */
 struct fib_table *fib_get_table(struct net *net, u32 id)
 {
 	struct fib_table *tb;
@@ -119,15 +120,11 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 		id = RT_TABLE_MAIN;
 	h = id & (FIB_TABLE_HASHSZ - 1);
 
-	rcu_read_lock();
 	head = &net->ipv4.fib_table_hash[h];
 	hlist_for_each_entry_rcu(tb, head, tb_hlist) {
-		if (tb->tb_id == id) {
-			rcu_read_unlock();
+		if (tb->tb_id == id)
 			return tb;
-		}
 	}
-	rcu_read_unlock();
 	return NULL;
 }
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
@@ -167,16 +164,18 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	if (ipv4_is_multicast(addr))
 		return RTN_MULTICAST;
 
+	rcu_read_lock();
+
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
 	if (local_table) {
 		ret = RTN_UNICAST;
-		rcu_read_lock();
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
 		}
-		rcu_read_unlock();
 	}
+
+	rcu_read_unlock();
 	return ret;
 }
 
@@ -919,7 +918,7 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 #undef BRD1_OK
 }
 
-static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
+static void nl_fib_lookup(struct net *net, struct fib_result_nl *frn)
 {
 
 	struct fib_result       res;
@@ -929,6 +928,11 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 		.flowi4_tos = frn->fl_tos,
 		.flowi4_scope = frn->fl_scope,
 	};
+	struct fib_table *tb;
+
+	rcu_read_lock();
+
+	tb = fib_get_table(net, frn->tb_id_in);
 
 	frn->err = -ENOENT;
 	if (tb) {
@@ -945,6 +949,8 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 		}
 		local_bh_enable();
 	}
+
+	rcu_read_unlock();
 }
 
 static void nl_fib_input(struct sk_buff *skb)
@@ -952,7 +958,6 @@ static void nl_fib_input(struct sk_buff *skb)
 	struct net *net;
 	struct fib_result_nl *frn;
 	struct nlmsghdr *nlh;
-	struct fib_table *tb;
 	u32 portid;
 
 	net = sock_net(skb->sk);
@@ -967,9 +972,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	nlh = nlmsg_hdr(skb);
 
 	frn = (struct fib_result_nl *) nlmsg_data(nlh);
-	tb = fib_get_table(net, frn->tb_id_in);
-
-	nl_fib_lookup(frn, tb);
+	nl_fib_lookup(net, frn);
 
 	portid = NETLINK_CB(skb).portid;      /* netlink portid */
 	NETLINK_CB(skb).portid = 0;        /* from kernel */
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 8f7bd56..d3db718 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -81,27 +81,25 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 		break;
 
 	case FR_ACT_UNREACHABLE:
-		err = -ENETUNREACH;
-		goto errout;
+		return -ENETUNREACH;
 
 	case FR_ACT_PROHIBIT:
-		err = -EACCES;
-		goto errout;
+		return -EACCES;
 
 	case FR_ACT_BLACKHOLE:
 	default:
-		err = -EINVAL;
-		goto errout;
+		return -EINVAL;
 	}
 
+	rcu_read_lock();
+
 	tbl = fib_get_table(rule->fr_net, rule->table);
-	if (!tbl)
-		goto errout;
+	if (tbl)
+		err = fib_table_lookup(tbl, &flp->u.ip4,
+				       (struct fib_result *)arg->result,
+				       arg->flags);
 
-	err = fib_table_lookup(tbl, &flp->u.ip4, (struct fib_result *) arg->result, arg->flags);
-	if (err > 0)
-		err = -EAGAIN;
-errout:
+	rcu_read_unlock();
 	return err;
 }
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 28a3065..987b06d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1181,72 +1181,6 @@ err:
 	return err;
 }
 
-/* should be called with rcu_read_lock */
-static int check_leaf(struct fib_table *tb, struct trie *t, struct tnode *l,
-		      t_key key,  const struct flowi4 *flp,
-		      struct fib_result *res, int fib_flags)
-{
-	struct leaf_info *li;
-	struct hlist_head *hhead = &l->list;
-
-	hlist_for_each_entry_rcu(li, hhead, hlist) {
-		struct fib_alias *fa;
-
-		if (l->key != (key & li->mask_plen))
-			continue;
-
-		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
-			struct fib_info *fi = fa->fa_info;
-			int nhsel, err;
-
-			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
-				continue;
-			if (fi->fib_dead)
-				continue;
-			if (fa->fa_info->fib_scope < flp->flowi4_scope)
-				continue;
-			fib_alias_accessed(fa);
-			err = fib_props[fa->fa_type].error;
-			if (unlikely(err < 0)) {
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-				this_cpu_inc(t->stats->semantic_match_passed);
-#endif
-				return err;
-			}
-			if (fi->fib_flags & RTNH_F_DEAD)
-				continue;
-			for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
-				const struct fib_nh *nh = &fi->fib_nh[nhsel];
-
-				if (nh->nh_flags & RTNH_F_DEAD)
-					continue;
-				if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
-					continue;
-
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-				this_cpu_inc(t->stats->semantic_match_passed);
-#endif
-				res->prefixlen = li->plen;
-				res->nh_sel = nhsel;
-				res->type = fa->fa_type;
-				res->scope = fi->fib_scope;
-				res->fi = fi;
-				res->table = tb;
-				res->fa_head = &li->falh;
-				if (!(fib_flags & FIB_LOOKUP_NOREF))
-					atomic_inc(&fi->fib_clntref);
-				return 0;
-			}
-		}
-
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-		this_cpu_inc(t->stats->semantic_match_miss);
-#endif
-	}
-
-	return 1;
-}
-
 static inline t_key prefix_mismatch(t_key key, struct tnode *n)
 {
 	t_key prefix = n->key;
@@ -1254,6 +1188,7 @@ static inline t_key prefix_mismatch(t_key key, struct tnode *n)
 	return (key ^ prefix) & (prefix | -prefix);
 }
 
+/* should be called with rcu_read_lock */
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags)
 {
@@ -1263,14 +1198,12 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 #endif
 	const t_key key = ntohl(flp->daddr);
 	struct tnode *n, *pn;
+	struct leaf_info *li;
 	t_key cindex;
-	int ret = 1;
-
-	rcu_read_lock();
 
 	n = rcu_dereference(t->trie);
 	if (!n)
-		goto failed;
+		return -EAGAIN;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	this_cpu_inc(stats->gets);
@@ -1350,7 +1283,7 @@ backtrace:
 
 				pn = node_parent_rcu(pn);
 				if (unlikely(!pn))
-					goto failed;
+					return -EAGAIN;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 				this_cpu_inc(stats->backtrack);
 #endif
@@ -1368,12 +1301,62 @@ backtrace:
 
 found:
 	/* Step 3: Process the leaf, if that fails fall back to backtracing */
-	ret = check_leaf(tb, t, n, key, flp, res, fib_flags);
-	if (unlikely(ret > 0))
-		goto backtrace;
-failed:
-	rcu_read_unlock();
-	return ret;
+	hlist_for_each_entry_rcu(li, &n->list, hlist) {
+		struct fib_alias *fa;
+
+		if ((key ^ n->key) & li->mask_plen)
+			continue;
+
+		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+			struct fib_info *fi = fa->fa_info;
+			int nhsel, err;
+
+			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
+				continue;
+			if (fi->fib_dead)
+				continue;
+			if (fa->fa_info->fib_scope < flp->flowi4_scope)
+				continue;
+			fib_alias_accessed(fa);
+			err = fib_props[fa->fa_type].error;
+			if (unlikely(err < 0)) {
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+				this_cpu_inc(stats->semantic_match_passed);
+#endif
+				return err;
+			}
+			if (fi->fib_flags & RTNH_F_DEAD)
+				continue;
+			for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
+				const struct fib_nh *nh = &fi->fib_nh[nhsel];
+
+				if (nh->nh_flags & RTNH_F_DEAD)
+					continue;
+				if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
+					continue;
+
+				if (!(fib_flags & FIB_LOOKUP_NOREF))
+					atomic_inc(&fi->fib_clntref);
+
+				res->prefixlen = li->plen;
+				res->nh_sel = nhsel;
+				res->type = fa->fa_type;
+				res->scope = fi->fib_scope;
+				res->fi = fi;
+				res->table = tb;
+				res->fa_head = &li->falh;
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+				this_cpu_inc(stats->semantic_match_passed);
+#endif
+				return err;
+			}
+		}
+
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+		this_cpu_inc(stats->semantic_match_miss);
+#endif
+	}
+	goto backtrace;
 }
 EXPORT_SYMBOL_GPL(fib_table_lookup);
 
