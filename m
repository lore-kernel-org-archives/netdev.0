From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: bcmgenet: add support for ethtool rx-frames
Date: Mon, 21 Apr 2014 08:45:23 -0700
Message-ID: <1398095124-5411-4-git-send-email-f.fainelli@gmail.com>
References: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:65468 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaDUPqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 11:46:11 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so3797355pdj.4
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 08:46:10 -0700 (PDT)
In-Reply-To: <1398095124-5411-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the ethtool rx-frames coalescing parameter which allows
defining the number of RX interrupts per frames received. Make sure that
whenever the link speed changes, we also re-program a correct push timer
value.

We can no longer enable the BDONE/PDONE interrupts as those would
fire for each packet/buffer received, which would defeat the MBDONE
interrupt purpose. The MBDONE interrupt is guaranteed to correspond to a
PDONE/BDONE interrupt when the threshold is set to 1.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 44 ++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  3 ++
 3 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f1b3969de10b..4922958ec4aa 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -78,13 +78,10 @@
 #define GENET_RDMA_REG_OFF	(priv->hw_params->rdma_offset + \
 				TOTAL_DESC * DMA_DESC_SIZE)
 
-/* TX DMA done mask: multiple buffer done */
+/* RX/TX DMA done mask: multiple buffer done */
 #define UMAC_TXDMA_DONE_MASK	(UMAC_IRQ_TXDMA_MBDONE)
 
-/* Rx DMA done masks: packet, buffer and multiple buffer done */
-#define UMAC_RXDMA_DONE_MASK	(UMAC_IRQ_RXDMA_BDONE | \
-				 UMAC_IRQ_RXDMA_PDONE | \
-				 UMAC_IRQ_RXDMA_MBDONE)
+#define UMAC_RXDMA_DONE_MASK	(UMAC_IRQ_RXDMA_MBDONE)
 
 static inline void dmadesc_set_length_status(struct bcmgenet_priv *priv,
 						void __iomem *d, u32 value)
@@ -210,6 +207,7 @@ enum dma_reg {
 	DMA_ARB_CTRL,
 	DMA_PRIORITY,
 	DMA_RING_PRIORITY,
+	DMA_RING16_TIMEOUT,
 };
 
 static const u8 bcmgenet_dma_regs_v3plus[] = {
@@ -220,6 +218,7 @@ static const u8 bcmgenet_dma_regs_v3plus[] = {
 	[DMA_ARB_CTRL]		= 0x2C,
 	[DMA_PRIORITY]		= 0x30,
 	[DMA_RING_PRIORITY]	= 0x38,
+	[DMA_RING16_TIMEOUT]	= 0x6C,
 };
 
 static const u8 bcmgenet_dma_regs_v2[] = {
@@ -230,6 +229,7 @@ static const u8 bcmgenet_dma_regs_v2[] = {
 	[DMA_ARB_CTRL]		= 0x30,
 	[DMA_PRIORITY]		= 0x34,
 	[DMA_RING_PRIORITY]	= 0x3C,
+	[DMA_RING16_TIMEOUT]	= 0x6C,
 };
 
 static const u8 bcmgenet_dma_regs_v1[] = {
@@ -239,6 +239,7 @@ static const u8 bcmgenet_dma_regs_v1[] = {
 	[DMA_ARB_CTRL]		= 0x30,
 	[DMA_PRIORITY]		= 0x34,
 	[DMA_RING_PRIORITY]	= 0x3C,
+	[DMA_RING16_TIMEOUT]	= 0x6C,
 };
 
 /* Set at runtime once bcmgenet version is known */
@@ -501,17 +502,42 @@ static int bcmgenet_get_coalesce(struct net_device *dev,
 
 	ec->tx_max_coalesced_frames = bcmgenet_tdma_ring_readl(priv,
 			DESC_INDEX, DMA_MBUF_DONE_THRESH);
+	ec->rx_max_coalesced_frames = bcmgenet_rdma_ring_readl(priv,
+			DESC_INDEX, DMA_MBUF_DONE_THRESH);
 
 	return 0;
 }
 
+/* Update RX coalescing scheme based on the current link speed, caller
+ * must have updated the ring threshold before calling us.
+ */
+void bcmgenet_update_rx_coal(struct net_device *dev)
+{
+	unsigned int speeds[] = { SPEED_10, SPEED_100, SPEED_1000, SPEED_2500 };
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	u32 cur_speed;
+	u32 timeout;
+	u32 rx_coal;
+
+	rx_coal = bcmgenet_rdma_ring_readl(priv, DESC_INDEX,
+			DMA_MBUF_DONE_THRESH);
+
+	cur_speed = (bcmgenet_umac_readl(priv, UMAC_CMD) >> CMD_SPEED_SHIFT) &
+			CMD_SPEED_MASK;
+
+	timeout = 2 * (rx_coal * ENET_MAX_MTU_SIZE) / speeds[cur_speed];
+	bcmgenet_rdma_writel(priv, timeout, DMA_RING16_TIMEOUT);
+}
+
 static int bcmgenet_set_coalesce(struct net_device *dev,
 				 struct ethtool_coalesce *ec)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	unsigned int i;
 
-	if (ec->tx_max_coalesced_frames > 255)
+	if (ec->tx_max_coalesced_frames > 255 ||
+	    ec->rx_max_coalesced_frames < 1 ||
+	    ec->rx_max_coalesced_frames > 255)
 		return -EINVAL;
 
 	/* Program all TX queues with the same values, as there is no
@@ -523,6 +549,11 @@ static int bcmgenet_set_coalesce(struct net_device *dev,
 	bcmgenet_tdma_ring_writel(priv, DESC_INDEX,
 			ec->tx_max_coalesced_frames, DMA_MBUF_DONE_THRESH);
 
+	bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
+			ec->rx_max_coalesced_frames, DMA_MBUF_DONE_THRESH);
+
+	bcmgenet_update_rx_coal(dev);
+
 	return 0;
 }
 
@@ -1680,6 +1711,7 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 			(DMA_FC_THRESH_LO << DMA_XOFF_THRESHOLD_SHIFT) |
 			DMA_FC_THRESH_HI, RDMA_XON_XOFF_THRESH);
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_READ_PTR);
+	bcmgenet_rdma_ring_writel(priv, index, 1, DMA_MBUF_DONE_THRESH);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 0f117105fed1..e9c17dcbc9ab 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -624,5 +624,6 @@ int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_mii_reset(struct net_device *dev);
+void bcmgenet_update_rx_coal(struct net_device *dev);
 
 #endif /* __BCMGENET_H__ */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 4608673beaff..fd2f9ba70977 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -143,6 +143,9 @@ static void bcmgenet_mii_setup(struct net_device *dev)
 			       CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE);
 		reg |= cmd_bits;
 		bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+
+		/* Update coalescing scheme based on current speed */
+		bcmgenet_update_rx_coal(priv->dev);
 	}
 
 	if (status_changed)
-- 
1.9.1
