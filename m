From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 7/11] cleanup error return codes
Date: Mon, 8 Sep 2003 20:14:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081946120.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* clean up error return code propagation and eliminate redundant
  DEBUGOUT statements.

-------------


diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c	2003-08-22 17:01:40.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c	2003-09-08 09:13:11.000000000 -0700
@@ -455,8 +455,7 @@ e1000_init_hw(struct e1000_hw *hw)
     DEBUGFUNC("e1000_init_hw");
 
     /* Initialize Identification LED */
-    ret_val = e1000_id_led_init(hw);
-    if(ret_val < 0) {
+    if((ret_val = e1000_id_led_init(hw))) {
         DEBUGOUT("Error Initializing Identification LED\n");
         return ret_val;
     }
@@ -1165,14 +1008,12 @@ e1000_setup_copper_link(struct e1000_hw 
             if(hw->mac_type >= e1000_82544) {
                 e1000_config_collision_dist(hw);
             } else {
-                ret_val = e1000_config_mac_to_phy(hw);
-                if(ret_val < 0) {
+                if((ret_val = e1000_config_mac_to_phy(hw))) {
                     DEBUGOUT("Error configuring MAC to PHY settings\n");
                     return ret_val;
-                  }
+                }
             }
-            ret_val = e1000_config_fc_after_link_up(hw);
-            if(ret_val < 0) {
+            if((ret_val = e1000_config_fc_after_link_up(hw))) {
                 DEBUGOUT("Error Configuring Flow Control\n");
                 return ret_val;
             }
@@ -1202,22 +1202,20 @@ e1000_setup_copper_link(struct e1000_hw 
 int32_t
 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 {
+    int32_t ret_val;
     uint16_t mii_autoneg_adv_reg;
     uint16_t mii_1000t_ctrl_reg;
 
     DEBUGFUNC("e1000_phy_setup_autoneg");
 
     /* Read the MII Auto-Neg Advertisement Register (Address 4). */
-    if(e1000_read_phy_reg(hw, PHY_AUTONEG_ADV, &mii_autoneg_adv_reg) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_read_phy_reg(hw, PHY_AUTONEG_ADV,
+                                     &mii_autoneg_adv_reg)))
+        return ret_val;
 
     /* Read the MII 1000Base-T Control Register (Address 9). */
-    if(e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg)))
+        return ret_val;
 
     /* Need to parse both autoneg_advertised and fc and set up
      * the appropriate PHY registers.  First we will parse for
@@ -1323,18 +1318,16 @@ e1000_phy_setup_autoneg(struct e1000_hw 
         return -E1000_ERR_CONFIG;
     }
 
-    if(e1000_write_phy_reg(hw, PHY_AUTONEG_ADV, mii_autoneg_adv_reg) < 0) {
-        DEBUGOUT("PHY Write Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_write_phy_reg(hw, PHY_AUTONEG_ADV,
+                                      mii_autoneg_adv_reg)))
+        return ret_val;
 
     DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-    if(e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg) < 0) {
-        DEBUGOUT("PHY Write Error\n");
-        return -E1000_ERR_PHY;
-    }
-    return 0;
+    if((ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg)))
+        return ret_val;
+
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -1370,10 +1363,8 @@ e1000_phy_force_speed_duplex(struct e100
     ctrl &= ~E1000_CTRL_ASDE;
 
     /* Read the MII Control Register. */
-    if(e1000_read_phy_reg(hw, PHY_CTRL, &mii_ctrl_reg) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &mii_ctrl_reg)))
+        return ret_val;
 
     /* We need to disable autoneg in order to force link and duplex. */
 
@@ -1419,19 +1410,18 @@ e1000_phy_force_speed_duplex(struct e100
     E1000_WRITE_REG(hw, CTRL, ctrl);
 
     if (hw->phy_type == e1000_phy_m88) {
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
+                                         &phy_data)))
+            return ret_val;
 
         /* Clear Auto-Crossover to force MDI manually. M88E1000 requires MDI
          * forced whenever speed are duplex are forced.
          */
         phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
-        if(e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
+                                          phy_data)))
+            return ret_val;
+
         DEBUGOUT1("M88E1000 PSCR: %x \n", phy_data);
 
         /* Need to reset the PHY or these changes will be ignored */
@@ -1440,26 +1275,23 @@ e1000_phy_force_speed_duplex(struct e100
         /* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
          * forced whenever speed or duplex are forced.
          */
-        if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL,
+                                         &phy_data)))
+            return ret_val;
 
         phy_data &= ~IGP01E1000_PSCR_AUTO_MDIX;
         phy_data &= ~IGP01E1000_PSCR_FORCE_MDI_MDIX;
 
-        if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL,
+                                          phy_data)))
+            return ret_val;
     }
 
     /* Write back the modified PHY MII control register. */
-    if(e1000_write_phy_reg(hw, PHY_CTRL, mii_ctrl_reg) < 0) {
-        DEBUGOUT("PHY Write Error\n");
-        return -E1000_ERR_PHY;
-    }
     udelay(1);
+    if((ret_val = e1000_write_phy_reg(hw, PHY_CTRL, mii_ctrl_reg)))
+        return ret_val;
+
 
     /* The wait_autoneg_complete flag may be a little misleading here.
      * Since we are forcing speed and duplex, Auto-Neg is not enabled.
@@ -1478,22 +1465,18 @@ e1000_phy_force_speed_duplex(struct e100
             /* Read the MII Status Register and wait for Auto-Neg Complete bit
              * to be set.
              */
-            if(e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
-            if(e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
+            if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg)))
+                return ret_val;
+
+            if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg)))
+                return ret_val;
+
             if(mii_status_reg & MII_SR_LINK_STATUS) break;
             msec_delay(100);
         }
         if(i == 0) { /* We didn't get link */
             /* Reset the DSP and wait again for link. */
-
-            ret_val = e1000_phy_reset_dsp(hw);
-            if(ret_val < 0) {
+            if((ret_val = e1000_phy_reset_dsp(hw))) {
                 DEBUGOUT("Error Resetting PHY DSP\n");
                 return ret_val;
             }
@@ -1505,14 +1488,11 @@ e1000_phy_force_speed_duplex(struct e100
             /* Read the MII Status Register and wait for Auto-Neg Complete bit
              * to be set.
              */
-            if(e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
-            if(e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
+            if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg)))
+                return ret_val;
+
+            if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg)))
+                return ret_val;
         }
     }
 
@@ -1521,30 +1501,29 @@ e1000_phy_force_speed_duplex(struct e100
          * Extended PHY Specific Control Register to 25MHz clock.  This value
          * defaults back to a 2.5MHz clock when the PHY is reset.
          */
-        if(e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+                                         &phy_data)))
+            return ret_val;
+
         phy_data |= M88E1000_EPSCR_TX_CLK_25;
-        if(e1000_write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+                                          phy_data)))
+            return ret_val;
 
         /* In addition, because of the s/w reset above, we need to enable CRS on
          * TX.  This must be set for both full and half duplex operation.
          */
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
+                                         &phy_data)))
+            return ret_val;
+
         phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
-        if(e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data) < 0) {
-            DEBUGOUT("PHY Write Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL,
+                                          phy_data)))
+            return ret_val;
+
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -1584,6 +1563,7 @@ static int32_t
 e1000_config_mac_to_phy(struct e1000_hw *hw)
 {
     uint32_t ctrl;
+    int32_t ret_val;
     uint16_t phy_data;
 
     DEBUGFUNC("e1000_config_mac_to_phy");
@@ -1599,10 +1579,10 @@ e1000_config_mac_to_phy(struct e1000_hw 
      * registers depending on negotiated values.
      */
     if (hw->phy_type == e1000_phy_igp) {
-        if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
+                                         &phy_data)))
+            return ret_val;
+
         if(phy_data & IGP01E1000_PSSR_FULL_DUPLEX) ctrl |= E1000_CTRL_FD;
         else ctrl &= ~E1000_CTRL_FD;
 
@@ -1618,10 +1598,10 @@ e1000_config_mac_to_phy(struct e1000_hw 
                 IGP01E1000_PSSR_SPEED_100MBPS)
             ctrl |= E1000_CTRL_SPD_100;
     } else {
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data) < 0) {
-            DEBUGOUT("PHY Read Error\n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
+                                         &phy_data)))
+            return ret_val;
+
         if(phy_data & M88E1000_PSSR_DPLX) ctrl |= E1000_CTRL_FD;
         else ctrl &= ~E1000_CTRL_FD;
 
@@ -1637,7 +1617,7 @@ e1000_config_mac_to_phy(struct e1000_hw 
     }
     /* Write the configured values back to the Device Control Reg. */
     E1000_WRITE_REG(hw, CTRL, ctrl);
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -1737,8 +1570,7 @@ e1000_config_fc_after_link_up(struct e10
     if(((hw->media_type == e1000_media_type_fiber) && (hw->autoneg_failed)) ||
        ((hw->media_type == e1000_media_type_internal_serdes) && (hw->autoneg_failed)) ||
        ((hw->media_type == e1000_media_type_copper) && (!hw->autoneg))) {
-        ret_val = e1000_force_mac_fc(hw);
-        if(ret_val < 0) {
+        if((ret_val = e1000_force_mac_fc(hw))) {
             DEBUGOUT("Error forcing flow control settings\n");
             return ret_val;
         }
@@ -1754,14 +1588,10 @@ e1000_config_fc_after_link_up(struct e10
          * has completed.  We read this twice because this reg has
          * some "sticky" (latched) bits.
          */
-        if(e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg) < 0) {
-            DEBUGOUT("PHY Read Error \n");
-            return -E1000_ERR_PHY;
-        }
-        if(e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg) < 0) {
-            DEBUGOUT("PHY Read Error \n");
-            return -E1000_ERR_PHY;
-        }
+        if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg)))
+            return ret_val;
+        if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &mii_status_reg)))
+            return ret_val;
 
         if(mii_status_reg & MII_SR_AUTONEG_COMPLETE) {
             /* The AutoNeg process has completed, so we now need to
@@ -1770,14 +1745,12 @@ e1000_config_fc_after_link_up(struct e10
              * Register (Address 5) to determine how flow control was
              * negotiated.
              */
-            if(e1000_read_phy_reg(hw, PHY_AUTONEG_ADV, &mii_nway_adv_reg) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
-            if(e1000_read_phy_reg(hw, PHY_LP_ABILITY, &mii_nway_lp_ability_reg) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
+            if((ret_val = e1000_read_phy_reg(hw, PHY_AUTONEG_ADV,
+                                             &mii_nway_adv_reg)))
+                return ret_val;
+            if((ret_val = e1000_read_phy_reg(hw, PHY_LP_ABILITY,
+                                             &mii_nway_lp_ability_reg)))
+                return ret_val;
 
             /* Two bits in the Auto Negotiation Advertisement Register
              * (Address 4) and two bits in the Auto Negotiation Base
@@ -1892,7 +1865,10 @@ e1000_config_fc_after_link_up(struct e10
              * negotiated to HALF DUPLEX, flow control should not be
              * enabled per IEEE 802.3 spec.
              */
-            e1000_get_speed_and_duplex(hw, &speed, &duplex);
+            if((ret_val = e1000_get_speed_and_duplex(hw, &speed, &duplex))) {
+                DEBUGOUT("Error getting link speed and duplex\n");
+                return ret_val;
+            }
 
             if(duplex == HALF_DUPLEX)
                 hw->fc = e1000_fc_none;
@@ -1900,16 +1876,15 @@ e1000_config_fc_after_link_up(struct e10
             /* Now we call a subroutine to actually force the MAC
              * controller to use the correct flow control settings.
              */
-            ret_val = e1000_force_mac_fc(hw);
-            if(ret_val < 0) {
+            if((ret_val = e1000_force_mac_fc(hw))) {
                 DEBUGOUT("Error forcing flow control settings\n");
                 return ret_val;
-             }
+            }
         } else {
             DEBUGOUT("Copper PHY and Auto Neg has not completed.\r\n");
         }
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -1956,14 +1931,10 @@ e1000_check_for_link(struct e1000_hw *hw
          * of the PHY.
          * Read the register twice since the link bit is sticky.
          */
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
 
         if(phy_data & MII_SR_LINK_STATUS) {
             hw->get_link_status = FALSE;
@@ -1996,8 +1967,7 @@ e1000_check_for_link(struct e1000_hw *hw
         if(hw->mac_type >= e1000_82544)
             e1000_config_collision_dist(hw);
         else {
-            ret_val = e1000_config_mac_to_phy(hw);
-            if(ret_val < 0) {
+            if((ret_val = e1000_config_mac_to_phy(hw))) {
                 DEBUGOUT("Error configuring MAC to PHY settings\n");
                 return ret_val;
             }
@@ -2007,8 +1977,7 @@ e1000_check_for_link(struct e1000_hw *hw
          * need to restore the desired flow control settings because we may
          * have had to re-autoneg with a different link partner.
          */
-        ret_val = e1000_config_fc_after_link_up(hw);
-        if(ret_val < 0) {
+        if((ret_val = e1000_config_fc_after_link_up(hw))) {
             DEBUGOUT("Error configuring flow control\n");
             return ret_val;
         }
@@ -2023,10 +1992,9 @@ e1000_check_for_link(struct e1000_hw *hw
          * partner is TBI-based, and we turn on TBI Compatibility.
          */
         if(hw->tbi_compatibility_en) {
-            if(e1000_read_phy_reg(hw, PHY_LP_ABILITY, &lp_capability) < 0) {
-                DEBUGOUT("PHY Read Error\n");
-                return -E1000_ERR_PHY;
-            }
+            if((ret_val = e1000_read_phy_reg(hw, PHY_LP_ABILITY,
+                                             &lp_capability)))
+                return ret_val;
             if(lp_capability & (NWAY_LPAR_10T_HD_CAPS |
                                 NWAY_LPAR_10T_FD_CAPS |
                                 NWAY_LPAR_100TX_HD_CAPS |
@@ -2083,8 +2051,7 @@ e1000_check_for_link(struct e1000_hw *hw
         E1000_WRITE_REG(hw, CTRL, ctrl);
 
         /* Configure Flow Control after forcing link up. */
-        ret_val = e1000_config_fc_after_link_up(hw);
-        if(ret_val < 0) {
+        if((ret_val = e1000_config_fc_after_link_up(hw))) {
             DEBUGOUT("Error configuring flow control\n");
             return ret_val;
         }
@@ -2101,7 +2068,7 @@ e1000_check_for_link(struct e1000_hw *hw
         E1000_WRITE_REG(hw, TXCW, hw->txcw);
         E1000_WRITE_REG(hw, CTRL, (ctrl & ~E1000_CTRL_SLU));
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -2178,6 +2145,7 @@ e1000_get_speed_and_duplex(struct e1000_
 int32_t
 e1000_wait_autoneg(struct e1000_hw *hw)
 {
+    int32_t ret_val;
     uint16_t i;
     uint16_t phy_data;
 
@@ -2189,20 +2157,16 @@ e1000_wait_autoneg(struct e1000_hw *hw)
         /* Read the MII Status Register and wait for Auto-Neg
          * Complete bit to be set.
          */
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
         if(phy_data & MII_SR_AUTONEG_COMPLETE) {
-            return 0;
+            return E1000_SUCCESS;
         }
         msec_delay(100);
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -2627,23 +2393,21 @@ e1000_phy_reset(struct e1000_hw *hw)
 int32_t
 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
+    int32_t phy_init_status, ret_val;
     uint16_t phy_id_high, phy_id_low;
     boolean_t match = FALSE;
-    int32_t phy_init_status;
 
     DEBUGFUNC("e1000_detect_gig_phy");
 
     /* Read the PHY ID Registers to identify which PHY is onboard. */
-    if(e1000_read_phy_reg(hw, PHY_ID1, &phy_id_high) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_read_phy_reg(hw, PHY_ID1, &phy_id_high)))
+        return ret_val;
+
     hw->phy_id = (uint32_t) (phy_id_high << 16);
     udelay(20);
-    if(e1000_read_phy_reg(hw, PHY_ID2, &phy_id_low) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_read_phy_reg(hw, PHY_ID2, &phy_id_low)))
+        return ret_val;
+
     hw->phy_id |= (uint32_t) (phy_id_low & PHY_REVISION_MASK);
     hw->phy_revision = (uint32_t) phy_id_low & ~PHY_REVISION_MASK;
 
@@ -2675,7 +2637,7 @@ e1000_detect_gig_phy(struct e1000_hw *hw
 
     if ((match) && (phy_init_status == E1000_SUCCESS)) {
         DEBUGOUT1("PHY ID 0x%X detected\n", hw->phy_id);
-        return 0;
+        return E1000_SUCCESS;
     }
     DEBUGOUT1("Invalid PHY ID 0x%X\n", hw->phy_id);
     return -E1000_ERR_PHY;
@@ -2728,13 +2690,14 @@ e1000_phy_igp_get_info(struct e1000_hw *
     phy_info->polarity_correction = e1000_polarity_reversal_enabled;
 
     /* Check polarity status */
-    if(e1000_check_polarity(hw, &polarity) < 0)
-        return -E1000_ERR_PHY;
+    if((ret_val = e1000_check_polarity(hw, &polarity)))
+        return ret_val;
 
     phy_info->cable_polarity = polarity;
 
-    if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS, &phy_data) < 0)
-        return -E1000_ERR_PHY;
+    if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
+                                     &phy_data)))
+        return ret_val;
 
     phy_info->mdix_mode = (phy_data & IGP01E1000_PSSR_MDIX) >>
                           IGP01E1000_PSSR_MDIX_SHIFT;
@@ -2742,8 +2705,8 @@ e1000_phy_igp_get_info(struct e1000_hw *
     if((phy_data & IGP01E1000_PSSR_SPEED_MASK) ==
        IGP01E1000_PSSR_SPEED_1000MBPS) {
         /* Local/Remote Receiver Information are only valid at 1000 Mbps */
-        if(e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data) < 0)
-            return -E1000_ERR_PHY;
+        if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data)))
+            return ret_val;
 
         phy_info->local_rx = (phy_data & SR_1000T_LOCAL_RX_STATUS) >>
                              SR_1000T_LOCAL_RX_STATUS_SHIFT;
@@ -2751,8 +2714,8 @@ e1000_phy_igp_get_info(struct e1000_hw *
                               SR_1000T_REMOTE_RX_STATUS_SHIFT;
 
         /* Get cable length */
-        if(e1000_get_cable_length(hw, &min_length, &max_length) < 0)
-            return -E1000_ERR_PHY;
+        if((ret_val = e1000_get_cable_length(hw, &min_length, &max_length)))
+            return ret_val;
 
         /* transalte to old method */
         average = (max_length + min_length) / 2;
@@ -2779,8 +2742,10 @@ e1000_phy_igp_get_info(struct e1000_hw *
 * phy_info - PHY information structure
 ******************************************************************************/
 int32_t
-e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
+e1000_phy_m88_get_info(struct e1000_hw *hw,
+                       struct e1000_phy_info *phy_info)
 {
+    int32_t ret_val;
     uint16_t phy_data, polarity;
 
     DEBUGFUNC("e1000_phy_m88_get_info");
@@ -2789,8 +2754,8 @@ e1000_phy_m88_get_info(struct e1000_hw *
      * and it stored in the hw->speed_downgraded parameter. */
     phy_info->downshift = hw->speed_downgraded;
 
-    if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data) < 0)
-        return -E1000_ERR_PHY;
+    if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data)))
+        return ret_val;
 
     phy_info->extended_10bt_distance =
         (phy_data & M88E1000_PSCR_10BT_EXT_DIST_ENABLE) >>
@@ -2800,13 +2765,13 @@ e1000_phy_m88_get_info(struct e1000_hw *
         M88E1000_PSCR_POLARITY_REVERSAL_SHIFT;
 
     /* Check polarity status */
-    if(e1000_check_polarity(hw, &polarity) < 0)
-        return -E1000_ERR_PHY;
+    if((ret_val = e1000_check_polarity(hw, &polarity)))
+        return ret_val;
 
     phy_info->cable_polarity = polarity;
 
-    if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data) < 0)
-        return -E1000_ERR_PHY;
+    if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data)))
+        return ret_val;
 
     phy_info->mdix_mode = (phy_data & M88E1000_PSSR_MDIX) >>
                           M88E1000_PSSR_MDIX_SHIFT;
@@ -2818,8 +2783,8 @@ e1000_phy_m88_get_info(struct e1000_hw *
         phy_info->cable_length = ((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
                                   M88E1000_PSSR_CABLE_LENGTH_SHIFT);
 
-        if(e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data) < 0)
-            return -E1000_ERR_PHY;
+        if((ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data)))
+            return ret_val;
 
         phy_info->local_rx = (phy_data & SR_1000T_LOCAL_RX_STATUS) >>
                              SR_1000T_LOCAL_RX_STATUS_SHIFT;
@@ -2841,6 +2806,7 @@ int32_t
 e1000_phy_get_info(struct e1000_hw *hw,
                    struct e1000_phy_info *phy_info)
 {
+    int32_t ret_val;
     uint16_t phy_data;
 
     DEBUGFUNC("e1000_phy_get_info");
@@ -2859,20 +2825,18 @@ e1000_phy_get_info(struct e1000_hw *hw,
         return -E1000_ERR_CONFIG;
     }
 
-    if(e1000_read_phy_reg(hw, PHY_STATUS, &phy_data) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
-    if(e1000_read_phy_reg(hw, PHY_STATUS, &phy_data) < 0) {
-        DEBUGOUT("PHY Read Error\n");
-        return -E1000_ERR_PHY;
-    }
+    if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data)))
+        return ret_val;
+
+    if((ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data)))
+        return ret_val;
+
     if((phy_data & MII_SR_LINK_STATUS) != MII_SR_LINK_STATUS) {
         DEBUGOUT("PHY info is only valid if link is up\n");
         return -E1000_ERR_CONFIG;
     }
 
-    if (hw->phy_type == e1000_phy_igp)
+    if(hw->phy_type == e1000_phy_igp)
         return e1000_phy_igp_get_info(hw, phy_info);
     else
         return e1000_phy_m88_get_info(hw, phy_info);
@@ -2888,7 +2852,7 @@ e1000_validate_mdi_setting(struct e1000_
         hw->mdix = 1;
         return -E1000_ERR_CONFIG;
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 
@@ -3445,9 +3409,9 @@ e1000_validate_eeprom_checksum(struct e1
         checksum += eeprom_data;
     }
 
-    if(checksum == (uint16_t) EEPROM_SUM) {
-        return 0;
-    } else {
+    if(checksum == (uint16_t) EEPROM_SUM)
+        return E1000_SUCCESS;
+    else {
         DEBUGOUT("EEPROM Checksum Invalid\n");
         return -E1000_ERR_EEPROM;
     }
@@ -3481,7 +3445,7 @@ e1000_update_eeprom_checksum(struct e100
         DEBUGOUT("EEPROM Write Error\n");
         return -E1000_ERR_EEPROM;
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3679,7 +3643,7 @@ e1000_write_eeprom_microwire(struct e100
 
     e1000_shift_out_ee_bits(hw, 0, (uint16_t)(eeprom->address_bits - 2));
 
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3713,7 +3677,7 @@ e1000_read_part_num(struct e1000_hw *hw,
     /* Save word 1 in lower half of part_num */
     *part_num |= eeprom_data;
 
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -3748,7 +3712,7 @@ e1000_read_mac_addr(struct e1000_hw * hw
     }
     for(i = 0; i < NODE_ADDRESS_SIZE; i++)
         hw->mac_addr[i] = hw->perm_mac_addr[i];
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -4024,7 +3988,7 @@ e1000_id_led_init(struct e1000_hw * hw)
 
     if(hw->mac_type < e1000_82540) {
         /* Nothing to do */
-        return 0;
+        return E1000_SUCCESS;
     }
 
     ledctl = E1000_READ_REG(hw, LEDCTL);
@@ -4075,7 +4039,7 @@ e1000_id_led_init(struct e1000_hw * hw)
             break;
         }
     }
-    return 0;
+    return E1000_SUCCESS;
 }
 
 /******************************************************************************
@@ -4590,9 +4554,11 @@ e1000_write_reg_io(struct e1000_hw *hw,
  * For IGP phy's, the function calculates the range by the AGC registers.
  *****************************************************************************/
 int32_t
-e1000_get_cable_length(struct e1000_hw *hw, uint16_t *min_length,
+e1000_get_cable_length(struct e1000_hw *hw,
+                       uint16_t *min_length,
                        uint16_t *max_length)
 {
+    int32_t ret_val;
     uint16_t agc_value = 0;
     uint16_t cur_agc, min_agc = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
     uint16_t i, phy_data;
@@ -4603,8 +4569,9 @@ e1000_get_cable_length(struct e1000_hw *
 
     /* Use old method for Phy older than IGP */
     if(hw->phy_type == e1000_phy_m88) {
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data) < 0)
-            return -E1000_ERR_PHY;
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
+                                         &phy_data)))
+            return ret_val;
 
         /* Convert the enum value to ranged values */
         switch((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
@@ -4707,22 +4674,26 @@ e1000_get_cable_length(struct e1000_hw *
  * IGP01E1000_PHY_PCS_INIT_REG.
  *****************************************************************************/
 int32_t
-e1000_check_polarity(struct e1000_hw *hw, uint16_t *polarity)
+e1000_check_polarity(struct e1000_hw *hw,
+                     uint16_t *polarity)
 {
+    int32_t ret_val;
     uint16_t phy_data;
 
     DEBUGFUNC("e1000_check_polarity");
 
     if(hw->phy_type == e1000_phy_m88) {
         /* return the Polarity bit in the Status register. */
-        if(e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data) < 0)
-            return -E1000_ERR_PHY;
+        if((ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
+                                         &phy_data)))
+            return ret_val;
         *polarity = (phy_data & M88E1000_PSSR_REV_POLARITY) >>
                     M88E1000_PSSR_REV_POLARITY_SHIFT;
     } else if(hw->phy_type == e1000_phy_igp) {
         /* Read the Status register to check the speed */
-        if(e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS, &phy_data) < 0)
-            return -E1000_ERR_PHY;
+        if((ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
+                                         &phy_data)))
+            return ret_val;
 
         /* If speed is 1000 Mbps, must read the IGP01E1000_PHY_PCS_INIT_REG to
          * find the polarity status */
