From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] netdev: fix compile issues for !CONFIG_PCI in 3c59x
Date: Sun, 25 Mar 2012 21:11:46 -0400
Message-ID: <1332724306-8799-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64920 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695Ab2CZBMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 21:12:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I hate to add in more #ifdef CONFIG_PCI but there are already
quite a few in this driver, and it seems like it hasn't been
built with CONFIG_PCI set to off in quite some time.  The
MIPS allmodconfig (ISA/EISA based) doesn't set CONFIG_PCI
and that is why we are here looking at this, even though any
modern platform has had PCI since 1995 or so.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index e463d10..36ad150 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -999,6 +999,7 @@ static int __init vortex_eisa_init(void)
 	return vortex_cards_found - orig_cards_found + eisa_found;
 }
 
+#ifdef CONFIG_PCI
 /* returns count (>= 0), or negative on error */
 static int __devinit vortex_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
@@ -1045,6 +1046,7 @@ static int __devinit vortex_init_one(struct pci_dev *pdev,
 out:
 	return rc;
 }
+#endif
 
 static const struct net_device_ops boomrang_netdev_ops = {
 	.ndo_open		= vortex_open,
@@ -1177,6 +1179,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 		compaq_net_device = dev;
 	}
 
+#ifdef CONFIG_PCI
 	/* PCI-only startup logic */
 	if (pdev) {
 		/* EISA resources already marked, so only PCI needs to do this here */
@@ -1204,6 +1207,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 			}
 		}
 	}
+#endif
 
 	spin_lock_init(&vp->lock);
 	spin_lock_init(&vp->mii_lock);
@@ -1321,7 +1325,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 			step, (eeprom[4]>>5) & 15, eeprom[4] & 31, eeprom[4]>>9);
 	}
 
-
+#ifdef CONFIG_PCI
 	if (pdev && vci->drv_flags & HAS_CB_FNS) {
 		unsigned short n;
 
@@ -1348,6 +1352,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 			window_write16(vp, 0x0800, 0, 0);
 		}
 	}
+#endif
 
 	/* Extract our information from the EEPROM data. */
 	vp->info1 = eeprom[13];
@@ -3222,6 +3227,7 @@ static void acpi_set_WOL(struct net_device *dev)
 }
 
 
+#ifdef CONFIG_PCI
 static void __devexit vortex_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -3269,6 +3275,7 @@ static struct pci_driver vortex_driver = {
 	.id_table	= vortex_pci_tbl,
 	.driver.pm	= VORTEX_PM_OPS,
 };
+#endif
 
 
 static int vortex_have_pci;
@@ -3277,9 +3284,13 @@ static int vortex_have_eisa;
 
 static int __init vortex_init(void)
 {
-	int pci_rc, eisa_rc;
+	int eisa_rc;
+#ifdef CONFIG_PCI
+	int pci_rc = pci_register_driver(&vortex_driver);
+#else
+	int pci_rc = -ENODEV;
+#endif
 
-	pci_rc = pci_register_driver(&vortex_driver);
 	eisa_rc = vortex_eisa_init();
 
 	if (pci_rc == 0)
@@ -3318,8 +3329,10 @@ static void __exit vortex_eisa_cleanup(void)
 
 static void __exit vortex_cleanup(void)
 {
+#ifdef CONFIG_PCI
 	if (vortex_have_pci)
 		pci_unregister_driver(&vortex_driver);
+#endif
 	if (vortex_have_eisa)
 		vortex_eisa_cleanup();
 }
-- 
1.7.9.4
