From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/23] e1000: add enums for several link properties
Date: Tue, 19 Sep 2006 10:28:45 -0700
Message-ID: <20060919172845.4605.34567.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:15117 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030341AbWISRTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:50 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |   89 +++++++++++++++++++++++++-----------------
 1 files changed, 53 insertions(+), 36 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index bfc03ff..34226c4 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -71,7 +71,7 @@ static int32_t e1000_host_if_read_cookie
 static uint8_t e1000_calculate_mng_checksum(char *buffer, uint32_t length);
 static uint8_t e1000_arc_subsystem_valid(struct e1000_hw *hw);
 static int32_t e1000_check_downshift(struct e1000_hw *hw);
-static int32_t e1000_check_polarity(struct e1000_hw *hw, uint16_t *polarity);
+static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
 static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
@@ -4060,7 +4060,8 @@ e1000_phy_igp_get_info(struct e1000_hw *
                        struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data, polarity, min_length, max_length, average;
+    uint16_t phy_data, min_length, max_length, average;
+    e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_igp_get_info");
 
@@ -4085,8 +4086,8 @@ e1000_phy_igp_get_info(struct e1000_hw *
     if (ret_val)
         return ret_val;
 
-    phy_info->mdix_mode = (phy_data & IGP01E1000_PSSR_MDIX) >>
-                          IGP01E1000_PSSR_MDIX_SHIFT;
+    phy_info->mdix_mode = (e1000_auto_x_mode)((phy_data & IGP01E1000_PSSR_MDIX) >>
+                          IGP01E1000_PSSR_MDIX_SHIFT);
 
     if ((phy_data & IGP01E1000_PSSR_SPEED_MASK) ==
        IGP01E1000_PSSR_SPEED_1000MBPS) {
@@ -4095,10 +4096,12 @@ e1000_phy_igp_get_info(struct e1000_hw *
         if (ret_val)
             return ret_val;
 
-        phy_info->local_rx = (phy_data & SR_1000T_LOCAL_RX_STATUS) >>
-                             SR_1000T_LOCAL_RX_STATUS_SHIFT;
-        phy_info->remote_rx = (phy_data & SR_1000T_REMOTE_RX_STATUS) >>
-                              SR_1000T_REMOTE_RX_STATUS_SHIFT;
+        phy_info->local_rx = ((phy_data & SR_1000T_LOCAL_RX_STATUS) >>
+                             SR_1000T_LOCAL_RX_STATUS_SHIFT) ?
+                             e1000_1000t_rx_status_ok : e1000_1000t_rx_status_not_ok;
+        phy_info->remote_rx = ((phy_data & SR_1000T_REMOTE_RX_STATUS) >>
+                              SR_1000T_REMOTE_RX_STATUS_SHIFT) ?
+                              e1000_1000t_rx_status_ok : e1000_1000t_rx_status_not_ok;
 
         /* Get cable length */
         ret_val = e1000_get_cable_length(hw, &min_length, &max_length);
@@ -4134,7 +4137,8 @@ e1000_phy_ife_get_info(struct e1000_hw *
                        struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data, polarity;
+    uint16_t phy_data;
+    e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_ife_get_info");
 
@@ -4145,8 +4149,9 @@ e1000_phy_ife_get_info(struct e1000_hw *
     if (ret_val)
         return ret_val;
     phy_info->polarity_correction =
-                        (phy_data & IFE_PSC_AUTO_POLARITY_DISABLE) >>
-                        IFE_PSC_AUTO_POLARITY_DISABLE_SHIFT;
+                        ((phy_data & IFE_PSC_AUTO_POLARITY_DISABLE) >>
+                        IFE_PSC_AUTO_POLARITY_DISABLE_SHIFT) ?
+                        e1000_polarity_reversal_disabled : e1000_polarity_reversal_enabled;
 
     if (phy_info->polarity_correction == e1000_polarity_reversal_enabled) {
         ret_val = e1000_check_polarity(hw, &polarity);
@@ -4154,8 +4159,9 @@ e1000_phy_ife_get_info(struct e1000_hw *
             return ret_val;
     } else {
         /* Polarity is forced. */
-        polarity = (phy_data & IFE_PSC_FORCE_POLARITY) >>
-                       IFE_PSC_FORCE_POLARITY_SHIFT;
+        polarity = ((phy_data & IFE_PSC_FORCE_POLARITY) >>
+                     IFE_PSC_FORCE_POLARITY_SHIFT) ?
+                     e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
     }
     phy_info->cable_polarity = polarity;
 
@@ -4163,9 +4169,9 @@ e1000_phy_ife_get_info(struct e1000_hw *
     if (ret_val)
         return ret_val;
 
-    phy_info->mdix_mode =
-                     (phy_data & (IFE_PMC_AUTO_MDIX | IFE_PMC_FORCE_MDIX)) >>
-                     IFE_PMC_MDIX_MODE_SHIFT;
+    phy_info->mdix_mode = (e1000_auto_x_mode)
+                     ((phy_data & (IFE_PMC_AUTO_MDIX | IFE_PMC_FORCE_MDIX)) >>
+                     IFE_PMC_MDIX_MODE_SHIFT);
 
     return E1000_SUCCESS;
 }
@@ -4181,7 +4187,8 @@ e1000_phy_m88_get_info(struct e1000_hw *
                        struct e1000_phy_info *phy_info)
 {
     int32_t ret_val;
-    uint16_t phy_data, polarity;
+    uint16_t phy_data;
+    e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_m88_get_info");
 
@@ -4194,11 +4201,14 @@ e1000_phy_m88_get_info(struct e1000_hw *
         return ret_val;
 
     phy_info->extended_10bt_distance =
-        (phy_data & M88E1000_PSCR_10BT_EXT_DIST_ENABLE) >>
-        M88E1000_PSCR_10BT_EXT_DIST_ENABLE_SHIFT;
+        ((phy_data & M88E1000_PSCR_10BT_EXT_DIST_ENABLE) >>
+        M88E1000_PSCR_10BT_EXT_DIST_ENABLE_SHIFT) ?
+        e1000_10bt_ext_dist_enable_lower : e1000_10bt_ext_dist_enable_normal;
+
     phy_info->polarity_correction =
-        (phy_data & M88E1000_PSCR_POLARITY_REVERSAL) >>
-        M88E1000_PSCR_POLARITY_REVERSAL_SHIFT;
+        ((phy_data & M88E1000_PSCR_POLARITY_REVERSAL) >>
+        M88E1000_PSCR_POLARITY_REVERSAL_SHIFT) ?
+        e1000_polarity_reversal_disabled : e1000_polarity_reversal_enabled;
 
     /* Check polarity status */
     ret_val = e1000_check_polarity(hw, &polarity);
@@ -4210,15 +4220,15 @@ e1000_phy_m88_get_info(struct e1000_hw *
     if (ret_val)
         return ret_val;
 
-    phy_info->mdix_mode = (phy_data & M88E1000_PSSR_MDIX) >>
-                          M88E1000_PSSR_MDIX_SHIFT;
+    phy_info->mdix_mode = (e1000_auto_x_mode)((phy_data & M88E1000_PSSR_MDIX) >>
+                          M88E1000_PSSR_MDIX_SHIFT);
 
     if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
         /* Cable Length Estimation and Local/Remote Receiver Information
          * are only valid at 1000 Mbps.
          */
         if (hw->phy_type != e1000_phy_gg82563) {
-            phy_info->cable_length = ((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
+            phy_info->cable_length = (e1000_cable_length)((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
                                       M88E1000_PSSR_CABLE_LENGTH_SHIFT);
         } else {
             ret_val = e1000_read_phy_reg(hw, GG82563_PHY_DSP_DISTANCE,
@@ -4226,18 +4236,20 @@ e1000_phy_m88_get_info(struct e1000_hw *
             if (ret_val)
                 return ret_val;
 
-            phy_info->cable_length = phy_data & GG82563_DSPD_CABLE_LENGTH;
+            phy_info->cable_length = (e1000_cable_length)(phy_data & GG82563_DSPD_CABLE_LENGTH);
         }
 
         ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
         if (ret_val)
             return ret_val;
 
-        phy_info->local_rx = (phy_data & SR_1000T_LOCAL_RX_STATUS) >>
-                             SR_1000T_LOCAL_RX_STATUS_SHIFT;
+        phy_info->local_rx = ((phy_data & SR_1000T_LOCAL_RX_STATUS) >>
+                             SR_1000T_LOCAL_RX_STATUS_SHIFT) ?
+                             e1000_1000t_rx_status_ok : e1000_1000t_rx_status_not_ok;
+        phy_info->remote_rx = ((phy_data & SR_1000T_REMOTE_RX_STATUS) >>
+                              SR_1000T_REMOTE_RX_STATUS_SHIFT) ?
+                              e1000_1000t_rx_status_ok : e1000_1000t_rx_status_not_ok;
 
-        phy_info->remote_rx = (phy_data & SR_1000T_REMOTE_RX_STATUS) >>
-                              SR_1000T_REMOTE_RX_STATUS_SHIFT;
     }
 
     return E1000_SUCCESS;
@@ -6841,7 +6853,7 @@ e1000_get_cable_length(struct e1000_hw *
  *****************************************************************************/
 static int32_t
 e1000_check_polarity(struct e1000_hw *hw,
-                     uint16_t *polarity)
+                     e1000_rev_polarity *polarity)
 {
     int32_t ret_val;
     uint16_t phy_data;
@@ -6855,8 +6867,10 @@ e1000_check_polarity(struct e1000_hw *hw
                                      &phy_data);
         if (ret_val)
             return ret_val;
-        *polarity = (phy_data & M88E1000_PSSR_REV_POLARITY) >>
-                    M88E1000_PSSR_REV_POLARITY_SHIFT;
+        *polarity = ((phy_data & M88E1000_PSSR_REV_POLARITY) >>
+                     M88E1000_PSSR_REV_POLARITY_SHIFT) ?
+                     e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
+
     } else if (hw->phy_type == e1000_phy_igp ||
               hw->phy_type == e1000_phy_igp_3 ||
               hw->phy_type == e1000_phy_igp_2) {
@@ -6878,19 +6892,22 @@ e1000_check_polarity(struct e1000_hw *hw
                 return ret_val;
 
             /* Check the polarity bits */
-            *polarity = (phy_data & IGP01E1000_PHY_POLARITY_MASK) ? 1 : 0;
+            *polarity = (phy_data & IGP01E1000_PHY_POLARITY_MASK) ?
+                         e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
         } else {
             /* For 10 Mbps, read the polarity bit in the status register. (for
              * 100 Mbps this bit is always 0) */
-            *polarity = phy_data & IGP01E1000_PSSR_POLARITY_REVERSED;
+            *polarity = (phy_data & IGP01E1000_PSSR_POLARITY_REVERSED) ?
+                         e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
         }
     } else if (hw->phy_type == e1000_phy_ife) {
         ret_val = e1000_read_phy_reg(hw, IFE_PHY_EXTENDED_STATUS_CONTROL,
                                      &phy_data);
         if (ret_val)
             return ret_val;
-        *polarity = (phy_data & IFE_PESC_POLARITY_REVERSED) >>
-                           IFE_PESC_POLARITY_REVERSED_SHIFT;
+        *polarity = ((phy_data & IFE_PESC_POLARITY_REVERSED) >>
+                     IFE_PESC_POLARITY_REVERSED_SHIFT) ?
+                     e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
     }
     return E1000_SUCCESS;
 }



---
Auke Kok <auke-jan.h.kok@intel.com>
