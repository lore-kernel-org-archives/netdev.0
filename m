From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 3/4] net: core: handle encapsulation offloads when computing segment lengths
Date: Sun, 19 Oct 2014 22:42:20 +0200
Message-ID: <1413751340-19621-4-git-send-email-fw@strlen.de>
References: <1413751340-19621-1-git-send-email-fw@strlen.de>
Cc: edumazet@google.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41338 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751956AbaJSUmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 16:42:40 -0400
In-Reply-To: <1413751340-19621-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if ->encapsulation is set we have to use inner_tcp_hdrlen and add the
size of the inner network headers too.

This is 'mostly harmless'; tbf might send skb that is slightly over
quota or drop skb even if it would have fit.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/skbuff.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7b3df0d..eb4b48b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4059,15 +4059,22 @@ EXPORT_SYMBOL_GPL(skb_scrub_packet);
 unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
 {
 	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+	unsigned int thlen = 0;
 
-	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
-		return tcp_hdrlen(skb) + shinfo->gso_size;
+	if (skb->encapsulation) {
+		thlen = skb_inner_transport_header(skb) -
+			skb_transport_header(skb);
 
+		if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
+			thlen += inner_tcp_hdrlen(skb);
+	} else if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))) {
+		thlen = tcp_hdrlen(skb);
+	}
 	/* UFO sets gso_size to the size of the fragmentation
 	 * payload, i.e. the size of the L4 (UDP) header is already
 	 * accounted for.
 	 */
-	return shinfo->gso_size;
+	return thlen + shinfo->gso_size;
 }
 EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
 
-- 
2.0.4
