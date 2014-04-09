From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2] net: core: don't account for udp header size when computing seglen
Date: Wed,  9 Apr 2014 10:28:50 +0200
Message-ID: <1397032130-2271-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52336 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932187AbaDIIdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 04:33:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of tcp, gso_size contains the tcpmss.

For UFO (udp fragmentation offloading) skbs, gso_size is the fragment
payload size, i.e. we must not account for udp header size.

Otherwise, when using virtio drivers, a to-be-forwarded UFO GSO packet
will be needlessly fragmented in the forward path, because we think its
individual segments are too large for the outgoing link.

Fixes: fe6cc55f3a9a053 ("net: ip, ipv6: handle gso skbs in forwarding path")
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Tobias Brunner <tobias@strongswan.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 changes since v1:
  - update 'Fixes:' tag.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 30c7d35..57e225c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3937,12 +3937,14 @@ EXPORT_SYMBOL_GPL(skb_scrub_packet);
 unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
 {
 	const struct skb_shared_info *shinfo = skb_shinfo(skb);
-	unsigned int hdr_len;
 
 	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
-		hdr_len = tcp_hdrlen(skb);
-	else
-		hdr_len = sizeof(struct udphdr);
-	return hdr_len + shinfo->gso_size;
+		return tcp_hdrlen(skb) + shinfo->gso_size;
+
+	/* UFO sets gso_size to the size of the fragmentation
+	 * payload, i.e. the size of the L4 (UDP) header is already
+	 * accounted for.
+	 */
+	return shinfo->gso_size;
 }
 EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
-- 
1.8.1.5
