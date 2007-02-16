From: akpm@linux-foundation.org
Subject: [patch 2/2] bugfixes and new hardware support for arcnet driver
Date: Fri, 16 Feb 2007 01:42:27 -0800
Message-ID: <200702160942.l1G9gRpM026492@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jmorrow@jmorrow.org, jeff@garzik.org, jmorrow@massspec.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37011 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423525AbXBPJsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 04:48:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Morrow <jmorrow@jmorrow.org>

The modifications and bug fixes noted below were done by Realtime Control
Works and Contemporary Control Systems, Inc, Jan 2005.  They were
incorporated into the 2.6 kernel by Jeff Morrow of Sierra Analytics, Feb
2007.  <jmorrow@massspec.com>

The changes have been tested on a Contemporary Controls PCI20U-4000.

Summary of changes:

Arc-rawmode.c:
      rx():
      - Fixed error in received packet lengths; 256 byte packets were
        being received as 257 bytes packets.

      prepare_tx():
      - Fixed error in transmit length calcs; 257 byte packets were being
        transmitted as 260 byte packets.

com20020.c:
      com20020_check():
      - We now load the SETUP2 register if the 'clockm' parameter is
        non-zero, instead of checking for ARC_CAN_10MBIT. The user is
        now responsible for whether or not SETUP2 is loaded.  If the
        clock multiplier is non-zero, this means that the user wants a
        baud rate greater than 2.5Mbps. This is not possible unless the
        SETUP2 register is present (COM20020D, or COM20022). So, we're
        relying on the user to be smart about what kind of chip he's
        dealing with...

com20020-pci.c
      - Added several entries to com20020pci_id_table[].

Signed-off-by: Jeff Morrow <jmorrow@massspec.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/arcnet/arc-rawmode.c  |    4 ++--
 drivers/net/arcnet/arcnet.c       |    2 +-
 drivers/net/arcnet/com20020-pci.c |    3 +++
 drivers/net/arcnet/com20020.c     |    2 +-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff -puN drivers/net/arcnet/arcnet.c~bugfixes-and-new-hardware-support-for-arcnet-driver drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c~bugfixes-and-new-hardware-support-for-arcnet-driver
+++ a/drivers/net/arcnet/arcnet.c
@@ -41,7 +41,7 @@
  *     <jojo@repas.de>
  */
 
-#define VERSION "arcnet: v3.93 BETA 2000/04/29 - by Avery Pennarun et al.\n"
+#define VERSION "arcnet: v3.94 BETA 2007/02/08 - by Avery Pennarun et al.\n"
 
 #include <linux/module.h>
 #include <linux/types.h>
diff -puN drivers/net/arcnet/arc-rawmode.c~bugfixes-and-new-hardware-support-for-arcnet-driver drivers/net/arcnet/arc-rawmode.c
--- a/drivers/net/arcnet/arc-rawmode.c~bugfixes-and-new-hardware-support-for-arcnet-driver
+++ a/drivers/net/arcnet/arc-rawmode.c
@@ -94,7 +94,7 @@ static void rx(struct net_device *dev, i
 
 	BUGMSG(D_DURING, "it's a raw packet (length=%d)\n", length);
 
-	if (length >= MinTU)
+	if (length > MTU)
 		ofs = 512 - length;
 	else
 		ofs = 256 - length;
@@ -183,7 +183,7 @@ static int prepare_tx(struct net_device 
 		       length, XMTU);
 		length = XMTU;
 	}
-	if (length > MinTU) {
+	if (length >= MinTU) {
 		hard->offset[0] = 0;
 		hard->offset[1] = ofs = 512 - length;
 	} else if (length > MTU) {
diff -puN drivers/net/arcnet/com20020.c~bugfixes-and-new-hardware-support-for-arcnet-driver drivers/net/arcnet/com20020.c
--- a/drivers/net/arcnet/com20020.c~bugfixes-and-new-hardware-support-for-arcnet-driver
+++ a/drivers/net/arcnet/com20020.c
@@ -104,7 +104,7 @@ int com20020_check(struct net_device *de
 	SET_SUBADR(SUB_SETUP1);
 	outb(lp->setup, _XREG);
 
-	if (lp->card_flags & ARC_CAN_10MBIT)
+	if (lp->clockm != 0)
 	{
 		SET_SUBADR(SUB_SETUP2);
 		outb(lp->setup2, _XREG);
diff -puN drivers/net/arcnet/com20020-pci.c~bugfixes-and-new-hardware-support-for-arcnet-driver drivers/net/arcnet/com20020-pci.c
--- a/drivers/net/arcnet/com20020-pci.c~bugfixes-and-new-hardware-support-for-arcnet-driver
+++ a/drivers/net/arcnet/com20020-pci.c
@@ -155,6 +155,7 @@ static struct pci_device_id com20020pci_
 	{ 0x1571, 0xa00b, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
 	{ 0x1571, 0xa00c, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
 	{ 0x1571, 0xa00d, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
+	{ 0x1571, 0xa00e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
 	{ 0x1571, 0xa201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa203, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
@@ -163,6 +164,8 @@ static struct pci_device_id com20020pci_
 	{ 0x1571, 0xa206, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x10B5, 0x9030, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x10B5, 0x9050, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
+	{ 0x14BA, 0x6000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
+	{ 0x10B5, 0x2200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{0,}
 };
 
_
