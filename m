From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable
 counts
Date: Tue, 17 Jan 2012 15:05:41 -0600
Message-ID: <20120117210541.GA21940@sgi.com>
References: <20120113155237.GA25103@sgi.com>
 <20120113162236.GK23916@ZenIV.linux.org.uk>
 <20120117171352.GA18738@sgi.com>
 <20120117.122229.323838457367599504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, paul.gortmaker@windriver.com,
	akpm@linux-foundation.org, jkosina@suse.cz, avi@redhat.com,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:45967 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755898Ab2AQVFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 16:05:47 -0500
Content-Disposition: inline
In-Reply-To: <20120117.122229.323838457367599504.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2012 at 12:22:29PM -0500, David Miller wrote:
> To be honest I think this is overkill.
> 
> Supporting anything larger than a 32-bit hash mask is not even close
> to being reasonable.  Nobody needs a 4GB hash table, not for anything.
>
Here is a patch that keeps the 32-bit hash mask.


 
When the number of dentry cache hash table entries gets too high
(2147483648 entries), as happens by default on a 16TB system, use
of a signed integer in the dcache_init() initialization loop prevents
the dentry_hashtable from getting initialized, causing a panic in
__d_lookup().  Fix this in dcache_init() and similar areas.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
---
 fs/dcache.c     |    8 ++++----
 fs/inode.c      |    8 ++++----
 kernel/pid.c    |    4 ++--
 mm/page_alloc.c |    1 +
 net/ipv4/tcp.c  |    5 +++--
 5 files changed, 14 insertions(+), 12 deletions(-)

Index: linux/fs/dcache.c
===================================================================
--- linux.orig/fs/dcache.c
+++ linux/fs/dcache.c
@@ -2968,7 +2968,7 @@ __setup("dhash_entries=", set_dhash_entr
 
 static void __init dcache_init_early(void)
 {
-	int loop;
+	unsigned int loop;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
@@ -2986,13 +2986,13 @@ static void __init dcache_init_early(voi
 					&d_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+	for (loop = 0; loop < (1U << d_hash_shift); loop++)
 		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
 static void __init dcache_init(void)
 {
-	int loop;
+	unsigned int loop;
 
 	/* 
 	 * A constructor could be added for stable state like the lists,
@@ -3016,7 +3016,7 @@ static void __init dcache_init(void)
 					&d_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+	for (loop = 0; loop < (1U << d_hash_shift); loop++)
 		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
Index: linux/fs/inode.c
===================================================================
--- linux.orig/fs/inode.c
+++ linux/fs/inode.c
@@ -1654,7 +1654,7 @@ __setup("ihash_entries=", set_ihash_entr
  */
 void __init inode_init_early(void)
 {
-	int loop;
+	unsigned int loop;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
@@ -1672,13 +1672,13 @@ void __init inode_init_early(void)
 					&i_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+	for (loop = 0; loop < (1U << i_hash_shift); loop++)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
 void __init inode_init(void)
 {
-	int loop;
+	unsigned int loop;
 
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache",
@@ -1702,7 +1702,7 @@ void __init inode_init(void)
 					&i_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+	for (loop = 0; loop < (1U << i_hash_shift); loop++)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -5258,6 +5258,7 @@ void *__init alloc_large_system_hash(con
 		max = ((unsigned long long)nr_all_pages << PAGE_SHIFT) >> 4;
 		do_div(max, bucketsize);
 	}
+	max = min(max, 0x80000000ULL);
 
 	if (numentries > max)
 		numentries = max;
Index: linux/kernel/pid.c
===================================================================
--- linux.orig/kernel/pid.c
+++ linux/kernel/pid.c
@@ -543,12 +543,12 @@ struct pid *find_ge_pid(int nr, struct p
  */
 void __init pidhash_init(void)
 {
-	int i, pidhash_size;
+	unsigned int i, pidhash_size;
 
 	pid_hash = alloc_large_system_hash("PID", sizeof(*pid_hash), 0, 18,
 					   HASH_EARLY | HASH_SMALL,
 					   &pidhash_shift, NULL, 4096);
-	pidhash_size = 1 << pidhash_shift;
+	pidhash_size = 1U << pidhash_shift;
 
 	for (i = 0; i < pidhash_size; i++)
 		INIT_HLIST_HEAD(&pid_hash[i]);
Index: linux/net/ipv4/tcp.c
===================================================================
--- linux.orig/net/ipv4/tcp.c
+++ linux/net/ipv4/tcp.c
@@ -3220,7 +3220,8 @@ void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
 	unsigned long limit;
-	int i, max_share, cnt;
+	int max_share, cnt;
+	unsigned int i;
 	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
@@ -3263,7 +3264,7 @@ void __init tcp_init(void)
 					&tcp_hashinfo.bhash_size,
 					NULL,
 					64 * 1024);
-	tcp_hashinfo.bhash_size = 1 << tcp_hashinfo.bhash_size;
+	tcp_hashinfo.bhash_size = 1U << tcp_hashinfo.bhash_size;
 	for (i = 0; i < tcp_hashinfo.bhash_size; i++) {
 		spin_lock_init(&tcp_hashinfo.bhash[i].lock);
 		INIT_HLIST_HEAD(&tcp_hashinfo.bhash[i].chain);
