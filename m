From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: [PATCH 2.6.23.12] net/bonding: option to specify initial bond interface number
Date: Wed, 2 Jan 2008 16:20:48 -0500
Message-ID: <413FEEF1743111439393FB76D0221E4809790942@leopard.zoo.q9networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.q9.com ([216.220.35.252]:53251 "EHLO mx3.q9.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbYABVih convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 16:38:37 -0500
Received: from leopard.zoo.q9networks.com (unknown [10.220.34.6])
	by mx3.q9.com (Postfix) with ESMTP id 7788214A
	for <netdev@vger.kernel.org>; Wed,  2 Jan 2008 16:20:49 -0500 (EST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the user to specify an initial interface number when loading the bonding driver. This is useful when loading multiple instances of the bonding driver and you want to control the interface number assignment. For example, if the user wishes to create a bond5 interface they can type 'modprobe -o bond5 bonding ifnum=5'. It also works with the max_bonds option.

Signed-off-by: Jari Takkala <jari.takkala@q9.com>
---
diff -ruN linux-2.6.23.12.orig/drivers/net/bonding/bond_main.c linux-2.6.23.12/drivers/net/bonding/bond_main.c
--- linux-2.6.23.12.orig/drivers/net/bonding/bond_main.c	2007-12-18 16:55:57.000000000 -0500
+++ linux-2.6.23.12/drivers/net/bonding/bond_main.c	2008-01-02 14:49:37.000000000 -0500
@@ -85,6 +85,7 @@
 #define BOND_LINK_MON_INTERV	0
 #define BOND_LINK_ARP_INTERV	0
 
+static int ifnum	= BOND_DEFAULT_IFNUM;
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
@@ -99,6 +100,8 @@
 static char *arp_validate = NULL;
 struct bond_params bonding_defaults;
 
+module_param(ifnum, int, 0);
+MODULE_PARM_DESC(ifnum, "Initial interface number to assign");
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(miimon, int, 0);
@@ -4388,6 +4391,14 @@
 		}
 	}
 
+	if (ifnum < 0 || ifnum > INT_MAX) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: ifnum (%d) not in range %d-%d, so it "
+		       "was reset to BOND_DEFAULT_IFNUM (%d)\n",
+		       ifnum, 0, INT_MAX, BOND_DEFAULT_IFNUM);
+		ifnum = BOND_DEFAULT_IFNUM;
+	}
+
 	if (max_bonds < 1 || max_bonds > INT_MAX) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
@@ -4703,6 +4714,7 @@
 {
 	int i;
 	int res;
+	char ifname[16];
 
 	printk(KERN_INFO "%s", version);
 
@@ -4715,7 +4727,13 @@
 	bond_create_proc_dir();
 #endif
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL, &bonding_defaults, NULL);
+		if (ifnum != BOND_DEFAULT_IFNUM) {
+			ifnum = ifnum + i;
+			snprintf(ifname, sizeof(ifname) - 1, "bond%d", ifnum);
+			res = bond_create(ifname, &bonding_defaults, NULL);
+		} else {
+			res = bond_create(NULL, &bonding_defaults, NULL);
+		}
 		if (res)
 			goto err;
 	}
diff -ruN linux-2.6.23.12.orig/include/linux/if_bonding.h linux-2.6.23.12/include/linux/if_bonding.h
--- linux-2.6.23.12.orig/include/linux/if_bonding.h	2007-12-18 16:55:57.000000000 -0500
+++ linux-2.6.23.12/include/linux/if_bonding.h	2008-01-02 13:30:18.000000000 -0500
@@ -81,6 +81,7 @@
 #define BOND_STATE_ACTIVE       0   /* link is active */
 #define BOND_STATE_BACKUP       1   /* link is backup */
 
+#define BOND_DEFAULT_IFNUM	0   /* Default interface number */
 #define BOND_DEFAULT_MAX_BONDS  1   /* Default maximum number of devices to support */
 
 /* hashing types */

