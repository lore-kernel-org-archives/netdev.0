From: Dimitri Sivanich <sivanich@sgi.com>
Subject: [PATCH] Fix panic in __d_lookup with high dentry hashtable counts
Date: Fri, 13 Jan 2012 09:52:37 -0600
Message-ID: <20120113155237.GA25103@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:40901 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932140Ab2AMPwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 10:52:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the number of dentry cache hash table entries gets too high
(2147483648 entries), use of a signed integer in the initialization
loop prevents the dentry_hashtable from getting initialized, resulting
in a panic in __d_lookup.  Fixing this in dcache_init and a few other
spots for consistency.

Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
---
 fs/dcache.c    |    8 ++++----
 fs/inode.c     |    8 ++++----
 kernel/pid.c   |    4 ++--
 net/ipv4/tcp.c |    3 ++-
 4 files changed, 12 insertions(+), 11 deletions(-)

Index: linux/fs/dcache.c
===================================================================
--- linux.orig/fs/dcache.c
+++ linux/fs/dcache.c
@@ -2968,7 +2968,7 @@ __setup("dhash_entries=", set_dhash_entr
 
 static void __init dcache_init_early(void)
 {
-	int loop;
+	long loop;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
@@ -2986,13 +2986,13 @@ static void __init dcache_init_early(voi
 					&d_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+	for (loop = 0; loop < (1L << d_hash_shift); loop++)
 		INIT_HLIST_BL_HEAD(dentry_hashtable + loop);
 }
 
 static void __init dcache_init(void)
 {
-	int loop;
+	long loop;
 
 	/* 
 	 * A constructor could be added for stable state like the lists,
@@ -3016,7 +3016,7 @@ static void __init dcache_init(void)
 					&d_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
+	for (loop = 0; loop < (1L << d_hash_shift); loop++)
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
+	long loop;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
@@ -1672,13 +1672,13 @@ void __init inode_init_early(void)
 					&i_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+	for (loop = 0; loop < (1L << i_hash_shift); loop++)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
 void __init inode_init(void)
 {
-	int loop;
+	long loop;
 
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache",
@@ -1702,7 +1702,7 @@ void __init inode_init(void)
 					&i_hash_mask,
 					0);
 
-	for (loop = 0; loop < (1 << i_hash_shift); loop++)
+	for (loop = 0; loop < (1L << i_hash_shift); loop++)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
Index: linux/kernel/pid.c
===================================================================
--- linux.orig/kernel/pid.c
+++ linux/kernel/pid.c
@@ -543,12 +543,12 @@ struct pid *find_ge_pid(int nr, struct p
  */
 void __init pidhash_init(void)
 {
-	int i, pidhash_size;
+	long i, pidhash_size;
 
 	pid_hash = alloc_large_system_hash("PID", sizeof(*pid_hash), 0, 18,
 					   HASH_EARLY | HASH_SMALL,
 					   &pidhash_shift, NULL, 4096);
-	pidhash_size = 1 << pidhash_shift;
+	pidhash_size = 1L << pidhash_shift;
 
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
+	long i;
+	int max_share, cnt;
 	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
