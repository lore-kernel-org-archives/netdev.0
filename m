From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] ixgb: enable sun hardware support for broadcom phy
Date: Fri, 14 Dec 2007 11:48:36 -0800
Message-ID: <20071214194836.15478.85555.stgit@localhost.localdomain>
References: <20071214194829.15478.2510.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com, matheos.worku@sun.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45701 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757247AbXLNTwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 14:52:22 -0500
In-Reply-To: <20071214194829.15478.2510.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <matheos.worku@sun.com>

Implement support for a SUN-specific PHY.

SUN provides a modified 82597-based board with their own
PHY that works with very little modification to the code. This
patch implements this new PHY which is identified by the
subvendor device ID. The device ID of the adapter remains
the same.

Signed-off-by: Matheos Worku <matheos.worku@sun.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_hw.c   |   82 +++++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgb/ixgb_hw.h   |    3 +-
 drivers/net/ixgb/ixgb_ids.h  |    4 ++
 drivers/net/ixgb/ixgb_main.c |   10 +++--
 4 files changed, 91 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 2c6367a..80a8b98 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -45,6 +45,8 @@ static boolean_t ixgb_link_reset(struct ixgb_hw *hw);
 
 static void ixgb_optics_reset(struct ixgb_hw *hw);
 
+static void ixgb_optics_reset_bcm(struct ixgb_hw *hw);
+
 static ixgb_phy_type ixgb_identify_phy(struct ixgb_hw *hw);
 
 static void ixgb_clear_hw_cntrs(struct ixgb_hw *hw);
@@ -90,10 +92,20 @@ static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
 	ASSERT(!(ctrl_reg & IXGB_CTRL0_RST));
 #endif
 
-	if (hw->phy_type == ixgb_phy_type_txn17401) {
-		ixgb_optics_reset(hw);
+	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID) {
+		ctrl_reg =  /* Enable interrupt from XFP and SerDes */
+			   IXGB_CTRL1_GPI0_EN |
+			   IXGB_CTRL1_SDP6_DIR |
+			   IXGB_CTRL1_SDP7_DIR |
+			   IXGB_CTRL1_SDP6 |
+			   IXGB_CTRL1_SDP7;
+		IXGB_WRITE_REG(hw, CTRL1, ctrl_reg);
+		ixgb_optics_reset_bcm(hw);
 	}
 
+	if (hw->phy_type == ixgb_phy_type_txn17401)
+		ixgb_optics_reset(hw);
+
 	return ctrl_reg;
 }
 
@@ -253,6 +265,10 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 		break;
 	}
 
+	/* update phy type for sun specific board */
+	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID)
+		phy_type = ixgb_phy_type_bcm;
+
 	return (phy_type);
 }
 
@@ -1225,3 +1241,65 @@ ixgb_optics_reset(struct ixgb_hw *hw)
 
 	return;
 }
+
+/******************************************************************************
+ * Resets the 10GbE optics module for Sun variant NIC.
+ *
+ * hw - Struct containing variables accessed by shared code
+ *****************************************************************************/
+
+#define   IXGB_BCM8704_USER_PMD_TX_CTRL_REG         0xC803
+#define   IXGB_BCM8704_USER_PMD_TX_CTRL_REG_VAL     0x0164
+#define   IXGB_BCM8704_USER_CTRL_REG                0xC800
+#define   IXGB_BCM8704_USER_CTRL_REG_VAL            0x7FBF
+#define   IXGB_BCM8704_USER_DEV3_ADDR               0x0003
+#define   IXGB_SUN_PHY_ADDRESS                      0x0000
+#define   IXGB_SUN_PHY_RESET_DELAY                     305
+
+static void
+ixgb_optics_reset_bcm(struct ixgb_hw *hw)
+{
+	u32 ctrl = IXGB_READ_REG(hw, CTRL0);
+	ctrl &= ~IXGB_CTRL0_SDP2;
+	ctrl |= IXGB_CTRL0_SDP3;
+	IXGB_WRITE_REG(hw, CTRL0, ctrl);
+
+	/* SerDes needs extra delay */
+	msleep(IXGB_SUN_PHY_RESET_DELAY);
+
+	/* Broadcom 7408L configuration */
+	/* Reference clock config */
+	ixgb_write_phy_reg(hw,
+			   IXGB_BCM8704_USER_PMD_TX_CTRL_REG,
+			   IXGB_SUN_PHY_ADDRESS,
+			   IXGB_BCM8704_USER_DEV3_ADDR,
+			   IXGB_BCM8704_USER_PMD_TX_CTRL_REG_VAL);
+	/*  we must read the registers twice */
+	ixgb_read_phy_reg(hw,
+			  IXGB_BCM8704_USER_PMD_TX_CTRL_REG,
+			  IXGB_SUN_PHY_ADDRESS,
+			  IXGB_BCM8704_USER_DEV3_ADDR);
+	ixgb_read_phy_reg(hw,
+			  IXGB_BCM8704_USER_PMD_TX_CTRL_REG,
+			  IXGB_SUN_PHY_ADDRESS,
+			  IXGB_BCM8704_USER_DEV3_ADDR);
+
+	ixgb_write_phy_reg(hw,
+			   IXGB_BCM8704_USER_CTRL_REG,
+			   IXGB_SUN_PHY_ADDRESS,
+			   IXGB_BCM8704_USER_DEV3_ADDR,
+			   IXGB_BCM8704_USER_CTRL_REG_VAL);
+	ixgb_read_phy_reg(hw,
+			  IXGB_BCM8704_USER_CTRL_REG,
+			  IXGB_SUN_PHY_ADDRESS,
+			  IXGB_BCM8704_USER_DEV3_ADDR);
+	ixgb_read_phy_reg(hw,
+			  IXGB_BCM8704_USER_CTRL_REG,
+			  IXGB_SUN_PHY_ADDRESS,
+			  IXGB_BCM8704_USER_DEV3_ADDR);
+
+	/* SerDes needs extra delay */
+	msleep(IXGB_SUN_PHY_RESET_DELAY);
+
+	return;
+}
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index af56433..f4e0044 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -44,7 +44,8 @@ typedef enum {
 	ixgb_phy_type_g6005,	/* 850nm, MM fiber, XPAK transceiver */
 	ixgb_phy_type_g6104,	/* 1310nm, SM fiber, XPAK transceiver */
 	ixgb_phy_type_txn17201,	/* 850nm, MM fiber, XPAK transceiver */
-	ixgb_phy_type_txn17401	/* 1310nm, SM fiber, XENPAK transceiver */
+	ixgb_phy_type_txn17401,	/* 1310nm, SM fiber, XENPAK transceiver */
+	ixgb_phy_type_bcm	/* SUN specific board */
 } ixgb_phy_type;
 
 /* XPAK transceiver vendors, for the SR adapters */
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index 4376e7e..180d20e 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -35,7 +35,8 @@
 
 #define INTEL_VENDOR_ID             0x8086
 #define INTEL_SUBVENDOR_ID          0x8086
-
+#define SUN_VENDOR_ID               0x108E
+#define SUN_SUBVENDOR_ID            0x108E
 
 #define IXGB_DEVICE_ID_82597EX      0x1048   
 #define IXGB_DEVICE_ID_82597EX_SR   0x1A48   
@@ -46,6 +47,7 @@
 #define IXGB_DEVICE_ID_82597EX_CX4   0x109E
 #define IXGB_SUBDEVICE_ID_A00C  0xA00C
 #define IXGB_SUBDEVICE_ID_A01C  0xA01C
+#define IXGB_SUBDEVICE_ID_7036  0x7036
 
 #endif /* #ifndef _IXGB_IDS_H_ */
 /* End of File */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index bf9085f..af4d5d4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -36,7 +36,7 @@ static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION		"1.0.126-k2"DRIVERNAPI
+#define DRV_VERSION		"1.0.126-k4"DRIVERNAPI
 const char ixgb_driver_version[] = DRV_VERSION;
 static const char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -212,9 +212,11 @@ static void
 ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
 	if(atomic_dec_and_test(&adapter->irq_sem)) {
-		IXGB_WRITE_REG(&adapter->hw, IMS,
-			       IXGB_INT_RXT0 | IXGB_INT_RXDMT0 | IXGB_INT_TXDW |
-			       IXGB_INT_LSC);
+		u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
+			  IXGB_INT_TXDW | IXGB_INT_LSC;
+		if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
+			val |= IXGB_INT_GPI0;
+		IXGB_WRITE_REG(&adapter->hw, IMS, val);
 		IXGB_WRITE_FLUSH(&adapter->hw);
 	}
 }

