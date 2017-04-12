From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 09/10] ftgmac100: Make ring sizes configurable via ethtool
Date: Wed, 12 Apr 2017 13:27:09 +1000
Message-ID: <20170412032710.17546-10-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41880 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752803AbdDLD15 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:57 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We set an arbitrary max at 1024 since we pre-allocate the actual
descriptor arrays and skb arrays to the full size to keep the
code a bit simpler and avoid allocation failures in the reset
task.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 204 ++++++++++++++++++++++---------
 1 file changed, 148 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 96153f8..0b92bde 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -38,8 +38,15 @@
 #define DRV_NAME	"ftgmac100"
 #define DRV_VERSION	"0.7"
 
-#define RX_QUEUE_ENTRIES	256	/* must be power of 2 */
-#define TX_QUEUE_ENTRIES	512	/* must be power of 2 */
+/* Arbitrary values, I am not sure the HW has limits */
+#define MAX_RX_QUEUE_ENTRIES	1024
+#define MAX_TX_QUEUE_ENTRIES	1024
+#define MIN_RX_QUEUE_ENTRIES	32
+#define MIN_TX_QUEUE_ENTRIES	32
+
+/* Defaults */
+#define DEF_RX_QUEUE_ENTRIES	256
+#define DEF_TX_QUEUE_ENTRIES	512
 
 #define MAX_PKT_SIZE		1536
 #define RX_BUF_SIZE		MAX_PKT_SIZE	/* must be smaller than 0x3fff */
@@ -47,30 +54,32 @@
 /* Min number of tx ring entries before stopping queue */
 #define TX_THRESHOLD		(MAX_SKB_FRAGS + 1)
 
-struct ftgmac100_descs {
-	struct ftgmac100_rxdes rxdes[RX_QUEUE_ENTRIES];
-	struct ftgmac100_txdes txdes[TX_QUEUE_ENTRIES];
-};
-
 struct ftgmac100 {
 	/* Registers */
 	struct resource *res;
 	void __iomem *base;
 
-	struct ftgmac100_descs *descs;
-	dma_addr_t descs_dma_addr;
-
 	/* Rx ring */
-	struct sk_buff *rx_skbs[RX_QUEUE_ENTRIES];
+	unsigned int rx_q_entries;
+	struct ftgmac100_rxdes *rxdes;
+	dma_addr_t rxdes_dma;
+	struct sk_buff **rx_skbs;
 	unsigned int rx_pointer;
 	u32 rxdes0_edorr_mask;
 
 	/* Tx ring */
-	struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];
+	unsigned int tx_q_entries;
+	struct ftgmac100_txdes *txdes;
+	dma_addr_t txdes_dma;
+	struct sk_buff **tx_skbs;
 	unsigned int tx_clean_pointer;
 	unsigned int tx_pointer;
 	u32 txdes0_edotr_mask;
 
+	/* Used to signal the reset task of ring change request */
+	unsigned int new_rx_q_entries;
+	unsigned int new_tx_q_entries;
+
 	/* Scratch page to use when rx skb alloc fails */
 	void *rx_scratch;
 	dma_addr_t rx_scratch_dma;
@@ -217,14 +226,10 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 	iowrite32(reg, priv->base + FTGMAC100_OFFSET_ISR);
 
 	/* Setup RX ring buffer base */
-	iowrite32(priv->descs_dma_addr +
-		  offsetof(struct ftgmac100_descs, rxdes),
-		  priv->base + FTGMAC100_OFFSET_RXR_BADR);
+	iowrite32(priv->rxdes_dma, priv->base + FTGMAC100_OFFSET_RXR_BADR);
 
 	/* Setup TX ring buffer base */
-	iowrite32(priv->descs_dma_addr +
-		  offsetof(struct ftgmac100_descs, txdes),
-		  priv->base + FTGMAC100_OFFSET_NPTXR_BADR);
+	iowrite32(priv->txdes_dma, priv->base + FTGMAC100_OFFSET_NPTXR_BADR);
 
 	/* Configure RX buffer size */
 	iowrite32(FTGMAC100_RBSR_SIZE(RX_BUF_SIZE),
@@ -337,7 +342,7 @@ static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 	dma_wmb();
 
 	/* Clean status (which resets own bit) */
-	if (entry == (RX_QUEUE_ENTRIES - 1))
+	if (entry == (priv->rx_q_entries - 1))
 		rxdes->rxdes0 = cpu_to_le32(priv->rxdes0_edorr_mask);
 	else
 		rxdes->rxdes0 = 0;
@@ -345,9 +350,10 @@ static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 	return 0;
 }
 
-static int ftgmac100_next_rx_pointer(int pointer)
+static unsigned int ftgmac100_next_rx_pointer(struct ftgmac100 *priv,
+					      unsigned int pointer)
 {
-	return (pointer + 1) & (RX_QUEUE_ENTRIES - 1);
+	return (pointer + 1) & (priv->rx_q_entries - 1);
 }
 
 static void ftgmac100_rx_packet_error(struct ftgmac100 *priv, u32 status)
@@ -377,7 +383,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
 	/* Grab next RX descriptor */
 	pointer = priv->rx_pointer;
-	rxdes = &priv->descs->rxdes[pointer];
+	rxdes = &priv->rxdes[pointer];
 
 	/* Grab descriptor status */
 	status = le32_to_cpu(rxdes->rxdes0);
@@ -465,7 +471,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
 	/* Resplenish rx ring */
 	ftgmac100_alloc_rx_buf(priv, pointer, rxdes, GFP_ATOMIC);
-	priv->rx_pointer = ftgmac100_next_rx_pointer(pointer);
+	priv->rx_pointer = ftgmac100_next_rx_pointer(priv, pointer);
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
@@ -484,7 +490,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
  drop:
 	/* Clean rxdes0 (which resets own bit) */
 	rxdes->rxdes0 = cpu_to_le32(status & priv->rxdes0_edorr_mask);
-	priv->rx_pointer = ftgmac100_next_rx_pointer(pointer);
+	priv->rx_pointer = ftgmac100_next_rx_pointer(priv, pointer);
 	netdev->stats.rx_dropped++;
 	return true;
 }
@@ -492,15 +498,16 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 static u32 ftgmac100_base_tx_ctlstat(struct ftgmac100 *priv,
 				     unsigned int index)
 {
-	if (index == (TX_QUEUE_ENTRIES - 1))
+	if (index == (priv->tx_q_entries - 1))
 		return priv->txdes0_edotr_mask;
 	else
 		return 0;
 }
 
-static int ftgmac100_next_tx_pointer(int pointer)
+static unsigned int ftgmac100_next_tx_pointer(struct ftgmac100 *priv,
+					      unsigned int pointer)
 {
-	return (pointer + 1) & (TX_QUEUE_ENTRIES - 1);
+	return (pointer + 1) & (priv->tx_q_entries - 1);
 }
 
 static u32 ftgmac100_tx_buf_avail(struct ftgmac100 *priv)
@@ -512,7 +519,7 @@ static u32 ftgmac100_tx_buf_avail(struct ftgmac100 *priv)
 	 * test for ftgmac100_tx_buf_cleanable() below
 	 */
 	return (priv->tx_clean_pointer - priv->tx_pointer - 1) &
-		(TX_QUEUE_ENTRIES - 1);
+		(priv->tx_q_entries - 1);
 }
 
 static bool ftgmac100_tx_buf_cleanable(struct ftgmac100 *priv)
@@ -552,7 +559,7 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 	u32 ctl_stat;
 
 	pointer = priv->tx_clean_pointer;
-	txdes = &priv->descs->txdes[pointer];
+	txdes = &priv->txdes[pointer];
 
 	ctl_stat = le32_to_cpu(txdes->txdes0);
 	if (ctl_stat & FTGMAC100_TXDES0_TXDMA_OWN)
@@ -564,7 +571,7 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 	ftgmac100_free_tx_packet(priv, pointer, skb, txdes, ctl_stat);
 	txdes->txdes0 = cpu_to_le32(ctl_stat & priv->txdes0_edotr_mask);
 
-	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(pointer);
+	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(priv, pointer);
 
 	return true;
 }
@@ -653,7 +660,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 
 	/* Grab the next free tx descriptor */
 	pointer = priv->tx_pointer;
-	txdes = first = &priv->descs->txdes[pointer];
+	txdes = first = &priv->txdes[pointer];
 
 	/* Setup it up with the packet head. Don't write the head to the
 	 * ring just yet
@@ -675,7 +682,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	txdes->txdes1 = cpu_to_le32(csum_vlan);
 
 	/* Next descriptor */
-	pointer = ftgmac100_next_tx_pointer(pointer);
+	pointer = ftgmac100_next_tx_pointer(priv, pointer);
 
 	/* Add the fragments */
 	for (i = 0; i < nfrags; i++) {
@@ -691,7 +698,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 
 		/* Setup descriptor */
 		priv->tx_skbs[pointer] = skb;
-		txdes = &priv->descs->txdes[pointer];
+		txdes = &priv->txdes[pointer];
 		ctl_stat = ftgmac100_base_tx_ctlstat(priv, pointer);
 		ctl_stat |= FTGMAC100_TXDES0_TXDMA_OWN;
 		ctl_stat |= FTGMAC100_TXDES0_TXBUF_SIZE(len);
@@ -702,7 +709,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		txdes->txdes3 = cpu_to_le32(map);
 
 		/* Next one */
-		pointer = ftgmac100_next_tx_pointer(pointer);
+		pointer = ftgmac100_next_tx_pointer(priv, pointer);
 	}
 
 	/* Order the previous packet and descriptor udpates
@@ -742,8 +749,8 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 
 	/* Then all fragments */
 	for (j = 0; j < i; j++) {
-		pointer = ftgmac100_next_tx_pointer(pointer);
-		txdes = &priv->descs->txdes[pointer];
+		pointer = ftgmac100_next_tx_pointer(priv, pointer);
+		txdes = &priv->txdes[pointer];
 		ctl_stat = le32_to_cpu(txdes->txdes0);
 		ftgmac100_free_tx_packet(priv, pointer, skb, txdes, ctl_stat);
 		txdes->txdes0 = cpu_to_le32(ctl_stat & priv->txdes0_edotr_mask);
@@ -766,8 +773,8 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 	int i;
 
 	/* Free all RX buffers */
-	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
+	for (i = 0; i < priv->rx_q_entries; i++) {
+		struct ftgmac100_rxdes *rxdes = &priv->rxdes[i];
 		struct sk_buff *skb = priv->rx_skbs[i];
 		dma_addr_t map = le32_to_cpu(rxdes->rxdes3);
 
@@ -780,8 +787,8 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 	}
 
 	/* Free all TX buffers */
-	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_txdes *txdes = &priv->descs->txdes[i];
+	for (i = 0; i < priv->tx_q_entries; i++) {
+		struct ftgmac100_txdes *txdes = &priv->txdes[i];
 		struct sk_buff *skb = priv->tx_skbs[i];
 
 		if (!skb)
@@ -793,10 +800,22 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 
 static void ftgmac100_free_rings(struct ftgmac100 *priv)
 {
+	/* Free skb arrays */
+	kfree(priv->rx_skbs);
+	kfree(priv->tx_skbs);
+
 	/* Free descriptors */
-	if (priv->descs)
-		dma_free_coherent(priv->dev, sizeof(struct ftgmac100_descs),
-				  priv->descs, priv->descs_dma_addr);
+	if (priv->rxdes)
+		dma_free_coherent(priv->dev, MAX_RX_QUEUE_ENTRIES *
+				  sizeof(struct ftgmac100_rxdes),
+				  priv->rxdes, priv->rxdes_dma);
+	priv->rxdes = NULL;
+
+	if (priv->txdes)
+		dma_free_coherent(priv->dev, MAX_TX_QUEUE_ENTRIES *
+				  sizeof(struct ftgmac100_txdes),
+				  priv->txdes, priv->txdes_dma);
+	priv->txdes = NULL;
 
 	/* Free scratch packet buffer */
 	if (priv->rx_scratch)
@@ -806,11 +825,28 @@ static void ftgmac100_free_rings(struct ftgmac100 *priv)
 
 static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
 {
+	/* Allocate skb arrays */
+	priv->rx_skbs = kcalloc(MAX_RX_QUEUE_ENTRIES, sizeof(void *),
+				GFP_KERNEL);
+	if (!priv->rx_skbs)
+		return -ENOMEM;
+	priv->tx_skbs = kcalloc(MAX_TX_QUEUE_ENTRIES, sizeof(void *),
+				GFP_KERNEL);
+	if (!priv->tx_skbs)
+		return -ENOMEM;
+
 	/* Allocate descriptors */
-	priv->descs = dma_zalloc_coherent(priv->dev,
-					  sizeof(struct ftgmac100_descs),
-					  &priv->descs_dma_addr, GFP_KERNEL);
-	if (!priv->descs)
+	priv->rxdes = dma_zalloc_coherent(priv->dev,
+					  MAX_RX_QUEUE_ENTRIES *
+					  sizeof(struct ftgmac100_rxdes),
+					  &priv->rxdes_dma, GFP_KERNEL);
+	if (!priv->rxdes)
+		return -ENOMEM;
+	priv->txdes = dma_zalloc_coherent(priv->dev,
+					  MAX_TX_QUEUE_ENTRIES *
+					  sizeof(struct ftgmac100_txdes),
+					  &priv->txdes_dma, GFP_KERNEL);
+	if (!priv->txdes)
 		return -ENOMEM;
 
 	/* Allocate scratch packet buffer */
@@ -826,22 +862,32 @@ static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
 
 static void ftgmac100_init_rings(struct ftgmac100 *priv)
 {
-	struct ftgmac100_rxdes *rxdes;
-	struct ftgmac100_txdes *txdes;
+	struct ftgmac100_rxdes *rxdes = NULL;
+	struct ftgmac100_txdes *txdes = NULL;
 	int i;
 
+	/* Update entries counts */
+	priv->rx_q_entries = priv->new_rx_q_entries;
+	priv->tx_q_entries = priv->new_tx_q_entries;
+
+	if (WARN_ON(priv->rx_q_entries < MIN_RX_QUEUE_ENTRIES))
+		return;
+
 	/* Initialize RX ring */
-	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
-		rxdes = &priv->descs->rxdes[i];
+	for (i = 0; i < priv->rx_q_entries; i++) {
+		rxdes = &priv->rxdes[i];
 		rxdes->rxdes0 = 0;
 		rxdes->rxdes3 = cpu_to_le32(priv->rx_scratch_dma);
 	}
 	/* Mark the end of the ring */
 	rxdes->rxdes0 |= cpu_to_le32(priv->rxdes0_edorr_mask);
 
+	if (WARN_ON(priv->tx_q_entries < MIN_RX_QUEUE_ENTRIES))
+		return;
+
 	/* Initialize TX ring */
-	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
-		txdes = &priv->descs->txdes[i];
+	for (i = 0; i < priv->tx_q_entries; i++) {
+		txdes = &priv->txdes[i];
 		txdes->txdes0 = 0;
 	}
 	txdes->txdes0 |= cpu_to_le32(priv->txdes0_edotr_mask);
@@ -851,8 +897,8 @@ static int ftgmac100_alloc_rx_buffers(struct ftgmac100 *priv)
 {
 	int i;
 
-	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
+	for (i = 0; i < priv->rx_q_entries; i++) {
+		struct ftgmac100_rxdes *rxdes = &priv->rxdes[i];
 
 		if (ftgmac100_alloc_rx_buf(priv, i, rxdes, GFP_KERNEL))
 			return -ENOMEM;
@@ -997,11 +1043,53 @@ static void ftgmac100_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
 }
 
+static int ftgmac100_nway_reset(struct net_device *ndev)
+{
+	if (!ndev->phydev)
+		return -ENXIO;
+	return phy_start_aneg(ndev->phydev);
+}
+
+static void ftgmac100_get_ringparam(struct net_device *netdev,
+				    struct ethtool_ringparam *ering)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	memset(ering, 0, sizeof(*ering));
+	ering->rx_max_pending = MAX_RX_QUEUE_ENTRIES;
+	ering->tx_max_pending = MAX_TX_QUEUE_ENTRIES;
+	ering->rx_pending = priv->rx_q_entries;
+	ering->tx_pending = priv->tx_q_entries;
+}
+
+static int ftgmac100_set_ringparam(struct net_device *netdev,
+				   struct ethtool_ringparam *ering)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	if (ering->rx_pending > MAX_RX_QUEUE_ENTRIES ||
+	    ering->tx_pending > MAX_TX_QUEUE_ENTRIES ||
+	    ering->rx_pending < MIN_RX_QUEUE_ENTRIES ||
+	    ering->tx_pending < MIN_TX_QUEUE_ENTRIES ||
+	    !is_power_of_2(ering->rx_pending) ||
+	    !is_power_of_2(ering->tx_pending))
+		return -EINVAL;
+
+	priv->new_rx_q_entries = ering->rx_pending;
+	priv->new_tx_q_entries = ering->tx_pending;
+	if (netif_running(netdev))
+		schedule_work(&priv->reset_task);
+
+	return 0;
+}
+
 static const struct ethtool_ops ftgmac100_ethtool_ops = {
 	.get_drvinfo		= ftgmac100_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
+	.get_ringparam		= ftgmac100_get_ringparam,
+	.set_ringparam		= ftgmac100_set_ringparam,
 };
 
 static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
@@ -1057,7 +1145,7 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 
 static bool ftgmac100_check_rx(struct ftgmac100 *priv)
 {
-	struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[priv->rx_pointer];
+	struct ftgmac100_rxdes *rxdes = &priv->rxdes[priv->rx_pointer];
 
 	/* Do we have a packet ? */
 	return !!(rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY));
@@ -1494,6 +1582,10 @@ static int ftgmac100_probe(struct platform_device *pdev)
 			goto err_setup_mdio;
 	}
 
+	/* Default ring sizes */
+	priv->rx_q_entries = priv->new_rx_q_entries = DEF_RX_QUEUE_ENTRIES;
+	priv->tx_q_entries = priv->new_tx_q_entries = DEF_TX_QUEUE_ENTRIES;
+
 	/* Base feature set */
 	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
 		NETIF_F_GRO | NETIF_F_SG;
-- 
2.9.3
