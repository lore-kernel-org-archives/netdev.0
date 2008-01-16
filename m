From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/2][NETNS][DST] dst: pass the dst_ops as parameter to the gc functions
Date: Wed, 16 Jan 2008 15:54:17 +0100
Message-ID: <20080116150724.711756326@localhost.localdomain>
References: <20080116145416.844293640@localhost.localdomain>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:23826 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbYAPPIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 10:08:46 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0GF8iau289668
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:44 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0GF8i0F4210724
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:44 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0GF8eK2019817
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 15:08:41 GMT
Content-Disposition: inline; filename=pass-dst-gc-ops-parameter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The garbage collection function receive the dst_ops structure as
parameter. This is useful for the next incoming patchset because
it will need the dst_ops (there will be several instances) and 
the network namespace pointer (contained in the dst_ops).

The protocols which do not take care of the namespaces will not
be impacted by this change (expect for the function signature),
they do just ignore the parameter.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/dst.h       |    2 +-
 net/core/dst.c          |    2 +-
 net/decnet/dn_route.c   |    4 ++--
 net/ipv4/route.c        |    6 +++---
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/route.c        |    4 ++--
 net/ipv6/xfrm6_policy.c |    2 +-
 7 files changed, 11 insertions(+), 11 deletions(-)

Index: net-2.6.25-misc/include/net/dst.h
===================================================================
--- net-2.6.25-misc.orig/include/net/dst.h
+++ net-2.6.25-misc/include/net/dst.h
@@ -89,7 +89,7 @@ struct dst_ops
 	__be16			protocol;
 	unsigned		gc_thresh;
 
-	int			(*gc)(void);
+	int			(*gc)(struct dst_ops *ops);
 	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
 	void			(*destroy)(struct dst_entry *);
 	void			(*ifdown)(struct dst_entry *,
Index: net-2.6.25-misc/net/core/dst.c
===================================================================
--- net-2.6.25-misc.orig/net/core/dst.c
+++ net-2.6.25-misc/net/core/dst.c
@@ -165,7 +165,7 @@ void * dst_alloc(struct dst_ops * ops)
 	struct dst_entry * dst;
 
 	if (ops->gc && atomic_read(&ops->entries) > ops->gc_thresh) {
-		if (ops->gc())
+		if (ops->gc(ops))
 			return NULL;
 	}
 	dst = kmem_cache_zalloc(ops->kmem_cachep, GFP_ATOMIC);
Index: net-2.6.25-misc/net/decnet/dn_route.c
===================================================================
--- net-2.6.25-misc.orig/net/decnet/dn_route.c
+++ net-2.6.25-misc/net/decnet/dn_route.c
@@ -107,7 +107,7 @@ static const int dn_rt_mtu_expires = 10 
 
 static unsigned long dn_rt_deadline;
 
-static int dn_dst_gc(void);
+static int dn_dst_gc(struct dst_ops *ops);
 static struct dst_entry *dn_dst_check(struct dst_entry *, __u32);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
@@ -185,7 +185,7 @@ static void dn_dst_check_expire(unsigned
 	mod_timer(&dn_route_timer, now + decnet_dst_gc_interval * HZ);
 }
 
-static int dn_dst_gc(void)
+static int dn_dst_gc(struct dst_ops *ops)
 {
 	struct dn_route *rt, **rtp;
 	int i;
Index: net-2.6.25-misc/net/ipv4/route.c
===================================================================
--- net-2.6.25-misc.orig/net/ipv4/route.c
+++ net-2.6.25-misc/net/ipv4/route.c
@@ -154,7 +154,7 @@ static void		 ipv4_dst_ifdown(struct dst
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
-static int rt_garbage_collect(void);
+static int rt_garbage_collect(struct dst_ops *ops);
 
 
 static struct dst_ops ipv4_dst_ops = {
@@ -820,7 +820,7 @@ static void rt_secret_rebuild(unsigned l
    and when load increases it reduces to limit cache size.
  */
 
-static int rt_garbage_collect(void)
+static int rt_garbage_collect(struct dst_ops *ops)
 {
 	static unsigned long expire = RT_GC_TIMEOUT;
 	static unsigned long last_gc;
@@ -1035,7 +1035,7 @@ restart:
 				int saved_int = ip_rt_gc_min_interval;
 				ip_rt_gc_elasticity	= 1;
 				ip_rt_gc_min_interval	= 0;
-				rt_garbage_collect();
+				rt_garbage_collect(&ipv4_dst_ops);
 				ip_rt_gc_min_interval	= saved_int;
 				ip_rt_gc_elasticity	= saved_elasticity;
 				goto restart;
Index: net-2.6.25-misc/net/ipv4/xfrm4_policy.c
===================================================================
--- net-2.6.25-misc.orig/net/ipv4/xfrm4_policy.c
+++ net-2.6.25-misc/net/ipv4/xfrm4_policy.c
@@ -185,7 +185,7 @@ _decode_session4(struct sk_buff *skb, st
 	fl->fl4_tos = iph->tos;
 }
 
-static inline int xfrm4_garbage_collect(void)
+static inline int xfrm4_garbage_collect(struct dst_ops *ops)
 {
 	xfrm4_policy_afinfo.garbage_collect();
 	return (atomic_read(&xfrm4_dst_ops.entries) > xfrm4_dst_ops.gc_thresh*2);
Index: net-2.6.25-misc/net/ipv6/route.c
===================================================================
--- net-2.6.25-misc.orig/net/ipv6/route.c
+++ net-2.6.25-misc/net/ipv6/route.c
@@ -79,7 +79,7 @@ static struct dst_entry *ip6_negative_ad
 static void		ip6_dst_destroy(struct dst_entry *);
 static void		ip6_dst_ifdown(struct dst_entry *,
 				       struct net_device *dev, int how);
-static int		 ip6_dst_gc(void);
+static int		 ip6_dst_gc(struct dst_ops *ops);
 
 static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
@@ -978,7 +978,7 @@ int ndisc_dst_gc(int *more)
 	return freed;
 }
 
-static int ip6_dst_gc(void)
+static int ip6_dst_gc(struct dst_ops *ops)
 {
 	static unsigned expire = 30*HZ;
 	static unsigned long last_gc;
Index: net-2.6.25-misc/net/ipv6/xfrm6_policy.c
===================================================================
--- net-2.6.25-misc.orig/net/ipv6/xfrm6_policy.c
+++ net-2.6.25-misc/net/ipv6/xfrm6_policy.c
@@ -212,7 +212,7 @@ _decode_session6(struct sk_buff *skb, st
 	}
 }
 
-static inline int xfrm6_garbage_collect(void)
+static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 {
 	xfrm6_policy_afinfo.garbage_collect();
 	return (atomic_read(&xfrm6_dst_ops.entries) > xfrm6_dst_ops.gc_thresh*2);

-- 
