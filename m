From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Sat, 7 Feb 2004 02:32:33 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402070232.33771.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, 

Yoshifuji-san and I send the patch which unifies IPv6 output routine and remove
RTF_NDISC again. It resolves an issue of IPv6 IPsec with neighbor discovery
without a flag.

This patch is against linux-2.6.2.

Best regards,

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
+++ edited/net/ipv6/ndisc.c	Mon Jan 26 15:10:16 2004
@@ -390,20 +390,6 @@
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
@@ -446,7 +432,7 @@
 
 	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_ADVERTISEMENT, src_addr, daddr);
 
-	dst = ndisc_dst_alloc(dev, neigh, ndisc_output);
+	dst = ndisc_dst_alloc(dev, neigh, ip6_output2);
 	if (!dst)
 		return;
 
@@ -533,7 +519,7 @@
 
 	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr);
 
-	dst = ndisc_dst_alloc(dev, neigh, ndisc_output);
+	dst = ndisc_dst_alloc(dev, neigh, ip6_output2);
 	if (!dst)
 		return;
 
@@ -605,7 +591,7 @@
 
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr);
 
-	dst = ndisc_dst_alloc(dev, NULL, ndisc_output);
+	dst = ndisc_dst_alloc(dev, NULL, ip6_output2);
 	if (!dst)
 		return;
 
===== net/ipv6/route.c 1.63 vs edited =====
--- 1.63/net/ipv6/route.c	Sun Jan 25 03:09:52 2004
+++ edited/net/ipv6/route.c	Mon Jan 26 15:11:39 2004
@@ -578,7 +578,7 @@
 	rt->rt6i_dev	  = dev;
 	rt->rt6i_nexthop  = neigh;
 	rt->rt6i_expires  = 0;
-	rt->rt6i_flags    = RTF_LOCAL | RTF_NDISC;
+	rt->rt6i_flags    = RTF_LOCAL;
 	rt->rt6i_metric   = 0;
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
@@ -832,7 +832,7 @@
 		}
 	}
 
-	rt->rt6i_flags = rtmsg->rtmsg_flags & ~RTF_NDISC;
+	rt->rt6i_flags = rtmsg->rtmsg_flags;
 
 install_route:
 	if (rta && rta[RTA_METRICS-1]) {
@@ -1124,8 +1124,6 @@
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
