From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Sat, 7 Feb 2004 13:33:51 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402071333.51909.kazunori@miyazawa.org>
References: <200402070232.33771.kazunori@miyazawa.org> <4023D6FB.9010909@kolumbus.fi> <20040207.131455.27570445.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / =?iso-2022-jp?q?=1B$B5HF#1QL=40=1B=28B?=" <yoshfuji@linux-ipv6.org>,
        mika.penttila@kolumbus.fi
In-Reply-To: <20040207.131455.27570445.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yoshifuji-san, thank you for following up.
I recreate the pactch. It cares multicast.

> > >Yoshifuji-san and I send the patch
> > > which unifies IPv6 output routine
> > > and remove RTF_NDISC again. It
> > > resolves an issue of IPv6 IPsec
> > > with neighbor discovery without a
> > > flag.
> >
> > You break multicast replies, see
> > what ndisc_build_ll_hdr() does...
>
> It doesn't "break."
> The ip6_output2() resolves and
> inserts link-layer address
> appropriately. If it did, we would
> have noticed (by conformance test or
> even by usual operation). ;-)
>
> BTW, Miyazawa-san, we do not need
> ndisc_build_ll_hdr() anymore.
> Compiler warns it. Please remove it.
> Thanks.
>
>
> Here's the description:
>
> dst->neighbour owns the neighbour
> entry for the destination.
>
> For multicast, we know its link-layer
> address (filled in
> ndisc_constructor()). For unicast,
> the link-layer address may be
> unknown.
>
> ip6_output2() will call
> ip6_output_finish() and it tries
> inserting the link-layer header.
>
> The destination link-layer address is
> used if it is known (*). (Note: you
> remember that we know link-layer
> address for multicast.)
>
--Kazunori Miyazawa

===== include/linux/ipv6_route.h 1.4 vs edited =====
--- 1.4/include/linux/ipv6_route.h	Sun Aug 31 13:26:12 2003
+++ edited/include/linux/ipv6_route.h	Mon Jan 26 15:09:34 2004
@@ -24,7 +24,6 @@
 #define RTF_CACHE	0x01000000	/* cache entry			*/
 #define RTF_FLOW	0x02000000	/* flow significant route	*/
 #define RTF_POLICY	0x04000000	/* policy route			*/
-#define RTF_NDISC	0x08000000	/* ndisc route			*/
 
 #define RTF_LOCAL	0x80000000
 
===== include/net/ip6_route.h 1.11 vs edited =====
--- 1.11/include/net/ip6_route.h	Sat Jul 19 15:42:53 2003
+++ edited/include/net/ip6_route.h	Sat Feb  7 04:11:39 2004
@@ -64,6 +64,7 @@
 
 extern struct dst_entry *ndisc_dst_alloc(struct net_device *dev,
 					 struct neighbour *neigh,
+					 struct in6_addr *addr,
 					 int (*output)(struct sk_buff *));
 extern int ndisc_dst_gc(int *more);
 extern void fib6_force_start_gc(void);
===== include/net/ipv6.h 1.28 vs edited =====
--- 1.28/include/net/ipv6.h	Wed Jan 14 09:36:24 2004
+++ edited/include/net/ipv6.h	Mon Jan 26 15:10:50 2004
@@ -355,6 +355,7 @@
  */
 
 extern int			ip6_output(struct sk_buff *skb);
+extern int			ip6_output2(struct sk_buff *skb);
 extern int			ip6_forward(struct sk_buff *skb);
 extern int			ip6_input(struct sk_buff *skb);
 extern int			ip6_mc_input(struct sk_buff *skb);
===== net/ipv6/ndisc.c 1.64 vs edited =====
--- 1.64/net/ipv6/ndisc.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/ndisc.c	Sat Feb  7 13:06:24 2004
@@ -345,65 +345,10 @@
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
-
-
-static int
-ndisc_build_ll_hdr(struct sk_buff *skb, struct net_device *dev,
-		   struct in6_addr *daddr, struct neighbour *neigh, int len)
-{
-	unsigned char ha[MAX_ADDR_LEN];
-	unsigned char *h_dest = NULL;
-
-	if (dev->hard_header) {
-		if (ipv6_addr_type(daddr) & IPV6_ADDR_MULTICAST) {
-			ndisc_mc_map(daddr, ha, dev, 1);
-			h_dest = ha;
-		} else if (neigh) {
-			read_lock_bh(&neigh->lock);
-			if (neigh->nud_state&NUD_VALID) {
-				memcpy(ha, neigh->ha, dev->addr_len);
-				h_dest = ha;
-			}
-			read_unlock_bh(&neigh->lock);
-		} else {
-			neigh = neigh_lookup(&nd_tbl, daddr, dev);
-			if (neigh) {
-				read_lock_bh(&neigh->lock);
-				if (neigh->nud_state&NUD_VALID) {
-					memcpy(ha, neigh->ha, dev->addr_len);
-					h_dest = ha;
-				}
-				read_unlock_bh(&neigh->lock);
-				neigh_release(neigh);
-			}
-		}
-
-		if (dev->hard_header(skb, dev, ETH_P_IPV6, h_dest, NULL, len) < 0)
-			return 0;
-	}
-
-	return 1;
-}
-
-
 /*
  *	Send a Neighbour Advertisement
  */
 
-static int ndisc_output(struct sk_buff *skb)
-{
-	if (skb) {
-		struct neighbour *neigh = (skb->dst ? skb->dst->neighbour : NULL);
-		if (ndisc_build_ll_hdr(skb, skb->dev, &skb->nh.ipv6h->daddr, neigh, skb->len) == 0) {
-			kfree_skb(skb);
-			return -EINVAL;
-		}
-		dev_queue_xmit(skb);
-		return 0;
-	}
-	return -EINVAL;
-}
-
 static inline void ndisc_flow_init(struct flowi *fl, u8 type,
 			    struct in6_addr *saddr, struct in6_addr *daddr)
 {
@@ -446,7 +391,7 @@
 
 	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_ADVERTISEMENT, src_addr, daddr);
 
-	dst = ndisc_dst_alloc(dev, neigh, ndisc_output);
+	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output2);
 	if (!dst)
 		return;
 
@@ -533,7 +478,7 @@
 
 	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr);
 
-	dst = ndisc_dst_alloc(dev, neigh, ndisc_output);
+	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output2);
 	if (!dst)
 		return;
 
@@ -605,7 +550,7 @@
 
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr);
 
-	dst = ndisc_dst_alloc(dev, NULL, ndisc_output);
+	dst = ndisc_dst_alloc(dev, NULL, daddr, ip6_output2);
 	if (!dst)
 		return;
 
===== net/ipv6/route.c 1.63 vs edited =====
--- 1.63/net/ipv6/route.c	Sun Jan 25 03:09:52 2004
+++ edited/net/ipv6/route.c	Sat Feb  7 03:57:17 2004
@@ -563,6 +563,7 @@
 
 struct dst_entry *ndisc_dst_alloc(struct net_device *dev, 
 				  struct neighbour *neigh,
+				  struct in6_addr *addr,
 				  int (*output)(struct sk_buff *))
 {
 	struct rt6_info *rt = ip6_dst_alloc();
@@ -574,11 +575,13 @@
 		dev_hold(dev);
 	if (neigh)
 		neigh_hold(neigh);
+	else
+		neigh = ndisc_get_neigh(dev, addr);
 
 	rt->rt6i_dev	  = dev;
 	rt->rt6i_nexthop  = neigh;
 	rt->rt6i_expires  = 0;
-	rt->rt6i_flags    = RTF_LOCAL | RTF_NDISC;
+	rt->rt6i_flags    = RTF_LOCAL;
 	rt->rt6i_metric   = 0;
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
@@ -832,7 +835,7 @@
 		}
 	}
 
-	rt->rt6i_flags = rtmsg->rtmsg_flags & ~RTF_NDISC;
+	rt->rt6i_flags = rtmsg->rtmsg_flags;
 
 install_route:
 	if (rta && rta[RTA_METRICS-1]) {
@@ -1124,8 +1127,6 @@
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
 	struct rt6_info *rt = ip6_dst_alloc();
-
-	BUG_ON(ort->rt6i_flags & RTF_NDISC);
 
 	if (rt) {
 		rt->u.dst.input = ort->u.dst.input;
===== net/ipv6/xfrm6_policy.c 1.14 vs edited =====
--- 1.14/net/ipv6/xfrm6_policy.c	Fri Oct 24 21:39:33 2003
+++ edited/net/ipv6/xfrm6_policy.c	Mon Jan 26 15:12:35 2004
@@ -55,13 +55,6 @@
 __xfrm6_find_bundle(struct flowi *fl, struct rtable *rt, struct xfrm_policy *policy)
 {
 	struct dst_entry *dst;
-	u32 ndisc_bit = 0;
-
-	if (fl->proto == IPPROTO_ICMPV6 &&
-	    (fl->fl_icmp_type == NDISC_NEIGHBOUR_ADVERTISEMENT ||
-	     fl->fl_icmp_type == NDISC_NEIGHBOUR_SOLICITATION  ||
-	     fl->fl_icmp_type == NDISC_ROUTER_SOLICITATION))
-		ndisc_bit = RTF_NDISC;
 
 	/* Still not clear if we should set fl->fl6_{src,dst}... */
 	read_lock_bh(&policy->lock);
@@ -69,9 +62,6 @@
 		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
 		struct in6_addr fl_dst_prefix, fl_src_prefix;
 
-		if ((xdst->u.rt6.rt6i_flags & RTF_NDISC) != ndisc_bit)
-			continue;
-
 		ipv6_addr_prefix(&fl_dst_prefix,
 				 &fl->fl6_dst,
 				 xdst->u.rt6.rt6i_dst.plen);
@@ -169,7 +159,7 @@
 		dst_prev->output	= dst_prev->xfrm->type->output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
-		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL|RTF_NDISC);
+		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
 		x->u.rt6.rt6i_metric   = rt0->rt6i_metric;
 		x->u.rt6.rt6i_node     = rt0->rt6i_node;
 		x->u.rt6.rt6i_gateway  = rt0->rt6i_gateway;
