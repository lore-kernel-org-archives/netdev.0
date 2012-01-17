From: Dimitri Sivanich <sivanich@sgi.com>
Subject: [PATCH] Fix panic in __d_lookup with high dentry hashtable counts
Date: Tue, 17 Jan 2012 11:13:52 -0600
Message-ID: <20120117171352.GA18738@sgi.com>
References: <20120113155237.GA25103@sgi.com>
 <20120113162236.GK23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Kosina <jkosina@suse.cz>, Avi Kivity <avi@redhat.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120113162236.GK23916@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the number of dentry cache hash table entries gets too high
(2147483648 entries), as happens by default on a 16TB system, use
of a signed integer in the dcache_init() initialization loop prevents
the dentry_hashtable from getting initialized, causing a panic in
__d_lookup().

In addition, the _hash_mask returned from alloc_large_system_hash() does
not support more than a 32 bit hash table size.

Changing the _hash_mask size returned from alloc_large_system_hash() to
support larger hash table sizes in the future, and changing loop counter
sizes appropriately.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
---
 fs/dcache.c             |   10 +++++-----
 fs/inode.c              |   10 +++++-----
 include/linux/bootmem.h |    2 +-
 mm/page_alloc.c         |    2 +-
 net/ipv4/route.c        |    8 ++++++--
 net/ipv4/tcp.c          |   13 +++++++++----
 net/ipv4/udp.c          |    5 ++++-
 7 files changed, 31 insertions(+), 19 deletions(-)

Index: linux/fs/dcache.c
===================================================================
--- linux.orig/fs/dcache.c
+++ linux/fs/dcache.c
@@ -99,7 +99,7 @@ static struct kmem_cache *dentry_cache _
 #define D_HASHBITS     d_hash_shift
 #define D_HASHMASK     d_hash_mask
 
-static unsigned int d_hash_mask __read_mostly;
+static unsigned long d_hash_mask __read_mostly;
 static unsigned int d_hash_shift __read_mostly;
 
 static struct hlist_bl_head *dentry_hashtable __read_mostly;
@@ -2968,7 +2968,7 @@ __setup("dhash_entries=", set_dhash_entr
 
 static void __init dcache_init_early(void)
 {
-	int loop;
+	unsigned long loop;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
@@ -2986,13 +2986,13 @@ static void __init dcache_init_early(voi
 					&d_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+	for (loop = 0; loop < (1UL << d_hash_shift); loop++)
 		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
 static void __init dcache_init(void)
 {
-	int loop;
+	unsigned long loop;
 
 	/* 
 	 * A constructor could be added for stable state like the lists,
@@ -3016,7 +3016,7 @@ static void __init dcache_init(void)
 					&d_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+	for (loop = 0; loop < (1UL << d_hash_shift); loop++)
 		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
Index: linux/fs/inode.c
===================================================================
--- linux.orig/fs/inode.c
+++ linux/fs/inode.c
@@ -60,7 +60,7 @@
  *   inode_hash_lock
  */
 
-static unsigned int i_hash_mask __read_mostly;
+static unsigned long i_hash_mask __read_mostly;
 static unsigned int i_hash_shift __read_mostly;
 static struct hlist_head *inode_hashtable __read_mostly;
 static __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_hash_lock);
@@ -1654,7 +1654,7 @@ __setup("ihash_entries=", set_ihash_entr
  */
 void __init inode_init_early(void)
 {
-	int loop;
+	unsigned long loop;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
@@ -1672,13 +1672,13 @@ void __init inode_init_early(void)
 					&i_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+	for (loop = 0; loop < (1UL << i_hash_shift); loop++)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
 void __init inode_init(void)
 {
-	int loop;
+	unsigned long loop;
 
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache",
@@ -1702,7 +1702,7 @@ void __init inode_init(void)
 					&i_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+	for (loop = 0; loop < (1UL << i_hash_shift); loop++)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
Index: linux/include/linux/bootmem.h
===================================================================
--- linux.orig/include/linux/bootmem.h
+++ linux/include/linux/bootmem.h
@@ -153,7 +153,7 @@ extern void *alloc_large_system_hash(con
 				     int scale,
 				     int flags,
 				     unsigned int *_hash_shift,
-				     unsigned int *_hash_mask,
+				     unsigned long *_hash_mask,
 				     unsigned long limit);
 
 #define HASH_EARLY	0x00000001	/* Allocating during early boot? */
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -5219,7 +5219,7 @@ void *__init alloc_large_system_hash(con
 				     int scale,
 				     int flags,
 				     unsigned int *_hash_shift,
-				     unsigned int *_hash_mask,
+				     unsigned long *_hash_mask,
 				     unsigned long limit)
 {
 	unsigned long long max = limit;
Index: linux/net/ipv4/route.c
===================================================================
--- linux.orig/net/ipv4/route.c
+++ linux/net/ipv4/route.c
@@ -3446,6 +3446,7 @@ __setup("rhash_entries=", set_rhash_entr
 
 int __init ip_rt_init(void)
 {
+	unsigned long hash_mask;
 	int rc = 0;
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -3474,8 +3475,11 @@ int __init ip_rt_init(void)
 					15 : 17,
 					0,
 					&rt_hash_log,
-					&rt_hash_mask,
-					rhash_entries ? 0 : 512 * 1024);
+					&hash_mask,
+					rhash_entries ? 0x80000000 :
+								512 * 1024);
+	/* FIXME: Above limit value (0x80000000) allows the following cast. */
+	rt_hash_mask = (unsigned int) hash_mask;
 	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
 	rt_hash_lock_init();
 
Index: linux/net/ipv4/tcp.c
===================================================================
--- linux.orig/net/ipv4/tcp.c
+++ linux/net/ipv4/tcp.c
@@ -3219,8 +3219,9 @@ __setup("thash_entries=", set_thash_entr
 void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
-	unsigned long limit;
-	int i, max_share, cnt;
+	unsigned long limit, hash_mask;
+	unsigned i;
+	int max_share, cnt;
 	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
@@ -3245,8 +3246,12 @@ void __init tcp_init(void)
 					13 : 15,
 					0,
 					NULL,
-					&tcp_hashinfo.ehash_mask,
-					thash_entries ? 0 : 512 * 1024);
+					&hash_mask,
+					thash_entries ? 0x80000000 :
+								512 * 1024);
+	/* FIXME: Above limit value (0x80000000) allows the following cast. */
+	tcp_hashinfo.ehash_mask = (unsigned int)hash_mask;
+
 	for (i = 0; i <= tcp_hashinfo.ehash_mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].chain, i);
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].twchain, i);
Index: linux/net/ipv4/udp.c
===================================================================
--- linux.orig/net/ipv4/udp.c
+++ linux/net/ipv4/udp.c
@@ -2180,6 +2180,7 @@ __setup("uhash_entries=", set_uhash_entr
 
 void __init udp_table_init(struct udp_table *table, const char *name)
 {
+	unsigned long hash_mask;
 	unsigned int i;
 
 	if (!CONFIG_BASE_SMALL)
@@ -2189,8 +2190,10 @@ void __init udp_table_init(struct udp_ta
 			21, /* one slot per 2 MB */
 			0,
 			&table->log,
-			&table->mask,
+			&hash_mask,
 			64 * 1024);
+	/* FIXME: Above limit value (64 * 1024) allows the following cast. */
+	table->mask = (unsigned int)hash_mask;
 	/*
 	 * Make sure hash table has the minimum size
 	 */
