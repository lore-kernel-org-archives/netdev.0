From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [3/5] [v2] pasemi_mac: cleanups and rx performance improvements
Date: Wed, 18 Apr 2007 01:26:52 -0500
Message-ID: <20070418062652.GD11308@lixom.net>
References: <20070416061654.GB19783@lixom.net> <20070418062451.GA11308@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:37175 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753928AbXDRGIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 02:08:31 -0400
Content-Disposition: inline
In-Reply-To: <20070418062451.GA11308@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NAPI fixes and cleanups for pasemi_mac:

* Timer changes/fixes
* Abstract out the rx intr restart to a separate function
* Similar function for tx intr to reset to a known clear state even if
  firmware used the same interface
* Add a copy-break and recycle the SKB in the driver for small
  packets
* Other minor changes to rx path

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: powerpc/drivers/net/pasemi_mac.c
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.c
+++ powerpc/drivers/net/pasemi_mac.c
@@ -61,12 +61,6 @@
 
 #define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 
-/* XXXOJN these should come out of the device tree some day */
-#define PAS_DMA_CAP_BASE   0xe00d0040
-#define PAS_DMA_CAP_SIZE   0x100
-#define PAS_DMA_COM_BASE   0xe00d0100
-#define PAS_DMA_COM_SIZE   0x100
-
 static struct pasdma_status *dma_status;
 
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
@@ -279,8 +273,8 @@ static void pasemi_mac_free_rx_resources
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		info = &RX_DESC_INFO(mac, i);
 		dp = &RX_DESC(mac, i);
-		if (info->dma) {
-			if (info->skb) {
+		if (info->skb) {
+			if (info->dma) {
 				pci_unmap_single(mac->dma_pdev,
 						 info->dma,
 						 info->skb->len,
@@ -311,84 +305,122 @@ static void pasemi_mac_replenish_rx_ring
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	int start = mac->rx->next_to_fill;
-	unsigned int count;
+	unsigned int limit, count;
 
-	count = (mac->rx->next_to_clean + RX_RING_SIZE -
+	limit = (mac->rx->next_to_clean + RX_RING_SIZE -
 		 mac->rx->next_to_fill) & (RX_RING_SIZE - 1);
 
 	/* Check to see if we're doing first-time setup */
 	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
-		count = RX_RING_SIZE;
+		limit = RX_RING_SIZE;
 
-	if (count <= 0)
+	if (limit <= 0)
 		return;
 
-	for (i = start; i < start + count; i++) {
+	i = start;
+
+	for (count = limit; count; count--) {
 		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
 		u64 *buff = &RX_BUFF(mac, i);
 		struct sk_buff *skb;
 		dma_addr_t dma;
 
-		skb = dev_alloc_skb(BUF_SIZE);
+		/* skb might still be in there for recycle on short receives */
+		if (info->skb)
+			skb = info->skb;
+		else
+			skb = dev_alloc_skb(BUF_SIZE);
 
-		if (!skb) {
-			count = i - start;
+		if (unlikely(!skb))
 			break;
-		}
 
 		skb->dev = dev;
 
 		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
 				     PCI_DMA_FROMDEVICE);
 
-		if (dma_mapping_error(dma)) {
+		if (unlikely(dma_mapping_error(dma))) {
 			dev_kfree_skb_irq(info->skb);
-			count = i - start;
 			break;
 		}
 
 		info->skb = skb;
 		info->dma = dma;
 		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
+		i++;
 	}
 
 	wmb();
 
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXCHAN_INCR(mac->dma_rxch),
-			       count);
+			       limit - count);
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_INCR(mac->dma_if),
-			       count);
+			       limit - count);
+
+	mac->rx->next_to_fill += limit - count;
+}
+
+static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
+{
+	unsigned int reg, stat;
+	/* Re-enable packet count interrupts: finally
+	 * ack the packet count interrupt we got in rx_intr.
+	 */
+
+	pci_read_config_dword(mac->iob_pdev,
+			      PAS_IOB_DMA_RXCH_STAT(mac->dma_rxch),
+			      &stat);
+
+	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(stat & PAS_IOB_DMA_RXCH_STAT_CNTDEL_M) |
+	      PAS_IOB_DMA_RXCH_RESET_PINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch),
+			       reg);
+}
+
+static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
+{
+	unsigned int reg, stat;
 
-	mac->rx->next_to_fill += count;
+	/* Re-enable packet count interrupts */
+	pci_read_config_dword(mac->iob_pdev,
+			      PAS_IOB_DMA_TXCH_STAT(mac->dma_txch), &stat);
+
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(stat & PAS_IOB_DMA_TXCH_STAT_CNTDEL_M) |
+	      PAS_IOB_DMA_TXCH_RESET_PINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+				PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
 }
 
+
 static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 {
-	unsigned int i;
-	int start, count;
+	unsigned int n;
+	int count;
+	struct pas_dma_xct_descr *dp;
+	struct pasemi_mac_buffer *info;
+	struct sk_buff *skb;
+	unsigned int i, len;
+	u64 macrx;
+	dma_addr_t dma;
 
 	spin_lock(&mac->rx->lock);
 
-	start = mac->rx->next_to_clean;
-	count = 0;
-
-	for (i = start; i < (start + RX_RING_SIZE) && count < limit; i++) {
-		struct pas_dma_xct_descr *dp;
-		struct pasemi_mac_buffer *info;
-		struct sk_buff *skb;
-		unsigned int j, len;
-		dma_addr_t dma;
+	n = mac->rx->next_to_clean;
 
+	for (count = limit; count; count--) {
 		rmb();
 
-		dp = &RX_DESC(mac, i);
+		dp = &RX_DESC(mac, n);
 
-		if (!(dp->macrx & XCT_MACRX_O))
-			break;
+		macrx = dp->macrx;
 
-		count++;
+		if (!(macrx & XCT_MACRX_O))
+			break;
 
 		info = NULL;
 
@@ -400,29 +432,42 @@ static int pasemi_mac_clean_rx(struct pa
 		 */
 
 		dma = (dp->ptr & XCT_PTR_ADDR_M);
-		for (j = start; j < (start + RX_RING_SIZE); j++) {
-			info = &RX_DESC_INFO(mac, j);
+		for (i = n; i < (n + RX_RING_SIZE); i++) {
+			info = &RX_DESC_INFO(mac, i);
 			if (info->dma == dma)
 				break;
 		}
 
-		BUG_ON(!info);
-		BUG_ON(info->dma != dma);
+		skb = info->skb;
+		info->dma = 0;
 
-		pci_unmap_single(mac->dma_pdev, info->dma, info->skb->len,
+		pci_unmap_single(mac->dma_pdev, dma, skb->len,
 				 PCI_DMA_FROMDEVICE);
 
-		skb = info->skb;
+		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
-		len = (dp->macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
+		if (len < 256) {
+			struct sk_buff *new_skb =
+			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
+			if (new_skb) {
+				skb_reserve(new_skb, NET_IP_ALIGN);
+				memcpy(new_skb->data - NET_IP_ALIGN,
+					skb->data - NET_IP_ALIGN,
+					len + NET_IP_ALIGN);
+				/* save the skb in buffer_info as good */
+				skb = new_skb;
+			}
+			/* else just continue with the old one */
+		} else
+			info->skb = NULL;
 
 		skb_put(skb, len);
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 
-		if ((dp->macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
+		if ((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
 			skb->ip_summed = CHECKSUM_COMPLETE;
-			skb->csum = (dp->macrx & XCT_MACRX_CSUM_M) >>
+			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
@@ -432,13 +477,13 @@ static int pasemi_mac_clean_rx(struct pa
 
 		netif_receive_skb(skb);
 
-		info->dma = 0;
-		info->skb = NULL;
 		dp->ptr = 0;
 		dp->macrx = 0;
+
+		n++;
 	}
 
-	mac->rx->next_to_clean += count;
+	mac->rx->next_to_clean += limit - count;
 	pasemi_mac_replenish_rx_ring(mac->netdev);
 
 	spin_unlock(&mac->rx->lock);
@@ -496,18 +541,28 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
 
-	if (!(*mac->rx_status & PAS_STATUS_INT))
+	if (!(*mac->rx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	netif_rx_schedule(dev);
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0));
+	if (*mac->rx_status & PAS_STATUS_ERROR)
+		printk("rx_status reported error\n");
 
-	reg = PAS_IOB_DMA_RXCH_RESET_PINTC | PAS_IOB_DMA_RXCH_RESET_SINTC |
-	      PAS_IOB_DMA_RXCH_RESET_DINTC;
+	/* Don't reset packet count so it won't fire again but clear
+	 * all others.
+	 */
+
+	pci_read_config_dword(mac->dma_pdev, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), &reg);
+
+	reg = 0;
+	if (*mac->rx_status & PAS_STATUS_SOFT)
+		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
+	if (*mac->rx_status & PAS_STATUS_ERROR)
+		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
 	if (*mac->rx_status & PAS_STATUS_TIMER)
 		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
+	netif_rx_schedule(dev);
+
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
 
@@ -521,14 +576,17 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
 
-	if (!(*mac->tx_status & PAS_STATUS_INT))
+	if (!(*mac->tx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	pasemi_mac_clean_tx(mac);
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PINTC | PAS_IOB_DMA_TXCH_RESET_SINTC;
-	if (*mac->tx_status & PAS_STATUS_TIMER)
-		reg |= PAS_IOB_DMA_TXCH_RESET_TINTC;
+	reg = PAS_IOB_DMA_TXCH_RESET_PINTC;
+
+	if (*mac->tx_status & PAS_STATUS_SOFT)
+		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
+	if (*mac->tx_status & PAS_STATUS_ERROR)
+		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
@@ -564,10 +622,18 @@ static int pasemi_mac_open(struct net_de
 	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
-			       PAS_IOB_DMA_RXCH_CFG_CNTTH(30));
+			       PAS_IOB_DMA_RXCH_CFG_CNTTH(1));
+
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
+			       PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
 
+	/* Clear out any residual packet count state from firmware */
+	pasemi_mac_restart_rx_intr(mac);
+	pasemi_mac_restart_tx_intr(mac);
+
+	/* 0xffffff is max value, about 16ms */
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
 	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
 
@@ -586,7 +652,7 @@ static int pasemi_mac_open(struct net_de
 	/* enable rx if */
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-			       PAS_DMA_RXINT_RCMDSTA_EN);
+			       PAS_DMA_RXINT_RCMDSTA_EN|PAS_DMA_RXINT_RCMDSTA_MBT);
 
 	/* enable rx channel */
 	pci_write_config_dword(mac->dma_pdev,
@@ -836,18 +902,18 @@ static int pasemi_mac_poll(struct net_de
 
 	pkts = pasemi_mac_clean_rx(mac, limit);
 
+	dev->quota -= pkts;
+	*budget -= pkts;
+
 	if (pkts < limit) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
 
-		/* re-enable receive interrupts */
-		pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-				       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+		pasemi_mac_restart_rx_intr(mac);
+
 		return 0;
 	} else {
 		/* used up our quantum, so reschedule */
-		dev->quota -= pkts;
-		*budget -= pkts;
 		return 1;
 	}
 }
Index: powerpc/drivers/net/pasemi_mac.h
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.h
+++ powerpc/drivers/net/pasemi_mac.h
@@ -195,11 +195,15 @@ enum {
 #define PAS_DMA_RXINT_RCMDSTA(i)	(0x200+(i)*_PAS_DMA_RXINT_STRIDE)
 #define    PAS_DMA_RXINT_RCMDSTA_EN	0x00000001
 #define    PAS_DMA_RXINT_RCMDSTA_ST	0x00000002
-#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00000100
-#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00000200
-#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00000400
+#define    PAS_DMA_RXINT_RCMDSTA_MBT	0x00000008
+#define    PAS_DMA_RXINT_RCMDSTA_MDR	0x00000010
+#define    PAS_DMA_RXINT_RCMDSTA_MOO	0x00000020
+#define    PAS_DMA_RXINT_RCMDSTA_MBP	0x00000040
 #define    PAS_DMA_RXINT_RCMDSTA_BT	0x00000800
-#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00002000
+#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00004000
+#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00008000
 #define    PAS_DMA_RXINT_RCMDSTA_ACT	0x00010000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
@@ -299,6 +303,7 @@ enum {
 #define    PAS_STATUS_DCNT_S		16
 #define    PAS_STATUS_BPCNT_M		0x0000ffff00000000ull
 #define    PAS_STATUS_BPCNT_S		32
+#define    PAS_STATUS_CAUSE_M		0xf000000000000000ull
 #define    PAS_STATUS_TIMER		0x1000000000000000ull
 #define    PAS_STATUS_ERROR		0x2000000000000000ull
 #define    PAS_STATUS_SOFT		0x4000000000000000ull
