From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 12/13] e1000:  Applied smart speed fix where the code
 was forcing smart speed on all the time.  Now it will honor the setting
 defined in the eeprom
Date: Thu, 6 Jan 2005 17:20:31 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061514210.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.c net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.c	2004-12-06 08:43:11.629382832 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c	2004-12-06 08:43:12.460256520 -0800
@@ -5203,14 +5203,29 @@ e1000_set_d3_lplu_state(struct e1000_hw 
          * Dx states where the power conservation is most important.  During
          * driver activity we should enable SmartSpeed, so performance is
          * maintained. */
-        ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG, &phy_data);
-        if(ret_val)
-            return ret_val;
+        if (hw->smart_speed == e1000_smart_speed_on) {
+            ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                         &phy_data);
+            if(ret_val)
+                return ret_val;
 
-        phy_data |= IGP01E1000_PSCFR_SMART_SPEED;
-        ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG, phy_data);
-        if(ret_val)
-            return ret_val;
+            phy_data |= IGP01E1000_PSCFR_SMART_SPEED;
+            ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                          phy_data);
+            if(ret_val)
+                return ret_val;
+        } else if (hw->smart_speed == e1000_smart_speed_off) {
+            ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                         &phy_data);
+	    if (ret_val)
+                return ret_val;
+
+            phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
+            ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+                                          phy_data);
+            if(ret_val)
+                return ret_val;
+        }
 
     } else if((hw->autoneg_advertised == AUTONEG_ADVERTISE_SPEED_DEFAULT) ||
               (hw->autoneg_advertised == AUTONEG_ADVERTISE_10_ALL ) ||
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.h net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.h	2004-12-06 08:43:11.633382224 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h	2004-12-06 08:43:12.497250896 -0800
@@ -169,6 +169,12 @@ typedef enum {
 } e1000_downshift;
 
 typedef enum {
+    e1000_smart_speed_default = 0,
+    e1000_smart_speed_on,
+    e1000_smart_speed_off
+} e1000_smart_speed;
+
+typedef enum {
     e1000_polarity_reversal_enabled = 0,
     e1000_polarity_reversal_disabled,
     e1000_polarity_reversal_undefined = 0xFF
@@ -1027,6 +1033,7 @@ struct e1000_hw {
     uint8_t perm_mac_addr[NODE_ADDRESS_SIZE];
     boolean_t disable_polarity_correction;
     boolean_t speed_downgraded;
+    e1000_smart_speed smart_speed;
     e1000_dsp_config dsp_config_state;
     boolean_t get_link_status;
     boolean_t serdes_link_down;
