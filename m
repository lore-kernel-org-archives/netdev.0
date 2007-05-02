From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Tue, 01 May 2007 18:13:34 -0700
Message-ID: <1178068414.4820.39.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3058 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161726AbXEBA0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:26:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 40-bit DMA workaround for 5708.

The internal PCIE-to-PCIX bridge of the 5708 has the same 40-bit DMA
limitation as some of the tg3 chips.  Use the same workaround used in
tg3.  On 64-bit systems without IOMMU, linearize the SKB if any
address is > 40-bit.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6d05397..dba4088 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4495,6 +4495,93 @@ bnx2_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
 }
 #endif
 
+/* Test for DMA addresses > 40-bit.
+ * Only 64-bit systems without IOMMU require DMA address checking.
+ */
+static inline int bnx2_40bit_overflow_test(struct bnx2 *bp, dma_addr_t mapping,
+					   int len)
+{
+#if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
+	if (CHIP_NUM(bp) == CHIP_NUM_5708)
+		return (((u64) mapping + len) > DMA_40BIT_MASK);
+	return 0;
+#else
+	return 0;
+#endif
+}
+
+#if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
+/* Workaround 40-bit hardware DMA bugs. */
+static int bnx2_dma_hwbug_workaround(struct bnx2 *bp, struct sk_buff **skb,
+				     u16 *last_plus_one, u32 base_flags,
+				     u32 mss)
+{
+	struct sk_buff *new_skb = skb_copy(*skb, GFP_ATOMIC);
+	dma_addr_t new_addr = 0;
+	int i, ret = 0;
+	u16 hw_prod = *last_plus_one;
+	u16 start, hw_start, prod;
+
+	prod = TX_RING_IDX(hw_prod);
+	start = prod - 1 - skb_shinfo(*skb)->nr_frags;
+	hw_start = hw_prod - 1 - skb_shinfo(*skb)->nr_frags;
+	start &= MAX_TX_DESC_CNT;
+	if (start > prod) {
+		start--;
+		hw_start--;
+	}
+
+	if (!new_skb) {
+		ret = -1;
+	} else {
+		struct tx_bd *txbd;
+
+		/* New SKB is guaranteed to be linear. */
+		new_addr = pci_map_single(bp->pdev, new_skb->data, new_skb->len,
+					  PCI_DMA_TODEVICE);
+		txbd = &bp->tx_desc_ring[start];
+
+		txbd->tx_bd_haddr_hi = (u64) new_addr >> 32;
+		txbd->tx_bd_haddr_lo = (u64) new_addr & 0xffffffff;
+		txbd->tx_bd_mss_nbytes = new_skb->len | (mss << 16);
+		txbd->tx_bd_vlan_tag_flags = base_flags | TX_BD_FLAGS_START |
+					     TX_BD_FLAGS_END;
+
+		*last_plus_one = NEXT_TX_BD(hw_start);
+	}
+
+	/* Now clean up the sw ring entries. */
+	i = 0;
+	while (start != prod) {
+		int len;
+
+		if (i == 0)
+			len = skb_headlen(*skb);
+		else
+			len = skb_shinfo(*skb)->frags[i-1].size;
+
+		pci_unmap_single(bp->pdev,
+				 pci_unmap_addr(&tp->tx_buf_ring[start],
+					 	mapping),
+				 len, PCI_DMA_TODEVICE);
+		if (i == 0) {
+			bp->tx_buf_ring[start].skb = new_skb;
+			pci_unmap_addr_set(&bp->tx_buf_ring[start], mapping,
+					   new_addr);
+		}
+		hw_start = NEXT_TX_BD(hw_start);
+		start = TX_RING_IDX(hw_start);
+		i++;
+	}
+
+	dev_kfree_skb(*skb);
+
+	*skb = new_skb;
+
+	return ret;
+}
+#endif
+
 /* Called with netif_tx_lock.
  * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue().
@@ -4508,7 +4595,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct sw_bd *tx_buf;
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
-	int i;
+	int i, would_hit_hwbug = 0;
 
 	if (unlikely(bnx2_tx_avail(bp) < (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
@@ -4598,10 +4685,25 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbd->tx_bd_mss_nbytes = len | (mss << 16);
 		txbd->tx_bd_vlan_tag_flags = vlan_tag_flags;
 
+		if (bnx2_40bit_overflow_test(bp, mapping, len))
+			would_hit_hwbug = 1;
 	}
 	txbd->tx_bd_vlan_tag_flags |= TX_BD_FLAGS_END;
 
 	prod = NEXT_TX_BD(prod);
+
+#if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
+	if (unlikely(would_hit_hwbug)) {
+		/* If the workaround fails due to memory/mapping
+		 * failure, silently drop this packet.
+		 */
+		if (bnx2_dma_hwbug_workaround(bp, &skb, &prod,
+					      vlan_tag_flags, mss))
+			return NETDEV_TX_OK;
+
+	}
+#endif
+
 	bp->tx_prod_bseq += skb->len;
 
 	REG_WR16(bp, bp->tx_bidx_addr, prod);
@@ -5711,6 +5813,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	unsigned long mem_len;
 	int rc;
 	u32 reg;
+	u64 dma_mask, persist_dma_mask;
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -5749,21 +5852,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_release;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) == 0) {
-		bp->flags |= USING_DAC_FLAG;
-		if (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) != 0) {
-			dev_err(&pdev->dev,
-				"pci_set_consistent_dma_mask failed, aborting.\n");
-			rc = -EIO;
-			goto err_out_release;
-		}
-	}
-	else if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0) {
-		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
-		rc = -EIO;
-		goto err_out_release;
-	}
-
 	bp->dev = dev;
 	bp->pdev = pdev;
 
@@ -5805,6 +5893,33 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		}
 	}
 
+	/* 5708 cannot support DMA addresses > 40-bit.
+	 * On 64-bit systems with IOMMU, use 40-bit dma_mask.
+	 * On 64-bit systems without IOMMU, use 64-bit dma_mask and
+	 * do DMA address check in bnx2_start_xmit().
+	 */
+	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
+#ifdef CONFIG_HIGHMEM
+		dma_mask = DMA_64BIT_MASK;
+#endif
+	} else
+		persist_dma_mask = dma_mask = DMA_64BIT_MASK;
+
+	/* Configure DMA attributes. */
+	if (pci_set_dma_mask(pdev, dma_mask) == 0) {
+		dev->features |= NETIF_F_HIGHDMA;
+		rc = pci_set_consistent_dma_mask(pdev, persist_dma_mask);
+		if (rc) {
+			dev_err(&pdev->dev,
+				"pci_set_consistent_dma_mask failed, aborting.\n");
+			goto err_out_unmap;
+		}
+	} else if ((rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) != 0) {
+		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
+		goto err_out_unmap;
+	}
+
 	/* Get bus information. */
 	reg = REG_RD(bp, BNX2_PCICFG_MISC_STATUS);
 	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {
@@ -6114,8 +6229,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	printk("\n");
 
 	dev->features |= NETIF_F_SG;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_IP_CSUM;
 #ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 878eee5..8e7b29a 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6433,7 +6433,6 @@ struct bnx2 {
 #define PCI_32BIT_FLAG			2
 #define ONE_TDMA_FLAG			4	/* no longer used */
 #define NO_WOL_FLAG			8
-#define USING_DAC_FLAG			0x10
 #define USING_MSI_FLAG			0x20
 #define ASF_ENABLE_FLAG			0x40
 


