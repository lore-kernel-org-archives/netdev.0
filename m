From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: reduce structures when XFRM=n
Date: Tue, 28 Oct 2008 15:46:22 +0300
Message-ID: <20081028124622.GA9347@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:56645 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbYJ1Mm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 08:42:58 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1018238eyi.37
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 05:42:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifdef out
* struct sk_buff::sp		(pointer)
* struct dst_entry::xfrm	(pointer)
* struct sock::sk_policy	(2 pointers)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/skbuff.h   |   15 ++++++++++++++-
 include/net/dst.h        |    3 ++-
 include/net/sock.h       |    2 ++
 include/net/xfrm.h       |    4 ++++
 net/core/skbuff.c        |    2 +-
 net/ipv4/icmp.c          |    3 ++-
 net/ipv4/ip_forward.c    |    2 +-
 net/ipv4/route.c         |    2 ++
 net/ipv6/icmp.c          |    3 ++-
 net/ipv6/ip6_output.c    |    2 +-
 security/selinux/hooks.c |    4 ++--
 11 files changed, 33 insertions(+), 9 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -269,8 +269,9 @@ struct sk_buff {
 		struct  dst_entry	*dst;
 		struct  rtable		*rtable;
 	};
+#ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
-
+#endif
 	/*
 	 * This is the control buffer. It is free to use for every
 	 * layer. Please put your private variables there. If you
@@ -1864,6 +1865,18 @@ static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_bu
 	to->queue_mapping = from->queue_mapping;
 }
 
+#ifdef CONFIG_XFRM
+static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
+{
+	return skb->sp;
+}
+#else
+static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
+{
+	return NULL;
+}
+#endif
+
 static inline int skb_is_gso(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_size;
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -59,8 +59,9 @@ struct dst_entry
 
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
+#ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
-
+#endif
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -229,7 +229,9 @@ struct sock {
 	} sk_backlog;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
+#ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
+#endif
 	rwlock_t		sk_dst_lock;
 	atomic_t		sk_rmem_alloc;
 	atomic_t		sk_wmem_alloc;
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -882,6 +882,7 @@ struct xfrm_dst
 	u32 path_cookie;
 };
 
+#ifdef CONFIG_XFRM
 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 {
 	dst_release(xdst->route);
@@ -894,6 +895,7 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 	xdst->partner = NULL;
 #endif
 }
+#endif
 
 extern void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
 
@@ -1536,9 +1538,11 @@ static inline void xfrm_states_delete(struct xfrm_state **states, int n)
 }
 #endif
 
+#ifdef CONFIG_XFRM
 static inline struct xfrm_state *xfrm_input_state(struct sk_buff *skb)
 {
 	return skb->sp->xvec[skb->sp->len - 1];
 }
+#endif
 
 #endif	/* _NET_XFRM_H */
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -489,7 +489,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
 	new->dst		= dst_clone(old->dst);
-#ifdef CONFIG_INET
+#ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
 	memcpy(new->cb, old->cb, sizeof(old->cb));
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -976,9 +976,10 @@ int icmp_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(rt->u.dst.dev);
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+		struct sec_path *sp = skb_sec_path(skb);
 		int nh;
 
-		if (!(skb->sp && skb->sp->xvec[skb->sp->len - 1]->props.flags &
+		if (!(sp && sp->xvec[sp->len - 1]->props.flags &
 				 XFRM_STATE_ICMP))
 			goto drop;
 
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -106,7 +106,7 @@ int ip_forward(struct sk_buff *skb)
 	 *	We now generate an ICMP HOST REDIRECT giving the route
 	 *	we calculated.
 	 */
-	if (rt->rt_flags&RTCF_DOREDIRECT && !opt->srr && !skb->sp)
+	if (rt->rt_flags&RTCF_DOREDIRECT && !opt->srr && !skb_sec_path(skb))
 		ip_rt_send_redirect(skb);
 
 	skb->priority = rt_tos2priority(iph->tos);
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1399,7 +1399,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				rt->u.dst.path		= &rt->u.dst;
 				rt->u.dst.neighbour	= NULL;
 				rt->u.dst.hh		= NULL;
+#ifdef CONFIG_XFRM
 				rt->u.dst.xfrm		= NULL;
+#endif
 				rt->rt_genid		= rt_genid(net);
 				rt->rt_flags		|= RTCF_REDIRECTED;
 
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -646,9 +646,10 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	int type;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+		struct sec_path *sp = skb_sec_path(skb);
 		int nh;
 
-		if (!(skb->sp && skb->sp->xvec[skb->sp->len - 1]->props.flags &
+		if (!(sp && sp->xvec[sp->len - 1]->props.flags &
 				 XFRM_STATE_ICMP))
 			goto drop_no_count;
 
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -490,7 +490,7 @@ int ip6_forward(struct sk_buff *skb)
 	   We don't send redirects to frames decapsulated from IPsec.
 	 */
 	if (skb->dev == dst->dev && dst->neighbour && opt->srcrt == 0 &&
-	    !skb->sp) {
+	    !skb_sec_path(skb)) {
 		struct in6_addr *target = NULL;
 		struct rt6_info *rt;
 		struct neighbour *n = dst->neighbour;
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4626,7 +4626,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	 * as fast and as clean as possible. */
 	if (selinux_compat_net || !selinux_policycap_netpeer)
 		return selinux_ip_postroute_compat(skb, ifindex, family);
-
+#ifdef CONFIG_XFRM
 	/* If skb->dst->xfrm is non-NULL then the packet is undergoing an IPsec
 	 * packet transformation so allow the packet to pass without any checks
 	 * since we'll have another chance to perform access control checks
@@ -4635,7 +4635,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	 *       is NULL, in this case go ahead and apply access control. */
 	if (skb->dst != NULL && skb->dst->xfrm != NULL)
 		return NF_ACCEPT;
-
+#endif
 	secmark_active = selinux_secmark_enabled();
 	peerlbl_active = netlbl_enabled() || selinux_xfrm_enabled();
 	if (!secmark_active && !peerlbl_active)
