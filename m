From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 4/5] ixgb: Invalidate software cache, when
 writing EEPROM.
Date: Tue, 15 Feb 2005 13:38:40 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151202070.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

4 Added code to invalidate software cache, when a write is made to the EEPROM.
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ee.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ee.c	2005-02-06 23:33:00.650031648 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.c	2005-02-06 23:33:01.466907464 -0800
@@ -372,11 +372,11 @@ ixgb_update_eeprom_checksum(struct ixgb_
  *
  *****************************************************************************/
 void
-ixgb_write_eeprom(struct ixgb_hw *hw,
-		   uint16_t offset,
-		   uint16_t data)
+ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t offset, uint16_t data)
 {
-	/*  Prepare the EEPROM for writing  */
+	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
+
+	/* Prepare the EEPROM for writing */
 	ixgb_setup_eeprom(hw);
 
 	/*  Send the 9-bit EWEN (write enable) command to the EEPROM (5-bit opcode
@@ -410,6 +410,9 @@ 
 	/*  Done with writing  */
 	ixgb_cleanup_eeprom(hw);
 
+	/* clear the init_ctrl_reg_1 to signify that the cache is invalidated */
+	ee_map->init_ctrl_reg_1 = EEPROM_ICW1_SIGNATURE_CLEAR;
+
 	return;
 }
 
@@ -478,6 +458,9 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 
 	if (checksum != (uint16_t) EEPROM_SUM) {
 		DEBUGOUT("ixgb_ee: Checksum invalid.\n");
+		/* clear the init_ctrl_reg_1 to signify that the cache is
+		 * invalidated */
+		ee_map->init_ctrl_reg_1 = EEPROM_ICW1_SIGNATURE_CLEAR;
 		return (FALSE);
 	}
 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ee.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ee.h	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.h	2005-02-06 23:33:01.482905032 -0800
@@ -63,6 +63,7 @@
 
 #define EEPROM_ICW1_SIGNATURE_MASK  0xC000
 #define EEPROM_ICW1_SIGNATURE_VALID 0x4000
+#define EEPROM_ICW1_SIGNATURE_CLEAR 0x0000
 
 /* For checksumming, the sum of all words in the EEPROM should equal 0xBABA. */
 #define EEPROM_SUM 0xBABA
	
