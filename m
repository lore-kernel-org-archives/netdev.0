From: Shirley Ma <mashirle@us.ibm.com>
Subject: Fix IPv6 MIBs counters in 2.6.5 kernel
Date: Mon, 5 Apr 2004 17:11:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404051711.27188.mashirle@us.ibm.com>
References: <OF8F6A9EBE.82E160C6-ON87256E69.001BB337-88256E69.001D33A3@us.ibm.com> <200404051351.09740.mashirle@us.ibm.com> <20040405144213.198f76ea.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_vWfcAXd3ZEjun88"
Cc: xma@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
        yoshfuji@cerberus.hongo.wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040405144213.198f76ea.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_vWfcAXd3ZEjun88
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have fixed IPv6 MIBs counters which don't increase under some cases
 in linux-2.6.5 kernel.

Please review it.

-- 
Thanks
Shirley Ma
IBM Linux Technology Center


--Boundary-00=_vWfcAXd3ZEjun88
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.5-oldmibs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.5-oldmibs.patch"

diff -urN linux-2.6.5/net/ipv6/exthdrs.c linux-2.6.5-oldmibs/net/ipv6/exthdrs.c
--- linux-2.6.5/net/ipv6/exthdrs.c	2004-04-03 19:36:15.000000000 -0800
+++ linux-2.6.5-oldmibs/net/ipv6/exthdrs.c	2004-04-05 15:34:44.325848720 -0700
@@ -159,6 +159,7 @@
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -171,6 +172,7 @@
 		return 1;
 	}
 
+	IP6_INC_STATS_BH(Ip6InHdrErrors);
 	return -1;
 }
 
@@ -234,6 +236,7 @@
 
 	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
+		IP6_INC_STATS_BH(Ip6InAddrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -249,11 +252,13 @@
 	}
 
 	if (hdr->type != IPV6_SRCRT_TYPE_0) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->type) - skb->nh.raw);
 		return -1;
 	}
 	
 	if (hdr->hdrlen & 0x01) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->hdrlen) - skb->nh.raw);
 		return -1;
 	}
@@ -266,6 +271,7 @@
 	n = hdr->hdrlen >> 1;
 
 	if (hdr->segments_left > n) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->segments_left) - skb->nh.raw);
 		return -1;
 	}
@@ -276,8 +282,11 @@
 	if (skb_cloned(skb)) {
 		struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
 		kfree_skb(skb);
-		if (skb2 == NULL)
+		/* the copy is a forwarded packet */
+		if (skb2 == NULL) {
+			IP6_INC_STATS_BH(Ip6OutDiscards);	
 			return -1;
+		}
 		*skbp = skb = skb2;
 		opt = (struct inet6_skb_parm *)skb2->cb;
 		hdr = (struct ipv6_rt_hdr *) skb2->h.raw;
@@ -293,6 +302,7 @@
 	addr += i - 1;
 
 	if (ipv6_addr_is_multicast(addr)) {
+		IP6_INC_STATS_BH(Ip6InAddrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -309,6 +319,7 @@
 	}
 	if (skb->dst->dev->flags&IFF_LOOPBACK) {
 		if (skb->nh.ipv6h->hop_limit <= 1) {
+			IP6_INC_STATS_BH(Ip6InHdrErrors);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 				    0, skb->dev);
 			kfree_skb(skb);
@@ -425,15 +436,18 @@
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n", skb->nh.raw[optoff+1]);
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		goto drop;
 	}
 
 	pkt_len = ntohl(*(u32*)(skb->nh.raw+optoff+2));
 	if (pkt_len <= IPV6_MAXPLEN) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return 0;
 	}
 	if (skb->nh.ipv6h->payload_len) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
 		return 0;
 	}
diff -urN linux-2.6.5/net/ipv6/ip6_input.c linux-2.6.5-oldmibs/net/ipv6/ip6_input.c
--- linux-2.6.5/net/ipv6/ip6_input.c	2004-04-03 19:37:38.000000000 -0800
+++ linux-2.6.5-oldmibs/net/ipv6/ip6_input.c	2004-04-05 15:09:55.000000000 -0700
@@ -79,8 +79,10 @@
 	if (skb->len < sizeof(struct ipv6hdr))
 		goto err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr))) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
 		goto drop;
+	}
 
 	hdr = skb->nh.ipv6h;
 
@@ -94,8 +96,10 @@
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
 			goto truncated;
 		if (pkt_len + sizeof(struct ipv6hdr) < skb->len) {
-			if (__pskb_trim(skb, pkt_len + sizeof(struct ipv6hdr)))
+			if (__pskb_trim(skb, pkt_len + sizeof(struct ipv6hdr))){
+				IP6_INC_STATS_BH(Ip6InHdrErrors);
 				goto drop;
+			}
 			hdr = skb->nh.ipv6h;
 			if (skb->ip_summed == CHECKSUM_HW)
 				skb->ip_summed = CHECKSUM_NONE;
@@ -206,6 +210,7 @@
 	return 0;
 
 discard:
+	IP6_INC_STATS_BH(Ip6InDiscards);
 	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
diff -urN linux-2.6.5/net/ipv6/ip6_output.c linux-2.6.5-oldmibs/net/ipv6/ip6_output.c
--- linux-2.6.5/net/ipv6/ip6_output.c	2004-04-03 19:36:16.000000000 -0800
+++ linux-2.6.5-oldmibs/net/ipv6/ip6_output.c	2004-04-05 15:09:55.000000000 -0700
@@ -87,6 +87,7 @@
 	} else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
+	IP6_INC_STATS_BH(Ip6OutNoRoutes);
 	kfree_skb(skb);
 	return -EINVAL;
 
@@ -131,6 +132,7 @@
 					ip6_dev_loopback_xmit);
 
 			if (skb->nh.ipv6h->hop_limit == 0) {
+				IP6_INC_STATS(Ip6OutDiscards);
 				kfree_skb(skb);
 				return 0;
 			}
@@ -167,6 +169,7 @@
 	dst = ip6_route_output(skb->sk, &fl);
 
 	if (dst->error) {
+		IP6_INC_STATS(Ip6OutNoRoutes);
 		if (net_ratelimit())
 			printk(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
 		dst_release(dst);
@@ -224,8 +227,10 @@
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
 			kfree_skb(skb);
 			skb = skb2;
-			if (skb == NULL)
+			if (skb == NULL) {	
+				IP6_INC_STATS(Ip6OutDiscards);
 				return -ENOBUFS;
+			}
 			if (sk)
 				skb_set_owner_w(skb, sk);
 		}
@@ -265,6 +270,7 @@
 		printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+	IP6_INC_STATS(Ip6FragFails);
 	kfree_skb(skb);
 	return -EMSGSIZE;
 }
@@ -345,8 +351,10 @@
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
 
-	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb))
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
+		IP6_INC_STATS(Ip6InDiscards);
 		goto drop;
+	}
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -382,8 +390,10 @@
 		return -ETIMEDOUT;
 	}
 
-	if (!xfrm6_route_forward(skb))
+	if (!xfrm6_route_forward(skb)) {
+		IP6_INC_STATS(Ip6InDiscards);
 		goto drop;
+	}
 
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.
@@ -420,12 +430,15 @@
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_pmtu(dst), skb->dev);
 		IP6_INC_STATS_BH(Ip6InTooBigErrors);
+		IP6_INC_STATS_BH(Ip6FragFails);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
 
-	if (skb_cow(skb, dst->dev->hard_header_len))
+	if (skb_cow(skb, dst->dev->hard_header_len)) {
+		IP6_INC_STATS(Ip6OutDiscards);
 		goto drop;
+	}
 
 	hdr = skb->nh.ipv6h;
 
@@ -648,6 +661,7 @@
 
 		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(printk(KERN_INFO "IPv6: frag: no memory for new fragment!\n"));
+			IP6_INC_STATS(Ip6FragFails);
 			err = -ENOMEM;
 			goto fail;
 		}
@@ -1062,6 +1076,7 @@
 	ipv6_addr_copy(&hdr->daddr, final_dst);
 
 	skb->dst = dst_clone(&rt->u.dst);
+	IP6_INC_STATS(Ip6OutRequests);	
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
 	if (err) {
 		if (err > 0)
@@ -1092,8 +1107,10 @@
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
 
-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		IP6_INC_STATS(Ip6OutDiscards);
 		kfree_skb(skb);
+	}
 
 	inet->cork.flags &= ~IPCORK_OPT;
 
diff -urN linux-2.6.5/net/ipv6/ndisc.c linux-2.6.5-oldmibs/net/ipv6/ndisc.c
--- linux-2.6.5/net/ipv6/ndisc.c	2004-04-03 19:37:23.000000000 -0800
+++ linux-2.6.5-oldmibs/net/ipv6/ndisc.c	2004-04-05 15:09:55.000000000 -0700
@@ -452,6 +452,7 @@
 
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
+	IP6_INC_STATS(Ip6OutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutNeighborAdvertisements);
@@ -535,6 +536,7 @@
 	/* send it! */
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
+	IP6_INC_STATS(Ip6OutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutNeighborSolicits);
@@ -607,6 +609,7 @@
 	/* send it! */
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
+	IP6_INC_STATS(Ip6OutRequests);	
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutRouterSolicits);
@@ -1332,6 +1335,7 @@
 
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
+	IP6_INC_STATS(Ip6OutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutRedirects);
diff -urN linux-2.6.5/net/ipv6/raw.c linux-2.6.5-oldmibs/net/ipv6/raw.c
--- linux-2.6.5/net/ipv6/raw.c	2004-04-03 19:36:56.000000000 -0800
+++ linux-2.6.5-oldmibs/net/ipv6/raw.c	2004-04-05 15:09:55.000000000 -0700
@@ -526,6 +526,7 @@
 	if (err)
 		goto error_fault;
 
+	IP6_INC_STATS(Ip6OutRequests);		
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
diff -urN linux-2.6.5/net/ipv6/reassembly.c linux-2.6.5-oldmibs/net/ipv6/reassembly.c
--- linux-2.6.5/net/ipv6/reassembly.c	2004-04-03 19:36:55.000000000 -0800
+++ linux-2.6.5-oldmibs/net/ipv6/reassembly.c	2004-04-05 15:09:55.000000000 -0700
@@ -426,6 +426,7 @@
 			((u8 *) (fhdr + 1) - (u8 *) (skb->nh.ipv6h + 1)));
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
+		IP6_INC_STATS_BH(Ip6InHdrErrors);
  		icmpv6_param_prob(skb,ICMPV6_HDR_FIELD, (u8*)&fhdr->frag_off - skb->nh.raw);
  		return;
 	}
@@ -452,6 +453,7 @@
 			/* RFC2460 says always send parameter problem in
 			 * this case. -DaveM
 			 */
+			IP6_INC_STATS_BH(Ip6InHdrErrors);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, 
 					  offsetof(struct ipv6hdr, payload_len));
 			return;
@@ -570,6 +572,7 @@
 	return;
 
 err:
+	IP6_INC_STATS(Ip6ReasmFails);
 	kfree_skb(skb);
 }
 
@@ -694,10 +697,12 @@
 
 	/* Jumbo payload inhibits frag. header */
 	if (hdr->payload_len==0) {
+		IP6_INC_STATS(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb->h.raw-skb->nh.raw);
 		return -1;
 	}
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+sizeof(struct frag_hdr))) {
+		IP6_INC_STATS(Ip6InHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb->h.raw-skb->nh.raw);
 		return -1;
 	}

--Boundary-00=_vWfcAXd3ZEjun88--
