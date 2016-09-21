From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 2/6] net/faraday: Make EDO{R,T}R bits configurable
Date: Thu, 22 Sep 2016 08:34:59 +0930
Message-ID: <20160921230503.23309-3-joel@jms.id.au>
References: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, Andrew Jeffery <andrew@aj.id.au>,
        gwshan@linux.vnet.ibm.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34397 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933364AbcIUXFh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:05:37 -0400
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Jeffery <andrew@aj.id.au>

These bits are #defined at a fixed location. In order to support future
hardware that has chosen to move these bits around move the bits into a
member of the struct ftgmac100.

Signed-off-by: Andrew Jeffery <andrew@aj.id.au>
Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 40 +++++++++++++++++++++-----------
 drivers/net/ethernet/faraday/ftgmac100.h |  2 --
 2 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 40622567159a..62a88d1a1f99 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -79,6 +79,9 @@ struct ftgmac100 {
 	int int_mask_all;
 	bool use_ncsi;
 	bool enabled;
+
+	u32 rxdes0_edorr_mask;
+	u32 txdes0_edotr_mask;
 };
 
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
@@ -259,10 +262,11 @@ static bool ftgmac100_rxdes_packet_ready(struct ftgmac100_rxdes *rxdes)
 	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY);
 }
 
-static void ftgmac100_rxdes_set_dma_own(struct ftgmac100_rxdes *rxdes)
+static void ftgmac100_rxdes_set_dma_own(const struct ftgmac100 *priv,
+					struct ftgmac100_rxdes *rxdes)
 {
 	/* clear status bits */
-	rxdes->rxdes0 &= cpu_to_le32(FTGMAC100_RXDES0_EDORR);
+	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
 }
 
 static bool ftgmac100_rxdes_rx_error(struct ftgmac100_rxdes *rxdes)
@@ -300,9 +304,10 @@ static bool ftgmac100_rxdes_multicast(struct ftgmac100_rxdes *rxdes)
 	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_MULTICAST);
 }
 
-static void ftgmac100_rxdes_set_end_of_ring(struct ftgmac100_rxdes *rxdes)
+static void ftgmac100_rxdes_set_end_of_ring(const struct ftgmac100 *priv,
+					    struct ftgmac100_rxdes *rxdes)
 {
-	rxdes->rxdes0 |= cpu_to_le32(FTGMAC100_RXDES0_EDORR);
+	rxdes->rxdes0 |= cpu_to_le32(priv->rxdes0_edorr_mask);
 }
 
 static void ftgmac100_rxdes_set_dma_addr(struct ftgmac100_rxdes *rxdes,
@@ -393,7 +398,7 @@ ftgmac100_rx_locate_first_segment(struct ftgmac100 *priv)
 		if (ftgmac100_rxdes_first_segment(rxdes))
 			return rxdes;
 
-		ftgmac100_rxdes_set_dma_own(rxdes);
+		ftgmac100_rxdes_set_dma_own(priv, rxdes);
 		ftgmac100_rx_pointer_advance(priv);
 		rxdes = ftgmac100_current_rxdes(priv);
 	}
@@ -464,7 +469,7 @@ static void ftgmac100_rx_drop_packet(struct ftgmac100 *priv)
 		if (ftgmac100_rxdes_last_segment(rxdes))
 			done = true;
 
-		ftgmac100_rxdes_set_dma_own(rxdes);
+		ftgmac100_rxdes_set_dma_own(priv, rxdes);
 		ftgmac100_rx_pointer_advance(priv);
 		rxdes = ftgmac100_current_rxdes(priv);
 	} while (!done && ftgmac100_rxdes_packet_ready(rxdes));
@@ -556,10 +561,11 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 /******************************************************************************
  * internal functions (transmit descriptor)
  *****************************************************************************/
-static void ftgmac100_txdes_reset(struct ftgmac100_txdes *txdes)
+static void ftgmac100_txdes_reset(const struct ftgmac100 *priv,
+				  struct ftgmac100_txdes *txdes)
 {
 	/* clear all except end of ring bit */
-	txdes->txdes0 &= cpu_to_le32(FTGMAC100_TXDES0_EDOTR);
+	txdes->txdes0 &= cpu_to_le32(priv->txdes0_edotr_mask);
 	txdes->txdes1 = 0;
 	txdes->txdes2 = 0;
 	txdes->txdes3 = 0;
@@ -580,9 +586,10 @@ static void ftgmac100_txdes_set_dma_own(struct ftgmac100_txdes *txdes)
 	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
 }
 
-static void ftgmac100_txdes_set_end_of_ring(struct ftgmac100_txdes *txdes)
+static void ftgmac100_txdes_set_end_of_ring(const struct ftgmac100 *priv,
+					    struct ftgmac100_txdes *txdes)
 {
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_EDOTR);
+	txdes->txdes0 |= cpu_to_le32(priv->txdes0_edotr_mask);
 }
 
 static void ftgmac100_txdes_set_first_segment(struct ftgmac100_txdes *txdes)
@@ -701,7 +708,7 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 
 	dev_kfree_skb(skb);
 
-	ftgmac100_txdes_reset(txdes);
+	ftgmac100_txdes_reset(priv, txdes);
 
 	ftgmac100_tx_clean_pointer_advance(priv);
 
@@ -792,7 +799,7 @@ static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 
 	ftgmac100_rxdes_set_page(priv, rxdes, page);
 	ftgmac100_rxdes_set_dma_addr(rxdes, map);
-	ftgmac100_rxdes_set_dma_own(rxdes);
+	ftgmac100_rxdes_set_dma_own(priv, rxdes);
 	return 0;
 }
 
@@ -839,7 +846,8 @@ static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
 		return -ENOMEM;
 
 	/* initialize RX ring */
-	ftgmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
+	ftgmac100_rxdes_set_end_of_ring(priv,
+					&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
 
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
@@ -849,7 +857,8 @@ static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
 	}
 
 	/* initialize TX ring */
-	ftgmac100_txdes_set_end_of_ring(&priv->descs->txdes[TX_QUEUE_ENTRIES - 1]);
+	ftgmac100_txdes_set_end_of_ring(priv,
+					&priv->descs->txdes[TX_QUEUE_ENTRIES - 1]);
 	return 0;
 
 err:
@@ -1336,6 +1345,9 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	priv->netdev = netdev;
 	priv->dev = &pdev->dev;
 
+	priv->rxdes0_edorr_mask = BIT(15);
+	priv->txdes0_edotr_mask = BIT(15);
+
 	spin_lock_init(&priv->tx_lock);
 
 	/* initialize NAPI */
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index 13408d448b05..c258586ce4a4 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -189,7 +189,6 @@ struct ftgmac100_txdes {
 } __attribute__ ((aligned(16)));
 
 #define FTGMAC100_TXDES0_TXBUF_SIZE(x)	((x) & 0x3fff)
-#define FTGMAC100_TXDES0_EDOTR		(1 << 15)
 #define FTGMAC100_TXDES0_CRC_ERR	(1 << 19)
 #define FTGMAC100_TXDES0_LTS		(1 << 28)
 #define FTGMAC100_TXDES0_FTS		(1 << 29)
@@ -215,7 +214,6 @@ struct ftgmac100_rxdes {
 } __attribute__ ((aligned(16)));
 
 #define FTGMAC100_RXDES0_VDBC		0x3fff
-#define FTGMAC100_RXDES0_EDORR		(1 << 15)
 #define FTGMAC100_RXDES0_MULTICAST	(1 << 16)
 #define FTGMAC100_RXDES0_BROADCAST	(1 << 17)
 #define FTGMAC100_RXDES0_RX_ERR		(1 << 18)
-- 
2.9.3
