From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation with IPv6 Neighbor Discovery
Date: Thu, 15 Aug 2013 01:06:17 +0200
Message-ID: <20130814230617.GA13066@order.stressinduktion.org>
References: <20130813221321.AEA1AB1E003@rfc-editor.org> <520B3D81.9070506@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52478 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933229Ab3HNXGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 19:06:19 -0400
Content-Disposition: inline
In-Reply-To: <520B3D81.9070506@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 05:19:13AM -0300, Fernando Gont wrote:
> Folks,
> 
> FYI. -- this is an important piece when it comes to First Hop (i.e.,
> "local link") Security.

Thanks for the heads-up, Fernando!

I sketched up a patch to protect the receiving side. I still don't know if I
should make this behaviour default or configurable via a sysctl knob. I really
don't want to break existing installations.

As an extra plus, we now discard packets with nested fragment headers at once.
Those packets should never have been accepted.

Thanks,

  Hannes


diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 77a4784..9ac5047 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -103,6 +103,7 @@ struct inet6_skb_parm {
 #define IP6SKB_FORWARDED	2
 #define IP6SKB_REROUTED		4
 #define IP6SKB_ROUTERALERT	8
+#define IP6SKB_FRAGMENTED      16
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 79aa965..5c91616 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1524,6 +1524,9 @@ int ndisc_rcv(struct sk_buff *skb)
 	if (skb_linearize(skb))
 		return 0;
 
+	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED)
+		return 0;
+
 	msg = (struct nd_msg *)skb_transport_header(skb);
 
 	__skb_push(skb, skb->data - skb_transport_header(skb));
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 790d9f4..1aeb473 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -490,6 +490,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	ipv6_hdr(head)->payload_len = htons(payload_len);
 	ipv6_change_dsfield(ipv6_hdr(head), 0xff, ecn);
 	IP6CB(head)->nhoff = nhoff;
+	IP6CB(head)->flags |= IP6SKB_FRAGMENTED;
 
 	/* Yes, and fold redundant checksum back. 8) */
 	if (head->ip_summed == CHECKSUM_COMPLETE)
@@ -524,6 +525,9 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int evicted;
 
+	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED)
+		goto fail_hdr;
+
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
@@ -544,6 +548,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 				 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMOKS);
 
 		IP6CB(skb)->nhoff = (u8 *)fhdr - skb_network_header(skb);
+		IP6CB(skb)->flags |= IP6SKB_FRAGMENTED;
 		return 1;
 	}
 
