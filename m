From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 1/4] net: smsc911x: Remove multiple exit points from smsc911x_open
Date: Thu,  1 Sep 2016 15:15:06 -0500
Message-ID: <1472760909-19688-2-git-send-email-jeremy.linton@arm.com>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, sergei.shtylyov@cogentembedded.com,
        andrew@lunn.ch, will.deacon@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39368 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934865AbcIAVd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:33:56 -0400
In-Reply-To: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework the error handling in smsc911x open in preparation
for the mdio startup being moved here.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index ca31345..c9b0e05 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1520,17 +1520,20 @@ static int smsc911x_open(struct net_device *dev)
 	unsigned int timeout;
 	unsigned int temp;
 	unsigned int intcfg;
+	int retval;
 
 	/* if the phy is not yet registered, retry later*/
 	if (!dev->phydev) {
 		SMSC_WARN(pdata, hw, "phy_dev is NULL");
-		return -EAGAIN;
+		retval = -EAGAIN;
+		goto out;
 	}
 
 	/* Reset the LAN911x */
-	if (smsc911x_soft_reset(pdata)) {
+	retval = smsc911x_soft_reset(pdata);
+	if (retval) {
 		SMSC_WARN(pdata, hw, "soft reset failed");
-		return -EIO;
+		goto out;
 	}
 
 	smsc911x_reg_write(pdata, HW_CFG, 0x00050000);
@@ -1600,7 +1603,8 @@ static int smsc911x_open(struct net_device *dev)
 	if (!pdata->software_irq_signal) {
 		netdev_warn(dev, "ISR failed signaling test (IRQ %d)\n",
 			    dev->irq);
-		return -ENODEV;
+		retval = -ENODEV;
+		goto out;
 	}
 	SMSC_TRACE(pdata, ifup, "IRQ handler passed test using IRQ %d",
 		   dev->irq);
@@ -1646,6 +1650,8 @@ static int smsc911x_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	return 0;
+out:
+	return retval;
 }
 
 /* Entry point for stopping the interface */
-- 
2.5.5
