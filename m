From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 1/11] new 82541/5/6/7 hardware support
Date: Mon, 8 Sep 2003 20:14:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081834570.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Added 82545 (rev3), 82546 (rev3), and 82541/7 (rev2) support
	- new device IDs
	- internal SERDES support for 82545/6 (rev3)
	- don't apply MMRBC workaround for 82545/6 (rev3)
	- don't use IO mapping for reset for 82545/6 (rev3)

------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_ethtool.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_ethtool.c	2003-08-22 16:55:33.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_ethtool.c	2003-09-08 09:13:10.000000000 -0700
@@ -958,9 +958,13 @@ e1000_set_phy_loopback(struct e1000_adap
 	case e1000_82544:
 	case e1000_82540:
 	case e1000_82545:
+	case e1000_82545_rev_3:
 	case e1000_82546:
+	case e1000_82546_rev_3:
 	case e1000_82541:
+	case e1000_82541_rev_2:
 	case e1000_82547:
+	case e1000_82547_rev_2:
 		return e1000_integrated_phy_loopback(adapter);
 		break;
 
@@ -983,9 +987,12 @@ e1000_setup_loopback_test(struct e1000_a
 {
 	uint32_t rctl;
 
-	if(adapter->hw.media_type == e1000_media_type_fiber) {
+	if(adapter->hw.media_type == e1000_media_type_fiber ||
+	   adapter->hw.media_type == e1000_media_type_internal_serdes) {
 		if(adapter->hw.mac_type == e1000_82545 ||
-		   adapter->hw.mac_type == e1000_82546)
+		   adapter->hw.mac_type == e1000_82546 ||
+		   adapter->hw.mac_type == e1000_82545_rev_3 ||
+		   adapter->hw.mac_type == e1000_82546_rev_3)
 			return e1000_set_phy_loopback(adapter);
 		else {
 			rctl = E1000_READ_REG(&adapter->hw, RCTL);
@@ -1010,9 +1017,12 @@ e1000_loopback_cleanup(struct e1000_adap
 	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 
 	if(adapter->hw.media_type == e1000_media_type_copper ||
-	   (adapter->hw.media_type == e1000_media_type_fiber &&
+	   ((adapter->hw.media_type == e1000_media_type_fiber ||
+	     adapter->hw.media_type == e1000_media_type_internal_serdes) &&
 	    (adapter->hw.mac_type == e1000_82545 ||
-	     adapter->hw.mac_type == e1000_82546))) {
+	     adapter->hw.mac_type == e1000_82546 ||
+	     adapter->hw.mac_type == e1000_82545_rev_3 ||
+	     adapter->hw.mac_type == e1000_82546_rev_3))) {
 		adapter->hw.autoneg = TRUE;
 		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
 		if(phy_reg & MII_CR_LOOPBACK) {
@@ -1162,6 +1172,7 @@ e1000_ethtool_gwol(struct e1000_adapter 
 		return;
 
 	case E1000_DEV_ID_82546EB_FIBER:
+	case E1000_DEV_ID_82546GB_FIBER:
 		/* Wake events only supported on port A for dual fiber */
 		if(E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported = 0;
@@ -1200,6 +1211,7 @@ e1000_ethtool_swol(struct e1000_adapter 
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
 	case E1000_DEV_ID_82546EB_FIBER:
+	case E1000_DEV_ID_82546GB_FIBER:
 		/* Wake events only supported on port A for dual fiber */
 		if(E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)
 			return wol->wolopts ? -EOPNOTSUPP : 0;
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c	2003-08-22 17:01:40.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c	2003-09-08 09:13:11.000000000 -0700
@@ -34,8 +34,9 @@
 
 static int32_t e1000_set_phy_type(struct e1000_hw *hw);
 static void e1000_phy_init_script(struct e1000_hw *hw);
-static int32_t e1000_setup_fiber_link(struct e1000_hw *hw);
 static int32_t e1000_setup_copper_link(struct e1000_hw *hw);
+static int32_t e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
+static int32_t e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
 static int32_t e1000_phy_force_speed_duplex(struct e1000_hw *hw);
 static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
 static int32_t e1000_force_mac_fc(struct e1000_hw *hw);
@@ -53,11 +53,16 @@ static int32_t e1000_write_eeprom_microw
 static void e1000_raise_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
 static void e1000_lower_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
 static void e1000_shift_out_ee_bits(struct e1000_hw *hw, uint16_t data, uint16_t count);
+static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
+                                      uint16_t phy_data);
+static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,uint32_t reg_addr,
+                                     uint16_t *phy_data);
 static uint16_t e1000_shift_in_ee_bits(struct e1000_hw *hw, uint16_t count);
 static int32_t e1000_acquire_eeprom(struct e1000_hw *hw);
 static void e1000_release_eeprom(struct e1000_hw *hw);
 static void e1000_standby_eeprom(struct e1000_hw *hw);
 static int32_t e1000_id_led_init(struct e1000_hw * hw);
+static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
 
 
 
@@ -100,50 +100,41 @@ e1000_phy_init_script(struct e1000_hw *h
     DEBUGFUNC("e1000_phy_init_script");
 
     if(hw->phy_init_script) {
-        msec_delay(10);
+        msec_delay(20);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x0000);
         e1000_write_phy_reg(hw,0x0000,0x0140);
 
         msec_delay(5);
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F95);
-        e1000_write_phy_reg(hw,0x0015,0x0001);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F71);
-        e1000_write_phy_reg(hw,0x0011,0xBD21);
+        if(hw->mac_type == e1000_82541 || hw->mac_type == e1000_82547) {
+            e1000_write_phy_reg(hw, 0x1F95, 0x0001);
+
+            e1000_write_phy_reg(hw, 0x1F71, 0xBD21);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F79);
-        e1000_write_phy_reg(hw,0x0019,0x0018);
+            e1000_write_phy_reg(hw, 0x1F79, 0x0018);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F30);
-        e1000_write_phy_reg(hw,0x0010,0x1600);
+            e1000_write_phy_reg(hw, 0x1F30, 0x1600);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F31);
-        e1000_write_phy_reg(hw,0x0011,0x0014);
+            e1000_write_phy_reg(hw, 0x1F31, 0x0014);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F32);
-        e1000_write_phy_reg(hw,0x0012,0x161C);
+            e1000_write_phy_reg(hw, 0x1F32, 0x161C);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F94);
-        e1000_write_phy_reg(hw,0x0014,0x0003);
+            e1000_write_phy_reg(hw, 0x1F94, 0x0003);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x1F96);
-        e1000_write_phy_reg(hw,0x0016,0x003F);
+            e1000_write_phy_reg(hw, 0x1F96, 0x003F);
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x2010);
-        e1000_write_phy_reg(hw,0x0010,0x0008);
+            e1000_write_phy_reg(hw, 0x2010, 0x0008);
+        } else {
+            e1000_write_phy_reg(hw, 0x1F73, 0x0099);
+        }
 
-        e1000_write_phy_reg(hw,IGP01E1000_PHY_PAGE_SELECT,0x0000);
-        e1000_write_phy_reg(hw,0x0000,0x3300);
+        e1000_write_phy_reg(hw, 0x0000, 0x3300);
 
 
         if(hw->mac_type == e1000_82547) {
             uint16_t fused, fine, coarse;
 
             /* Move to analog registers page */
-            e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 
-                                IGP01E1000_ANALOG_REGS_PAGE);
-
             e1000_read_phy_reg(hw, IGP01E1000_ANALOG_SPARE_FUSE_STATUS, &fused);
 
             if(!(fused & IGP01E1000_ANALOG_SPARE_FUSE_ENABLED)) {
@@ -158,17 +155,14 @@ e1000_phy_init_script(struct e1000_hw *h
                 } else if(coarse == IGP01E1000_ANALOG_FUSE_COARSE_THRESH)
                     fine -= IGP01E1000_ANALOG_FUSE_FINE_10;
 
-                fused = (fused & IGP01E1000_ANALOG_FUSE_POLY_MASK) | 
-                        (fine & IGP01E1000_ANALOG_FUSE_FINE_MASK) | 
+                fused = (fused & IGP01E1000_ANALOG_FUSE_POLY_MASK) |
+                        (fine & IGP01E1000_ANALOG_FUSE_FINE_MASK) |
                         (coarse & IGP01E1000_ANALOG_FUSE_COARSE_MASK);
 
                 e1000_write_phy_reg(hw, IGP01E1000_ANALOG_FUSE_CONTROL, fused);
-                e1000_write_phy_reg(hw, IGP01E1000_ANALOG_FUSE_BYPASS, 
+                e1000_write_phy_reg(hw, IGP01E1000_ANALOG_FUSE_BYPASS,
                                     IGP01E1000_ANALOG_FUSE_ENABLE_SW_CONTROL);
             }
-            /* Return to first page of registers */
-            e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                IGP01E1000_IEEE_REGS_PAGE);
         }
     }
 }
@@ -218,18 +224,36 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82545EM_FIBER:
         hw->mac_type = e1000_82545;
         break;
+    case E1000_DEV_ID_82545GM_COPPER:
+    case E1000_DEV_ID_82545GM_FIBER:
+    case E1000_DEV_ID_82545GM_SERDES:
+        hw->mac_type = e1000_82545_rev_3;
+        break;
     case E1000_DEV_ID_82546EB_COPPER:
     case E1000_DEV_ID_82546EB_FIBER:
     case E1000_DEV_ID_82546EB_QUAD_COPPER:
         hw->mac_type = e1000_82546;
         break;
+    case E1000_DEV_ID_82546GB_COPPER:
+    case E1000_DEV_ID_82546GB_FIBER:
+    case E1000_DEV_ID_82546GB_SERDES:
+        hw->mac_type = e1000_82546_rev_3;
+        break;
     case E1000_DEV_ID_82541EI:
-    case E1000_DEV_ID_82541EP:
+    case E1000_DEV_ID_82541EI_MOBILE:
         hw->mac_type = e1000_82541;
         break;
+    case E1000_DEV_ID_82541ER:
+    case E1000_DEV_ID_82541GI:
+    case E1000_DEV_ID_82541GI_MOBILE:
+        hw->mac_type = e1000_82541_rev_2;
+        break;
     case E1000_DEV_ID_82547EI:
         hw->mac_type = e1000_82547;
         break;
+    case E1000_DEV_ID_82547GI:
+        hw->mac_type = e1000_82547_rev_2;
+        break;
     default:
         /* Should never have loaded on this device */
         return -E1000_ERR_MAC_TYPE;
@@ -243,7 +224,7 @@ 
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void
+int32_t
 e1000_reset_hw(struct e1000_hw *hw)
 {
     uint32_t ctrl;
@@ -300,29 +343,54 @@ e1000_reset_hw(struct e1000_hw *hw)
         case e1000_82545:
         case e1000_82546:
         case e1000_82541:
+        case e1000_82541_rev_2:
             /* These controllers can't ack the 64-bit write when issuing the
              * reset, so use IO-mapping as a workaround to issue the reset */
             E1000_WRITE_REG_IO(hw, CTRL, (ctrl | E1000_CTRL_RST));
             break;
+        case e1000_82545_rev_3:
+        case e1000_82546_rev_3:
+            /* Reset is performed on a shadow of the control register */
+            E1000_WRITE_REG(hw, CTRL_DUP, (ctrl | E1000_CTRL_RST));
+            break;
         default:
             E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));
             break;
     }
 
-    /* Force a reload from the EEPROM if necessary */
-    if(hw->mac_type < e1000_82540) {
-        /* Wait for reset to complete */
-        udelay(10);
-        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
-        ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-        E1000_WRITE_FLUSH(hw);
-        /* Wait for EEPROM reload */
-        msec_delay(2);
-    } else {
-        /* Wait for EEPROM reload (it happens automatically) */
-        msec_delay(5);
-        /* Dissable HW ARPs on ASF enabled adapters */
+    /* After MAC reset, force reload of EEPROM to restore power-on settings to
+     * device.  Later controllers reload the EEPROM automatically, so just wait
+     * for reload to complete.
+     */
+    switch(hw->mac_type) {
+        case e1000_82542_rev2_0:
+        case e1000_82542_rev2_1:
+        case e1000_82543:
+        case e1000_82544:
+            /* Wait for reset to complete */
+            udelay(10);
+            ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+            ctrl_ext |= E1000_CTRL_EXT_EE_RST;
+            E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+            E1000_WRITE_FLUSH(hw);
+            /* Wait for EEPROM reload */
+            msec_delay(2);
+            break;
+        case e1000_82541:
+        case e1000_82541_rev_2:
+        case e1000_82547:
+        case e1000_82547_rev_2:
+            /* Wait for EEPROM reload */
+            msec_delay(20);
+            break;
+        default:
+            /* Wait for EEPROM reload (it happens automatically) */
+            msec_delay(5);
+            break;
+    }
+
+    /* Disable HW ARPs on ASF enabled adapters */
+    if(hw->mac_type >= e1000_82540) {
         manc = E1000_READ_REG(hw, MANC);
         manc &= ~(E1000_MANC_ARP_EN);
         E1000_WRITE_REG(hw, MANC, manc);
@@ -350,6 +387,8 @@ e1000_reset_hw(struct e1000_hw *hw)
         if(hw->pci_cmd_word & CMD_MEM_WRT_INVALIDATE)
             e1000_pci_set_mwi(hw);
     }
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -446,21 +485,30 @@ e1000_init_hw(struct e1000_hw *hw)
         E1000_WRITE_REG(hw, CTRL, ctrl | E1000_CTRL_PRIOR);
     }
 
-    /* Workaround for PCI-X problem when BIOS sets MMRBC incorrectly. */
-    if(hw->bus_type == e1000_bus_type_pcix) {
-        e1000_read_pci_cfg(hw, PCIX_COMMAND_REGISTER, &pcix_cmd_word);
-        e1000_read_pci_cfg(hw, PCIX_STATUS_REGISTER_HI, &pcix_stat_hi_word);
-        cmd_mmrbc = (pcix_cmd_word & PCIX_COMMAND_MMRBC_MASK) >>
-            PCIX_COMMAND_MMRBC_SHIFT;
-        stat_mmrbc = (pcix_stat_hi_word & PCIX_STATUS_HI_MMRBC_MASK) >>
-            PCIX_STATUS_HI_MMRBC_SHIFT;
-        if(stat_mmrbc == PCIX_STATUS_HI_MMRBC_4K)
-            stat_mmrbc = PCIX_STATUS_HI_MMRBC_2K;
-        if(cmd_mmrbc > stat_mmrbc) {
-            pcix_cmd_word &= ~PCIX_COMMAND_MMRBC_MASK;
-            pcix_cmd_word |= stat_mmrbc << PCIX_COMMAND_MMRBC_SHIFT;
-            e1000_write_pci_cfg(hw, PCIX_COMMAND_REGISTER, &pcix_cmd_word);
+    switch(hw->mac_type) {
+    case e1000_82545_rev_3:
+    case e1000_82546_rev_3:
+        break;
+    default:
+        /* Workaround for PCI-X problem when BIOS sets MMRBC incorrectly. */
+        if(hw->bus_type == e1000_bus_type_pcix) {
+            e1000_read_pci_cfg(hw, PCIX_COMMAND_REGISTER, &pcix_cmd_word);
+            e1000_read_pci_cfg(hw, PCIX_STATUS_REGISTER_HI,
+                &pcix_stat_hi_word);
+            cmd_mmrbc = (pcix_cmd_word & PCIX_COMMAND_MMRBC_MASK) >>
+                PCIX_COMMAND_MMRBC_SHIFT;
+            stat_mmrbc = (pcix_stat_hi_word & PCIX_STATUS_HI_MMRBC_MASK) >>
+                PCIX_STATUS_HI_MMRBC_SHIFT;
+            if(stat_mmrbc == PCIX_STATUS_HI_MMRBC_4K)
+                stat_mmrbc = PCIX_STATUS_HI_MMRBC_2K;
+            if(cmd_mmrbc > stat_mmrbc) {
+                pcix_cmd_word &= ~PCIX_COMMAND_MMRBC_MASK;
+                pcix_cmd_word |= stat_mmrbc << PCIX_COMMAND_MMRBC_SHIFT;
+                e1000_write_pci_cfg(hw, PCIX_COMMAND_REGISTER,
+                    &pcix_cmd_word);
+            }
         }
+        break;
     }
 
     /* Call a subroutine to configure the link and setup flow control. */
@@ -484,6 +532,46 @@ e1000_init_hw(struct e1000_hw *hw)
 }
 
 /******************************************************************************
+ * Adjust SERDES output amplitude based on EEPROM setting.
+ *
+ * hw - Struct containing variables accessed by shared code.
+ *****************************************************************************/
+static int32_t
+e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
+{
+    uint16_t eeprom_data;
+    int32_t  ret_val;
+
+    DEBUGFUNC("e1000_adjust_serdes_amplitude");
+
+    if(hw->media_type != e1000_media_type_internal_serdes)
+        return E1000_SUCCESS;
+
+    switch(hw->mac_type) {
+    case e1000_82545_rev_3:
+    case e1000_82546_rev_3:
+        break;
+    default:
+        return E1000_SUCCESS;
+    }
+
+    if ((ret_val = e1000_read_eeprom(hw, EEPROM_SERDES_AMPLITUDE, 1,
+                                     &eeprom_data))) {
+        return ret_val;
+    }
+
+    if(eeprom_data != EEPROM_RESERVED_WORD) {
+        /* Adjust SERDES output amplitude only. */
+        eeprom_data &= EEPROM_SERDES_AMPLITUDE_MASK; 
+        if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_EXT_CTRL,
+                                          eeprom_data)))
+            return ret_val;
+    }
+
+    return E1000_SUCCESS;
+}
+
+/******************************************************************************
  * Configures flow control and link settings.
  *
  * hw - Struct containing variables accessed by shared code
@@ -554,9 +642,9 @@ e1000_setup_link(struct e1000_hw *hw)
     }
 
     /* Call the necessary subroutine to configure the link. */
-    ret_val = (hw->media_type == e1000_media_type_fiber) ?
-              e1000_setup_fiber_link(hw) :
-              e1000_setup_copper_link(hw);
+    ret_val = (hw->media_type == e1000_media_type_copper) ?
+              e1000_setup_copper_link(hw) :
+              e1000_setup_fiber_serdes_link(hw);
 
     /* Initialize the flow control address, type, and PAUSE timer
      * registers to their default values.  This is done even if flow
@@ -595,7 +683,7 @@ e1000_setup_link(struct e1000_hw *hw)
 }
 
 /******************************************************************************
- * Sets up link for a fiber based adapter
+ * Sets up link for a fiber based or serdes based adapter
  *
  * hw - Struct containing variables accessed by shared code
  *
@@ -604,28 +692,37 @@ e1000_setup_link(struct e1000_hw *hw)
  * and receiver are not enabled.
  *****************************************************************************/
 static int32_t
-e1000_setup_fiber_link(struct e1000_hw *hw)
+e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
     uint32_t ctrl;
     uint32_t status;
     uint32_t txcw = 0;
     uint32_t i;
-    uint32_t signal;
+    uint32_t signal = 0;
     int32_t ret_val;
 
-    DEBUGFUNC("e1000_setup_fiber_link");
+    DEBUGFUNC("e1000_setup_fiber_serdes_link");
 
-    /* On adapters with a MAC newer that 82544, SW Defineable pin 1 will be
+    /* On adapters with a MAC newer than 82544, SW Defineable pin 1 will be
      * set when the optics detect a signal. On older adapters, it will be
-     * cleared when there is a signal
+     * cleared when there is a signal.  This applies to fiber media only.
+     * If we're on serdes media, adjust the output amplitude to value set in
+     * the EEPROM.
      */
     ctrl = E1000_READ_REG(hw, CTRL);
-    if(hw->mac_type > e1000_82544) signal = E1000_CTRL_SWDPIN1;
-    else signal = 0;
+    if(hw->media_type == e1000_media_type_fiber)
+        signal = (hw->mac_type > e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
+
+    if((ret_val = e1000_adjust_serdes_amplitude(hw)))
+        return ret_val;
 
     /* Take the link out of reset */
     ctrl &= ~(E1000_CTRL_LRST);
 
+    /* Adjust VCO speed to improve BER performance */
+    if((ret_val = e1000_set_vco_speed(hw)))
+        return ret_val;
+
     e1000_config_collision_dist(hw);
 
     /* Check for a software override of the flow control settings, and setup
@@ -692,8 +789,10 @@ e1000_setup_fiber_link(struct e1000_hw *
      * indication in the Device Status Register.  Time-out if a link isn't
      * seen in 500 milliseconds seconds (Auto-negotiation should complete in
      * less than 500 milliseconds even if the other end is doing it in SW).
+     * For internal serdes, we just assume a signal is present, then poll.
      */
-    if((E1000_READ_REG(hw, CTRL) & E1000_CTRL_SWDPIN1) == signal) {
+    if(hw->media_type == e1000_media_type_internal_serdes ||
+       (E1000_READ_REG(hw, CTRL) & E1000_CTRL_SWDPIN1) == signal) {
         DEBUGOUT("Looking for Link\n");
         for(i = 0; i < (LINK_UP_TIMEOUT / 10); i++) {
             msec_delay(10);
@@ -701,19 +800,20 @@ e1000_setup_fiber_link(struct e1000_hw *
             if(status & E1000_STATUS_LU) break;
         }
         if(i == (LINK_UP_TIMEOUT / 10)) {
-            /* AutoNeg failed to achieve a link, so we'll call
-             * e1000_check_for_link. This routine will force the link up if we
-             * detect a signal. This will allow us to communicate with
-             * non-autonegotiating link partners.
-             */
             DEBUGOUT("Never got a valid link from auto-neg!!!\n");
             hw->autoneg_failed = 1;
-            ret_val = e1000_check_for_link(hw);
-            if(ret_val < 0) {
-                DEBUGOUT("Error while checking for link\n");
-                return ret_val;
+            if(hw->media_type == e1000_media_type_fiber) {
+                /* AutoNeg failed to achieve a link, so we'll call
+                 * e1000_check_for_link. This routine will force the link up if
+                 * we detect a signal. This will allow us to communicate with
+                 * non-autonegotiating link partners.
+                 */
+                if((ret_val = e1000_check_for_link(hw))) {
+                    DEBUGOUT("Error while checking for link\n");
+                    return ret_val;
+                }
+                hw->autoneg_failed = 0;
             }
-            hw->autoneg_failed = 0;
         } else {
             hw->autoneg_failed = 0;
             DEBUGOUT("Valid Link Found\n");
@@ -721,7 +821,7 @@ e1000_setup_fiber_link(struct e1000_hw *
     } else {
         DEBUGOUT("No Signal Detected\n");
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -756,233 +856,281 @@ e1000_setup_copper_link(struct e1000_hw 
     }
 
     /* Make sure we have a valid PHY */
-    ret_val = e1000_detect_gig_phy(hw);
-    if(ret_val < 0) {
+    if((ret_val = e1000_detect_gig_phy(hw))) {
         DEBUGOUT("Error, did not detect valid phy.\n");
         return ret_val;
     }
     DEBUGOUT1("Phy ID = %x \n", hw->phy_id);
 
-    if (hw->phy_type == e1000_phy_igp) {
-
-        ret_val = e1000_phy_reset(hw);
-        if(ret_val < 0) {
-            DEBUGOUT("Error Resetting the PHY\n");
-            return ret_val;
-        }
+    if(hw->mac_type <= e1000_82543 ||
+       hw->mac_type == e1000_82541 || hw->mac_type == e1000_82547 ||
+       hw->mac_type == e1000_82541_rev_2 || hw->mac_type == e1000_82547_rev_2)
+        hw->phy_reset_disable = FALSE;
 
-        /* Wait 10ms for MAC to configure PHY from eeprom settings */
-        msec_delay(15);
+    if(!hw->phy_reset_disable) {
+        if (hw->phy_type == e1000_phy_igp) {
 
-        if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 0x0000) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+            if((ret_val = e1000_phy_reset(hw))) {
+                DEBUGOUT("Error Resetting the PHY\n");
+                return ret_val;
+            }
 
-        /* Configure activity LED after PHY reset */
-        led_ctrl = E1000_READ_REG(hw, LEDCTL);
-        led_ctrl &= IGP_ACTIVITY_LED_MASK;
-        led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
-        E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
+            /* Wait 10ms for MAC to configure PHY from eeprom settings */
+            msec_delay(15);
 
-        if(hw->autoneg_advertised == ADVERTISE_1000_FULL) {
-            /* Disable SmartSpeed */
-            if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
-                                  &phy_data) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
-            phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-            if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
-                                   phy_data) < 0) {
-                DEBUGOUT("PHY Write Error\n");
-                return -E1000_ERR_PHY;
-            }
-            /* Set auto Master/Slave resolution process */
-            if(e1000_read_phy_reg(hw, PHY_1000T_CTRL, &phy_data) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
+            /* Configure activity LED after PHY reset */
+            led_ctrl = E1000_READ_REG(hw, LEDCTL);
+            led_ctrl &= IGP_ACTIVITY_LED_MASK;
+            led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
+            E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
+
+            /* disable lplu d3 during driver init */
+            if((ret_val = e1000_set_d3_lplu_state(hw, FALSE))) {
+                DEBUGOUT("Error Disabling LPLU D3\n");
+                return ret_val;
             }
-            phy_data &= ~CR_1000T_MS_ENABLE;
-            if(e1000_write_phy_reg(hw, PHY_1000T_CTRL, phy_data) < 0) {
-                DEBUGOUT("PHY Write Error\n");
-                return -E1000_ERR_PHY;
+
+            /* Configure mdi-mdix settings */
+            if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL,
+                                             &phy_data)))
+                return ret_val;
+
+            if((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
+                hw->dsp_config_state = e1000_dsp_config_disabled;
+                /* Force MDI for IGP B-0 PHY */
+                phy_data &= ~(IGP01E1000_PSCR_AUTO_MDIX |
+                              IGP01E1000_PSCR_FORCE_MDI_MDIX);
+                hw->mdix = 1;
+
+            } else {
+                hw->dsp_config_state = e1000_dsp_config_enabled;
+                phy_data &= ~IGP01E1000_PSCR_AUTO_MDIX;
+
+                switch (hw->mdix) {
+                case 1:
+                    phy_data &= ~IGP01E1000_PSCR_FORCE_MDI_MDIX;
+                    break;
+                case 2:
+                    phy_data |= IGP01E1000_PSCR_FORCE_MDI_MDIX;
+                    break;
+                case 0:
+                default:
+                    phy_data |= IGP01E1000_PSCR_AUTO_MDIX;
+                    break;
+                }
             }
-        }
+            if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL,
+                                              phy_data)))
+                return ret_val;
 
-        if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+            /* set auto-master slave resolution settings */
+            if(hw->autoneg) {
+                e1000_ms_type phy_ms_setting = hw->master_slave;
+
+                if(hw->ffe_config_state == e1000_ffe_config_active)
+                    hw->ffe_config_state = e1000_ffe_config_enabled;
+
+                if(hw->dsp_config_state == e1000_dsp_config_activated)
+                    hw->dsp_config_state = e1000_dsp_config_enabled;
+
+                /* when autonegotiation advertisment is only 1000Mbps then we
+                 * should disable SmartSpeed and enable Auto MasterSlave
+                 * resolution as hardware default. */
+                if(hw->autoneg_advertised == ADVERTISE_1000_FULL) {
+                    /* Disable SmartSpeed */
+                    if((ret_val = e1000_read_phy_reg(hw,
+                                                    IGP01E1000_PHY_PORT_CONFIG,
+                                                    &phy_data)))
+                        return ret_val;
+                    phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
+                    if((ret_val = e1000_write_phy_reg(hw,
+                                                     IGP01E1000_PHY_PORT_CONFIG,
+                                                     phy_data)))
+                        return ret_val;
+                    /* Set auto Master/Slave resolution process */
+                    if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL,
+                                                     &phy_data)))
+                        return ret_val;
+                    phy_data &= ~CR_1000T_MS_ENABLE;
+                    if((ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL,
+                                                      phy_data)))
+                        return ret_val;
+                }
 
-        /* Force MDI for IGP PHY */
-        phy_data &= ~(IGP01E1000_PSCR_AUTO_MDIX |
-                      IGP01E1000_PSCR_FORCE_MDI_MDIX);
+                if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL,
+                                                 &phy_data)))
+                    return ret_val;
 
-        hw->mdix = 1;
+                /* load defaults for future use */
+                hw->original_master_slave = (phy_data & CR_1000T_MS_ENABLE) ?
+                                            ((phy_data & CR_1000T_MS_VALUE) ?
+                                             e1000_ms_force_master :
+                                             e1000_ms_force_slave) :
+                                             e1000_ms_auto;
+
+                switch (phy_ms_setting) {
+                case e1000_ms_force_master:
+                    phy_data |= (CR_1000T_MS_ENABLE | CR_1000T_MS_VALUE);
+                    break;
+                case e1000_ms_force_slave:
+                    phy_data |= CR_1000T_MS_ENABLE;
+                    phy_data &= ~(CR_1000T_MS_VALUE);
+                    break;
+                case e1000_ms_auto:
+                    phy_data &= ~CR_1000T_MS_ENABLE;
+                default:
+                    break;
+                }
+                if((ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL,
+                                                  phy_data)))
+                    return ret_val;
+            }
+        } else {
+            /* Enable CRS on TX. This must be set for half-duplex operation. */
+            if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
+                                             &phy_data)))
+                return ret_val;
 
-        if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+            phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 
-    } else {
-        /* Enable CRS on TX. This must be set for half-duplex operation. */
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
-        phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
+            /* Options:
+             *   MDI/MDI-X = 0 (default)
+             *   0 - Auto for all speeds
+             *   1 - MDI mode
+             *   2 - MDI-X mode
+             *   3 - Auto for 1000Base-T only (MDI-X for 10/100Base-T modes)
+             */
+            phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
 
-        /* Options:
-         *   MDI/MDI-X = 0 (default)
-         *   0 - Auto for all speeds
-         *   1 - MDI mode
-         *   2 - MDI-X mode
-         *   3 - Auto for 1000Base-T only (MDI-X for 10/100Base-T modes)
-         */
-        phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
+            switch (hw->mdix) {
+            case 1:
+                phy_data |= M88E1000_PSCR_MDI_MANUAL_MODE;
+                break;
+            case 2:
+                phy_data |= M88E1000_PSCR_MDIX_MANUAL_MODE;
+                break;
+            case 3:
+                phy_data |= M88E1000_PSCR_AUTO_X_1000T;
+                break;
+            case 0:
+            default:
+                phy_data |= M88E1000_PSCR_AUTO_X_MODE;
+                break;
+            }
 
-        switch (hw->mdix) {
-        case 1:
-            phy_data |= M88E1000_PSCR_MDI_MANUAL_MODE;
-            break;
-        case 2:
-            phy_data |= M88E1000_PSCR_MDIX_MANUAL_MODE;
-            break;
-        case 3:
-            phy_data |= M88E1000_PSCR_AUTO_X_1000T;
-            break;
-        case 0:
-        default:
-            phy_data |= M88E1000_PSCR_AUTO_X_MODE;
-            break;
-        }
+            /* Options:
+             *   disable_polarity_correction = 0 (default)
+             *       Automatic Correction for Reversed Cable Polarity
+             *   0 - Disabled
+             *   1 - Enabled
+             */
+            phy_data &= ~M88E1000_PSCR_POLARITY_REVERSAL;
+            if(hw->disable_polarity_correction == 1)
+                phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
+            if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
+                                              phy_data)))
+                return ret_val;
 
-        /* Options:
-         *   disable_polarity_correction = 0 (default)
-         *       Automatic Correction for Reversed Cable Polarity
-         *   0 - Disabled
-         *   1 - Enabled
-         */
-        phy_data &= ~M88E1000_PSCR_POLARITY_REVERSAL;
-        if(hw->disable_polarity_correction == 1)
-            phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
-        if(e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+            /* Force TX_CLK in the Extended PHY Specific Control Register
+             * to 25MHz clock.
+             */
+            if((ret_val = e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+                                             &phy_data)))
+                return ret_val;
 
-        /* Force TX_CLK in the Extended PHY Specific Control Register
-         * to 25MHz clock.
-         */
-        if(e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
-        phy_data |= M88E1000_EPSCR_TX_CLK_25;
+            phy_data |= M88E1000_EPSCR_TX_CLK_25;
 
-        if (hw->phy_revision < M88E1011_I_REV_4) {
-            /* Configure Master and Slave downshift values */
-            phy_data &= ~(M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK |
-                          M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK);
-            phy_data |= (M88E1000_EPSCR_MASTER_DOWNSHIFT_1X |
-                         M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X);
-            if(e1000_write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
-                                   phy_data) < 0) {
-                DEBUGOUT("PHY Write Error\n");
-                return -E1000_ERR_PHY;
+            if (hw->phy_revision < M88E1011_I_REV_4) {
+                /* Configure Master and Slave downshift values */
+                phy_data &= ~(M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK |
+                              M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK);
+                phy_data |= (M88E1000_EPSCR_MASTER_DOWNSHIFT_1X |
+                             M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X);
+                if((ret_val = e1000_write_phy_reg(hw,
+                                                  M88E1000_EXT_PHY_SPEC_CTRL,
+                                                  phy_data)))
+                    return ret_val;
             }
-        }
 
-        /* SW Reset the PHY so all changes take effect */
-        ret_val = e1000_phy_reset(hw);
-        if(ret_val < 0) {
-            DEBUGOUT("Error Resetting the PHY\n");
-            return ret_val;
+            /* SW Reset the PHY so all changes take effect */
+            if((ret_val = e1000_phy_reset(hw))) {
+                DEBUGOUT("Error Resetting the PHY\n");
+                return ret_val;
+            }
         }
-    }
 
-    /* Options:
-     *   autoneg = 1 (default)
-     *      PHY will advertise value(s) parsed from
-     *      autoneg_advertised and fc
-     *   autoneg = 0
-     *      PHY will be set to 10H, 10F, 100H, or 100F
-     *      depending on value parsed from forced_speed_duplex.
-     */
+        /* Options:
+         *   autoneg = 1 (default)
+         *      PHY will advertise value(s) parsed from
+         *      autoneg_advertised and fc
+         *   autoneg = 0
+         *      PHY will be set to 10H, 10F, 100H, or 100F
+         *      depending on value parsed from forced_speed_duplex.
+         */
+
+        /* Is autoneg enabled?  This is enabled by default or by software
+         * override.  If so, call e1000_phy_setup_autoneg routine to parse the
+         * autoneg_advertised and fc options. If autoneg is NOT enabled, then
+         * the user should have provided a speed/duplex override.  If so, then
+         * call e1000_phy_force_speed_duplex to parse and set this up.
+         */
+        if(hw->autoneg) {
+            /* Perform some bounds checking on the hw->autoneg_advertised
+             * parameter.  If this variable is zero, then set it to the default.
+             */
+            hw->autoneg_advertised &= AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-    /* Is autoneg enabled?  This is enabled by default or by software override.
-     * If so, call e1000_phy_setup_autoneg routine to parse the
-     * autoneg_advertised and fc options. If autoneg is NOT enabled, then the
-     * user should have provided a speed/duplex override.  If so, then call
-     * e1000_phy_force_speed_duplex to parse and set this up.
-     */
-    if(hw->autoneg) {
-        /* Perform some bounds checking on the hw->autoneg_advertised
-         * parameter.  If this variable is zero, then set it to the default.
-         */
-        hw->autoneg_advertised &= AUTONEG_ADVERTISE_SPEED_DEFAULT;
+            /* If autoneg_advertised is zero, we assume it was not defaulted
+             * by the calling code so we set to advertise full capability.
+             */
+            if(hw->autoneg_advertised == 0)
+                hw->autoneg_advertised = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-        /* If autoneg_advertised is zero, we assume it was not defaulted
-         * by the calling code so we set to advertise full capability.
-         */
-        if(hw->autoneg_advertised == 0)
-            hw->autoneg_advertised = AUTONEG_ADVERTISE_SPEED_DEFAULT;
+            DEBUGOUT("Reconfiguring auto-neg advertisement params\n");
+            if((ret_val = e1000_phy_setup_autoneg(hw))) {
+                DEBUGOUT("Error Setting up Auto-Negotiation\n");
+                return ret_val;
+            }
+            DEBUGOUT("Restarting Auto-Neg\n");
 
-        DEBUGOUT("Reconfiguring auto-neg advertisement params\n");
-        ret_val = e1000_phy_setup_autoneg(hw);
-        if(ret_val < 0) {
-            DEBUGOUT("Error Setting up Auto-Negotiation\n");
-            return ret_val;
-        }
-        DEBUGOUT("Restarting Auto-Neg\n");
+            /* Restart auto-negotiation by setting the Auto Neg Enable bit and
+             * the Auto Neg Restart bit in the PHY control register.
+             */
+            if((ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data)))
+                return ret_val;
 
-        /* Restart auto-negotiation by setting the Auto Neg Enable bit and
-         * the Auto Neg Restart bit in the PHY control register.
-         */
-        if(e1000_read_phy_reg(hw, PHY_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
-        phy_data |= (MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG);
-        if(e1000_write_phy_reg(hw, PHY_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+            phy_data |= (MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG);
+            if((ret_val = e1000_write_phy_reg(hw, PHY_CTRL, phy_data)))
+                return ret_val;
 
-        /* Does the user want to wait for Auto-Neg to complete here, or
-         * check at a later time (for example, callback routine).
-         */
-        if(hw->wait_autoneg_complete) {
-            ret_val = e1000_wait_autoneg(hw);
-            if(ret_val < 0) {
-                DEBUGOUT("Error while waiting for autoneg to complete\n");
+            /* Does the user want to wait for Auto-Neg to complete here, or
+             * check at a later time (for example, callback routine).
+             */
+            if(hw->wait_autoneg_complete) {
+                if((ret_val = e1000_wait_autoneg(hw))) {
+                    DEBUGOUT("Error while waiting for autoneg to complete\n");
+                    return ret_val;
+                }
+            }
+            hw->get_link_status = TRUE;
+        } else {
+            DEBUGOUT("Forcing speed and duplex\n");
+            if((ret_val = e1000_phy_force_speed_duplex(hw))) {
+                DEBUGOUT("Error Forcing Speed and Duplex\n");
                 return ret_val;
             }
         }
-        hw->get_link_status = TRUE;
-    } else {
-        DEBUGOUT("Forcing speed and duplex\n");
-        ret_val = e1000_phy_force_speed_duplex(hw);
-        if(ret_val < 0) {
-            DEBUGOUT("Error Forcing Speed and Duplex\n");
-            return ret_val;
-        }
-    }
+    } /* !hw->phy_reset_disable */
 
     /* Check link status. Wait up to 100 microseconds for link to become
      * valid.
      */
     for(i = 0; i < 10; i++) {
-        if(e1000_read_phy_reg(hw, PHY_STATUS, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
-        if(e1000_read_phy_reg(hw, PHY_STATUS, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data)))
+            return ret_val;
+        if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data)))
+            return ret_val;
+
         if(phy_data & MII_SR_LINK_STATUS) {
             /* We have link, so we need to finish the config process:
              *   1) Set up the MAC to the current PHY speed/duplex
@@ -1007,13 +1177,21 @@ e1000_setup_copper_link(struct e1000_hw 
                 return ret_val;
             }
             DEBUGOUT("Valid link established!!!\n");
-            return 0;
+
+            if(hw->phy_type == e1000_phy_igp) {
+                if((ret_val = e1000_config_dsp_after_link_change(hw, TRUE))) {
+                    DEBUGOUT("Error Configuring DSP after link up\n");
+                    return ret_val;
+                }
+            }
+            DEBUGOUT("Valid link established!!!\n");
+            return E1000_SUCCESS;
         }
         udelay(10);
     }
 
     DEBUGOUT("Unable to establish link!!!\n");
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -1557,6 +1728,7 @@ e1000_config_fc_after_link_up(struct e10
      * configuration of the MAC to match the "fc" parameter.
      */
     if(((hw->media_type == e1000_media_type_fiber) && (hw->autoneg_failed)) ||
+       ((hw->media_type == e1000_media_type_internal_serdes) && (hw->autoneg_failed)) ||
        ((hw->media_type == e1000_media_type_copper) && (!hw->autoneg))) {
         ret_val = e1000_force_mac_fc(hw);
         if(ret_val < 0) {
@@ -1704,7 +1861,7 @@ e1000_config_fc_after_link_up(struct e10
                     hw->original_fc == e1000_fc_tx_pause) {
                 hw->fc = e1000_fc_none;
                 DEBUGOUT("Flow Control = NONE.\r\n");
-            } else {
+            } else if(!hw->fc_strict_ieee) {
                 hw->fc = e1000_fc_rx_pause;
                 DEBUGOUT("Flow Control = RX PAUSE frames only.\r\n");
             }
@@ -1747,19 +1904,19 @@ e1000_check_for_link(struct e1000_hw *hw
     uint32_t ctrl;
     uint32_t status;
     uint32_t rctl;
-    uint32_t signal;
+    uint32_t signal = 0;
     int32_t ret_val;
     uint16_t phy_data;
     uint16_t lp_capability;
 
     DEBUGFUNC("e1000_check_for_link");
 
-    /* On adapters with a MAC newer that 82544, SW Defineable pin 1 will be
+    /* On adapters with a MAC newer than 82544, SW Defineable pin 1 will be
      * set when the optics detect a signal. On older adapters, it will be
-     * cleared when there is a signal
+     * cleared when there is a signal.  This applies to fiber media only.
      */
-    if(hw->mac_type > e1000_82544) signal = E1000_CTRL_SWDPIN1;
-    else signal = 0;
+    if(hw->media_type == e1000_media_type_fiber)
+        signal = (hw->mac_type > e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
 
     ctrl = E1000_READ_REG(hw, CTRL);
     status = E1000_READ_REG(hw, STATUS);
@@ -1794,6 +1951,7 @@ e1000_check_for_link(struct e1000_hw *hw
 
         } else {
             /* No link detected */
+            e1000_config_dsp_after_link_change(hw, FALSE);
             return 0;
         }
 
@@ -1802,6 +1960,9 @@ e1000_check_for_link(struct e1000_hw *hw
          */
         if(!hw->autoneg) return -E1000_ERR_CONFIG;
 
+        /* optimize the dsp settings for the igp phy */
+        e1000_config_dsp_after_link_change(hw, TRUE);
+
         /* We have a M88E1000 PHY and Auto-Neg is enabled.  If we
          * have Si on board that is 82544 or newer, Auto
          * Speed Detection takes care of MAC speed/duplex
@@ -1928,12 +2089,14 @@ e1000_check_for_link(struct e1000_hw *hw
  * speed - Speed of the connection
  * duplex - Duplex setting of the connection
  *****************************************************************************/
-void
+int32_t
 e1000_get_speed_and_duplex(struct e1000_hw *hw,
                            uint16_t *speed,
                            uint16_t *duplex)
 {
     uint32_t status;
+    int32_t ret_val;
+    uint16_t phy_data;
 
     DEBUGFUNC("e1000_get_speed_and_duplex");
 
@@ -1962,6 +2125,27 @@ e1000_get_speed_and_duplex(struct e1000_
         *speed = SPEED_1000;
         *duplex = FULL_DUPLEX;
     }
+
+    /* IGP01 PHY may advertise full duplex operation after speed downgrade even
+     * if it is operating at half duplex.  Here we set the duplex settings to
+     * match the duplex in the link partner's capabilities.
+     */
+    if(hw->phy_type == e1000_phy_igp && hw->speed_downgraded) {
+        if((ret_val = e1000_read_phy_reg(hw, PHY_AUTONEG_EXP, &phy_data)))
+            return ret_val;
+
+        if(!(phy_data & NWAY_ER_LP_NWAY_CAPS))
+            *duplex = HALF_DUPLEX;
+        else {
+            if((ret_val == e1000_read_phy_reg(hw, PHY_LP_ABILITY, &phy_data)))
+                return ret_val;
+            if((*speed == SPEED_100 && !(phy_data & NWAY_LPAR_100TX_FD_CAPS)) ||
+               (*speed == SPEED_10 && !(phy_data & NWAY_LPAR_10T_FD_CAPS)))
+                *duplex = HALF_DUPLEX;
+        }
+    }
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -2010,11 +2194,11 @@ e1000_raise_mdi_clk(struct e1000_hw *hw,
                     uint32_t *ctrl)
 {
     /* Raise the clock input to the Management Data Clock (by setting the MDC
-     * bit), and then delay 2 microseconds.
+     * bit), and then delay 10 microseconds.
      */
     E1000_WRITE_REG(hw, CTRL, (*ctrl | E1000_CTRL_MDC));
     E1000_WRITE_FLUSH(hw);
-    udelay(2);
+    udelay(10);
 }
 
 /******************************************************************************
@@ -2028,11 +2212,11 @@ e1000_lower_mdi_clk(struct e1000_hw *hw,
                     uint32_t *ctrl)
 {
     /* Lower the clock input to the Management Data Clock (by clearing the MDC
-     * bit), and then delay 2 microseconds.
+     * bit), and then delay 10 microseconds.
      */
     E1000_WRITE_REG(hw, CTRL, (*ctrl & ~E1000_CTRL_MDC));
     E1000_WRITE_FLUSH(hw);
-    udelay(2);
+    udelay(10);
 }
 
 /******************************************************************************
@@ -2076,7 +2260,7 @@ e1000_shift_out_mdi_bits(struct e1000_hw
         E1000_WRITE_REG(hw, CTRL, ctrl);
         E1000_WRITE_FLUSH(hw);
 
-        udelay(2);
+        udelay(10);
 
         e1000_raise_mdi_clk(hw, &ctrl);
         e1000_lower_mdi_clk(hw, &ctrl);
@@ -2138,8 +2322,8 @@ e1000_shift_in_mdi_bits(struct e1000_hw 
 }
 
 /*****************************************************************************
-* Reads the value from a PHY register
-*
+* Reads the value from a PHY register, if the value is on a specific non zero
+* page, sets the page first.
 * hw - Struct containing variables accessed by shared code
 * reg_addr - address of the PHY register to read
 ******************************************************************************/
@@ -2148,11 +2332,33 @@ e1000_read_phy_reg(struct e1000_hw *hw,
                    uint32_t reg_addr,
                    uint16_t *phy_data)
 {
+    uint32_t ret_val;
+
+    DEBUGFUNC("e1000_read_phy_reg");
+
+    if(hw->phy_type == e1000_phy_igp &&
+       (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
+        if((ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
+                                             (uint16_t)reg_addr)))
+            return ret_val;
+    }
+
+    ret_val = e1000_read_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+                                    phy_data);
+
+    return ret_val;
+}
+
+int32_t
+e1000_read_phy_reg_ex(struct e1000_hw *hw,
+                      uint32_t reg_addr,
+                      uint16_t *phy_data)
+{
     uint32_t i;
     uint32_t mdic = 0;
     const uint32_t phy_addr = 1;
 
-    DEBUGFUNC("e1000_read_phy_reg");
+    DEBUGFUNC("e1000_read_phy_reg_ex");
 
     if(reg_addr > MAX_PHY_REG_ADDRESS) {
         DEBUGOUT1("PHY Address %d is out of range\n", reg_addr);
@@ -2172,7 +2378,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
 
         /* Poll the ready bit to see if the MDI read completed */
         for(i = 0; i < 64; i++) {
-            udelay(10);
+            udelay(50);
             mdic = E1000_READ_REG(hw, MDIC);
             if(mdic & E1000_MDIC_READY) break;
         }
@@ -2214,7 +2420,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
          */
         *phy_data = e1000_shift_in_mdi_bits(hw);
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -2229,11 +2435,33 @@ e1000_write_phy_reg(struct e1000_hw *hw,
                     uint32_t reg_addr,
                     uint16_t phy_data)
 {
+    uint32_t ret_val;
+
+    DEBUGFUNC("e1000_write_phy_reg");
+
+    if(hw->phy_type == e1000_phy_igp &&
+       (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
+        if((ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
+                                             (uint16_t)reg_addr)))
+            return ret_val;
+    }
+
+    ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+                                     phy_data);
+
+    return ret_val;
+}
+
+int32_t
+e1000_write_phy_reg_ex(struct e1000_hw *hw,
+                    uint32_t reg_addr,
+                    uint16_t phy_data)
+{
     uint32_t i;
     uint32_t mdic = 0;
     const uint32_t phy_addr = 1;
 
-    DEBUGFUNC("e1000_write_phy_reg");
+    DEBUGFUNC("e1000_write_phy_reg_ex");
 
     if(reg_addr > MAX_PHY_REG_ADDRESS) {
         DEBUGOUT1("PHY Address %d is out of range\n", reg_addr);
@@ -2254,7 +2482,7 @@ e1000_write_phy_reg(struct e1000_hw *hw,
 
         /* Poll the ready bit to see if the MDI read completed */
         for(i = 0; i < 64; i++) {
-            udelay(10);
+            udelay(50);
             mdic = E1000_READ_REG(hw, MDIC);
             if(mdic & E1000_MDIC_READY) break;
         }
@@ -2284,7 +2512,7 @@ e1000_write_phy_reg(struct e1000_hw *hw,
         e1000_shift_out_mdi_bits(hw, mdic, 32);
     }
 
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -2329,11 +2553,6 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
     udelay(150);
 
     if((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
-        if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 0x0000) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return;
-        }
-
         /* Configure activity LED after PHY reset */
         led_ctrl = E1000_READ_REG(hw, LEDCTL);
         led_ctrl &= IGP_ACTIVITY_LED_MASK;
@@ -2352,24 +2575,26 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
 int32_t
 e1000_phy_reset(struct e1000_hw *hw)
 {
+    int32_t ret_val;
     uint16_t phy_data;
 
     DEBUGFUNC("e1000_phy_reset");
 
-    if(e1000_read_phy_reg(hw, PHY_CTRL, &phy_data) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
-    phy_data |= MII_CR_RESET;
-    if(e1000_write_phy_reg(hw, PHY_CTRL, phy_data) < 0) {
-        DEBUGOUT("PHY Write Error\n");
-        return -E1000_ERR_PHY;
-    }
-    udelay(1);
-    if (hw->phy_type == e1000_phy_igp) {
+    if(hw->mac_type != e1000_82541_rev_2) {
+        if((ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data)))
+            return ret_val;
+
+        phy_data |= MII_CR_RESET;
+        if((ret_val = e1000_write_phy_reg(hw, PHY_CTRL, phy_data)))
+            return ret_val;
+
+        udelay(1);
+    } else e1000_phy_hw_reset(hw);
+
+    if(hw->phy_type == e1000_phy_igp)
         e1000_phy_init_script(hw);
-    }
-    return 0;
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -2409,11 +2634,15 @@ e1000_detect_gig_phy(struct e1000_hw *hw
         break;
     case e1000_82540:
     case e1000_82545:
+    case e1000_82545_rev_3:
     case e1000_82546:
+    case e1000_82546_rev_3:
         if(hw->phy_id == M88E1011_I_PHY_ID) match = TRUE;
         break;
     case e1000_82541:
+    case e1000_82541_rev_2:
     case e1000_82547:
+    case e1000_82547_rev_2:
         if(hw->phy_id == IGP01E1000_I_PHY_ID) match = TRUE;
         break;
     default:
@@ -2438,17 +2667,16 @@ e1000_detect_gig_phy(struct e1000_hw *hw
 static int32_t
 e1000_phy_reset_dsp(struct e1000_hw *hw)
 {
-    int32_t ret_val = -E1000_ERR_PHY;
+    int32_t ret_val;
     DEBUGFUNC("e1000_phy_reset_dsp");
 
     do {
-        if(e1000_write_phy_reg(hw, 29, 0x001d) < 0) break;
-        if(e1000_write_phy_reg(hw, 30, 0x00c1) < 0) break;
-        if(e1000_write_phy_reg(hw, 30, 0x0000) < 0) break;
-        ret_val = 0;
+        if((ret_val = e1000_write_phy_reg(hw, 29, 0x001d))) break;
+        if((ret_val = e1000_write_phy_reg(hw, 30, 0x00c1))) break;
+        if((ret_val = e1000_write_phy_reg(hw, 30, 0x0000))) break;
+        ret_val = E1000_SUCCESS;
     } while(0);
 
-    if(ret_val < 0) DEBUGOUT("PHY Write Error\n");
     return ret_val;
 }
 
@@ -2459,8 +2687,10 @@ e1000_phy_reset_dsp(struct e1000_hw *hw)
 * phy_info - PHY information structure
 ******************************************************************************/
 int32_t
-e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
+e1000_phy_igp_get_info(struct e1000_hw *hw,
+                       struct e1000_phy_info *phy_info)
 {
+    int32_t ret_val;
     uint16_t phy_data, polarity, min_length, max_length, average;
 
     DEBUGFUNC("e1000_phy_igp_get_info");
@@ -2668,7 +2898,9 @@ e1000_init_eeprom_params(struct e1000_hw
         break;
     case e1000_82540:
     case e1000_82545:
+    case e1000_82545_rev_3:
     case e1000_82546:
+    case e1000_82546_rev_3:
         eeprom->type = e1000_eeprom_microwire;
         eeprom->opcode_bits = 3;
         eeprom->delay_usec = 50;
@@ -2681,8 +2913,9 @@ e1000_init_eeprom_params(struct e1000_hw
         }
         break;
     case e1000_82541:
+    case e1000_82541_rev_2:
     case e1000_82547:
-    default:
+    case e1000_82547_rev_2:
         if (eecd & E1000_EECD_TYPE) {
             eeprom->type = e1000_eeprom_spi;
             eeprom->opcode_bits = 8;
@@ -2707,6 +2940,18 @@ e1000_init_eeprom_params(struct e1000_hw
             }
         }
         break;
+    default:
+        eeprom->type = e1000_eeprom_spi;
+        eeprom->opcode_bits = 8;
+        eeprom->delay_usec = 1;
+        if (eecd & E1000_EECD_ADDR_BITS) {
+            eeprom->page_size = 32;
+            eeprom->address_bits = 16;
+        } else {
+            eeprom->page_size = 8;
+            eeprom->address_bits = 8;
+        }
+        break;
     }
 
     if (eeprom->type == e1000_eeprom_spi) {
@@ -2715,28 +2960,28 @@ e1000_init_eeprom_params(struct e1000_hw
             eeprom_size &= EEPROM_SIZE_MASK;
 
             switch (eeprom_size) {
-                case EEPROM_SIZE_16KB:
-                    eeprom->word_size = 8192;
-                    break;
-                case EEPROM_SIZE_8KB:
-                    eeprom->word_size = 4096;
-                    break;
-                case EEPROM_SIZE_4KB:
-                    eeprom->word_size = 2048;
-                    break;
-                case EEPROM_SIZE_2KB:
-                    eeprom->word_size = 1024;
-                    break;
-                case EEPROM_SIZE_1KB:
-                    eeprom->word_size = 512;
-                    break;
-                case EEPROM_SIZE_512B:
-                    eeprom->word_size = 256;
-                    break;
-                case EEPROM_SIZE_128B:
-                default:
-                    eeprom->word_size = 64;
-                    break;
+            case EEPROM_SIZE_16KB:
+                eeprom->word_size = 8192;
+                break;
+            case EEPROM_SIZE_8KB:
+                eeprom->word_size = 4096;
+                break;
+            case EEPROM_SIZE_4KB:
+                eeprom->word_size = 2048;
+                break;
+            case EEPROM_SIZE_2KB:
+                eeprom->word_size = 1024;
+                break;
+            case EEPROM_SIZE_1KB:
+                eeprom->word_size = 512;
+                break;
+            case EEPROM_SIZE_512B:
+                eeprom->word_size = 256;
+                break;
+            case EEPROM_SIZE_128B:
+            default:
+                eeprom->word_size = 64;
+                break;
             }
         }
     }
@@ -3101,13 +3346,17 @@ e1000_read_eeprom(struct e1000_hw *hw,
     }
 
     /* Prepare the EEPROM for reading  */
-    if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
+    if(e1000_acquire_eeprom(hw) != E1000_SUCCESS)
         return -E1000_ERR_EEPROM;
 
     if(eeprom->type == e1000_eeprom_spi) {
+        uint16_t word_in;
         uint8_t read_opcode = EEPROM_READ_OPCODE_SPI;
 
-        if(e1000_spi_eeprom_ready(hw)) return -E1000_ERR_EEPROM;
+        if(e1000_spi_eeprom_ready(hw)) {
+            e1000_release_eeprom(hw);
+            return -E1000_ERR_EEPROM;
+        }
 
         e1000_standby_eeprom(hw);
 
@@ -3118,30 +3367,35 @@ e1000_read_eeprom(struct e1000_hw *hw,
         /* Send the READ command (opcode + addr)  */
         e1000_shift_out_ee_bits(hw, read_opcode, eeprom->opcode_bits);
         e1000_shift_out_ee_bits(hw, (uint16_t)(offset*2), eeprom->address_bits);
-    }
-    else if(eeprom->type == e1000_eeprom_microwire) {
-        /* Send the READ command (opcode + addr)  */
-        e1000_shift_out_ee_bits(hw, EEPROM_READ_OPCODE_MICROWIRE,
-                                eeprom->opcode_bits);
-        e1000_shift_out_ee_bits(hw, offset, eeprom->address_bits);
-    }
 
-    /* Read the data.  The address of the eeprom internally increments with
-     * each word (microwire) or byte (spi) being read, saving on the overhead
-     * of eeprom setup and tear-down.  The address counter will roll over if
-     * reading beyond the size of the eeprom, thus allowing the entire memory
-     * to be read starting from any offset. */
-    for (i = 0; i < words; i++) {
-        uint16_t word_in = e1000_shift_in_ee_bits(hw, 16);
-        if (eeprom->type == e1000_eeprom_spi)
-            word_in = (word_in >> 8) | (word_in << 8);
-        data[i] = word_in;
+        /* Read the data.  The address of the eeprom internally increments with
+         * each byte (spi) being read, saving on the overhead of eeprom setup
+         * and tear-down.  The address counter will roll over if reading beyond
+         * the size of the eeprom, thus allowing the entire memory to be read
+         * starting from any offset. */
+        for (i = 0; i < words; i++) {
+            word_in = e1000_shift_in_ee_bits(hw, 16);
+            data[i] = (word_in >> 8) | (word_in << 8);
+        }
+    } else if(eeprom->type == e1000_eeprom_microwire) {
+        for (i = 0; i < words; i++) {
+            /* Send the READ command (opcode + addr)  */
+            e1000_shift_out_ee_bits(hw, EEPROM_READ_OPCODE_MICROWIRE,
+                                    eeprom->opcode_bits);
+            e1000_shift_out_ee_bits(hw, (uint16_t)(offset + i),
+                                    eeprom->address_bits);
+
+            /* Read the data.  For microwire, each word requires the overhead
+             * of eeprom setup and tear-down. */
+            data[i] = e1000_shift_in_ee_bits(hw, 16);
+            e1000_standby_eeprom(hw);
+        }
     }
 
     /* End this read operation */
     e1000_release_eeprom(hw);
 
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3463,7 +3717,7 @@ e1000_read_mac_addr(struct e1000_hw * hw
         hw->perm_mac_addr[i] = (uint8_t) (eeprom_data & 0x00FF);
         hw->perm_mac_addr[i+1] = (uint8_t) (eeprom_data >> 8);
     }
-    if((hw->mac_type == e1000_82546) &&
+    if(((hw->mac_type == e1000_82546) || (hw->mac_type == e1000_82546_rev_3)) &&
        (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)) {
         if(hw->perm_mac_addr[5] & 0x01)
             hw->perm_mac_addr[5] &= ~(0x01);
@@ -3811,49 +4065,48 @@ int32_t
 e1000_setup_led(struct e1000_hw *hw)
 {
     uint32_t ledctl;
+    int32_t ret_val = E1000_SUCCESS;
 
     DEBUGFUNC("e1000_setup_led");
 
-    switch(hw->device_id) {
-    case E1000_DEV_ID_82542:
-    case E1000_DEV_ID_82543GC_FIBER:
-    case E1000_DEV_ID_82543GC_COPPER:
-    case E1000_DEV_ID_82544EI_COPPER:
-    case E1000_DEV_ID_82544EI_FIBER:
-    case E1000_DEV_ID_82544GC_COPPER:
-    case E1000_DEV_ID_82544GC_LOM:
+    switch(hw->mac_type) {
+    case e1000_82542_rev2_0:
+    case e1000_82542_rev2_1:
+    case e1000_82543:
+    case e1000_82544:
         /* No setup necessary */
         break;
-    case E1000_DEV_ID_82545EM_FIBER:
-    case E1000_DEV_ID_82546EB_FIBER:
-        ledctl = E1000_READ_REG(hw, LEDCTL);
-        /* Save current LEDCTL settings */
-        hw->ledctl_default = ledctl;
-        /* Turn off LED0 */
-        ledctl &= ~(E1000_LEDCTL_LED0_IVRT |
-                    E1000_LEDCTL_LED0_BLINK |
-                    E1000_LEDCTL_LED0_MODE_MASK);
-        ledctl |= (E1000_LEDCTL_MODE_LED_OFF << E1000_LEDCTL_LED0_MODE_SHIFT);
-        E1000_WRITE_REG(hw, LEDCTL, ledctl);
+    case e1000_82541:
+    case e1000_82547:
+    case e1000_82541_rev_2:
+    case e1000_82547_rev_2:
+        /* Turn off PHY Smart Power Down (if enabled) */
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_GMII_FIFO,
+                                         &hw->phy_spd_default)))
+            return ret_val;
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO,
+                                          (uint16_t)(hw->phy_spd_default &
+                                          ~IGP01E1000_GMII_SPD))))
+            return ret_val;
+        /* Fall Through */
+    default:
+        if(hw->media_type == e1000_media_type_fiber) {
+            ledctl = E1000_READ_REG(hw, LEDCTL);
+            /* Save current LEDCTL settings */
+            hw->ledctl_default = ledctl;
+            /* Turn off LED0 */
+            ledctl &= ~(E1000_LEDCTL_LED0_IVRT |
+                        E1000_LEDCTL_LED0_BLINK |
+                        E1000_LEDCTL_LED0_MODE_MASK);
+            ledctl |= (E1000_LEDCTL_MODE_LED_OFF <<
+                       E1000_LEDCTL_LED0_MODE_SHIFT);
+            E1000_WRITE_REG(hw, LEDCTL, ledctl);
+        } else if(hw->media_type == e1000_media_type_copper)
+            E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
         break;
-    case E1000_DEV_ID_82540EP:
-    case E1000_DEV_ID_82540EP_LOM:
-    case E1000_DEV_ID_82540EP_LP:
-    case E1000_DEV_ID_82540EM:
-    case E1000_DEV_ID_82540EM_LOM:
-    case E1000_DEV_ID_82545EM_COPPER:
-    case E1000_DEV_ID_82546EB_COPPER:
-    case E1000_DEV_ID_82546EB_QUAD_COPPER:
-    case E1000_DEV_ID_82541EI:
-    case E1000_DEV_ID_82541EP:
-    case E1000_DEV_ID_82547EI:
-        E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
-        break;
-    default:
-        DEBUGOUT("Invalid device ID\n");
-        return -E1000_ERR_CONFIG;
     }
-    return 0;
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3864,39 +4117,33 @@ e1000_setup_led(struct e1000_hw *hw)
 int32_t
 e1000_cleanup_led(struct e1000_hw *hw)
 {
+    int32_t ret_val = E1000_SUCCESS;
+
     DEBUGFUNC("e1000_cleanup_led");
 
-    switch(hw->device_id) {
-    case E1000_DEV_ID_82542:
-    case E1000_DEV_ID_82543GC_FIBER:
-    case E1000_DEV_ID_82543GC_COPPER:
-    case E1000_DEV_ID_82544EI_COPPER:
-    case E1000_DEV_ID_82544EI_FIBER:
-    case E1000_DEV_ID_82544GC_COPPER:
-    case E1000_DEV_ID_82544GC_LOM:
+    switch(hw->mac_type) {
+    case e1000_82542_rev2_0:
+    case e1000_82542_rev2_1:
+    case e1000_82543:
+    case e1000_82544:
         /* No cleanup necessary */
         break;
-    case E1000_DEV_ID_82540EP:
-    case E1000_DEV_ID_82540EP_LOM:
-    case E1000_DEV_ID_82540EP_LP:
-    case E1000_DEV_ID_82540EM:
-    case E1000_DEV_ID_82540EM_LOM:
-    case E1000_DEV_ID_82545EM_COPPER:
-    case E1000_DEV_ID_82545EM_FIBER:
-    case E1000_DEV_ID_82546EB_COPPER:
-    case E1000_DEV_ID_82546EB_FIBER:
-    case E1000_DEV_ID_82546EB_QUAD_COPPER:
-    case E1000_DEV_ID_82541EI:
-    case E1000_DEV_ID_82541EP:
-    case E1000_DEV_ID_82547EI:
+    case e1000_82541:
+    case e1000_82547:
+    case e1000_82541_rev_2:
+    case e1000_82547_rev_2:
+        /* Turn on PHY Smart Power Down (if previously enabled) */
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO,
+                                          hw->phy_spd_default)))
+            return ret_val;
+        /* Fall Through */
+    default:
         /* Restore LEDCTL settings */
         E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_default);
         break;
-    default:
-        DEBUGOUT("Invalid device ID\n");
-        return -E1000_ERR_CONFIG;
     }
-    return 0;
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3907,50 +4154,44 @@ e1000_cleanup_led(struct e1000_hw *hw)
 int32_t
 e1000_led_on(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    uint32_t ctrl = E1000_READ_REG(hw, CTRL);
 
     DEBUGFUNC("e1000_led_on");
 
-    switch(hw->device_id) {
-    case E1000_DEV_ID_82542:
-    case E1000_DEV_ID_82543GC_FIBER:
-    case E1000_DEV_ID_82543GC_COPPER:
-    case E1000_DEV_ID_82544EI_FIBER:
-        ctrl = E1000_READ_REG(hw, CTRL);
+    switch(hw->mac_type) {
+    case e1000_82542_rev2_0:
+    case e1000_82542_rev2_1:
+    case e1000_82543:
         /* Set SW Defineable Pin 0 to turn on the LED */
         ctrl |= E1000_CTRL_SWDPIN0;
         ctrl |= E1000_CTRL_SWDPIO0;
-        E1000_WRITE_REG(hw, CTRL, ctrl);
-        break;
-    case E1000_DEV_ID_82544EI_COPPER:
-    case E1000_DEV_ID_82544GC_COPPER:
-    case E1000_DEV_ID_82544GC_LOM:
-    case E1000_DEV_ID_82545EM_FIBER:
-    case E1000_DEV_ID_82546EB_FIBER:
-        ctrl = E1000_READ_REG(hw, CTRL);
-        /* Clear SW Defineable Pin 0 to turn on the LED */
-        ctrl &= ~E1000_CTRL_SWDPIN0;
-        ctrl |= E1000_CTRL_SWDPIO0;
-        E1000_WRITE_REG(hw, CTRL, ctrl);
         break;
-    case E1000_DEV_ID_82540EP:
-    case E1000_DEV_ID_82540EP_LOM:
-    case E1000_DEV_ID_82540EP_LP:
-    case E1000_DEV_ID_82540EM:
-    case E1000_DEV_ID_82540EM_LOM:
-    case E1000_DEV_ID_82545EM_COPPER:
-    case E1000_DEV_ID_82546EB_COPPER:
-    case E1000_DEV_ID_82546EB_QUAD_COPPER:
-    case E1000_DEV_ID_82541EI:
-    case E1000_DEV_ID_82541EP:
-    case E1000_DEV_ID_82547EI:
-        E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode2);
+    case e1000_82544:
+        if(hw->media_type == e1000_media_type_fiber) {
+            /* Set SW Defineable Pin 0 to turn on the LED */
+            ctrl |= E1000_CTRL_SWDPIN0;
+            ctrl |= E1000_CTRL_SWDPIO0;
+        } else {
+            /* Clear SW Defineable Pin 0 to turn on the LED */
+            ctrl &= ~E1000_CTRL_SWDPIN0;
+            ctrl |= E1000_CTRL_SWDPIO0;
+        }
         break;
     default:
-        DEBUGOUT("Invalid device ID\n");
-        return -E1000_ERR_CONFIG;
+        if(hw->media_type == e1000_media_type_fiber) {
+            /* Clear SW Defineable Pin 0 to turn on the LED */
+            ctrl &= ~E1000_CTRL_SWDPIN0;
+            ctrl |= E1000_CTRL_SWDPIO0;
+        } else if(hw->media_type == e1000_media_type_copper) {
+            E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode2);
+            return E1000_SUCCESS;
+        }
+        break;
     }
-    return 0;
+
+    E1000_WRITE_REG(hw, CTRL, ctrl);
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3961,50 +4202,44 @@ e1000_led_on(struct e1000_hw *hw)
 int32_t
 e1000_led_off(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    uint32_t ctrl = E1000_READ_REG(hw, CTRL);
 
     DEBUGFUNC("e1000_led_off");
 
-    switch(hw->device_id) {
-    case E1000_DEV_ID_82542:
-    case E1000_DEV_ID_82543GC_FIBER:
-    case E1000_DEV_ID_82543GC_COPPER:
-    case E1000_DEV_ID_82544EI_FIBER:
-        ctrl = E1000_READ_REG(hw, CTRL);
+    switch(hw->mac_type) {
+    case e1000_82542_rev2_0:
+    case e1000_82542_rev2_1:
+    case e1000_82543:
         /* Clear SW Defineable Pin 0 to turn off the LED */
         ctrl &= ~E1000_CTRL_SWDPIN0;
         ctrl |= E1000_CTRL_SWDPIO0;
-        E1000_WRITE_REG(hw, CTRL, ctrl);
-        break;
-    case E1000_DEV_ID_82544EI_COPPER:
-    case E1000_DEV_ID_82544GC_COPPER:
-    case E1000_DEV_ID_82544GC_LOM:
-    case E1000_DEV_ID_82545EM_FIBER:
-    case E1000_DEV_ID_82546EB_FIBER:
-        ctrl = E1000_READ_REG(hw, CTRL);
-        /* Set SW Defineable Pin 0 to turn off the LED */
-        ctrl |= E1000_CTRL_SWDPIN0;
-        ctrl |= E1000_CTRL_SWDPIO0;
-        E1000_WRITE_REG(hw, CTRL, ctrl);
         break;
-    case E1000_DEV_ID_82540EP:
-    case E1000_DEV_ID_82540EP_LOM:
-    case E1000_DEV_ID_82540EP_LP:
-    case E1000_DEV_ID_82540EM:
-    case E1000_DEV_ID_82540EM_LOM:
-    case E1000_DEV_ID_82545EM_COPPER:
-    case E1000_DEV_ID_82546EB_COPPER:
-    case E1000_DEV_ID_82546EB_QUAD_COPPER:
-    case E1000_DEV_ID_82541EI:
-    case E1000_DEV_ID_82541EP:
-    case E1000_DEV_ID_82547EI:
-        E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
+    case e1000_82544:
+        if(hw->media_type == e1000_media_type_fiber) {
+            /* Clear SW Defineable Pin 0 to turn off the LED */
+            ctrl &= ~E1000_CTRL_SWDPIN0;
+            ctrl |= E1000_CTRL_SWDPIO0;
+        } else {
+            /* Set SW Defineable Pin 0 to turn off the LED */
+            ctrl |= E1000_CTRL_SWDPIN0;
+            ctrl |= E1000_CTRL_SWDPIO0;
+        }
         break;
     default:
-        DEBUGOUT("Invalid device ID\n");
-        return -E1000_ERR_CONFIG;
+        if(hw->media_type == e1000_media_type_fiber) {
+            /* Set SW Defineable Pin 0 to turn off the LED */
+            ctrl |= E1000_CTRL_SWDPIN0;
+            ctrl |= E1000_CTRL_SWDPIO0;
+        } else if(hw->media_type == e1000_media_type_copper) {
+            E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
+            return E1000_SUCCESS;
+        }
+        break;
     }
-    return 0;
+
+    E1000_WRITE_REG(hw, CTRL, ctrl);
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -4324,7 +4559,8 @@ e1000_write_reg_io(struct e1000_hw *hw,
  * min_length - The estimated minimum length
  * max_length - The estimated maximum length
  *
- * returns: E1000_SUCCESS / -E1000_ERR_XXX
+ * returns: - E1000_ERR_XXX
+ *            E1000_SUCCESS
  *
  * This function always returns a ranged length (minimum & maximum).
  * So for M88 phy's, this function interprets the one value returned from the
@@ -4439,7 +4675,8 @@ e1000_get_cable_length(struct e1000_hw *
  * polarity - output parameter : 0 - Polarity is not reversed
  *                               1 - Polarity is reversed.
  *
- * returns: E1000_SUCCESS / -E1000_ERR_XXX
+ * returns: - E1000_ERR_XXX
+ *            E1000_SUCCESS
  *
  * For phy's older then IGP, this function simply reads the polarity bit in the
  * Phy Status register.  For IGP phy's, this bit is valid only if link speed is
@@ -4471,18 +4708,9 @@ e1000_check_polarity(struct e1000_hw *hw
            IGP01E1000_PSSR_SPEED_1000MBPS) {
 
             /* Read the GIG initialization PCS register (0x00B4) */
-            if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                   IGP01E1000_PHY_PCS_INIT_REG) < 0)
-                return -E1000_ERR_PHY;
-
-            if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PCS_INIT_REG &
-                                  IGP01E1000_PHY_PAGE_SELECT, &phy_data) < 0)
-                return -E1000_ERR_PHY;
-
-            /* Return to page 0 */
-            if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 0x0) !=
-               E1000_SUCCESS)
-                return -E1000_ERR_PHY;
+            if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PCS_INIT_REG,
+                                             &phy_data)))
+                return ret_val;
 
             /* Check the polarity bits */
             *polarity = (phy_data & IGP01E1000_PHY_POLARITY_MASK) ? 1 : 0;
@@ -4502,7 +4730,8 @@ e1000_check_polarity(struct e1000_hw *hw
  * downshift - output parameter : 0 - No Downshift ocured.
  *                                1 - Downshift ocured.
  *
- * returns: E1000_SUCCESS / -E1000_ERR_XXX
+ * returns: - E1000_ERR_XXX
+ *            E1000_SUCCESS 
  *
  * For phy's older then IGP, this function reads the Downshift bit in the Phy
  * Specific Status register.  For IGP phy's, it reads the Downgrade bit in the
@@ -4512,25 +4738,287 @@ e1000_check_polarity(struct e1000_hw *hw
 int32_t
 e1000_check_downshift(struct e1000_hw *hw)
 {
+    int32_t ret_val;
     uint16_t phy_data;
 
     DEBUGFUNC("e1000_check_downshift");
 
     if(hw->phy_type == e1000_phy_igp) {
-        if(e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH,
+                                         &phy_data)))
+            return ret_val;
+
         hw->speed_downgraded = (phy_data & IGP01E1000_PLHR_SS_DOWNGRADE) ? 1 : 0;
     }
     else if(hw->phy_type == e1000_phy_m88) {
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
+                                         &phy_data)))
+            return ret_val;
+
         hw->speed_downgraded = (phy_data & M88E1000_PSSR_DOWNSHIFT) >>
-                                M88E1000_PSSR_DOWNSHIFT_SHIFT;
+                               M88E1000_PSSR_DOWNSHIFT_SHIFT;
+    }
+    return E1000_SUCCESS;
+}
+
+/*****************************************************************************
+ *
+ * 82541_rev_2 & 82547_rev_2 have the capability to configure the DSP when a
+ * gigabit link is achieved to improve link quality.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ * returns: - E1000_ERR_PHY if fail to read/write the PHY
+ *            E1000_SUCCESS at any other case.
+ *
+ ****************************************************************************/
+
+int32_t
+e1000_config_dsp_after_link_change(struct e1000_hw *hw,
+                                   boolean_t link_up)
+{
+    int32_t ret_val;
+    uint16_t phy_data, speed, duplex, i;
+    uint16_t dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
+                                        {IGP01E1000_PHY_AGC_PARAM_A,
+                                        IGP01E1000_PHY_AGC_PARAM_B,
+                                        IGP01E1000_PHY_AGC_PARAM_C,
+                                        IGP01E1000_PHY_AGC_PARAM_D};
+    uint16_t min_length, max_length;
+
+    DEBUGFUNC("e1000_config_dsp_after_link_change");
+
+    if(hw->phy_type != e1000_phy_igp)
+        return E1000_SUCCESS;
+
+    if(link_up) {
+        if((ret_val = e1000_get_speed_and_duplex(hw, &speed, &duplex))) {
+            DEBUGOUT("Error getting link speed and duplex\n");
+            return ret_val;
+        }
+
+        if(speed == SPEED_1000) {
+
+            e1000_get_cable_length(hw, &min_length, &max_length);
+
+            if((hw->dsp_config_state == e1000_dsp_config_enabled) &&
+                min_length >= e1000_igp_cable_length_50) {
+
+                for(i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
+                    if((ret_val = e1000_read_phy_reg(hw, dsp_reg_array[i],
+                                                     &phy_data)))
+                        return ret_val;
+
+                    phy_data &= ~IGP01E1000_PHY_EDAC_MU_INDEX;
+
+                    if((ret_val = e1000_write_phy_reg(hw, dsp_reg_array[i],
+                                                      phy_data)))
+                        return ret_val;
+                }
+                hw->dsp_config_state = e1000_dsp_config_activated;
+            }
+
+            if((hw->ffe_config_state == e1000_ffe_config_enabled) &&
+               (min_length < e1000_igp_cable_length_50)) {
+
+                uint16_t ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
+                uint32_t idle_errs = 0;
+
+                /* clear previous idle error counts */
+                if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS,
+                                                 &phy_data)))
+                    return ret_val;
+
+                for(i = 0; i < ffe_idle_err_timeout; i++) {
+                    udelay(1000);
+                    if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS,
+                                                     &phy_data)))
+                        return ret_val;
+
+                    idle_errs += (phy_data & SR_1000T_IDLE_ERROR_CNT);
+                    if(idle_errs > SR_1000T_PHY_EXCESSIVE_IDLE_ERR_COUNT) {
+                        hw->ffe_config_state = e1000_ffe_config_active;
+
+                        if((ret_val = e1000_write_phy_reg(hw,
+                                    IGP01E1000_PHY_DSP_FFE,
+                                    IGP01E1000_PHY_DSP_FFE_CM_CP)))
+                            return ret_val;
+                        break;
+                    }
+
+                    if(idle_errs)
+                        ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_100;
+                }
+            }
+        }
+    } else {
+        if(hw->dsp_config_state == e1000_dsp_config_activated) {
+            if((ret_val = e1000_write_phy_reg(hw, 0x0000,
+                IGP01E1000_IEEE_FORCE_GIGA)))
+                return ret_val;
+            for(i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
+                if((ret_val = e1000_read_phy_reg(hw, dsp_reg_array[i],
+                                                 &phy_data)))
+                    return ret_val;
+
+                phy_data &= ~IGP01E1000_PHY_EDAC_MU_INDEX;
+                phy_data |=  IGP01E1000_PHY_EDAC_SIGN_EXT_9_BITS;
+
+                if((ret_val = e1000_write_phy_reg(hw,dsp_reg_array[i],
+                                                  phy_data)))
+                    return ret_val;
+            }
+
+            if((ret_val = e1000_write_phy_reg(hw, 0x0000,
+                                              IGP01E1000_IEEE_RESTART_AUTONEG)))
+                return ret_val;
+
+            hw->dsp_config_state = e1000_dsp_config_enabled;
+        }
+
+        if(hw->ffe_config_state == e1000_ffe_config_active) {
+            if((ret_val = e1000_write_phy_reg(hw, 0x0000,
+                                              IGP01E1000_IEEE_FORCE_GIGA)))
+                return ret_val;
+            if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_DSP_FFE,
+                                              IGP01E1000_PHY_DSP_FFE_DEFAULT)))
+                return ret_val;
+
+            if((ret_val = e1000_write_phy_reg(hw, 0x0000,
+                                              IGP01E1000_IEEE_RESTART_AUTONEG)))
+                return ret_val;
+        hw->ffe_config_state = e1000_ffe_config_enabled;
+        }
+    }
+    return E1000_SUCCESS;
+}
+
+/*****************************************************************************
+ *
+ * This function sets the lplu state according to the active flag.  When
+ * activating lplu this function also disables smart speed and vise versa.
+ * lplu will not be activated unless the device autonegotiation advertisment
+ * meets standards of either 10 or 10/100 or 10/100/1000 at all duplexes.
+ * hw: Struct containing variables accessed by shared code
+ * active - true to enable lplu false to disable lplu.
+ *
+ * returns: - E1000_ERR_PHY if fail to read/write the PHY
+ *            E1000_SUCCESS at any other case.
+ *
+ ****************************************************************************/
+
+int32_t
+e1000_set_d3_lplu_state(struct e1000_hw *hw,
+                        boolean_t active)
+{
+    int32_t ret_val;
+    uint16_t phy_data;
+    DEBUGFUNC("e1000_set_d3_lplu_state");
+
+    if(!((hw->mac_type == e1000_82541_rev_2) ||
+         (hw->mac_type == e1000_82547_rev_2)))
+        return E1000_SUCCESS;
+
+    /* During driver activity LPLU should not be used or it will attain link
+     * from the lowest speeds starting from 10Mbps. The capability is used for
+     * Dx transitions and states */
+    if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_GMII_FIFO, &phy_data)))
+        return ret_val;
+
+    if(!active) {
+        phy_data &= ~IGP01E1000_GMII_FLEX_SPD;
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO, phy_data)))
+            return ret_val;
+
+        /* LPLU and SmartSpeed are mutually exclusive.  LPLU is used during
+         * Dx states where the power conservation is most important.  During
+         * driver activity we should enable SmartSpeed, so performance is
+         * maintained. */
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                         &phy_data)))
+            return ret_val;
+
+        phy_data |= IGP01E1000_PSCFR_SMART_SPEED;
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                          phy_data)))
+            return ret_val;
+
+    } else if((hw->autoneg_advertised == AUTONEG_ADVERTISE_SPEED_DEFAULT) ||
+              (hw->autoneg_advertised == AUTONEG_ADVERTISE_10_ALL ) ||
+              (hw->autoneg_advertised == AUTONEG_ADVERTISE_10_100_ALL)) {
+
+        phy_data |= IGP01E1000_GMII_FLEX_SPD;
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO, phy_data)))
+            return ret_val;
+
+        /* When LPLU is enabled we should disable SmartSpeed */
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                         &phy_data)))
+            return ret_val;
+
+        phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                          phy_data)))
+            return ret_val;
+
     }
     return E1000_SUCCESS;
 }
 
+/******************************************************************************
+ * Change VCO speed register to improve Bit Error Rate performance of SERDES.
+ *
+ * hw - Struct containing variables accessed by shared code
+ *****************************************************************************/
+static int32_t
+e1000_set_vco_speed(struct e1000_hw *hw)
+{
+    int32_t  ret_val;
+    uint16_t default_page = 0;
+    uint16_t phy_data;
+
+    DEBUGFUNC("e1000_set_vco_speed");
+
+    switch(hw->mac_type) {
+    case e1000_82545_rev_3:
+    case e1000_82546_rev_3:
+       break;
+    default:
+        return E1000_SUCCESS;
+    }
+
+    /* Set PHY register 30, page 5, bit 8 to 0 */
+
+    if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_PAGE_SELECT,
+                                     &default_page)))
+        return ret_val;
+
+    if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0005)))
+        return ret_val;
+
+    if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, &phy_data)))
+        return ret_val;
+
+    phy_data &= ~M88E1000_PHY_VCO_REG_BIT8;
+    if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, phy_data)))
+        return ret_val;
+
+    /* Set PHY register 30, page 4, bit 11 to 1 */
+
+    if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT, 0x0004)))
+        return ret_val;
+
+    if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, &phy_data)))
+        return ret_val;
+
+    phy_data |= M88E1000_PHY_VCO_REG_BIT11;
+    if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL, phy_data)))
+        return ret_val;
+
+    if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT,
+                                      default_page)))
+        return ret_val;
+
+    return E1000_SUCCESS;
+}
+
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h	2003-08-22 16:58:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h	2003-09-08 09:13:16.000000000 -0700
@@ -50,9 +50,13 @@ typedef enum {
     e1000_82544,
     e1000_82540,
     e1000_82545,
+    e1000_82545_rev_3,
     e1000_82546,
+    e1000_82546_rev_3,
     e1000_82541,
+    e1000_82541_rev_2,
     e1000_82547,
+    e1000_82547_rev_2,
     e1000_num_macs
 } e1000_mac_type;
 
@@ -67,6 +71,7 @@ typedef enum {
 typedef enum {
     e1000_media_type_copper = 0,
     e1000_media_type_fiber = 1,
+    e1000_media_type_internal_serdes = 2,
     e1000_num_media_types
 } e1000_media_type;
 
@@ -90,7 +95,8 @@ typedef enum {
 typedef enum {
     e1000_bus_type_unknown = 0,
     e1000_bus_type_pci,
-    e1000_bus_type_pcix
+    e1000_bus_type_pcix,
+    e1000_bus_type_reserved
 } e1000_bus_type;
 
 /* PCI bus speeds */
@@ -108,7 +114,8 @@ typedef enum {
 typedef enum {
     e1000_bus_width_unknown = 0,
     e1000_bus_width_32,
-    e1000_bus_width_64
+    e1000_bus_width_64,
+    e1000_bus_width_reserved
 } e1000_bus_width;
 
 /* PHY status info structure and supporting enums */
@@ -186,6 +193,26 @@ typedef enum {
     e1000_phy_undefined = 0xFF
 } e1000_phy_type;
 
+typedef enum {
+    e1000_ms_hw_default = 0,
+    e1000_ms_force_master,
+    e1000_ms_force_slave,
+    e1000_ms_auto
+} e1000_ms_type;
+
+typedef enum {
+    e1000_ffe_config_enabled = 0,
+    e1000_ffe_config_active,
+    e1000_ffe_config_blocked
+} e1000_ffe_config;
+
+typedef enum {
+    e1000_dsp_config_disabled = 0,
+    e1000_dsp_config_enabled,
+    e1000_dsp_config_activated,
+    e1000_dsp_config_undefined = 0xFF
+} e1000_dsp_config;
+
 struct e1000_phy_info {
     e1000_cable_length cable_length;
     e1000_10bt_ext_dist_enable extended_10bt_distance;
@@ -224,9 +251,10 @@ struct e1000_eeprom_info {
 
 /* Function prototypes */
 /* Initialization */
-void e1000_reset_hw(struct e1000_hw *hw);
+int32_t e1000_reset_hw(struct e1000_hw *hw);
 int32_t e1000_init_hw(struct e1000_hw *hw);
 int32_t e1000_set_mac_type(struct e1000_hw *hw);
+void e1000_set_media_type(struct e1000_hw *hw);
 
 /* Link Configuration */
 int32_t e1000_setup_link(struct e1000_hw *hw);
@@ -234,7 +262,7 @@ int32_t e1000_phy_setup_autoneg(struct e
 void e1000_config_collision_dist(struct e1000_hw *hw);
 int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
 int32_t e1000_check_for_link(struct e1000_hw *hw);
-void e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t * speed, uint16_t * duplex);
+int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t * speed, uint16_t * duplex);
 int32_t e1000_wait_autoneg(struct e1000_hw *hw);
 
 /* PHY */
@@ -292,6 +321,8 @@ uint32_t e1000_io_read(struct e1000_hw *
 uint32_t e1000_read_reg_io(struct e1000_hw *hw, uint32_t offset);
 void e1000_io_write(struct e1000_hw *hw, uint32_t port, uint32_t value);
 void e1000_write_reg_io(struct e1000_hw *hw, uint32_t offset, uint32_t value);
+int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw, boolean_t link_up);
+int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, boolean_t active);
 
 #define E1000_READ_REG_IO(a, reg) \
     e1000_read_reg_io((a), E1000_##reg)
@@ -313,13 +343,22 @@ void e1000_write_reg_io(struct e1000_hw 
 #define E1000_DEV_ID_82540EP_LP          0x101E
 #define E1000_DEV_ID_82545EM_COPPER      0x100F
 #define E1000_DEV_ID_82545EM_FIBER       0x1011
+#define E1000_DEV_ID_82545GM_COPPER      0x1026
+#define E1000_DEV_ID_82545GM_FIBER       0x1027
+#define E1000_DEV_ID_82545GM_SERDES      0x1028
 #define E1000_DEV_ID_82546EB_COPPER      0x1010
 #define E1000_DEV_ID_82546EB_FIBER       0x1012
 #define E1000_DEV_ID_82546EB_QUAD_COPPER 0x101D
 #define E1000_DEV_ID_82541EI             0x1013
-#define E1000_DEV_ID_82541EP             0x1018
+#define E1000_DEV_ID_82541EI_MOBILE      0x1018
+#define E1000_DEV_ID_82541ER             0x1078
+#define E1000_DEV_ID_82547GI             0x1075
+#define E1000_DEV_ID_82541GI             0x1076
+#define E1000_DEV_ID_82541GI_MOBILE      0x1077
+#define E1000_DEV_ID_82546GB_COPPER      0x1079
+#define E1000_DEV_ID_82546GB_FIBER       0x107A
+#define E1000_DEV_ID_82546GB_SERDES      0x107B
 #define E1000_DEV_ID_82547EI             0x1019
-#define NUM_DEV_IDS 20
 
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
@@ -599,6 +638,7 @@ struct e1000_ffvt_entry {
  * A - register array
  */
 #define E1000_CTRL     0x00000  /* Device Control - RW */
+#define E1000_CTRL_DUP 0x00004  /* Device Control Duplicate (Shadow) - RW */
 #define E1000_STATUS   0x00008  /* Device Status - RO */
 #define E1000_EECD     0x00010  /* EEPROM/Flash Control - RW */
 #define E1000_EERD     0x00014  /* EEPROM Read - RW */
@@ -934,6 +974,9 @@ struct e1000_hw {
     e1000_bus_width bus_width;
     e1000_bus_type bus_type;
     struct e1000_eeprom_info eeprom;
+    e1000_ms_type master_slave;
+    e1000_ms_type original_master_slave;
+    e1000_ffe_config ffe_config_state;
     uint32_t io_base;
     uint32_t phy_id;
     uint32_t phy_revision;
@@ -950,6 +993,8 @@ struct e1000_hw {
     uint32_t ledctl_default;
     uint32_t ledctl_mode1;
     uint32_t ledctl_mode2;
+    uint16_t phy_spd_default;
+    uint16_t dsp_reset_counter;
     uint16_t autoneg_advertised;
     uint16_t pci_cmd_word;
     uint16_t fc_high_water;
@@ -974,10 +1021,13 @@ struct e1000_hw {
     uint8_t perm_mac_addr[NODE_ADDRESS_SIZE];
     boolean_t disable_polarity_correction;
     boolean_t speed_downgraded;
+    e1000_dsp_config dsp_config_state;
     boolean_t get_link_status;
     boolean_t tbi_compatibility_en;
     boolean_t tbi_compatibility_on;
+    boolean_t phy_reset_disable;
     boolean_t fc_send_xon;
+    boolean_t fc_strict_ieee;
     boolean_t report_tx_early;
     boolean_t adaptive_ifs;
     boolean_t ifs_params_forced;
@@ -1426,15 +1474,17 @@ struct e1000_hw {
 #define EEPROM_SIZE_128B        0x0000
 #define EEPROM_SIZE_MASK        0x1C00
 
-
 /* EEPROM Word Offsets */
-#define EEPROM_COMPAT              0x0003
-#define EEPROM_ID_LED_SETTINGS     0x0004
-#define EEPROM_INIT_CONTROL1_REG   0x000A
-#define EEPROM_INIT_CONTROL2_REG   0x000F
-#define EEPROM_CFG                 0x0012
-#define EEPROM_FLASH_VERSION       0x0032
-#define EEPROM_CHECKSUM_REG        0x003F
+#define EEPROM_COMPAT                 0x0003
+#define EEPROM_ID_LED_SETTINGS        0x0004
+#define EEPROM_SERDES_AMPLITUDE       0x0006 /* For SERDES output amplitude adjustment. */
+#define EEPROM_INIT_CONTROL1_REG      0x000A
+#define EEPROM_INIT_CONTROL2_REG      0x000F
+#define EEPROM_INIT_CONTROL3_PORT_B   0x0014
+#define EEPROM_INIT_CONTROL3_PORT_A   0x0024
+#define EEPROM_CFG                    0x0012
+#define EEPROM_FLASH_VERSION          0x0032
+#define EEPROM_CHECKSUM_REG           0x003F
 
 /* Word definitions for ID LED Settings */
 #define ID_LED_RESERVED_0000 0x0000
@@ -1458,6 +1508,9 @@ struct e1000_hw {
 #define IGP_LED3_MODE           0x07000000
 
 
+/* Mask bits for SERDES amplitude adjustment in Word 6 of the EEPROM */
+#define EEPROM_SERDES_AMPLITUDE_MASK  0x000F
+
 /* Mask bits for fields in Word 0x0a of the EEPROM */
 #define EEPROM_WORD0A_ILOS   0x0010
 #define EEPROM_WORD0A_SWDPIO 0x01E0
@@ -1479,6 +1532,8 @@ struct e1000_hw {
 #define EEPROM_NODE_ADDRESS_BYTE_0 0
 #define EEPROM_PBA_BYTE_1          8
 
+#define EEPROM_RESERVED_WORD          0xFFFF
+
 /* EEPROM Map Sizes (Byte Counts) */
 #define PBA_SIZE 4
 
@@ -1668,7 +1723,16 @@ struct e1000_hw {
 #define M88E1000_EXT_PHY_SPEC_CTRL 0x14  /* Extended PHY Specific Control */
 #define M88E1000_RX_ERR_CNTR       0x15  /* Receive Error Counter */
 
+#define M88E1000_PHY_EXT_CTRL      0x1A  /* PHY extend control register */
+#define M88E1000_PHY_PAGE_SELECT   0x1D  /* Reg 29 for page number setting */
+#define M88E1000_PHY_GEN_CONTROL   0x1E  /* Its meaning depends on reg 29 */
+#define M88E1000_PHY_VCO_REG_BIT8  0x100 /* Bits 8 & 11 are adjusted for */
+#define M88E1000_PHY_VCO_REG_BIT11 0x800    /* improved BER performance */
+
 #define IGP01E1000_IEEE_REGS_PAGE  0x0000
+#define IGP01E1000_IEEE_RESTART_AUTONEG 0x3300
+#define IGP01E1000_IEEE_FORCE_GIGA      0x0140
+
 /* IGP01E1000 Specific Registers */
 #define IGP01E1000_PHY_PORT_CONFIG 0x10 /* PHY Specific Port Config Register */
 #define IGP01E1000_PHY_PORT_STATUS 0x11 /* PHY Specific Status Register */
@@ -1684,17 +1748,35 @@ struct e1000_hw {
 #define IGP01E1000_PHY_AGC_C        0x1472
 #define IGP01E1000_PHY_AGC_D        0x1872
 
-/* Number of AGC registers */
-#define IGP01E1000_PHY_AGC_NUM     4
+/* IGP01E1000 DSP Reset Register */
+#define IGP01E1000_PHY_DSP_RESET   0x1F33
+#define IGP01E1000_PHY_DSP_SET     0x1F71
+#define IGP01E1000_PHY_DSP_FFE     0x1F35
+
+#define IGP01E1000_PHY_CHANNEL_NUM    4
+#define IGP01E1000_PHY_AGC_PARAM_A    0x1171
+#define IGP01E1000_PHY_AGC_PARAM_B    0x1271
+#define IGP01E1000_PHY_AGC_PARAM_C    0x1471
+#define IGP01E1000_PHY_AGC_PARAM_D    0x1871
+
+#define IGP01E1000_PHY_EDAC_MU_INDEX        0xC000
+#define IGP01E1000_PHY_EDAC_SIGN_EXT_9_BITS 0x8000
+
+#define IGP01E1000_PHY_ANALOG_TX_STATE      0x2890
+#define IGP01E1000_PHY_ANALOG_CLASS_A       0x2000
+#define IGP01E1000_PHY_FORCE_ANALOG_ENABLE  0x0004
+#define IGP01E1000_PHY_DSP_FFE_CM_CP        0x0069
 
+#define IGP01E1000_PHY_DSP_FFE_DEFAULT      0x002A
 /* IGP01E1000 PCS Initialization register - stores the polarity status when
  * speed = 1000 Mbps. */
 #define IGP01E1000_PHY_PCS_INIT_REG  0x00B4
+#define IGP01E1000_PHY_PCS_CTRL_REG  0x00B5
 
 #define IGP01E1000_ANALOG_REGS_PAGE  0x20C0
 
 #define MAX_PHY_REG_ADDRESS 0x1F        /* 5 bit address bus (0-0x1F) */
-
+#define MAX_PHY_MULTI_PAGE_REG  0xF     /*Registers that are equal on all pages*/
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB 0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
 #define MII_CR_COLL_TEST_ENABLE 0x0080  /* Collision test enable */
@@ -1808,8 +1890,11 @@ struct e1000_hw {
 #define SR_1000T_LOCAL_RX_STATUS  0x2000 /* Local receiver OK */
 #define SR_1000T_MS_CONFIG_RES    0x4000 /* 1=Local TX is Master, 0=Slave */
 #define SR_1000T_MS_CONFIG_FAULT  0x8000 /* Master/Slave config fault */
-#define SR_1000T_REMOTE_RX_STATUS_SHIFT 12
-#define SR_1000T_LOCAL_RX_STATUS_SHIFT  13
+#define SR_1000T_REMOTE_RX_STATUS_SHIFT          12
+#define SR_1000T_LOCAL_RX_STATUS_SHIFT           13
+#define SR_1000T_PHY_EXCESSIVE_IDLE_ERR_COUNT    5
+#define FFE_IDLE_ERR_COUNT_TIMEOUT_20            20
+#define FFE_IDLE_ERR_COUNT_TIMEOUT_100           100
 
 /* Extended Status Register */
 #define IEEE_ESR_1000T_HD_CAPS 0x1000 /* 1000T HD capable */
@@ -1952,6 +2037,11 @@ struct e1000_hw {
 #define IGP01E1000_MSE_CHANNEL_B        0x0F00
 #define IGP01E1000_MSE_CHANNEL_A        0xF000
 
+/* IGP01E1000 DSP reset macros */
+#define DSP_RESET_ENABLE     0x0
+#define DSP_RESET_DISABLE    0x2
+#define E1000_MAX_DSP_RESETS 10
+
 /* IGP01E1000 AGC Registers */
 
 #define IGP01E1000_AGC_LENGTH_SHIFT 7         /* Coarse - 13:11, Fine - 10:7 */
@@ -1983,10 +2057,10 @@ uint16_t e1000_igp_cable_length_table[IG
                                                      * on Link-Up */
 #define IGP01E1000_GMII_SPD                    0x20 /* Enable SPD */
 /* IGP01E1000 Analog Register */
-#define IGP01E1000_ANALOG_SPARE_FUSE_STATUS         0x0011
-#define IGP01E1000_ANALOG_FUSE_STATUS               0x0010
-#define IGP01E1000_ANALOG_FUSE_CONTROL              0x001C
-#define IGP01E1000_ANALOG_FUSE_BYPASS               0x001E
+#define IGP01E1000_ANALOG_SPARE_FUSE_STATUS       0x20D1
+#define IGP01E1000_ANALOG_FUSE_STATUS             0x20D0
+#define IGP01E1000_ANALOG_FUSE_CONTROL            0x20DC
+#define IGP01E1000_ANALOG_FUSE_BYPASS             0x20DE
 
 #define IGP01E1000_ANALOG_FUSE_POLY_MASK            0xF000
 #define IGP01E1000_ANALOG_FUSE_FINE_MASK            0x0F80
@@ -2032,5 +2108,8 @@ uint16_t e1000_igp_cable_length_table[IG
 #define ADVERTISE_1000_HALF 0x0010
 #define ADVERTISE_1000_FULL 0x0020
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT 0x002F  /* Everything but 1000-Half */
+#define AUTONEG_ADVERTISE_10_100_ALL    0x000F /* All 10/100 speeds*/
+#define AUTONEG_ADVERTISE_10_ALL        0x0003 /* 10Mbps Full & Half speeds*/
+
 
 #endif /* _E1000_HW_H_ */
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -71,15 +71,28 @@ static struct pci_device_id e1000_pci_tb
 	{0x8086, 0x100D, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x100E, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x100F, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1012, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1013, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1015, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1016, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1017, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x101E, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x101D, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1013, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1018, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1019, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x101D, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x101E, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1026, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1027, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1028, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1075, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1076, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1077, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1078, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x1079, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x107A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x8086, 0x107B, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	/* required last entry */
 	{0,}
 };
@@ -426,6 +439,11 @@ e1000_probe(struct pci_dev *pdev,
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	/* before reading the EEPROM, reset the controller to 
+	 * put the device in a known good starting state */
+	
+	e1000_reset_hw(&adapter->hw);
+
 	/* make sure the EEPROM is good */
 
 	if(e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
@@ -584,7 +628,10 @@ e1000_sw_init(struct e1000_adapter *adap
 	hw->fc_pause_time = E1000_FC_PAUSE_TIME;
 	hw->fc_send_xon = 1;
 
-	if((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547))
+	if((hw->mac_type == e1000_82541) ||
+	   (hw->mac_type == e1000_82547) ||
+	   (hw->mac_type == e1000_82541_rev_2) ||
+	   (hw->mac_type == e1000_82547_rev_2))
 		hw->phy_init_script = 1;
 
 	/* Media type - copper or fiber */
@@ -763,7 +784,8 @@ e1000_configure_tx(struct e1000_adapter 
 		tipg |= DEFAULT_82542_TIPG_IPGR2 << E1000_TIPG_IPGR2_SHIFT;
 		break;
 	default:
-		if(adapter->hw.media_type == e1000_media_type_fiber)
+		if(adapter->hw.media_type == e1000_media_type_fiber ||
+		   adapter->hw.media_type == e1000_media_type_internal_serdes)
 			tipg = DEFAULT_82543_TIPG_IPGT_FIBER;
 		else
 			tipg = DEFAULT_82543_TIPG_IPGT_COPPER;
@@ -2387,7 +2409,7 @@ e1000_mii_ioctl(struct net_device *netde
 	uint16_t mii_reg;
 	uint16_t spddplx;
 
-	if(adapter->hw.media_type == e1000_media_type_fiber)
+	if(adapter->hw.media_type != e1000_media_type_copper)
 		return -EOPNOTSUPP;
 
 	switch (cmd) {
@@ -2706,7 +2728,8 @@ e1000_suspend(struct pci_dev *pdev, uint
 			E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 		}
 
-		if(adapter->hw.media_type == e1000_media_type_fiber) {
+		if(adapter->hw.media_type == e1000_media_type_fiber ||
+		   adapter->hw.media_type == e1000_media_type_internal_serdes) {
 			/* keep the laser running in D3 */
 			ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
 			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_param.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_param.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_param.c	2003-08-22 16:57:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_param.c	2003-09-08 09:13:12.000000000 -0700
@@ -458,6 +458,7 @@ e1000_check_options(struct e1000_adapter
 
 	switch(adapter->hw.media_type) {
 	case e1000_media_type_fiber:
+	case e1000_media_type_internal_serdes:
 		e1000_check_fiber_options(adapter);
 		break;
 	case e1000_media_type_copper:
