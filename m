From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 10/13] e1000: Added workaround to prevent inadvertent
 gigabit waveform to be sent out on the wire due to init-time operations on
 the IGP phy
Date: Thu, 6 Jan 2005 17:20:17 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061510410.7330-100000@isotope.jf.intel.com>
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
@@ -123,17 +123,31 @@ e1000_set_phy_type(struct e1000_hw *hw)
 static void
 e1000_phy_init_script(struct e1000_hw *hw)
 {
+    uint32_t ret_val;
+    uint16_t phy_saved_data;
+
     DEBUGFUNC("e1000_phy_init_script");
 
-    
+
     if(hw->phy_init_script) {
         msec_delay(20);
 
+        /* Save off the current value of register 0x2F5B to be restored at
+         * the end of this routine. */
+        ret_val = e1000_read_phy_reg(hw, 0x2F5B, &phy_saved_data);
+
+        /* Disabled the PHY transmitter */
+        e1000_write_phy_reg(hw, 0x2F5B, 0x0003);
+
+        msec_delay(20);
+
         e1000_write_phy_reg(hw,0x0000,0x0140);
 
         msec_delay(5);
 
-        if(hw->mac_type == e1000_82541 || hw->mac_type == e1000_82547) {
+        switch(hw->mac_type) {
+        case e1000_82541:
+        case e1000_82547:
             e1000_write_phy_reg(hw, 0x1F95, 0x0001);
 
             e1000_write_phy_reg(hw, 0x1F71, 0xBD21);
@@ -151,12 +165,23 @@ e1000_phy_init_script(struct e1000_hw *h
             e1000_write_phy_reg(hw, 0x1F96, 0x003F);
 
             e1000_write_phy_reg(hw, 0x2010, 0x0008);
-        } else {
+            break;
+
+        case e1000_82541_rev_2:
+        case e1000_82547_rev_2:
             e1000_write_phy_reg(hw, 0x1F73, 0x0099);
+            break;
+        default:
+            break;
         }
 
         e1000_write_phy_reg(hw, 0x0000, 0x3300);
 
+        msec_delay(20);
+
+        /* Now enable the transmitter */
+        e1000_write_phy_reg(hw, 0x2F5B, phy_saved_data);
+
         if(hw->mac_type == e1000_82547) {
             uint16_t fused, fine, coarse;
 
@@ -968,7 +993,7 @@ e1000_setup_copper_link(struct e1000_hw 
 
             if((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
                 hw->dsp_config_state = e1000_dsp_config_disabled;
-                /* Force MDI for IGP B-0 PHY */
+                /* Force MDI for earlier revs of the IGP PHY */
                 phy_data &= ~(IGP01E1000_PSCR_AUTO_MDIX |
                               IGP01E1000_PSCR_FORCE_MDI_MDIX);
                 hw->mdix = 1;
@@ -4924,7 +4949,7 @@ e1000_config_dsp_after_link_change(struc
                                    boolean_t link_up)
 {
     int32_t ret_val;
-    uint16_t phy_data, speed, duplex, i;
+    uint16_t phy_data, phy_saved_data, speed, duplex, i;
     uint16_t dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                         {IGP01E1000_PHY_AGC_PARAM_A,
                                         IGP01E1000_PHY_AGC_PARAM_B,
@@ -5005,6 +5030,21 @@ e1000_config_dsp_after_link_change(struc
         }
     } else {
         if(hw->dsp_config_state == e1000_dsp_config_activated) {
+            /* Save off the current value of register 0x2F5B to be restored at
+             * the end of the routines. */
+            ret_val = e1000_read_phy_reg(hw, 0x2F5B, &phy_saved_data);
+
+            if(ret_val)
+                return ret_val;
+
+            /* Disable the PHY transmitter */
+            ret_val = e1000_write_phy_reg(hw, 0x2F5B, 0x0003);
+
+            if(ret_val)
+                return ret_val;
+
+            msec_delay(20);
+
             ret_val = e1000_write_phy_reg(hw, 0x0000,
                                           IGP01E1000_IEEE_FORCE_GIGA);
             if(ret_val)
@@ -5027,10 +5067,33 @@ e1000_config_dsp_after_link_change(struc
             if(ret_val)
                 return ret_val;
 
+            msec_delay(20);
+
+            /* Now enable the transmitter */
+            ret_val = e1000_write_phy_reg(hw, 0x2F5B, phy_saved_data);
+
+            if(ret_val)
+                return ret_val;
+
             hw->dsp_config_state = e1000_dsp_config_enabled;
         }
 
         if(hw->ffe_config_state == e1000_ffe_config_active) {
+            /* Save off the current value of register 0x2F5B to be restored at
+             * the end of the routines. */
+            ret_val = e1000_read_phy_reg(hw, 0x2F5B, &phy_saved_data);
+
+            if(ret_val)
+                return ret_val;
+
+            /* Disable the PHY transmitter */
+            ret_val = e1000_write_phy_reg(hw, 0x2F5B, 0x0003);
+
+            if(ret_val)
+                return ret_val;
+
+            msec_delay(20);
+
             ret_val = e1000_write_phy_reg(hw, 0x0000,
                                           IGP01E1000_IEEE_FORCE_GIGA);
             if(ret_val)
@@ -5044,6 +5107,15 @@ e1000_config_dsp_after_link_change(struc
                                           IGP01E1000_IEEE_RESTART_AUTONEG);
             if(ret_val)
                 return ret_val;
+
+            msec_delay(20);
+
+            /* Now enable the transmitter */
+            ret_val = e1000_write_phy_reg(hw, 0x2F5B, phy_saved_data);
+
+            if(ret_val)
+                return ret_val;
+
             hw->ffe_config_state = e1000_ffe_config_enabled;
         }
     }
