From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for '8139cp-20060912-00' branch
Date: Tue, 12 Sep 2006 21:20:39 +0200
Message-ID: <20060912192039.GA4482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:9378 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1030226AbWILTVC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 15:21:02 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag '8139cp-20060912-00' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

to get the change below:

(patch applies to jeff#upstream-linus)

Shortlog
--------

Francois Romieu:

    8139cp: ring_info removal for the transmit path
    8139cp: use PCI_DEVICE() to shorten the PCI device table
    8139cp: pci_get_drvdata(pdev) can not be NULL in suspend handler
    8139cp: removal of useless BUG_ON() check
    8139cp: sync the device private data with its r8169 counterpart
    8139cp: ring_info removal for the receive path
    8139cp: remove gratuitous indirection
    8139cp: trim ring_info
    
Patch
-----

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 1428bb7..c3b8400 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -314,12 +314,6 @@ struct cp_desc {
 	u64		addr;
 };
 
-struct ring_info {
-	struct sk_buff		*skb;
-	dma_addr_t		mapping;
-	u32			len;
-};
-
 struct cp_dma_stats {
 	u64			tx_ok;
 	u64			rx_ok;
@@ -353,23 +347,23 @@ struct cp_private {
 	struct net_device_stats net_stats;
 	struct cp_extra_stats	cp_stats;
 
-	unsigned		rx_tail		____cacheline_aligned;
+	unsigned		rx_head		____cacheline_aligned;
+	unsigned		rx_tail;
 	struct cp_desc		*rx_ring;
-	struct ring_info	rx_skb[CP_RX_RING_SIZE];
-	unsigned		rx_buf_sz;
+	struct sk_buff		*rx_skb[CP_RX_RING_SIZE];
 
 	unsigned		tx_head		____cacheline_aligned;
 	unsigned		tx_tail;
-
 	struct cp_desc		*tx_ring;
-	struct ring_info	tx_skb[CP_TX_RING_SIZE];
-	dma_addr_t		ring_dma;
+	struct sk_buff		*tx_skb[CP_TX_RING_SIZE];
+
+	unsigned		rx_buf_sz;
+	unsigned		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
 
 #if CP_VLAN_TAG_USED
 	struct vlan_group	*vlgrp;
 #endif
-
-	unsigned int		wol_enabled : 1; /* Is Wake-on-LAN enabled? */
+	dma_addr_t		ring_dma;
 
 	struct mii_if_info	mii_if;
 };
@@ -407,10 +401,8 @@ static int cp_set_eeprom(struct net_devi
 			 struct ethtool_eeprom *eeprom, u8 *data);
 
 static struct pci_device_id cp_pci_tbl[] = {
-	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8139,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
-	{ PCI_VENDOR_ID_TTTECH, PCI_DEVICE_ID_TTTECH_MC322,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	PCI_DEVICE_ID_REALTEK_8139), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_TTTECH,	PCI_DEVICE_ID_TTTECH_MC322), },
 	{ },
 };
 MODULE_DEVICE_TABLE(pci, cp_pci_tbl);
@@ -542,7 +534,7 @@ rx_status_loop:
 		struct cp_desc *desc;
 		unsigned buflen;
 
-		skb = cp->rx_skb[rx_tail].skb;
+		skb = cp->rx_skb[rx_tail];
 		BUG_ON(!skb);
 
 		desc = &cp->rx_ring[rx_tail];
@@ -551,7 +543,7 @@ rx_status_loop:
 			break;
 
 		len = (status & 0x1fff) - 4;
-		mapping = cp->rx_skb[rx_tail].mapping;
+		mapping = le64_to_cpu(desc->addr);
 
 		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag)) {
 			/* we don't support incoming fragmented frames.
@@ -572,7 +564,7 @@ rx_status_loop:
 
 		if (netif_msg_rx_status(cp))
 			printk(KERN_DEBUG "%s: rx slot %d status 0x%x len %d\n",
-			       cp->dev->name, rx_tail, status, len);
+			       dev->name, rx_tail, status, len);
 
 		buflen = cp->rx_buf_sz + RX_OFFSET;
 		new_skb = dev_alloc_skb (buflen);
@@ -582,7 +574,7 @@ rx_status_loop:
 		}
 
 		skb_reserve(new_skb, RX_OFFSET);
-		new_skb->dev = cp->dev;
+		new_skb->dev = dev;
 
 		pci_unmap_single(cp->pdev, mapping,
 				 buflen, PCI_DMA_FROMDEVICE);
@@ -595,11 +587,9 @@ rx_status_loop:
 
 		skb_put(skb, len);
 
-		mapping =
-		cp->rx_skb[rx_tail].mapping =
-			pci_map_single(cp->pdev, new_skb->data,
-				       buflen, PCI_DMA_FROMDEVICE);
-		cp->rx_skb[rx_tail].skb = new_skb;
+		mapping = pci_map_single(cp->pdev, new_skb->data, buflen,
+					 PCI_DMA_FROMDEVICE);
+		cp->rx_skb[rx_tail] = new_skb;
 
 		cp_rx_skb(cp, skb, desc);
 		rx++;
@@ -717,19 +707,21 @@ static void cp_tx (struct cp_private *cp
 	unsigned tx_tail = cp->tx_tail;
 
 	while (tx_tail != tx_head) {
+		struct cp_desc *txd = cp->tx_ring + tx_tail;
 		struct sk_buff *skb;
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(cp->tx_ring[tx_tail].opts1);
+		status = le32_to_cpu(txd->opts1);
 		if (status & DescOwn)
 			break;
 
-		skb = cp->tx_skb[tx_tail].skb;
+		skb = cp->tx_skb[tx_tail];
 		BUG_ON(!skb);
 
-		pci_unmap_single(cp->pdev, cp->tx_skb[tx_tail].mapping,
-				 cp->tx_skb[tx_tail].len, PCI_DMA_TODEVICE);
+		pci_unmap_single(cp->pdev, le64_to_cpu(txd->addr),
+				 le32_to_cpu(txd->opts1) & 0xffff,
+				 PCI_DMA_TODEVICE);
 
 		if (status & LastFrag) {
 			if (status & (TxError | TxFIFOUnder)) {
@@ -756,7 +748,7 @@ static void cp_tx (struct cp_private *cp
 			dev_kfree_skb_irq(skb);
 		}
 
-		cp->tx_skb[tx_tail].skb = NULL;
+		cp->tx_skb[tx_tail] = NULL;
 
 		tx_tail = NEXT_TX(tx_tail);
 	}
@@ -826,9 +818,7 @@ #endif
 		txd->opts1 = cpu_to_le32(flags);
 		wmb();
 
-		cp->tx_skb[entry].skb = skb;
-		cp->tx_skb[entry].mapping = mapping;
-		cp->tx_skb[entry].len = len;
+		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
 	} else {
 		struct cp_desc *txd;
@@ -844,9 +834,7 @@ #endif
 		first_len = skb_headlen(skb);
 		first_mapping = pci_map_single(cp->pdev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
-		cp->tx_skb[entry].skb = skb;
-		cp->tx_skb[entry].mapping = first_mapping;
-		cp->tx_skb[entry].len = first_len;
+		cp->tx_skb[entry] = skb;
 		entry = NEXT_TX(entry);
 
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
@@ -887,9 +875,7 @@ #endif
 			txd->opts1 = cpu_to_le32(ctrl);
 			wmb();
 
-			cp->tx_skb[entry].skb = skb;
-			cp->tx_skb[entry].mapping = mapping;
-			cp->tx_skb[entry].len = len;
+			cp->tx_skb[entry] = skb;
 			entry = NEXT_TX(entry);
 		}
 
@@ -1091,6 +1077,7 @@ static int cp_refill_rx (struct cp_priva
 
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
+		dma_addr_t mapping;
 
 		skb = dev_alloc_skb(cp->rx_buf_sz + RX_OFFSET);
 		if (!skb)
@@ -1099,12 +1086,12 @@ static int cp_refill_rx (struct cp_priva
 		skb->dev = cp->dev;
 		skb_reserve(skb, RX_OFFSET);
 
-		cp->rx_skb[i].mapping = pci_map_single(cp->pdev,
-			skb->data, cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		cp->rx_skb[i].skb = skb;
+		mapping = pci_map_single(cp->pdev, skb->data, cp->rx_buf_sz,
+					 PCI_DMA_FROMDEVICE);
+		cp->rx_skb[i] = skb;
 
 		cp->rx_ring[i].opts2 = 0;
-		cp->rx_ring[i].addr = cpu_to_le64(cp->rx_skb[i].mapping);
+		cp->rx_ring[i].addr = cpu_to_le64(mapping);
 		if (i == (CP_RX_RING_SIZE - 1))
 			cp->rx_ring[i].opts1 =
 				cpu_to_le32(DescOwn | RingEnd | cp->rx_buf_sz);
@@ -1152,23 +1139,27 @@ static int cp_alloc_rings (struct cp_pri
 
 static void cp_clean_rings (struct cp_private *cp)
 {
+	struct cp_desc *desc;
 	unsigned i;
 
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
-		if (cp->rx_skb[i].skb) {
-			pci_unmap_single(cp->pdev, cp->rx_skb[i].mapping,
+		if (cp->rx_skb[i]) {
+			desc = cp->rx_ring + i;
+			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(cp->rx_skb[i].skb);
+			dev_kfree_skb(cp->rx_skb[i]);
 		}
 	}
 
 	for (i = 0; i < CP_TX_RING_SIZE; i++) {
-		if (cp->tx_skb[i].skb) {
-			struct sk_buff *skb = cp->tx_skb[i].skb;
-
-			pci_unmap_single(cp->pdev, cp->tx_skb[i].mapping,
-				 	 cp->tx_skb[i].len, PCI_DMA_TODEVICE);
-			if (le32_to_cpu(cp->tx_ring[i].opts1) & LastFrag)
+		if (cp->tx_skb[i]) {
+			struct sk_buff *skb = cp->tx_skb[i];
+
+			desc = cp->tx_ring + i;
+			pci_unmap_single(cp->pdev, le64_to_cpu(desc->addr),
+					 le32_to_cpu(desc->opts1) & 0xffff,
+					 PCI_DMA_TODEVICE);
+			if (le32_to_cpu(desc->opts1) & LastFrag)
 				dev_kfree_skb(skb);
 			cp->net_stats.tx_dropped++;
 		}
@@ -1177,8 +1168,8 @@ static void cp_clean_rings (struct cp_pr
 	memset(cp->rx_ring, 0, sizeof(struct cp_desc) * CP_RX_RING_SIZE);
 	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);
 
-	memset(&cp->rx_skb, 0, sizeof(struct ring_info) * CP_RX_RING_SIZE);
-	memset(&cp->tx_skb, 0, sizeof(struct ring_info) * CP_TX_RING_SIZE);
+	memset(cp->rx_skb, 0, sizeof(struct sk_buff *) * CP_RX_RING_SIZE);
+	memset(cp->tx_skb, 0, sizeof(struct sk_buff *) * CP_TX_RING_SIZE);
 }
 
 static void cp_free_rings (struct cp_private *cp)
@@ -2010,7 +2001,6 @@ static void cp_remove_one (struct pci_de
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cp_private *cp = netdev_priv(dev);
 
-	BUG_ON(!dev);
 	unregister_netdev(dev);
 	iounmap(cp->regs);
 	if (cp->wol_enabled)
@@ -2025,14 +2015,12 @@ static void cp_remove_one (struct pci_de
 #ifdef CONFIG_PM
 static int cp_suspend (struct pci_dev *pdev, pm_message_t state)
 {
-	struct net_device *dev;
-	struct cp_private *cp;
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
 
-	dev = pci_get_drvdata (pdev);
-	cp  = netdev_priv(dev);
-
-	if (!dev || !netif_running (dev)) return 0;
+	if (!netif_running(dev))
+		return 0;
 
 	netif_device_detach (dev);
 	netif_stop_queue (dev);
-- 
Ueimor
