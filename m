From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6-exp 1/2] h/w workarounds + remove device ID.
Date: Mon, 22 Dec 2003 17:02:47 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312221701190.20044-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Remove device ID 8086:1014 support: never a production ID.
* Add #define for stripping CRC on Rx.
* Added polarity reversal workaround for forced 10Mbps on 82543/4
  controllers.  The polirity detection algorithm check the link
  pulse to see if the polarity is reversed.  The end of packet
  waveform of 10Base-T packets look like an inverted link pulse
  and can make 82443/4 polarity detection algorithms think that
  the polarity is reversed by mistake.
* Change the condition for applying the TBI workaround on 82543:
  previously enabled workaround if link partner advertised
  capabilities; now enable based on negotiated speed - only
  enable for gig speed.

diff -Naurp net-drivers-2.5-exp/drivers/net/e1000/e1000_hw.c net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_hw.c
--- net-drivers-2.5-exp/drivers/net/e1000/e1000_hw.c	2003-12-16 17:18:18.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_hw.c	2003-12-16 17:19:02.000000000 -0800
@@ -96,8 +96,14 @@ e1000_set_phy_type(struct e1000_hw *hw)
         hw->phy_type = e1000_phy_m88;
         break;
     case IGP01E1000_I_PHY_ID:
-        hw->phy_type = e1000_phy_igp;
-        break;
+        if(hw->mac_type == e1000_82541 ||
+           hw->mac_type == e1000_82541_rev_2 ||
+           hw->mac_type == e1000_82547 ||
+           hw->mac_type == e1000_82547_rev_2) {
+            hw->phy_type = e1000_phy_igp;
+            break;
+        }
+        /* Fall Through */
     default:
         /* Should never have loaded on this device */
         hw->phy_type = e1000_phy_undefined;
@@ -148,7 +154,6 @@ e1000_phy_init_script(struct e1000_hw *h
 
         e1000_write_phy_reg(hw, 0x0000, 0x3300);
 
-
         if(hw->mac_type == e1000_82547) {
             uint16_t fused, fine, coarse;
 
@@ -1533,6 +1538,25 @@ e1000_phy_force_speed_duplex(struct e100
                                           phy_data)))
             return ret_val;
 
+        /* Polarity reversal workaround for forced 10F/10H links. */
+        if(hw->mac_type <= e1000_82544 &&
+           (hw->forced_speed_duplex == e1000_10_full ||
+            hw->forced_speed_duplex == e1000_10_half)) {
+            if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT,
+                                              0x0019)))
+                return ret_val;
+            if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL,
+                                              0x8F0F)))
+                return ret_val;
+            /* IEEE requirement is 150ms */
+            msec_delay(200);
+            if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_PAGE_SELECT,
+                                              0x0019)))
+                return ret_val;
+            if((ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_GEN_CONTROL,
+                                              0x8F00)))
+                return ret_val;
+        }
     }
     return E1000_SUCCESS;
 }
@@ -1916,7 +1940,6 @@ e1000_check_for_link(struct e1000_hw *hw
     uint32_t signal = 0;
     int32_t ret_val;
     uint16_t phy_data;
-    uint16_t lp_capability;
 
     DEBUGFUNC("e1000_check_for_link");
 
@@ -1996,24 +2019,17 @@ e1000_check_for_link(struct e1000_hw *hw
 
         /* At this point we know that we are on copper and we have
          * auto-negotiated link.  These are conditions for checking the link
-         * parter capability register.  We use the link partner capability to
-         * determine if TBI Compatibility needs to be turned on or off.  If
-         * the link partner advertises any speed in addition to Gigabit, then
-         * we assume that they are GMII-based, and TBI compatibility is not
-         * needed. If no other speeds are advertised, we assume the link
-         * partner is TBI-based, and we turn on TBI Compatibility.
-         */
-        if(hw->tbi_compatibility_en) {
-            if((ret_val = e1000_read_phy_reg(hw, PHY_LP_ABILITY,
-                                             &lp_capability)))
-                return ret_val;
-            if(lp_capability & (NWAY_LPAR_10T_HD_CAPS |
-                                NWAY_LPAR_10T_FD_CAPS |
-                                NWAY_LPAR_100TX_HD_CAPS |
-                                NWAY_LPAR_100TX_FD_CAPS |
-                                NWAY_LPAR_100T4_CAPS)) {
-                /* If our link partner advertises anything in addition to
-                 * gigabit, we do not need to enable TBI compatibility.
+         * partner capability register.  We use the link speed to determine if
+         * TBI compatibility needs to be turned on or off.  If the link is not
+         * at gigabit speed, then TBI compatibility is not needed.  If we are
+         * at gigabit speed, we turn on TBI compatibility.
+         */
+	if(hw->tbi_compatibility_en) {
+            uint16_t speed, duplex;
+            e1000_get_speed_and_duplex(hw, &speed, &duplex);
+            if(speed != SPEED_1000) {
+                /* If link speed is not set to gigabit speed, we do not need
+                 * to enable TBI compatibility.
                  */
                 if(hw->tbi_compatibility_on) {
                     /* If we previously were in the mode, turn it off. */
@@ -2101,6 +2117,10 @@ e1000_check_for_link(struct e1000_hw *hw
             DEBUGOUT("SERDES: Link is down.\n");
         }
     }
+    if((hw->media_type == e1000_media_type_internal_serdes) &&
+       (E1000_TXCW_ANE & E1000_READ_REG(hw, TXCW))) {
+        hw->serdes_link_down = !(E1000_STATUS_LU & E1000_READ_REG(hw, STATUS));
+    }
     return E1000_SUCCESS;
 }
 
@@ -3784,6 +3804,7 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
  * mc_addr_list - the list of new multicast addresses
  * mc_addr_count - number of addresses
  * pad - number of bytes between addresses in the list
+ * rar_used_count - offset where to start adding mc addresses into the RAR's
  *
  * The given list replaces any existing list. Clears the last 15 receive
  * address registers and the multicast table. Uses receive address registers
@@ -3795,7 +3816,7 @@ e1000_mc_addr_list_update(struct e1000_h
                           uint8_t *mc_addr_list,
                           uint32_t mc_addr_count,
                           uint32_t pad,
-			  uint32_t rar_used_count)
+                          uint32_t rar_used_count)
 {
     uint32_t hash_value;
     uint32_t i;
diff -Naurp net-drivers-2.5-exp/drivers/net/e1000/e1000_hw.h net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_hw.h
--- net-drivers-2.5-exp/drivers/net/e1000/e1000_hw.h	2003-12-16 17:18:18.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_hw.h	2003-12-16 17:19:09.000000000 -0800
@@ -1311,6 +1311,7 @@ struct e1000_hw {
 #define E1000_RCTL_DPF            0x00400000    /* discard pause frames */
 #define E1000_RCTL_PMCF           0x00800000    /* pass MAC control frames */
 #define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
+#define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
 
 /* Receive Descriptor */
 #define E1000_RDT_DELAY 0x0000ffff      /* Delay timer (1=1024us) */
diff -Naurp net-drivers-2.5-exp/drivers/net/e1000/e1000_main.c net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_main.c
--- net-drivers-2.5-exp/drivers/net/e1000/e1000_main.c	2003-12-16 17:18:18.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_main.c	2003-12-16 17:19:14.000000000 -0800
@@ -87,7 +87,6 @@ static struct pci_device_id e1000_pci_tb
 	{0x8086, 0x1011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1012, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1013, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1015, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1016, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x8086, 0x1017, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
