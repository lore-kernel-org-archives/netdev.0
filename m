From: Len Remmerswaal <lpri@xs4all.nl>
Subject: Patch in kernel/driver/net/sis900.* to get Sis948 chipset's NIC running
Date: Mon, 06 Jan 2003 02:07:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E18D6BD.7080300@xs4all.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020902030108040609080000"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, submit@bugs.debian.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020902030108040609080000
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Package:  kernel-source-2.2.20
Version 2.2.20-5
Files: driver/net/sis900.*

I have never done any Linux related bug-shooting, so I am not sure 
wether you guys are the right persons to send this to and if it is in 
the right form. The docs seem to point in your direction :-). If not so 
please inform me of the rigth channels.
Also I have not quite set up all the rigth e-mail accounts yet, so I 
would appreciate not to publish my email address, exposing it to spam bots.

When firing up Linux (Debian Woody 3.0 rev 0) on my beatiful new Asus 
P4S8X motherboard (SiS948 chipset), the NIC would not be recognised 
properly, with an ugly message:
"eth0: Error EERPOM read 0xffff".
I found no solutions on the debian support mailing list, so I had a peek 
in the source.
Turns out that the driver sis900.c knows up  to version 0x90, while the 
chipset has a version 0x91 (says lspci).
I gambled that treating version 0x91 as if it were a version 0x90 might 
work. It did.
This is the response I get now, and it works fine for me:

Jan  5 11:32:13 donar kernel: sis900.c: v1.06.09-1  09/28/2001
Jan  5 11:32:13 donar kernel: eth0: SiS 900 PCI Fast Ethernet at 0x9800, 
IRQ 5, 00:e0:06:09:55:66.
Jan  5 11:32:13 donar kernel: eth0: Unknown PHY transceiver found at 
address 1.
Jan  5 11:32:13 donar kernel: eth0: Using transceiver found at address 1 
as default

Please find the patches to do this attached.
I checked the 2.4.18 source: Nothing changed on this detail so things 
should work here too.

I read that I should like test this on 5 different machines and 6 
different configurations before submitting. I do not have such resources.
Hope this helps anyway.

Len Remmerswaal






--------------020902030108040609080000
Content-Type: text/plain;
 name="sis900.c.2_2_10.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sis900.c.2_2_10.patch"

--- sis900.c_original	Fri Nov  2 17:39:07 2001
+++ sis900.c	Mon Jan  6 01:54:32 2003
@@ -18,6 +18,7 @@
    preliminary Rev. 1.0 Jan. 18, 1998
    http://www.sis.com.tw/support/databook.htm
 
+   Rev 1.06.09-1 Jan. 05 2002 Len Remmerswaal update for 948 chipset
    Rev 1.06.09 Sep. 28 2001 Hui-Fen Hsu (hfhsu@sis.com.tw) update for 630ET & workaround for ICS1893 PHY
    Rev 1.06.08 Mar.  2 2001 Hui-Fen Hsu (hfhsu@sis.com.tw) some bug fix & 635M/B support
    Rev 1.06.07 Jan.  8 2001 Lei-Chun Chang added RTL8201 PHY support
@@ -55,7 +56,7 @@
 #include "sis900.h"
 
 static const char *version =
-"sis900.c: v1.06.09  09/28/2001\n";
+"sis900.c: v1.06.09-1  09/28/2001\n";
 
 static int max_interrupt_work = 20;
 static int multicast_filter_limit = 128;
@@ -148,7 +149,7 @@
 #ifdef MODULE
 #if LINUX_VERSION_CODE > 0x20115
 MODULE_AUTHOR("Jim Huang <cmhuang@sis.com.tw>, Ollie Lho <ollie@sis.com.tw>");
-MODULE_DESCRIPTION("SiS 900 PCI Fast Ethernet driver");
+MODULE_DESCRIPTION("SiS 900 PCI Fast Ethernet driver - adapted for Sis948");
 MODULE_PARM(multicast_filter_limit, "i");
 MODULE_PARM(max_interrupt_work, "i");
 MODULE_PARM(debug, "i");
@@ -334,14 +335,14 @@
 	sis_priv->pci_dev = pci_dev;
 	sis_priv->mac = mac;
 
+        /* gambling that version 0x91 will behave as a 0x90 */		
 	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
 	if ( revision == SIS630E_900_REV )
 		ret = sis630e_get_mac_addr(pci_dev, net_dev);
-	else if ((revision > 0x81) && (revision <= 0x90))
+	else if ((revision > 0x81) && (revision <= 0x91 ))
 		ret = sis635_get_mac_addr(pci_dev, net_dev);
 	else
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
-
 	if (ret == 0) {
 		unregister_netdev(net_dev);
 		return NULL;

--------------020902030108040609080000
Content-Type: text/plain;
 name="sis900.h.2_2_10.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sis900.h.2_2_10.patch"

--- sis900.h_original	Fri Nov  2 17:39:07 2001
+++ sis900.h	Tue Dec 31 22:57:17 2002
@@ -10,6 +10,8 @@
  *   http://www.sis.com.tw/support/databook.htm
  */
 
+/* Len R.: Adapted to include sis900 revision ID 0x91 */
+
 /* MAC operationl registers of SiS 7016 and SiS 900 ehternet controller */
 /* The I/O extent, SiS 900 needs 256 bytes of io address */
 #define SIS900_TOTAL_SIZE 0x100
@@ -233,11 +235,14 @@
 	MII_STSSUM_AUTO = 0x0002, MII_STSSUM_SPD  = 0x0001
 };
 
+/* Len R.: New revision SIS963_900_REV added (963 is the chip's name)  */
+
 enum sis900_revision_id {
 	SIS630A_900_REV = 0x80, 	SIS630E_900_REV = 0x81,
 	SIS630S_900_REV = 0x82,		SIS630EA1_900_REV = 0x83,
 	SIS630ET_900_REV = 0x84,        SIS635A_900_REV = 0x90,
-	SIS900B_900_REV = 0x03
+	SIS900B_900_REV = 0x03,         
+	SIS963_900_REV = 0x91
 };
 
 enum sis630_revision_id {

--------------020902030108040609080000--
