From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 9/10] e1000: Fixes related to Cable length
Date: Tue, 15 Feb 2005 14:46:52 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151444270.4560-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

9 Fixes related to Cable length estimation
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_hw.c net-drivers-2.6/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.6/drivers/net/e1000/e1000_hw.c	2005-02-01 23:10:24.987106184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_hw.c	2005-02-01 23:10:26.569865568 -0800
@@ -2503,7 +2503,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
         }
     }
 
-    ret_val = e1000_read_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+    ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                     phy_data);
 
     return ret_val;
@@ -2609,7 +2609,7 @@ e1000_write_phy_reg(struct e1000_hw *hw,
         }
     }
 
-    ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+    ret_val = e1000_write_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                      phy_data);
 
     return ret_val;
@@ -2966,9 +2966,9 @@ e1000_phy_m88_get_info(struct e1000_hw *
     phy_info->mdix_mode = (phy_data & M88E1000_PSSR_MDIX) >>
                           M88E1000_PSSR_MDIX_SHIFT;
 
-    if(phy_data & M88E1000_PSSR_1000MBS) {
-        /* Cable Length Estimation and Local/Remote Receiver Informatoion
-         * are only valid at 1000 Mbps
+    if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
+        /* Cable Length Estimation and Local/Remote Receiver Information
+         * are only valid at 1000 Mbps.
          */
         phy_info->cable_length = ((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
                                   M88E1000_PSSR_CABLE_LENGTH_SHIFT);
@@ -4639,41 +4639,44 @@ e1000_get_bus_info(struct e1000_hw *hw)
 {
     uint32_t status;
 
-    if(hw->mac_type < e1000_82543) {
+    switch (hw->mac_type) {
+    case e1000_82542_rev2_0:
+    case e1000_82542_rev2_1:
         hw->bus_type = e1000_bus_type_unknown;
         hw->bus_speed = e1000_bus_speed_unknown;
         hw->bus_width = e1000_bus_width_unknown;
-        return;
-    }
-
-    status = E1000_READ_REG(hw, STATUS);
-    hw->bus_type = (status & E1000_STATUS_PCIX_MODE) ?
-                   e1000_bus_type_pcix : e1000_bus_type_pci;
+        break;
+    default:
+        status = E1000_READ_REG(hw, STATUS);
+        hw->bus_type = (status & E1000_STATUS_PCIX_MODE) ?
+                       e1000_bus_type_pcix : e1000_bus_type_pci;
 
-    if(hw->device_id == E1000_DEV_ID_82546EB_QUAD_COPPER) {
-        hw->bus_speed = (hw->bus_type == e1000_bus_type_pci) ?
-                        e1000_bus_speed_66 : e1000_bus_speed_120;
-    } else if(hw->bus_type == e1000_bus_type_pci) {
-        hw->bus_speed = (status & E1000_STATUS_PCI66) ?
-                        e1000_bus_speed_66 : e1000_bus_speed_33;
-    } else {
-        switch (status & E1000_STATUS_PCIX_SPEED) {
-        case E1000_STATUS_PCIX_SPEED_66:
-            hw->bus_speed = e1000_bus_speed_66;
-            break;
-        case E1000_STATUS_PCIX_SPEED_100:
-            hw->bus_speed = e1000_bus_speed_100;
-            break;
-        case E1000_STATUS_PCIX_SPEED_133:
-            hw->bus_speed = e1000_bus_speed_133;
-            break;
-        default:
-            hw->bus_speed = e1000_bus_speed_reserved;
-            break;
+        if(hw->device_id == E1000_DEV_ID_82546EB_QUAD_COPPER) {
+            hw->bus_speed = (hw->bus_type == e1000_bus_type_pci) ?
+                            e1000_bus_speed_66 : e1000_bus_speed_120;
+        } else if(hw->bus_type == e1000_bus_type_pci) {
+            hw->bus_speed = (status & E1000_STATUS_PCI66) ?
+                            e1000_bus_speed_66 : e1000_bus_speed_33;
+        } else {
+            switch (status & E1000_STATUS_PCIX_SPEED) {
+            case E1000_STATUS_PCIX_SPEED_66:
+                hw->bus_speed = e1000_bus_speed_66;
+                break;
+            case E1000_STATUS_PCIX_SPEED_100:
+                hw->bus_speed = e1000_bus_speed_100;
+                break;
+            case E1000_STATUS_PCIX_SPEED_133:
+                hw->bus_speed = e1000_bus_speed_133;
+                break;
+            default:
+                hw->bus_speed = e1000_bus_speed_reserved;
+                break;
+            }
         }
+        hw->bus_width = (status & E1000_STATUS_BUS64) ?
+                        e1000_bus_width_64 : e1000_bus_width_32;
+        break;
     }
-    hw->bus_width = (status & E1000_STATUS_BUS64) ?
-                    e1000_bus_width_64 : e1000_bus_width_32;
 }
 /******************************************************************************
  * Reads a value from one of the devices registers using port I/O (as opposed
@@ -4738,6 +4741,7 @@ e1000_get_cable_length(struct e1000_hw *
     uint16_t agc_value = 0;
     uint16_t cur_agc, min_agc = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
     uint16_t i, phy_data;
+    uint16_t cable_length;
 
     DEBUGFUNC("e1000_get_cable_length");
 
@@ -4749,10 +4750,11 @@ e1000_get_cable_length(struct e1000_hw *
                                      &phy_data);
         if(ret_val)
             return ret_val;
+        cable_length = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
+                       M88E1000_PSSR_CABLE_LENGTH_SHIFT;
 
         /* Convert the enum value to ranged values */
-        switch((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
-               M88E1000_PSSR_CABLE_LENGTH_SHIFT) {
+        switch (cable_length) {
         case e1000_cable_length_50:
             *min_length = 0;
             *max_length = e1000_igp_cable_length_50;
	
