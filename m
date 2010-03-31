From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH nf-next-2.6] xt_hashlimit: RCU conversion
Date: Wed, 31 Mar 2010 14:23:30 +0200
Message-ID: <1270038210.2103.23.camel@edumazet-laptop>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>
	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>
	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop>
	 <1269509574.3626.9.camel@edumazet-laptop>  <4BAB3C8B.3030104@trash.net>
	 <1269514928.3626.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1269514928.3626.13.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

xt_hashlimit uses a central lock per hash table and suffers from
contention on some workloads. (Multiqueue NIC or if RPS is enabled)

After RCU conversion, central lock is only used when a writer wants to
add or delete an entry.

For 'readers', updating an existing entry, they use an individual lock
per entry.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/xt_hashlimit.c |  115 ++++++++++++++++++---------------
 1 file changed, 66 insertions(+), 49 deletions(-)
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 5470bb0..f245de6 100644
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
@@ -143,54 +145,30 @@ dsthash_find(const struct xt_hashlimit_htable *ht,
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
 
-/* allocate dsthash_ent, initialize dst, put in htable and lock it */
-static struct dsthash_ent *
-dsthash_alloc_init(struct xt_hashlimit_htable *ht,
-		   const struct dsthash_dst *dst)
+static void dsthash_free_rcu(struct rcu_head *head)
 {
-	struct dsthash_ent *ent;
+	struct dsthash_ent *ent = container_of(head, struct dsthash_ent, rcu);
 
-	/* initialize hash with random val at the time we allocate
-	 * the first hashtable entry */
-	if (!ht->rnd_initialized) {
-		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
-		ht->rnd_initialized = true;
-	}
-
-	if (ht->cfg.max && ht->count >= ht->cfg.max) {
-		/* FIXME: do something. question is what.. */
-		if (net_ratelimit())
-			pr_err("max count of %u reached\n", ht->cfg.max);
-		return NULL;
-	}
-
-	ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
-	if (!ent) {
-		if (net_ratelimit())
-			pr_err("cannot allocate dsthash_ent\n");
-		return NULL;
-	}
-	memcpy(&ent->dst, dst, sizeof(ent->dst));
-
-	hlist_add_head(&ent->node, &ht->hash[hash_dst(ht, dst)]);
-	ht->count++;
-	return ent;
+	kmem_cache_free(hashlimit_cachep, ent);
 }
 
-static inline void
-dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
+static void dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 {
-	hlist_del(&ent->node);
-	kmem_cache_free(hashlimit_cachep, ent);
+	hlist_del_rcu(&ent->node);
+	call_rcu_bh(&ent->rcu, dsthash_free_rcu);
 	ht->count--;
 }
+
+
 static void htable_gc(unsigned long htlong);
 
 static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
@@ -500,6 +478,49 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 	return 0;
 }
 
+/* allocate dsthash_ent, initialize dst, put in htable and lock it */
+static struct dsthash_ent *
+dsthash_alloc_init(struct xt_hashlimit_htable *ht,
+		   const struct dsthash_dst *dst)
+{
+	struct dsthash_ent *ent;
+
+	spin_lock(&ht->lock);
+	/* initialize hash with random val at the time we allocate
+	 * the first hashtable entry */
+	if (unlikely(!ht->rnd_initialized)) {
+		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
+		ht->rnd_initialized = true;
+	}
+
+	if (ht->cfg.max && ht->count >= ht->cfg.max) {
+		/* FIXME: do something. question is what.. */
+		if (net_ratelimit())
+			pr_err("max count of %u reached\n", ht->cfg.max);
+		ent = NULL;
+	} else
+		ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
+	if (!ent) {
+		if (net_ratelimit())
+			pr_err("cannot allocate dsthash_ent\n");
+	} else {
+		memcpy(&ent->dst, dst, sizeof(ent->dst));
+		spin_lock_init(&ent->lock);
+
+		ent->expires = jiffies + msecs_to_jiffies(ht->cfg.expire);
+		ent->rateinfo.prev = jiffies;
+		ent->rateinfo.credit = user2credits(ht->cfg.avg *
+		                      ht->cfg.burst);
+		ent->rateinfo.credit_cap = user2credits(ht->cfg.avg *
+		                          ht->cfg.burst);
+		ent->rateinfo.cost = user2credits(ht->cfg.avg);
+		spin_lock(&ent->lock);
+		hlist_add_head_rcu(&ent->node, &ht->hash[hash_dst(ht, dst)]);
+		ht->count++;
+	}
+	spin_unlock(&ht->lock);
+	return ent;
+}
 static bool
 hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
@@ -512,22 +533,14 @@ hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
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
-		dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		dh->rateinfo.prev = jiffies;
-		dh->rateinfo.credit = user2credits(hinfo->cfg.avg *
-		                      hinfo->cfg.burst);
-		dh->rateinfo.credit_cap = user2credits(hinfo->cfg.avg *
-		                          hinfo->cfg.burst);
-		dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
 	} else {
 		/* update expiration timeout */
 		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
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
 
@@ -817,9 +832,11 @@ err1:
 
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


