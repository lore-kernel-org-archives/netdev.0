From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 18/21] e1000: integrate ich8 support into driver
Date: Wed, 21 Jun 2006 22:20:46 -0700
Message-ID: <20060622052046.25497.11216.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:62728 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932810AbWFVFOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:49 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This hooks up the ich8 structure into the driver itself.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    1 
 drivers/net/e1000/e1000_ethtool.c |   80 +++--
 drivers/net/e1000/e1000_hw.c      |  654 ++++++++++++++++++++++++++++++++-----
 drivers/net/e1000/e1000_main.c    |  118 ++++++-
 4 files changed, 724 insertions(+), 129 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index dbdaa33..323a268 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -143,6 +143,7 @@ struct e1000_adapter;
 
 #define AUTO_ALL_MODES            0
 #define E1000_EEPROM_82544_APM    0x0004
+#define E1000_EEPROM_ICH8_APME    0x0004
 #define E1000_EEPROM_APME         0x0400
 
 #ifndef E1000_MASTER_SLAVE
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 0609155..3a0b847 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -109,7 +109,8 @@ e1000_get_settings(struct net_device *ne
 		                   SUPPORTED_1000baseT_Full|
 		                   SUPPORTED_Autoneg |
 		                   SUPPORTED_TP);
-
+		if (hw->phy_type == e1000_phy_ife)
+			ecmd->supported &= ~SUPPORTED_1000baseT_Full;
 		ecmd->advertising = ADVERTISED_TP;
 
 		if (hw->autoneg == 1) {
@@ -573,6 +574,7 @@ e1000_get_drvinfo(struct net_device *net
 	case e1000_82572:
 	case e1000_82573:
 	case e1000_80003es2lan:
+	case e1000_ich8lan:
 		sprintf(firmware_version, "%d.%d-%d",
 			(eeprom_data & 0xF000) >> 12,
 			(eeprom_data & 0x0FF0) >> 4,
@@ -757,6 +759,7 @@ e1000_reg_test(struct e1000_adapter *ada
 		toggle = 0x7FFFF3FF;
 		break;
 	case e1000_82573:
+	case e1000_ich8lan:
 		toggle = 0x7FFFF033;
 		break;
 	default:
@@ -776,11 +779,12 @@ e1000_reg_test(struct e1000_adapter *ada
 	}
 	/* restore previous status */
 	E1000_WRITE_REG(&adapter->hw, STATUS, before);
-
-	REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
+	if (adapter->hw.mac_type != e1000_ich8lan) {
+		REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
+		REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
+	}
 	REG_PATTERN_TEST(RDTR, 0x0000FFFF, 0xFFFFFFFF);
 	REG_PATTERN_TEST(RDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
 	REG_PATTERN_TEST(RDLEN, 0x000FFF80, 0x000FFFFF);
@@ -793,20 +797,22 @@ e1000_reg_test(struct e1000_adapter *ada
 	REG_PATTERN_TEST(TDLEN, 0x000FFF80, 0x000FFFFF);
 
 	REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x00000000);
-	REG_SET_AND_CHECK(RCTL, 0x06DFB3FE, 0x003FFFFB);
+	before = (adapter->hw.mac_type == e1000_ich8lan ?
+			0x06C3B33E : 0x06DFB3FE);
+	REG_SET_AND_CHECK(RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(TCTL, 0xFFFFFFFF, 0x00000000);
 
 	if (adapter->hw.mac_type >= e1000_82543) {
 
-		REG_SET_AND_CHECK(RCTL, 0x06DFB3FE, 0xFFFFFFFF);
+		REG_SET_AND_CHECK(RCTL, before, 0xFFFFFFFF);
 		REG_PATTERN_TEST(RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
+		if (adapter->hw.mac_type != e1000_ich8lan)
+			REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
 		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
-
-		for (i = 0; i < E1000_RAR_ENTRIES; i++) {
-			REG_PATTERN_TEST(RA + ((i << 1) << 2), 0xFFFFFFFF,
-					 0xFFFFFFFF);
+		value = (adapter->hw.mac_type == e1000_ich8lan ?
+				E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
+		for (i = 0; i < value; i++) {
 			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
 					 0xFFFFFFFF);
 		}
@@ -820,7 +826,9 @@ e1000_reg_test(struct e1000_adapter *ada
 
 	}
 
-	for (i = 0; i < E1000_MC_TBL_SIZE; i++)
+	value = (adapter->hw.mac_type == e1000_ich8lan ?
+			E1000_MC_TBL_SIZE_ICH8LAN : E1000_MC_TBL_SIZE);
+	for (i = 0; i < value; i++)
 		REG_PATTERN_TEST(MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
 
 	*data = 0;
@@ -892,6 +900,8 @@ e1000_intr_test(struct e1000_adapter *ad
 	/* Test each interrupt */
 	for (; i < 10; i++) {
 
+		if (adapter->hw.mac_type == e1000_ich8lan && i == 8)
+			continue;
 		/* Interrupt to test */
 		mask = 1 << i;
 
@@ -1251,16 +1261,31 @@ e1000_integrated_phy_loopback(struct e10
 		                    GG82563_PHY_KMRN_MODE_CTRL,
 		                    0x1CC);
 	}
-	/* force 1000, set loopback */
-	e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x4140);
 
-	/* Now set up the MAC to the same speed/duplex as the PHY. */
 	ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
-	ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
-	ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
-		     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
-		     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
-		     E1000_CTRL_FD);	 /* Force Duplex to FULL */
+
+	if (adapter->hw.phy_type == e1000_phy_ife) {
+		/* force 100, set loopback */
+		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x6100);
+
+		/* Now set up the MAC to the same speed/duplex as the PHY. */
+		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
+		ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
+			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
+			     E1000_CTRL_SPD_100 |/* Force Speed to 100 */
+			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
+	} else {
+		/* force 1000, set loopback */
+		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x4140);
+
+		/* Now set up the MAC to the same speed/duplex as the PHY. */
+		ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
+		ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
+			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
+			     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
+			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
+	}
 
 	if (adapter->hw.media_type == e1000_media_type_copper &&
 	   adapter->hw.phy_type == e1000_phy_m88) {
@@ -1320,6 +1345,7 @@ e1000_set_phy_loopback(struct e1000_adap
 	case e1000_82572:
 	case e1000_82573:
 	case e1000_80003es2lan:
+	case e1000_ich8lan:
 		return e1000_integrated_phy_loopback(adapter);
 		break;
 
@@ -1786,6 +1812,16 @@ e1000_phys_id(struct net_device *netdev,
 		mod_timer(&adapter->blink_timer, jiffies);
 		msleep_interruptible(data * 1000);
 		del_timer_sync(&adapter->blink_timer);
+	} else if (adapter->hw.phy_type == e1000_phy_ife) {
+		if (!adapter->blink_timer.function) {
+			init_timer(&adapter->blink_timer);
+			adapter->blink_timer.function = e1000_led_blink_callback;
+			adapter->blink_timer.data = (unsigned long) adapter;
+		}
+		mod_timer(&adapter->blink_timer, jiffies);
+		msleep_interruptible(data * 1000);
+		del_timer_sync(&adapter->blink_timer);
+		e1000_write_phy_reg(&(adapter->hw), IFE_PHY_SPECIAL_CONTROL_LED, 0);
 	} else {
 		e1000_blink_led_start(&adapter->hw);
 		msleep_interruptible(data * 1000);
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index a3f5ccd..583518a 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -101,7 +101,8 @@ static void e1000_write_reg_io(struct e1
 
 #define E1000_WRITE_REG_IO(a, reg, val) \
 	    e1000_write_reg_io((a), E1000_##reg, val)
-static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw);
+static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
+                                               uint16_t duplex);
 static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
 /* IGP cable length table */
@@ -156,6 +157,14 @@ e1000_set_phy_type(struct e1000_hw *hw)
             hw->phy_type = e1000_phy_igp;
             break;
         }
+    case IGP03E1000_E_PHY_ID:
+        hw->phy_type = e1000_phy_igp_3;
+        break;
+    case IFE_E_PHY_ID:
+    case IFE_PLUS_E_PHY_ID:
+    case IFE_C_E_PHY_ID:
+        hw->phy_type = e1000_phy_ife;
+        break;
     case GG82563_E_PHY_ID:
         if (hw->mac_type == e1000_80003es2lan) {
             hw->phy_type = e1000_phy_gg82563;
@@ -332,6 +341,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
         break;
     case E1000_DEV_ID_82541EI:
     case E1000_DEV_ID_82541EI_MOBILE:
+    case E1000_DEV_ID_82541ER_LOM:
         hw->mac_type = e1000_82541;
         break;
     case E1000_DEV_ID_82541ER:
@@ -341,6 +351,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
         hw->mac_type = e1000_82541_rev_2;
         break;
     case E1000_DEV_ID_82547EI:
+    case E1000_DEV_ID_82547EI_MOBILE:
         hw->mac_type = e1000_82547;
         break;
     case E1000_DEV_ID_82547GI:
@@ -354,6 +365,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82572EI_COPPER:
     case E1000_DEV_ID_82572EI_FIBER:
     case E1000_DEV_ID_82572EI_SERDES:
+    case E1000_DEV_ID_82572EI:
         hw->mac_type = e1000_82572;
         break;
     case E1000_DEV_ID_82573E:
@@ -361,16 +373,29 @@ e1000_set_mac_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82573L:
         hw->mac_type = e1000_82573;
         break;
+    case E1000_DEV_ID_80003ES2LAN_COPPER_SPT:
+    case E1000_DEV_ID_80003ES2LAN_SERDES_SPT:
     case E1000_DEV_ID_80003ES2LAN_COPPER_DPT:
     case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
         hw->mac_type = e1000_80003es2lan;
         break;
+    case E1000_DEV_ID_ICH8_IGP_M_AMT:
+    case E1000_DEV_ID_ICH8_IGP_AMT:
+    case E1000_DEV_ID_ICH8_IGP_C:
+    case E1000_DEV_ID_ICH8_IFE:
+    case E1000_DEV_ID_ICH8_IGP_M:
+        hw->mac_type = e1000_ich8lan;
+        break;
     default:
         /* Should never have loaded on this device */
         return -E1000_ERR_MAC_TYPE;
     }
 
     switch(hw->mac_type) {
+    case e1000_ich8lan:
+        hw->swfwhw_semaphore_present = TRUE;
+        hw->asf_firmware_present = TRUE;
+        break;
     case e1000_80003es2lan:
         hw->swfw_sync_present = TRUE;
         /* fall through */
@@ -423,6 +448,7 @@ e1000_set_media_type(struct e1000_hw *hw
         case e1000_82542_rev2_1:
             hw->media_type = e1000_media_type_fiber;
             break;
+        case e1000_ich8lan:
         case e1000_82573:
             /* The STATUS_TBIMODE bit is reserved or reused for the this
              * device.
@@ -527,6 +553,14 @@ e1000_reset_hw(struct e1000_hw *hw)
         } while(timeout);
     }
 
+    /* Workaround for ICH8 bit corruption issue in FIFO memory */
+    if (hw->mac_type == e1000_ich8lan) {
+        /* Set Tx and Rx buffer allocation to 8k apiece. */
+        E1000_WRITE_REG(hw, PBA, E1000_PBA_8K);
+        /* Set Packet Buffer Size to 16k. */
+        E1000_WRITE_REG(hw, PBS, E1000_PBS_16K);
+    }
+
     /* Issue a global reset to the MAC.  This will reset the chip's
      * transmit, receive, DMA, and link units.  It will not effect
      * the current PCI configuration.  The global reset bit is self-
@@ -550,6 +584,20 @@ e1000_reset_hw(struct e1000_hw *hw)
             /* Reset is performed on a shadow of the control register */
             E1000_WRITE_REG(hw, CTRL_DUP, (ctrl | E1000_CTRL_RST));
             break;
+        case e1000_ich8lan:
+            if (!hw->phy_reset_disable &&
+                e1000_check_phy_reset_block(hw) == E1000_SUCCESS) {
+                /* e1000_ich8lan PHY HW reset requires MAC CORE reset
+                 * at the same time to make sure the interface between
+                 * MAC and the external PHY is reset.
+                 */
+                ctrl |= E1000_CTRL_PHY_RST;
+            }
+
+            e1000_get_software_flag(hw);
+            E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));
+            msec_delay(5);
+            break;
         default:
             E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));
             break;
@@ -591,6 +639,7 @@ e1000_reset_hw(struct e1000_hw *hw)
             /* fall through */
         case e1000_82571:
         case e1000_82572:
+        case e1000_ich8lan:
         case e1000_80003es2lan:
             ret_val = e1000_get_auto_rd_done(hw);
             if(ret_val)
@@ -633,6 +682,12 @@ e1000_reset_hw(struct e1000_hw *hw)
             e1000_pci_set_mwi(hw);
     }
 
+    if (hw->mac_type == e1000_ich8lan) {
+        uint32_t kab = E1000_READ_REG(hw, KABGTXD);
+        kab |= E1000_KABGTXD_BGSQLBIAS;
+        E1000_WRITE_REG(hw, KABGTXD, kab);
+    }
+
     return E1000_SUCCESS;
 }
 
@@ -675,9 +730,12 @@ e1000_init_hw(struct e1000_hw *hw)
 
     /* Disabling VLAN filtering. */
     DEBUGOUT("Initializing the IEEE VLAN\n");
-    if (hw->mac_type < e1000_82545_rev_3)
-        E1000_WRITE_REG(hw, VET, 0);
-    e1000_clear_vfta(hw);
+    /* VET hardcoded to standard value and VFTA removed in ICH8 LAN */
+    if (hw->mac_type != e1000_ich8lan) {
+        if (hw->mac_type < e1000_82545_rev_3)
+            E1000_WRITE_REG(hw, VET, 0);
+        e1000_clear_vfta(hw);
+    }
 
     /* For 82542 (rev 2.0), disable MWI and put the receiver into reset */
     if(hw->mac_type == e1000_82542_rev2_0) {
@@ -705,6 +763,8 @@ e1000_init_hw(struct e1000_hw *hw)
     /* Zero out the Multicast HASH table */
     DEBUGOUT("Zeroing the MTA\n");
     mta_size = E1000_MC_TBL_SIZE;
+    if (hw->mac_type == e1000_ich8lan)
+        mta_size = E1000_MC_TBL_SIZE_ICH8LAN;
     for(i = 0; i < mta_size; i++) {
         E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
         /* use write flush to prevent Memory Write Block (MWB) from
@@ -748,6 +808,10 @@ e1000_init_hw(struct e1000_hw *hw)
         break;
     }
 
+    /* More time needed for PHY to initialize */
+    if (hw->mac_type == e1000_ich8lan)
+        msec_delay(15);
+
     /* Call a subroutine to configure the link and setup flow control. */
     ret_val = e1000_setup_link(hw);
 
@@ -761,6 +825,7 @@ e1000_init_hw(struct e1000_hw *hw)
         case e1000_82571:
         case e1000_82572:
         case e1000_82573:
+        case e1000_ich8lan:
         case e1000_80003es2lan:
             ctrl |= E1000_TXDCTL_COUNT_DESC;
             break;
@@ -799,6 +864,7 @@ e1000_init_hw(struct e1000_hw *hw)
         /* Fall through */
     case e1000_82571:
     case e1000_82572:
+    case e1000_ich8lan:
         ctrl = E1000_READ_REG(hw, TXDCTL1);
         ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
         if(hw->mac_type >= e1000_82571)
@@ -822,6 +888,11 @@ e1000_init_hw(struct e1000_hw *hw)
      */
     e1000_clear_hw_cntrs(hw);
 
+    /* ICH8 No-snoop bits are opposite polarity.
+     * Set to snoop by default after reset. */
+    if (hw->mac_type == e1000_ich8lan)
+        e1000_set_pci_ex_no_snoop(hw, PCI_EX_82566_SNOOP_ALL);
+
     if (hw->device_id == E1000_DEV_ID_82546GB_QUAD_COPPER ||
         hw->device_id == E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3) {
         ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
@@ -909,6 +980,7 @@ e1000_setup_link(struct e1000_hw *hw)
      */
     if (hw->fc == e1000_fc_default) {
         switch (hw->mac_type) {
+        case e1000_ich8lan:
         case e1000_82573:
             hw->fc = e1000_fc_full;
             break;
@@ -975,9 +1047,12 @@ e1000_setup_link(struct e1000_hw *hw)
      */
     DEBUGOUT("Initializing the Flow Control address, type and timer regs\n");
 
-    E1000_WRITE_REG(hw, FCAL, FLOW_CONTROL_ADDRESS_LOW);
-    E1000_WRITE_REG(hw, FCAH, FLOW_CONTROL_ADDRESS_HIGH);
-    E1000_WRITE_REG(hw, FCT, FLOW_CONTROL_TYPE);
+    /* FCAL/H and FCT are hardcoded to standard values in e1000_ich8lan. */
+    if (hw->mac_type != e1000_ich8lan) {
+        E1000_WRITE_REG(hw, FCT, FLOW_CONTROL_TYPE);
+        E1000_WRITE_REG(hw, FCAH, FLOW_CONTROL_ADDRESS_HIGH);
+        E1000_WRITE_REG(hw, FCAL, FLOW_CONTROL_ADDRESS_LOW);
+    }
 
     E1000_WRITE_REG(hw, FCTTV, hw->fc_pause_time);
 
@@ -1241,12 +1316,13 @@ e1000_copper_link_igp_setup(struct e1000
 
     /* Wait 10ms for MAC to configure PHY from eeprom settings */
     msec_delay(15);
-
+    if (hw->mac_type != e1000_ich8lan) {
     /* Configure activity LED after PHY reset */
     led_ctrl = E1000_READ_REG(hw, LEDCTL);
     led_ctrl &= IGP_ACTIVITY_LED_MASK;
     led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
     E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
+    }
 
     /* disable lplu d3 during driver init */
     ret_val = e1000_set_d3_lplu_state(hw, FALSE);
@@ -1482,8 +1558,7 @@ e1000_copper_link_ggp_setup(struct e1000
             if (ret_val)
                 return ret_val;
 
-            /* Enable Pass False Carrier on the PHY */
-            phy_data |= GG82563_KMCR_PASS_FALSE_CARRIER;
+            phy_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
 
             ret_val = e1000_write_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL,
                                           phy_data);
@@ -1636,6 +1711,10 @@ e1000_copper_link_autoneg(struct e1000_h
     if(hw->autoneg_advertised == 0)
         hw->autoneg_advertised = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
+    /* IFE phy only supports 10/100 */
+    if (hw->phy_type == e1000_phy_ife)
+        hw->autoneg_advertised &= AUTONEG_ADVERTISE_10_100_ALL;
+
     DEBUGOUT("Reconfiguring auto-neg advertisement params\n");
     ret_val = e1000_phy_setup_autoneg(hw);
     if(ret_val) {
@@ -1733,6 +1812,26 @@ e1000_setup_copper_link(struct e1000_hw 
 
     DEBUGFUNC("e1000_setup_copper_link");
 
+    switch (hw->mac_type) {
+    case e1000_80003es2lan:
+    case e1000_ich8lan:
+        /* Set the mac to wait the maximum time between each
+         * iteration and increase the max iterations when
+         * polling the phy; this fixes erroneous timeouts at 10Mbps. */
+        ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
+        if (ret_val)
+            return ret_val;
+        ret_val = e1000_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
+        if (ret_val)
+            return ret_val;
+        reg_data |= 0x3F;
+        ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
+        if (ret_val)
+            return ret_val;
+    default:
+        break;
+    }
+
     /* Check if it is a valid PHY and set PHY mode if necessary. */
     ret_val = e1000_copper_link_preconfig(hw);
     if(ret_val)
@@ -1740,10 +1839,8 @@ e1000_setup_copper_link(struct e1000_hw 
 
     switch (hw->mac_type) {
     case e1000_80003es2lan:
-        ret_val = e1000_read_kmrn_reg(hw, E1000_KUMCTRLSTA_OFFSET_INB_CTRL,
-                                      &reg_data);
-        if (ret_val)
-            return ret_val;
+        /* Kumeran registers are written-only */
+        reg_data = E1000_KUMCTRLSTA_INB_CTRL_LINK_STATUS_TX_TIMEOUT_DEFAULT;
         reg_data |= E1000_KUMCTRLSTA_INB_CTRL_DIS_PADDING;
         ret_val = e1000_write_kmrn_reg(hw, E1000_KUMCTRLSTA_OFFSET_INB_CTRL,
                                        reg_data);
@@ -1755,6 +1852,7 @@ e1000_setup_copper_link(struct e1000_hw 
     }
 
     if (hw->phy_type == e1000_phy_igp ||
+        hw->phy_type == e1000_phy_igp_3 ||
         hw->phy_type == e1000_phy_igp_2) {
         ret_val = e1000_copper_link_igp_setup(hw);
         if(ret_val)
@@ -1819,7 +1917,7 @@ e1000_setup_copper_link(struct e1000_hw 
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
 static int32_t
-e1000_configure_kmrn_for_10_100(struct e1000_hw *hw)
+e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, uint16_t duplex)
 {
     int32_t ret_val = E1000_SUCCESS;
     uint32_t tipg;
@@ -1839,6 +1937,18 @@ e1000_configure_kmrn_for_10_100(struct e
     tipg |= DEFAULT_80003ES2LAN_TIPG_IPGT_10_100;
     E1000_WRITE_REG(hw, TIPG, tipg);
 
+    ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
+
+    if (ret_val)
+        return ret_val;
+
+    if (duplex == HALF_DUPLEX)
+        reg_data |= GG82563_KMCR_PASS_FALSE_CARRIER;
+    else
+        reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
+
+    ret_val = e1000_write_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
+
     return ret_val;
 }
 
@@ -1863,6 +1973,14 @@ e1000_configure_kmrn_for_1000(struct e10
     tipg |= DEFAULT_80003ES2LAN_TIPG_IPGT_1000;
     E1000_WRITE_REG(hw, TIPG, tipg);
 
+    ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
+
+    if (ret_val)
+        return ret_val;
+
+    reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
+    ret_val = e1000_write_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
+
     return ret_val;
 }
 
@@ -1885,10 +2003,13 @@ e1000_phy_setup_autoneg(struct e1000_hw 
     if(ret_val)
         return ret_val;
 
-    /* Read the MII 1000Base-T Control Register (Address 9). */
-    ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
-    if(ret_val)
-        return ret_val;
+    if (hw->phy_type != e1000_phy_ife) {
+        /* Read the MII 1000Base-T Control Register (Address 9). */
+        ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
+        if (ret_val)
+            return ret_val;
+    } else
+        mii_1000t_ctrl_reg=0;
 
     /* Need to parse both autoneg_advertised and fc and set up
      * the appropriate PHY registers.  First we will parse for
@@ -1939,6 +2060,9 @@ e1000_phy_setup_autoneg(struct e1000_hw 
     if(hw->autoneg_advertised & ADVERTISE_1000_FULL) {
         DEBUGOUT("Advertise 1000mb Full duplex\n");
         mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
+        if (hw->phy_type == e1000_phy_ife) {
+            DEBUGOUT("e1000_phy_ife is a 10/100 PHY. Gigabit speed is not supported.\n");
+        }
     }
 
     /* Check for a software override of the flow control settings, and
@@ -2000,9 +2124,11 @@ e1000_phy_setup_autoneg(struct e1000_hw 
 
     DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-    ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
-    if(ret_val)
-        return ret_val;
+    if (hw->phy_type != e1000_phy_ife) {
+        ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
+        if (ret_val)
+            return ret_val;
+    }
 
     return E1000_SUCCESS;
 }
@@ -2105,6 +2231,18 @@ e1000_phy_force_speed_duplex(struct e100
 
         /* Need to reset the PHY or these changes will be ignored */
         mii_ctrl_reg |= MII_CR_RESET;
+    /* Disable MDI-X support for 10/100 */
+    } else if (hw->phy_type == e1000_phy_ife) {
+        ret_val = e1000_read_phy_reg(hw, IFE_PHY_MDIX_CONTROL, &phy_data);
+        if (ret_val)
+            return ret_val;
+
+        phy_data &= ~IFE_PMC_AUTO_MDIX;
+        phy_data &= ~IFE_PMC_FORCE_MDIX;
+
+        ret_val = e1000_write_phy_reg(hw, IFE_PHY_MDIX_CONTROL, phy_data);
+        if (ret_val)
+            return ret_val;
     } else {
         /* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
          * forced whenever speed or duplex are forced.
@@ -2909,7 +3047,13 @@ e1000_get_speed_and_duplex(struct e1000_
         if (*speed == SPEED_1000)
             ret_val = e1000_configure_kmrn_for_1000(hw);
         else
-            ret_val = e1000_configure_kmrn_for_10_100(hw);
+            ret_val = e1000_configure_kmrn_for_10_100(hw, *duplex);
+        if (ret_val)
+            return ret_val;
+    }
+
+    if ((hw->phy_type == e1000_phy_igp_3) && (*speed == SPEED_1000)) {
+        ret_val = e1000_kumeran_lock_loss_workaround(hw);
         if (ret_val)
             return ret_val;
     }
@@ -3099,6 +3243,9 @@ e1000_swfw_sync_acquire(struct e1000_hw 
 
     DEBUGFUNC("e1000_swfw_sync_acquire");
 
+    if (hw->swfwhw_semaphore_present)
+        return e1000_get_software_flag(hw);
+
     if (!hw->swfw_sync_present)
         return e1000_get_hw_eeprom_semaphore(hw);
 
@@ -3138,6 +3285,11 @@ e1000_swfw_sync_release(struct e1000_hw 
 
     DEBUGFUNC("e1000_swfw_sync_release");
 
+    if (hw->swfwhw_semaphore_present) {
+        e1000_release_software_flag(hw);
+        return;
+    }
+
     if (!hw->swfw_sync_present) {
         e1000_put_hw_eeprom_semaphore(hw);
         return;
@@ -3180,7 +3332,8 @@ e1000_read_phy_reg(struct e1000_hw *hw,
     if (e1000_swfw_sync_acquire(hw, swfw))
         return -E1000_ERR_SWFW_SYNC;
 
-    if((hw->phy_type == e1000_phy_igp ||
+    if ((hw->phy_type == e1000_phy_igp ||
+        hw->phy_type == e1000_phy_igp_3 ||
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -3319,7 +3472,8 @@ e1000_write_phy_reg(struct e1000_hw *hw,
     if (e1000_swfw_sync_acquire(hw, swfw))
         return -E1000_ERR_SWFW_SYNC;
 
-    if((hw->phy_type == e1000_phy_igp ||
+    if ((hw->phy_type == e1000_phy_igp ||
+        hw->phy_type == e1000_phy_igp_3 ||
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -3534,7 +3688,7 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
         E1000_WRITE_FLUSH(hw);
 
         if (hw->mac_type >= e1000_82571)
-            msec_delay(10);
+            msec_delay_irq(10);
         e1000_swfw_sync_release(hw, swfw);
     } else {
         /* Read the Extended Device Control Register, assert the PHY_RESET_DIR
@@ -3564,6 +3718,12 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
     ret_val = e1000_get_phy_cfg_done(hw);
     e1000_release_software_semaphore(hw);
 
+        if ((hw->mac_type == e1000_ich8lan) &&
+            (hw->phy_type == e1000_phy_igp_3)) {
+            ret_val = e1000_init_lcd_from_nvm(hw);
+            if (ret_val)
+                return ret_val;
+        }
     return ret_val;
 }
 
@@ -3592,9 +3752,11 @@ e1000_phy_reset(struct e1000_hw *hw)
     case e1000_82541_rev_2:
     case e1000_82571:
     case e1000_82572:
+    case e1000_ich8lan:
         ret_val = e1000_phy_hw_reset(hw);
         if(ret_val)
             return ret_val;
+
         break;
     default:
         ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data);
@@ -3742,8 +3904,8 @@ e1000_detect_gig_phy(struct e1000_hw *hw
     /* The 82571 firmware may still be configuring the PHY.  In this
      * case, we cannot access the PHY until the configuration is done.  So
      * we explicitly set the PHY values. */
-    if(hw->mac_type == e1000_82571 ||
-       hw->mac_type == e1000_82572) {
+    if (hw->mac_type == e1000_82571 ||
+        hw->mac_type == e1000_82572) {
         hw->phy_id = IGP01E1000_I_PHY_ID;
         hw->phy_type = e1000_phy_igp_2;
         return E1000_SUCCESS;
@@ -3760,7 +3922,7 @@ e1000_detect_gig_phy(struct e1000_hw *hw
 
     /* Read the PHY ID Registers to identify which PHY is onboard. */
     ret_val = e1000_read_phy_reg(hw, PHY_ID1, &phy_id_high);
-    if(ret_val)
+    if (ret_val)
         return ret_val;
 
     hw->phy_id = (uint32_t) (phy_id_high << 16);
@@ -3798,6 +3960,12 @@ e1000_detect_gig_phy(struct e1000_hw *hw
     case e1000_80003es2lan:
         if (hw->phy_id == GG82563_E_PHY_ID) match = TRUE;
         break;
+    case e1000_ich8lan:
+        if (hw->phy_id == IGP03E1000_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == IFE_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == IFE_PLUS_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == IFE_C_E_PHY_ID) match = TRUE;
+        break;
     default:
         DEBUGOUT1("Invalid MAC type %d\n", hw->mac_type);
         return -E1000_ERR_CONFIG;
@@ -4074,9 +4242,12 @@ e1000_phy_get_info(struct e1000_hw *hw,
         return -E1000_ERR_CONFIG;
     }
 
-    if(hw->phy_type == e1000_phy_igp ||
+    if (hw->phy_type == e1000_phy_igp ||
+        hw->phy_type == e1000_phy_igp_3 ||
         hw->phy_type == e1000_phy_igp_2)
         return e1000_phy_igp_get_info(hw, phy_info);
+    else if (hw->phy_type == e1000_phy_ife)
+        return e1000_phy_ife_get_info(hw, phy_info);
     else
         return e1000_phy_m88_get_info(hw, phy_info);
 }
@@ -4225,6 +4396,35 @@ e1000_init_eeprom_params(struct e1000_hw
         eeprom->use_eerd = TRUE;
         eeprom->use_eewr = FALSE;
         break;
+    case e1000_ich8lan:
+    {
+        int32_t  i = 0;
+        uint32_t flash_size = E1000_READ_ICH8_REG(hw, ICH8_FLASH_GFPREG);
+
+        eeprom->type = e1000_eeprom_ich8;
+        eeprom->use_eerd = FALSE;
+        eeprom->use_eewr = FALSE;
+        eeprom->word_size = E1000_SHADOW_RAM_WORDS;
+
+        /* Zero the shadow RAM structure. But don't load it from NVM
+         * so as to save time for driver init */
+        if (hw->eeprom_shadow_ram != NULL) {
+            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
+                hw->eeprom_shadow_ram[i].modified = FALSE;
+                hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
+            }
+        }
+
+        hw->flash_base_addr = (flash_size & ICH8_GFPREG_BASE_MASK) *
+                              ICH8_FLASH_SECTOR_SIZE;
+
+        hw->flash_bank_size = ((flash_size >> 16) & ICH8_GFPREG_BASE_MASK) + 1;
+        hw->flash_bank_size -= (flash_size & ICH8_GFPREG_BASE_MASK);
+        hw->flash_bank_size *= ICH8_FLASH_SECTOR_SIZE;
+        hw->flash_bank_size /= 2 * sizeof(uint16_t);
+
+        break;
+    }
     default:
         break;
     }
@@ -4645,7 +4845,10 @@ e1000_read_eeprom(struct e1000_hw *hw,
         return ret_val;
     }
 
-    if(eeprom->type == e1000_eeprom_spi) {
+    if (eeprom->type == e1000_eeprom_ich8)
+        return e1000_read_eeprom_ich8(hw, offset, words, data);
+
+    if (eeprom->type == e1000_eeprom_spi) {
         uint16_t word_in;
         uint8_t read_opcode = EEPROM_READ_OPCODE_SPI;
 
@@ -4812,7 +5015,10 @@ e1000_is_onboard_nvm_eeprom(struct e1000
 
     DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
 
-    if(hw->mac_type == e1000_82573) {
+    if (hw->mac_type == e1000_ich8lan)
+        return FALSE;
+
+    if (hw->mac_type == e1000_82573) {
         eecd = E1000_READ_REG(hw, EECD);
 
         /* Isolate bits 15 & 16 */
@@ -4862,8 +5068,22 @@ e1000_validate_eeprom_checksum(struct e1
         }
     }
 
-    for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
-        if(e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
+    if (hw->mac_type == e1000_ich8lan) {
+        /* Drivers must allocate the shadow ram structure for the
+         * EEPROM checksum to be updated.  Otherwise, this bit as well
+         * as the checksum must both be set correctly for this
+         * validation to pass.
+         */
+        e1000_read_eeprom(hw, 0x19, 1, &eeprom_data);
+        if ((eeprom_data & 0x40) == 0) {
+            eeprom_data |= 0x40;
+            e1000_write_eeprom(hw, 0x19, 1, &eeprom_data);
+            e1000_update_eeprom_checksum(hw);
+        }
+    }
+
+    for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
+        if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
             DEBUGOUT("EEPROM Read Error\n");
             return -E1000_ERR_EEPROM;
         }
@@ -4889,6 +5109,7 @@ e1000_validate_eeprom_checksum(struct e1
 int32_t
 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
+    uint32_t ctrl_ext;
     uint16_t checksum = 0;
     uint16_t i, eeprom_data;
 
@@ -4907,6 +5128,14 @@ e1000_update_eeprom_checksum(struct e100
         return -E1000_ERR_EEPROM;
     } else if (hw->eeprom.type == e1000_eeprom_flash) {
         e1000_commit_shadow_ram(hw);
+    } else if (hw->eeprom.type == e1000_eeprom_ich8) {
+        e1000_commit_shadow_ram(hw);
+        /* Reload the EEPROM, or else modifications will not appear
+         * until after next adapter reset. */
+        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+        ctrl_ext |= E1000_CTRL_EXT_EE_RST;
+        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+        msec_delay(10);
     }
     return E1000_SUCCESS;
 }
@@ -4946,6 +5175,9 @@ e1000_write_eeprom(struct e1000_hw *hw,
     if(eeprom->use_eewr == TRUE)
         return e1000_write_eeprom_eewr(hw, offset, words, data);
 
+    if (eeprom->type == e1000_eeprom_ich8)
+        return e1000_write_eeprom_ich8(hw, offset, words, data);
+
     /* Prepare the EEPROM for writing  */
     if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
         return -E1000_ERR_EEPROM;
@@ -5133,11 +5365,17 @@ e1000_commit_shadow_ram(struct e1000_hw 
     uint32_t flop = 0;
     uint32_t i = 0;
     int32_t error = E1000_SUCCESS;
-
-    /* The flop register will be used to determine if flash type is STM */
-    flop = E1000_READ_REG(hw, FLOP);
+    uint32_t old_bank_offset = 0;
+    uint32_t new_bank_offset = 0;
+    uint32_t sector_retries = 0;
+    uint8_t low_byte = 0;
+    uint8_t high_byte = 0;
+    uint8_t temp_byte = 0;
+    boolean_t sector_write_failed = FALSE;
 
     if (hw->mac_type == e1000_82573) {
+        /* The flop register will be used to determine if flash type is STM */
+        flop = E1000_READ_REG(hw, FLOP);
         for (i=0; i < attempts; i++) {
             eecd = E1000_READ_REG(hw, EECD);
             if ((eecd & E1000_EECD_FLUPD) == 0) {
@@ -5171,6 +5409,106 @@ e1000_commit_shadow_ram(struct e1000_hw 
         }
     }
 
+    if (hw->mac_type == e1000_ich8lan && hw->eeprom_shadow_ram != NULL) {
+        /* We're writing to the opposite bank so if we're on bank 1,
+         * write to bank 0 etc.  We also need to erase the segment that
+         * is going to be written */
+        if (!(E1000_READ_REG(hw, EECD) & E1000_EECD_SEC1VAL)) {
+            new_bank_offset = hw->flash_bank_size * 2;
+            old_bank_offset = 0;
+            e1000_erase_ich8_4k_segment(hw, 1);
+        } else {
+            old_bank_offset = hw->flash_bank_size * 2;
+            new_bank_offset = 0;
+            e1000_erase_ich8_4k_segment(hw, 0);
+        }
+
+        do {
+            sector_write_failed = FALSE;
+            /* Loop for every byte in the shadow RAM,
+             * which is in units of words. */
+            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
+                /* Determine whether to write the value stored
+                 * in the other NVM bank or a modified value stored
+                 * in the shadow RAM */
+                if (hw->eeprom_shadow_ram[i].modified == TRUE) {
+                    low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
+                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
+                                         &temp_byte);
+                    udelay(100);
+                    error = e1000_verify_write_ich8_byte(hw,
+                                                 (i << 1) + new_bank_offset,
+                                                 low_byte);
+                    if (error != E1000_SUCCESS)
+                        sector_write_failed = TRUE;
+                    high_byte =
+                        (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
+                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
+                                         &temp_byte);
+                    udelay(100);
+                } else {
+                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
+                                         &low_byte);
+                    udelay(100);
+                    error = e1000_verify_write_ich8_byte(hw,
+                                 (i << 1) + new_bank_offset, low_byte);
+                    if (error != E1000_SUCCESS)
+                        sector_write_failed = TRUE;
+                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
+                                         &high_byte);
+                }
+
+                /* If the word is 0x13, then make sure the signature bits
+                 * (15:14) are 11b until the commit has completed.
+                 * This will allow us to write 10b which indicates the
+                 * signature is valid.  We want to do this after the write
+                 * has completed so that we don't mark the segment valid
+                 * while the write is still in progress */
+                if (i == E1000_ICH8_NVM_SIG_WORD)
+                    high_byte = E1000_ICH8_NVM_SIG_MASK | high_byte;
+
+                error = e1000_verify_write_ich8_byte(hw,
+                             (i << 1) + new_bank_offset + 1, high_byte);
+                if (error != E1000_SUCCESS)
+                    sector_write_failed = TRUE;
+
+                if (sector_write_failed == FALSE) {
+                    /* Clear the now not used entry in the cache */
+                    hw->eeprom_shadow_ram[i].modified = FALSE;
+                    hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
+                }
+            }
+
+            /* Don't bother writing the segment valid bits if sector
+             * programming failed. */
+            if (sector_write_failed == FALSE) {
+                /* Finally validate the new segment by setting bit 15:14
+                 * to 10b in word 0x13 , this can be done without an
+                 * erase as well since these bits are 11 to start with
+                 * and we need to change bit 14 to 0b */
+                e1000_read_ich8_byte(hw,
+                    E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
+                    &high_byte);
+                high_byte &= 0xBF;
+                error = e1000_verify_write_ich8_byte(hw,
+                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
+                            high_byte);
+                if (error != E1000_SUCCESS)
+                    sector_write_failed = TRUE;
+
+                /* And invalidate the previously valid segment by setting
+                 * its signature word (0x13) high_byte to 0b. This can be
+                 * done without an erase because flash erase sets all bits
+                 * to 1's. We can write 1's to 0's without an erase */
+                error = e1000_verify_write_ich8_byte(hw,
+                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + old_bank_offset,
+                            0);
+                if (error != E1000_SUCCESS)
+                    sector_write_failed = TRUE;
+            }
+        } while (++sector_retries < 10 && sector_write_failed == TRUE);
+    }
+
     return error;
 }
 
@@ -5278,6 +5616,9 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
      * the other port. */
     if ((hw->mac_type == e1000_82571) && (hw->laa_is_present == TRUE))
         rar_num -= 1;
+    if (hw->mac_type == e1000_ich8lan)
+        rar_num = E1000_RAR_ENTRIES_ICH8LAN;
+
     /* Zero out the other 15 receive addresses. */
     DEBUGOUT("Clearing RAR[1-15]\n");
     for(i = 1; i < rar_num; i++) {
@@ -5288,7 +5629,6 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
     }
 }
 
-#if 0
 /******************************************************************************
  * Updates the MAC's list of multicast addresses.
  *
@@ -5323,6 +5663,8 @@ e1000_mc_addr_list_update(struct e1000_h
     /* Clear RAR[1-15] */
     DEBUGOUT(" Clearing RAR[1-15]\n");
     num_rar_entry = E1000_RAR_ENTRIES;
+    if (hw->mac_type == e1000_ich8lan)
+        num_rar_entry = E1000_RAR_ENTRIES_ICH8LAN;
     /* Reserve a spot for the Locally Administered Address to work around
      * an 82571 issue in which a reset on one port will reload the MAC on
      * the other port. */
@@ -5339,6 +5681,8 @@ e1000_mc_addr_list_update(struct e1000_h
     /* Clear the MTA */
     DEBUGOUT(" Clearing MTA\n");
     num_mta_entry = E1000_NUM_MTA_REGISTERS;
+    if (hw->mac_type == e1000_ich8lan)
+        num_mta_entry = E1000_NUM_MTA_REGISTERS_ICH8LAN;
     for(i = 0; i < num_mta_entry; i++) {
         E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
         E1000_WRITE_FLUSH(hw);
@@ -5375,7 +5719,6 @@ e1000_mc_addr_list_update(struct e1000_h
     }
     DEBUGOUT("MC Update Complete\n");
 }
-#endif  /*  0  */
 
 /******************************************************************************
  * Hashes an address to determine its location in the multicast table
@@ -5398,24 +5741,46 @@ e1000_hash_mc_addr(struct e1000_hw *hw,
      * LSB                 MSB
      */
     case 0:
-        /* [47:36] i.e. 0x563 for above example address */
-        hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+        if (hw->mac_type == e1000_ich8lan) {
+            /* [47:38] i.e. 0x158 for above example address */
+            hash_value = ((mc_addr[4] >> 6) | (((uint16_t) mc_addr[5]) << 2));
+        } else {
+            /* [47:36] i.e. 0x563 for above example address */
+            hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+        }
         break;
     case 1:
-        /* [46:35] i.e. 0xAC6 for above example address */
-        hash_value = ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
+        if (hw->mac_type == e1000_ich8lan) {
+            /* [46:37] i.e. 0x2B1 for above example address */
+            hash_value = ((mc_addr[4] >> 5) | (((uint16_t) mc_addr[5]) << 3));
+        } else {
+            /* [46:35] i.e. 0xAC6 for above example address */
+            hash_value = ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
+        }
         break;
     case 2:
-        /* [45:34] i.e. 0x5D8 for above example address */
-        hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+        if (hw->mac_type == e1000_ich8lan) {
+            /*[45:36] i.e. 0x163 for above example address */
+            hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+        } else {
+            /* [45:34] i.e. 0x5D8 for above example address */
+            hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+        }
         break;
     case 3:
-        /* [43:32] i.e. 0x634 for above example address */
-        hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
+        if (hw->mac_type == e1000_ich8lan) {
+            /* [43:34] i.e. 0x18D for above example address */
+            hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+        } else {
+            /* [43:32] i.e. 0x634 for above example address */
+            hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
+        }
         break;
     }
 
     hash_value &= 0xFFF;
+    if (hw->mac_type == e1000_ich8lan)
+        hash_value &= 0x3FF;
 
     return hash_value;
 }
@@ -5443,6 +5808,8 @@ e1000_mta_set(struct e1000_hw *hw,
      * register are determined by the lower 5 bits of the value.
      */
     hash_reg = (hash_value >> 5) & 0x7F;
+    if (hw->mac_type == e1000_ich8lan)
+        hash_reg &= 0x1F;
     hash_bit = hash_value & 0x1F;
 
     mta = E1000_READ_REG_ARRAY(hw, MTA, hash_reg);
@@ -5537,7 +5904,10 @@ e1000_write_vfta(struct e1000_hw *hw,
 {
     uint32_t temp;
 
-    if((hw->mac_type == e1000_82544) && ((offset & 0x1) == 1)) {
+    if (hw->mac_type == e1000_ich8lan)
+        return;
+
+    if ((hw->mac_type == e1000_82544) && ((offset & 0x1) == 1)) {
         temp = E1000_READ_REG_ARRAY(hw, VFTA, (offset - 1));
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, value);
         E1000_WRITE_FLUSH(hw);
@@ -5562,6 +5932,9 @@ e1000_clear_vfta(struct e1000_hw *hw)
     uint32_t vfta_offset = 0;
     uint32_t vfta_bit_in_reg = 0;
 
+    if (hw->mac_type == e1000_ich8lan)
+        return;
+
     if (hw->mac_type == e1000_82573) {
         if (hw->mng_cookie.vlan_id != 0) {
             /* The VFTA is a 4096b bit-field, each identifying a single VLAN
@@ -5611,9 +5984,18 @@ e1000_id_led_init(struct e1000_hw * hw)
         DEBUGOUT("EEPROM Read Error\n");
         return -E1000_ERR_EEPROM;
     }
-    if((eeprom_data== ID_LED_RESERVED_0000) ||
-       (eeprom_data == ID_LED_RESERVED_FFFF)) eeprom_data = ID_LED_DEFAULT;
-    for(i = 0; i < 4; i++) {
+
+    if ((hw->mac_type == e1000_82573) &&
+        (eeprom_data == ID_LED_RESERVED_82573))
+        eeprom_data = ID_LED_DEFAULT_82573;
+    else if ((eeprom_data == ID_LED_RESERVED_0000) ||
+            (eeprom_data == ID_LED_RESERVED_FFFF)) {
+        if (hw->mac_type == e1000_ich8lan)
+            eeprom_data = ID_LED_DEFAULT_ICH8LAN;
+        else
+            eeprom_data = ID_LED_DEFAULT;
+    }
+    for (i = 0; i < 4; i++) {
         temp = (eeprom_data >> (i << 2)) & led_mask;
         switch(temp) {
         case ID_LED_ON1_DEF2:
@@ -5776,6 +6158,10 @@ e1000_cleanup_led(struct e1000_hw *hw)
             return ret_val;
         /* Fall Through */
     default:
+        if (hw->phy_type == e1000_phy_ife) {
+            e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
+            break;
+        }
         /* Restore LEDCTL settings */
         E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_default);
         break;
@@ -5820,7 +6206,10 @@ e1000_led_on(struct e1000_hw *hw)
             /* Clear SW Defineable Pin 0 to turn on the LED */
             ctrl &= ~E1000_CTRL_SWDPIN0;
             ctrl |= E1000_CTRL_SWDPIO0;
-        } else if(hw->media_type == e1000_media_type_copper) {
+        } else if (hw->phy_type == e1000_phy_ife) {
+            e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED,
+                 (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_ON));
+        } else if (hw->media_type == e1000_media_type_copper) {
             E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode2);
             return E1000_SUCCESS;
         }
@@ -5868,7 +6257,10 @@ e1000_led_off(struct e1000_hw *hw)
             /* Set SW Defineable Pin 0 to turn off the LED */
             ctrl |= E1000_CTRL_SWDPIN0;
             ctrl |= E1000_CTRL_SWDPIO0;
-        } else if(hw->media_type == e1000_media_type_copper) {
+        } else if (hw->phy_type == e1000_phy_ife) {
+            e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED,
+                 (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_OFF));
+        } else if (hw->media_type == e1000_media_type_copper) {
             E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
             return E1000_SUCCESS;
         }
@@ -5906,12 +6298,16 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw
     temp = E1000_READ_REG(hw, XOFFRXC);
     temp = E1000_READ_REG(hw, XOFFTXC);
     temp = E1000_READ_REG(hw, FCRUC);
+
+    if (hw->mac_type != e1000_ich8lan) {
     temp = E1000_READ_REG(hw, PRC64);
     temp = E1000_READ_REG(hw, PRC127);
     temp = E1000_READ_REG(hw, PRC255);
     temp = E1000_READ_REG(hw, PRC511);
     temp = E1000_READ_REG(hw, PRC1023);
     temp = E1000_READ_REG(hw, PRC1522);
+    }
+
     temp = E1000_READ_REG(hw, GPRC);
     temp = E1000_READ_REG(hw, BPRC);
     temp = E1000_READ_REG(hw, MPRC);
@@ -5931,12 +6327,16 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw
     temp = E1000_READ_REG(hw, TOTH);
     temp = E1000_READ_REG(hw, TPR);
     temp = E1000_READ_REG(hw, TPT);
+
+    if (hw->mac_type != e1000_ich8lan) {
     temp = E1000_READ_REG(hw, PTC64);
     temp = E1000_READ_REG(hw, PTC127);
     temp = E1000_READ_REG(hw, PTC255);
     temp = E1000_READ_REG(hw, PTC511);
     temp = E1000_READ_REG(hw, PTC1023);
     temp = E1000_READ_REG(hw, PTC1522);
+    }
+
     temp = E1000_READ_REG(hw, MPTC);
     temp = E1000_READ_REG(hw, BPTC);
 
@@ -5959,6 +6359,9 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw
 
     temp = E1000_READ_REG(hw, IAC);
     temp = E1000_READ_REG(hw, ICRXOC);
+
+    if (hw->mac_type == e1000_ich8lan) return;
+
     temp = E1000_READ_REG(hw, ICRXPTC);
     temp = E1000_READ_REG(hw, ICRXATC);
     temp = E1000_READ_REG(hw, ICTXPTC);
@@ -6139,6 +6542,7 @@ e1000_get_bus_info(struct e1000_hw *hw)
         hw->bus_width = e1000_bus_width_pciex_1;
         break;
     case e1000_82571:
+    case e1000_ich8lan:
     case e1000_80003es2lan:
         hw->bus_type = e1000_bus_type_pci_express;
         hw->bus_speed = e1000_bus_speed_2500;
@@ -6176,8 +6580,6 @@ e1000_get_bus_info(struct e1000_hw *hw)
         break;
     }
 }
-
-#if 0
 /******************************************************************************
  * Reads a value from one of the devices registers using port I/O (as opposed
  * memory mapped I/O). Only 82544 and newer devices support port I/O.
@@ -6195,7 +6597,6 @@ e1000_read_reg_io(struct e1000_hw *hw,
     e1000_io_write(hw, io_addr, offset);
     return e1000_io_read(hw, io_data);
 }
-#endif  /*  0  */
 
 /******************************************************************************
  * Writes a value to one of the devices registers using port I/O (as opposed to
@@ -6240,8 +6641,6 @@ e1000_get_cable_length(struct e1000_hw *
 {
     int32_t ret_val;
     uint16_t agc_value = 0;
-    uint16_t cur_agc, min_agc = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
-    uint16_t max_agc = 0;
     uint16_t i, phy_data;
     uint16_t cable_length;
 
@@ -6314,6 +6713,8 @@ e1000_get_cable_length(struct e1000_hw *
             break;
         }
     } else if(hw->phy_type == e1000_phy_igp) { /* For IGP PHY */
+        uint16_t cur_agc_value;
+        uint16_t min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
         uint16_t agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                                          {IGP01E1000_PHY_AGC_A,
                                                           IGP01E1000_PHY_AGC_B,
@@ -6326,23 +6727,23 @@ e1000_get_cable_length(struct e1000_hw *
             if(ret_val)
                 return ret_val;
 
-            cur_agc = phy_data >> IGP01E1000_AGC_LENGTH_SHIFT;
+            cur_agc_value = phy_data >> IGP01E1000_AGC_LENGTH_SHIFT;
 
-            /* Array bound check. */
-            if((cur_agc >= IGP01E1000_AGC_LENGTH_TABLE_SIZE - 1) ||
-               (cur_agc == 0))
+            /* Value bound check. */
+            if ((cur_agc_value >= IGP01E1000_AGC_LENGTH_TABLE_SIZE - 1) ||
+                (cur_agc_value == 0))
                 return -E1000_ERR_PHY;
 
-            agc_value += cur_agc;
+            agc_value += cur_agc_value;
 
             /* Update minimal AGC value. */
-            if(min_agc > cur_agc)
-                min_agc = cur_agc;
+            if (min_agc_value > cur_agc_value)
+                min_agc_value = cur_agc_value;
         }
 
         /* Remove the minimal AGC result for length < 50m */
-        if(agc_value < IGP01E1000_PHY_CHANNEL_NUM * e1000_igp_cable_length_50) {
-            agc_value -= min_agc;
+        if (agc_value < IGP01E1000_PHY_CHANNEL_NUM * e1000_igp_cable_length_50) {
+            agc_value -= min_agc_value;
 
             /* Get the average length of the remaining 3 channels */
             agc_value /= (IGP01E1000_PHY_CHANNEL_NUM - 1);
@@ -6358,7 +6759,10 @@ e1000_get_cable_length(struct e1000_hw *
                        IGP01E1000_AGC_RANGE) : 0;
         *max_length = e1000_igp_cable_length_table[agc_value] +
                       IGP01E1000_AGC_RANGE;
-    } else if (hw->phy_type == e1000_phy_igp_2) {
+    } else if (hw->phy_type == e1000_phy_igp_2 ||
+               hw->phy_type == e1000_phy_igp_3) {
+        uint16_t cur_agc_index, max_agc_index = 0;
+        uint16_t min_agc_index = IGP02E1000_AGC_LENGTH_TABLE_SIZE - 1;
         uint16_t agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
                                                          {IGP02E1000_PHY_AGC_A,
                                                           IGP02E1000_PHY_AGC_B,
@@ -6373,19 +6777,27 @@ e1000_get_cable_length(struct e1000_hw *
 	    /* Getting bits 15:9, which represent the combination of course and
              * fine gain values.  The result is a number that can be put into
              * the lookup table to obtain the approximate cable length. */
-            cur_agc = (phy_data >> IGP02E1000_AGC_LENGTH_SHIFT) &
-                      IGP02E1000_AGC_LENGTH_MASK;
+            cur_agc_index = (phy_data >> IGP02E1000_AGC_LENGTH_SHIFT) &
+                            IGP02E1000_AGC_LENGTH_MASK;
+
+            /* Array index bound check. */
+            if ((cur_agc_index >= IGP02E1000_AGC_LENGTH_TABLE_SIZE) ||
+                (cur_agc_index == 0))
+                return -E1000_ERR_PHY;
 
             /* Remove min & max AGC values from calculation. */
-            if (e1000_igp_2_cable_length_table[min_agc] > e1000_igp_2_cable_length_table[cur_agc])
-                min_agc = cur_agc;
-	    if (e1000_igp_2_cable_length_table[max_agc] < e1000_igp_2_cable_length_table[cur_agc])
-                max_agc = cur_agc;
+            if (e1000_igp_2_cable_length_table[min_agc_index] >
+                e1000_igp_2_cable_length_table[cur_agc_index])
+                min_agc_index = cur_agc_index;
+            if (e1000_igp_2_cable_length_table[max_agc_index] <
+                e1000_igp_2_cable_length_table[cur_agc_index])
+                max_agc_index = cur_agc_index;
 
-            agc_value += e1000_igp_2_cable_length_table[cur_agc];
+            agc_value += e1000_igp_2_cable_length_table[cur_agc_index];
         }
 
-        agc_value -= (e1000_igp_2_cable_length_table[min_agc] + e1000_igp_2_cable_length_table[max_agc]);
+        agc_value -= (e1000_igp_2_cable_length_table[min_agc_index] +
+                      e1000_igp_2_cable_length_table[max_agc_index]);
         agc_value /= (IGP02E1000_PHY_CHANNEL_NUM - 2);
 
         /* Calculate cable length with the error range of +/- 10 meters. */
@@ -6431,7 +6843,8 @@ e1000_check_polarity(struct e1000_hw *hw
             return ret_val;
         *polarity = (phy_data & M88E1000_PSSR_REV_POLARITY) >>
                     M88E1000_PSSR_REV_POLARITY_SHIFT;
-    } else if(hw->phy_type == e1000_phy_igp ||
+    } else if (hw->phy_type == e1000_phy_igp ||
+              hw->phy_type == e1000_phy_igp_3 ||
               hw->phy_type == e1000_phy_igp_2) {
         /* Read the Status register to check the speed */
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
@@ -6457,6 +6870,13 @@ e1000_check_polarity(struct e1000_hw *hw
              * 100 Mbps this bit is always 0) */
             *polarity = phy_data & IGP01E1000_PSSR_POLARITY_REVERSED;
         }
+    } else if (hw->phy_type == e1000_phy_ife) {
+        ret_val = e1000_read_phy_reg(hw, IFE_PHY_EXTENDED_STATUS_CONTROL,
+                                     &phy_data);
+        if (ret_val)
+            return ret_val;
+        *polarity = (phy_data & IFE_PESC_POLARITY_REVERSED) >>
+                           IFE_PESC_POLARITY_REVERSED_SHIFT;
     }
     return E1000_SUCCESS;
 }
@@ -6484,7 +6904,8 @@ e1000_check_downshift(struct e1000_hw *h
 
     DEBUGFUNC("e1000_check_downshift");
 
-    if(hw->phy_type == e1000_phy_igp ||
+    if (hw->phy_type == e1000_phy_igp ||
+        hw->phy_type == e1000_phy_igp_3 ||
         hw->phy_type == e1000_phy_igp_2) {
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH,
                                      &phy_data);
@@ -6501,6 +6922,9 @@ e1000_check_downshift(struct e1000_hw *h
 
         hw->speed_downgraded = (phy_data & M88E1000_PSSR_DOWNSHIFT) >>
                                M88E1000_PSSR_DOWNSHIFT_SHIFT;
+    } else if (hw->phy_type == e1000_phy_ife) {
+        /* e1000_phy_ife supports 10/100 speed only */
+        hw->speed_downgraded = FALSE;
     }
 
     return E1000_SUCCESS;
@@ -6545,7 +6969,9 @@ e1000_config_dsp_after_link_change(struc
 
         if(speed == SPEED_1000) {
 
-            e1000_get_cable_length(hw, &min_length, &max_length);
+            ret_val = e1000_get_cable_length(hw, &min_length, &max_length);
+            if (ret_val)
+                return ret_val;
 
             if((hw->dsp_config_state == e1000_dsp_config_enabled) &&
                 min_length >= e1000_igp_cable_length_50) {
@@ -6753,20 +7179,27 @@ static int32_t
 e1000_set_d3_lplu_state(struct e1000_hw *hw,
                         boolean_t active)
 {
+    uint32_t phy_ctrl = 0;
     int32_t ret_val;
     uint16_t phy_data;
     DEBUGFUNC("e1000_set_d3_lplu_state");
 
-    if(hw->phy_type != e1000_phy_igp && hw->phy_type != e1000_phy_igp_2)
+    if (hw->phy_type != e1000_phy_igp && hw->phy_type != e1000_phy_igp_2
+        && hw->phy_type != e1000_phy_igp_3)
         return E1000_SUCCESS;
 
     /* During driver activity LPLU should not be used or it will attain link
      * from the lowest speeds starting from 10Mbps. The capability is used for
      * Dx transitions and states */
-    if(hw->mac_type == e1000_82541_rev_2 || hw->mac_type == e1000_82547_rev_2) {
+    if (hw->mac_type == e1000_82541_rev_2 || hw->mac_type == e1000_82547_rev_2) {
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_GMII_FIFO, &phy_data);
-        if(ret_val)
+        if (ret_val)
             return ret_val;
+    } else if (hw->mac_type == e1000_ich8lan) {
+        /* MAC writes into PHY register based on the state transition
+         * and start auto-negotiation. SW driver can overwrite the settings
+         * in CSR PHY power control E1000_PHY_CTRL register. */
+        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL);
     } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if(ret_val)
@@ -6781,11 +7214,16 @@ e1000_set_d3_lplu_state(struct e1000_hw 
             if(ret_val)
                 return ret_val;
         } else {
+            if (hw->mac_type == e1000_ich8lan) {
+                phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
+                E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+            } else {
                 phy_data &= ~IGP02E1000_PM_D3_LPLU;
                 ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
                                               phy_data);
                 if (ret_val)
                     return ret_val;
+            }
         }
 
         /* LPLU and SmartSpeed are mutually exclusive.  LPLU is used during
@@ -6821,17 +7259,22 @@ e1000_set_d3_lplu_state(struct e1000_hw 
               (hw->autoneg_advertised == AUTONEG_ADVERTISE_10_100_ALL)) {
 
         if(hw->mac_type == e1000_82541_rev_2 ||
-           hw->mac_type == e1000_82547_rev_2) {
+            hw->mac_type == e1000_82547_rev_2) {
             phy_data |= IGP01E1000_GMII_FLEX_SPD;
             ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO, phy_data);
             if(ret_val)
                 return ret_val;
         } else {
+            if (hw->mac_type == e1000_ich8lan) {
+                phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
+                E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+            } else {
                 phy_data |= IGP02E1000_PM_D3_LPLU;
                 ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
                                               phy_data);
                 if (ret_val)
                     return ret_val;
+            }
         }
 
         /* When LPLU is enabled we should disable SmartSpeed */
@@ -6866,6 +7309,7 @@ static int32_t
 e1000_set_d0_lplu_state(struct e1000_hw *hw,
                         boolean_t active)
 {
+    uint32_t phy_ctrl = 0;
     int32_t ret_val;
     uint16_t phy_data;
     DEBUGFUNC("e1000_set_d0_lplu_state");
@@ -6873,15 +7317,24 @@ e1000_set_d0_lplu_state(struct e1000_hw 
     if(hw->mac_type <= e1000_82547_rev_2)
         return E1000_SUCCESS;
 
+    if (hw->mac_type == e1000_ich8lan) {
+        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL);
+    } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if(ret_val)
             return ret_val;
+    }
 
     if (!active) {
+        if (hw->mac_type == e1000_ich8lan) {
+            phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
+            E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+        } else {
             phy_data &= ~IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
             if (ret_val)
                 return ret_val;
+        }
 
         /* LPLU and SmartSpeed are mutually exclusive.  LPLU is used during
          * Dx states where the power conservation is most important.  During
@@ -6914,10 +7367,15 @@ e1000_set_d0_lplu_state(struct e1000_hw 
 
     } else {
 
+        if (hw->mac_type == e1000_ich8lan) {
+            phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
+            E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+        } else {
             phy_data |= IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
             if (ret_val)
                 return ret_val;
+        }
 
         /* When LPLU is enabled we should disable SmartSpeed */
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG, &phy_data);
@@ -7191,15 +7649,18 @@ e1000_mng_write_commit(
  * returns  - TRUE when the mode is IAMT or FALSE.
  ****************************************************************************/
 boolean_t
-e1000_check_mng_mode(
-    struct e1000_hw *hw)
+e1000_check_mng_mode(struct e1000_hw *hw)
 {
     uint32_t fwsm;
 
     fwsm = E1000_READ_REG(hw, FWSM);
 
-    if((fwsm & E1000_FWSM_MODE_MASK) ==
-        (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
+    if (hw->mac_type == e1000_ich8lan) {
+        if ((fwsm & E1000_FWSM_MODE_MASK) ==
+            (E1000_MNG_ICH_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
+            return TRUE;
+    } else if ((fwsm & E1000_FWSM_MODE_MASK) ==
+               (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
         return TRUE;
 
     return FALSE;
@@ -7439,7 +7900,6 @@ e1000_set_pci_express_master_disable(str
     E1000_WRITE_REG(hw, CTRL, ctrl);
 }
 
-#if 0
 /***************************************************************************
  *
  * Enables PCI-Express master access.
@@ -7463,7 +7923,6 @@ e1000_enable_pciex_master(struct e1000_h
     ctrl &= ~E1000_CTRL_GIO_MASTER_DISABLE;
     E1000_WRITE_REG(hw, CTRL, ctrl);
 }
-#endif  /*  0  */
 
 /*******************************************************************************
  *
@@ -7529,8 +7988,10 @@ e1000_get_auto_rd_done(struct e1000_hw *
     case e1000_82572:
     case e1000_82573:
     case e1000_80003es2lan:
-        while(timeout) {
-            if (E1000_READ_REG(hw, EECD) & E1000_EECD_AUTO_RD) break;
+    case e1000_ich8lan:
+        while (timeout) {
+            if (E1000_READ_REG(hw, EECD) & E1000_EECD_AUTO_RD)
+                break;
             else msec_delay(1);
             timeout--;
         }
@@ -7570,7 +8031,7 @@ e1000_get_phy_cfg_done(struct e1000_hw *
 
     switch (hw->mac_type) {
     default:
-        msec_delay(10);
+        msec_delay_irq(10);
         break;
     case e1000_80003es2lan:
         /* Separate *_CFG_DONE_* bit for each port */
@@ -7753,6 +8214,13 @@ int32_t
 e1000_check_phy_reset_block(struct e1000_hw *hw)
 {
     uint32_t manc = 0;
+    uint32_t fwsm = 0;
+
+    if (hw->mac_type == e1000_ich8lan) {
+        fwsm = E1000_READ_REG(hw, FWSM);
+        return (fwsm & E1000_FWSM_RSPCIPHY) ? E1000_SUCCESS
+                                            : E1000_BLK_PHY_RESET;
+    }
 
     if (hw->mac_type > e1000_82547_rev_2)
         manc = E1000_READ_REG(hw, MANC);
@@ -7779,6 +8247,8 @@ e1000_arc_subsystem_valid(struct e1000_h
         if((fwsm & E1000_FWSM_MODE_MASK) != 0)
             return TRUE;
         break;
+    case e1000_ich8lan:
+        return TRUE;
     default:
         break;
     }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f5689fa..95f4435 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -366,6 +366,7 @@ e1000_release_hw_control(struct e1000_ad
 {
 	uint32_t ctrl_ext;
 	uint32_t swsm;
+	uint32_t extcnf;
 
 	/* Let firmware taken over control of h/w */
 	switch (adapter->hw.mac_type) {
@@ -380,6 +381,11 @@ e1000_release_hw_control(struct e1000_ad
 		swsm = E1000_READ_REG(&adapter->hw, SWSM);
 		E1000_WRITE_REG(&adapter->hw, SWSM,
 				swsm & ~E1000_SWSM_DRV_LOAD);
+	case e1000_ich8lan:
+		extcnf = E1000_READ_REG(&adapter->hw, CTRL_EXT);
+		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
+				extcnf & ~E1000_CTRL_EXT_DRV_LOAD);
+		break;
 	default:
 		break;
 	}
@@ -401,6 +407,7 @@ e1000_get_hw_control(struct e1000_adapte
 {
 	uint32_t ctrl_ext;
 	uint32_t swsm;
+	uint32_t extcnf;
 	/* Let firmware know the driver has taken over */
 	switch (adapter->hw.mac_type) {
 	case e1000_82571:
@@ -415,6 +422,11 @@ e1000_get_hw_control(struct e1000_adapte
 		E1000_WRITE_REG(&adapter->hw, SWSM,
 				swsm | E1000_SWSM_DRV_LOAD);
 		break;
+	case e1000_ich8lan:
+		extcnf = E1000_READ_REG(&adapter->hw, EXTCNF_CTRL);
+		E1000_WRITE_REG(&adapter->hw, EXTCNF_CTRL,
+				extcnf | E1000_EXTCNF_CTRL_SWFLAG);
+		break;
 	default:
 		break;
 	}
@@ -490,6 +502,7 @@ static void e1000_power_down_phy(struct 
 	 * (b) AMT is active
 	 * (c) SoL/IDER session is active */
 	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.mac_type != e1000_ich8lan &&
 	    adapter->hw.media_type == e1000_media_type_copper &&
 	    !(E1000_READ_REG(&adapter->hw, MANC) & E1000_MANC_SMBUS_EN) &&
 	    !mng_mode_enabled &&
@@ -561,6 +574,9 @@ e1000_reset(struct e1000_adapter *adapte
 	case e1000_82573:
 		pba = E1000_PBA_12K;
 		break;
+	case e1000_ich8lan:
+		pba = E1000_PBA_8K;
+		break;
 	default:
 		pba = E1000_PBA_48K;
 		break;
@@ -585,6 +601,12 @@ e1000_reset(struct e1000_adapter *adapte
 	/* Set the FC high water mark to 90% of the FIFO size.
 	 * Required to clear last 3 LSB */
 	fc_high_water_mark = ((pba * 9216)/10) & 0xFFF8;
+	/* We can't use 90% on small FIFOs because the remainder
+	 * would be less than 1 full frame.  In this case, we size
+	 * it to allow at least a full frame above the high water
+	 *  mark. */
+	if (pba < E1000_PBA_16K)
+		fc_high_water_mark = (pba * 1024) - 1600;
 
 	adapter->hw.fc_high_water = fc_high_water_mark;
 	adapter->hw.fc_low_water = fc_high_water_mark - 8;
@@ -622,6 +644,8 @@ e1000_reset(struct e1000_adapter *adapte
 		                    phy_data);
 	}
 
+	if (adapter->hw.mac_type < e1000_ich8lan)
+	/* FIXME: this code is duplicate and wrong for PCI Express */
 	if (adapter->en_mng_pt) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
@@ -648,6 +672,7 @@ e1000_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct e1000_adapter *adapter;
 	unsigned long mmio_start, mmio_len;
+	unsigned long flash_start, flash_len;
 
 	static int cards_found = 0;
 	static int e1000_ksp3_port_a = 0; /* global ksp3 port a indication */
@@ -657,10 +682,12 @@ e1000_probe(struct pci_dev *pdev,
 	if ((err = pci_enable_device(pdev)))
 		return err;
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
+	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
 		pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) &&
+		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
 			E1000_ERR("No usable DMA configuration, aborting\n");
 			return err;
 		}
@@ -740,6 +767,19 @@ e1000_probe(struct pci_dev *pdev,
 	if ((err = e1000_sw_init(adapter)))
 		goto err_sw_init;
 
+	/* Flash BAR mapping must happen after e1000_sw_init
+	 * because it depends on mac_type */
+	if ((adapter->hw.mac_type == e1000_ich8lan) &&
+	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
+		flash_start = pci_resource_start(pdev, 1);
+		flash_len = pci_resource_len(pdev, 1);
+		adapter->hw.flash_address = ioremap(flash_start, flash_len);
+		if (!adapter->hw.flash_address) {
+			err = -EIO;
+			goto err_flashmap;
+		}
+	}
+
 	if ((err = e1000_check_phy_reset_block(&adapter->hw)))
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
@@ -758,6 +798,8 @@ e1000_probe(struct pci_dev *pdev,
 				   NETIF_F_HW_VLAN_TX |
 				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
+		if (adapter->hw.mac_type == e1000_ich8lan)
+			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
 	}
 
 #ifdef NETIF_F_TSO
@@ -773,11 +815,17 @@ e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	/* hard_start_xmit is safe against parallel locking */
 	netdev->features |= NETIF_F_LLTX;
 
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
+	/* initialize eeprom parameters */
+
+	if (e1000_init_eeprom_params(&adapter->hw)) {
+		E1000_ERR("EEPROM initialization failed\n");
+		return -EIO;
+	}
+
 	/* before reading the EEPROM, reset the controller to
 	 * put the device in a known good starting state */
 
@@ -845,6 +893,11 @@ e1000_probe(struct pci_dev *pdev,
 			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_82544_APM;
 		break;
+	case e1000_ich8lan:
+		e1000_read_eeprom(&adapter->hw,
+			EEPROM_INIT_CONTROL1_REG, 1, &eeprom_data);
+		eeprom_apme_mask = E1000_EEPROM_ICH8_APME;
+		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
 	case e1000_82571:
@@ -904,6 +957,9 @@ e1000_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	if (adapter->hw.flash_address)
+		iounmap(adapter->hw.flash_address);
+err_flashmap:
 err_sw_init:
 err_eeprom:
 	iounmap(adapter->hw.hw_addr);
@@ -937,6 +993,7 @@ e1000_remove(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 	if (adapter->hw.mac_type >= e1000_82540 &&
+	   adapter->hw.mac_type != e1000_ich8lan &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if (manc & E1000_MANC_SMBUS_EN) {
@@ -965,6 +1022,8 @@ e1000_remove(struct pci_dev *pdev)
 #endif
 
 	iounmap(adapter->hw.hw_addr);
+	if (adapter->hw.flash_address)
+		iounmap(adapter->hw.flash_address);
 	pci_release_regions(pdev);
 
 	free_netdev(netdev);
@@ -1015,13 +1074,6 @@ e1000_sw_init(struct e1000_adapter *adap
 		return -EIO;
 	}
 
-	/* initialize eeprom parameters */
-
-	if (e1000_init_eeprom_params(hw)) {
-		E1000_ERR("EEPROM initialization failed\n");
-		return -EIO;
-	}
-
 	switch (hw->mac_type) {
 	default:
 		break;
@@ -1257,8 +1309,7 @@ e1000_setup_tx_resources(struct e1000_ad
 	int size;
 
 	size = sizeof(struct e1000_buffer) * txdr->count;
-
-	txdr->buffer_info = vmalloc_node(size, pcibus_to_node(pdev->bus));
+	txdr->buffer_info = vmalloc(size);
 	if (!txdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the transmit descriptor ring\n");
@@ -1486,7 +1537,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	int size, desc_len;
 
 	size = sizeof(struct e1000_buffer) * rxdr->count;
-	rxdr->buffer_info = vmalloc_node(size, pcibus_to_node(pdev->bus));
+	rxdr->buffer_info = vmalloc(size);
 	if (!rxdr->buffer_info) {
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
@@ -2153,6 +2204,12 @@ e1000_set_multi(struct net_device *netde
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
+	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
+				E1000_NUM_MTA_REGISTERS_ICH8LAN :
+				E1000_NUM_MTA_REGISTERS;
+
+	if (adapter->hw.mac_type == e1000_ich8lan)
+		rar_entries = E1000_RAR_ENTRIES_ICH8LAN;
 
 	/* reserve RAR[14] for LAA over-write work-around */
 	if (adapter->hw.mac_type == e1000_82571)
@@ -2199,7 +2256,7 @@ e1000_set_multi(struct net_device *netde
 
 	/* clear the old settings from the multicast hash table */
 
-	for (i = 0; i < E1000_NUM_MTA_REGISTERS; i++) {
+	for (i = 0; i < mta_reg_count; i++) {
 		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
 		E1000_WRITE_FLUSH(hw);
 	}
@@ -2278,8 +2335,16 @@ e1000_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
+	int32_t ret_val;
 
-	e1000_check_for_link(&adapter->hw);
+	ret_val = e1000_check_for_link(&adapter->hw);
+	if ((ret_val == E1000_ERR_PHY) &&
+	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
+	    (E1000_READ_REG(&adapter->hw, CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
+		/* See e1000_kumeran_lock_loss_workaround() */
+		DPRINTK(LINK, INFO,
+			"Gigabit has been disabled, downgrading speed\n");
+	}
 	if (adapter->hw.mac_type == e1000_82573) {
 		e1000_enable_tx_pkt_filtering(&adapter->hw);
 		if (adapter->mng_vlan_id != adapter->hw.mng_cookie.vlan_id)
@@ -2845,6 +2910,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 			case e1000_82571:
 			case e1000_82572:
 			case e1000_82573:
+			case e1000_ich8lan:
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
 					DPRINTK(DRV, ERR,
@@ -3029,6 +3095,7 @@ e1000_change_mtu(struct net_device *netd
 	/* Adapter-specific max frame size limits. */
 	switch (adapter->hw.mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
+	case e1000_ich8lan:
 		if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
 			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
 			return -EINVAL;
@@ -3137,12 +3204,15 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->stats.bprc += E1000_READ_REG(hw, BPRC);
 	adapter->stats.mprc += E1000_READ_REG(hw, MPRC);
 	adapter->stats.roc += E1000_READ_REG(hw, ROC);
+
+	if (adapter->hw.mac_type != e1000_ich8lan) {
 	adapter->stats.prc64 += E1000_READ_REG(hw, PRC64);
 	adapter->stats.prc127 += E1000_READ_REG(hw, PRC127);
 	adapter->stats.prc255 += E1000_READ_REG(hw, PRC255);
 	adapter->stats.prc511 += E1000_READ_REG(hw, PRC511);
 	adapter->stats.prc1023 += E1000_READ_REG(hw, PRC1023);
 	adapter->stats.prc1522 += E1000_READ_REG(hw, PRC1522);
+	}
 
 	adapter->stats.symerrs += E1000_READ_REG(hw, SYMERRS);
 	adapter->stats.mpc += E1000_READ_REG(hw, MPC);
@@ -3170,12 +3240,16 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->stats.totl += E1000_READ_REG(hw, TOTL);
 	adapter->stats.toth += E1000_READ_REG(hw, TOTH);
 	adapter->stats.tpr += E1000_READ_REG(hw, TPR);
+
+	if (adapter->hw.mac_type != e1000_ich8lan) {
 	adapter->stats.ptc64 += E1000_READ_REG(hw, PTC64);
 	adapter->stats.ptc127 += E1000_READ_REG(hw, PTC127);
 	adapter->stats.ptc255 += E1000_READ_REG(hw, PTC255);
 	adapter->stats.ptc511 += E1000_READ_REG(hw, PTC511);
 	adapter->stats.ptc1023 += E1000_READ_REG(hw, PTC1023);
 	adapter->stats.ptc1522 += E1000_READ_REG(hw, PTC1522);
+	}
+
 	adapter->stats.mptc += E1000_READ_REG(hw, MPTC);
 	adapter->stats.bptc += E1000_READ_REG(hw, BPTC);
 
@@ -3197,6 +3271,8 @@ e1000_update_stats(struct e1000_adapter 
 	if (hw->mac_type > e1000_82547_rev_2) {
 		adapter->stats.iac += E1000_READ_REG(hw, IAC);
 		adapter->stats.icrxoc += E1000_READ_REG(hw, ICRXOC);
+
+		if (adapter->hw.mac_type != e1000_ich8lan) {
 		adapter->stats.icrxptc += E1000_READ_REG(hw, ICRXPTC);
 		adapter->stats.icrxatc += E1000_READ_REG(hw, ICRXATC);
 		adapter->stats.ictxptc += E1000_READ_REG(hw, ICTXPTC);
@@ -3204,6 +3280,7 @@ e1000_update_stats(struct e1000_adapter 
 		adapter->stats.ictxqec += E1000_READ_REG(hw, ICTXQEC);
 		adapter->stats.ictxqmtc += E1000_READ_REG(hw, ICTXQMTC);
 		adapter->stats.icrxdmtc += E1000_READ_REG(hw, ICRXDMTC);
+		}
 	}
 
 	/* Fill out the OS statistics structure */
@@ -4338,18 +4415,21 @@ e1000_vlan_rx_register(struct net_device
 		ctrl |= E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
+		if (adapter->hw.mac_type != e1000_ich8lan) {
 		/* enable VLAN receive filtering */
 		rctl = E1000_READ_REG(&adapter->hw, RCTL);
 		rctl |= E1000_RCTL_VFE;
 		rctl &= ~E1000_RCTL_CFIEN;
 		E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 		e1000_update_mng_vlan(adapter);
+		}
 	} else {
 		/* disable VLAN tag insert/strip */
 		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 		ctrl &= ~E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
+		if (adapter->hw.mac_type != e1000_ich8lan) {
 		/* disable VLAN filtering */
 		rctl = E1000_READ_REG(&adapter->hw, RCTL);
 		rctl &= ~E1000_RCTL_VFE;
@@ -4358,6 +4438,7 @@ e1000_vlan_rx_register(struct net_device
 			e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 		}
+		}
 	}
 
 	e1000_irq_enable(adapter);
@@ -4586,7 +4667,9 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
+	/* FIXME: this code is incorrect for PCI Express */
 	if (adapter->hw.mac_type >= e1000_82540 &&
+	   adapter->hw.mac_type != e1000_ich8lan &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if (manc & E1000_MANC_SMBUS_EN) {
@@ -4597,6 +4680,9 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		}
 	}
 
+	if (adapter->hw.phy_type == e1000_phy_igp_3)
+		e1000_phy_powerdown_workaround(&adapter->hw);
+
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);
@@ -4632,7 +4718,9 @@ e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
+	/* FIXME: this code is incorrect for PCI Express */
 	if (adapter->hw.mac_type >= e1000_82540 &&
+	   adapter->hw.mac_type != e1000_ich8lan &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc &= ~(E1000_MANC_ARP_EN);



--
Auke Kok <auke-jan.h.kok@intel.com>
