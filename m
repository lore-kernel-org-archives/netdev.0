From: kaber@trash.net
Subject: [PATCH 54/84] netfilter: xt_hashlimit: RCU conversion
Date: Mon, 10 May 2010 22:18:25 +0200
Message-ID: <1273522735-24672-55-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54521 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756881Ab0EJUTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:18 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

xt_hashlimit uses a central lock per hash table and suffers from
contention on some workloads. (Multiqueue NIC or if RPS is enabled)

After RCU conversion, central lock is only used when a writer wants to
add or delete an entry.

For 'readers', updating an existing entry, they use an individual lock
per entry.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_hashlimit.c |   70 ++++++++++++++++++++++++++++--------------
 1 files changed, 47 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 5470bb0..453178d 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -81,12 +81,14 @@ struct dsthash_ent {
 	struct dsthash_dst dst;
 
 	/* modified structure members in the end */
+	spinlock_t lock;
 	unsigned long expires;		/* precalculated expiry time */
 	struct {
 		unsigned long prev;	/* last modification */
 		u_int32_t credit;
 		u_int32_t credit_cap, cost;
 	} rateinfo;
+	struct rcu_head rcu;
 };
 
 struct xt_hashlimit_htable {
@@ -143,9 +145,11 @@ dsthash_find(const struct xt_hashlimit_htable *ht,
 	u_int32_t hash = hash_dst(ht, dst);
 
 	if (!hlist_empty(&ht->hash[hash])) {
-		hlist_for_each_entry(ent, pos, &ht->hash[hash], node)
-			if (dst_cmp(ent, dst))
+		hlist_for_each_entry_rcu(ent, pos, &ht->hash[hash], node)
+			if (dst_cmp(ent, dst)) {
+				spin_lock(&ent->lock);
 				return ent;
+			}
 	}
 	return NULL;
 }
@@ -157,9 +161,10 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 {
 	struct dsthash_ent *ent;
 
+	spin_lock(&ht->lock);
 	/* initialize hash with random val at the time we allocate
 	 * the first hashtable entry */
-	if (!ht->rnd_initialized) {
+	if (unlikely(!ht->rnd_initialized)) {
 		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
 		ht->rnd_initialized = true;
 	}
@@ -168,27 +173,36 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 		/* FIXME: do something. question is what.. */
 		if (net_ratelimit())
 			pr_err("max count of %u reached\n", ht->cfg.max);
-		return NULL;
-	}
-
-	ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
+		ent = NULL;
+	} else
+		ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
 	if (!ent) {
 		if (net_ratelimit())
 			pr_err("cannot allocate dsthash_ent\n");
-		return NULL;
-	}
-	memcpy(&ent->dst, dst, sizeof(ent->dst));
+	} else {
+		memcpy(&ent->dst, dst, sizeof(ent->dst));
+		spin_lock_init(&ent->lock);
 
-	hlist_add_head(&ent->node, &ht->hash[hash_dst(ht, dst)]);
-	ht->count++;
+		spin_lock(&ent->lock);
+		hlist_add_head_rcu(&ent->node, &ht->hash[hash_dst(ht, dst)]);
+		ht->count++;
+	}
+	spin_unlock(&ht->lock);
 	return ent;
 }
 
+static void dsthash_free_rcu(struct rcu_head *head)
+{
+	struct dsthash_ent *ent = container_of(head, struct dsthash_ent, rcu);
+
+	kmem_cache_free(hashlimit_cachep, ent);
+}
+
 static inline void
 dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 {
-	hlist_del(&ent->node);
-	kmem_cache_free(hashlimit_cachep, ent);
+	hlist_del_rcu(&ent->node);
+	call_rcu_bh(&ent->rcu, dsthash_free_rcu);
 	ht->count--;
 }
 static void htable_gc(unsigned long htlong);
@@ -512,15 +526,14 @@ hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
 		goto hotdrop;
 
-	spin_lock_bh(&hinfo->lock);
+	rcu_read_lock_bh();
 	dh = dsthash_find(hinfo, &dst);
 	if (dh == NULL) {
 		dh = dsthash_alloc_init(hinfo, &dst);
 		if (dh == NULL) {
-			spin_unlock_bh(&hinfo->lock);
+			rcu_read_unlock_bh();
 			goto hotdrop;
 		}
-
 		dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
 		dh->rateinfo.prev = jiffies;
 		dh->rateinfo.credit = user2credits(hinfo->cfg.avg *
@@ -537,11 +550,13 @@ hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (dh->rateinfo.credit >= dh->rateinfo.cost) {
 		/* below the limit */
 		dh->rateinfo.credit -= dh->rateinfo.cost;
-		spin_unlock_bh(&hinfo->lock);
+		spin_unlock(&dh->lock);
+		rcu_read_unlock_bh();
 		return !(info->cfg.mode & XT_HASHLIMIT_INVERT);
 	}
 
-	spin_unlock_bh(&hinfo->lock);
+	spin_unlock(&dh->lock);
+	rcu_read_unlock_bh();
 	/* default match is underlimit - so over the limit, we need to invert */
 	return info->cfg.mode & XT_HASHLIMIT_INVERT;
 
@@ -666,12 +681,15 @@ static void dl_seq_stop(struct seq_file *s, void *v)
 static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				   struct seq_file *s)
 {
+	int res;
+
+	spin_lock(&ent->lock);
 	/* recalculate to show accurate numbers */
 	rateinfo_recalc(ent, jiffies);
 
 	switch (family) {
 	case NFPROTO_IPV4:
-		return seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
+		res = seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
 				 &ent->dst.ip.src,
 				 ntohs(ent->dst.src_port),
@@ -679,9 +697,10 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				 ntohs(ent->dst.dst_port),
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
 				 ent->rateinfo.cost);
+		break;
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	case NFPROTO_IPV6:
-		return seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
+		res = seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
 				 &ent->dst.ip6.src,
 				 ntohs(ent->dst.src_port),
@@ -689,11 +708,14 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				 ntohs(ent->dst.dst_port),
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
 				 ent->rateinfo.cost);
+		break;
 #endif
 	default:
 		BUG();
-		return 0;
+		res = 0;
 	}
+	spin_unlock(&ent->lock);
+	return res;
 }
 
 static int dl_seq_show(struct seq_file *s, void *v)
@@ -817,9 +839,11 @@ err1:
 
 static void __exit hashlimit_mt_exit(void)
 {
-	kmem_cache_destroy(hashlimit_cachep);
 	xt_unregister_matches(hashlimit_mt_reg, ARRAY_SIZE(hashlimit_mt_reg));
 	unregister_pernet_subsys(&hashlimit_net_ops);
+
+	rcu_barrier_bh();
+	kmem_cache_destroy(hashlimit_cachep);
 }
 
 module_init(hashlimit_mt_init);
-- 
1.7.0.4

