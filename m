From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v3] ne2k-pci: Add pci_disable_device in error handling
Date: Tue, 23 Dec 2014 11:29:03 +0800
Message-ID: <1419305343-29032-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: davem@davemloft.net, bhelgaas@google.com, benoit.taine@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:56171 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753728AbaLWD3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 22:29:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For linux-3.18.0
The driver lacks pci_disable_device in error handling code of
ne2k_pci_init_one, so the device enabled by pci_enable_device is not
disabled when errors occur.
This patch fixes this problem.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/8390/ne2k-pci.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 89c8d9f..160c161 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -246,13 +246,13 @@ static int ne2k_pci_init_one(struct pci_dev *pdev,
 
 	if (!ioaddr || ((pci_resource_flags (pdev, 0) & IORESOURCE_IO) == 0)) {
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
+	pci_disable_device(pdev);
 	return -ENODEV;
 }
 
-- 
1.7.9.5
