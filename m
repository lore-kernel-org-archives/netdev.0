From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] xfrm: select sane defaults for xfrm[4|6] gc_thresh
Date: Thu, 30 Jul 2009 21:11:30 -0400
Message-ID: <20090731011130.GA16769@localhost.localdomain>
References: <20090729003433.GA3414@localhost.localdomain> <20090730.142345.148651785.davem@davemloft.net> <20090730.142554.103113174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45275 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbZGaBLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 21:11:39 -0400
Content-Disposition: inline
In-Reply-To: <20090730.142554.103113174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 02:25:54PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 30 Jul 2009 14:23:45 -0700 (PDT)
> 
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Tue, 28 Jul 2009 20:34:33 -0400
> > 
> >> Choose saner defaults for xfrm[4|6] gc_thresh values on init
> > 
> > Looks great, applied to net-next-2.6
> 
> Actually I had to revert, how the heck did you build test
> this? :-/
> 
> In file included from include/net/xfrm.h:21,
>                  from net/ipv4/af_inet.c:113:
> include/net/ip6_fib.h:28:1: warning: "FIB_TABLE_HASHSZ" redefined
> In file included from net/ipv4/af_inet.c:102:
> include/net/ip_fib.h:134:1: warning: this is the location of the previous definition
> 

Ok, version 2. I'm not sure exactly what went wrong, but I definately had it
built and running.  My best guess is that I did a partial build in a tree, and
the dependency check decided that the ipv4 code didn't need to be rebuilt, and
so I didn't get the error.  Anywho, The problem is that the ipv4 code had
FIB_TABLE_HASHSZ defined globally, which was causing namespace clashes with my
changes (which moved the privately ipv6 defined FIB_TABLE_HASHSZ to a global
visibility).  I've fixed it by modifying the IPv6 definition and uses to be
FIB6_TABLE_HASHSZ.  I just tested it (with a clean build), and it works fine.
Apologies for the noise.

Neil


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
 net/ipv6/ip6_fib.c      |   16 +++++-----------
 net/ipv6/xfrm6_policy.c |   15 +++++++++++++++
 6 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 7c5c0f7..15b492a 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -22,6 +22,12 @@
 #include <net/flow.h>
 #include <net/netlink.h>
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+#define FIB6_TABLE_HASHSZ 256
+#else
+#define FIB6_TABLE_HASHSZ 1
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
index 52ee1dc..0e93ca5 100644
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
@@ -180,7 +174,7 @@ static void fib6_link_table(struct net *net, struct fib6_table *tb)
 	 */
 	rwlock_init(&tb->tb6_lock);
 
-	h = tb->tb6_id & (FIB_TABLE_HASHSZ - 1);
+	h = tb->tb6_id & (FIB6_TABLE_HASHSZ - 1);
 
 	/*
 	 * No protection necessary, this is the only list mutatation
@@ -231,7 +225,7 @@ struct fib6_table *fib6_get_table(struct net *net, u32 id)
 
 	if (id == 0)
 		id = RT6_TABLE_MAIN;
-	h = id & (FIB_TABLE_HASHSZ - 1);
+	h = id & (FIB6_TABLE_HASHSZ - 1);
 	rcu_read_lock();
 	head = &net->ipv6.fib_table_hash[h];
 	hlist_for_each_entry_rcu(tb, node, head, tb6_hlist) {
@@ -382,7 +376,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	arg.net = net;
 	w->args = &arg;
 
-	for (h = s_h; h < FIB_TABLE_HASHSZ; h++, s_e = 0) {
+	for (h = s_h; h < FIB6_TABLE_HASHSZ; h++, s_e = 0) {
 		e = 0;
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry(tb, node, head, tb6_hlist) {
@@ -1368,7 +1362,7 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 	unsigned int h;
 
 	rcu_read_lock();
-	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(table, node, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
@@ -1483,7 +1477,7 @@ static int fib6_net_init(struct net *net)
 	if (!net->ipv6.rt6_stats)
 		goto out_timer;
 
-	net->ipv6.fib_table_hash = kcalloc(FIB_TABLE_HASHSZ,
+	net->ipv6.fib_table_hash = kcalloc(FIB6_TABLE_HASHSZ,
 					   sizeof(*net->ipv6.fib_table_hash),
 					   GFP_KERNEL);
 	if (!net->ipv6.fib_table_hash)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 4acc308..4df7da6 100644
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
+	gc_thresh = FIB6_TABLE_HASHSZ * 8;
+	xfrm6_dst_ops.gc_thresh = (gc_thresh < 1024) ? 1024 : gc_thresh;
+
 	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv6_ctl_path,
 						xfrm6_policy_table);
 out:
