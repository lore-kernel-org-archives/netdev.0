From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] tulip : fix 21142 with 10Mbps without negotiation
Date: Tue, 27 Jan 2009 17:57:27 +0100
Message-ID: <20090127165727.GA25748@frolo.macqel>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:56606 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016AbZA0Q5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:57:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.macqel.be (Postfix) with ESMTP id C2448130E18
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 17:57:29 +0100 (CET)
Received: from mail.macqel.be ([127.0.0.1])
	by localhost (mail.macqel.be [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yu4FFPo8hO4i for <netdev@vger.kernel.org>;
	Tue, 27 Jan 2009 17:57:27 +0100 (CET)
Received: from frolo.macqel.be (frolo.macqel [10.1.40.73])
	by mail.macqel.be (Postfix) with ESMTP id 80031130E09
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 17:57:27 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello list

with current kernels, tulip 21142 ethernet controllers fail to connect
to a 10Mbps only (i.e. without negotiation-partner) network.  It used
to work in 2.4 kernels.  Fix that.  Tested on a 21142 Rev 0x11.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>

diff -r 4e8869c1d518 drivers/net/tulip/21142.c
--- a/drivers/net/tulip/21142.c	Sat Jan 17 23:00:27 2009 +0000
+++ b/drivers/net/tulip/21142.c	Tue Jan 27 16:44:04 2009 +0100
@@ -9,6 +9,11 @@
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
 	for more information on this driver.
+
+	DC21143 manual "21143 PCI/CardBus 10/100Mb/s Ethernet LAN Controller
+	Hardware Reference Manual" is currently available at
+	http://developer.intel.com/design/network/manuals/278074.htm
+	
 	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
@@ -32,7 +37,11 @@ void t21142_media_task(struct work_struc
 	int csr12 = ioread32(ioaddr + CSR12);
 	int next_tick = 60*HZ;
 	int new_csr6 = 0;
-
+	int csr14 = ioread32(ioaddr + CSR14);
+
+	/* CSR12[LS10,LS100] are not reliable during autonegotiation */
+	if ((csr14 & 0x80) && (csr12 & 0x7000) != 0x5000)
+		csr12 |= 6;
 	if (tulip_debug > 2)
 		printk(KERN_INFO"%s: 21143 negotiation status %8.8x, %s.\n",
 			   dev->name, csr12, medianame[dev->if_port]);
@@ -76,7 +85,7 @@ void t21142_media_task(struct work_struc
 			new_csr6 = 0x83860000;
 			dev->if_port = 3;
 			iowrite32(0, ioaddr + CSR13);
-			iowrite32(0x0003FF7F, ioaddr + CSR14);
+			iowrite32(0x0003FFFF, ioaddr + CSR14);
 			iowrite16(8, ioaddr + CSR15);
 			iowrite32(1, ioaddr + CSR13);
 		}
@@ -132,10 +141,14 @@ void t21142_lnk_change(struct net_device
 	struct tulip_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->base_addr;
 	int csr12 = ioread32(ioaddr + CSR12);
-
+	int csr14 = ioread32(ioaddr + CSR14);
+
+	/* CSR12[LS10,LS100] are not reliable during autonegotiation */
+	if ((csr14 & 0x80) && (csr12 & 0x7000) != 0x5000)
+		csr12 |= 6;
 	if (tulip_debug > 1)
 		printk(KERN_INFO"%s: 21143 link status interrupt %8.8x, CSR5 %x, "
-			   "%8.8x.\n", dev->name, csr12, csr5, ioread32(ioaddr + CSR14));
+			   "%8.8x.\n", dev->name, csr12, csr5, csr14);
 
 	/* If NWay finished and we have a negotiated partner capability. */
 	if (tp->nway  &&  !tp->nwayset  &&  (csr12 & 0x7000) == 0x5000) {
@@ -143,7 +156,9 @@ void t21142_lnk_change(struct net_device
 		int negotiated = tp->sym_advertise & (csr12 >> 16);
 		tp->lpar = csr12 >> 16;
 		tp->nwayset = 1;
-		if (negotiated & 0x0100)		dev->if_port = 5;
+		/* If partner cannot negotiate, it is 10Mbps Half Duplex */
+		if (!(csr12 & 0x8000))		dev->if_port = 0;
+		else if (negotiated & 0x0100)	dev->if_port = 5;
 		else if (negotiated & 0x0080)	dev->if_port = 3;
 		else if (negotiated & 0x0040)	dev->if_port = 4;
 		else if (negotiated & 0x0020)	dev->if_port = 0;
@@ -214,7 +229,7 @@ void t21142_lnk_change(struct net_device
 			tp->timer.expires = RUN_AT(3*HZ);
 			add_timer(&tp->timer);
 		} else if (dev->if_port == 5)
-			iowrite32(ioread32(ioaddr + CSR14) & ~0x080, ioaddr + CSR14);
+			iowrite32(csr14 & ~0x080, ioaddr + CSR14);
 	} else if (dev->if_port == 0  ||  dev->if_port == 4) {
 		if ((csr12 & 4) == 0)
 			printk(KERN_INFO"%s: 21143 10baseT link beat good.\n",

--gBBFr7Ir9EOA20Yy
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="dc21143-nonegotiation.diff"

diff -r 4e8869c1d518 drivers/net/tulip/21142.c
--- a/drivers/net/tulip/21142.c	Sat Jan 17 23:00:27 2009 +0000
+++ b/drivers/net/tulip/21142.c	Tue Jan 27 16:44:04 2009 +0100
@@ -9,6 +9,11 @@
 
 	Please refer to Documentation/DocBook/tulip-user.{pdf,ps,html}
 	for more information on this driver.
+
+	DC21143 manual "21143 PCI/CardBus 10/100Mb/s Ethernet LAN Controller
+	Hardware Reference Manual" is currently available at :
+	http://developer.intel.com/design/network/manuals/278074.htm
+	
 	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
@@ -32,7 +37,11 @@ void t21142_media_task(struct work_struc
 	int csr12 = ioread32(ioaddr + CSR12);
 	int next_tick = 60*HZ;
 	int new_csr6 = 0;
-
+	int csr14 = ioread32(ioaddr + CSR14);
+
+	/* CSR12[LS10,LS100] are not reliable during autonegotiation */
+	if ((csr14 & 0x80) && (csr12 & 0x7000) != 0x5000)
+		csr12 |= 6;
 	if (tulip_debug > 2)
 		printk(KERN_INFO"%s: 21143 negotiation status %8.8x, %s.\n",
 			   dev->name, csr12, medianame[dev->if_port]);
@@ -76,7 +85,7 @@ void t21142_media_task(struct work_struc
 			new_csr6 = 0x83860000;
 			dev->if_port = 3;
 			iowrite32(0, ioaddr + CSR13);
-			iowrite32(0x0003FF7F, ioaddr + CSR14);
+			iowrite32(0x0003FFFF, ioaddr + CSR14);
 			iowrite16(8, ioaddr + CSR15);
 			iowrite32(1, ioaddr + CSR13);
 		}
@@ -132,10 +141,14 @@ void t21142_lnk_change(struct net_device
 	struct tulip_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->base_addr;
 	int csr12 = ioread32(ioaddr + CSR12);
-
+	int csr14 = ioread32(ioaddr + CSR14);
+
+	/* CSR12[LS10,LS100] are not reliable during autonegotiation */
+	if ((csr14 & 0x80) && (csr12 & 0x7000) != 0x5000)
+		csr12 |= 6;
 	if (tulip_debug > 1)
 		printk(KERN_INFO"%s: 21143 link status interrupt %8.8x, CSR5 %x, "
-			   "%8.8x.\n", dev->name, csr12, csr5, ioread32(ioaddr + CSR14));
+			   "%8.8x.\n", dev->name, csr12, csr5, csr14);
 
 	/* If NWay finished and we have a negotiated partner capability. */
 	if (tp->nway  &&  !tp->nwayset  &&  (csr12 & 0x7000) == 0x5000) {
@@ -143,7 +156,9 @@ void t21142_lnk_change(struct net_device
 		int negotiated = tp->sym_advertise & (csr12 >> 16);
 		tp->lpar = csr12 >> 16;
 		tp->nwayset = 1;
-		if (negotiated & 0x0100)		dev->if_port = 5;
+		/* If partner cannot negotiate, it is 10Mbps Half Duplex */
+		if (!(csr12 & 0x8000))		dev->if_port = 0;
+		else if (negotiated & 0x0100)	dev->if_port = 5;
 		else if (negotiated & 0x0080)	dev->if_port = 3;
 		else if (negotiated & 0x0040)	dev->if_port = 4;
 		else if (negotiated & 0x0020)	dev->if_port = 0;
@@ -214,7 +229,7 @@ void t21142_lnk_change(struct net_device
 			tp->timer.expires = RUN_AT(3*HZ);
 			add_timer(&tp->timer);
 		} else if (dev->if_port == 5)
-			iowrite32(ioread32(ioaddr + CSR14) & ~0x080, ioaddr + CSR14);
+			iowrite32(csr14 & ~0x080, ioaddr + CSR14);
 	} else if (dev->if_port == 0  ||  dev->if_port == 4) {
 		if ((csr12 & 4) == 0)
 			printk(KERN_INFO"%s: 21143 10baseT link beat good.\n",

--gBBFr7Ir9EOA20Yy--
