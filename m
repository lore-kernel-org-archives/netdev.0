From: Fernando <fernando@syspac.com.br>
Subject: [PATCH] Add basic support for smsc9311 in smsc911x Driver
Date: Tue, 15 Feb 2011 12:57:08 -0200
Message-ID: <20110215125708.79245312@SyspacSw04>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emls0004.whservidor.com ([200.98.199.38]:59753 "EHLO
	emls0004.whservidor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871Ab1BOPCu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 10:02:50 -0500
Received: from SyspacSw04 (200-207-12-95.dsl.telesp.net.br [200.207.12.95])
	(Authenticated sender: fernando@syspac.com.br)
	by emls0004.whservidor.com (Postfix) with ESMTPA id D56AFEB90DA
	for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 12:57:09 -0200 (BRST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The smsc9311 chip is an switch chip with 3 ports that have almost the same
register structure of the LAN9115. There are some differences in IRQ regs,
but that doesn't seem to be a problem right now.

This patch was tested on a Torpedo (OMAP35x) based board and is based on
v2.6.38-rc4.

Fernando

>From e987729802dd3980041fd7e48e68f3a9f53424bd Mon Sep 17 00:00:00 2001
From: Fernando Governatore <fernando@syspac.com.br>
Date: Tue, 15 Feb 2011 12:10:22 -0200
Subject: [PATCH] Add basic support for smsc9311 in smsc911x Driver

  The smsc9311 chip is an switch chip with three ports.
Here is assumed that only the first one is connected to
the host.

  Makes the driver aware of the chip revision id.

  If no external phy is being used, mask out all the PHY
IDs that are not present by default.

  The default switch configuration is not changed.
---
 drivers/net/smc911x.h  |    2 ++
 drivers/net/smsc911x.c |   15 ++++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 3269292..5e336d2 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -687,6 +687,7 @@ smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
 #define CHIP_9215	0x115A
 #define CHIP_9217	0x117A
 #define CHIP_9218	0x118A
+#define CHIP_9311	0x9311
 
 struct chip_id {
 	u16 id;
@@ -702,6 +703,7 @@ static const struct chip_id chip_ids[] =  {
 	{ CHIP_9215, "LAN9215" },
 	{ CHIP_9217, "LAN9217" },
 	{ CHIP_9218, "LAN9218" },
+	{ CHIP_9311, "LAN9311" },
 	{ 0, NULL },
 };
 
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 64bfdae..483fdbd 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -856,6 +856,7 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	case 0x01150000:
 	case 0x117A0000:
 	case 0x115A0000:
+	case 0x93110000:
 		/* External PHY supported, try to autodetect */
 		smsc911x_phy_initialise_external(pdata);
 		break;
@@ -867,8 +868,15 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	}
 
 	if (!pdata->using_extphy) {
-		/* Mask all PHYs except ID 1 (internal) */
-		pdata->mii_bus->phy_mask = ~(1 << 1);
+		/* Mask all PHYs except internal IDs */
+		switch(pdata->idrev & 0xFFFF0000){
+		case 0x93110000:
+			pdata->mii_bus->phy_mask = ~(1 << 0) & ~(1 << 1) & ~(1 << 2);
+			break;
+		default:
+			pdata->mii_bus->phy_mask = ~(1 << 1);
+			break;
+		}
 	}
 
 	if (mdiobus_register(pdata->mii_bus)) {
@@ -1870,7 +1878,8 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	case 0x92110000:
 	case 0x92200000:
 	case 0x92210000:
-		/* LAN9210/LAN9211/LAN9220/LAN9221 */
+	case 0x93110000:
+		/* LAN9210/LAN9211/LAN9220/LAN9221/LAN9311 */
 		pdata->generation = 4;
 		break;
 
-- 
1.7.1

