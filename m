From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 8/11] move static to table from .h to .c
Date: Mon, 8 Sep 2003 20:14:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081948480.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Move static table from hw.h to hw.c to avoid creating a copy
  of table everytime hw.h is included.in .c.

----------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c	2003-08-22 17:01:40.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c	2003-09-08 09:13:11.000000000 -0700
@@ -64,6 +64,17 @@ static int32_t e1000_write_eeprom_microw
 static int32_t e1000_id_led_init(struct e1000_hw * hw);
 static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
 
+/* IGP cable length table */
+static const
+uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
+    { 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
+      5, 10, 10, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 25, 25, 25,
+      25, 25, 25, 25, 30, 30, 30, 30, 40, 40, 40, 40, 40, 40, 40, 40,
+      40, 50, 50, 50, 50, 50, 50, 50, 60, 60, 60, 60, 60, 60, 60, 60,
+      60, 70, 70, 70, 70, 70, 70, 80, 80, 80, 80, 80, 80, 90, 90, 90,
+      90, 90, 90, 90, 90, 90, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
+      100, 100, 100, 100, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110,
+      110, 110, 110, 110, 110, 110, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120};
 
 
 /******************************************************************************
@@ -4601,19 +4601,16 @@ e1000_get_cable_length(struct e1000_hw *
             break;
         }
     } else if(hw->phy_type == e1000_phy_igp) { /* For IGP PHY */
-        uint16_t agc_reg_array[IGP01E1000_PHY_AGC_NUM] = {IGP01E1000_PHY_AGC_A,
+        uint16_t agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
+                                                         {IGP01E1000_PHY_AGC_A,
                                                           IGP01E1000_PHY_AGC_B,
                                                           IGP01E1000_PHY_AGC_C,
                                                           IGP01E1000_PHY_AGC_D};
         /* Read the AGC registers for all channels */
-        for(i = 0; i < IGP01E1000_PHY_AGC_NUM; i++) {
-            if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                   agc_reg_array[i]) != E1000_SUCCESS)
-                return -E1000_ERR_PHY;
-            if(e1000_read_phy_reg(hw, agc_reg_array[i] &
-                                  IGP01E1000_PHY_PAGE_SELECT, &phy_data) !=
-                                  E1000_SUCCESS)
-                return -E1000_ERR_PHY;
+        for(i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
+
+            if((ret_val = e1000_read_phy_reg(hw, agc_reg_array[i], &phy_data)))
+                return ret_val;
 
             cur_agc = phy_data >> IGP01E1000_AGC_LENGTH_SHIFT;
 
@@ -4629,20 +4637,15 @@ e1000_get_cable_length(struct e1000_hw *
                 min_agc = cur_agc;
         }
 
-        /* Return to page 0 */
-        if(e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 0x0) !=
-           E1000_SUCCESS)
-            return -E1000_ERR_PHY;
-
         /* Remove the minimal AGC result for length < 50m */
-        if(agc_value < IGP01E1000_PHY_AGC_NUM * e1000_igp_cable_length_50) {
+        if(agc_value < IGP01E1000_PHY_CHANNEL_NUM * e1000_igp_cable_length_50) {
             agc_value -= min_agc;
 
             /* Get the average length of the remaining 3 channels */
-            agc_value /= (IGP01E1000_PHY_AGC_NUM - 1);
+            agc_value /= (IGP01E1000_PHY_CHANNEL_NUM - 1);
         } else {
             /* Get the average length of all the 4 channels. */
-            agc_value /= IGP01E1000_PHY_AGC_NUM;
+            agc_value /= IGP01E1000_PHY_CHANNEL_NUM;
         }
 
         /* Set the range of the calculated length. */
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h	2003-08-22 16:58:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h	2003-09-08 09:13:16.000000000 -0700
@@ -2053,18 +2053,6 @@ struct e1000_hw {
 /* The precision of the length is +/- 10 meters */
 #define IGP01E1000_AGC_RANGE    10
 
-/* IGP cable length table */
-static const
-uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
-    { 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
-      5, 10, 10, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 25, 25, 25,
-      25, 25, 25, 25, 30, 30, 30, 30, 40, 40, 40, 40, 40, 40, 40, 40,
-      40, 50, 50, 50, 50, 50, 50, 50, 60, 60, 60, 60, 60, 60, 60, 60,
-      60, 70, 70, 70, 70, 70, 70, 80, 80, 80, 80, 80, 80, 90, 90, 90,
-      90, 90, 90, 90, 90, 90, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
-      100, 100, 100, 100, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110,
-      110, 110, 110, 110, 110, 110, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120};
-
 /* IGP01E1000 PCS Initialization register */
 /* bits 3:6 in the PCS registers stores the channels polarity */
 #define IGP01E1000_PHY_POLARITY_MASK    0x0078
