From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 24/62: xt_hashlimit: fix race condition and simplify locking
Date: Tue, 16 Feb 2010 15:55:52 +0100 (MET)
Message-ID: <20100216145550.2796.32.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427Ab0BPOzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:53 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2eff25c18c3d332d3c4dd98f2ac9b7114e9771b0
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 13:24:54 2010 +0100

    netfilter: xt_hashlimit: fix race condition and simplify locking
    
    As noticed by Shin Hong <hongshin@gmail.com>, there is a race between
    htable_find_get() and htable_put():
    
    htable_put():				htable_find_get():
    
    					spin_lock_bh(&hashlimit_lock);
    					<search entry>
    atomic_dec_and_test(&hinfo->use)
    					atomic_inc(&hinfo->use)
    					spin_unlock_bh(&hashlimit_lock)
    					return hinfo;
    spin_lock_bh(&hashlimit_lock);
    hlist_del(&hinfo->node);
    spin_unlock_bh(&hashlimit_lock);
    htable_destroy(hinfo);
    
    The entire locking concept is overly complicated, tables are only
    created/referenced and released in process context, so a single
    mutex works just fine. Remove the hashinfo_spinlock and atomic
    reference count and use the mutex to protect table lookups/creation
    and reference count changes.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index fb7fcb7..017c959 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -90,7 +90,7 @@ struct dsthash_ent {
 
 struct xt_hashlimit_htable {
 	struct hlist_node node;		/* global list of all htables */
-	atomic_t use;
+	int use;
 	u_int8_t family;
 	bool rnd_initialized;
 
@@ -109,8 +109,7 @@ struct xt_hashlimit_htable {
 	struct hlist_head hash[0];	/* hashtable itself */
 };
 
-static DEFINE_SPINLOCK(hashlimit_lock);	/* protects htables list */
-static DEFINE_MUTEX(hlimit_mutex);	/* additional checkentry protection */
+static DEFINE_MUTEX(hashlimit_mutex);	/* protects htables list */
 static struct kmem_cache *hashlimit_cachep __read_mostly;
 
 static inline bool dst_cmp(const struct dsthash_ent *ent,
@@ -244,7 +243,7 @@ static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_
 	for (i = 0; i < hinfo->cfg.size; i++)
 		INIT_HLIST_HEAD(&hinfo->hash[i]);
 
-	atomic_set(&hinfo->use, 1);
+	hinfo->use = 1;
 	hinfo->count = 0;
 	hinfo->family = family;
 	hinfo->rnd_initialized = false;
@@ -263,9 +262,9 @@ static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_
 	hinfo->timer.expires = jiffies + msecs_to_jiffies(hinfo->cfg.gc_interval);
 	add_timer(&hinfo->timer);
 
-	spin_lock_bh(&hashlimit_lock);
+	mutex_lock(&hashlimit_mutex);
 	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
-	spin_unlock_bh(&hashlimit_lock);
+	mutex_unlock(&hashlimit_mutex);
 
 	return 0;
 }
@@ -308,7 +307,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	for (i = 0; i < hinfo->cfg.size; i++)
 		INIT_HLIST_HEAD(&hinfo->hash[i]);
 
-	atomic_set(&hinfo->use, 1);
+	hinfo->use = 1;
 	hinfo->count = 0;
 	hinfo->family = family;
 	hinfo->rnd_initialized = false;
@@ -328,9 +327,9 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	hinfo->timer.expires = jiffies + msecs_to_jiffies(hinfo->cfg.gc_interval);
 	add_timer(&hinfo->timer);
 
-	spin_lock_bh(&hashlimit_lock);
+	mutex_lock(&hashlimit_mutex);
 	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
-	spin_unlock_bh(&hashlimit_lock);
+	mutex_unlock(&hashlimit_mutex);
 
 	return 0;
 }
@@ -402,27 +401,24 @@ static struct xt_hashlimit_htable *htable_find_get(struct net *net,
 	struct xt_hashlimit_htable *hinfo;
 	struct hlist_node *pos;
 
-	spin_lock_bh(&hashlimit_lock);
 	hlist_for_each_entry(hinfo, pos, &hashlimit_net->htables, node) {
 		if (!strcmp(name, hinfo->pde->name) &&
 		    hinfo->family == family) {
-			atomic_inc(&hinfo->use);
-			spin_unlock_bh(&hashlimit_lock);
+			hinfo->use++;
 			return hinfo;
 		}
 	}
-	spin_unlock_bh(&hashlimit_lock);
 	return NULL;
 }
 
 static void htable_put(struct xt_hashlimit_htable *hinfo)
 {
-	if (atomic_dec_and_test(&hinfo->use)) {
-		spin_lock_bh(&hashlimit_lock);
+	mutex_lock(&hashlimit_mutex);
+	if (--hinfo->use == 0) {
 		hlist_del(&hinfo->node);
-		spin_unlock_bh(&hashlimit_lock);
 		htable_destroy(hinfo);
 	}
+	mutex_unlock(&hashlimit_mutex);
 }
 
 /* The algorithm used is the Simple Token Bucket Filter (TBF)
@@ -710,19 +706,13 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	if (r->name[sizeof(r->name) - 1] != '\0')
 		return false;
 
-	/* This is the best we've got: We cannot release and re-grab lock,
-	 * since checkentry() is called before x_tables.c grabs xt_mutex.
-	 * We also cannot grab the hashtable spinlock, since htable_create will
-	 * call vmalloc, and that can sleep.  And we cannot just re-search
-	 * the list of htable's in htable_create(), since then we would
-	 * create duplicate proc files. -HW */
-	mutex_lock(&hlimit_mutex);
+	mutex_lock(&hashlimit_mutex);
 	r->hinfo = htable_find_get(net, r->name, par->match->family);
 	if (!r->hinfo && htable_create_v0(net, r, par->match->family) != 0) {
-		mutex_unlock(&hlimit_mutex);
+		mutex_unlock(&hashlimit_mutex);
 		return false;
 	}
-	mutex_unlock(&hlimit_mutex);
+	mutex_unlock(&hashlimit_mutex);
 
 	return true;
 }
@@ -752,19 +742,13 @@ static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
 			return false;
 	}
 
-	/* This is the best we've got: We cannot release and re-grab lock,
-	 * since checkentry() is called before x_tables.c grabs xt_mutex.
-	 * We also cannot grab the hashtable spinlock, since htable_create will
-	 * call vmalloc, and that can sleep.  And we cannot just re-search
-	 * the list of htable's in htable_create(), since then we would
-	 * create duplicate proc files. -HW */
-	mutex_lock(&hlimit_mutex);
+	mutex_lock(&hashlimit_mutex);
 	info->hinfo = htable_find_get(net, info->name, par->match->family);
 	if (!info->hinfo && htable_create(net, info, par->match->family) != 0) {
-		mutex_unlock(&hlimit_mutex);
+		mutex_unlock(&hashlimit_mutex);
 		return false;
 	}
-	mutex_unlock(&hlimit_mutex);
+	mutex_unlock(&hashlimit_mutex);
 	return true;
 }
 
