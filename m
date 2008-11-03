From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/15] tg3: Use pci_ioremap_bar()
Date: Mon, 3 Nov 2008 02:10:35 -0800
Message-ID: <1225751618.6169@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2837 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756520AbYKCWdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the existing APE register mapping code with a call
to pci_ioremap_bar().  The code that maps the main device register space
did not undergo a similar change because the information derived from
the pci_resource_start() and pci_resource_len() is still used to
populate the (optional) mem_start and mem_end netdevice members.
Replace hardcoded constants where appropriate.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b47e8a1..e129a6a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -54,6 +54,9 @@
 #include <asm/prom.h>
 #endif
 
+#define BAR_0	0
+#define BAR_2	2
+
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define TG3_VLAN_TAG_USED 1
 #else
@@ -13247,8 +13250,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	static int tg3_version_printed = 0;
-	resource_size_t tg3reg_base;
-	unsigned long tg3reg_len;
+	resource_size_t tg3reg_len;
 	struct net_device *dev;
 	struct tg3 *tp;
 	int err, pm_cap;
@@ -13265,7 +13267,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		return err;
 	}
 
-	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+	if (!(pci_resource_flags(pdev, BAR_0) & IORESOURCE_MEM)) {
 		printk(KERN_ERR PFX "Cannot find proper PCI device "
 		       "base address, aborting.\n");
 		err = -ENODEV;
@@ -13290,9 +13292,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	tg3reg_base = pci_resource_start(pdev, 0);
-	tg3reg_len = pci_resource_len(pdev, 0);
-
 	dev = alloc_etherdev(sizeof(*tp));
 	if (!dev) {
 		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
@@ -13344,7 +13343,11 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task);
 
-	tp->regs = ioremap_nocache(tg3reg_base, tg3reg_len);
+	dev->mem_start = pci_resource_start(pdev, BAR_0);
+	tg3reg_len = pci_resource_len(pdev, BAR_0);
+	dev->mem_end = dev->mem_start + tg3reg_len;
+
+	tp->regs = ioremap_nocache(dev->mem_start, tg3reg_len);
 	if (!tp->regs) {
 		printk(KERN_ERR PFX "Cannot map device registers, "
 		       "aborting.\n");
@@ -13467,17 +13470,14 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	}
 
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
-		if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
+		if (!(pci_resource_flags(pdev, BAR_2) & IORESOURCE_MEM)) {
 			printk(KERN_ERR PFX "Cannot find proper PCI device "
 			       "base address for APE, aborting.\n");
 			err = -ENODEV;
 			goto err_out_iounmap;
 		}
 
-		tg3reg_base = pci_resource_start(pdev, 2);
-		tg3reg_len = pci_resource_len(pdev, 2);
-
-		tp->aperegs = ioremap_nocache(tg3reg_base, tg3reg_len);
+		tp->aperegs = pci_ioremap_bar(pdev, BAR_2);
 		if (!tp->aperegs) {
 			printk(KERN_ERR PFX "Cannot map APE registers, "
 			       "aborting.\n");
-- 
1.5.6.4



