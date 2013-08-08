From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] net/tg3: Support shutdown on PCI device
Date: Thu,  8 Aug 2013 15:26:09 +0800
Message-ID: <1375946769-22814-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: nsujir@broadcom.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:35470 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215Ab3HHH0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 03:26:24 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 8 Aug 2013 03:26:23 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A1F816E803C
	for <netdev@vger.kernel.org>; Thu,  8 Aug 2013 03:26:14 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r787QJLZ38993920
	for <netdev@vger.kernel.org>; Thu, 8 Aug 2013 03:26:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r787QIOW030617
	for <netdev@vger.kernel.org>; Thu, 8 Aug 2013 03:26:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before we tries to load new kernel with "kexec", we cound't bring
the tg3 NICs down manually because dhcp daemon keeps them up. So
there're still lots of traffic (DMA operations) on the tg3 card
from the old kernel while running the new kernel. It leads to
unnecessary EEH errors on Power platform because the network traffic
(from old kernel) breaks what we have in the IOMMU, which is built
by the new kernel.

	ifconfig eth0 down
	kexec -l vmlinux -c "root=/dev/sda5 debug" && kexec -f -e

The patch adds the shutdown interface for the PCI device to make
things more robust. The PCI device can be put to silent state before
loading the new kernel and to avoid unnecessary EEH errors.

Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ddebc7a..dc6178b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17663,6 +17663,17 @@ static void tg3_remove_one(struct pci_dev *pdev)
 	}
 }
 
+static void tg3_shutdown_one(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (!dev)
+		return;
+
+	netif_device_detach(dev);
+	tg3_remove_one(pdev);
+}
+
 #ifdef CONFIG_PM_SLEEP
 static int tg3_suspend(struct device *device)
 {
@@ -17909,6 +17920,7 @@ static struct pci_driver tg3_driver = {
 	.id_table	= tg3_pci_tbl,
 	.probe		= tg3_init_one,
 	.remove		= tg3_remove_one,
+	.shutdown	= tg3_shutdown_one,
 	.err_handler	= &tg3_err_handler,
 	.driver.pm	= &tg3_pm_ops,
 };
-- 
1.7.5.4
