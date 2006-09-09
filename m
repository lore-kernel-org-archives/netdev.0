From: Paolo <oopla@users.sf.net>
Subject: Realtek r1000 driver
Date: Sat, 9 Sep 2006 17:04:57 +0200
Message-ID: <20060909150457.GA5538@pp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-relay-2.tiscali.it ([213.205.33.42]:49040 "EHLO
	mail-relay-2.tiscali.it") by vger.kernel.org with ESMTP
	id S932251AbWIIPFD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 11:05:03 -0400
Received: from npp (84.222.101.169) by mail-relay-2.tiscali.it (7.3.110.2)
        id 44EEFF60000D7F07 for netdev@vger.kernel.org; Sat, 9 Sep 2006 17:05:01 +0200
Received: from oopla by npp with local (masqmail 0.2.11) id
 1GM4O9-1Uu-00 for <netdev@vger.kernel.org>; Sat, 09 Sep 2006 17:04:57
 +0200
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hello,

I've got a Toshiba A110-262 which comes with an 10ec:8136 ethernet chip,
which turns out to be an Realtek 8101E. Seems no in-kernel driver covers
such chips yet. 

Realtek offers the GPL'd driver r1000, v1.04 at present, but seems it's not
compatible with current 2.6.x kernel at the module param interface.

I've pushed Realtek src in-tree after applying the attached patches. The
r1000 driver now compiles and WFM fine for .16.28, .17.13, .18-rc6-git3.

Hope this helps make them into .18.

-- 
 paolo
 
 GPG/PGP id:0x21426690 kfp:EDFB 0103 A8D8 4180 8AB5  D59E 9771 0F28 2142 6690
 "Indeed, it does come with warranty: it *will* fail."

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="net_Kconfig_r1000.diff"

--- a/drivers/net/Kconfig.17.11	2006-09-06 22:26:23.000000000 +0200
+++ b/drivers/net/Kconfig	2006-09-06 22:24:33.000000000 +0200
@@ -2002,6 +2002,63 @@
 	  
 	  If in doubt, say Y.
 
+config R1000
+	tristate "Realtek support for 8169S/SB/SC 8168B 8101E"
+	depends on PCI
+	---help---
+	  Say Y here if you have a Realtek LAN chip of the family below.
+	  
+	  E.g. the 810x may be identified as 'Unknow device 8136' as
+	  of 2.6.18-rc6, with PCI_ID=10ec:8136, on recent (as of Aug 2006)
+	  Toshiba laptops.  
+
+	  Also, this r1000 may be a better (it's newer at least) choice 
+	  for RTL8169 as well than r8169 above.
+	  
+	  To compile this driver as a module, choose M here: the module
+	  will be called r1000.  This is recommended.
+
+	  == Most relevant excerpt from original README ==
+	  Chips supported:
+	  1. RTL8169S/SB/SC (Gigabit Ethernet with PCI interface)
+	  2. RTL8168B (Gigabit Ethernet with PCI-Express interface)
+	  3. RTL8101E (Fast Ethernet with PCI-Express interface)
+          
+          Advanced feature:
+
+          - Supports Jumbo Frame
+          - Hardware Tx/Rx flow control
+
+	  Force the link status when insert the driver.
+	  If the user is in the path ~/r1000, the link status can be 
+	  forced to one of the 5 modes as following command.
+
+	  #insmod ./src/r1000.ko speed=SPEED_MODE duplex=DUPLEX_MODE 
+	  	autoneg=NWAY_OPTION
+
+	  where
+		SPEED_MODE	= 1000	for 1000Mbps
+				= 100	for 100Mbps
+				= 10	for 10Mbps
+		DUPLEX_MODE	= 0	for half-duplex
+				= 1	for full-duplex
+		NWAY_OPTION	= 0	for auto-negotiation off
+				= 1	for auto-negotiation on
+
+          Force the link status by using ethtool:
+
+	  #ethtool -s eth? speed SPEED_MODE duplex DUPLEX_MODE 
+	  	autoneg NWAY_OPTION
+
+	  where
+		SPEED_MODE	= 1000	for 1000Mbps
+				= 100	for 100Mbps
+				= 10	for 10Mbps
+		DUPLEX_MODE	= half	for half-duplex
+				= full	for full-duplex
+		NWAY_OPTION	= off	for auto-negotiation off
+				= on	for auto-negotiation on
+
 config SIS190
 	tristate "SiS190/SiS191 gigabit ethernet support"
 	depends on PCI

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="net_Makefile_r1000.diff"

--- ../linux-2.6.17/drivers/net/Makefile.17.11	2006-09-06 22:28:38.000000000 +0200
+++ ../linux-2.6.17/drivers/net/Makefile	2006-09-06 22:29:18.000000000 +0200
@@ -145,6 +145,10 @@
 obj-$(CONFIG_3C515) += 3c515.o
 obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
+obj-$(CONFIG_R1000) += r1000.o
+
+r1000-objs := r1000_n.o r1000_ioctl.o
+
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_ZNET) += znet.o

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="net_r1000_n.c.diff"

--- ../modules/r1000_v1.04/src/r1000_n.c	2006-07-07 07:24:09.000000000 +0200
+++ drivers/net/r1000_n.c	2006-09-07 08:55:40.000000000 +0200
@@ -48,9 +48,12 @@
 MODULE_DEVICE_TABLE (pci, r1000_pci_tbl);
 MODULE_AUTHOR ("Realtek");
 MODULE_DESCRIPTION ("Linux device driver for Realtek Ethernet Controllers");
-MODULE_PARM (speed, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM (duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM (autoneg, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM_DESC (speed, "Speed mode: [10,100,1000] Mbps");
+module_param_array (speed, int, NULL, 0444);
+MODULE_PARM_DESC (duplex, "Duplex mode: 0=half, 1=full");
+module_param_array (duplex, int, NULL, 0444);
+MODULE_PARM_DESC (autoneg, "Nway option: [0,1]=auto-negotiation [off,on]");
+module_param_array (autoneg, int, NULL, 0444);
 MODULE_LICENSE("GPL");
 
 

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="pci_ids_r1000.diff"

--- a/include/linux/pci_ids.h	2006-09-06 01:10:38.000000000 +0200
+++ b/include/linux/pci_ids.h	2006-09-06 22:14:23.000000000 +0200
@@ -1198,8 +1187,11 @@
 #define PCI_DEVICE_ID_INTERG_5050	0x5050
 
 #define PCI_VENDOR_ID_REALTEK		0x10ec
-#define PCI_DEVICE_ID_REALTEK_8139	0x8139
 #define PCI_DEVICE_ID_REALTEK_8136	0x8136
+#define PCI_DEVICE_ID_REALTEK_8139	0x8139
+#define PCI_DEVICE_ID_REALTEK_8167	0x8167
+#define PCI_DEVICE_ID_REALTEK_8168	0x8168
+#define PCI_DEVICE_ID_REALTEK_8169	0x8169
 
 #define PCI_VENDOR_ID_XILINX		0x10ee
 #define PCI_DEVICE_ID_RME_DIGI96	0x3fc0

--TB36FDmn/VVEgNH/--
