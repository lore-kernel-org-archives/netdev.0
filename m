From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Tue, 28 Jul 2009 20:34:33 -0400
Message-ID: <20090729003433.GA3414@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44156 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165AbZG2Aeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 20:34:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Choose saner defaults for xfrm[4|6] gc_thresh values on init

Currently, the xfrm[4|6] code has hard-coded initial gc_thresh values (set to
1024).  Given that the ipv4 and ipv6 routing caches are sized dynamically at
boot time, the static selections can be non-sensical.  This patch dynamically
selects an appropriate gc threshold based on the corresponding main routing
table size, using the assumption that we should in the worst case be able to
handle as many connections as the routing table can.

For ipv4, the maximum route cache size is 16 * the number of hash buckets in the
route cache.  Given that xfrm4 starts garbage collection at the gc_thresh and
prevents new allocations at 2 * gc_thresh, we set gc_thresh to half the maximum
route cache size.

For ipv6, its a bit trickier.  there is no maximum route cache size, but the
ipv6 dst_ops gc_thresh is statically set to 1024.  It seems sane to select a
simmilar gc_thresh for the xfrm6 code that is half the number of hash buckets in
the v6 route cache times 16 (like the v4 code does).

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/ip6_fib.h   |    6 ++++++
 include/net/xfrm.h      |    2 +-
 net/ipv4/route.c        |    2 +-
 net/ipv4/xfrm4_policy.c |   13 ++++++++++++-
 net/ipv6/ip6_fib.c      |    6 ------
 net/ipv6/xfrm6_policy.c |   15 +++++++++++++++
 6 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 7c5c0f7..5f9abb7 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -22,6 +22,12 @@
 #include <net/flow.h>
 #include <net/netlink.h>
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+#define FIB_TABLE_HASHSZ 256
+#else
+#define FIB_TABLE_HASHSZ 1
+#endif
+
 struct rt6_info;
 
 struct fib6_config
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9e3a3f4..223e90a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1280,7 +1280,7 @@ struct xfrm6_tunnel {
 };
 
 extern void xfrm_init(void);
-extern void xfrm4_init(void);
+extern void xfrm4_init(int rt_hash_size);
 extern int xfrm_state_init(struct net *net);
 extern void xfrm_state_fini(struct net *net);
 extern void xfrm4_state_init(void);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 278f46f..fafbe16 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3442,7 +3442,7 @@ int __init ip_rt_init(void)
 		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
 	xfrm_init();
-	xfrm4_init();
+	xfrm4_init(ip_rt_max_size);
 #endif
 	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL);
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 018ac8b..00f7f80 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -290,10 +290,21 @@ static void __exit xfrm4_policy_fini(void)
 	xfrm_policy_unregister_afinfo(&xfrm4_policy_afinfo);
 }
 
-void __init xfrm4_init(void)
+void __init xfrm4_init(int rt_max_size)
 {
 	xfrm4_state_init();
 	xfrm4_policy_init();
+	/*
+	 * Select a default value for the gc_thresh based on the main route
+	 * table hash size.  It seems to me the worst case scenario is when 
+	 * we have ipsec operating in transport mode, in which we create a
+	 * dst_entry per socket.  The xfrm gc algorithm starts trying to remove
+	 * entries at gc_thresh, and prevents new allocations as 2*gc_thresh
+	 * so lets set an initial xfrm gc_thresh value at the rt_max_size/2.
+	 * That will let us store an ipsec connection per route table entry,
+	 * and start cleaning when were 1/2 full 
+	 */
+	xfrm4_dst_ops.gc_thresh = rt_max_size/2;
 	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path,
 						xfrm4_policy_table);
 }
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 52ee1dc..9e915d3 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -164,12 +164,6 @@ static __inline__ void rt6_release(struct rt6_info *rt)
 		dst_free(&rt->u.dst);
 }
 
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-#define FIB_TABLE_HASHSZ 256
-#else
-#define FIB_TABLE_HASHSZ 1
-#endif
-
 static void fib6_link_table(struct net *net, struct fib6_table *tb)
 {
 	unsigned int h;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 4acc308..db1f927 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -323,6 +323,7 @@ static struct ctl_table_header *sysctl_hdr;
 int __init xfrm6_init(void)
 {
 	int ret;
+	unsigned int gc_thresh;
 
 	ret = xfrm6_policy_init();
 	if (ret)
@@ -331,6 +332,20 @@ int __init xfrm6_init(void)
 	ret = xfrm6_state_init();
 	if (ret)
 		goto out_policy;
+	/*
+	 * We need a good default value for the xfrm6 gc threshold.
+	 * In ipv4 we set it to the route hash table size * 8, which 
+	 * is half the size of the maximaum route cache for ipv4.  It 
+	 * would be good to do the same thing for v6, except the table is
+	 * constructed differently here.  Here each table for a net namespace
+	 * can have FIB_TABLE_HASHSZ entries, so lets go with the same
+	 * computation that we used for ipv4 here.  Also, lets keep the initial
+	 * gc_thresh to a minimum of 1024, since, the ipv6 route cache defaults 
+	 * to that as a minimum as well
+	 */
+	gc_thresh = FIB_TABLE_HASHSZ * 8;
+	xfrm6_dst_ops.gc_thresh = (gc_thresh < 1024) ? 1024 : gc_thresh;
+
 	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv6_ctl_path,
 						xfrm6_policy_table);
 out:
