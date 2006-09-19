From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 13/23] e1000: gather hardware bit tweaks.
Date: Tue, 19 Sep 2006 10:29:02 -0700
Message-ID: <20060919172901.4605.36283.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:23053 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030346AbWISRUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:07 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several hardware bits were set all over the driver and have been
consolidated into a single function.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c   |  142 +++++++++++++++++++++++++++++++++-------
 drivers/net/e1000/e1000_hw.h   |    1 
 drivers/net/e1000/e1000_main.c |   24 +++----
 3 files changed, 129 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 9422864..a143b49 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -61,6 +61,7 @@ static int32_t e1000_id_led_init(struct 
 static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
 static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
+static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
 static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
 static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
 static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
@@ -716,6 +717,110 @@ e1000_reset_hw(struct e1000_hw *hw)
 }
 
 /******************************************************************************
+ *
+ * Initialize a number of hardware-dependent bits
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ *****************************************************************************/
+static void
+e1000_initialize_hardware_bits(struct e1000_hw *hw)
+{
+    if ((hw->mac_type >= e1000_82571) && (!hw->initialize_hw_bits_disable)) {
+        /* Settings common to all silicon */
+        uint32_t reg_ctrl, reg_ctrl_ext;
+        uint32_t reg_tarc0, reg_tarc1;
+        uint32_t reg_tctl;
+        uint32_t reg_txdctl, reg_txdctl1;
+
+        reg_tarc0 = E1000_READ_REG(hw, TARC0);
+        reg_tarc0 &= ~0x78000000;           /* Clear bits 30, 29, 28, and 27 */
+
+        reg_txdctl = E1000_READ_REG(hw, TXDCTL);
+        reg_txdctl |= E1000_TXDCTL_COUNT_DESC;       /* Set bit 22 */
+        E1000_WRITE_REG(hw, TXDCTL, reg_txdctl);
+
+        reg_txdctl1 = E1000_READ_REG(hw, TXDCTL1);
+        reg_txdctl1 |= E1000_TXDCTL_COUNT_DESC;      /* Set bit 22 */
+        E1000_WRITE_REG(hw, TXDCTL1, reg_txdctl1);
+
+        switch (hw->mac_type) {
+            case e1000_82571:
+            case e1000_82572:
+                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+
+                /* Set the phy Tx compatible mode bits */
+                reg_tarc1 &= ~0x60000000;   /* Clear bits 30 and 29 */
+
+                reg_tarc0 |= 0x07800000;    /* Set TARC0 bits 23-26 */
+                reg_tarc1 |= 0x07000000;    /* Set TARC1 bits 24-26 */
+
+                if (reg_tctl & E1000_TCTL_MULR)
+                    reg_tarc1 &= ~0x10000000;   /* Clear bit 28 if MULR is 1b */
+                else
+                    reg_tarc1 |= 0x10000000;    /* Set bit 28 if MULR is 0b */
+
+                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                break;
+            case e1000_82573:
+                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl = E1000_READ_REG(hw, CTRL);
+
+                reg_ctrl_ext &= ~0x00800000;    /* Clear bit 23 */
+                reg_ctrl_ext |= 0x00400000;     /* Set bit 22 */
+                reg_ctrl &= ~0x20000000;        /* Clear bit 29 */
+
+                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
+                E1000_WRITE_REG(hw, CTRL, reg_ctrl);
+                break;
+            case e1000_80003es2lan:
+                if ((hw->media_type == e1000_media_type_fiber) ||
+                    (hw->media_type == e1000_media_type_internal_serdes)) {
+                    reg_tarc0 &= ~0x00100000;   /* Clear bit 20 */
+                }
+
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                if (reg_tctl & E1000_TCTL_MULR)
+                    reg_tarc1 &= ~0x10000000;   /* Clear bit 28 if MULR is 1b */
+                else
+                    reg_tarc1 |= 0x10000000;    /* Set bit 28 if MULR is 0b */
+
+                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                break;
+            case e1000_ich8lan:
+                if ((hw->revision_id < 3) ||
+                    ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
+                     (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))
+                    reg_tarc0 |= 0x30000000;    /* Set TARC0 bits 29 and 28 */
+                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl_ext |= 0x00400000;     /* Set bit 22 */
+                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
+
+                reg_tarc0 |= 0x0d800000;    /* Set TARC0 bits 23, 24, 26, 27 */
+
+                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tctl = E1000_READ_REG(hw, TCTL);
+
+                if (reg_tctl & E1000_TCTL_MULR)
+                    reg_tarc1 &= ~0x10000000;   /* Clear bit 28 if MULR is 1b */
+                else
+                    reg_tarc1 |= 0x10000000;    /* Set bit 28 if MULR is 0b */
+
+                reg_tarc1 |= 0x45000000;        /* Set bit 24, 26 and 30 */
+
+                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                break;
+            default:
+                break;
+        }
+
+        E1000_WRITE_REG(hw, TARC0, reg_tarc0);
+    }
+}
+
+/******************************************************************************
  * Performs basic configuration of the adapter.
  *
  * hw - Struct containing variables accessed by shared code
@@ -743,14 +848,13 @@ e1000_init_hw(struct e1000_hw *hw)
     DEBUGFUNC("e1000_init_hw");
 
     /* force full DMA clock frequency for 10/100 on ICH8 A0-B0 */
-    if (hw->mac_type == e1000_ich8lan) {
-        reg_data = E1000_READ_REG(hw, TARC0);
-        reg_data |= 0x30000000;
-        E1000_WRITE_REG(hw, TARC0, reg_data);
-
-        reg_data = E1000_READ_REG(hw, STATUS);
-        reg_data &= ~0x80000000;
-        E1000_WRITE_REG(hw, STATUS, reg_data);
+    if ((hw->mac_type == e1000_ich8lan) &&
+        ((hw->revision_id < 3) ||
+         ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
+          (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))) {
+            reg_data = E1000_READ_REG(hw, STATUS);
+            reg_data &= ~0x80000000;
+            E1000_WRITE_REG(hw, STATUS, reg_data);
     }
 
     /* Initialize Identification LED */
@@ -763,6 +867,9 @@ e1000_init_hw(struct e1000_hw *hw)
     /* Set the media type and TBI compatibility */
     e1000_set_media_type(hw);
 
+    /* Must be called after e1000_set_media_type because media_type is used */
+    e1000_initialize_hardware_bits(hw);
+
     /* Disabling VLAN filtering. */
     DEBUGOUT("Initializing the IEEE VLAN\n");
     /* VET hardcoded to standard value and VFTA removed in ICH8 LAN */
@@ -854,17 +961,6 @@ e1000_init_hw(struct e1000_hw *hw)
     if (hw->mac_type > e1000_82544) {
         ctrl = E1000_READ_REG(hw, TXDCTL);
         ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        switch (hw->mac_type) {
-        default:
-            break;
-        case e1000_82571:
-        case e1000_82572:
-        case e1000_82573:
-        case e1000_ich8lan:
-        case e1000_80003es2lan:
-            ctrl |= E1000_TXDCTL_COUNT_DESC;
-            break;
-        }
         E1000_WRITE_REG(hw, TXDCTL, ctrl);
     }
 
@@ -902,8 +998,6 @@ e1000_init_hw(struct e1000_hw *hw)
     case e1000_ich8lan:
         ctrl = E1000_READ_REG(hw, TXDCTL1);
         ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        if (hw->mac_type >= e1000_82571)
-            ctrl |= E1000_TXDCTL_COUNT_DESC;
         E1000_WRITE_REG(hw, TXDCTL1, ctrl);
         break;
     }
@@ -1143,11 +1237,11 @@ e1000_setup_fiber_serdes_link(struct e10
     if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572)
         E1000_WRITE_REG(hw, SCTL, E1000_DISABLE_SERDES_LOOPBACK);
 
-    /* On adapters with a MAC newer than 82544, SW Defineable pin 1 will be
+    /* On adapters with a MAC newer than 82544, SWDP 1 will be
      * set when the optics detect a signal. On older adapters, it will be
      * cleared when there is a signal.  This applies to fiber media only.
-     * If we're on serdes media, adjust the output amplitude to value set in
-     * the EEPROM.
+     * If we're on serdes media, adjust the output amplitude to value
+     * set in the EEPROM.
      */
     ctrl = E1000_READ_REG(hw, CTRL);
     if (hw->media_type == e1000_media_type_fiber)
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 5ca88a7..58b9221 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1429,6 +1429,7 @@ struct e1000_hw {
     boolean_t tbi_compatibility_on;
     boolean_t laa_is_present;
     boolean_t phy_reset_disable;
+    boolean_t initialize_hw_bits_disable;
     boolean_t fc_send_xon;
     boolean_t fc_strict_ieee;
     boolean_t report_tx_early;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index af9d360..09f6662 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -573,6 +573,9 @@ void
 e1000_reset(struct e1000_adapter *adapter)
 {
 	uint32_t pba, manc;
+#ifdef DISABLE_MULR
+	uint32_t tctl;
+#endif
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
 
 	/* Repartition Pba for greater than 9k mtu
@@ -639,6 +642,12 @@ e1000_reset(struct e1000_adapter *adapte
 	e1000_reset_hw(&adapter->hw);
 	if (adapter->hw.mac_type >= e1000_82544)
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
+#ifdef DISABLE_MULR
+	/* disable Multiple Reads in Transmit Control Register for debugging */
+	tctl = E1000_READ_REG(hw, TCTL);
+	E1000_WRITE_REG(hw, TCTL, tctl & ~E1000_TCTL_MULR);
+
+#endif
 	if (e1000_init_hw(&adapter->hw))
 		DPRINTK(PROBE, ERR, "Hardware Error\n");
 	e1000_update_mng_vlan(adapter);
@@ -1517,27 +1526,14 @@ e1000_configure_tx(struct e1000_adapter 
 	/* Program the Transmit Control Register */
 
 	tctl = E1000_READ_REG(hw, TCTL);
-
 	tctl &= ~E1000_TCTL_CT;
 	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
 		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
 
-#ifdef DISABLE_MULR
-	/* disable Multiple Reads for debugging */
-	tctl &= ~E1000_TCTL_MULR;
-#endif
-
 	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
 		tarc = E1000_READ_REG(hw, TARC0);
-		tarc |= ((1 << 25) | (1 << 21));
+		tarc |= (1 << 21);
 		E1000_WRITE_REG(hw, TARC0, tarc);
-		tarc = E1000_READ_REG(hw, TARC1);
-		tarc |= (1 << 25);
-		if (tctl & E1000_TCTL_MULR)
-			tarc &= ~(1 << 28);
-		else
-			tarc |= (1 << 28);
-		E1000_WRITE_REG(hw, TARC1, tarc);
 	} else if (hw->mac_type == e1000_80003es2lan) {
 		tarc = E1000_READ_REG(hw, TARC0);
 		tarc |= 1;



---
Auke Kok <auke-jan.h.kok@intel.com>
