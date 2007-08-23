From: Olof Johansson <olof@lixom.net>
Subject: [PATCH v2] [02/10] pasemi_mac: Stop using the pci config space
	accessors for register read/writes
Date: Thu, 23 Aug 2007 13:13:10 -0500
Message-ID: <20070823181310.GB31882@lixom.net>
References: <20070817205413.548020000@lixom.net> <20070822141248.GC16830@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:58833 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbXHWTIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 15:08:10 -0400
Content-Disposition: inline
In-Reply-To: <20070822141248.GC16830@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move away from using the pci config access functions for simple register
access.  Our device has all of the registers in the config space (hey,
from the hardware point of view it looks reasonable :-), so we need to
somehow get to it. Newer firmwares have it in the device tree such that
we can just get it and ioremap it there (in case it ever moves in future
products). For now, provide a hardcoded fallback for older firmwares.


Signed-off-by: Olof Johansson <olof@lixom.net>


---

Updated: Removed explicit inlines, cleaned up read functions, fixed
grammar.


Index: mainline/drivers/net/pasemi_mac.c
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.c
+++ mainline/drivers/net/pasemi_mac.c
@@ -83,44 +83,35 @@ static struct pasdma_status *dma_status;
 
 static unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int reg)
 {
-	unsigned int val;
-
-	pci_read_config_dword(mac->iob_pdev, reg, &val);
-	return val;
+	return in_le32(mac->iob_regs+reg);
 }
 
 static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
-	pci_write_config_dword(mac->iob_pdev, reg, val);
+	out_le32(mac->iob_regs+reg, val);
 }
 
 static unsigned int read_mac_reg(struct pasemi_mac *mac, unsigned int reg)
 {
-	unsigned int val;
-
-	pci_read_config_dword(mac->pdev, reg, &val);
-	return val;
+	return in_le32(mac->regs+reg);
 }
 
 static void write_mac_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
-	pci_write_config_dword(mac->pdev, reg, val);
+	out_le32(mac->regs+reg, val);
 }
 
 static unsigned int read_dma_reg(struct pasemi_mac *mac, unsigned int reg)
 {
-	unsigned int val;
-
-	pci_read_config_dword(mac->dma_pdev, reg, &val);
-	return val;
+	return in_le32(mac->dma_regs+reg);
 }
 
 static void write_dma_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
-	pci_write_config_dword(mac->dma_pdev, reg, val);
+	out_le32(mac->dma_regs+reg, val);
 }
 
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
@@ -585,7 +576,6 @@ static int pasemi_mac_clean_tx(struct pa
 	}
 	mac->tx->next_to_clean += count;
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
-
 	netif_wake_queue(mac->netdev);
 
 	return count;
@@ -1076,6 +1066,73 @@ static int pasemi_mac_poll(struct net_de
 	}
 }
 
+static void __iomem * __devinit map_onedev(struct pci_dev *p, int index)
+{
+	struct device_node *dn;
+	void __iomem *ret;
+
+	dn = pci_device_to_OF_node(p);
+	if (!dn)
+		goto fallback;
+
+	ret = of_iomap(dn, index);
+	if (!ret)
+		goto fallback;
+
+	return ret;
+fallback:
+	/* This is hardcoded and ugly, but we have some firmware versions
+	 * that don't provide the register space in the device tree. Luckily
+	 * they are at well-known locations so we can just do the math here.
+	 */
+	return ioremap(0xe0000000 + (p->devfn << 12), 0x2000);
+}
+
+static int __devinit pasemi_mac_map_regs(struct pasemi_mac *mac)
+{
+	struct resource res;
+	struct device_node *dn;
+	int err;
+
+	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
+	if (!mac->dma_pdev) {
+		dev_err(&mac->pdev->dev, "Can't find DMA Controller\n");
+		return -ENODEV;
+	}
+
+	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
+	if (!mac->iob_pdev) {
+		dev_err(&mac->pdev->dev, "Can't find I/O Bridge\n");
+		return -ENODEV;
+	}
+
+	mac->regs = map_onedev(mac->pdev, 0);
+	mac->dma_regs = map_onedev(mac->dma_pdev, 0);
+	mac->iob_regs = map_onedev(mac->iob_pdev, 0);
+
+	if (!mac->regs || !mac->dma_regs || !mac->iob_regs) {
+		dev_err(&mac->pdev->dev, "Can't map registers\n");
+		return -ENODEV;
+	}
+
+	/* The dma status structure is located in the I/O bridge, and
+	 * is cache coherent.
+	 */
+	if (!dma_status) {
+		dn = pci_device_to_OF_node(mac->iob_pdev);
+		if (dn)
+			err = of_address_to_resource(dn, 1, &res);
+		if (!dn || err) {
+			/* Fallback for old firmware */
+			res.start = 0xfd800000;
+			res.end = res.start + 0x1000;
+		}
+		dma_status = __ioremap(res.start, res.end-res.start, 0);
+	}
+
+	return 0;
+}
+
 static int __devinit
 pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1104,21 +1161,6 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 
 	mac->pdev = pdev;
 	mac->netdev = dev;
-	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
-
-	if (!mac->dma_pdev) {
-		dev_err(&pdev->dev, "Can't find DMA Controller\n");
-		err = -ENODEV;
-		goto out_free_netdev;
-	}
-
-	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
-
-	if (!mac->iob_pdev) {
-		dev_err(&pdev->dev, "Can't find I/O Bridge\n");
-		err = -ENODEV;
-		goto out_put_dma_pdev;
-	}
 
 	/* These should come out of the device tree eventually */
 	mac->dma_txch = index;
@@ -1161,12 +1203,9 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	dev->poll = pasemi_mac_poll;
 	dev->features = NETIF_F_HW_CSUM;
 
-	/* The dma status structure is located in the I/O bridge, and
-	 * is cache coherent.
-	 */
-	if (!dma_status)
-		/* XXXOJN This should come from the device tree */
-		dma_status = __ioremap(0xfd800000, 0x1000, 0);
+	err = pasemi_mac_map_regs(mac);
+	if (err)
+		goto out;
 
 	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
 	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
@@ -1193,10 +1232,17 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	return err;
 
 out:
-	pci_dev_put(mac->iob_pdev);
-out_put_dma_pdev:
-	pci_dev_put(mac->dma_pdev);
-out_free_netdev:
+	if (mac->iob_pdev)
+		pci_dev_put(mac->iob_pdev);
+	if (mac->dma_pdev)
+		pci_dev_put(mac->dma_pdev);
+	if (mac->dma_regs)
+		iounmap(mac->dma_regs);
+	if (mac->iob_regs)
+		iounmap(mac->iob_regs);
+	if (mac->regs)
+		iounmap(mac->regs);
+
 	free_netdev(dev);
 out_disable_device:
 	pci_disable_device(pdev);
@@ -1220,6 +1266,10 @@ static void __devexit pasemi_mac_remove(
 	pci_dev_put(mac->dma_pdev);
 	pci_dev_put(mac->iob_pdev);
 
+	iounmap(mac->regs);
+	iounmap(mac->dma_regs);
+	iounmap(mac->iob_regs);
+
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 }
Index: mainline/drivers/net/pasemi_mac.h
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.h
+++ mainline/drivers/net/pasemi_mac.h
@@ -52,6 +52,9 @@ struct pasemi_mac_rxring {
 
 struct pasemi_mac {
 	struct net_device *netdev;
+	void __iomem *regs;
+	void __iomem *dma_regs;
+	void __iomem *iob_regs;
 	struct pci_dev *pdev;
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
