From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 4/11] read correct bit from EEPROM for getting WoL settings
Date: Mon, 8 Sep 2003 20:14:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081851400.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Bug fix: read the correct bit from the EEPROM that controls the
  initial setting for WoL after a reset.

---------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000.h linux-2.6.0-test4/drivers/net/e1000.new/e1000.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000.h	2003-08-22 16:50:56.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000.h	2003-09-08 09:13:16.000000000 -0700
@@ -122,7 +122,7 @@ struct e1000_adapter;
 #define E1000_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
 #define AUTO_ALL_MODES       0
-#define E1000_EEPROM_APME    4
+#define E1000_EEPROM_APME    0x0400
 
 /* only works for sizes that are powers of 2 */
 #define E1000_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -494,12 +494,28 @@ e1000_probe(struct pci_dev *pdev,
 	 * enable the ACPI Magic Packet filter
 	 */
 
-	e1000_read_eeprom(&adapter->hw, EEPROM_INIT_CONTROL2_REG,1, &eeprom_data);
-	if((adapter->hw.mac_type >= e1000_82544) &&
-	   (eeprom_data & E1000_EEPROM_APME))
+	switch(adapter->hw.mac_type) {
+	case e1000_82542_rev2_0:
+	case e1000_82542_rev2_1:
+	case e1000_82543:
+		break;
+	case e1000_82546:
+	case e1000_82546_rev_3:
+		if((E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1)
+		   && (adapter->hw.media_type == e1000_media_type_copper)) {
+			e1000_read_eeprom(&adapter->hw,
+				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
+			break;
+		}
+		/* Fall Through */
+	default:
+		e1000_read_eeprom(&adapter->hw,
+			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
+		break;
+	}
+	if(eeprom_data & E1000_EEPROM_APME)
 		adapter->wol |= E1000_WUFC_MAG;
 
-
 	/* reset the hardware with the new settings */
 
 	e1000_reset(adapter);
