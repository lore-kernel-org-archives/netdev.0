From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/10] tg3: Embrace pci_ioremap_bar()
Date: Fri, 21 Nov 2008 11:01:54 -0800
Message-ID: <1227295576.5622@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1305 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754341AbYKUT0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per Dave Miller's suggestion, replace the remaining ioremap_nocache()
call with pci_ioremap_bar().  Remove the two IORESOURCE_MEM checks as
they are redundant.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   21 +--------------------
 1 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2b70b0f..89d897d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13514,7 +13514,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	static int tg3_version_printed = 0;
-	resource_size_t tg3reg_len;
 	struct net_device *dev;
 	struct tg3 *tp;
 	int err, pm_cap;
@@ -13531,13 +13530,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		return err;
 	}
 
-	if (!(pci_resource_flags(pdev, BAR_0) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX "Cannot find proper PCI device "
-		       "base address, aborting.\n");
-		err = -ENODEV;
-		goto err_out_disable_pdev;
-	}
-
 	err = pci_request_regions(pdev, DRV_MODULE_NAME);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
@@ -13606,11 +13598,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task);
 
-	dev->mem_start = pci_resource_start(pdev, BAR_0);
-	tg3reg_len = pci_resource_len(pdev, BAR_0);
-	dev->mem_end = dev->mem_start + tg3reg_len;
-
-	tp->regs = ioremap_nocache(dev->mem_start, tg3reg_len);
+	tp->regs = pci_ioremap_bar(pdev, BAR_0);
 	if (!tp->regs) {
 		printk(KERN_ERR PFX "Cannot map device registers, "
 		       "aborting.\n");
@@ -13733,13 +13721,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	}
 
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
-		if (!(pci_resource_flags(pdev, BAR_2) & IORESOURCE_MEM)) {
-			printk(KERN_ERR PFX "Cannot find proper PCI device "
-			       "base address for APE, aborting.\n");
-			err = -ENODEV;
-			goto err_out_iounmap;
-		}
-
 		tp->aperegs = pci_ioremap_bar(pdev, BAR_2);
 		if (!tp->aperegs) {
 			printk(KERN_ERR PFX "Cannot map APE registers, "
-- 
1.5.6.4



