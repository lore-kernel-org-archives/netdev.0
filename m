From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: [PATCH] ne2k+8390 in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 21:27:57 +0800
Message-ID: <001801d01c58$c4c1f650$4e45e2f0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:52174 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbaLTN2C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 08:28:02 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have actually tested ne2k+8390 driver on the real hardware(Realtek RTL8029
PCI Ethernet Controller), and find some potential bugs:
The target file is drivers/net/ethernet/8390/ne2k-pci.c, which is used to
build ne2k-pci.ko.

(1) The function request_region is called by ne2k_pci_init_one when
initializing the ethernet card driver. But when request_region is failed,
which means that it returns the error value, ne2k_pci_init_one returns
immediately to halt the process. However, because pci_enable_device has been
called before request_region in ne2k_pci_init_one, pci_disable_device should
be called before exiting. When the driver works normally, pci_enable_device
and pci_disable_device are called in pairs in ne2k_pci_init_one and
ne2k_pci_remove_one. Moreover, other ethernet card drivers call
pci_enable_device and pci_disable_device in pairs in error handling paths,
such as r8169 and sky2.
(2) The similar problem occurs when alloc_ei_netdev is failed in
ne2k_pci_init_one.
(3) The similar problem occurs when register_netdev is failed in
ne2k_pci_init_one.


Meanwhile, I also write the patch to fix the bugs. I have run the patch on
the hardware, it can work normally and fix the above bugs.

diff --git a/drivers/net/ethernet/8390/ne2k-pci.c
b/drivers/net/ethernet/8390/ne2k-pci.c
index 89c8d9f..f241c6b 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -246,13 +246,13 @@ static int ne2k_pci_init_one(struct pci_dev *pdev,
 
 	if (!ioaddr || ((pci_resource_flags (pdev, 0) & IORESOURCE_IO) ==
0)) {
 		dev_err(&pdev->dev, "no I/O resource at PCI BAR #0\n");
-		return -ENODEV;
+		goto err_out;
 	}
 
 	if (request_region (ioaddr, NE_IO_EXTENT, DRV_NAME) == NULL) {
 		dev_err(&pdev->dev, "I/O resource 0x%x @ 0x%lx busy\n",
 			NE_IO_EXTENT, ioaddr);
-		return -EBUSY;
+		goto err_out;
 	}
 
 	reg0 = inb(ioaddr);
@@ -392,6 +392,8 @@ err_out_free_netdev:
 	free_netdev (dev);
 err_out_free_res:
 	release_region (ioaddr, NE_IO_EXTENT);
+err_out:
+	pci_disable_device (pdev);
 	return -ENODEV;
 }


Thanks!
