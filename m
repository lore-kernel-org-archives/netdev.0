From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: vrf: Fix dst reference counting
Date: Thu,  7 Apr 2016 11:10:06 -0700
Message-ID: <1460052606-1108-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34485 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756645AbcDGSKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:10:15 -0400
Received: by mail-pf0-f176.google.com with SMTP id c20so60173184pfc.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:10:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek reported a kernel exception deleting a VRF with an active
connection through it. The root cause is that the socket has a cached
reference to a dst that is destroyed. Converting the dst_destroy to
dst_release and letting proper reference counting kick in does not
work as the dst has a reference to the device which needs to be released
as well.

I talked to Hannes about this at netdev and he pointed out the ipv4 and
ipv6 dst handling has dst_ifdown for just this scenario. Rather than
continuing with the reinvented dst wheel in VRF just remove it and
leverage the ipv4 and ipv6 versions.

Fixes: 193125dbd8eb2 ("net: Introduce VRF device driver")
Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c       | 177 +++++-------------------------------------------
 include/net/ip6_route.h |   3 +
 include/net/route.h     |   3 +
 net/ipv4/route.c        |   7 +-
 net/ipv6/route.c        |   7 +-
 5 files changed, 30 insertions(+), 167 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 9a9fabb900c1..8a8f1e58b415 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -60,41 +60,6 @@ struct pcpu_dstats {
 	struct u64_stats_sync	syncp;
 };
 
-static struct dst_entry *vrf_ip_check(struct dst_entry *dst, u32 cookie)
-{
-	return dst;
-}
-
-static int vrf_ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
-{
-	return ip_local_out(net, sk, skb);
-}
-
-static unsigned int vrf_v4_mtu(const struct dst_entry *dst)
-{
-	/* TO-DO: return max ethernet size? */
-	return dst->dev->mtu;
-}
-
-static void vrf_dst_destroy(struct dst_entry *dst)
-{
-	/* our dst lives forever - or until the device is closed */
-}
-
-static unsigned int vrf_default_advmss(const struct dst_entry *dst)
-{
-	return 65535 - 40;
-}
-
-static struct dst_ops vrf_dst_ops = {
-	.family		= AF_INET,
-	.local_out	= vrf_ip_local_out,
-	.check		= vrf_ip_check,
-	.mtu		= vrf_v4_mtu,
-	.destroy	= vrf_dst_destroy,
-	.default_advmss	= vrf_default_advmss,
-};
-
 /* neighbor handling is done with actual device; do not want
  * to flip skb->dev for those ndisc packets. This really fails
  * for multiple next protocols (e.g., NEXTHDR_HOP). But it is
@@ -349,46 +314,6 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static struct dst_entry *vrf_ip6_check(struct dst_entry *dst, u32 cookie)
-{
-	return dst;
-}
-
-static struct dst_ops vrf_dst_ops6 = {
-	.family		= AF_INET6,
-	.local_out	= ip6_local_out,
-	.check		= vrf_ip6_check,
-	.mtu		= vrf_v4_mtu,
-	.destroy	= vrf_dst_destroy,
-	.default_advmss	= vrf_default_advmss,
-};
-
-static int init_dst_ops6_kmem_cachep(void)
-{
-	vrf_dst_ops6.kmem_cachep = kmem_cache_create("vrf_ip6_dst_cache",
-						     sizeof(struct rt6_info),
-						     0,
-						     SLAB_HWCACHE_ALIGN,
-						     NULL);
-
-	if (!vrf_dst_ops6.kmem_cachep)
-		return -ENOMEM;
-
-	return 0;
-}
-
-static void free_dst_ops6_kmem_cachep(void)
-{
-	kmem_cache_destroy(vrf_dst_ops6.kmem_cachep);
-}
-
-static int vrf_input6(struct sk_buff *skb)
-{
-	skb->dev->stats.rx_errors++;
-	kfree_skb(skb);
-	return 0;
-}
-
 /* modelled after ip6_finish_output2 */
 static int vrf_finish_output6(struct net *net, struct sock *sk,
 			      struct sk_buff *skb)
@@ -429,67 +354,34 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
 
-static void vrf_rt6_destroy(struct net_vrf *vrf)
+static void vrf_rt6_release(struct net_vrf *vrf)
 {
-	dst_destroy(&vrf->rt6->dst);
-	free_percpu(vrf->rt6->rt6i_pcpu);
+	dst_release(&vrf->rt6->dst);
 	vrf->rt6 = NULL;
 }
 
 static int vrf_rt6_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct dst_entry *dst;
+	struct net *net = dev_net(dev);
 	struct rt6_info *rt6;
-	int cpu;
 	int rc = -ENOMEM;
 
-	rt6 = dst_alloc(&vrf_dst_ops6, dev, 0,
-			DST_OBSOLETE_NONE,
-			(DST_HOST | DST_NOPOLICY | DST_NOXFRM));
+	rt6 = ip6_dst_alloc(net, dev,
+			    DST_HOST | DST_NOPOLICY | DST_NOXFRM | DST_NOCACHE);
 	if (!rt6)
 		goto out;
 
-	dst = &rt6->dst;
-
-	rt6->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_KERNEL);
-	if (!rt6->rt6i_pcpu) {
-		dst_destroy(dst);
-		goto out;
-	}
-	for_each_possible_cpu(cpu) {
-		struct rt6_info **p = per_cpu_ptr(rt6->rt6i_pcpu, cpu);
-		*p =  NULL;
-	}
-
-	memset(dst + 1, 0, sizeof(*rt6) - sizeof(*dst));
-
-	INIT_LIST_HEAD(&rt6->rt6i_siblings);
-	INIT_LIST_HEAD(&rt6->rt6i_uncached);
-
-	rt6->dst.input	= vrf_input6;
 	rt6->dst.output	= vrf_output6;
-
-	rt6->rt6i_table = fib6_get_table(dev_net(dev), vrf->tb_id);
-
-	atomic_set(&rt6->dst.__refcnt, 2);
-
+	rt6->rt6i_table = fib6_get_table(net, vrf->tb_id);
+	dst_hold(&rt6->dst);
 	vrf->rt6 = rt6;
 	rc = 0;
 out:
 	return rc;
 }
 #else
-static int init_dst_ops6_kmem_cachep(void)
-{
-	return 0;
-}
-
-static void free_dst_ops6_kmem_cachep(void)
-{
-}
-
-static void vrf_rt6_destroy(struct net_vrf *vrf)
+static void vrf_rt6_release(struct net_vrf *vrf)
 {
 }
 
@@ -557,11 +449,11 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
-static void vrf_rtable_destroy(struct net_vrf *vrf)
+static void vrf_rtable_release(struct net_vrf *vrf)
 {
 	struct dst_entry *dst = (struct dst_entry *)vrf->rth;
 
-	dst_destroy(dst);
+	dst_release(dst);
 	vrf->rth = NULL;
 }
 
@@ -570,22 +462,10 @@ static struct rtable *vrf_rtable_create(struct net_device *dev)
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct rtable *rth;
 
-	rth = dst_alloc(&vrf_dst_ops, dev, 2,
-			DST_OBSOLETE_NONE,
-			(DST_HOST | DST_NOPOLICY | DST_NOXFRM));
+	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
 	if (rth) {
 		rth->dst.output	= vrf_output;
-		rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
-		rth->rt_flags	= 0;
-		rth->rt_type	= RTN_UNICAST;
-		rth->rt_is_input = 0;
-		rth->rt_iif	= 0;
-		rth->rt_pmtu	= 0;
-		rth->rt_gateway	= 0;
-		rth->rt_uses_gateway = 0;
 		rth->rt_table_id = vrf->tb_id;
-		INIT_LIST_HEAD(&rth->rt_uncached);
-		rth->rt_uncached_list = NULL;
 	}
 
 	return rth;
@@ -673,8 +553,8 @@ static void vrf_dev_uninit(struct net_device *dev)
 	struct net_device *port_dev;
 	struct list_head *iter;
 
-	vrf_rtable_destroy(vrf);
-	vrf_rt6_destroy(vrf);
+	vrf_rtable_release(vrf);
+	vrf_rt6_release(vrf);
 
 	netdev_for_each_lower_dev(dev, port_dev, iter)
 		vrf_del_slave(dev, port_dev);
@@ -704,7 +584,7 @@ static int vrf_dev_init(struct net_device *dev)
 	return 0;
 
 out_rth:
-	vrf_rtable_destroy(vrf);
+	vrf_rtable_release(vrf);
 out_stats:
 	free_percpu(dev->dstats);
 	dev->dstats = NULL;
@@ -737,7 +617,7 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 		struct net_vrf *vrf = netdev_priv(dev);
 
 		rth = vrf->rth;
-		atomic_inc(&rth->dst.__refcnt);
+		dst_hold(&rth->dst);
 	}
 
 	return rth;
@@ -788,7 +668,7 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 		struct net_vrf *vrf = netdev_priv(dev);
 
 		rt = vrf->rt6;
-		atomic_inc(&rt->dst.__refcnt);
+		dst_hold(&rt->dst);
 	}
 
 	return (struct dst_entry *)rt;
@@ -946,19 +826,6 @@ static int __init vrf_init_module(void)
 {
 	int rc;
 
-	vrf_dst_ops.kmem_cachep =
-		kmem_cache_create("vrf_ip_dst_cache",
-				  sizeof(struct rtable), 0,
-				  SLAB_HWCACHE_ALIGN,
-				  NULL);
-
-	if (!vrf_dst_ops.kmem_cachep)
-		return -ENOMEM;
-
-	rc = init_dst_ops6_kmem_cachep();
-	if (rc != 0)
-		goto error2;
-
 	register_netdevice_notifier(&vrf_notifier_block);
 
 	rc = rtnl_link_register(&vrf_link_ops);
@@ -969,22 +836,10 @@ static int __init vrf_init_module(void)
 
 error:
 	unregister_netdevice_notifier(&vrf_notifier_block);
-	free_dst_ops6_kmem_cachep();
-error2:
-	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
 	return rc;
 }
 
-static void __exit vrf_cleanup_module(void)
-{
-	rtnl_link_unregister(&vrf_link_ops);
-	unregister_netdevice_notifier(&vrf_notifier_block);
-	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
-	free_dst_ops6_kmem_cachep();
-}
-
 module_init(vrf_init_module);
-module_exit(vrf_cleanup_module);
 MODULE_AUTHOR("Shrijeet Mukherjee, David Ahern");
 MODULE_DESCRIPTION("Device driver to instantiate VRF domains");
 MODULE_LICENSE("GPL");
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 295d291269e2..54c779416eec 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -101,6 +101,9 @@ void fib6_force_start_gc(struct net *net);
 struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    const struct in6_addr *addr, bool anycast);
 
+struct rt6_info *ip6_dst_alloc(struct net *net, struct net_device *dev,
+			       int flags);
+
 /*
  *	support functions for ND
  *
diff --git a/include/net/route.h b/include/net/route.h
index 9b0a523bb428..6de665bf1750 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -209,6 +209,9 @@ unsigned int inet_addr_type_dev_table(struct net *net,
 void ip_rt_multicast_event(struct in_device *);
 int ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
 void ip_rt_get_source(u8 *src, struct sk_buff *skb, struct rtable *rt);
+struct rtable *rt_dst_alloc(struct net_device *dev,
+			     unsigned int flags, u16 type,
+			     bool nopolicy, bool noxfrm, bool will_cache);
 
 struct in_ifaddr;
 void fib_add_ifaddr(struct in_ifaddr *);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c62299d717..2852bdf73540 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1438,9 +1438,9 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #endif
 }
 
-static struct rtable *rt_dst_alloc(struct net_device *dev,
-				   unsigned int flags, u16 type,
-				   bool nopolicy, bool noxfrm, bool will_cache)
+struct rtable *rt_dst_alloc(struct net_device *dev,
+			    unsigned int flags, u16 type,
+			    bool nopolicy, bool noxfrm, bool will_cache)
 {
 	struct rtable *rt;
 
@@ -1468,6 +1468,7 @@ static struct rtable *rt_dst_alloc(struct net_device *dev,
 
 	return rt;
 }
+EXPORT_SYMBOL(rt_dst_alloc);
 
 /* called in rcu_read_lock() section */
 static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed446639219c..1d8871a5ed20 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -338,9 +338,9 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 	return rt;
 }
 
-static struct rt6_info *ip6_dst_alloc(struct net *net,
-				      struct net_device *dev,
-				      int flags)
+struct rt6_info *ip6_dst_alloc(struct net *net,
+			       struct net_device *dev,
+			       int flags)
 {
 	struct rt6_info *rt = __ip6_dst_alloc(net, dev, flags);
 
@@ -364,6 +364,7 @@ static struct rt6_info *ip6_dst_alloc(struct net *net,
 
 	return rt;
 }
+EXPORT_SYMBOL(ip6_dst_alloc);
 
 static void ip6_dst_destroy(struct dst_entry *dst)
 {
-- 
2.1.4
