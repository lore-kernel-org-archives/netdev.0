From: Ralf Baechle <ralf@linux-mips.org>
Subject: [IOC3] Switch to pci refcounting safe APIs
Date: Tue, 10 Jul 2007 17:05:16 +0100
Message-ID: <20070710160516.GA25176@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:35064 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315AbXGJQQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 12:16:03 -0400
Received: from localhost.localdomain ([127.0.0.1]:10468 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021686AbXGJQQC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 17:16:02 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From:	Alan Cox <alan@lxorguk.ukuu.org.uk>

Convert the IOC3 driver to use ref counting pci interfaces so that we can
obsolete the (usually unsafe) pci_find_{slot/device} interfaces and avoid
future authors writing hotplug-unsafe device drivers.

Signed-off-by: Alan Cox <alan@redhat.com>

Build fixes:
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Index: upstream-linus/drivers/net/ioc3-eth.c
===================================================================
--- upstream-linus.orig/drivers/net/ioc3-eth.c
+++ upstream-linus/drivers/net/ioc3-eth.c
@@ -352,13 +352,12 @@ static u64 nic_find(struct ioc3 *ioc3, i
 
 static int nic_init(struct ioc3 *ioc3)
 {
-	const char *type;
+	const char *unknown = "unknown";
+	const char *type = unknown;
 	u8 crc;
 	u8 serial[6];
 	int save = 0, i;
 
-	type = "unknown";
-
 	while (1) {
 		u64 reg;
 		reg = nic_find(ioc3, &save);
@@ -392,7 +391,7 @@ static int nic_init(struct ioc3 *ioc3)
 	}
 
 	printk("Found %s NIC", type);
-	if (type != "unknown") {
+	if (type != unknown) {
 		printk (" registration number %02x:%02x:%02x:%02x:%02x:%02x,"
 			" CRC %02x", serial[0], serial[1], serial[2],
 			serial[3], serial[4], serial[5], crc);
@@ -1103,20 +1102,28 @@ static int ioc3_close(struct net_device 
  * MiniDINs; all other subdevices are left swinging in the wind, leave
  * them disabled.
  */
-static inline int ioc3_is_menet(struct pci_dev *pdev)
+
+static int ioc3_adjacent_is_ioc3(struct pci_dev *pdev, int slot)
 {
-	struct pci_dev *dev;
+	struct pci_dev *dev = pci_get_slot(pdev->bus, PCI_DEVFN(slot, 0));
+	int ret = 0;
+
+	if (dev) {
+		if (dev->vendor == PCI_VENDOR_ID_SGI &&
+			dev->device == PCI_DEVICE_ID_SGI_IOC3)
+			ret = 1;
+		pci_dev_put(dev);
+	}
 
-	return pdev->bus->parent == NULL
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(0, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(1, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3
-	       && (dev = pci_find_slot(pdev->bus->number, PCI_DEVFN(2, 0)))
-	       && dev->vendor == PCI_VENDOR_ID_SGI
-	       && dev->device == PCI_DEVICE_ID_SGI_IOC3;
+	return ret;
+}
+
+static int ioc3_is_menet(struct pci_dev *pdev)
+{
+	return pdev->bus->parent == NULL &&
+	       ioc3_adjacent_is_ioc3(pdev, 0) &&
+	       ioc3_adjacent_is_ioc3(pdev, 1) &&
+	       ioc3_adjacent_is_ioc3(pdev, 2);
 }
 
 #ifdef CONFIG_SERIAL_8250
