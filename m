From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.11-rc2 1/2] wireless: Clean up firmware loading in
	Atmel driver
Date: Wed, 02 Feb 2005 10:17:52 -0500
Message-ID: <1107357472.27197.5.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, simon@thekelleys.org.uk
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(resend)

Identify different firmware by enums, not strings, as we need to have
some integral firmware identifier for choosing maximum rssi values for
each different firmware type.  Consolidate the information about
firmware filenames and capabilities in the atmel module, not in atmel_cs
or atmel_pci.  Move common prototypes and firmware enum into new atmel.h
file.  The atmel_cs driver also thought that init_atmel_card() took "int
irq" as the first parameter, this is now fixed to be "unsigned short
irq".

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- /dev/null	2005-02-01 04:17:36.619366448 -0500
+++ b/drivers/net/wireless/atmel.h	2005-01-30 18:33:31.000000000 -0500
@@ -0,0 +1,43 @@
+/*** -*- linux-c -*- **********************************************************
+
+     Driver for Atmel at76c502 at76c504 and at76c506 wireless cards.
+
+         Copyright 2005 Dan Williams and Red Hat, Inc.
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This software is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with Atmel wireless lan drivers; if not, write to the Free Software
+    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+******************************************************************************/
+
+#ifndef _ATMEL_H
+#define _ATMEL_H
+
+typedef enum {
+	ATMEL_FW_TYPE_NONE = 0,
+	ATMEL_FW_TYPE_502,
+	ATMEL_FW_TYPE_502D,
+	ATMEL_FW_TYPE_502E,
+	ATMEL_FW_TYPE_502_3COM,
+	ATMEL_FW_TYPE_504,
+	ATMEL_FW_TYPE_504_2958,
+	ATMEL_FW_TYPE_504A_2958,
+	ATMEL_FW_TYPE_506
+} AtmelFWType;
+
+struct net_device *init_atmel_card(unsigned short, int, const AtmelFWType, struct device *, 
+				    int (*present_func)(void *), void * );
+void stop_atmel_card( struct net_device *, int );
+int atmel_open( struct net_device * );
+
+#endif
--- a/drivers/net/wireless/atmel.c	2005-02-01 16:15:55.000000000 -0500
+++ b/drivers/net/wireless/atmel.c	2005-02-01 16:22:26.000000000 -0500
@@ -69,6 +69,7 @@
 #include <linux/moduleparam.h>
 #include <linux/firmware.h>
 #include "ieee802_11.h"
+#include "atmel.h"
 
 #define DRIVER_MAJOR 0
 #define DRIVER_MINOR 96
@@ -83,6 +84,23 @@
 static char *firmware = NULL;
 module_param(firmware, charp, 0);
 
+/* table of firmware file names */
+static struct { 
+	AtmelFWType fw_type;
+	const char *fw_file;
+	const char *fw_file_ext;
+} fw_table[] = {
+	{ ATMEL_FW_TYPE_502,      "atmel_at76c502",      "bin" },
+	{ ATMEL_FW_TYPE_502D,     "atmel_at76c502d",     "bin" },
+	{ ATMEL_FW_TYPE_502E,     "atmel_at76c502e",     "bin" },
+	{ ATMEL_FW_TYPE_502_3COM, "atmel_at76c502_3com", "bin" },
+	{ ATMEL_FW_TYPE_504,      "atmel_at76c504",      "bin" },
+	{ ATMEL_FW_TYPE_504_2958, "atmel_at76c504_2958", "bin" },
+	{ ATMEL_FW_TYPE_504A_2958,"atmel_at76c504a_2958","bin" },
+	{ ATMEL_FW_TYPE_506,      "atmel_at76c506",      "bin" },
+	{ ATMEL_FW_TYPE_NONE,      NULL,                  NULL }
+};
+
 #define MAX_SSID_LENGTH 32
 #define MGMT_JIFFIES (256 * HZ / 100)
 
@@ -458,8 +476,8 @@
 	void *card; /* Bus dependent stucture varies for PCcard */
 	int (*present_callback)(void *); /* And callback which uses it */
 	char firmware_id[32];
-	char firmware_template[32];
-	unsigned char *firmware;
+	AtmelFWType firmware_type;
+	u8 *firmware;
 	int firmware_length;
 	struct timer_list management_timer;
 	struct net_device *dev;
@@ -1482,7 +1500,7 @@
         return len;
 }
 
-struct net_device *init_atmel_card( unsigned short irq, int port, char *firmware_id,  
+struct net_device *init_atmel_card( unsigned short irq, int port, const AtmelFWType fw_type,  
 				    struct device *sys_dev, int (*card_present)(void *), void *card)
 {
 	struct net_device *dev;
@@ -1507,11 +1525,9 @@
 	priv->card = card;
 	priv->firmware = NULL;
 	priv->firmware_id[0] = '\0';
-	priv->firmware_template[0] = '\0';
+	priv->firmware_type = fw_type;
 	if (firmware) /* module parameter */
 		strcpy(priv->firmware_id, firmware);
-	else if (firmware_id) /* from PCMCIA card-matching or PCI */
-		strcpy(priv->firmware_template, firmware_id);
 	priv->bus_type = card_present ? BUS_TYPE_PCCARD : BUS_TYPE_PCI;
 	priv->station_state = STATION_STATE_DOWN;
 	priv->do_rx_crc = 0;
@@ -3613,8 +3629,8 @@
 		const struct firmware *fw_entry = NULL;
 		unsigned char *fw;
 		int len = priv->firmware_length;
-		if (!(fw = priv->firmware)) { 
-			if (strlen(priv->firmware_template) == 0) {	
+		if (!(fw = priv->firmware)) {
+			if (priv->firmware_type == ATMEL_FW_TYPE_NONE) {
 				if (strlen(priv->firmware_id) == 0) {
 					printk(KERN_INFO
 					       "%s: card type is unknown: assuming at76c502 firmware is OK.\n",
@@ -3629,24 +3645,36 @@
 					       "%s: firmware %s is missing, cannot continue.\n", 
 					       dev->name, priv->firmware_id);
 					return 0;
-					
-				} 
+				}
 			} else {
-				int i;
+				int fw_index = 0;
+				int success = 0;
+
+				/* get firmware filename entry based on firmware type ID */
+				while (fw_table[fw_index].fw_type != priv->firmware_type
+						&& fw_table[fw_index].fw_type != ATMEL_FW_TYPE_NONE)
+					fw_index++;
 				
-				for (i = 0; firmware_modifier[i]; i++) {
-					sprintf(priv->firmware_id, priv->firmware_template, firmware_modifier[i]);
-					if (request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev) == 0) 
-						break;
+				/* construct the actual firmware file name */
+				if (fw_table[fw_index].fw_type != ATMEL_FW_TYPE_NONE) {
+					int i;
+					for (i = 0; firmware_modifier[i]; i++) {
+						snprintf(priv->firmware_id, 32, "%s%s.%s", fw_table[fw_index].fw_file,
+							firmware_modifier[i], fw_table[fw_index].fw_file_ext);
+						priv->firmware_id[31] = '\0';
+						if (request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev) == 0) {
+							success = 1;
+							break;
+						}
+					}
 				}
-				if (!firmware_modifier[i]) {
+				if (!success) {
 					printk(KERN_ALERT 
 					       "%s: firmware %s is missing, cannot start.\n", 
 					       dev->name, priv->firmware_id);
 					priv->firmware_id[0] = '\0';
 					return 0;	
 				}
-				priv->firmware_template[0] = '\0';	
 			}
 			
 			fw = fw_entry->data;
--- a/drivers/net/wireless/atmel_cs.c	2005-02-01 16:15:24.000000000 -0500
+++ b/drivers/net/wireless/atmel_cs.c	2005-01-30 14:05:08.000000000 -0500
@@ -55,6 +55,7 @@
 #include <asm/system.h>
 #include <linux/wireless.h>
 
+#include "atmel.h"
 
 /*
    All the PCMCIA modules use PCMCIA_DEBUG to control debugging.  If
@@ -90,11 +91,6 @@
    event handler. 
 */
 
-struct net_device *init_atmel_card(int, int, char *, struct device *, 
-				    int (*present_func)(void *), void * );
-void stop_atmel_card( struct net_device *, int );
-int atmel_open( struct net_device * );
-
 static void atmel_config(dev_link_t *link);
 static void atmel_release(dev_link_t *link);
 static int atmel_event(event_t event, int priority,
@@ -307,28 +303,28 @@
 static struct { 
 	int manf, card;
 	char *ver1;
-	char *firmware;
+	AtmelFWType firmware;
 	char *name;
 } card_table[] = {
-	{ 0, 0, "WLAN/802.11b PC CARD", "atmel_at76c502d%s.bin", "Actiontec 802CAT1" },  
-	{ 0, 0, "ATMEL/AT76C502AR", "atmel_at76c502%s.bin", "NoName-RFMD" }, 
-	{ 0, 0, "ATMEL/AT76C502AR_D", "atmel_at76c502d%s.bin", "NoName-revD" }, 
-	{ 0, 0, "ATMEL/AT76C502AR_E", "atmel_at76c502e%s.bin", "NoName-revE" },
-	{ 0, 0, "ATMEL/AT76C504", "atmel_at76c504%s.bin", "NoName-504" },
-	{ 0, 0, "ATMEL/AT76C504A", "atmel_at76c504a_2958%s.bin", "NoName-504a-2958" },
-	{ 0, 0, "ATMEL/AT76C504_R", "atmel_at76c504_2958%s.bin", "NoName-504-2958" },
-	{ MANFID_3COM, 0x0620, NULL, "atmel_at76c502_3com%s.bin", "3com 3CRWE62092B" }, 
-	{ MANFID_3COM, 0x0696, NULL, "atmel_at76c502_3com%s.bin", "3com 3CRSHPW196" }, 
-	{ 0, 0, "SMC/2632W-V2", "atmel_at76c502%s.bin", "SMC 2632W-V2" },
-        { 0, 0, "SMC/2632W", "atmel_at76c502d%s.bin", "SMC 2632W-V3" },
-	{ 0xd601, 0x0007, NULL, "atmel_at76c502%s.bin", "Sitecom WLAN-011" }, 
-	{ 0x01bf, 0x3302, NULL, "atmel_at76c502e%s.bin", "Belkin F5D6020-V2" }, 
-	{ 0, 0, "BT/Voyager 1020 Laptop Adapter", "atmel_at76c502%s.bin", "BT Voyager 1020" },
-        { 0, 0, "IEEE 802.11b/Wireless LAN PC Card", "atmel_at76c502%s.bin", "Siemens Gigaset PC Card II" },
-	{ 0, 0, "CNet/CNWLC 11Mbps Wireless PC Card V-5", "atmel_at76c502e%s.bin", "CNet CNWLC-811ARL" },
-	{ 0, 0, "Wireless/PC_CARD", "atmel_at76c502d%s.bin", "Planet WL-3552" },
-	{ 0, 0, "OEM/11Mbps Wireless LAN PC Card V-3", "atmel_at76c502%s.bin", "OEM 11Mbps WLAN PCMCIA Card" },
-	{ 0, 0, "11WAVE/11WP611AL-E", "atmel_at76c502e%s.bin", "11WAVE WaveBuddy" } 
+	{ 0, 0, "WLAN/802.11b PC CARD", ATMEL_FW_TYPE_502D, "Actiontec 802CAT1" },  
+	{ 0, 0, "ATMEL/AT76C502AR", ATMEL_FW_TYPE_502, "NoName-RFMD" }, 
+	{ 0, 0, "ATMEL/AT76C502AR_D", ATMEL_FW_TYPE_502D, "NoName-revD" }, 
+	{ 0, 0, "ATMEL/AT76C502AR_E", ATMEL_FW_TYPE_502E, "NoName-revE" },
+	{ 0, 0, "ATMEL/AT76C504", ATMEL_FW_TYPE_504, "NoName-504" },
+	{ 0, 0, "ATMEL/AT76C504A", ATMEL_FW_TYPE_504A_2958, "NoName-504a-2958" },
+	{ 0, 0, "ATMEL/AT76C504_R", ATMEL_FW_TYPE_504_2958, "NoName-504-2958" },
+	{ MANFID_3COM, 0x0620, NULL, ATMEL_FW_TYPE_502_3COM, "3com 3CRWE62092B" }, 
+	{ MANFID_3COM, 0x0696, NULL, ATMEL_FW_TYPE_502_3COM, "3com 3CRSHPW196" }, 
+	{ 0, 0, "SMC/2632W-V2", ATMEL_FW_TYPE_502, "SMC 2632W-V2" },
+	{ 0, 0, "SMC/2632W", ATMEL_FW_TYPE_502D, "SMC 2632W-V3" },
+	{ 0xd601, 0x0007, NULL, ATMEL_FW_TYPE_502, "Sitecom WLAN-011" }, 
+	{ 0x01bf, 0x3302, NULL, ATMEL_FW_TYPE_502E, "Belkin F5D6020-V2" }, 
+	{ 0, 0, "BT/Voyager 1020 Laptop Adapter", ATMEL_FW_TYPE_502, "BT Voyager 1020" },
+	{ 0, 0, "IEEE 802.11b/Wireless LAN PC Card", ATMEL_FW_TYPE_502, "Siemens Gigaset PC Card II" },
+	{ 0, 0, "CNet/CNWLC 11Mbps Wireless PC Card V-5", ATMEL_FW_TYPE_502E, "CNet CNWLC-811ARL" },
+	{ 0, 0, "Wireless/PC_CARD", ATMEL_FW_TYPE_502D, "Planet WL-3552" },
+	{ 0, 0, "OEM/11Mbps Wireless LAN PC Card V-3", ATMEL_FW_TYPE_502, "OEM 11Mbps WLAN PCMCIA Card" },
+	{ 0, 0, "11WAVE/11WP611AL-E", ATMEL_FW_TYPE_502E, "11WAVE WaveBuddy" } 
 };
 
 static void atmel_config(dev_link_t *link)
@@ -520,7 +516,7 @@
 	((local_info_t*)link->priv)->eth_dev = 
 		init_atmel_card(link->irq.AssignedIRQ,
 				link->io.BasePort1,
-				card_index == -1 ? NULL :  card_table[card_index].firmware,
+				card_index == -1 ? ATMEL_FW_TYPE_NONE :  card_table[card_index].firmware,
 				&handle_to_dev(handle),
 				card_present, 
 				link);
--- a/drivers/net/wireless/atmel_pci.c	2005-02-01 16:15:24.000000000 -0500
+++ b/drivers/net/wireless/atmel_pci.c	2005-01-30 14:05:30.000000000 -0500
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
+#include "atmel.h"
 
 MODULE_AUTHOR("Simon Kelley");
 MODULE_DESCRIPTION("Support for Atmel at76c50x 802.11 wireless ethernet cards.");
@@ -40,9 +41,6 @@
 
 static int atmel_pci_probe(struct pci_dev *, const struct pci_device_id *);
 static void atmel_pci_remove(struct pci_dev *);
-struct net_device *init_atmel_card(int, int, char *, struct device *, 
-				   int (*present_func)(void *), void * );
-void stop_atmel_card( struct net_device *, int );
 
 static struct pci_driver atmel_driver = {
 	.name     = "atmel",
@@ -63,7 +61,7 @@
 	pci_set_master(pdev);
 	
 	dev = init_atmel_card(pdev->irq, pdev->resource[1].start, 
-			      "atmel_at76c506%s.bin",
+			      ATMEL_FW_TYPE_506,
 			      &pdev->dev, NULL, NULL);
 	if (!dev)
 		return -ENODEV;
