From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 2/4] force 1000/full on SERDES connected to back-plane
 switch
Date: Thu, 25 Sep 2003 22:49:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309252247010.6939-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Bug fix: SERDES devices might be connected to back-plan switch that
  doesn't support auto-neg, so add the capability to force 1000/full.

-------------

diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_hw.c net-drivers-2.5/drivers/net/e1000.mod/e1000_hw.c
--- net-drivers-2.5/drivers/net/e1000/e1000_hw.c	2003-09-24 21:20:30.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_hw.c	2003-09-24 21:23:48.000000000 -0700
@@ -836,18 +836,16 @@ e1000_setup_fiber_serdes_link(struct e10
         if(i == (LINK_UP_TIMEOUT / 10)) {
             DEBUGOUT("Never got a valid link from auto-neg!!!\n");
             hw->autoneg_failed = 1;
-            if(hw->media_type == e1000_media_type_fiber) {
-                /* AutoNeg failed to achieve a link, so we'll call
-                 * e1000_check_for_link. This routine will force the link up if
-                 * we detect a signal. This will allow us to communicate with
-                 * non-autonegotiating link partners.
-                 */
-                if((ret_val = e1000_check_for_link(hw))) {
-                    DEBUGOUT("Error while checking for link\n");
-                    return ret_val;
-                }
-                hw->autoneg_failed = 0;
+            /* AutoNeg failed to achieve a link, so we'll call
+             * e1000_check_for_link. This routine will force the link up if
+             * we detect a signal. This will allow us to communicate with
+             * non-autonegotiating link partners.
+             */
+            if((ret_val = e1000_check_for_link(hw))) {
+                DEBUGOUT("Error while checking for link\n");
+                return ret_val;
             }
+            hw->autoneg_failed = 0;
         } else {
             hw->autoneg_failed = 0;
             DEBUGOUT("Valid Link Found\n");
@@ -1456,10 +1454,10 @@ e1000_phy_force_speed_duplex(struct e100
     }
 
     /* Write back the modified PHY MII control register. */
-    udelay(1);
     if((ret_val = e1000_write_phy_reg(hw, PHY_CTRL, mii_ctrl_reg)))
         return ret_val;
 
+    usec_delay(1);
 
     /* The wait_autoneg_complete flag may be a little misleading here.
      * Since we are forcing speed and duplex, Auto-Neg is not enabled.
@@ -2046,9 +2044,10 @@ e1000_check_for_link(struct e1000_hw *hw
      * auto-negotiation time to complete, in case the cable was just plugged
      * in. The autoneg_failed flag does this.
      */
-    else if((hw->media_type == e1000_media_type_fiber) &&
+    else if((((hw->media_type == e1000_media_type_fiber) &&
+            ((ctrl & E1000_CTRL_SWDPIN1) == signal)) ||
+            (hw->media_type == e1000_media_type_internal_serdes)) &&
             (!(status & E1000_STATUS_LU)) &&
-            ((ctrl & E1000_CTRL_SWDPIN1) == signal) &&
             (!(rxcw & E1000_RXCW_C))) {
         if(hw->autoneg_failed == 0) {
             hw->autoneg_failed = 1;
@@ -2075,7 +2074,8 @@ e1000_check_for_link(struct e1000_hw *hw
      * Device Control register in an attempt to auto-negotiate with our link
      * partner.
      */
-    else if((hw->media_type == e1000_media_type_fiber) &&
+    else if(((hw->media_type == e1000_media_type_fiber) ||
+             (hw->media_type == e1000_media_type_internal_serdes)) &&
               (ctrl & E1000_CTRL_SLU) &&
               (rxcw & E1000_RXCW_C)) {
         DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\r\n");
