From: Daniel Drake <dsd@gentoo.org>
Subject: [RFT] Realtek 8168 ethernet support
Date: Thu,  1 Jun 2006 21:02:00 +0100 (BST)
Message-ID: <20060601200200.A0E0689D05D@zog.reactivated.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:37558 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030258AbWFAUB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 16:01:59 -0400
Received: from aamtaout03-winn.ispmail.ntl.com ([81.103.221.35])
          by mtaout03-winn.ispmail.ntl.com with ESMTP
          id <20060601200154.IFGJ27969.mtaout03-winn.ispmail.ntl.com@aamtaout03-winn.ispmail.ntl.com>
          for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 21:01:54 +0100
Received: from zog.reactivated.net ([86.14.216.162])
          by aamtaout03-winn.ispmail.ntl.com with ESMTP
          id <20060601200154.UHBY16286.aamtaout03-winn.ispmail.ntl.com@zog.reactivated.net>
          for <netdev@vger.kernel.org>; Thu, 1 Jun 2006 21:01:54 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've produced this patch which should allow the r8169 driver to work with the
new Realtek 8168 chips. These are found in PCI-Express form and onboard some
newer motherboards.

Does anyone own this hardware? I'm looking for someone to test it before I
send it on.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/r8169.c
===================================================================
--- linux.orig/drivers/net/r8169.c
+++ linux/drivers/net/r8169.c
@@ -184,6 +184,7 @@ static const struct {
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), },
 	{ PCI_DEVICE(0x16ec,			0x0116), },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032, PCI_ANY_ID, 0x0024, },
@@ -1398,6 +1399,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	struct net_device *dev;
 	struct rtl8169_private *tp;
 	int rc = -ENOMEM, i, acpi_idle_state = 0, pm_cap;
+	u32 mmio_base = 0;
 
 	assert(ioaddr_out != NULL);
 
@@ -1442,20 +1444,24 @@ rtl8169_init_board(struct pci_dev *pdev,
 		}
 	}
 
-	/* make sure PCI base addr 1 is MMIO */
-	if (!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		if (netif_msg_probe(tp)) {
-			printk(KERN_ERR PFX
-			       "region #1 not an MMIO resource, aborting\n");
-		}
-		rc = -ENODEV;
-		goto err_out_mwi;
+	/* find MMIO resource: this varies between 8168 and 8169 */
+	for (i = 0; i < 5; i++) {
+		/* check resource type */
+		if (!(pci_resource_flags(pdev, i) & IORESOURCE_MEM))
+			continue;
+
+		/* check for weird/broken PCI region reporting */
+		if (pci_resource_len(pdev, i) < R8169_REGS_SIZE)
+			continue;
+
+		mmio_base = pci_resource_start(pdev, i);
+		break;
 	}
-	/* check for weird/broken PCI region reporting */
-	if (pci_resource_len(pdev, 1) < R8169_REGS_SIZE) {
+
+	if (mmio_base == 0) {
 		if (netif_msg_probe(tp)) {
 			printk(KERN_ERR PFX
-			       "Invalid PCI region size(s), aborting\n");
+			       "couldn't find valid MMIO resource, aborting\n");
 		}
 		rc = -ENODEV;
 		goto err_out_mwi;
@@ -1490,7 +1496,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	/* ioremap MMIO region */
-	ioaddr = ioremap(pci_resource_start(pdev, 1), R8169_REGS_SIZE);
+	ioaddr = ioremap(mmio_base, R8169_REGS_SIZE);
 	if (ioaddr == NULL) {
 		if (netif_msg_probe(tp))
 			printk(KERN_ERR PFX "cannot remap MMIO, aborting\n");
