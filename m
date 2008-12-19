From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: fix BUG if module is removed while interface is up
Date: Fri, 19 Dec 2008 14:03:38 +0000
Message-ID: <1229695418-27275-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:51016 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753257AbYLSODi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 09:03:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the module is removed while its interface is up, smsc911x_stop is not
called until after smsc911x_drv_remove has disposed of phy_dev.  This
patch changes the stop method to handle this situation.

This is a different problem to the one reported by dfoley@telus.net.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index fa28542..552e97f 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1267,8 +1267,6 @@ static int smsc911x_stop(struct net_device *dev)
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	unsigned int temp;
 
-	BUG_ON(!pdata->phy_dev);
-
 	/* Disable all device interrupts */
 	temp = smsc911x_reg_read(pdata, INT_CFG);
 	temp &= ~INT_CFG_IRQ_EN_;
@@ -1283,7 +1281,8 @@ static int smsc911x_stop(struct net_device *dev)
 	smsc911x_tx_update_txcounters(dev);
 
 	/* Bring the PHY down */
-	phy_stop(pdata->phy_dev);
+	if (pdata->phy_dev)
+		phy_stop(pdata->phy_dev);
 
 	SMSC_TRACE(IFDOWN, "Interface stopped");
 	return 0;
-- 
1.6.0.4

