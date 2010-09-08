From: "Arce, Abraham" <x0066660@ti.com>
Subject: [PATCH] KS8851: Correct RX packet allocation
Date: Wed, 8 Sep 2010 18:26:55 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A530450AB386D@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
	"Ha, Tristram" <Tristram.Ha@micrel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:41960 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756679Ab0IHX1A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 19:27:00 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Use netdev_alloc_skb_ip_align() helper and do correct allocation

Tested-by: Abraham Arce <x0066660@ti.com>
Signed-off-by: Abraham Arce <x0066660@ti.com>
---
 drivers/net/ks8851.c |   39 +++++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b4fb07a..51919fc 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -503,30 +503,33 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 		ks8851_wrreg16(ks, KS_RXQCR,
 			       ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);
 
-		if (rxlen > 0) {
-			skb = netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
-			if (!skb) {
-				/* todo - dump frame and move on */
-			}
+		if (rxlen > 4) {
+			unsigned int rxalign;
+
+			rxlen -= 4;
+			rxalign = ALIGN(rxlen, 4);
+			skb = netdev_alloc_skb_ip_align(ks->netdev, rxalign);
+			if (skb) {
 
-			/* two bytes to ensure ip is aligned, and four bytes
-			 * for the status header and 4 bytes of garbage */
-			skb_reserve(skb, 2 + 4 + 4);
+				/* 4 bytes of status header + 4 bytes of
+				 * garbage: we put them before ethernet
+				 * header, so that they are copied,
+				 * but ignored.
+				 */
 
-			rxpkt = skb_put(skb, rxlen - 4) - 8;
+				rxpkt = skb_put(skb, rxlen) - 8;
 
-			/* align the packet length to 4 bytes, and add 4 bytes
-			 * as we're getting the rx status header as well */
-			ks8851_rdfifo(ks, rxpkt, ALIGN(rxlen, 4) + 8);
+				ks8851_rdfifo(ks, rxpkt, rxalign + 8);
 
-			if (netif_msg_pktdata(ks))
-				ks8851_dbg_dumpkkt(ks, rxpkt);
+				if (netif_msg_pktdata(ks))
+					ks8851_dbg_dumpkkt(ks, rxpkt);
 
-			skb->protocol = eth_type_trans(skb, ks->netdev);
-			netif_rx(skb);
+				skb->protocol = eth_type_trans(skb, ks->netdev);
+				netif_rx(skb);
 
-			ks->netdev->stats.rx_packets++;
-			ks->netdev->stats.rx_bytes += rxlen - 4;
+				ks->netdev->stats.rx_packets++;
+				ks->netdev->stats.rx_bytes += rxlen;
+			}
 		}
 
 		ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
-- 
1.5.4.3

