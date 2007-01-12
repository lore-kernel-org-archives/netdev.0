From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Thu, 11 Jan 2007 22:52:04 -0600
Message-ID: <45a713f4.CVklfeegOYfmrIW+%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI-E modifications to bcm43xx do not set up the interrupt vector
correctly.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This fix should be applied to wireless-2.6 _AND_ pushed upstream to
2.6.20-rcX. Without this patch, none of the PCI-E interfaces will work.

Larry


Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2704,7 +2704,7 @@ static int bcm43xx_probe_cores(struct bc
 		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
 		/* extract core_id, core_rev, core_vendor */
-		core_id = (sb_id_hi & 0xFFF0) >> 4;
+		core_id = (sb_id_hi & 0x8FF0) >> 4;
 		core_rev = (sb_id_hi & 0xF);
 		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
@@ -2717,7 +2717,7 @@ static int bcm43xx_probe_cores(struct bc
 		case BCM43xx_COREID_PCIE:
 			core = &bcm->core_pci;
 			if (core->available) {
-				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
+				printk(KERN_WARNING PFX "Multiple PCI/PCI-E cores found.\n");
 				continue;
 			}
 			break;
@@ -2872,11 +2872,14 @@ static int bcm43xx_wireless_core_init(st
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id != BCM43xx_COREID_PCIE) {
+	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id == BCM43xx_COREID_PCI) {
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		sbimconfiglow |= 0x32;
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
+			sbimconfiglow |= 0x32;
+		else
+			sbimconfiglow |= 0x53;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 
@@ -3070,6 +3073,7 @@ static int bcm43xx_setup_backplane_pci_c
 	u32 backplane_flag_nr;
 	u32 value;
 	struct bcm43xx_coreinfo *old_core;
+	struct bcm43xx_coreinfo *pci_core = &bcm->core_pci ;
 	int err = 0;
 
 	value = bcm43xx_read32(bcm, BCM43xx_CIR_SBTPSFLAG);
@@ -3080,26 +3084,22 @@ static int bcm43xx_setup_backplane_pci_c
 	if (err)
 		goto out;
 
-	if (bcm->current_core->rev < 6 ||
-		bcm->current_core->id == BCM43xx_COREID_PCI) {
-		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
-		value |= (1 << backplane_flag_nr);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
-	} else {
+	if ((pci_core->rev >= 6) || (pci_core->id == BCM43xx_COREID_PCIE)) {
 		err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCICFG_ICR, &value);
-		if (err) {
-			printk(KERN_ERR PFX "Error: ICR setup failure!\n");
+		if (err)
 			goto out_switch_back;
-		}
 		value |= core_mask << 8;
 		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_ICR, value);
-		if (err) {
-			printk(KERN_ERR PFX "Error: ICR setup failure!\n");
+		if (err)
 			goto out_switch_back;
-		}
+	} else {
+                err = -EINVAL;
+                value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
+		value |= 1 << backplane_flag_nr;
+                bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
 	}
 
-	if (bcm->current_core->id == BCM43xx_COREID_PCI) {
+	if (pci_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
 		value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
 		bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
@@ -3118,21 +3118,21 @@ static int bcm43xx_setup_backplane_pci_c
 			value |= BCM43xx_SBTOPCI2_MEMREAD_MULTI;
 			bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
 		}
-	} else {
-		if (bcm->current_core->rev == 0 || bcm->current_core->rev == 1) {
+	} else if (pci_core->id == BCM43xx_COREID_PCIE) {
+		if (pci_core->rev == 0 || pci_core->rev == 1) {
 			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_TLP_WORKAROUND);
 			value |= 0x8;
 			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_TLP_WORKAROUND,
 					       value);
 		}
-		if (bcm->current_core->rev == 0) {
+		if (pci_core->rev == 0) {
 			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
 						BCM43xx_SERDES_RXTIMER, 0x8128);
 			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
 						BCM43xx_SERDES_CDR, 0x0100);
 			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
 						BCM43xx_SERDES_CDR_BW, 0x1466);
-		} else if (bcm->current_core->rev == 1) {
+		} else if (pci_core->rev == 1) {
 			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_DLLP_LINKCTL);
 			value |= 0x40;
 			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_DLLP_LINKCTL,
@@ -3141,6 +3141,7 @@ static int bcm43xx_setup_backplane_pci_c
 	}
 out_switch_back:
 	err = bcm43xx_switch_core(bcm, old_core);
+	printk(KERN_ERR PFX "Error: ICR setup failure!\n");
 out:
 	return err;
 }

---
