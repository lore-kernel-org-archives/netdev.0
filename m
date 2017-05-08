From: Alexandru Ardelean <ardeleanalex@gmail.com>
Subject: [PATCH] net/fsl: remove func xgmac_wait_until_free() as duplicate
Date: Mon,  8 May 2017 14:31:18 +0300
Message-ID: <1494243078-17917-1-git-send-email-ardeleanalex@gmail.com>
Cc: Shaohui.Xie@nxp.com, davem@davemloft.net,
        Alexandru Ardelean <ardeleanalex@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36692 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdEHLb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:31:26 -0400
Received: by mail-wr0-f195.google.com with SMTP id v42so7992096wrc.3
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:31:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at xgmac_wait_until_done() and xgmac_wait_until_free()
functions, they seem to have turned out completely identical.

Though, judging from the git history it seems they
initially weren't.

Remove xgmac_wait_until_free() in favor of xgmac_wait_until_done().

Signed-off-by: Alexandru Ardelean <ardeleanalex@gmail.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 33 ++++-------------------------
 1 file changed, 4 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index e03b30c..54597a8 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -71,31 +71,6 @@ static void xgmac_write32(u32 value,
 }
 
 /*
- * Wait until the MDIO bus is free
- */
-static int xgmac_wait_until_free(struct device *dev,
-				 struct tgec_mdio_controller __iomem *regs,
-				 bool is_little_endian)
-{
-	unsigned int timeout;
-
-	/* Wait till the bus is free */
-	timeout = TIMEOUT;
-	while ((xgmac_read32(&regs->mdio_stat, is_little_endian) &
-		MDIO_STAT_BSY) && timeout) {
-		cpu_relax();
-		timeout--;
-	}
-
-	if (!timeout) {
-		dev_err(dev, "timeout waiting for bus to be free\n");
-		return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
-/*
  * Wait till the MDIO read or write operation is complete
  */
 static int xgmac_wait_until_done(struct device *dev,
@@ -147,7 +122,7 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phy_id, int regnum, u16 val
 
 	xgmac_write32(mdio_stat, &regs->mdio_stat, endian);
 
-	ret = xgmac_wait_until_free(&bus->dev, regs, endian);
+	ret = xgmac_wait_until_done(&bus->dev, regs, endian);
 	if (ret)
 		return ret;
 
@@ -159,7 +134,7 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phy_id, int regnum, u16 val
 	if (regnum & MII_ADDR_C45) {
 		xgmac_write32(regnum & 0xffff, &regs->mdio_addr, endian);
 
-		ret = xgmac_wait_until_free(&bus->dev, regs, endian);
+		ret = xgmac_wait_until_done(&bus->dev, regs, endian);
 		if (ret)
 			return ret;
 	}
@@ -201,7 +176,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 
 	xgmac_write32(mdio_stat, &regs->mdio_stat, endian);
 
-	ret = xgmac_wait_until_free(&bus->dev, regs, endian);
+	ret = xgmac_wait_until_done(&bus->dev, regs, endian);
 	if (ret)
 		return ret;
 
@@ -213,7 +188,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 	if (regnum & MII_ADDR_C45) {
 		xgmac_write32(regnum & 0xffff, &regs->mdio_addr, endian);
 
-		ret = xgmac_wait_until_free(&bus->dev, regs, endian);
+		ret = xgmac_wait_until_done(&bus->dev, regs, endian);
 		if (ret)
 			return ret;
 	}
-- 
2.7.4
