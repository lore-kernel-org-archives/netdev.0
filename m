From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 12:01:23 +0200
Message-ID: <1343383283.2626.12691.camel@edumazet-glaptop>
References: <20120726.155327.947597248143903676.davem@davemloft.net>
	 <CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	 <20120726.200846.66786272076299783.davem@davemloft.net>
	 <20120726.230246.219188476590178857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59377 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab2G0KB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 06:01:29 -0400
Received: by bkwj10 with SMTP id j10so1804275bkw.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 03:01:27 -0700 (PDT)
In-Reply-To: <20120726.230246.219188476590178857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Thu, 2012-07-26 at 23:02 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 26 Jul 2012 20:08:46 -0700 (PDT)
> 
> > A lot of the overhead comes from write traffic that results from
> > filling in the "fib_result" structure onto the callers stack.
> 
> Here's the longer analysis of how things are now.
> 
> There are several components to a route lookup result, and struct
> fib_result tries to encapsulate all of this.
> 
> Another aspect is that our route tables are broken up into different
> datas tructures which reference each other, in order to save space.
> 
> So the actual objects in the FIB trie are fib_alias structures, and
> those point to fib_info.  There is a many to one relationship between
> FIB trie nodes and fib_info objects.
> 
> The idea is that many routes have the same set of nexthops, metrics,
> preferred source address, etc.
> 
> So one thing we return in the fib_result is a pointer to the fib_info
> and an index into the nexthop array (nh_sel).  That's why we have all
> of these funny accessor's FIB_RES_X(res) which essentially provide
> res.fi->fib_nh[res.nh_sel].X
> 
> Therefore one area of simplification would be to just return a pointer
> to the FIB nexthop, rather than the fib_info pointer and the nexthop
> index.  We can get to the fib_info, if we need to, via the nh_parent
> pointer of the nexthop.
> 
> It seems also that the res->scope value can be cribbed from the
> fib_info as well.
> 
> res->type is embedded in the fib_alias we select hanging off of the
> FIB trie node.  And the res->prefixlen is taken from the FIB trie
> node.
> 
> res->tclassid is problematic, because it comes from the FIB rules
> tables rather than the FIB trie.  We used to store a full FIB rules
> pointer in the fib_result, but I reduced it down to just the u32
> tclassid.
> 
> This whole area, as well as the FIB trie lookup itself, is an area
> ripe for a large number of small micro-optimizations that in the end
> make it's overhead much more reasonable.
> 
> Another thing I haven't mentioned is that another part of FIB trie's
> overhead is that it does backtracking.  The shorter prefixes sit at
> the top of the trie, so when it traverses down it does so until it
> can't get a match, then it walks back up to the root until it does
> have a match.

We also have cache line misses in this code, and we shouldn't have them
at all.

Following patch helps a lot in my case.

Thanks

[PATCH] ipv4: fib: avoid false sharing

Now IP route cache is removed, we should make sure fib structures
cant share cache lines with possibly often dirtied objects.

On x86, kmalloc-96 cache can be source of such problems.

Problem spotted with perf ... -e cache-misses ... while doing
a forwarding benchmark.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip_fib.h     |    6 ++++++
 net/ipv4/fib_frontend.c  |    5 +----
 net/ipv4/fib_semantics.c |   15 ++++++++-------
 net/ipv4/fib_trie.c      |   26 +++++++++-----------------
 4 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e69c3a4..5b6a9b3 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -295,6 +295,12 @@ extern void fib_select_multipath(struct fib_result *res);
 /* Exported by fib_trie.c */
 extern void fib_trie_init(void);
 extern struct fib_table *fib_trie_table(u32 id);
+static inline void *fib_zalloc(size_t size)
+{
+	/* We want to avoid possible false sharing */
+	return kzalloc(max_t(size_t, 128, size), GFP_KERNEL);
+}
+
 
 static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8732cc7..a3d0285 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1089,10 +1089,7 @@ static int __net_init ip_fib_net_init(struct net *net)
 	int err;
 	size_t size = sizeof(struct hlist_head) * FIB_TABLE_HASHSZ;
 
-	/* Avoid false sharing : Use at least a full cache line */
-	size = max_t(size_t, size, L1_CACHE_BYTES);
-
-	net->ipv4.fib_table_hash = kzalloc(size, GFP_KERNEL);
+	net->ipv4.fib_table_hash = fib_zalloc(size);
 	if (net->ipv4.fib_table_hash == NULL)
 		return -ENOMEM;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da0cc2e..a9f5e87 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -651,17 +651,17 @@ static inline unsigned int fib_laddr_hashfn(__be32 val)
 		((__force u32)val >> 14)) & mask;
 }
 
-static struct hlist_head *fib_info_hash_alloc(int bytes)
+static struct hlist_head *fib_info_hash_alloc(size_t bytes)
 {
 	if (bytes <= PAGE_SIZE)
-		return kzalloc(bytes, GFP_KERNEL);
+		return fib_zalloc(bytes);
 	else
 		return (struct hlist_head *)
 			__get_free_pages(GFP_KERNEL | __GFP_ZERO,
 					 get_order(bytes));
 }
 
-static void fib_info_hash_free(struct hlist_head *hash, int bytes)
+static void fib_info_hash_free(struct hlist_head *hash, size_t bytes)
 {
 	if (!hash)
 		return;
@@ -678,7 +678,8 @@ static void fib_info_hash_move(struct hlist_head *new_info_hash,
 {
 	struct hlist_head *old_info_hash, *old_laddrhash;
 	unsigned int old_size = fib_info_hash_size;
-	unsigned int i, bytes;
+	unsigned int i;
+	size_t bytes;
 
 	spin_lock_bh(&fib_info_lock);
 	old_info_hash = fib_info_hash;
@@ -766,10 +767,10 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		unsigned int new_size = fib_info_hash_size << 1;
 		struct hlist_head *new_info_hash;
 		struct hlist_head *new_laddrhash;
-		unsigned int bytes;
+		size_t bytes;
 
 		if (!new_size)
-			new_size = 1;
+			new_size = 16;
 		bytes = new_size * sizeof(struct hlist_head *);
 		new_info_hash = fib_info_hash_alloc(bytes);
 		new_laddrhash = fib_info_hash_alloc(bytes);
@@ -783,7 +784,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			goto failure;
 	}
 
-	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
+	fi = fib_zalloc(sizeof(*fi) + nhs*sizeof(struct fib_nh));
 	if (fi == NULL)
 		goto failure;
 	if (cfg->fc_mx) {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 18cbc15..664152c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -379,7 +379,7 @@ static inline void free_leaf_info(struct leaf_info *leaf)
 static struct tnode *tnode_alloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
-		return kzalloc(size, GFP_KERNEL);
+		return fib_zalloc(size);
 	else
 		return vzalloc(size);
 }
@@ -449,7 +449,7 @@ static struct leaf *leaf_new(void)
 
 static struct leaf_info *leaf_info_new(int plen)
 {
-	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
+	struct leaf_info *li = fib_zalloc(sizeof(struct leaf_info));
 	if (li) {
 		li->plen = plen;
 		li->mask_plen = ntohl(inet_make_mask(plen));
@@ -1969,32 +1969,24 @@ void __init fib_trie_init(void)
 {
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias",
 					  sizeof(struct fib_alias),
-					  0, SLAB_PANIC, NULL);
+					  0, SLAB_PANIC | SLAB_HWCACHE_ALIGN, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
 					   max(sizeof(struct leaf),
 					       sizeof(struct leaf_info)),
-					   0, SLAB_PANIC, NULL);
+					   0, SLAB_PANIC | SLAB_HWCACHE_ALIGN, NULL);
 }
 
 
 struct fib_table *fib_trie_table(u32 id)
 {
 	struct fib_table *tb;
-	struct trie *t;
-
-	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct trie),
-		     GFP_KERNEL);
-	if (tb == NULL)
-		return NULL;
-
-	tb->tb_id = id;
-	tb->tb_default = -1;
-	tb->tb_num_default = 0;
-
-	t = (struct trie *) tb->tb_data;
-	memset(t, 0, sizeof(*t));
 
+	tb = fib_zalloc(sizeof(struct fib_table) + sizeof(struct trie));
+	if (tb) {
+		tb->tb_id = id;
+		tb->tb_default = -1;
+	}
 	return tb;
 }
 
