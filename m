From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: reuse ip6_frag_id from ip6_ufo_append_data
Date: Fri, 21 Feb 2014 02:55:35 +0100
Message-ID: <20140221015535.GB28822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42403 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670AbaBUBzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 20:55:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we generate a new fragmentation id on UFO segmentation. It
is pretty hairy to identify the correct net namespace and dst there.
Especially tunnels use IFF_XMIT_DST_RELEASE and thus have no skb_dst
available at all.

This causes unreliable or very predictable ipv6 fragmentation id
generation while segmentation.

Luckily we already have pregenerated the ip6_frag_id in
ip6_ufo_append_data and can use it here.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/udp_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index e7359f9..b261ee8 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -113,7 +113,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
 		fptr->nexthdr = nexthdr;
 		fptr->reserved = 0;
-		ipv6_select_ident(fptr, (struct rt6_info *)skb_dst(skb));
+		fptr->identification = skb_shinfo(skb)->ip6_frag_id;
 
 		/* Fragment the skb. ipv6 header and the remaining fields of the
 		 * fragment header are updated in ipv6_gso_segment()
-- 
1.8.5.3
