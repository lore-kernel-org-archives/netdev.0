From: James Morris <jmorris@redhat.com>
Subject: [PATCH] SLAB_PANIC cleanup
Date: Tue, 17 Aug 2004 02:43:38 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a cleanup patch which adds the SLAB_PANIC to appropriate calls to 
kmem_cache_create() in the networking code.  This eliminiates the need for 
calling code to check the return value then panic on its own.

I found a few places that did not check for an error return from 
kmem_cache_create(), and these have been converted to use SLAB_PANIC.  
They are:
 net/ipv4/fib_hash.c: fn_hash_kmem = kmem_cache_create("ip_fib_hash"
 net/bridge/br_fdb.c: br_fdb_cache = kmem_cache_create("bridge_fdb_cache"
 net/decnet/dn_table.c:  dn_hash_kmem = kmem_cache_create("dn_fib_info_cache"
 net/socket.c: sock_inode_cachep = kmem_cache_create("sock_inode_cache"

Please review & apply if ok.

Signed-off-by: James Morris <jmorris@redhat.com>

 net/bridge/br_fdb.c    |    4 ++--
 net/core/flow.c        |    5 +----
 net/core/neighbour.c   |    7 ++-----
 net/core/skbuff.c      |    4 +---
 net/core/sock.c        |    6 ++----
 net/decnet/dn_route.c  |    7 ++-----
 net/decnet/dn_table.c  |    2 +-
 net/ipv4/af_inet.c     |   12 ++++++------
 net/ipv4/fib_hash.c    |    4 ++--
 net/ipv4/inetpeer.c    |    5 +----
 net/ipv4/ipmr.c        |    5 +----
 net/ipv4/route.c       |    7 ++-----
 net/ipv4/tcp.c         |   18 ++++++------------
 net/ipv6/af_inet6.c    |   12 ++++++------
 net/ipv6/ip6_fib.c     |    4 +---
 net/ipv6/route.c       |    6 ++----
 net/socket.c           |    9 +++------
 net/unix/af_unix.c     |    7 ++-----
 net/xfrm/xfrm_input.c  |    4 +---
 net/xfrm/xfrm_policy.c |    5 +----
 20 files changed, 45 insertions(+), 88 deletions(-)

diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/bridge/br_fdb.c linux-2.6.8.1-mm1.w/net/bridge/br_fdb.c
--- linux-2.6.8.1-mm1.o/net/bridge/br_fdb.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/bridge/br_fdb.c	2004-08-17 02:41:47.939429992 -0400
@@ -30,8 +30,8 @@
 {
 	br_fdb_cache = kmem_cache_create("bridge_fdb_cache",
 					 sizeof(struct net_bridge_fdb_entry),
-					 0,
-					 SLAB_HWCACHE_ALIGN, NULL, NULL);
+					 0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					 NULL, NULL);
 }
 
 void __exit br_fdb_fini(void)
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/core/flow.c linux-2.6.8.1-mm1.w/net/core/flow.c
--- linux-2.6.8.1-mm1.o/net/core/flow.c	2004-06-16 01:18:55.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/core/flow.c	2004-08-17 02:37:06.516212824 -0400
@@ -343,12 +343,9 @@
 
 	flow_cachep = kmem_cache_create("flow_cache",
 					sizeof(struct flow_cache_entry),
-					0, SLAB_HWCACHE_ALIGN,
+					0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					NULL, NULL);
 
-	if (!flow_cachep)
-		panic("NET: failed to allocate flow cache slab\n");
-
 	flow_hash_shift = 10;
 	flow_lwm = 2 * flow_hash_size;
 	flow_hwm = 4 * flow_hash_size;
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/core/neighbour.c linux-2.6.8.1-mm1.w/net/core/neighbour.c
--- linux-2.6.8.1-mm1.o/net/core/neighbour.c	2004-06-16 01:18:56.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/core/neighbour.c	2004-08-17 02:57:22.888296160 -0400
@@ -1165,12 +1165,9 @@
 	if (!tbl->kmem_cachep)
 		tbl->kmem_cachep = kmem_cache_create(tbl->id,
 						     tbl->entry_size,
-						     0, SLAB_HWCACHE_ALIGN,
+						     0, SLAB_HWCACHE_ALIGN|
+						     SLAB_PANIC,
 						     NULL, NULL);
-
-	if (!tbl->kmem_cachep)
-		panic("cannot create neighbour cache");
-
 	tbl->lock	       = RW_LOCK_UNLOCKED;
 	init_timer(&tbl->gc_timer);
 	tbl->gc_timer.data     = (unsigned long)tbl;
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/core/skbuff.c linux-2.6.8.1-mm1.w/net/core/skbuff.c
--- linux-2.6.8.1-mm1.o/net/core/skbuff.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/core/skbuff.c	2004-08-17 02:38:35.910622808 -0400
@@ -1430,10 +1430,8 @@
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
-					      SLAB_HWCACHE_ALIGN,
+					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					      NULL, NULL);
-	if (!skbuff_head_cache)
-		panic("cannot create skbuff cache");
 }
 
 EXPORT_SYMBOL(___pskb_trim);
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/core/sock.c linux-2.6.8.1-mm1.w/net/core/sock.c
--- linux-2.6.8.1-mm1.o/net/core/sock.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/core/sock.c	2004-08-17 02:51:36.197001248 -0400
@@ -660,10 +660,8 @@
 void __init sk_init(void)
 {
 	sk_cachep = kmem_cache_create("sock", sizeof(struct sock), 0,
-				      SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!sk_cachep)
-		printk(KERN_CRIT "sk_init: Cannot create sock SLAB cache!");
-
+				      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+				      NULL, NULL);
 	if (num_physpages <= 4096) {
 		sysctl_wmem_max = 32767;
 		sysctl_rmem_max = 32767;
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/decnet/dn_route.c linux-2.6.8.1-mm1.w/net/decnet/dn_route.c
--- linux-2.6.8.1-mm1.o/net/decnet/dn_route.c	2004-08-16 19:23:09.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/decnet/dn_route.c	2004-08-17 02:49:12.544839696 -0400
@@ -1788,12 +1788,9 @@
 
 	dn_dst_ops.kmem_cachep = kmem_cache_create("dn_dst_cache",
 						   sizeof(struct dn_route),
-						   0, SLAB_HWCACHE_ALIGN,
+						   0,
+						   SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						   NULL, NULL);
-
-	if (!dn_dst_ops.kmem_cachep)
-		panic("DECnet: Failed to allocate dn_dst_cache\n");
-
 	init_timer(&dn_route_timer);
 	dn_route_timer.function = dn_dst_check_expire;
 	dn_route_timer.expires = jiffies + decnet_dst_gc_interval * HZ;
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/decnet/dn_table.c linux-2.6.8.1-mm1.w/net/decnet/dn_table.c
--- linux-2.6.8.1-mm1.o/net/decnet/dn_table.c	2004-06-16 01:19:02.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/decnet/dn_table.c	2004-08-17 02:48:00.593777920 -0400
@@ -810,7 +810,7 @@
 {
 	dn_hash_kmem = kmem_cache_create("dn_fib_info_cache",
 					sizeof(struct dn_fib_info),
-					0, SLAB_HWCACHE_ALIGN,
+					0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					NULL, NULL);
 }
 
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv4/af_inet.c linux-2.6.8.1-mm1.w/net/ipv4/af_inet.c
--- linux-2.6.8.1-mm1.o/net/ipv4/af_inet.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv4/af_inet.c	2004-08-17 02:30:55.632595704 -0400
@@ -1018,16 +1018,16 @@
 
 	tcp_sk_cachep = kmem_cache_create("tcp_sock",
 					  sizeof(struct tcp_sock), 0,
-					  SLAB_HWCACHE_ALIGN, NULL, NULL);
+					  SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					  NULL, NULL);
 	udp_sk_cachep = kmem_cache_create("udp_sock",
 					  sizeof(struct udp_sock), 0,
-					  SLAB_HWCACHE_ALIGN, NULL, NULL);
+					  SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					  NULL, NULL);
 	raw4_sk_cachep = kmem_cache_create("raw4_sock",
 					   sizeof(struct raw_sock), 0,
-					   SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!tcp_sk_cachep || !udp_sk_cachep || !raw4_sk_cachep)
-		printk(KERN_CRIT
-		       "inet_init: Can't create protocol sock SLAB caches!\n");
+					   SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					   NULL, NULL);
 	/*
 	 *	Tell SOCKET that we are alive... 
 	 */
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv4/fib_hash.c linux-2.6.8.1-mm1.w/net/ipv4/fib_hash.c
--- linux-2.6.8.1-mm1.o/net/ipv4/fib_hash.c	2004-06-16 01:19:23.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv4/fib_hash.c	2004-08-17 02:34:57.717793160 -0400
@@ -873,8 +873,8 @@
 
 	if (fn_hash_kmem == NULL)
 		fn_hash_kmem = kmem_cache_create("ip_fib_hash",
-						 sizeof(struct fib_node),
-						 0, SLAB_HWCACHE_ALIGN,
+						 sizeof(struct fib_node), 0,
+						 SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						 NULL, NULL);
 
 	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv4/inetpeer.c linux-2.6.8.1-mm1.w/net/ipv4/inetpeer.c
--- linux-2.6.8.1-mm1.o/net/ipv4/inetpeer.c	2004-06-16 01:20:03.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv4/inetpeer.c	2004-08-17 02:35:53.926248176 -0400
@@ -126,12 +126,9 @@
 
 	peer_cachep = kmem_cache_create("inet_peer_cache",
 			sizeof(struct inet_peer),
-			0, SLAB_HWCACHE_ALIGN,
+			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 			NULL, NULL);
 
-	if (!peer_cachep)
-		panic("cannot create inet_peer_cache");
-
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
 	 */
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv4/ipmr.c linux-2.6.8.1-mm1.w/net/ipv4/ipmr.c
--- linux-2.6.8.1-mm1.o/net/ipv4/ipmr.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv4/ipmr.c	2004-08-17 02:33:16.673154280 -0400
@@ -1885,11 +1885,8 @@
 {
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
-				       0, SLAB_HWCACHE_ALIGN,
+				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 				       NULL, NULL);
-	if (!mrt_cachep)
-		panic("cannot allocate ip_mrt_cache");
-
 	init_timer(&ipmr_expire_timer);
 	ipmr_expire_timer.function=ipmr_expire_process;
 	register_netdevice_notifier(&ip_mr_notifier);
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv4/route.c linux-2.6.8.1-mm1.w/net/ipv4/route.c
--- linux-2.6.8.1-mm1.o/net/ipv4/route.c	2004-08-16 19:23:09.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv4/route.c	2004-08-17 02:36:33.417244632 -0400
@@ -2760,13 +2760,10 @@
 #endif
 
 	ipv4_dst_ops.kmem_cachep = kmem_cache_create("ip_dst_cache",
-						     sizeof(struct rtable),
-						     0, SLAB_HWCACHE_ALIGN,
+						     sizeof(struct rtable), 0,
+						     SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						     NULL, NULL);
 
-	if (!ipv4_dst_ops.kmem_cachep)
-		panic("IP: failed to allocate ip_dst_cache\n");
-
 	goal = num_physpages >> (26 - PAGE_SHIFT);
 	if (rhash_entries)
 		goal = (rhash_entries * sizeof(struct rt_hash_bucket)) >> PAGE_SHIFT;
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv4/tcp.c linux-2.6.8.1-mm1.w/net/ipv4/tcp.c
--- linux-2.6.8.1-mm1.o/net/ipv4/tcp.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv4/tcp.c	2004-08-17 02:32:26.816733608 -0400
@@ -2211,25 +2211,19 @@
 					   sizeof(skb->cb));
 
 	tcp_openreq_cachep = kmem_cache_create("tcp_open_request",
-						   sizeof(struct open_request),
-					       0, SLAB_HWCACHE_ALIGN,
+					       sizeof(struct open_request), 0,
+					       SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					       NULL, NULL);
-	if (!tcp_openreq_cachep)
-		panic("tcp_init: Cannot alloc open_request cache.");
 
 	tcp_bucket_cachep = kmem_cache_create("tcp_bind_bucket",
-					      sizeof(struct tcp_bind_bucket),
-					      0, SLAB_HWCACHE_ALIGN,
+					      sizeof(struct tcp_bind_bucket), 0,
+					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					      NULL, NULL);
-	if (!tcp_bucket_cachep)
-		panic("tcp_init: Cannot alloc tcp_bind_bucket cache.");
 
 	tcp_timewait_cachep = kmem_cache_create("tcp_tw_bucket",
-						sizeof(struct tcp_tw_bucket),
-						0, SLAB_HWCACHE_ALIGN,
+						sizeof(struct tcp_tw_bucket), 0,
+						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL, NULL);
-	if (!tcp_timewait_cachep)
-		panic("tcp_init: Cannot alloc tcp_tw_bucket cache.");
 
 	/* Size and allocate the main established and bind bucket
 	 * hash tables.
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv6/af_inet6.c linux-2.6.8.1-mm1.w/net/ipv6/af_inet6.c
--- linux-2.6.8.1-mm1.o/net/ipv6/af_inet6.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv6/af_inet6.c	2004-08-17 02:43:32.244573200 -0400
@@ -717,16 +717,16 @@
 	/* allocate our sock slab caches */
         tcp6_sk_cachep = kmem_cache_create("tcp6_sock",
 					   sizeof(struct tcp6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
+                                           SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+                                           NULL, NULL);
         udp6_sk_cachep = kmem_cache_create("udp6_sock",
 					   sizeof(struct udp6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
+                                           SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+                                           NULL, NULL);
         raw6_sk_cachep = kmem_cache_create("raw6_sock",
 					   sizeof(struct raw6_sock), 0,
-                                           SLAB_HWCACHE_ALIGN, NULL, NULL);
-        if (!tcp6_sk_cachep || !udp6_sk_cachep || !raw6_sk_cachep)
-                printk(KERN_CRIT "%s: Can't create protocol sock SLAB "
-		       "caches!\n", __FUNCTION__);
+                                           SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+                                           NULL, NULL);
 
 	/* Register the socket-side information for inet6_create.  */
 	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv6/ip6_fib.c linux-2.6.8.1-mm1.w/net/ipv6/ip6_fib.c
--- linux-2.6.8.1-mm1.o/net/ipv6/ip6_fib.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv6/ip6_fib.c	2004-08-17 02:44:59.806261800 -0400
@@ -1237,10 +1237,8 @@
 {
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!fib6_node_kmem)
-		panic("cannot create fib6_nodes cache");
 }
 
 void __exit fib6_gc_cleanup(void)
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/ipv6/route.c linux-2.6.8.1-mm1.w/net/ipv6/route.c
--- linux-2.6.8.1-mm1.o/net/ipv6/route.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/ipv6/route.c	2004-08-17 02:44:31.302595016 -0400
@@ -2026,11 +2026,9 @@
 
 	ip6_dst_ops.kmem_cachep = kmem_cache_create("ip6_dst_cache",
 						     sizeof(struct rt6_info),
-						     0, SLAB_HWCACHE_ALIGN,
+						     0, SLAB_HWCACHE_ALIGN|
+						     SLAB_PANIC,
 						     NULL, NULL);
-	if (!ip6_dst_ops.kmem_cachep)
-		panic("cannot create ip6_dst_cache");
-
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
 	p = proc_net_create("ipv6_route", 0, rt6_proc_info);
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/socket.c linux-2.6.8.1-mm1.w/net/socket.c
--- linux-2.6.8.1-mm1.o/net/socket.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/socket.c	2004-08-17 02:50:50.653924848 -0400
@@ -307,15 +307,12 @@
 		inode_init_once(&ei->vfs_inode);
 }
  
-static int init_inodecache(void)
+static void init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
 				sizeof(struct socket_alloc),
-				0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
-				init_once, NULL);
-	if (sock_inode_cachep == NULL)
-		return -ENOMEM;
-	return 0;
+				0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
+				SLAB_PANIC, init_once, NULL);
 }
 
 static struct super_operations sockfs_ops = {
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/unix/af_unix.c linux-2.6.8.1-mm1.w/net/unix/af_unix.c
--- linux-2.6.8.1-mm1.o/net/unix/af_unix.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/unix/af_unix.c	2004-08-17 02:47:27.418821280 -0400
@@ -2034,11 +2034,8 @@
         /* allocate our sock slab cache */
         unix_sk_cachep = kmem_cache_create("unix_sock",
 					   sizeof(struct unix_sock), 0,
-					   SLAB_HWCACHE_ALIGN, NULL, NULL);
-        if (!unix_sk_cachep)
-                printk(KERN_CRIT
-                        "af_unix_init: Cannot create unix_sock SLAB cache!\n");
-
+					   SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					   NULL, NULL);
 	sock_register(&unix_family_ops);
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("unix", 0, &unix_seq_fops);
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/xfrm/xfrm_input.c linux-2.6.8.1-mm1.w/net/xfrm/xfrm_input.c
--- linux-2.6.8.1-mm1.o/net/xfrm/xfrm_input.c	2004-06-16 01:18:54.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/xfrm/xfrm_input.c	2004-08-17 02:46:00.745997552 -0400
@@ -78,8 +78,6 @@
 {
 	secpath_cachep = kmem_cache_create("secpath_cache",
 					   sizeof(struct sec_path),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!secpath_cachep)
-		panic("XFRM: failed to allocate secpath_cache\n");
 }
diff -urN -X dontdiff linux-2.6.8.1-mm1.o/net/xfrm/xfrm_policy.c linux-2.6.8.1-mm1.w/net/xfrm/xfrm_policy.c
--- linux-2.6.8.1-mm1.o/net/xfrm/xfrm_policy.c	2004-08-14 10:25:45.000000000 -0400
+++ linux-2.6.8.1-mm1.w/net/xfrm/xfrm_policy.c	2004-08-17 02:46:32.691141152 -0400
@@ -1230,11 +1230,8 @@
 {
 	xfrm_dst_cache = kmem_cache_create("xfrm_dst_cache",
 					   sizeof(struct xfrm_dst),
-					   0, SLAB_HWCACHE_ALIGN,
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL, NULL);
-	if (!xfrm_dst_cache)
-		panic("XFRM: failed to allocate xfrm_dst_cache\n");
-
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task, NULL);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
