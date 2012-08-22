From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 17/17] SUNRPC: use new hashtable implementation
	in auth
Date: Wed, 22 Aug 2012 04:27:12 +0200
Message-ID: <1345602432-27673-18-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Switch sunrpc/auth.c  to use the new hashtable implementation. This reduces the amount of
generic unrelated code in auth.c.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/sunrpc/auth.c |   45 +++++++++++++++++++--------------------------
 1 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..5d50e2d 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/spinlock.h>
+#include <linux/hashtable.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -222,7 +223,7 @@ static DEFINE_SPINLOCK(rpc_credcache_lock);
 static void
 rpcauth_unhash_cred_locked(struct rpc_cred *cred)
 {
-	hlist_del_rcu(&cred->cr_hash);
+	hash_del_rcu(&cred->cr_hash);
 	smp_mb__before_clear_bit();
 	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
 }
@@ -249,16 +250,15 @@ int
 rpcauth_init_credcache(struct rpc_auth *auth)
 {
 	struct rpc_cred_cache *new;
-	unsigned int hashsize;
 
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_nocache;
 	new->hashbits = auth_hashbits;
-	hashsize = 1U << new->hashbits;
-	new->hashtable = kcalloc(hashsize, sizeof(new->hashtable[0]), GFP_KERNEL);
+	new->hashtable = kmalloc(HASH_REQUIRED_SIZE(new->hashbits), GFP_KERNEL);
 	if (!new->hashtable)
 		goto out_nohashtbl;
+	hash_init_size(new->hashtable, new->hashbits);
 	spin_lock_init(&new->lock);
 	auth->au_credcache = new;
 	return 0;
@@ -292,25 +292,20 @@ void
 rpcauth_clear_credcache(struct rpc_cred_cache *cache)
 {
 	LIST_HEAD(free);
-	struct hlist_head *head;
+	struct hlist_node *n, *t;
 	struct rpc_cred	*cred;
-	unsigned int hashsize = 1U << cache->hashbits;
-	int		i;
+	int i;
 
 	spin_lock(&rpc_credcache_lock);
 	spin_lock(&cache->lock);
-	for (i = 0; i < hashsize; i++) {
-		head = &cache->hashtable[i];
-		while (!hlist_empty(head)) {
-			cred = hlist_entry(head->first, struct rpc_cred, cr_hash);
-			get_rpccred(cred);
-			if (!list_empty(&cred->cr_lru)) {
-				list_del(&cred->cr_lru);
-				number_cred_unused--;
-			}
-			list_add_tail(&cred->cr_lru, &free);
-			rpcauth_unhash_cred_locked(cred);
+	hash_for_each_safe_size(cache->hashtable, cache->hashbits, i, n, t, cred, cr_hash) {
+		get_rpccred(cred);
+		if (!list_empty(&cred->cr_lru)) {
+			list_del(&cred->cr_lru);
+			number_cred_unused--;
 		}
+		list_add_tail(&cred->cr_lru, &free);
+		rpcauth_unhash_cred_locked(cred);
 	}
 	spin_unlock(&cache->lock);
 	spin_unlock(&rpc_credcache_lock);
@@ -408,14 +403,11 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	LIST_HEAD(free);
 	struct rpc_cred_cache *cache = auth->au_credcache;
 	struct hlist_node *pos;
-	struct rpc_cred	*cred = NULL,
-			*entry, *new;
-	unsigned int nr;
-
-	nr = hash_long(acred->uid, cache->hashbits);
+	struct rpc_cred	*cred = NULL, *entry = NULL, *new;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
+	hash_for_each_possible_rcu_size(cache->hashtable, cred, cache->hashbits,
+					pos, cr_hash, acred->uid) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		spin_lock(&cache->lock);
@@ -439,7 +431,8 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	}
 
 	spin_lock(&cache->lock);
-	hlist_for_each_entry(entry, pos, &cache->hashtable[nr], cr_hash) {
+	hash_for_each_possible_size(cache->hashtable, entry, cache->hashbits, pos,
+					cr_hash, acred->uid) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		cred = get_rpccred(entry);
@@ -448,7 +441,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred == NULL) {
 		cred = new;
 		set_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
-		hlist_add_head_rcu(&cred->cr_hash, &cache->hashtable[nr]);
+		hash_add_size(cache->hashtable, cache->hashbits, &cred->cr_hash, acred->uid);
 	} else
 		list_add_tail(&new->cr_lru, &free);
 	spin_unlock(&cache->lock);
-- 
1.7.8.6
