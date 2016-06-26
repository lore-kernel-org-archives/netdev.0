From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH net 4/5] batman-adv: Fix ICMP RR ethernet access after skb_linearize
Date: Sun, 26 Jun 2016 11:16:12 +0200
Message-ID: <1466932573-23105-4-git-send-email-sven@narfation.org>
References: <10049349.EHEiaYmtBd@sven-edge>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40204 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbcFZJQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2016 05:16:33 -0400
In-Reply-To: <10049349.EHEiaYmtBd@sven-edge>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_linearize may reallocate the skb. This makes the calculated pointer
for ethhdr invalid. But it the pointer is used later to fill in the RR
field of the batadv_icmp_packet_rr packet.

Instead re-evaluate eth_hdr after the skb_linearize+skb_cow to fix the
pointer and avoid the invalid read.

Fixes: da6b8c20a5b8 ("batman-adv: generalize batman-adv icmp packet handling")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/routing.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e3857ed..6c2901a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -374,6 +374,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 		if (skb_cow(skb, ETH_HLEN) < 0)
 			goto out;
 
+		ethhdr = eth_hdr(skb);
 		icmph = (struct batadv_icmp_header *)skb->data;
 		icmp_packet_rr = (struct batadv_icmp_packet_rr *)icmph;
 		if (icmp_packet_rr->rr_cur >= BATADV_RR_LEN)
-- 
2.8.1
