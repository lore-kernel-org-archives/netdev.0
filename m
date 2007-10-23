From: Bill Hayes <bill.hayes@hp.com>
Subject: [PATCH] e1000: alternate MAC address support
Date: Tue, 23 Oct 2007 13:14:39 -0600
Message-ID: <1193166879.14801.73.camel@dual.billh>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:32815 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbXJWTTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 15:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Port alternate MAC address support from the sourceforge 
e1000 driver to the upstream e1000 driver.

Signed-off-by: Bill Hayes <bill.hayes@hp.com>
---

 drivers/net/e1000/e1000_hw.c |   42 +++++++++++++++++++++++++++++++++++++++---
 drivers/net/e1000/e1000_hw.h |    2 ++
 2 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 8fa0fe4..07e3178 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -719,6 +719,11 @@ e1000_reset_hw(struct e1000_hw *hw)
     DEBUGOUT("Masking off all interrupts\n");
     E1000_WRITE_REG(hw, IMC, 0xffffffff);
 
+    if (hw->mac_type == e1000_82571 && hw->alt_mac_addr_is_present) {
+    	hw->laa_is_present = 1;
+    	e1000_rar_set(hw, hw->mac_addr, E1000_RAR_ENTRIES - 1);
+    }
+
     /* Clear any pending interrupt events. */
     icr = E1000_READ_REG(hw, ICR);
 
@@ -5693,11 +5698,41 @@ e1000_read_mac_addr(struct e1000_hw * hw)
 {
     uint16_t offset;
     uint16_t eeprom_data, i;
+    u16 mac_addr_offset = 0;
 
     DEBUGFUNC("e1000_read_mac_addr");
 
+    if (hw->mac_type == e1000_82571) {
+        /* Check for an alternate MAC address.  An alternate MAC address can
+         * be setup by pre-boot software and must be treated like a permanent
+         * address and must override the actual permanent MAC address. */
+        if (e1000_read_eeprom(hw, EEPROM_ALT_MAC_ADDR_PTR, 1,
+                              &mac_addr_offset) < 0) {
+            DEBUGOUT("EEPROM Read Error\n");
+            return -E1000_ERR_EEPROM;
+        }
+        if (mac_addr_offset == 0xFFFF)
+            mac_addr_offset = 0;
+
+        if (mac_addr_offset) {
+            if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)
+                mac_addr_offset += NODE_ADDRESS_SIZE/sizeof(u16);
+
+            /* make sure we have a valid mac address here before using it */
+            if (e1000_read_eeprom(hw, mac_addr_offset, 1, &eeprom_data) < 0) {
+                DEBUGOUT("EEPROM Read Error\n");
+                return -E1000_ERR_EEPROM;
+            }
+            if (eeprom_data & 0x0001)
+                mac_addr_offset = 0;
+	}
+
+        if (mac_addr_offset) 
+                hw->alt_mac_addr_is_present = 1;
+    }
+
     for (i = 0; i < NODE_ADDRESS_SIZE; i += 2) {
-        offset = i >> 1;
+        offset = mac_addr_offset + (i >> 1);
         if (e1000_read_eeprom(hw, offset, 1, &eeprom_data) < 0) {
             DEBUGOUT("EEPROM Read Error\n");
             return -E1000_ERR_EEPROM;
@@ -5713,8 +5748,9 @@ e1000_read_mac_addr(struct e1000_hw * hw)
     case e1000_82546_rev_3:
     case e1000_82571:
     case e1000_80003es2lan:
-        if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)
-            hw->perm_mac_addr[5] ^= 0x01;
+        if (!mac_addr_offset &&
+            (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1))
+                hw->perm_mac_addr[5] ^= 0x01;
         break;
     }
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a2a86c5..e18760d 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1456,6 +1456,7 @@ struct e1000_hw {
 	boolean_t		tbi_compatibility_en;
 	boolean_t		tbi_compatibility_on;
 	boolean_t		laa_is_present;
+	boolean_t		alt_mac_addr_is_present;
 	boolean_t		phy_reset_disable;
 	boolean_t		initialize_hw_bits_disable;
 	boolean_t		fc_send_xon;
@@ -2286,6 +2287,7 @@ struct e1000_host_command_info {
 #define EEPROM_INIT_CONTROL3_PORT_A   0x0024
 #define EEPROM_CFG                    0x0012
 #define EEPROM_FLASH_VERSION          0x0032
+#define EEPROM_ALT_MAC_ADDR_PTR       0x0037
 #define EEPROM_CHECKSUM_REG           0x003F
 
 #define E1000_EEPROM_CFG_DONE         0x00040000   /* MNG config cycle done */

