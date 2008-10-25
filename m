From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] [PCI] move ICHx GbE NVM write-protection from e1000e to PCI
	quirk
Date: Fri, 24 Oct 2008 18:13:58 -0700
Message-ID: <20081025011358.9975.77556.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	jbarnes@virtuousgeek.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:33363 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751215AbYJYBOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 21:14:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The write-protection method being in the driver probe routine is called
late in the boot sequence, and not at all if the driver is never loaded.
By making it a PCI quirk the NVM is protected much earlier whether or not
the driver is loaded.  The write-protection quirk can be disabled with a
new kernel parameter in the unlikely event the NVM needs to be modified.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/kernel-parameters.txt |    4 +
 drivers/net/Makefile                |    1 
 drivers/net/e1000e/Makefile         |    1 
 drivers/net/e1000e/e1000.h          |    1 
 drivers/net/e1000e/ethtool.c        |    6 +
 drivers/net/e1000e/ich8lan.c        |   93 +++-----------------
 drivers/net/e1000e/ich8lan.h        |   68 +++++++++++++++
 drivers/net/e1000e/netdev.c         |    4 -
 drivers/net/e1000e/param.c          |   30 ------
 drivers/net/e1000e/quirks.c         |  162 +++++++++++++++++++++++++++++++++++
 10 files changed, 256 insertions(+), 114 deletions(-)
 create mode 100644 drivers/net/e1000e/ich8lan.h
 create mode 100644 drivers/net/e1000e/quirks.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1150444..de0134b 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2274,6 +2274,10 @@ and is between 256 and 4096 characters. It is defined in the file
 	norandmaps	Don't use address space randomization
 			Equivalent to echo 0 > /proc/sys/kernel/randomize_va_space
 
+	ichlan_protect=	[KNL] Intel ICHx GbE NVM write-protection
+			Format: { enable (default) | disable }
+			disable: disable NVM write protection
+
 ______________________________________________________________________
 
 TODO:
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fa2510b..fc4f1cf 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_E1000) += e1000/
 obj-$(CONFIG_E1000E) += e1000e/
+obj-y += e1000e/
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
 obj-$(CONFIG_IGB) += igb/
 obj-$(CONFIG_IXGBE) += ixgbe/
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/e1000e/Makefile
index 360c913..a3eb70c 100644
--- a/drivers/net/e1000e/Makefile
+++ b/drivers/net/e1000e/Makefile
@@ -35,3 +35,4 @@ obj-$(CONFIG_E1000E) += e1000e.o
 e1000e-objs := 82571.o ich8lan.o es2lan.o \
 	       lib.o phy.o param.o ethtool.o netdev.o
 
+obj-y += quirks.o
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c55de1c..ee4bfa2 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -408,7 +408,6 @@ extern bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw);
 extern bool e1000e_get_laa_state_82571(struct e1000_hw *hw);
 extern void e1000e_set_laa_state_82571(struct e1000_hw *hw, bool state);
 
-extern void e1000e_write_protect_nvm_ich8lan(struct e1000_hw *hw);
 extern void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 						 bool state);
 extern void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 70c11c8..00b8394 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -533,8 +533,12 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	if (eeprom->magic != (adapter->pdev->vendor | (adapter->pdev->device << 16)))
 		return -EFAULT;
 
-	if (adapter->flags & FLAG_READ_ONLY_NVM)
+	if (adapter->flags & FLAG_READ_ONLY_NVM) {
+		e_info("NVM is read-only. Reboot with 'ichlan_protect=disable' "
+		       "only if you absolutely *must* change the EEPROM/NVM, "
+		       "otherwise leave it read-only to prevent corruption.\n");
 		return -EINVAL;
+	}
 
 	max_len = hw->nvm.word_size * 2;
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 523b971..a9a2506 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -54,13 +54,11 @@
 #include <linux/pci.h>
 
 #include "e1000.h"
+#include "ich8lan.h"
 
-#define ICH_FLASH_GFPREG		0x0000
-#define ICH_FLASH_HSFSTS		0x0004
 #define ICH_FLASH_HSFCTL		0x0006
 #define ICH_FLASH_FADDR			0x0008
 #define ICH_FLASH_FDATA0		0x0010
-#define ICH_FLASH_PR0			0x0074
 
 #define ICH_FLASH_READ_COMMAND_TIMEOUT	500
 #define ICH_FLASH_WRITE_COMMAND_TIMEOUT	500
@@ -72,7 +70,6 @@
 #define ICH_CYCLE_WRITE			2
 #define ICH_CYCLE_ERASE			3
 
-#define FLASH_GFPREG_BASE_MASK		0x1FFF
 #define FLASH_SECTOR_ADDR_SHIFT		12
 
 #define ICH_FLASH_SEG_SIZE_256		256
@@ -112,23 +109,6 @@
 #define IGP3_VR_CTRL_DEV_POWERDOWN_MODE_MASK 0x0300
 #define IGP3_VR_CTRL_MODE_SHUTDOWN	0x0200
 
-/* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
-/* Offset 04h HSFSTS */
-union ich8_hws_flash_status {
-	struct ich8_hsfsts {
-		u16 flcdone    :1; /* bit 0 Flash Cycle Done */
-		u16 flcerr     :1; /* bit 1 Flash Cycle Error */
-		u16 dael       :1; /* bit 2 Direct Access error Log */
-		u16 berasesz   :2; /* bit 4:3 Sector Erase Size */
-		u16 flcinprog  :1; /* bit 5 flash cycle in Progress */
-		u16 reserved1  :2; /* bit 13:6 Reserved */
-		u16 reserved2  :6; /* bit 13:6 Reserved */
-		u16 fldesvalid :1; /* bit 14 Flash Descriptor Valid */
-		u16 flockdn    :1; /* bit 15 Flash Config Lock-Down */
-	} hsf_status;
-	u16 regval;
-};
-
 /* ICH GbE Flash Hardware Sequencing Flash control Register bit breakdown */
 /* Offset 06h FLCTL */
 union ich8_hws_flash_ctrl {
@@ -153,19 +133,6 @@ union ich8_hws_flash_regacc {
 	u16 regval;
 };
 
-/* ICH Flash Protected Region */
-union ich8_flash_protected_range {
-	struct ich8_pr {
-		u32 base:13;     /* 0:12 Protected Range Base */
-		u32 reserved1:2; /* 13:14 Reserved */
-		u32 rpe:1;       /* 15 Read Protection Enable */
-		u32 limit:13;    /* 16:28 Protected Range Limit */
-		u32 reserved2:2; /* 29:30 Reserved */
-		u32 wpe:1;       /* 31 Write Protection Enable */
-	} range;
-	u32 regval;
-};
-
 static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw);
 static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw);
 static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw);
@@ -364,6 +331,9 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	union ich8_flash_protected_range pr0;
+	union ich8_hws_flash_status hsfsts;
+	u32 gfpreg;
 	s32 rc;
 
 	rc = e1000_init_mac_params_ich8lan(adapter);
@@ -382,6 +352,17 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	    (adapter->hw.phy.type == e1000_phy_igp_3))
 		adapter->flags |= FLAG_LSC_GIG_SPEED_DROP;
 
+	/* Check if GbE Sector of NVM is Write-protected */
+	gfpreg = er32flash(ICH_FLASH_GFPREG);
+	pr0.regval = er32flash(ICH_FLASH_PR0);
+	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
+
+	if ((pr0.range.base == (gfpreg & FLASH_GFPREG_BASE_MASK)) &&
+	    (pr0.range.limit == ((gfpreg >> 16) & FLASH_GFPREG_BASE_MASK)) &&
+	    (pr0.range.wpe == true) &&
+	    (hsfsts.hsf_status.flockdn == true))
+		adapter->flags |= FLAG_READ_ONLY_NVM;
+
 	return 0;
 }
 
@@ -1417,7 +1398,6 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 * programming failed.
 	 */
 	if (ret_val) {
-		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
 		hw_dbg(hw, "Flash commit failed.\n");
 		e1000_release_swflag_ich8lan(hw);
 		return ret_val;
@@ -1508,49 +1488,6 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_write_protect_nvm_ich8lan - Make the NVM read-only
- *  @hw: pointer to the HW structure
- *
- *  To prevent malicious write/erase of the NVM, set it to be read-only
- *  so that the hardware ignores all write/erase cycles of the NVM via
- *  the flash control registers.  The shadow-ram copy of the NVM will
- *  still be updated, however any updates to this copy will not stick
- *  across driver reloads.
- **/
-void e1000e_write_protect_nvm_ich8lan(struct e1000_hw *hw)
-{
-	union ich8_flash_protected_range pr0;
-	union ich8_hws_flash_status hsfsts;
-	u32 gfpreg;
-	s32 ret_val;
-
-	ret_val = e1000_acquire_swflag_ich8lan(hw);
-	if (ret_val)
-		return;
-
-	gfpreg = er32flash(ICH_FLASH_GFPREG);
-
-	/* Write-protect GbE Sector of NVM */
-	pr0.regval = er32flash(ICH_FLASH_PR0);
-	pr0.range.base = gfpreg & FLASH_GFPREG_BASE_MASK;
-	pr0.range.limit = ((gfpreg >> 16) & FLASH_GFPREG_BASE_MASK);
-	pr0.range.wpe = true;
-	ew32flash(ICH_FLASH_PR0, pr0.regval);
-
-	/*
-	 * Lock down a subset of GbE Flash Control Registers, e.g.
-	 * PR0 to prevent the write-protection from being lifted.
-	 * Once FLOCKDN is set, the registers protected by it cannot
-	 * be written until FLOCKDN is cleared by a hardware reset.
-	 */
-	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-	hsfsts.hsf_status.flockdn = true;
-	ew32flash(ICH_FLASH_HSFSTS, hsfsts.regval);
-
-	e1000_release_swflag_ich8lan(hw);
-}
-
-/**
  *  e1000_write_flash_data_ich8lan - Writes bytes to the NVM
  *  @hw: pointer to the HW structure
  *  @offset: The offset (in bytes) of the byte/word to read.
diff --git a/drivers/net/e1000e/ich8lan.h b/drivers/net/e1000e/ich8lan.h
new file mode 100644
index 0000000..13c73f5
--- /dev/null
+++ b/drivers/net/e1000e/ich8lan.h
@@ -0,0 +1,68 @@
+/*******************************************************************************
+
+  Intel PRO/1000 Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _ICH8LAN_H_
+#define _ICH8LAN_H_
+
+#define ICH_FLASH_GFPREG                 0x0000
+#define ICH_FLASH_HSFSTS                 0x0004
+#define ICH_FLASH_PR0                    0x0074
+
+#define FLASH_GFPREG_BASE_MASK           0x1FFF
+
+/* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
+/* Offset 04h HSFSTS */
+union ich8_hws_flash_status {
+	struct ich8_hsfsts {
+		u16 flcdone    :1; /* bit 0 Flash Cycle Done */
+		u16 flcerr     :1; /* bit 1 Flash Cycle Error */
+		u16 dael       :1; /* bit 2 Direct Access error Log */
+		u16 berasesz   :2; /* bit 4:3 Sector Erase Size */
+		u16 flcinprog  :1; /* bit 5 flash cycle in Progress */
+		u16 reserved1  :2; /* bit 13:6 Reserved */
+		u16 reserved2  :6; /* bit 13:6 Reserved */
+		u16 fldesvalid :1; /* bit 14 Flash Descriptor Valid */
+		u16 flockdn    :1; /* bit 15 Flash Config Lock-Down */
+	} hsf_status;
+	u16 regval;
+};
+
+/* ICH Flash Protected Region */
+union ich8_flash_protected_range {
+	struct ich8_pr {
+		u32 base:13;     /* 0:12 Protected Range Base */
+		u32 reserved1:2; /* 13:14 Reserved */
+		u32 rpe:1;       /* 15 Read Protection Enable */
+		u32 limit:13;    /* 16:28 Protected Range Limit */
+		u32 reserved2:2; /* 29:30 Reserved */
+		u32 wpe:1;       /* 31 Write Protection Enable */
+	} range;
+	u32 regval;
+};
+
+#endif
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1b72749..f361d9e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4814,10 +4814,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_hw_init;
 
-	if ((adapter->flags & FLAG_IS_ICH) &&
-	    (adapter->flags & FLAG_READ_ONLY_NVM))
-		e1000e_write_protect_nvm_ich8lan(&adapter->hw);
-
 	hw->mac.ops.get_bus_info(&adapter->hw);
 
 	adapter->hw.phy.autoneg_wait_to_complete = 0;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 77a3d72..f46db6c 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -142,15 +142,6 @@ E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
  */
 E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
 
-/*
- * Write Protect NVM
- *
- * Valid Range: 0, 1
- *
- * Default Value: 1 (enabled)
- */
-E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lead to corrupted NVM]");
-
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;
@@ -424,25 +415,4 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 								       opt.def);
 		}
 	}
-	{ /* Write-protect NVM */
-		const struct e1000_option opt = {
-			.type = enable_option,
-			.name = "Write-protect NVM",
-			.err  = "defaulting to Enabled",
-			.def  = OPTION_ENABLED
-		};
-
-		if (adapter->flags & FLAG_IS_ICH) {
-			if (num_WriteProtectNVM > bd) {
-				unsigned int write_protect_nvm = WriteProtectNVM[bd];
-				e1000_validate_option(&write_protect_nvm, &opt,
-						      adapter);
-				if (write_protect_nvm)
-					adapter->flags |= FLAG_READ_ONLY_NVM;
-			} else {
-				if (opt.def)
-					adapter->flags |= FLAG_READ_ONLY_NVM;
-			}
-		}
-	}
 }
diff --git a/drivers/net/e1000e/quirks.c b/drivers/net/e1000e/quirks.c
new file mode 100644
index 0000000..b0bfddd
--- /dev/null
+++ b/drivers/net/e1000e/quirks.c
@@ -0,0 +1,162 @@
+/*******************************************************************************
+
+  Intel PRO/1000 Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/pci.h>
+#include "ich8lan.h"
+#include "defines.h"
+
+#define E1000_EXTCNF_CTRL	0x00F00
+
+static int ichlan_nvm_write_protect = 1;
+
+static int __init ichlan_nvm_write_setup(char *str)
+{
+	if (str) {
+		if (!strncmp("disable", str, 7))
+			ichlan_nvm_write_protect = 0;
+	}
+	return 1;
+}
+__setup("ichlan_protect=", ichlan_nvm_write_setup);
+
+
+/*
+ * The GbE region of the NVM on certain ICHx-based platforms is not write-
+ * protected.  Accesss to this region is through mapped flash control
+ * registers located at an address provided by BAR1.  Because the NVM
+ * region is not write-protected, malicious code (intentional or not) can
+ * write to the mapped flash control registers and potentially cause the
+ * NVM region to be corrupted.  This quirk prevents this from happening.
+ */
+static void __devinit quirk_ichlan(struct pci_dev *dev)
+{
+	union ich8_flash_protected_range pr0;
+	union ich8_hws_flash_status hsfsts;
+	u8 __iomem *csr = NULL;
+	u8 __iomem *flash = NULL;
+	u32 timeout = 100;
+	u32 reg_val;
+
+	if (ichlan_nvm_write_protect == 0)
+		goto out;
+
+	if (!(pci_resource_flags(dev, 0) & IORESOURCE_MEM) ||
+	    !(pci_resource_flags(dev, 1) & IORESOURCE_MEM)) {
+		dev_err(&dev->dev, "Required BAR not a memory resource\n");
+		goto out;
+	}
+
+	csr = ioremap(pci_resource_start(dev, 0), pci_resource_len(dev, 0));
+	if (!csr) {
+		dev_err(&dev->dev, "Cannot map CSR register space\n");
+		goto out;
+	}
+
+	flash = ioremap(pci_resource_start(dev, 1), pci_resource_len(dev, 1));
+	if (!flash) {
+		dev_err(&dev->dev, "Cannot map flash register space\n");
+		goto out;
+	}
+
+	/* Acquire the HW/SW/FW semaphore */
+	might_sleep();
+	while (timeout) {
+		reg_val = readl(csr + E1000_EXTCNF_CTRL);
+		reg_val |= E1000_EXTCNF_CTRL_SWFLAG;
+		writel(reg_val, csr + E1000_EXTCNF_CTRL);
+
+		reg_val = readl(csr + E1000_EXTCNF_CTRL);
+		if (reg_val & E1000_EXTCNF_CTRL_SWFLAG)
+			break;
+		mdelay(1);
+		timeout--;
+	}
+	if (!timeout) {
+		dev_err(&dev->dev, "FW or HW has locked the NVM too long\n");
+		goto out;
+	}
+
+	/* Get base/limit of GbE region */
+	reg_val = readl(flash + ICH_FLASH_GFPREG);
+
+	/* Write-protect GbE region of NVM */
+	pr0.regval = readl(flash + ICH_FLASH_PR0);
+	pr0.range.base = reg_val & FLASH_GFPREG_BASE_MASK;
+	pr0.range.limit = ((reg_val >> 16) & FLASH_GFPREG_BASE_MASK);
+	pr0.range.wpe = true;
+	writel(pr0.regval, flash + ICH_FLASH_PR0);
+
+	/*
+	 * Lock down a subset of GbE Flash Control Registers, e.g.
+	 * PR0 to prevent the write-protection from being lifted.
+	 * Once FLOCKDN is set, the registers protected by it cannot
+	 * be written until FLOCKDN is cleared by a hardware reset.
+	 */
+	hsfsts.regval = readw(flash + ICH_FLASH_HSFSTS);
+	hsfsts.hsf_status.flockdn = true;
+	writew(hsfsts.regval, flash + ICH_FLASH_HSFSTS);
+
+	/* Release the HW/SW/FW semaphore */
+	reg_val = readl(csr + E1000_EXTCNF_CTRL);
+	reg_val &= ~E1000_EXTCNF_CTRL_SWFLAG;
+	writel(reg_val, csr + E1000_EXTCNF_CTRL);
+
+	/* flush writes */
+	pci_read_config_word(dev, PCI_STATUS, (u16 *)&reg_val);
+
+out:
+	if (flash)
+		iounmap(flash);
+	if (csr)
+		iounmap(csr);
+	if (pr0.range.wpe != true)
+		dev_info(&dev->dev, "NVM write-protection disabled\n"
+		                    "Warning: can lead to a corrupted NVM\n");
+	return;
+}
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x1049, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x104a, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x104b, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x104c, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x104d, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10bd, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10bf, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10c0, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10c2, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10c3, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10c4, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10c5, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10cb, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10cc, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10cd, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10ce, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10de, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10df, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10e5, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10f5, quirk_ichlan);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x294c, quirk_ichlan);

