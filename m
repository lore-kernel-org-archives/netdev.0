From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 1/2] net: smsc911x: Fix bug where PHY interrupts are overwritten by 0
Date: Thu, 16 Jun 2016 10:54:30 -0500
Message-ID: <1466092470-20958-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:44792 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbcFPPyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 11:54:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, mdiobus_alloc() sets the PHY's to polling mode, but a
pointer size memcpy means that couple IRQs (depending
on 32-bit or 64-bit kernels) end up being overwritten with
a value of 0. This means that PHY_POLL is disabled and results
in unpredictable behavior depending on the PHYs location on the mdio
bus. Remove that memcpy and the now unused phy_irq member to force
SMSC911x PHY's into polling mode 100% of the time.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8af2556..b5ab5e1 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -116,7 +116,6 @@ struct smsc911x_data {
 
 	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
-	int phy_irq[PHY_MAX_ADDR];
 	unsigned int using_extphy;
 	int last_duplex;
 	int last_carrier;
@@ -1073,7 +1072,6 @@ static int smsc911x_mii_init(struct platform_device *pdev,
 	pdata->mii_bus->priv = pdata;
 	pdata->mii_bus->read = smsc911x_mii_read;
 	pdata->mii_bus->write = smsc911x_mii_write;
-	memcpy(pdata->mii_bus->irq, pdata->phy_irq, sizeof(pdata->mii_bus));
 
 	pdata->mii_bus->parent = &pdev->dev;
 
-- 
2.5.5
