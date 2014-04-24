From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 1/4] Altera TSE: Work around unaligned DMA receive packet issue with Altera SGDMA
Date: Thu, 24 Apr 2014 16:58:08 -0500
Message-ID: <1398376691-15265-2-git-send-email-vbridgers2013@gmail.com>
References: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, Vince Bridgers <vbridger@altera.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:63885 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352AbaDXWCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:02:36 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so2043635pdj.32
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:02:35 -0700 (PDT)
In-Reply-To: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridger@altera.com>

This patch works around a recently discovered unaligned receive dma problem
with the Altera SGMDA. The Altera SGDMA component cannot be configured to
DMA data to unaligned addresses for receive packet operations from the
Triple Speed Ethernet component because of a potential data transfer
corruption that can occur. This patch addresses this issue by
utilizing the shift 16 bits feature of the Altera Triple Speed Ethernet
component and modifying the receive buffer physical addresses accordingly
such that the target receive DMA address is always aligned on a 32-bit
boundary.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
Tested-by: Matthew Gerlach <mgerlach@altera.com>
---
 drivers/net/ethernet/altera/altera_msgdma.c   |    7 +-
 drivers/net/ethernet/altera/altera_msgdma.h   |    3 +-
 drivers/net/ethernet/altera/altera_sgdma.c    |  105 ++++++++++++++++---------
 drivers/net/ethernet/altera/altera_sgdma.h    |    3 +-
 drivers/net/ethernet/altera/altera_tse.h      |    4 +-
 drivers/net/ethernet/altera/altera_tse_main.c |   30 ++++---
 6 files changed, 101 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/ethernet/altera/altera_msgdma.c
index 3df1866..219a8a1 100644
--- a/drivers/net/ethernet/altera/altera_msgdma.c
+++ b/drivers/net/ethernet/altera/altera_msgdma.c
@@ -29,6 +29,10 @@ void msgdma_uninitialize(struct altera_tse_private *priv)
 {
 }
 
+void msgdma_start_rxdma(struct altera_tse_private *priv)
+{
+}
+
 void msgdma_reset(struct altera_tse_private *priv)
 {
 	int counter;
@@ -154,7 +158,7 @@ u32 msgdma_tx_completions(struct altera_tse_private *priv)
 
 /* Put buffer to the mSGDMA RX FIFO
  */
-int msgdma_add_rx_desc(struct altera_tse_private *priv,
+void msgdma_add_rx_desc(struct altera_tse_private *priv,
 			struct tse_buffer *rxbuffer)
 {
 	struct msgdma_extended_desc *desc = priv->rx_dma_desc;
@@ -175,7 +179,6 @@ int msgdma_add_rx_desc(struct altera_tse_private *priv,
 	iowrite32(0, &desc->burst_seq_num);
 	iowrite32(0x00010001, &desc->stride);
 	iowrite32(control, &desc->control);
-	return 1;
 }
 
 /* status is returned on upper 16 bits,
diff --git a/drivers/net/ethernet/altera/altera_msgdma.h b/drivers/net/ethernet/altera/altera_msgdma.h
index 7f0f5bf..42cf61c 100644
--- a/drivers/net/ethernet/altera/altera_msgdma.h
+++ b/drivers/net/ethernet/altera/altera_msgdma.h
@@ -25,10 +25,11 @@ void msgdma_disable_txirq(struct altera_tse_private *);
 void msgdma_clear_rxirq(struct altera_tse_private *);
 void msgdma_clear_txirq(struct altera_tse_private *);
 u32 msgdma_tx_completions(struct altera_tse_private *);
-int msgdma_add_rx_desc(struct altera_tse_private *, struct tse_buffer *);
+void msgdma_add_rx_desc(struct altera_tse_private *, struct tse_buffer *);
 int msgdma_tx_buffer(struct altera_tse_private *, struct tse_buffer *);
 u32 msgdma_rx_status(struct altera_tse_private *);
 int msgdma_initialize(struct altera_tse_private *);
 void msgdma_uninitialize(struct altera_tse_private *);
+void msgdma_start_rxdma(struct altera_tse_private *);
 
 #endif /*  __ALTERA_MSGDMA_H__ */
diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index 0ee9663..4bcdd34 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -64,11 +64,15 @@ queue_rx_peekhead(struct altera_tse_private *priv);
 
 int sgdma_initialize(struct altera_tse_private *priv)
 {
-	priv->txctrlreg = SGDMA_CTRLREG_ILASTD;
+	priv->txctrlreg = SGDMA_CTRLREG_ILASTD |
+		      SGDMA_CTRLREG_INTEN;
 
 	priv->rxctrlreg = SGDMA_CTRLREG_IDESCRIP |
+		      SGDMA_CTRLREG_INTEN |
 		      SGDMA_CTRLREG_ILASTD;
 
+	priv->sgdmadesclen = sizeof(sgdma_descrip);
+
 	INIT_LIST_HEAD(&priv->txlisthd);
 	INIT_LIST_HEAD(&priv->rxlisthd);
 
@@ -93,6 +97,16 @@ int sgdma_initialize(struct altera_tse_private *priv)
 		return -EINVAL;
 	}
 
+	/* Initialize descriptor memory to all 0's, sync memory to cache */
+	memset(priv->tx_dma_desc, 0, priv->txdescmem);
+	memset(priv->rx_dma_desc, 0, priv->rxdescmem);
+
+	dma_sync_single_for_device(priv->device, priv->txdescphys,
+				   priv->txdescmem, DMA_TO_DEVICE);
+
+	dma_sync_single_for_device(priv->device, priv->rxdescphys,
+				   priv->rxdescmem, DMA_TO_DEVICE);
+
 	return 0;
 }
 
@@ -130,26 +144,23 @@ void sgdma_reset(struct altera_tse_private *priv)
 	iowrite32(0, &prxsgdma->control);
 }
 
+/* For SGDMA, interrupts remain enabled after initially enabling,
+ * so no need to provide implementations for abstract enable
+ * and disable
+ */
+
 void sgdma_enable_rxirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	priv->rxctrlreg |= SGDMA_CTRLREG_INTEN;
-	tse_set_bit(&csr->control, SGDMA_CTRLREG_INTEN);
 }
 
 void sgdma_enable_txirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
-	priv->txctrlreg |= SGDMA_CTRLREG_INTEN;
-	tse_set_bit(&csr->control, SGDMA_CTRLREG_INTEN);
 }
 
-/* for SGDMA, RX interrupts remain enabled after enabling */
 void sgdma_disable_rxirq(struct altera_tse_private *priv)
 {
 }
 
-/* for SGDMA, TX interrupts remain enabled after enabling */
 void sgdma_disable_txirq(struct altera_tse_private *priv)
 {
 }
@@ -219,11 +230,15 @@ u32 sgdma_tx_completions(struct altera_tse_private *priv)
 	return ready;
 }
 
-int sgdma_add_rx_desc(struct altera_tse_private *priv,
-		      struct tse_buffer *rxbuffer)
+void sgdma_start_rxdma(struct altera_tse_private *priv)
+{
+	sgdma_async_read(priv);
+}
+
+void sgdma_add_rx_desc(struct altera_tse_private *priv,
+		       struct tse_buffer *rxbuffer)
 {
 	queue_rx(priv, rxbuffer);
-	return sgdma_async_read(priv);
 }
 
 /* status is returned on upper 16 bits,
@@ -240,28 +255,52 @@ u32 sgdma_rx_status(struct altera_tse_private *priv)
 	unsigned int pktstatus = 0;
 	struct tse_buffer *rxbuffer = NULL;
 
-	dma_sync_single_for_cpu(priv->device,
-				priv->rxdescphys,
-				priv->rxdescmem,
-				DMA_BIDIRECTIONAL);
+	u32 sts = ioread32(&csr->status);
 
 	desc = &base[0];
-	if ((ioread32(&csr->status) & SGDMA_STSREG_EOP) ||
-	    (desc->status & SGDMA_STATUS_EOP)) {
+	if (sts & SGDMA_STSREG_EOP) {
+		dma_sync_single_for_cpu(priv->device,
+					priv->rxdescphys,
+					priv->sgdmadesclen,
+					DMA_FROM_DEVICE);
+
 		pktlength = desc->bytes_xferred;
 		pktstatus = desc->status & 0x3f;
 		rxstatus = pktstatus;
 		rxstatus = rxstatus << 16;
 		rxstatus |= (pktlength & 0xffff);
 
-		desc->status = 0;
+		if (rxstatus) {
+			desc->status = 0;
 
-		rxbuffer = dequeue_rx(priv);
-		if (rxbuffer == NULL)
-			netdev_err(priv->dev,
-				   "sgdma rx and rx queue empty!\n");
+			rxbuffer = dequeue_rx(priv);
+			if (rxbuffer == NULL)
+				netdev_info(priv->dev,
+					    "sgdma rx and rx queue empty!\n");
+
+			/* Clear control */
+			iowrite32(0, &csr->control);
+			/* clear status */
+			iowrite32(0xf, &csr->status);
 
-		/* kick the rx sgdma after reaping this descriptor */
+			/* kick the rx sgdma after reaping this descriptor */
+			pktsrx = sgdma_async_read(priv);
+
+		} else {
+			/* If the SGDMA indicated an end of packet on recv,
+			 * then it's expected that the rxstatus from the
+			 * descriptor is non-zero - meaning a valid packet
+			 * with a nonzero length, or an error has been
+			 * indicated. if not, then all we can do is signal
+			 * an error and return no packet received. Most likely
+			 * there is a system design error, or an error in the
+			 * underlying kernel (cache or cache management problem)
+			 */
+			netdev_err(priv->dev,
+				   "SGDMA RX Error Info: %x, %x, %x\n",
+				   sts, desc->status, rxstatus);
+		}
+	} else if (sts == 0) {
 		pktsrx = sgdma_async_read(priv);
 	}
 
@@ -319,13 +358,14 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 	struct sgdma_descrip *cdesc = &descbase[0];
 	struct sgdma_descrip *ndesc = &descbase[1];
 
-	unsigned int sts = ioread32(&csr->status);
 	struct tse_buffer *rxbuffer = NULL;
 
 	if (!sgdma_rxbusy(priv)) {
 		rxbuffer = queue_rx_peekhead(priv);
-		if (rxbuffer == NULL)
+		if (rxbuffer == NULL) {
+			netdev_err(priv->dev, "no rx buffers available\n");
 			return 0;
+		}
 
 		sgdma_descrip(cdesc,		/* current descriptor */
 			      ndesc,		/* next descriptor */
@@ -337,17 +377,10 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 			      0,		/* read fixed: NA for rx dma */
 			      0);		/* SOP: NA for rx DMA */
 
-		/* clear control and status */
-		iowrite32(0, &csr->control);
-
-		/* If status available, clear those bits */
-		if (sts & 0xf)
-			iowrite32(0xf, &csr->status);
-
 		dma_sync_single_for_device(priv->device,
 					   priv->rxdescphys,
-					   priv->rxdescmem,
-					   DMA_BIDIRECTIONAL);
+					   priv->sgdmadesclen,
+					   DMA_TO_DEVICE);
 
 		iowrite32(lower_32_bits(sgdma_rxphysaddr(priv, cdesc)),
 			  &csr->next_descrip);
@@ -374,7 +407,7 @@ static int sgdma_async_write(struct altera_tse_private *priv,
 	iowrite32(0x1f, &csr->status);
 
 	dma_sync_single_for_device(priv->device, priv->txdescphys,
-				   priv->txdescmem, DMA_TO_DEVICE);
+				   priv->sgdmadesclen, DMA_TO_DEVICE);
 
 	iowrite32(lower_32_bits(sgdma_txphysaddr(priv, desc)),
 		  &csr->next_descrip);
diff --git a/drivers/net/ethernet/altera/altera_sgdma.h b/drivers/net/ethernet/altera/altera_sgdma.h
index 07d4717..584977e 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.h
+++ b/drivers/net/ethernet/altera/altera_sgdma.h
@@ -26,10 +26,11 @@ void sgdma_clear_rxirq(struct altera_tse_private *);
 void sgdma_clear_txirq(struct altera_tse_private *);
 int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *);
 u32 sgdma_tx_completions(struct altera_tse_private *);
-int sgdma_add_rx_desc(struct altera_tse_private *priv, struct tse_buffer *);
+void sgdma_add_rx_desc(struct altera_tse_private *priv, struct tse_buffer *);
 void sgdma_status(struct altera_tse_private *);
 u32 sgdma_rx_status(struct altera_tse_private *);
 int sgdma_initialize(struct altera_tse_private *);
 void sgdma_uninitialize(struct altera_tse_private *);
+void sgdma_start_rxdma(struct altera_tse_private *);
 
 #endif /*  __ALTERA_SGDMA_H__ */
diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index 8feeed0..6059a09 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -390,10 +390,11 @@ struct altera_dmaops {
 	void (*clear_rxirq)(struct altera_tse_private *);
 	int (*tx_buffer)(struct altera_tse_private *, struct tse_buffer *);
 	u32 (*tx_completions)(struct altera_tse_private *);
-	int (*add_rx_desc)(struct altera_tse_private *, struct tse_buffer *);
+	void (*add_rx_desc)(struct altera_tse_private *, struct tse_buffer *);
 	u32 (*get_rx_status)(struct altera_tse_private *);
 	int (*init_dma)(struct altera_tse_private *);
 	void (*uninit_dma)(struct altera_tse_private *);
+	void (*start_rxdma)(struct altera_tse_private *);
 };
 
 /* This structure is private to each device.
@@ -453,6 +454,7 @@ struct altera_tse_private {
 	u32 rxctrlreg;
 	dma_addr_t rxdescphys;
 	dma_addr_t txdescphys;
+	size_t sgdmadesclen;
 
 	struct list_head txlisthd;
 	struct list_head rxlisthd;
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index c70a29e..dabba5e 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -224,6 +224,7 @@ static int tse_init_rx_buffer(struct altera_tse_private *priv,
 		dev_kfree_skb_any(rxbuffer->skb);
 		return -EINVAL;
 	}
+	rxbuffer->dma_addr &= (dma_addr_t)~3;
 	rxbuffer->len = len;
 	return 0;
 }
@@ -425,9 +426,10 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 		priv->dev->stats.rx_bytes += pktlength;
 
 		entry = next_entry;
+
+		tse_rx_refill(priv);
 	}
 
-	tse_rx_refill(priv);
 	return count;
 }
 
@@ -520,7 +522,6 @@ static irqreturn_t altera_isr(int irq, void *dev_id)
 	struct altera_tse_private *priv;
 	unsigned long int flags;
 
-
 	if (unlikely(!dev)) {
 		pr_err("%s: invalid dev pointer\n", __func__);
 		return IRQ_NONE;
@@ -868,13 +869,13 @@ static int init_mac(struct altera_tse_private *priv)
 	/* Disable RX/TX shift 16 for alignment of all received frames on 16-bit
 	 * start address
 	 */
-	tse_clear_bit(&mac->rx_cmd_stat, ALTERA_TSE_RX_CMD_STAT_RX_SHIFT16);
+	tse_set_bit(&mac->rx_cmd_stat, ALTERA_TSE_RX_CMD_STAT_RX_SHIFT16);
 	tse_clear_bit(&mac->tx_cmd_stat, ALTERA_TSE_TX_CMD_STAT_TX_SHIFT16 |
 					 ALTERA_TSE_TX_CMD_STAT_OMIT_CRC);
 
 	/* Set the MAC options */
 	cmd = ioread32(&mac->command_config);
-	cmd |= MAC_CMDCFG_PAD_EN;	/* Padding Removal on Receive */
+	cmd &= ~MAC_CMDCFG_PAD_EN;	/* No padding Removal on Receive */
 	cmd &= ~MAC_CMDCFG_CRC_FWD;	/* CRC Removal */
 	cmd |= MAC_CMDCFG_RX_ERR_DISC;	/* Automatically discard frames
 					 * with CRC errors
@@ -882,6 +883,12 @@ static int init_mac(struct altera_tse_private *priv)
 	cmd |= MAC_CMDCFG_CNTL_FRM_ENA;
 	cmd &= ~MAC_CMDCFG_TX_ENA;
 	cmd &= ~MAC_CMDCFG_RX_ENA;
+
+	/* Default speed and duplex setting, full/100 */
+	cmd &= ~MAC_CMDCFG_HD_ENA;
+	cmd &= ~MAC_CMDCFG_ETH_SPEED;
+	cmd &= ~MAC_CMDCFG_ENA_10;
+
 	iowrite32(cmd, &mac->command_config);
 
 	if (netif_msg_hw(priv))
@@ -1085,17 +1092,19 @@ static int tse_open(struct net_device *dev)
 
 	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
 
-	/* Start MAC Rx/Tx */
-	spin_lock(&priv->mac_cfg_lock);
-	tse_set_mac(priv, true);
-	spin_unlock(&priv->mac_cfg_lock);
-
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
+	priv->dmaops->start_rxdma(priv);
+
+	/* Start MAC Rx/Tx */
+	spin_lock(&priv->mac_cfg_lock);
+	tse_set_mac(priv, true);
+	spin_unlock(&priv->mac_cfg_lock);
+
 	return 0;
 
 tx_request_irq_error:
@@ -1167,7 +1176,6 @@ static struct net_device_ops altera_tse_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-
 static int request_and_map(struct platform_device *pdev, const char *name,
 			   struct resource **res, void __iomem **ptr)
 {
@@ -1496,6 +1504,7 @@ struct altera_dmaops altera_dtype_sgdma = {
 	.get_rx_status = sgdma_rx_status,
 	.init_dma = sgdma_initialize,
 	.uninit_dma = sgdma_uninitialize,
+	.start_rxdma = sgdma_start_rxdma,
 };
 
 struct altera_dmaops altera_dtype_msgdma = {
@@ -1514,6 +1523,7 @@ struct altera_dmaops altera_dtype_msgdma = {
 	.get_rx_status = msgdma_rx_status,
 	.init_dma = msgdma_initialize,
 	.uninit_dma = msgdma_uninitialize,
+	.start_rxdma = msgdma_start_rxdma,
 };
 
 static struct of_device_id altera_tse_ids[] = {
-- 
1.7.9.5
