From: Brice Goglin <brice@myri.com>
Subject: [PATCH 06/16] myri10ge: report FIBER in ethtool for XFP based NIC
Date: Fri, 09 May 2008 02:18:24 +0200
Message-ID: <48239850.5050900@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763485AbYEIAqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:19 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ethtool report FIBER for XFP based NIC's port type.
Don't bother to poke around and try to find out what is in
the XFP cage, since Linux does not have separate media types
for -SR -LR, etc.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:04:07.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:04:48.000000000 +0200
@@ -205,6 +205,7 @@
 	int pause;
 	char *fw_name;
 	char eeprom_strings[MYRI10GE_EEPROM_STRINGS_SIZE];
+	char *product_code_string;
 	char fw_version[128];
 	int fw_ver_major;
 	int fw_ver_minor;
@@ -421,6 +422,10 @@
 				ptr += 1;
 			}
 		}
+		if (memcmp(ptr, "PC=", 3) == 0) {
+			ptr += 3;
+			mgp->product_code_string = ptr;
+		}
 		if (memcmp((const void *)ptr, "SN=", 3) == 0) {
 			ptr += 3;
 			mgp->serial_number = simple_strtoul(ptr, &ptr, 10);
@@ -1304,9 +1309,39 @@
 static int
 myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	char *ptr;
+	int i;
+
 	cmd->autoneg = AUTONEG_DISABLE;
 	cmd->speed = SPEED_10000;
 	cmd->duplex = DUPLEX_FULL;
+
+	/*
+	 * parse the product code to deterimine the interface type
+	 * (CX4, XFP, Quad Ribbon Fiber) by looking at the character
+	 * after the 3rd dash in the driver's cached copy of the
+	 * EEPROM's product code string.
+	 */
+	ptr = mgp->product_code_string;
+	if (ptr == NULL) {
+		printk(KERN_ERR "myri10ge: %s: Missing product code\n",
+			netdev->name);
+		return 0;
+	}
+	for (i = 0; i < 3; i++, ptr++) {
+		ptr = strchr(ptr, '-');
+		if (ptr == NULL) {
+			printk(KERN_ERR "myri10ge: %s: Invalid product "
+			       "code %s\n", netdev->name,
+			       mgp->product_code_string);
+			return 0;
+		}
+	}
+	if (*ptr == 'R' || *ptr == 'Q') {
+		/* We've found either an XFP or quad ribbon fiber */
+		cmd->port = PORT_FIBRE;
+	}
 	return 0;
 }
 


