From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 4/11] r8169: enable MWI
Date: Tue, 24 Aug 2004 00:48:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823224813.GD20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823224706.GC20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


- enable Memory Write and Invalidate (disabled after reset);
- fix wrong goto.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-030 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-030	2004-08-23 23:30:00.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:00.000000000 +0200
@@ -32,7 +32,6 @@ VERSION 1.2	<2002/11/30>
 	- Use ether_crc in stock kernel (linux/crc32.h)
 	- Copy mc_filter setup code from 8139cp
 	  (includes an optimization, and avoids set_bit use)
-
 */
 
 #include <linux/module.h>
@@ -963,6 +962,10 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_free_dev;
 	}
 
+	rc = pci_set_mwi(pdev);
+	if (rc < 0)
+		goto err_out_disable;
+
 	/* save power state before pci_enable_device overwrites it */
 	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (pm_cap) {
@@ -973,7 +976,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	} else {
 		printk(KERN_ERR PFX
 		       "Cannot find PowerManagement capability, aborting.\n");
-		goto err_out_free_res;
+		goto err_out_mwi;
 	}
 
 	// make sure PCI base addr 1 is MMIO
@@ -981,20 +984,20 @@ rtl8169_init_board(struct pci_dev *pdev,
 		printk(KERN_ERR PFX
 		       "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
-		goto err_out_disable;
+		goto err_out_mwi;
 	}
 	// check for weird/broken PCI region reporting
 	if (pci_resource_len(pdev, 1) < R8169_REGS_SIZE) {
 		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
-		goto err_out_disable;
+		goto err_out_mwi;
 	}
 
 	rc = pci_request_regions(pdev, MODULENAME);
 	if (rc) {
 		printk(KERN_ERR PFX "%s: could not request regions.\n",
 		       pdev->slot_name);
-		goto err_out_disable;
+		goto err_out_mwi;
 	}
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
@@ -1011,7 +1014,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 
 
-	// enable PCI bus-mastering
 	pci_set_master(pdev);
 
 	// ioremap MMIO region 
@@ -1062,6 +1064,9 @@ out:
 err_out_free_res:
 	pci_release_regions(pdev);
 
+err_out_mwi:
+	pci_clear_mwi(pdev);
+
 err_out_disable:
 	pci_disable_device(pdev);
 

_
