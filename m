From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.11-rc2] wireless: Atmel clearer firmware selection and
 502e max rssi fix
Date: Sun, 30 Jan 2005 19:05:20 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0501301847300.6929@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="279707962-801068342-1107129390=:6929"
Cc: jgarzik@redhat.com, jt@hpl.hp.com, simon@thekelleys.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.58.0501301858230.6929@devserv.devel.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--279707962-801068342-1107129390=:6929
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.58.0501301858231.6929@devserv.devel.redhat.com>

Clear up firmware selection by passing an enum into init_atmel_card() 
rather than the firmware string.  Necessary to differentiate between 
firmware versions due to different max rssi for each firmware.  Move 
common prototypes into new atmel.h file which also contains firmware enum.

Signed-off-by: Dan Williams <dcbw@redhat.com>


--- /dev/null	1969-12-31 19:00:00.000000000 -0500
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
--- a/drivers/net/wireless/atmel.c	2005-01-27 20:26:46.000000000 -0500
+++ b/drivers/net/wireless/atmel.c	2005-01-30 18:37:27.000000000 -0500
@@ -69,6 +69,7 @@
 #include <linux/moduleparam.h>
 #include <linux/firmware.h>
 #include "ieee802_11.h"
+#include "atmel.h"
 
 #define DRIVER_MAJOR 0
 #define DRIVER_MINOR 96
@@ -83,6 +84,22 @@
 static char *firmware = NULL;
 module_param(firmware, charp, 0);
 
+/* table of firmware file names */
+static struct { 
+	AtmelFWType fw_type;
+	const char *filename;
+} firmware_table[] = {
+	{ ATMEL_FW_TYPE_502,      "atmel_at76c502%s.bin" },
+	{ ATMEL_FW_TYPE_502D,     "atmel_at76c502d%s.bin" },
+	{ ATMEL_FW_TYPE_502E,     "atmel_at76c502e%s.bin" },
+	{ ATMEL_FW_TYPE_502_3COM, "atmel_at76c502_3com%s.bin" },
+	{ ATMEL_FW_TYPE_504,      "atmel_at76c504%s.bin" },
+	{ ATMEL_FW_TYPE_504_2958, "atmel_at76c504_2958%s.bin" },
+	{ ATMEL_FW_TYPE_504A_2958,"atmel_at76c504a_2958%s.bin" },
+	{ ATMEL_FW_TYPE_506,      "atmel_at76c506%s.bin" },
+	{ ATMEL_FW_TYPE_NONE,      NULL }
+};
+
 #define MAX_SSID_LENGTH 32
 #define MGMT_JIFFIES (256 * HZ / 100)
 
@@ -458,8 +475,8 @@
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
@@ -1293,17 +1310,21 @@
 	if (priv->operating_mode == IW_MODE_INFRA) {
 		if (priv->station_state != STATION_STATE_READY) {
 			priv->wstats.qual.qual = 0;
-			priv->wstats.qual.level	= 0;
+			priv->wstats.qual.level = 0;
+			priv->wstats.qual.updated |= (IW_QUAL_QUAL_INVALID
+						| IW_QUAL_LEVEL_INVALID);
 		}
 		priv->wstats.qual.noise = 0;
-		priv->wstats.qual.updated = 7;
+		priv->wstats.qual.updated |= IW_QUAL_NOISE_INVALID;
 	} else {
 		/* Quality levels cannot be determined in ad-hoc mode,
 		   because we can 'hear' more that one remote station. */
 		priv->wstats.qual.qual = 0;
 		priv->wstats.qual.level	= 0;
 		priv->wstats.qual.noise	= 0;
-		priv->wstats.qual.updated = 0;
+		priv->wstats.qual.updated = IW_QUAL_QUAL_INVALID
+					| IW_QUAL_LEVEL_INVALID
+					| IW_QUAL_NOISE_INVALID;
 		priv->wstats.miss.beacon = 0;
 	}
 	
@@ -1482,7 +1503,7 @@
         return len;
 }
 
-struct net_device *init_atmel_card( unsigned short irq, int port, char *firmware_id,  
+struct net_device *init_atmel_card( unsigned short irq, int port, const AtmelFWType fw_type,  
 				    struct device *sys_dev, int (*card_present)(void *), void *card)
 {
 	struct net_device *dev;
@@ -1507,11 +1528,9 @@
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
@@ -2218,6 +2237,9 @@
 	range->max_qual.qual = 100;
 	range->max_qual.level = 100;
 	range->max_qual.noise = 0;
+	range->max_qual.updated = IW_QUAL_QUAL_UPDATED
+				| IW_QUAL_LEVEL_UPDATED
+				| IW_QUAL_NOISE_INVALID;
 	range->sensitivity = 0;
 
 	range->bitrate[0] =  1000000;
@@ -2247,9 +2269,13 @@
 	range->r_time_flags = 0;
 	range->min_retry = 1;
 	range->max_retry = 65535;
+
 	range->avg_qual.qual = 50;
 	range->avg_qual.level = 50;
 	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_QUAL_UPDATED
+				| IW_QUAL_LEVEL_UPDATED
+				| IW_QUAL_NOISE_INVALID;
 
 	return 0;
 }
@@ -3025,16 +3051,23 @@
 static void smooth_rssi(struct atmel_private *priv, u8 rssi)
 {
 	u8 old = priv->wstats.qual.level;
+	u8 max_rssi = 42; /* 502-rmfd-revd max by experiment */
 
-	/* 502-rmfd-revd gives max signal level as 42, by experiment.
-	   This is going to break for other hardware variants. */
+	switch (priv->firmware_type) {
+		case ATMEL_FW_TYPE_502E:
+			max_rssi = 63; /* 502-rmfd-reve max by experiment */
+			break;
+		default:
+			break;
+	}
 
-	rssi = rssi * 100 / 42;
+	rssi = rssi * 100 / max_rssi;
 	if((rssi + old) % 2)
 		priv->wstats.qual.level =  ((rssi + old)/2) + 1;
 	else
 		priv->wstats.qual.level =  ((rssi + old)/2);		
-	
+	priv->wstats.qual.updated |= IW_QUAL_LEVEL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_LEVEL_INVALID;
 }
 
 static void atmel_smooth_qual(struct atmel_private *priv)
@@ -3047,8 +3080,10 @@
 			priv->beacons_this_sec * priv->beacon_period * 
(priv->wstats.qual.level + 100) / 4000;
 		priv->beacons_this_sec = 0;
 	}
+	priv->wstats.qual.updated |= IW_QUAL_QUAL_UPDATED;
+	priv->wstats.qual.updated &= ~IW_QUAL_QUAL_INVALID;
 }
-	
+
 /* deals with incoming managment frames. */
 static void atmel_management_frame(struct atmel_private *priv, struct ieee802_11_hdr *header, 
 		      u16 frame_len, u8 rssi)
@@ -3571,6 +3606,17 @@
 	atmel_set_mib(priv, Mac_Wep_Mib_Type, 0, (u8 *)&mib, sizeof(mib));
 }
 					
+static const char *atmel_get_firmware_template (const AtmelFWType fw_type)
+{
+	int i;
+	for(i = 0; i < sizeof(firmware_table)/sizeof(firmware_table[0]); i++)
+	{
+		if (firmware_table[i].fw_type == fw_type)
+			return firmware_table[i].filename;
+	}
+	return NULL;
+}
+
 static int reset_atmel_card(struct net_device *dev) 
 {
 	/* do everything necessary to wake up the hardware, including
@@ -3611,8 +3657,8 @@
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
@@ -3627,24 +3673,24 @@
 					       "%s: firmware %s is missing, cannot continue.\n", 
 					       dev->name, priv->firmware_id);
 					return 0;
-					
-				} 
+				}
 			} else {
 				int i;
+				const char *s = atmel_get_firmware_template(priv->firmware_type);
 				
-				for (i = 0; firmware_modifier[i]; i++) {
-					sprintf(priv->firmware_id, priv->firmware_template, firmware_modifier[i]);
+				for (i = 0; s && firmware_modifier[i]; i++) {
+					snprintf(priv->firmware_id, 32, s, firmware_modifier[i]);
+					priv->firmware_id[31] = '\0';
 					if (request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev) == 0) 
 						break;
 				}
-				if (!firmware_modifier[i]) {
+				if (!s || !firmware_modifier[i]) {
 					printk(KERN_ALERT 
 					       "%s: firmware %s is missing, cannot start.\n", 
 					       dev->name, priv->firmware_id);
 					priv->firmware_id[0] = '\0';
 					return 0;	
 				}
-				priv->firmware_template[0] = '\0';	
 			}
 			
 			fw = fw_entry->data;
--- a/drivers/net/wireless/atmel_cs.c	2005-01-27 20:26:46.000000000 -0500
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
--- a/drivers/net/wireless/atmel_pci.c	2005-01-27 20:26:46.000000000 -0500
+++ b/drivers/net/wireless/atmel_pci.c	2005-01-30 14:05:30.000000000 -0500
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
+#include "atmel.h"
 
 MODULE_AUTHOR("Simon Kelley");
 MODULE_DESCRIPTION("Support for Atmel at76c50x 802.11 wireless ethernet 
cards.");
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

--279707962-801068342-1107129390=:6929
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="atmel-502e-quality-fix.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0501301856301.6929@devserv.devel.redhat.com>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="atmel-502e-quality-fix.patch"

LS0tIC9kZXYvbnVsbAkxOTY5LTEyLTMxIDE5OjAwOjAwLjAwMDAwMDAwMCAt
MDUwMA0KKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvYXRtZWwuaAkyMDA1
LTAxLTMwIDE4OjMzOjMxLjAwMDAwMDAwMCAtMDUwMA0KQEAgLTAsMCArMSw0
MyBAQA0KKy8qKiogLSotIGxpbnV4LWMgLSotICoqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioNCisN
CisgICAgIERyaXZlciBmb3IgQXRtZWwgYXQ3NmM1MDIgYXQ3NmM1MDQgYW5k
IGF0NzZjNTA2IHdpcmVsZXNzIGNhcmRzLg0KKw0KKyAgICAgICAgIENvcHly
aWdodCAyMDA1IERhbiBXaWxsaWFtcyBhbmQgUmVkIEhhdCwgSW5jLg0KKw0K
KyAgICBUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiBy
ZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1vZGlmeQ0KKyAgICBpdCB1bmRlciB0
aGUgdGVybXMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGFz
IHB1Ymxpc2hlZCBieQ0KKyAgICB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0
aW9uOyBlaXRoZXIgdmVyc2lvbiAyIG9mIHRoZSBMaWNlbnNlLCBvcg0KKyAg
ICAoYXQgeW91ciBvcHRpb24pIGFueSBsYXRlciB2ZXJzaW9uLg0KKw0KKyAg
ICBUaGlzIHNvZnR3YXJlIGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIHRo
YXQgaXQgd2lsbCBiZSB1c2VmdWwsDQorICAgIGJ1dCBXSVRIT1VUIEFOWSBX
QVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9m
DQorICAgIE1FUkNIQU5UQUJJTElUWSBvciBGSVRORVNTIEZPUiBBIFBBUlRJ
Q1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUNCisgICAgR05VIEdlbmVyYWwgUHVi
bGljIExpY2Vuc2UgZm9yIG1vcmUgZGV0YWlscy4NCisNCisgICAgWW91IHNo
b3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwg
UHVibGljIExpY2Vuc2UNCisgICAgYWxvbmcgd2l0aCBBdG1lbCB3aXJlbGVz
cyBsYW4gZHJpdmVyczsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0
d2FyZQ0KKyAgICBGb3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUgUGxhY2Us
IFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAgMDIxMTEtMTMwNyAgVVNBDQorDQor
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqLw0KKw0KKyNpZm5k
ZWYgX0FUTUVMX0gNCisjZGVmaW5lIF9BVE1FTF9IDQorDQordHlwZWRlZiBl
bnVtIHsNCisJQVRNRUxfRldfVFlQRV9OT05FID0gMCwNCisJQVRNRUxfRldf
VFlQRV81MDIsDQorCUFUTUVMX0ZXX1RZUEVfNTAyRCwNCisJQVRNRUxfRldf
VFlQRV81MDJFLA0KKwlBVE1FTF9GV19UWVBFXzUwMl8zQ09NLA0KKwlBVE1F
TF9GV19UWVBFXzUwNCwNCisJQVRNRUxfRldfVFlQRV81MDRfMjk1OCwNCisJ
QVRNRUxfRldfVFlQRV81MDRBXzI5NTgsDQorCUFUTUVMX0ZXX1RZUEVfNTA2
DQorfSBBdG1lbEZXVHlwZTsNCisNCitzdHJ1Y3QgbmV0X2RldmljZSAqaW5p
dF9hdG1lbF9jYXJkKHVuc2lnbmVkIHNob3J0LCBpbnQsIGNvbnN0IEF0bWVs
RldUeXBlLCBzdHJ1Y3QgZGV2aWNlICosIA0KKwkJCQkgICAgaW50ICgqcHJl
c2VudF9mdW5jKSh2b2lkICopLCB2b2lkICogKTsNCit2b2lkIHN0b3BfYXRt
ZWxfY2FyZCggc3RydWN0IG5ldF9kZXZpY2UgKiwgaW50ICk7DQoraW50IGF0
bWVsX29wZW4oIHN0cnVjdCBuZXRfZGV2aWNlICogKTsNCisNCisjZW5kaWYN
Ci0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2F0bWVsLmMJMjAwNS0wMS0y
NyAyMDoyNjo0Ni4wMDAwMDAwMDAgLTA1MDANCisrKyBiL2RyaXZlcnMvbmV0
L3dpcmVsZXNzL2F0bWVsLmMJMjAwNS0wMS0zMCAxODozNzoyNy4wMDAwMDAw
MDAgLTA1MDANCkBAIC02OSw2ICs2OSw3IEBADQogI2luY2x1ZGUgPGxpbnV4
L21vZHVsZXBhcmFtLmg+DQogI2luY2x1ZGUgPGxpbnV4L2Zpcm13YXJlLmg+
DQogI2luY2x1ZGUgImllZWU4MDJfMTEuaCINCisjaW5jbHVkZSAiYXRtZWwu
aCINCiANCiAjZGVmaW5lIERSSVZFUl9NQUpPUiAwDQogI2RlZmluZSBEUklW
RVJfTUlOT1IgOTYNCkBAIC04Myw2ICs4NCwyMiBAQA0KIHN0YXRpYyBjaGFy
ICpmaXJtd2FyZSA9IE5VTEw7DQogbW9kdWxlX3BhcmFtKGZpcm13YXJlLCBj
aGFycCwgMCk7DQogDQorLyogdGFibGUgb2YgZmlybXdhcmUgZmlsZSBuYW1l
cyAqLw0KK3N0YXRpYyBzdHJ1Y3QgeyANCisJQXRtZWxGV1R5cGUgZndfdHlw
ZTsNCisJY29uc3QgY2hhciAqZmlsZW5hbWU7DQorfSBmaXJtd2FyZV90YWJs
ZVtdID0gew0KKwl7IEFUTUVMX0ZXX1RZUEVfNTAyLCAgICAgICJhdG1lbF9h
dDc2YzUwMiVzLmJpbiIgfSwNCisJeyBBVE1FTF9GV19UWVBFXzUwMkQsICAg
ICAiYXRtZWxfYXQ3NmM1MDJkJXMuYmluIiB9LA0KKwl7IEFUTUVMX0ZXX1RZ
UEVfNTAyRSwgICAgICJhdG1lbF9hdDc2YzUwMmUlcy5iaW4iIH0sDQorCXsg
QVRNRUxfRldfVFlQRV81MDJfM0NPTSwgImF0bWVsX2F0NzZjNTAyXzNjb20l
cy5iaW4iIH0sDQorCXsgQVRNRUxfRldfVFlQRV81MDQsICAgICAgImF0bWVs
X2F0NzZjNTA0JXMuYmluIiB9LA0KKwl7IEFUTUVMX0ZXX1RZUEVfNTA0XzI5
NTgsICJhdG1lbF9hdDc2YzUwNF8yOTU4JXMuYmluIiB9LA0KKwl7IEFUTUVM
X0ZXX1RZUEVfNTA0QV8yOTU4LCJhdG1lbF9hdDc2YzUwNGFfMjk1OCVzLmJp
biIgfSwNCisJeyBBVE1FTF9GV19UWVBFXzUwNiwgICAgICAiYXRtZWxfYXQ3
NmM1MDYlcy5iaW4iIH0sDQorCXsgQVRNRUxfRldfVFlQRV9OT05FLCAgICAg
IE5VTEwgfQ0KK307DQorDQogI2RlZmluZSBNQVhfU1NJRF9MRU5HVEggMzIN
CiAjZGVmaW5lIE1HTVRfSklGRklFUyAoMjU2ICogSFogLyAxMDApDQogDQpA
QCAtNDU4LDggKzQ3NSw4IEBADQogCXZvaWQgKmNhcmQ7IC8qIEJ1cyBkZXBl
bmRlbnQgc3R1Y3R1cmUgdmFyaWVzIGZvciBQQ2NhcmQgKi8NCiAJaW50ICgq
cHJlc2VudF9jYWxsYmFjaykodm9pZCAqKTsgLyogQW5kIGNhbGxiYWNrIHdo
aWNoIHVzZXMgaXQgKi8NCiAJY2hhciBmaXJtd2FyZV9pZFszMl07DQotCWNo
YXIgZmlybXdhcmVfdGVtcGxhdGVbMzJdOw0KLQl1bnNpZ25lZCBjaGFyICpm
aXJtd2FyZTsNCisJQXRtZWxGV1R5cGUgZmlybXdhcmVfdHlwZTsNCisJdTgg
KmZpcm13YXJlOw0KIAlpbnQgZmlybXdhcmVfbGVuZ3RoOw0KIAlzdHJ1Y3Qg
dGltZXJfbGlzdCBtYW5hZ2VtZW50X3RpbWVyOw0KIAlzdHJ1Y3QgbmV0X2Rl
dmljZSAqZGV2Ow0KQEAgLTEyOTMsMTcgKzEzMTAsMjEgQEANCiAJaWYgKHBy
aXYtPm9wZXJhdGluZ19tb2RlID09IElXX01PREVfSU5GUkEpIHsNCiAJCWlm
IChwcml2LT5zdGF0aW9uX3N0YXRlICE9IFNUQVRJT05fU1RBVEVfUkVBRFkp
IHsNCiAJCQlwcml2LT53c3RhdHMucXVhbC5xdWFsID0gMDsNCi0JCQlwcml2
LT53c3RhdHMucXVhbC5sZXZlbAk9IDA7DQorCQkJcHJpdi0+d3N0YXRzLnF1
YWwubGV2ZWwgPSAwOw0KKwkJCXByaXYtPndzdGF0cy5xdWFsLnVwZGF0ZWQg
fD0gKElXX1FVQUxfUVVBTF9JTlZBTElEDQorCQkJCQkJCXwgSVdfUVVBTF9M
RVZFTF9JTlZBTElEKTsNCiAJCX0NCiAJCXByaXYtPndzdGF0cy5xdWFsLm5v
aXNlID0gMDsNCi0JCXByaXYtPndzdGF0cy5xdWFsLnVwZGF0ZWQgPSA3Ow0K
KwkJcHJpdi0+d3N0YXRzLnF1YWwudXBkYXRlZCB8PSBJV19RVUFMX05PSVNF
X0lOVkFMSUQ7DQogCX0gZWxzZSB7DQogCQkvKiBRdWFsaXR5IGxldmVscyBj
YW5ub3QgYmUgZGV0ZXJtaW5lZCBpbiBhZC1ob2MgbW9kZSwNCiAJCSAgIGJl
Y2F1c2Ugd2UgY2FuICdoZWFyJyBtb3JlIHRoYXQgb25lIHJlbW90ZSBzdGF0
aW9uLiAqLw0KIAkJcHJpdi0+d3N0YXRzLnF1YWwucXVhbCA9IDA7DQogCQlw
cml2LT53c3RhdHMucXVhbC5sZXZlbAk9IDA7DQogCQlwcml2LT53c3RhdHMu
cXVhbC5ub2lzZQk9IDA7DQotCQlwcml2LT53c3RhdHMucXVhbC51cGRhdGVk
ID0gMDsNCisJCXByaXYtPndzdGF0cy5xdWFsLnVwZGF0ZWQgPSBJV19RVUFM
X1FVQUxfSU5WQUxJRA0KKwkJCQkJCQl8IElXX1FVQUxfTEVWRUxfSU5WQUxJ
RA0KKwkJCQkJCQl8IElXX1FVQUxfTk9JU0VfSU5WQUxJRDsNCiAJCXByaXYt
PndzdGF0cy5taXNzLmJlYWNvbiA9IDA7DQogCX0NCiAJDQpAQCAtMTQ4Miw3
ICsxNTAzLDcgQEANCiAgICAgICAgIHJldHVybiBsZW47DQogfQ0KIA0KLXN0
cnVjdCBuZXRfZGV2aWNlICppbml0X2F0bWVsX2NhcmQoIHVuc2lnbmVkIHNo
b3J0IGlycSwgaW50IHBvcnQsIGNoYXIgKmZpcm13YXJlX2lkLCAgDQorc3Ry
dWN0IG5ldF9kZXZpY2UgKmluaXRfYXRtZWxfY2FyZCggdW5zaWduZWQgc2hv
cnQgaXJxLCBpbnQgcG9ydCwgY29uc3QgQXRtZWxGV1R5cGUgZndfdHlwZSwg
IA0KIAkJCQkgICAgc3RydWN0IGRldmljZSAqc3lzX2RldiwgaW50ICgqY2Fy
ZF9wcmVzZW50KSh2b2lkICopLCB2b2lkICpjYXJkKQ0KIHsNCiAJc3RydWN0
IG5ldF9kZXZpY2UgKmRldjsNCkBAIC0xNTA3LDExICsxNTI4LDkgQEANCiAJ
cHJpdi0+Y2FyZCA9IGNhcmQ7DQogCXByaXYtPmZpcm13YXJlID0gTlVMTDsN
CiAJcHJpdi0+ZmlybXdhcmVfaWRbMF0gPSAnXDAnOw0KLQlwcml2LT5maXJt
d2FyZV90ZW1wbGF0ZVswXSA9ICdcMCc7DQorCXByaXYtPmZpcm13YXJlX3R5
cGUgPSBmd190eXBlOw0KIAlpZiAoZmlybXdhcmUpIC8qIG1vZHVsZSBwYXJh
bWV0ZXIgKi8NCiAJCXN0cmNweShwcml2LT5maXJtd2FyZV9pZCwgZmlybXdh
cmUpOw0KLQllbHNlIGlmIChmaXJtd2FyZV9pZCkgLyogZnJvbSBQQ01DSUEg
Y2FyZC1tYXRjaGluZyBvciBQQ0kgKi8NCi0JCXN0cmNweShwcml2LT5maXJt
d2FyZV90ZW1wbGF0ZSwgZmlybXdhcmVfaWQpOw0KIAlwcml2LT5idXNfdHlw
ZSA9IGNhcmRfcHJlc2VudCA/IEJVU19UWVBFX1BDQ0FSRCA6IEJVU19UWVBF
X1BDSTsNCiAJcHJpdi0+c3RhdGlvbl9zdGF0ZSA9IFNUQVRJT05fU1RBVEVf
RE9XTjsNCiAJcHJpdi0+ZG9fcnhfY3JjID0gMDsNCkBAIC0yMjE4LDYgKzIy
MzcsOSBAQA0KIAlyYW5nZS0+bWF4X3F1YWwucXVhbCA9IDEwMDsNCiAJcmFu
Z2UtPm1heF9xdWFsLmxldmVsID0gMTAwOw0KIAlyYW5nZS0+bWF4X3F1YWwu
bm9pc2UgPSAwOw0KKwlyYW5nZS0+bWF4X3F1YWwudXBkYXRlZCA9IElXX1FV
QUxfUVVBTF9VUERBVEVEDQorCQkJCQkJfCBJV19RVUFMX0xFVkVMX1VQREFU
RUQNCisJCQkJCQl8IElXX1FVQUxfTk9JU0VfSU5WQUxJRDsNCiAJcmFuZ2Ut
PnNlbnNpdGl2aXR5ID0gMDsNCiANCiAJcmFuZ2UtPmJpdHJhdGVbMF0gPSAg
MTAwMDAwMDsNCkBAIC0yMjQ3LDkgKzIyNjksMTMgQEANCiAJcmFuZ2UtPnJf
dGltZV9mbGFncyA9IDA7DQogCXJhbmdlLT5taW5fcmV0cnkgPSAxOw0KIAly
YW5nZS0+bWF4X3JldHJ5ID0gNjU1MzU7DQorDQogCXJhbmdlLT5hdmdfcXVh
bC5xdWFsID0gNTA7DQogCXJhbmdlLT5hdmdfcXVhbC5sZXZlbCA9IDUwOw0K
IAlyYW5nZS0+YXZnX3F1YWwubm9pc2UgPSAwOw0KKwlyYW5nZS0+YXZnX3F1
YWwudXBkYXRlZCA9IElXX1FVQUxfUVVBTF9VUERBVEVEDQorCQkJCQkJfCBJ
V19RVUFMX0xFVkVMX1VQREFURUQNCisJCQkJCQl8IElXX1FVQUxfTk9JU0Vf
SU5WQUxJRDsNCiANCiAJcmV0dXJuIDA7DQogfQ0KQEAgLTMwMjUsMTYgKzMw
NTEsMjMgQEANCiBzdGF0aWMgdm9pZCBzbW9vdGhfcnNzaShzdHJ1Y3QgYXRt
ZWxfcHJpdmF0ZSAqcHJpdiwgdTggcnNzaSkNCiB7DQogCXU4IG9sZCA9IHBy
aXYtPndzdGF0cy5xdWFsLmxldmVsOw0KKwl1OCBtYXhfcnNzaSA9IDQyOyAv
KiA1MDItcm1mZC1yZXZkIG1heCBieSBleHBlcmltZW50ICovDQogDQotCS8q
IDUwMi1ybWZkLXJldmQgZ2l2ZXMgbWF4IHNpZ25hbCBsZXZlbCBhcyA0Miwg
YnkgZXhwZXJpbWVudC4NCi0JICAgVGhpcyBpcyBnb2luZyB0byBicmVhayBm
b3Igb3RoZXIgaGFyZHdhcmUgdmFyaWFudHMuICovDQorCXN3aXRjaCAocHJp
di0+ZmlybXdhcmVfdHlwZSkgew0KKwkJY2FzZSBBVE1FTF9GV19UWVBFXzUw
MkU6DQorCQkJbWF4X3Jzc2kgPSA2MzsgLyogNTAyLXJtZmQtcmV2ZSBtYXgg
YnkgZXhwZXJpbWVudCAqLw0KKwkJCWJyZWFrOw0KKwkJZGVmYXVsdDoNCisJ
CQlicmVhazsNCisJfQ0KIA0KLQlyc3NpID0gcnNzaSAqIDEwMCAvIDQyOw0K
Kwlyc3NpID0gcnNzaSAqIDEwMCAvIG1heF9yc3NpOw0KIAlpZigocnNzaSAr
IG9sZCkgJSAyKQ0KIAkJcHJpdi0+d3N0YXRzLnF1YWwubGV2ZWwgPSAgKChy
c3NpICsgb2xkKS8yKSArIDE7DQogCWVsc2UNCiAJCXByaXYtPndzdGF0cy5x
dWFsLmxldmVsID0gICgocnNzaSArIG9sZCkvMik7CQkNCi0JDQorCXByaXYt
PndzdGF0cy5xdWFsLnVwZGF0ZWQgfD0gSVdfUVVBTF9MRVZFTF9VUERBVEVE
Ow0KKwlwcml2LT53c3RhdHMucXVhbC51cGRhdGVkICY9IH5JV19RVUFMX0xF
VkVMX0lOVkFMSUQ7DQogfQ0KIA0KIHN0YXRpYyB2b2lkIGF0bWVsX3Ntb290
aF9xdWFsKHN0cnVjdCBhdG1lbF9wcml2YXRlICpwcml2KQ0KQEAgLTMwNDcs
OCArMzA4MCwxMCBAQA0KIAkJCXByaXYtPmJlYWNvbnNfdGhpc19zZWMgKiBw
cml2LT5iZWFjb25fcGVyaW9kICogKHByaXYtPndzdGF0cy5xdWFsLmxldmVs
ICsgMTAwKSAvIDQwMDA7DQogCQlwcml2LT5iZWFjb25zX3RoaXNfc2VjID0g
MDsNCiAJfQ0KKwlwcml2LT53c3RhdHMucXVhbC51cGRhdGVkIHw9IElXX1FV
QUxfUVVBTF9VUERBVEVEOw0KKwlwcml2LT53c3RhdHMucXVhbC51cGRhdGVk
ICY9IH5JV19RVUFMX1FVQUxfSU5WQUxJRDsNCiB9DQotCQ0KKw0KIC8qIGRl
YWxzIHdpdGggaW5jb21pbmcgbWFuYWdtZW50IGZyYW1lcy4gKi8NCiBzdGF0
aWMgdm9pZCBhdG1lbF9tYW5hZ2VtZW50X2ZyYW1lKHN0cnVjdCBhdG1lbF9w
cml2YXRlICpwcml2LCBzdHJ1Y3QgaWVlZTgwMl8xMV9oZHIgKmhlYWRlciwg
DQogCQkgICAgICB1MTYgZnJhbWVfbGVuLCB1OCByc3NpKQ0KQEAgLTM1NzEs
NiArMzYwNiwxNyBAQA0KIAlhdG1lbF9zZXRfbWliKHByaXYsIE1hY19XZXBf
TWliX1R5cGUsIDAsICh1OCAqKSZtaWIsIHNpemVvZihtaWIpKTsNCiB9DQog
CQkJCQkNCitzdGF0aWMgY29uc3QgY2hhciAqYXRtZWxfZ2V0X2Zpcm13YXJl
X3RlbXBsYXRlIChjb25zdCBBdG1lbEZXVHlwZSBmd190eXBlKQ0KK3sNCisJ
aW50IGk7DQorCWZvcihpID0gMDsgaSA8IHNpemVvZihmaXJtd2FyZV90YWJs
ZSkvc2l6ZW9mKGZpcm13YXJlX3RhYmxlWzBdKTsgaSsrKQ0KKwl7DQorCQlp
ZiAoZmlybXdhcmVfdGFibGVbaV0uZndfdHlwZSA9PSBmd190eXBlKQ0KKwkJ
CXJldHVybiBmaXJtd2FyZV90YWJsZVtpXS5maWxlbmFtZTsNCisJfQ0KKwly
ZXR1cm4gTlVMTDsNCit9DQorDQogc3RhdGljIGludCByZXNldF9hdG1lbF9j
YXJkKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpIA0KIHsNCiAJLyogZG8gZXZl
cnl0aGluZyBuZWNlc3NhcnkgdG8gd2FrZSB1cCB0aGUgaGFyZHdhcmUsIGlu
Y2x1ZGluZw0KQEAgLTM2MTEsOCArMzY1Nyw4IEBADQogCQljb25zdCBzdHJ1
Y3QgZmlybXdhcmUgKmZ3X2VudHJ5ID0gTlVMTDsNCiAJCXVuc2lnbmVkIGNo
YXIgKmZ3Ow0KIAkJaW50IGxlbiA9IHByaXYtPmZpcm13YXJlX2xlbmd0aDsN
Ci0JCWlmICghKGZ3ID0gcHJpdi0+ZmlybXdhcmUpKSB7IA0KLQkJCWlmIChz
dHJsZW4ocHJpdi0+ZmlybXdhcmVfdGVtcGxhdGUpID09IDApIHsJDQorCQlp
ZiAoIShmdyA9IHByaXYtPmZpcm13YXJlKSkgew0KKwkJCWlmIChwcml2LT5m
aXJtd2FyZV90eXBlID09IEFUTUVMX0ZXX1RZUEVfTk9ORSkgew0KIAkJCQlp
ZiAoc3RybGVuKHByaXYtPmZpcm13YXJlX2lkKSA9PSAwKSB7DQogCQkJCQlw
cmludGsoS0VSTl9JTkZPDQogCQkJCQkgICAgICAgIiVzOiBjYXJkIHR5cGUg
aXMgdW5rbm93bjogYXNzdW1pbmcgYXQ3NmM1MDIgZmlybXdhcmUgaXMgT0su
XG4iLA0KQEAgLTM2MjcsMjQgKzM2NzMsMjQgQEANCiAJCQkJCSAgICAgICAi
JXM6IGZpcm13YXJlICVzIGlzIG1pc3NpbmcsIGNhbm5vdCBjb250aW51ZS5c
biIsIA0KIAkJCQkJICAgICAgIGRldi0+bmFtZSwgcHJpdi0+ZmlybXdhcmVf
aWQpOw0KIAkJCQkJcmV0dXJuIDA7DQotCQkJCQkNCi0JCQkJfSANCisJCQkJ
fQ0KIAkJCX0gZWxzZSB7DQogCQkJCWludCBpOw0KKwkJCQljb25zdCBjaGFy
ICpzID0gYXRtZWxfZ2V0X2Zpcm13YXJlX3RlbXBsYXRlKHByaXYtPmZpcm13
YXJlX3R5cGUpOw0KIAkJCQkNCi0JCQkJZm9yIChpID0gMDsgZmlybXdhcmVf
bW9kaWZpZXJbaV07IGkrKykgew0KLQkJCQkJc3ByaW50Zihwcml2LT5maXJt
d2FyZV9pZCwgcHJpdi0+ZmlybXdhcmVfdGVtcGxhdGUsIGZpcm13YXJlX21v
ZGlmaWVyW2ldKTsNCisJCQkJZm9yIChpID0gMDsgcyAmJiBmaXJtd2FyZV9t
b2RpZmllcltpXTsgaSsrKSB7DQorCQkJCQlzbnByaW50Zihwcml2LT5maXJt
d2FyZV9pZCwgMzIsIHMsIGZpcm13YXJlX21vZGlmaWVyW2ldKTsNCisJCQkJ
CXByaXYtPmZpcm13YXJlX2lkWzMxXSA9ICdcMCc7DQogCQkJCQlpZiAocmVx
dWVzdF9maXJtd2FyZSgmZndfZW50cnksIHByaXYtPmZpcm13YXJlX2lkLCBw
cml2LT5zeXNfZGV2KSA9PSAwKSANCiAJCQkJCQlicmVhazsNCiAJCQkJfQ0K
LQkJCQlpZiAoIWZpcm13YXJlX21vZGlmaWVyW2ldKSB7DQorCQkJCWlmICgh
cyB8fCAhZmlybXdhcmVfbW9kaWZpZXJbaV0pIHsNCiAJCQkJCXByaW50ayhL
RVJOX0FMRVJUIA0KIAkJCQkJICAgICAgICIlczogZmlybXdhcmUgJXMgaXMg
bWlzc2luZywgY2Fubm90IHN0YXJ0LlxuIiwgDQogCQkJCQkgICAgICAgZGV2
LT5uYW1lLCBwcml2LT5maXJtd2FyZV9pZCk7DQogCQkJCQlwcml2LT5maXJt
d2FyZV9pZFswXSA9ICdcMCc7DQogCQkJCQlyZXR1cm4gMDsJDQogCQkJCX0N
Ci0JCQkJcHJpdi0+ZmlybXdhcmVfdGVtcGxhdGVbMF0gPSAnXDAnOwkNCiAJ
CQl9DQogCQkJDQogCQkJZncgPSBmd19lbnRyeS0+ZGF0YTsNCi0tLSBhL2Ry
aXZlcnMvbmV0L3dpcmVsZXNzL2F0bWVsX2NzLmMJMjAwNS0wMS0yNyAyMDoy
Njo0Ni4wMDAwMDAwMDAgLTA1MDANCisrKyBiL2RyaXZlcnMvbmV0L3dpcmVs
ZXNzL2F0bWVsX2NzLmMJMjAwNS0wMS0zMCAxNDowNTowOC4wMDAwMDAwMDAg
LTA1MDANCkBAIC01NSw2ICs1NSw3IEBADQogI2luY2x1ZGUgPGFzbS9zeXN0
ZW0uaD4NCiAjaW5jbHVkZSA8bGludXgvd2lyZWxlc3MuaD4NCiANCisjaW5j
bHVkZSAiYXRtZWwuaCINCiANCiAvKg0KICAgIEFsbCB0aGUgUENNQ0lBIG1v
ZHVsZXMgdXNlIFBDTUNJQV9ERUJVRyB0byBjb250cm9sIGRlYnVnZ2luZy4g
IElmDQpAQCAtOTAsMTEgKzkxLDYgQEANCiAgICBldmVudCBoYW5kbGVyLiAN
CiAqLw0KIA0KLXN0cnVjdCBuZXRfZGV2aWNlICppbml0X2F0bWVsX2NhcmQo
aW50LCBpbnQsIGNoYXIgKiwgc3RydWN0IGRldmljZSAqLCANCi0JCQkJICAg
IGludCAoKnByZXNlbnRfZnVuYykodm9pZCAqKSwgdm9pZCAqICk7DQotdm9p
ZCBzdG9wX2F0bWVsX2NhcmQoIHN0cnVjdCBuZXRfZGV2aWNlICosIGludCAp
Ow0KLWludCBhdG1lbF9vcGVuKCBzdHJ1Y3QgbmV0X2RldmljZSAqICk7DQot
DQogc3RhdGljIHZvaWQgYXRtZWxfY29uZmlnKGRldl9saW5rX3QgKmxpbmsp
Ow0KIHN0YXRpYyB2b2lkIGF0bWVsX3JlbGVhc2UoZGV2X2xpbmtfdCAqbGlu
ayk7DQogc3RhdGljIGludCBhdG1lbF9ldmVudChldmVudF90IGV2ZW50LCBp
bnQgcHJpb3JpdHksDQpAQCAtMzA3LDI4ICszMDMsMjggQEANCiBzdGF0aWMg
c3RydWN0IHsgDQogCWludCBtYW5mLCBjYXJkOw0KIAljaGFyICp2ZXIxOw0K
LQljaGFyICpmaXJtd2FyZTsNCisJQXRtZWxGV1R5cGUgZmlybXdhcmU7DQog
CWNoYXIgKm5hbWU7DQogfSBjYXJkX3RhYmxlW10gPSB7DQotCXsgMCwgMCwg
IldMQU4vODAyLjExYiBQQyBDQVJEIiwgImF0bWVsX2F0NzZjNTAyZCVzLmJp
biIsICJBY3Rpb250ZWMgODAyQ0FUMSIgfSwgIA0KLQl7IDAsIDAsICJBVE1F
TC9BVDc2QzUwMkFSIiwgImF0bWVsX2F0NzZjNTAyJXMuYmluIiwgIk5vTmFt
ZS1SRk1EIiB9LCANCi0JeyAwLCAwLCAiQVRNRUwvQVQ3NkM1MDJBUl9EIiwg
ImF0bWVsX2F0NzZjNTAyZCVzLmJpbiIsICJOb05hbWUtcmV2RCIgfSwgDQot
CXsgMCwgMCwgIkFUTUVML0FUNzZDNTAyQVJfRSIsICJhdG1lbF9hdDc2YzUw
MmUlcy5iaW4iLCAiTm9OYW1lLXJldkUiIH0sDQotCXsgMCwgMCwgIkFUTUVM
L0FUNzZDNTA0IiwgImF0bWVsX2F0NzZjNTA0JXMuYmluIiwgIk5vTmFtZS01
MDQiIH0sDQotCXsgMCwgMCwgIkFUTUVML0FUNzZDNTA0QSIsICJhdG1lbF9h
dDc2YzUwNGFfMjk1OCVzLmJpbiIsICJOb05hbWUtNTA0YS0yOTU4IiB9LA0K
LQl7IDAsIDAsICJBVE1FTC9BVDc2QzUwNF9SIiwgImF0bWVsX2F0NzZjNTA0
XzI5NTglcy5iaW4iLCAiTm9OYW1lLTUwNC0yOTU4IiB9LA0KLQl7IE1BTkZJ
RF8zQ09NLCAweDA2MjAsIE5VTEwsICJhdG1lbF9hdDc2YzUwMl8zY29tJXMu
YmluIiwgIjNjb20gM0NSV0U2MjA5MkIiIH0sIA0KLQl7IE1BTkZJRF8zQ09N
LCAweDA2OTYsIE5VTEwsICJhdG1lbF9hdDc2YzUwMl8zY29tJXMuYmluIiwg
IjNjb20gM0NSU0hQVzE5NiIgfSwgDQotCXsgMCwgMCwgIlNNQy8yNjMyVy1W
MiIsICJhdG1lbF9hdDc2YzUwMiVzLmJpbiIsICJTTUMgMjYzMlctVjIiIH0s
DQotICAgICAgICB7IDAsIDAsICJTTUMvMjYzMlciLCAiYXRtZWxfYXQ3NmM1
MDJkJXMuYmluIiwgIlNNQyAyNjMyVy1WMyIgfSwNCi0JeyAweGQ2MDEsIDB4
MDAwNywgTlVMTCwgImF0bWVsX2F0NzZjNTAyJXMuYmluIiwgIlNpdGVjb20g
V0xBTi0wMTEiIH0sIA0KLQl7IDB4MDFiZiwgMHgzMzAyLCBOVUxMLCAiYXRt
ZWxfYXQ3NmM1MDJlJXMuYmluIiwgIkJlbGtpbiBGNUQ2MDIwLVYyIiB9LCAN
Ci0JeyAwLCAwLCAiQlQvVm95YWdlciAxMDIwIExhcHRvcCBBZGFwdGVyIiwg
ImF0bWVsX2F0NzZjNTAyJXMuYmluIiwgIkJUIFZveWFnZXIgMTAyMCIgfSwN
Ci0gICAgICAgIHsgMCwgMCwgIklFRUUgODAyLjExYi9XaXJlbGVzcyBMQU4g
UEMgQ2FyZCIsICJhdG1lbF9hdDc2YzUwMiVzLmJpbiIsICJTaWVtZW5zIEdp
Z2FzZXQgUEMgQ2FyZCBJSSIgfSwNCi0JeyAwLCAwLCAiQ05ldC9DTldMQyAx
MU1icHMgV2lyZWxlc3MgUEMgQ2FyZCBWLTUiLCAiYXRtZWxfYXQ3NmM1MDJl
JXMuYmluIiwgIkNOZXQgQ05XTEMtODExQVJMIiB9LA0KLQl7IDAsIDAsICJX
aXJlbGVzcy9QQ19DQVJEIiwgImF0bWVsX2F0NzZjNTAyZCVzLmJpbiIsICJQ
bGFuZXQgV0wtMzU1MiIgfSwNCi0JeyAwLCAwLCAiT0VNLzExTWJwcyBXaXJl
bGVzcyBMQU4gUEMgQ2FyZCBWLTMiLCAiYXRtZWxfYXQ3NmM1MDIlcy5iaW4i
LCAiT0VNIDExTWJwcyBXTEFOIFBDTUNJQSBDYXJkIiB9LA0KLQl7IDAsIDAs
ICIxMVdBVkUvMTFXUDYxMUFMLUUiLCAiYXRtZWxfYXQ3NmM1MDJlJXMuYmlu
IiwgIjExV0FWRSBXYXZlQnVkZHkiIH0gDQorCXsgMCwgMCwgIldMQU4vODAy
LjExYiBQQyBDQVJEIiwgQVRNRUxfRldfVFlQRV81MDJELCAiQWN0aW9udGVj
IDgwMkNBVDEiIH0sICANCisJeyAwLCAwLCAiQVRNRUwvQVQ3NkM1MDJBUiIs
IEFUTUVMX0ZXX1RZUEVfNTAyLCAiTm9OYW1lLVJGTUQiIH0sIA0KKwl7IDAs
IDAsICJBVE1FTC9BVDc2QzUwMkFSX0QiLCBBVE1FTF9GV19UWVBFXzUwMkQs
ICJOb05hbWUtcmV2RCIgfSwgDQorCXsgMCwgMCwgIkFUTUVML0FUNzZDNTAy
QVJfRSIsIEFUTUVMX0ZXX1RZUEVfNTAyRSwgIk5vTmFtZS1yZXZFIiB9LA0K
Kwl7IDAsIDAsICJBVE1FTC9BVDc2QzUwNCIsIEFUTUVMX0ZXX1RZUEVfNTA0
LCAiTm9OYW1lLTUwNCIgfSwNCisJeyAwLCAwLCAiQVRNRUwvQVQ3NkM1MDRB
IiwgQVRNRUxfRldfVFlQRV81MDRBXzI5NTgsICJOb05hbWUtNTA0YS0yOTU4
IiB9LA0KKwl7IDAsIDAsICJBVE1FTC9BVDc2QzUwNF9SIiwgQVRNRUxfRldf
VFlQRV81MDRfMjk1OCwgIk5vTmFtZS01MDQtMjk1OCIgfSwNCisJeyBNQU5G
SURfM0NPTSwgMHgwNjIwLCBOVUxMLCBBVE1FTF9GV19UWVBFXzUwMl8zQ09N
LCAiM2NvbSAzQ1JXRTYyMDkyQiIgfSwgDQorCXsgTUFORklEXzNDT00sIDB4
MDY5NiwgTlVMTCwgQVRNRUxfRldfVFlQRV81MDJfM0NPTSwgIjNjb20gM0NS
U0hQVzE5NiIgfSwgDQorCXsgMCwgMCwgIlNNQy8yNjMyVy1WMiIsIEFUTUVM
X0ZXX1RZUEVfNTAyLCAiU01DIDI2MzJXLVYyIiB9LA0KKwl7IDAsIDAsICJT
TUMvMjYzMlciLCBBVE1FTF9GV19UWVBFXzUwMkQsICJTTUMgMjYzMlctVjMi
IH0sDQorCXsgMHhkNjAxLCAweDAwMDcsIE5VTEwsIEFUTUVMX0ZXX1RZUEVf
NTAyLCAiU2l0ZWNvbSBXTEFOLTAxMSIgfSwgDQorCXsgMHgwMWJmLCAweDMz
MDIsIE5VTEwsIEFUTUVMX0ZXX1RZUEVfNTAyRSwgIkJlbGtpbiBGNUQ2MDIw
LVYyIiB9LCANCisJeyAwLCAwLCAiQlQvVm95YWdlciAxMDIwIExhcHRvcCBB
ZGFwdGVyIiwgQVRNRUxfRldfVFlQRV81MDIsICJCVCBWb3lhZ2VyIDEwMjAi
IH0sDQorCXsgMCwgMCwgIklFRUUgODAyLjExYi9XaXJlbGVzcyBMQU4gUEMg
Q2FyZCIsIEFUTUVMX0ZXX1RZUEVfNTAyLCAiU2llbWVucyBHaWdhc2V0IFBD
IENhcmQgSUkiIH0sDQorCXsgMCwgMCwgIkNOZXQvQ05XTEMgMTFNYnBzIFdp
cmVsZXNzIFBDIENhcmQgVi01IiwgQVRNRUxfRldfVFlQRV81MDJFLCAiQ05l
dCBDTldMQy04MTFBUkwiIH0sDQorCXsgMCwgMCwgIldpcmVsZXNzL1BDX0NB
UkQiLCBBVE1FTF9GV19UWVBFXzUwMkQsICJQbGFuZXQgV0wtMzU1MiIgfSwN
CisJeyAwLCAwLCAiT0VNLzExTWJwcyBXaXJlbGVzcyBMQU4gUEMgQ2FyZCBW
LTMiLCBBVE1FTF9GV19UWVBFXzUwMiwgIk9FTSAxMU1icHMgV0xBTiBQQ01D
SUEgQ2FyZCIgfSwNCisJeyAwLCAwLCAiMTFXQVZFLzExV1A2MTFBTC1FIiwg
QVRNRUxfRldfVFlQRV81MDJFLCAiMTFXQVZFIFdhdmVCdWRkeSIgfSANCiB9
Ow0KIA0KIHN0YXRpYyB2b2lkIGF0bWVsX2NvbmZpZyhkZXZfbGlua190ICps
aW5rKQ0KQEAgLTUyMCw3ICs1MTYsNyBAQA0KIAkoKGxvY2FsX2luZm9fdCop
bGluay0+cHJpdiktPmV0aF9kZXYgPSANCiAJCWluaXRfYXRtZWxfY2FyZChs
aW5rLT5pcnEuQXNzaWduZWRJUlEsDQogCQkJCWxpbmstPmlvLkJhc2VQb3J0
MSwNCi0JCQkJY2FyZF9pbmRleCA9PSAtMSA/IE5VTEwgOiAgY2FyZF90YWJs
ZVtjYXJkX2luZGV4XS5maXJtd2FyZSwNCisJCQkJY2FyZF9pbmRleCA9PSAt
MSA/IEFUTUVMX0ZXX1RZUEVfTk9ORSA6ICBjYXJkX3RhYmxlW2NhcmRfaW5k
ZXhdLmZpcm13YXJlLA0KIAkJCQkmaGFuZGxlX3RvX2RldihoYW5kbGUpLA0K
IAkJCQljYXJkX3ByZXNlbnQsIA0KIAkJCQlsaW5rKTsNCi0tLSBhL2RyaXZl
cnMvbmV0L3dpcmVsZXNzL2F0bWVsX3BjaS5jCTIwMDUtMDEtMjcgMjA6MjY6
NDYuMDAwMDAwMDAwIC0wNTAwDQorKysgYi9kcml2ZXJzL25ldC93aXJlbGVz
cy9hdG1lbF9wY2kuYwkyMDA1LTAxLTMwIDE0OjA1OjMwLjAwMDAwMDAwMCAt
MDUwMA0KQEAgLTI1LDYgKzI1LDcgQEANCiAjaW5jbHVkZSA8bGludXgvbW9k
dWxlLmg+DQogI2luY2x1ZGUgPGxpbnV4L2luaXQuaD4NCiAjaW5jbHVkZSA8
bGludXgvbmV0ZGV2aWNlLmg+DQorI2luY2x1ZGUgImF0bWVsLmgiDQogDQog
TU9EVUxFX0FVVEhPUigiU2ltb24gS2VsbGV5Iik7DQogTU9EVUxFX0RFU0NS
SVBUSU9OKCJTdXBwb3J0IGZvciBBdG1lbCBhdDc2YzUweCA4MDIuMTEgd2ly
ZWxlc3MgZXRoZXJuZXQgY2FyZHMuIik7DQpAQCAtNDAsOSArNDEsNiBAQA0K
IA0KIHN0YXRpYyBpbnQgYXRtZWxfcGNpX3Byb2JlKHN0cnVjdCBwY2lfZGV2
ICosIGNvbnN0IHN0cnVjdCBwY2lfZGV2aWNlX2lkICopOw0KIHN0YXRpYyB2
b2lkIGF0bWVsX3BjaV9yZW1vdmUoc3RydWN0IHBjaV9kZXYgKik7DQotc3Ry
dWN0IG5ldF9kZXZpY2UgKmluaXRfYXRtZWxfY2FyZChpbnQsIGludCwgY2hh
ciAqLCBzdHJ1Y3QgZGV2aWNlICosIA0KLQkJCQkgICBpbnQgKCpwcmVzZW50
X2Z1bmMpKHZvaWQgKiksIHZvaWQgKiApOw0KLXZvaWQgc3RvcF9hdG1lbF9j
YXJkKCBzdHJ1Y3QgbmV0X2RldmljZSAqLCBpbnQgKTsNCiANCiBzdGF0aWMg
c3RydWN0IHBjaV9kcml2ZXIgYXRtZWxfZHJpdmVyID0gew0KIAkubmFtZSAg
ICAgPSAiYXRtZWwiLA0KQEAgLTYzLDcgKzYxLDcgQEANCiAJcGNpX3NldF9t
YXN0ZXIocGRldik7DQogCQ0KIAlkZXYgPSBpbml0X2F0bWVsX2NhcmQocGRl
di0+aXJxLCBwZGV2LT5yZXNvdXJjZVsxXS5zdGFydCwgDQotCQkJICAgICAg
ImF0bWVsX2F0NzZjNTA2JXMuYmluIiwNCisJCQkgICAgICBBVE1FTF9GV19U
WVBFXzUwNiwNCiAJCQkgICAgICAmcGRldi0+ZGV2LCBOVUxMLCBOVUxMKTsN
CiAJaWYgKCFkZXYpDQogCQlyZXR1cm4gLUVOT0RFVjsNCg==

--279707962-801068342-1107129390=:6929--
