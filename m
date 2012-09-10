From: Alexander Sverdlin <asv@sysgo.com>
Subject: [PATCH] Generalise "auto-negotiation done" function, move generic
 PHY code to phy_device.c
Date: Mon, 10 Sep 2012 13:30:01 +0200
Message-ID: <504DCF39.3000704@sysgo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexander Sverdlin <alexander.sverdlin.ext@nsn.com>
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sysgo.com ([176.9.26.183]:48687 "EHLO mail1.sysgo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757433Ab2IJLjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 07:39:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <alexander.sverdlin@sysgo.com>

Generalise "auto-negotiation done" function, move generic PHY code to phy_device.c 

Not all devices have "auto-negotiation done" bit at the place, as expected by
phy_aneg_done() in phy.c. Example of such device is Marvell 88E61xx Ethernet 
switch which could be controlled by Linux PHY layer, if struct phy_driver had
abstraction for above function. So move hardware-dependent implementation details
for "generic" PHY to phy_device.c, and modify all PHY drivers to use new field.
Now phy.c contains only high-level state-machine functionality, leaving 
hardware-layer to different drivers.

Signed-off-by: Alexander Sverdlin <alexander.sverdlin@sysgo.com>
---
diff -uprN linux-3.6-rc4.orig/Documentation/networking/phy.txt linux-3.6-rc4/Documentation/networking/phy.txt
--- linux-3.6-rc4.orig/Documentation/networking/phy.txt	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/Documentation/networking/phy.txt	2012-09-10 10:54:52.000000000 +0200
@@ -1,7 +1,7 @@
 
 -------
 PHY Abstraction Layer
-(Updated 2008-04-08)
+(Updated 2012-09-06)
 
 Purpose
 
@@ -257,15 +257,16 @@ Writing a PHY driver
    probe: Does any setup needed by the driver
    suspend/resume: power management
    config_aneg: Changes the speed/duplex/negotiation settings
+   aneg_done: Reads current auto-negotiation state
    read_status: Reads the current speed/duplex/negotiation settings
    ack_interrupt: Clear a pending interrupt
    config_intr: Enable or disable interrupts
    remove: Does any driver take-down
 
- Of these, only config_aneg and read_status are required to be
+ Of these, only config_aneg, aneg_done and read_status are required to be
  assigned by the driver code.  The rest are optional.  Also, it is
- preferred to use the generic phy driver's versions of these two
- functions if at all possible: genphy_read_status and
+ preferred to use the generic phy driver's versions of these three
+ functions if at all possible: genphy_read_status, genphy_aneg_done and
  genphy_config_aneg.  If this is not possible, it is likely that
  you only need to perform some actions before and after invoking
  these functions, and so your functions will wrap the generic
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/amd.c linux-3.6-rc4/drivers/net/phy/amd.c
--- linux-3.6-rc4.orig/drivers/net/phy/amd.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/amd.c	2012-09-10 11:04:35.000000000 +0200
@@ -69,6 +69,7 @@ static struct phy_driver am79c_driver = 
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= am79c_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= am79c_ack_interrupt,
 	.config_intr	= am79c_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/bcm63xx.c linux-3.6-rc4/drivers/net/phy/bcm63xx.c
--- linux-3.6-rc4.orig/drivers/net/phy/bcm63xx.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/bcm63xx.c	2012-09-10 11:10:04.000000000 +0200
@@ -81,6 +81,7 @@ static struct phy_driver bcm63xx_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= bcm63xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm63xx_ack_interrupt,
 	.config_intr	= bcm63xx_config_intr,
@@ -94,6 +95,7 @@ static struct phy_driver bcm63xx_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= bcm63xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm63xx_ack_interrupt,
 	.config_intr	= bcm63xx_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/bcm87xx.c linux-3.6-rc4/drivers/net/phy/bcm87xx.c
--- linux-3.6-rc4.orig/drivers/net/phy/bcm87xx.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/bcm87xx.c	2012-09-10 11:10:59.000000000 +0200
@@ -195,6 +195,7 @@ static struct phy_driver bcm87xx_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= bcm87xx_config_init,
 	.config_aneg	= bcm87xx_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= bcm87xx_read_status,
 	.ack_interrupt	= bcm87xx_ack_interrupt,
 	.config_intr	= bcm87xx_config_intr,
@@ -208,6 +209,7 @@ static struct phy_driver bcm87xx_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= bcm87xx_config_init,
 	.config_aneg	= bcm87xx_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= bcm87xx_read_status,
 	.ack_interrupt	= bcm87xx_ack_interrupt,
 	.config_intr	= bcm87xx_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/broadcom.c linux-3.6-rc4/drivers/net/phy/broadcom.c
--- linux-3.6-rc4.orig/drivers/net/phy/broadcom.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/broadcom.c	2012-09-10 11:09:49.000000000 +0200
@@ -692,6 +692,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -705,6 +706,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -718,6 +720,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -731,6 +734,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -744,6 +748,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= bcm5481_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -757,6 +762,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm5482_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -770,6 +776,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -783,6 +790,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -796,6 +804,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -809,6 +818,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= brcm_fet_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
@@ -822,6 +832,7 @@ static struct phy_driver broadcom_driver
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= brcm_fet_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= brcm_fet_ack_interrupt,
 	.config_intr	= brcm_fet_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/cicada.c linux-3.6-rc4/drivers/net/phy/cicada.c
--- linux-3.6-rc4.orig/drivers/net/phy/cicada.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/cicada.c	2012-09-10 11:06:41.000000000 +0200
@@ -111,6 +111,7 @@ static struct phy_driver cis820x_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &cis820x_config_init,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
@@ -123,6 +124,7 @@ static struct phy_driver cis820x_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &cis820x_config_init,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/davicom.c linux-3.6-rc4/drivers/net/phy/davicom.c
--- linux-3.6-rc4.orig/drivers/net/phy/davicom.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/davicom.c	2012-09-10 11:05:54.000000000 +0200
@@ -152,6 +152,7 @@ static struct phy_driver dm91xx_driver[]
 	.features	= PHY_BASIC_FEATURES,
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
@@ -161,6 +162,7 @@ static struct phy_driver dm91xx_driver[]
 	.features	= PHY_BASIC_FEATURES,
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
@@ -170,6 +172,7 @@ static struct phy_driver dm91xx_driver[]
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/dp83640.c linux-3.6-rc4/drivers/net/phy/dp83640.c
--- linux-3.6-rc4.orig/drivers/net/phy/dp83640.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/dp83640.c	2012-09-10 11:10:16.000000000 +0200
@@ -1257,6 +1257,7 @@ static struct phy_driver dp83640_driver 
 	.probe		= dp83640_probe,
 	.remove		= dp83640_remove,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ts_info	= dp83640_ts_info,
 	.hwtstamp	= dp83640_hwtstamp,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/et1011c.c linux-3.6-rc4/drivers/net/phy/et1011c.c
--- linux-3.6-rc4.orig/drivers/net/phy/et1011c.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/et1011c.c	2012-09-10 11:04:08.000000000 +0200
@@ -94,6 +94,7 @@ static struct phy_driver et1011c_driver 
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_1000baseT_Full),
 	.flags		= PHY_POLL,
 	.config_aneg	= et1011c_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= et1011c_read_status,
 	.driver 	= { .owner = THIS_MODULE,},
 };
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/icplus.c linux-3.6-rc4/drivers/net/phy/icplus.c
--- linux-3.6-rc4.orig/drivers/net/phy/icplus.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/icplus.c	2012-09-10 11:05:27.000000000 +0200
@@ -210,6 +210,7 @@ static struct phy_driver icplus_driver[]
 	.features	= PHY_BASIC_FEATURES,
 	.config_init	= &ip175c_config_init,
 	.config_aneg	= &ip175c_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &ip175c_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
@@ -222,6 +223,7 @@ static struct phy_driver icplus_driver[]
 			  SUPPORTED_Asym_Pause,
 	.config_init	= &ip1001_config_init,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
@@ -236,6 +238,7 @@ static struct phy_driver icplus_driver[]
 	.ack_interrupt	= ip101a_g_ack_interrupt,
 	.config_init	= &ip101a_g_config_init,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/lxt.c linux-3.6-rc4/drivers/net/phy/lxt.c
--- linux-3.6-rc4.orig/drivers/net/phy/lxt.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/lxt.c	2012-09-10 11:06:12.000000000 +0200
@@ -158,6 +158,7 @@ static struct phy_driver lxt97x_driver[]
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= lxt970_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
@@ -169,6 +170,7 @@ static struct phy_driver lxt97x_driver[]
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
@@ -181,6 +183,7 @@ static struct phy_driver lxt97x_driver[]
 	.flags		= 0,
 	.probe		= lxt973_probe,
 	.config_aneg	= lxt973_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.driver		= { .owner = THIS_MODULE,},
 } };
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/marvell.c linux-3.6-rc4/drivers/net/phy/marvell.c
--- linux-3.6-rc4.orig/drivers/net/phy/marvell.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/marvell.c	2012-09-10 11:07:30.000000000 +0200
@@ -713,6 +713,7 @@ static struct phy_driver marvell_drivers
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.config_aneg = &marvell_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -726,6 +727,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -739,6 +741,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -752,6 +755,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1118_config_init,
 		.config_aneg = &m88e1118_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -764,6 +768,7 @@ static struct phy_driver marvell_drivers
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.config_aneg = &m88e1121_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -777,6 +782,7 @@ static struct phy_driver marvell_drivers
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.config_aneg = &m88e1318_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -791,6 +797,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1145_config_init,
 		.config_aneg = &marvell_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -804,6 +811,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1149_config_init,
 		.config_aneg = &m88e1118_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
@@ -817,6 +825,7 @@ static struct phy_driver marvell_drivers
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
+		.aneg_done = genphy_aneg_done,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/micrel.c linux-3.6-rc4/drivers/net/phy/micrel.c
--- linux-3.6-rc4.orig/drivers/net/phy/micrel.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/micrel.c	2012-09-10 11:07:55.000000000 +0200
@@ -123,6 +123,7 @@ static struct phy_driver ksphy_driver[] 
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ks8737_config_intr,
@@ -136,6 +137,7 @@ static struct phy_driver ksphy_driver[] 
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
@@ -149,6 +151,7 @@ static struct phy_driver ksphy_driver[] 
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= ks8051_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
@@ -161,6 +164,7 @@ static struct phy_driver ksphy_driver[] 
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
@@ -174,6 +178,7 @@ static struct phy_driver ksphy_driver[] 
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= ksz9021_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/national.c linux-3.6-rc4/drivers/net/phy/national.c
--- linux-3.6-rc4.orig/drivers/net/phy/national.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/national.c	2012-09-10 11:08:27.000000000 +0200
@@ -137,6 +137,7 @@ static struct phy_driver dp83865_driver 
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ns_config_init,
 	.config_aneg = genphy_config_aneg,
+	.aneg_done = genphy_aneg_done,
 	.read_status = genphy_read_status,
 	.ack_interrupt = ns_ack_interrupt,
 	.config_intr = ns_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/phy.c linux-3.6-rc4/drivers/net/phy/phy.c
--- linux-3.6-rc4.orig/drivers/net/phy/phy.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/phy.c	2012-09-10 11:24:18.000000000 +0200
@@ -95,24 +95,6 @@ static int phy_config_interrupt(struct p
 	return err;
 }
 
-
-/**
- * phy_aneg_done - return auto-negotiation status
- * @phydev: target phy_device struct
- *
- * Description: Reads the status register and returns 0 either if
- *   auto-negotiation is incomplete, or if there was an error.
- *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
- */
-static inline int phy_aneg_done(struct phy_device *phydev)
-{
-	int retval;
-
-	retval = phy_read(phydev, MII_BMSR);
-
-	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
-}
-
 /* A structure for mapping a particular speed and duplex
  * combination to a particular SUPPORTED and ADVERTISED value */
 struct phy_setting {
@@ -807,7 +789,7 @@ void phy_state_machine(struct work_struc
 
 			/* Check if negotiation is done.  Break
 			 * if there's an error */
-			err = phy_aneg_done(phydev);
+			err = phydev->drv->aneg_done(phydev);
 			if (err < 0)
 				break;
 
@@ -921,7 +903,7 @@ void phy_state_machine(struct work_struc
 				break;
 
 			if (AUTONEG_ENABLE == phydev->autoneg) {
-				err = phy_aneg_done(phydev);
+				err = phydev->drv->aneg_done(phydev);
 				if (err < 0)
 					break;
 
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/phy_device.c linux-3.6-rc4/drivers/net/phy/phy_device.c
--- linux-3.6-rc4.orig/drivers/net/phy/phy_device.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/phy_device.c	2012-09-06 15:00:32.000000000 +0200
@@ -785,6 +785,23 @@ int genphy_config_aneg(struct phy_device
 EXPORT_SYMBOL(genphy_config_aneg);
 
 /**
+ * genphy_aneg_done - return auto-negotiation status
+ * @phydev: target phy_device struct
+ *
+ * Description: Reads the status register and returns positive value if
+ * auto-negotiation is complete, 0 if incomplete and negative on failure.
+ */
+int genphy_aneg_done(struct phy_device *phydev)
+{
+	int retval;
+
+	retval = phy_read(phydev, MII_BMSR);
+
+	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
+}
+EXPORT_SYMBOL(genphy_aneg_done);
+
+/**
  * genphy_update_link - update link status in @phydev
  * @phydev: target phy_device struct
  *
@@ -1117,6 +1134,7 @@ static struct phy_driver genphy_driver =
 	.config_init	= genphy_config_init,
 	.features	= 0,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/qsemi.c linux-3.6-rc4/drivers/net/phy/qsemi.c
--- linux-3.6-rc4.orig/drivers/net/phy/qsemi.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/qsemi.c	2012-09-10 11:11:08.000000000 +0200
@@ -119,6 +119,7 @@ static struct phy_driver qs6612_driver =
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= qs6612_config_init,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= qs6612_ack_interrupt,
 	.config_intr	= qs6612_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/realtek.c linux-3.6-rc4/drivers/net/phy/realtek.c
--- linux-3.6-rc4.orig/drivers/net/phy/realtek.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/realtek.c	2012-09-10 11:11:49.000000000 +0200
@@ -57,6 +57,7 @@ static struct phy_driver rtl821x_driver 
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &rtl821x_ack_interrupt,
 	.config_intr	= &rtl821x_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/smsc.c linux-3.6-rc4/drivers/net/phy/smsc.c
--- linux-3.6-rc4.orig/drivers/net/phy/smsc.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/smsc.c	2012-09-10 11:11:35.000000000 +0200
@@ -73,6 +73,7 @@ static struct phy_driver smsc_phy_driver
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
@@ -95,6 +96,7 @@ static struct phy_driver smsc_phy_driver
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
@@ -117,6 +119,7 @@ static struct phy_driver smsc_phy_driver
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
@@ -139,6 +142,7 @@ static struct phy_driver smsc_phy_driver
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.config_init	= lan911x_config_init,
 
@@ -161,6 +165,7 @@ static struct phy_driver smsc_phy_driver
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.config_init	= smsc_phy_config_init,
 
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/ste10Xp.c linux-3.6-rc4/drivers/net/phy/ste10Xp.c
--- linux-3.6-rc4.orig/drivers/net/phy/ste10Xp.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/ste10Xp.c	2012-09-10 11:10:37.000000000 +0200
@@ -90,6 +90,7 @@ static struct phy_driver ste10xp_pdriver
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ste10Xp_config_init,
 	.config_aneg = genphy_config_aneg,
+	.aneg_done = genphy_aneg_done,
 	.read_status = genphy_read_status,
 	.ack_interrupt = ste10Xp_ack_interrupt,
 	.config_intr = ste10Xp_config_intr,
@@ -104,6 +105,7 @@ static struct phy_driver ste10xp_pdriver
 	.flags = PHY_HAS_INTERRUPT,
 	.config_init = ste10Xp_config_init,
 	.config_aneg = genphy_config_aneg,
+	.aneg_done = genphy_aneg_done,
 	.read_status = genphy_read_status,
 	.ack_interrupt = ste10Xp_ack_interrupt,
 	.config_intr = ste10Xp_config_intr,
diff -uprN linux-3.6-rc4.orig/drivers/net/phy/vitesse.c linux-3.6-rc4/drivers/net/phy/vitesse.c
--- linux-3.6-rc4.orig/drivers/net/phy/vitesse.c	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/drivers/net/phy/vitesse.c	2012-09-10 11:06:28.000000000 +0200
@@ -160,6 +160,7 @@ static struct phy_driver vsc82xx_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
@@ -173,6 +174,7 @@ static struct phy_driver vsc82xx_driver[
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc8221_config_init,
 	.config_aneg	= &genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
diff -uprN linux-3.6-rc4.orig/include/linux/phy.h linux-3.6-rc4/include/linux/phy.h
--- linux-3.6-rc4.orig/include/linux/phy.h	2012-09-01 19:39:58.000000000 +0200
+++ linux-3.6-rc4/include/linux/phy.h	2012-09-06 15:06:40.000000000 +0200
@@ -369,8 +369,8 @@ struct phy_device {
  * flags: A bitfield defining certain other features this PHY
  *   supports (like interrupts)
  *
- * The drivers must implement config_aneg and read_status.  All
- * other functions are optional. Note that none of these
+ * The drivers must implement config_aneg, aneg_done  and read_status.
+ * All other functions are optional. Note that none of these
  * functions should be called from interrupt time.  The goal is
  * for the bus read/write functions to be able to block when the
  * bus transaction is happening, and be freed up by an interrupt
@@ -408,6 +408,13 @@ struct phy_driver {
 	 */
 	int (*config_aneg)(struct phy_device *phydev);
 
+	/*
+	 * Reads auto-negotiation status. Returns positive value if
+	 * auto-negotiation is complete, 0 if incomplete and negative
+	 * value on error
+	 */
+	int (*aneg_done)(struct phy_device *phydev);
+
 	/* Determines the negotiated speed and duplex */
 	int (*read_status)(struct phy_device *phydev);
 
@@ -528,6 +535,7 @@ static inline int phy_read_status(struct
 
 int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
+int genphy_aneg_done(struct phy_device *phydev);
 int genphy_update_link(struct phy_device *phydev);
 int genphy_read_status(struct phy_device *phydev);
 int genphy_suspend(struct phy_device *phydev);


-- 
Best regards,
Alexander Sverdlin.
