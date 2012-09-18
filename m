From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: xt_hashlimit.c race?
Date: Tue, 18 Sep 2012 16:26:25 +0200
Message-ID: <1347978385.26523.261.camel@edumazet-glaptop>
References: <20201347974535@web11g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50965 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab2IRO0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:26:31 -0400
Received: by eekc1 with SMTP id c1so3980542eek.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 07:26:29 -0700 (PDT)
In-Reply-To: <20201347974535@web11g.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-18 at 17:22 +0400, "Oleg A. Arkhangelsky" wrote:
> Hello,
> 
> Looking at the net/netfilter/xt_hashlimit.c revealed one question. As far as
> I can understand hashlimit_mt() code under rcu_read_lock_bh() can be
> executed simultaneously by more than one CPU. So what if we have two
> packets with the same new dst value that processed in parallel by different
> CPUs? In both cases dh is NULL and both CPUs tries to create new
> entry in hash table. This is not what we want and can lead to undefined
> behavior in the future.
> 
> Or maybe I'm wrong? Could anyone tell me is this situation possible?
> 

Its absolutely possible, but should not have big impact.

One of the newly inserted entry will never be reached again and will
expire.

Following (untested) patch should remove the race.

 net/netfilter/xt_hashlimit.c |  125 ++++++++++++++++-----------------
 1 file changed, 62 insertions(+), 63 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 26a668a..246bc92 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -136,56 +136,6 @@ hash_dst(const struct xt_hashlimit_htable *ht, const struct dsthash_dst *dst)
 	return ((u64)hash * ht->cfg.size) >> 32;
 }
 
-static struct dsthash_ent *
-dsthash_find(const struct xt_hashlimit_htable *ht,
-	     const struct dsthash_dst *dst)
-{
-	struct dsthash_ent *ent;
-	struct hlist_node *pos;
-	u_int32_t hash = hash_dst(ht, dst);
-
-	if (!hlist_empty(&ht->hash[hash])) {
-		hlist_for_each_entry_rcu(ent, pos, &ht->hash[hash], node)
-			if (dst_cmp(ent, dst)) {
-				spin_lock(&ent->lock);
-				return ent;
-			}
-	}
-	return NULL;
-}
-
-/* allocate dsthash_ent, initialize dst, put in htable and lock it */
-static struct dsthash_ent *
-dsthash_alloc_init(struct xt_hashlimit_htable *ht,
-		   const struct dsthash_dst *dst)
-{
-	struct dsthash_ent *ent;
-
-	spin_lock(&ht->lock);
-	/* initialize hash with random val at the time we allocate
-	 * the first hashtable entry */
-	if (unlikely(!ht->rnd_initialized)) {
-		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
-		ht->rnd_initialized = true;
-	}
-
-	if (ht->cfg.max && ht->count >= ht->cfg.max) {
-		/* FIXME: do something. question is what.. */
-		net_err_ratelimited("max count of %u reached\n", ht->cfg.max);
-		ent = NULL;
-	} else
-		ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
-	if (ent) {
-		memcpy(&ent->dst, dst, sizeof(ent->dst));
-		spin_lock_init(&ent->lock);
-
-		spin_lock(&ent->lock);
-		hlist_add_head_rcu(&ent->node, &ht->hash[hash_dst(ht, dst)]);
-		ht->count++;
-	}
-	spin_unlock(&ht->lock);
-	return ent;
-}
 
 static void dsthash_free_rcu(struct rcu_head *head)
 {
@@ -577,12 +527,70 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 	return (u32) tmp;
 }
 
+static struct dsthash_ent *
+dsthash_find(struct xt_hashlimit_htable *ht,
+	     const struct dsthash_dst *dst)
+{
+	struct dsthash_ent *dh;
+	struct hlist_node *pos;
+	u_int32_t hash = hash_dst(ht, dst);
+	unsigned long now = jiffies;
+
+	hlist_for_each_entry_rcu(dh, pos, &ht->hash[hash], node) {
+		if (dst_cmp(dh, dst)) {
+found:
+			spin_lock(&dh->lock);
+			/* update expiration timeout */
+			dh->expires = now + msecs_to_jiffies(ht->cfg.expire);
+			rateinfo_recalc(dh, now, ht->cfg.mode);
+			return dh;
+		}
+	}
+
+	/* slow path */
+	spin_lock(&ht->lock);
+
+	/* initialize hash with random val at the time we allocate
+	 * the first hashtable entry
+	 */
+	if (unlikely(!ht->rnd_initialized)) {
+		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
+		ht->rnd_initialized = true;
+	}
+	hash = hash_dst(ht, dst);
+	hlist_for_each_entry_rcu(dh, pos, &ht->hash[hash], node) {
+		if (dst_cmp(dh, dst)) {
+			spin_unlock(&ht->lock);
+			goto found;
+		}
+	}
+
+	if (ht->cfg.max && ht->count >= ht->cfg.max) {
+		/* FIXME: do something. question is what.. */
+		net_err_ratelimited("max count of %u reached\n", ht->cfg.max);
+		dh = NULL;
+	} else {
+		dh = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
+	}
+	if (dh) {
+		memcpy(&dh->dst, dst, sizeof(dh->dst));
+		spin_lock_init(&dh->lock);
+
+		spin_lock(&dh->lock);
+		hlist_add_head_rcu(&dh->node, &ht->hash[hash_dst(ht, dst)]);
+		ht->count++;
+		dh->expires = now + msecs_to_jiffies(ht->cfg.expire);
+		rateinfo_init(dh, ht);
+	}
+	spin_unlock(&ht->lock);
+	return dh;
+}
+
 static bool
 hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
-	unsigned long now = jiffies;
 	struct dsthash_ent *dh;
 	struct dsthash_dst dst;
 	u32 cost;
@@ -593,17 +601,8 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	rcu_read_lock_bh();
 	dh = dsthash_find(hinfo, &dst);
 	if (dh == NULL) {
-		dh = dsthash_alloc_init(hinfo, &dst);
-		if (dh == NULL) {
-			rcu_read_unlock_bh();
-			goto hotdrop;
-		}
-		dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_init(dh, hinfo);
-	} else {
-		/* update expiration timeout */
-		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_recalc(dh, now, hinfo->cfg.mode);
+		rcu_read_unlock_bh();
+		goto hotdrop;
 	}
 
 	if (info->cfg.mode & XT_HASHLIMIT_BYTES)
@@ -624,7 +623,7 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/* default match is underlimit - so over the limit, we need to invert */
 	return info->cfg.mode & XT_HASHLIMIT_INVERT;
 
- hotdrop:
+hotdrop:
 	par->hotdrop = true;
 	return false;
 }
