From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [17/*] [NET] Replace dst_pmtu with dst_mtu
Date: Tue, 15 Mar 2005 21:05:22 +1100
Message-ID: <20050315100522.GA7275@gondor.apana.org.au>
References: <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ikeVEW9yuYc//A+q"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050315095837.GA7130@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch replaces most of the other uses of dst_pmtu with dst_mtu.
As far as I can tell these are either identical because dst->path == dst,
or they're a straightforward replacement of (the slightly incorrect)
dst_pmtu(dst) - dst->header_Len with dst_mtu(dst).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

At this point the only remaining user of dst_pmtu is ipt_REJECT which
will go away either when we use icmp_send in there or when I replace
it with dst_mtu.

We can now remove the other users of dst->path as well with the removal
of that attribute itself as the goal.
  
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-17

===== net/decnet/af_decnet.c 1.49 vs edited =====
--- 1.49/net/decnet/af_decnet.c	2005-01-21 09:35:54 +11:00
+++ edited/net/decnet/af_decnet.c	2005-03-15 20:59:05 +11:00
@@ -1868,7 +1868,7 @@
 
 	/* This works out the maximum size of segment we can send out */
 	if (dst) {
-		u32 mtu = dst_pmtu(dst);
+		u32 mtu = dst_mtu(dst);
 		mss_now = min_t(int, dn_mss_from_pmtu(dst->dev, mtu), mss_now);
 	}
 
===== net/decnet/dn_route.c 1.32 vs edited =====
--- 1.32/net/decnet/dn_route.c	2005-03-11 13:17:32 +11:00
+++ edited/net/decnet/dn_route.c	2005-03-15 20:59:05 +11:00
@@ -817,7 +817,7 @@
 	if (rt->u.dst.metrics[RTAX_MTU-1] == 0 || 
             rt->u.dst.metrics[RTAX_MTU-1] > rt->u.dst.dev->mtu)
 		rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
-	mss = dn_mss_from_pmtu(dev, dst_pmtu(&rt->u.dst));
+	mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->u.dst));
 	if (rt->u.dst.metrics[RTAX_ADVMSS-1] == 0 ||
 	    rt->u.dst.metrics[RTAX_ADVMSS-1] > mss)
 		rt->u.dst.metrics[RTAX_ADVMSS-1] = mss;
===== net/ipv4/ip_output.c 1.76 vs edited =====
--- 1.76/net/ipv4/ip_output.c	2005-02-01 02:43:53 +11:00
+++ edited/net/ipv4/ip_output.c	2005-03-15 20:59:05 +11:00
@@ -278,7 +278,7 @@
 				newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	if (skb->len > dst_pmtu(&rt->u.dst))
+	if (skb->len > dst_mtu(&rt->u.dst))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -288,7 +288,7 @@
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_pmtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -448,7 +448,7 @@
 
 	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(dst_pmtu(&rt->u.dst)));
+			  htonl(dst_mtu(&rt->u.dst)));
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
@@ -458,7 +458,7 @@
 	 */
 
 	hlen = iph->ihl * 4;
-	mtu = dst_pmtu(&rt->u.dst) - hlen;	/* Size of data space */
+	mtu = dst_mtu(&rt->u.dst) - hlen;	/* Size of data space */
 
 	/* When frag_list is given, use it. First, check its validity:
 	 * some transformers could create wrong frag_list or break existing
===== net/ipv4/ip_sockglue.c 1.31 vs edited =====
--- 1.31/net/ipv4/ip_sockglue.c	2005-01-14 15:41:05 +11:00
+++ edited/net/ipv4/ip_sockglue.c	2005-03-15 20:59:05 +11:00
@@ -955,7 +955,7 @@
 			val = 0;
 			dst = sk_dst_get(sk);
 			if (dst) {
-				val = dst_pmtu(dst) - dst->header_len;
+				val = dst_mtu(dst);
 				dst_release(dst);
 			}
 			if (!val) {
===== net/ipv6/ip6_output.c 1.85 vs edited =====
--- 1.85/net/ipv6/ip6_output.c	2005-03-03 16:12:38 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-03-15 20:59:05 +11:00
@@ -147,7 +147,7 @@
 
 int ip6_output(struct sk_buff *skb)
 {
-	if (skb->len > dst_pmtu(skb->dst) || dst_allfrag(skb->dst))
+	if (skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -263,7 +263,7 @@
 	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
 	ipv6_addr_copy(&hdr->daddr, first_hop);
 
-	mtu = dst_pmtu(dst);
+	mtu = dst_mtu(dst);
 	if ((skb->len <= mtu) || ipfragok) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_maybe_reroute);
@@ -428,10 +428,10 @@
 		goto error;
 	}
 
-	if (skb->len > dst_pmtu(dst)) {
+	if (skb->len > dst_mtu(dst)) {
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_pmtu(dst), skb->dev);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_mtu(dst), skb->dev);
 		IP6_INC_STATS_BH(IPSTATS_MIB_INTOOBIGERRORS);
 		IP6_INC_STATS_BH(IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
@@ -534,7 +534,7 @@
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
 
-	mtu = dst_pmtu(&rt->u.dst) - hlen - sizeof(struct frag_hdr);
+	mtu = dst_mtu(&rt->u.dst) - hlen - sizeof(struct frag_hdr);
 
 	if (skb_shinfo(skb)->frag_list) {
 		int first_len = skb_pagelen(skb);
===== net/ipv6/ipv6_sockglue.c 1.34 vs edited =====
--- 1.34/net/ipv6/ipv6_sockglue.c	2005-01-14 15:41:06 +11:00
+++ edited/net/ipv6/ipv6_sockglue.c	2005-03-15 20:59:05 +11:00
@@ -607,7 +607,7 @@
 		lock_sock(sk);
 		dst = sk_dst_get(sk);
 		if (dst) {
-			val = dst_pmtu(dst) - dst->header_len;
+			val = dst_mtu(dst);
 			dst_release(dst);
 		}
 		release_sock(sk);
===== net/ipv6/route.c 1.111 vs edited =====
--- 1.111/net/ipv6/route.c	2005-03-11 13:17:32 +11:00
+++ edited/net/ipv6/route.c	2005-03-15 20:59:05 +11:00
@@ -625,7 +625,7 @@
 {
 	struct rt6_info *rt6 = (struct rt6_info*)dst;
 
-	if (mtu < dst_pmtu(dst) && rt6->rt6i_dst.plen == 128) {
+	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
 		rt6->rt6i_flags |= RTF_MODIFIED;
 		if (mtu < IPV6_MIN_MTU) {
 			mtu = IPV6_MIN_MTU;
@@ -686,7 +686,7 @@
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.output  = output;
 
 #if 0	/* there's no chance to use these for ndisc */
@@ -971,7 +971,7 @@
 	if (!rt->u.dst.metrics[RTAX_MTU-1])
 		rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
 	if (!rt->u.dst.metrics[RTAX_ADVMSS-1])
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
+		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
 	return ip6_ins_rt(rt, nlh, _rtattr);
@@ -1134,7 +1134,7 @@
 	nrt->rt6i_nexthop = neigh_clone(neigh);
 	/* Reset pmtu, it may be better */
 	nrt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
-	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&nrt->u.dst));
+	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&nrt->u.dst));
 
 	if (ip6_ins_rt(nrt, NULL, NULL))
 		goto out;
@@ -1164,7 +1164,7 @@
 	if (rt == NULL)
 		return;
 
-	if (pmtu >= dst_pmtu(&rt->u.dst))
+	if (pmtu >= dst_mtu(&rt->u.dst))
 		goto out;
 
 	if (pmtu < IPV6_MIN_MTU) {
@@ -1405,7 +1405,7 @@
 	rt->rt6i_dev = &loopback_dev;
 	rt->rt6i_idev = idev;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
 	rt->u.dst.obsolete = -1;
 
@@ -1480,9 +1480,9 @@
 	 */
 	if (rt->rt6i_dev == arg->dev &&
 	    !dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
-            (dst_pmtu(&rt->u.dst) > arg->mtu ||
-             (dst_pmtu(&rt->u.dst) < arg->mtu &&
-	      dst_pmtu(&rt->u.dst) == idev->cnf.mtu6)))
+            (dst_mtu(&rt->u.dst) > arg->mtu ||
+             (dst_mtu(&rt->u.dst) < arg->mtu &&
+	      dst_mtu(&rt->u.dst) == idev->cnf.mtu6)))
 		rt->u.dst.metrics[RTAX_MTU-1] = arg->mtu;
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(arg->mtu);
 	return 0;
===== net/sctp/transport.c 1.31 vs edited =====
--- 1.31/net/sctp/transport.c	2005-01-15 15:32:41 +11:00
+++ edited/net/sctp/transport.c	2005-03-15 20:59:05 +11:00
@@ -227,7 +227,7 @@
 	dst = transport->af_specific->get_dst(NULL, &transport->ipaddr, NULL);
 
 	if (dst) {
-		transport->pmtu = dst_pmtu(dst);
+		transport->pmtu = dst_mtu(dst);
 		dst_release(dst);
 	} else
 		transport->pmtu = SCTP_DEFAULT_MAXSEGMENT;
@@ -253,7 +253,7 @@
 
 	transport->dst = dst;
 	if (dst) {
-		transport->pmtu = dst_pmtu(dst);
+		transport->pmtu = dst_mtu(dst);
 
 		/* Initialize sk->sk_rcv_saddr, if the transport is the
 		 * association's active path for getsockname().
===== net/xfrm/xfrm_policy.c 1.72 vs edited =====
--- 1.72/net/xfrm/xfrm_policy.c	2005-03-11 13:17:32 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-03-15 20:59:05 +11:00
@@ -1119,12 +1119,12 @@
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 		u32 pmtu, route_mtu_cached;
 
-		pmtu = dst_pmtu(dst->child);
+		pmtu = dst_mtu(dst->child);
 		xdst->child_mtu_cached = pmtu;
 
 		pmtu = xfrm_state_mtu(dst->xfrm, pmtu);
 
-		route_mtu_cached = dst_pmtu(xdst->route);
+		route_mtu_cached = dst_mtu(xdst->route);
 		xdst->route_mtu_cached = route_mtu_cached;
 
 		if (pmtu > route_mtu_cached)
@@ -1160,7 +1160,7 @@
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
 
-		mtu = dst_pmtu(dst->child);
+		mtu = dst_mtu(dst->child);
 		if (xdst->child_mtu_cached != mtu) {
 			last = xdst;
 			xdst->child_mtu_cached = mtu;
@@ -1168,7 +1168,7 @@
 
 		if (!dst_check(xdst->route, 0))
 			return 0;
-		mtu = dst_pmtu(xdst->route);
+		mtu = dst_mtu(xdst->route);
 		if (xdst->route_mtu_cached != mtu) {
 			last = xdst;
 			xdst->route_mtu_cached = mtu;

--ikeVEW9yuYc//A+q--
