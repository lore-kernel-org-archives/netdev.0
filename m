From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 10/10] ftgmac100: Work around HW bug in runt frame detection
Date: Thu,  6 Apr 2017 11:02:52 +1000
Message-ID: <20170406010252.29208-11-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37954 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756520AbdDFBDu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:50 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HW incorrectly calculates the frame size without the vlan
tag and compares that against 64. It will thus flag 64-bytes
frames with a vlan tag as 60-bytes frames "runt" packets
which we'll then drop. Thus we end up dropping ARP packets
on vlan's ...

It does that whether vlan tag stripping is enabled or not.

This works around it by ignoring the "runt" error bit of the
frame has been vlan tagged and is at least 60 bytes.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 35 +++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index e42ef8f..9f18e5e 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -348,7 +348,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	struct ftgmac100_rxdes *rxdes;
 	struct sk_buff *skb;
 	unsigned int pointer, size;
-	u32 status;
+	u32 status, csum_vlan;
 	dma_addr_t map;
 
 	/* Grab next RX descriptor */
@@ -370,10 +370,27 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 		     !(status & FTGMAC100_RXDES0_LRS)))
 		goto drop;
 
+	/* Grab received size and csum vlan field in the descriptor */
+	size = status & FTGMAC100_RXDES0_VDBC;
+	csum_vlan = le32_to_cpu(rxdes->rxdes1);
+
 	/* Any error (other than csum offload) flagged ? */
 	if (unlikely(status & RXDES0_ANY_ERROR)) {
-		ftgmac100_rx_packet_error(priv, status);
-		goto drop;
+		/* Correct for incorrect flagging of runt packets
+		 * with vlan tags... Just accept a runt packet that
+		 * has been flagged as vlan and whose size is at
+		 * least 60 bytes.
+		 */
+		if ((status & FTGMAC100_RXDES0_RUNT) &&
+		    (csum_vlan & FTGMAC100_RXDES1_VLANTAG_AVAIL) &&
+		    (size >= 60))
+			status &= ~FTGMAC100_RXDES0_RUNT;
+
+		/* Any error still in there ? */
+		if (status & RXDES0_ANY_ERROR) {
+			ftgmac100_rx_packet_error(priv, status);
+			goto drop;
+		}
 	}
 
 	/* If the packet had no skb (failed to allocate earlier)
@@ -395,19 +412,17 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	 * we accept the HW test results.
 	 */
 	if (netdev->features & NETIF_F_RXCSUM) {
-		__le32 csum_vlan = rxdes->rxdes1;
-		__le32 err_bits = cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR |
-					      FTGMAC100_RXDES1_UDP_CHKSUM_ERR |
-					      FTGMAC100_RXDES1_IP_CHKSUM_ERR);
+		u32 err_bits = FTGMAC100_RXDES1_TCP_CHKSUM_ERR |
+			FTGMAC100_RXDES1_UDP_CHKSUM_ERR |
+			FTGMAC100_RXDES1_IP_CHKSUM_ERR;
 		if ((csum_vlan & err_bits) ||
-		    !(csum_vlan & cpu_to_le32(FTGMAC100_RXDES1_PROT_MASK)))
+		    !(csum_vlan & FTGMAC100_RXDES1_PROT_MASK))
 			skb->ip_summed = CHECKSUM_NONE;
 		else
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	/* Grab received size annd transfer to skb */
-	size = status & FTGMAC100_RXDES0_VDBC;
+	/* Transfer received size to skb */
 	skb_put(skb, size);
 
 	/* Tear down DMA mapping, do necessary cache management */
-- 
2.9.3
