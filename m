From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 04/10] r6040: rework the RX buffers allocation routine
Date: Sun, 13 Jul 2008 14:32:18 +0200
Message-ID: <200807131432.18779.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:55938 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbYGMMcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:32:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework the RX buffers allocation function so that we do not
leak memory in the case we could not allocate skbs for the
RX path. Propagate the errors to the r6040_up function
where we call the RX buffers allocation function.

Also rename the r6040_alloc_txbufs function to
r6040_init_txbufs, to reflect what it really does.

Signed-Off-By: Joerg Albert <jal2@gmx.de>
Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 0972152..4f2ebb2 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -312,7 +312,7 @@ static void r6040_rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 	lp->rx_insert_ptr = descptr;
 }
 
-static void r6040_alloc_txbufs(struct net_device *dev)
+static void r6040_init_txbufs(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 
@@ -322,16 +322,39 @@ static void r6040_alloc_txbufs(struct net_device *dev)
 	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
 }
 
-static void r6040_alloc_rxbufs(struct net_device *dev)
+static int r6040_alloc_rxbufs(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-
-	lp->rx_free_desc = 0;
+	struct r6040_descriptor *desc;
+	struct sk_buff *skb;
+	int rc;
 
 	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
 	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
 
-	r6040_rx_buf_alloc(lp, dev);
+	/* Allocate skbs for the rx descriptors */
+	desc = lp->rx_ring;
+	do {
+		skb = netdev_alloc_skb(dev, MAX_BUF_SIZE);
+		if (!skb) {
+			printk(KERN_ERR "%s: failed to alloc skb for rx\n", dev->name);
+			rc = -ENOMEM;
+			goto err_exit;
+		}
+		desc->skb_ptr = skb;
+		desc->buf = cpu_to_le32(pci_map_single(lp->pdev,
+						desc->skb_ptr->data,
+						MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
+		desc->status = 0x8000;
+		desc = desc->vndescp;
+	} while (desc != lp->rx_ring);
+
+	return 0;
+
+err_exit:
+	/* Deallocate all previously allocated skbs */
+	r6040_free_rxbufs(dev);
+	return rc;
 }
 
 static void r6040_init_mac_regs(struct net_device *dev)
@@ -697,14 +720,17 @@ static void r6040_poll_controller(struct net_device *dev)
 #endif
 
 /* Init RDC MAC */
-static void r6040_up(struct net_device *dev)
+static int r6040_up(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
+	int ret;
 
 	/* Initialise and alloc RX/TX buffers */
-	r6040_alloc_txbufs(dev);
-	r6040_alloc_rxbufs(dev);
+	r6040_init_txbufs(dev);
+	ret = r6040_alloc_rxbufs(dev);
+	if (ret)
+		return ret;
 
 	/* Read the PHY ID */
 	lp->switch_sig = r6040_phy_read(ioaddr, 0, 2);
@@ -734,6 +760,8 @@ static void r6040_up(struct net_device *dev)
 
 	/* Initialize all MAC registers */
 	r6040_init_mac_regs(dev);
+
+	return 0;
 }
 
 /*
@@ -812,7 +840,14 @@ static int r6040_open(struct net_device *dev)
 		return -ENOMEM;
 	}
 
-	r6040_up(dev);
+	ret = r6040_up(dev);
+	if (ret) {
+		pci_free_consistent(lp->pdev, TX_DESC_SIZE, lp->tx_ring,
+							lp->tx_ring_dma);
+		pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
+							lp->rx_ring_dma);
+		return ret;
+	}
 
 	napi_enable(&lp->napi);
 	netif_start_queue(dev);
