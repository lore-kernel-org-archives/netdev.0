From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [RESEND/BUG PATCH v3] net: smsc911x: Fix bug where PHY interrupts are overwritten by 0
Date: Tue,  5 Jul 2016 10:32:49 -0500
Message-ID: <1467732769-12471-1-git-send-email-jeremy.linton@arm.com>
Cc: davem@davemloft.net, steve.glendinning@shawell.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:53805 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbcGEPcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 11:32:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, mdiobus_alloc() sets the PHYs to polling mode, but a
pointer size memcpy means that a couple IRQs end up being overwritten
with a value of 0. This means that PHY_POLL is disabled and results
in unpredictable behavior depending on the PHY's location on the
MDIO bus. Remove that memcpy and the now unused phy_irq member to
force the SMSC911x PHYs into polling mode 100% of the time.

Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
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
