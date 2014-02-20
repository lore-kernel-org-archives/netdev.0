From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Thu, 20 Feb 2014 03:44:18 +0100
Message-ID: <20140220024418.GG1179@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de> <20140211024403.GE11150@order.stressinduktion.org> <5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de> <20140217160916.GE22833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39800 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbaBTCoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 21:44:20 -0500
Content-Disposition: inline
In-Reply-To: <20140217160916.GE22833@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 05:09:16PM +0100, Hannes Frederic Sowa wrote:
> [+Cc Cong Wang]
> 
> Hi Cong!
> 
> In commit d949d826c09fb ("ipv6: Add generic UDP Tunnel segmentation") you
> patched ip6_offload.c:
> 
> @@ -126,7 +128,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>                 ipv6h = ipv6_hdr(skb);
>                 ipv6h->payload_len = htons(skb->len - skb->mac_len -
>                                            sizeof(*ipv6h));
> -               if (proto == IPPROTO_UDP) {
> +               if (!tunnel && proto == IPPROTO_UDP) {
>                         unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
>                         fptr = (struct frag_hdr *)(skb_network_header(skb) +
>                                 unfrag_ip6hlen);
> 
> 
> I wonder about the !tunnel exception. This now seems to be a problem in sit
> ufo output path, where we don't update fragmentation offsets any more thus
> generating invalid frames.
> 
> I am not too firm with segmentation in case of tunnels but don't we need to
> always update the fragmentation offset no matter what, if upper gso callback
> produced more segments?

Not perfect nor clean (well, I don't know).

The idea is to have the segmentation at the first guessed tunnel
header cut. I don't know how to deal with stacked tunnels yet, I guess
we need to have a bit more state in the skb. Just to maybe keep the discussion
going...

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index ecd2c3f..3eefe03 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1297,7 +1297,11 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
 	/* Note : following gso_segment() might change skb->encapsulation */
-	udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
+	udpfrag = proto == IPPROTO_UDP;
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL|SKB_GSO_GRE))
+		udpfrag = udpfrag && !skb->encapsulation;
+	else if (skb->encapsulation)
+		udpfrag = udpfrag && encap;
 
 	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment))
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 1e8683b..d70c10b 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -89,7 +89,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	unsigned int unfrag_ip6hlen;
 	u8 *prevhdr;
 	int offset = 0;
-	bool tunnel;
+	bool encap, udpfrag;
 	int nhoff;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
@@ -110,8 +110,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
 		goto out;
 
-	tunnel = SKB_GSO_CB(skb)->encap_level > 0;
-	if (tunnel)
+	encap = SKB_GSO_CB(skb)->encap_level > 0;
+	if (encap)
 		features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	SKB_GSO_CB(skb)->encap_level += sizeof(*ipv6h);
 
@@ -121,6 +121,12 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 
+	udpfrag = proto == IPPROTO_UDP;
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL|SKB_GSO_GRE))
+		udpfrag = udpfrag && !skb->encapsulation;
+	else if (skb->encapsulation)
+		udpfrag = udpfrag && encap;
+
 	ops = rcu_dereference(inet6_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment)) {
 		skb_reset_transport_header(skb);
@@ -133,13 +139,9 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
 		ipv6h->payload_len = htons(skb->len - nhoff - sizeof(*ipv6h));
-		if (tunnel) {
-			skb_reset_inner_headers(skb);
-			skb->encapsulation = 1;
-		}
 		skb->network_header = (u8 *)ipv6h - skb->head;
 
-		if (!tunnel && proto == IPPROTO_UDP) {
+		if (udpfrag) {
 			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
 			fptr = (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
 			fptr->frag_off = htons(offset);
@@ -148,6 +150,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 			offset += (ntohs(ipv6h->payload_len) -
 				   sizeof(struct frag_hdr));
 		}
+		if (encap)
+			skb_reset_inner_headers(skb);
 	}
 
 out:
