From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r6040' branch
Date: Wed, 28 Nov 2007 23:08:12 +0100
Message-ID: <20071128220812.GA12598@electric-eye.fr.zoreil.com>
References: <20071127204536.61bf7921.akpm@google.com> <20071127230601.fbb60024.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45269 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752771AbXK1WMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 17:12:21 -0500
Content-Disposition: inline
In-Reply-To: <20071127230601.fbb60024.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'r6040' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r6040

to get the changes below.

Distance from 'netdev-2.6-upstream' (02e063b58b7c7084bae3d599c54dcf26c8efa9b7)
------------------------------------------------------------------------------

8dd657d2d82657c1d70219a704ccfe4fecfc55be
f00c12227fe587b6c1bbb6b459394db29dc5fac0
c7eaa9bde00c778b53f778d49617353d3b9b0c21
cc27eeb9474a87b2073488f37d9e90e6a3557664

Diffstat
--------

 drivers/net/r6040.c     |  138 ++++++++++++++++++++++-------------------------
 include/linux/pci_ids.h |    1 -
 2 files changed, 64 insertions(+), 75 deletions(-)

Shortlog
--------

Francois Romieu (4):
      r6040: compile error
      r6040: remove virt_to_bus
      r6040: erroneous dev->priv
      r6040: cleanups

Patch
-----

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 1d7efa2..2334f4e 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -3,7 +3,7 @@
  *
  * Copyright (C) 2004 Sten Wang <sten.wang@rdc.com.tw>
  * Copyright (C) 2007
- * 	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
+ *	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
  *	Florian Fainelli <florian@openwrt.org>
  *
  * This program is free software; you can redistribute it and/or
@@ -60,7 +60,7 @@
 #define PHY_CAP		0x01E1	/* PHY CHIP Register 4 */
 
 /* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT  	(6000 * HZ / 1000)
+#define TX_TIMEOUT	(6000 * HZ / 1000)
 #define TIMER_WUT	(jiffies + HZ * 1)/* timer wakeup time : 1 second */
 
 /* RDC MAC I/O Size */
@@ -126,8 +126,8 @@
 #define TX_DCNT		0x80	/* TX descriptor count */
 #define RX_DCNT		0x80	/* RX descriptor count */
 #define MAX_BUF_SIZE	0x600
-#define ALLOC_DESC_SIZE	((TX_DCNT+RX_DCNT) * \
-	sizeof(struct r6040_descriptor) + 0x10)
+#define RX_DESC_SIZE	(RX_DCNT * sizeof(struct r6040_descriptor))
+#define TX_DESC_SIZE	(TX_DCNT * sizeof(struct r6040_descriptor))
 #define MBCR_DEFAULT	0x012A	/* MAC Bus Control Register */
 #define MCAST_MAX	4	/* Max number multicast addresses to filter */
 
@@ -164,10 +164,12 @@ struct r6040_private {
 	struct r6040_descriptor *rx_remove_ptr;
 	struct r6040_descriptor *tx_insert_ptr;
 	struct r6040_descriptor *tx_remove_ptr;
+	struct r6040_descriptor *rx_ring;
+	struct r6040_descriptor *tx_ring;
+	dma_addr_t rx_ring_dma;
+	dma_addr_t tx_ring_dma;
 	u16	tx_free_desc, rx_free_desc, phy_addr, phy_mode;
 	u16	mcr0, mcr1;
-	dma_addr_t desc_dma;
-	char	*desc_pool;
 	u16	switch_sig;
 	struct net_device *dev;
 	struct mii_if_info mii_if;
@@ -233,8 +235,7 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 	phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
-static void
-r6040_tx_timeout(struct net_device *dev)
+static void r6040_tx_timeout(struct net_device *dev)
 {
 	struct r6040_private *priv = netdev_priv(dev);
 
@@ -260,7 +261,7 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 		if (!descptr->skb_ptr)
 			break;
 		descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
-			descptr->skb_ptr->tail,
+			descptr->skb_ptr->data,
 			MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
 		descptr->status = 0x8000;
 		descptr = descptr->vndescp;
@@ -291,6 +292,7 @@ static void r6040_down(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
+	struct pci_dev *pdev = lp->pdev;
 	int i;
 	int limit = 2048;
 	u16 *adrp;
@@ -334,12 +336,11 @@ static void r6040_down(struct net_device *dev)
 	}
 
 	/* Free Descriptor memory */
-	pci_free_consistent(lp->pdev, ALLOC_DESC_SIZE,
-		lp->desc_pool, lp->desc_dma);
+	pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
+	pci_free_consistent(pdev, TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
 }
 
-static int
-r6040_close(struct net_device *dev)
+static int r6040_close(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 
@@ -402,7 +403,7 @@ static void r6040_set_carrier(struct mii_if_info *mii)
 static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	struct mii_ioctl_data *data = (struct mii_ioctl_data *) &rq->ifr_data;
+	struct mii_ioctl_data *data = if_mii(rq);
 	int rc;
 
 	if (!netif_running(dev))
@@ -571,73 +572,58 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 static void r6040_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	r6040_interrupt(dev->irq, (void *)dev);
+	r6040_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
 
+static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
+				 dma_addr_t desc_dma, int size)
+{
+	struct r6040_descriptor *desc = desc_ring;
+	dma_addr_t mapping = desc_dma;
+
+	while (size-- > 0) {
+		mapping += sizeof(sizeof(*desc));
+		desc->ndesc = cpu_to_le32(mapping);
+		desc->vndescp = desc + 1;
+		desc++;
+	}
+	desc--;
+	desc->ndesc = cpu_to_le32(desc_dma);
+	desc->vndescp = desc_ring;
+}
 
 /* Init RDC MAC */
 static void r6040_up(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	struct r6040_descriptor *descptr;
 	void __iomem *ioaddr = lp->base;
-	int i;
-	__le32 tmp_addr;
-	dma_addr_t desc_dma, start_dma;
 
 	/* Initialize */
 	lp->tx_free_desc = TX_DCNT;
 	lp->rx_free_desc = 0;
 	/* Init descriptor */
-	memset(lp->desc_pool, 0, ALLOC_DESC_SIZE); /* Let all descriptor = 0 */
-	lp->tx_insert_ptr = (struct r6040_descriptor *)lp->desc_pool;
-	lp->tx_remove_ptr = lp->tx_insert_ptr;
-	lp->rx_insert_ptr = (struct r6040_descriptor *)lp->tx_insert_ptr +
-		TX_DCNT;
-	lp->rx_remove_ptr = lp->rx_insert_ptr;
+	lp->tx_remove_ptr = lp->tx_insert_ptr = lp->tx_ring;
+	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
 	/* Init TX descriptor */
-	descptr = lp->tx_insert_ptr;
-	desc_dma = lp->desc_dma;
-	start_dma = desc_dma;
-	for (i = 0; i < TX_DCNT; i++) {
-		descptr->ndesc = cpu_to_le32(desc_dma +
-			sizeof(struct r6040_descriptor));
-		descptr->vndescp = (descptr + 1);
-		descptr = (descptr + 1);
-		desc_dma += sizeof(struct r6040_descriptor);
-	}
-	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
-	(descptr - 1)->vndescp = lp->tx_insert_ptr;
+	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
 
 	/* Init RX descriptor */
-	start_dma = desc_dma;
-	descptr = lp->rx_insert_ptr;
-	for (i = 0; i < RX_DCNT; i++) {
-		descptr->ndesc = cpu_to_le32(desc_dma +
-			sizeof(struct r6040_descriptor));
-		descptr->vndescp = (descptr + 1);
-		descptr = (descptr + 1);
-		desc_dma += sizeof(struct r6040_descriptor);
-	}
-	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
-	(descptr - 1)->vndescp = lp->rx_insert_ptr;
+	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
 
 	/* Allocate buffer for RX descriptor */
 	rx_buf_alloc(lp, dev);
 
-	/* TX and RX descriptor start Register */
-	tmp_addr = cpu_to_le32((u32)lp->tx_insert_ptr);
-	tmp_addr = virt_to_bus((volatile void *)tmp_addr);
-	/* Lower 16-bits to MTD_SA0 */
-	iowrite16(tmp_addr, ioaddr + MTD_SA0);
-	/* Higher 16-bits to MTD_SA1 */
-	iowrite16((u16)(tmp_addr >> 16), ioaddr + MTD_SA1);
-	tmp_addr = cpu_to_le32((u32)lp->rx_insert_ptr);
-	tmp_addr = virt_to_bus((volatile void *)tmp_addr);
-	iowrite16(tmp_addr, ioaddr + MRD_SA0);
-	iowrite16((u16)(tmp_addr >> 16), ioaddr + MRD_SA1);
+	/*
+	 * TX and RX descriptor start registers.
+	 * Lower 16-bits to MxD_SA0. Higher 16-bits to MxD_SA1.
+	 */
+	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
+	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
+
+	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
+	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
 
 	/* Buffer Size Register */
 	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
@@ -685,7 +671,7 @@ static void r6040_up(struct net_device *dev)
 static void r6040_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct r6040_private *lp = netdev_priv(dev->priv);
+	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 phy_mode;
 
@@ -727,10 +713,9 @@ static void r6040_mac_address(struct net_device *dev)
 	iowrite16(adrp[2], ioaddr + MID_0H);
 }
 
-static int
-r6040_open(struct net_device *dev)
+static int r6040_open(struct net_device *dev)
 {
-	struct r6040_private *lp = dev->priv;
+	struct r6040_private *lp = netdev_priv(dev);
 	int ret;
 
 	/* Request IRQ and Register interrupt handler */
@@ -743,11 +728,19 @@ r6040_open(struct net_device *dev)
 	r6040_mac_address(dev);
 
 	/* Allocate Descriptor memory */
-	lp->desc_pool = pci_alloc_consistent(lp->pdev,
-		ALLOC_DESC_SIZE, &lp->desc_dma);
-	if (!lp->desc_pool)
+	lp->rx_ring =
+		pci_alloc_consistent(lp->pdev, RX_DESC_SIZE, &lp->rx_ring_dma);
+	if (!lp->rx_ring)
 		return -ENOMEM;
 
+	lp->tx_ring =
+		pci_alloc_consistent(lp->pdev, TX_DESC_SIZE, &lp->tx_ring_dma);
+	if (!lp->tx_ring) {
+		pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
+				     lp->rx_ring_dma);
+		return -ENOMEM;
+	}
+
 	r6040_up(dev);
 
 	napi_enable(&lp->napi);
@@ -764,8 +757,7 @@ r6040_open(struct net_device *dev)
 	return 0;
 }
 
-static int
-r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	struct r6040_descriptor *descptr;
@@ -813,8 +805,7 @@ r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
-static void
-r6040_multicast_list(struct net_device *dev)
+static void r6040_multicast_list(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
@@ -941,7 +932,6 @@ static struct ethtool_ops netdev_ethtool_ops = {
 	.get_link		= netdev_get_link,
 };
 
-
 static int __devinit r6040_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
@@ -1078,13 +1068,13 @@ static void __devexit r6040_remove_one(struct pci_dev *pdev)
 
 
 static struct pci_device_id r6040_pci_tbl[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, PCI_DEVICE_ID_RDC_R6040) },
-	{0 }
+	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, 0x6040) },
+	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, r6040_pci_tbl);
 
 static struct pci_driver r6040_driver = {
-	.name		= "r6040",
+	.name		= DRV_NAME,
 	.id_table	= r6040_pci_tbl,
 	.probe		= r6040_init_one,
 	.remove		= __devexit_p(r6040_remove_one),
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index e148e02..290f84c 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2108,7 +2108,6 @@
 #define PCI_DEVICE_ID_HERC_UNI		0x5832
 
 #define PCI_VENDOR_ID_RDC		0x17f3
-#define PCI_DEVICE_ID_RDC_R6040		0x6040
 
 #define PCI_VENDOR_ID_SITECOM		0x182d
 #define PCI_DEVICE_ID_SITECOM_DC105V2	0x3069
-- 
Ueimor
