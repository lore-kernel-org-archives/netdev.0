From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Tue, 5 Nov 2013 02:41:27 +0100
Message-ID: <20131105014127.GG8832@order.stressinduktion.org>
References: <4BC5337E23A5EE4A96D91D9DABA8FAE55E440B568D@WP40068.corp.ads> <20131103033207.GF30284@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Saran Neti <Saran.Neti@telus.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pshelar@nicira.com,
	dl TSL Vulnerability Research Team
	<tsl-vulnerability-research@telus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49775 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab3KEBl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 20:41:28 -0500
Content-Disposition: inline
In-Reply-To: <20131103033207.GF30284@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1e2bd517c108816220f262d7954b697af03b5f9c ("udp6: Fix udp
fragmentation for tunnel traffic.") changed the calculation if
there is enough space to include a fragment header in the skb from a
skb->mac_header dervived one to skb_headroom. Because we already peeled
off the skb to transport_header this is wrong. Change this back to check
if we have enough room before the mac_header.

This fixes a panic Saran Neti reported. He used the tbf scheduler which
skb_gso_segments the skb. The offsets get negative and we panic in memcpy
because the skb was erroneously not expanded at the head.

Reported-by: Saran Neti <Saran.Neti@telus.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/udp_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 08e23b0..e7359f9 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -90,7 +90,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 
 		/* Check if there is enough headroom to insert fragment header. */
 		tnl_hlen = skb_tnl_header_len(skb);
-		if (skb_headroom(skb) < (tnl_hlen + frag_hdr_sz)) {
+		if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
 			if (gso_pskb_expand_head(skb, tnl_hlen + frag_hdr_sz))
 				goto out;
 		}
-- 
1.8.3.1
