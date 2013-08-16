From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] sis900: don't restart auto-negotiation each time after link resume.
Date: Fri, 16 Aug 2013 11:20:07 +0400
Message-ID: <1376637607-2356-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:65075 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013Ab3HPLOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:14:31 -0400
Received: by mail-la0-f43.google.com with SMTP id ep20so1351743lab.16
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 04:14:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 drivers/net/ethernet/sis/sis900.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index f5d7ad7..b7a3930 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1309,23 +1309,9 @@ static void sis900_timer(unsigned long data)
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_phy *mii_phy = sis_priv->mii;
 	static const int next_tick = 5*HZ;
+	int speed = 0, duplex = 0;
 	u16 status;
 
-	if (!sis_priv->autong_complete){
-		int uninitialized_var(speed), duplex = 0;
-
-		sis900_read_mode(net_dev, &speed, &duplex);
-		if (duplex){
-			sis900_set_mode(sis_priv, speed, duplex);
-			sis630_set_eq(net_dev, sis_priv->chipset_rev);
-			netif_carrier_on(net_dev);
-		}
-
-		sis_priv->timer.expires = jiffies + HZ;
-		add_timer(&sis_priv->timer);
-		return;
-	}
-
 	status = mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS);
 	status = mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS);
 
@@ -1336,8 +1322,16 @@ static void sis900_timer(unsigned long data)
 		status = sis900_default_phy(net_dev);
 		mii_phy = sis_priv->mii;
 
-		if (status & MII_STAT_LINK)
-			sis900_check_mode(net_dev, mii_phy);
+		if (status & MII_STAT_LINK) {
+			WARN_ON(!(status & MII_STAT_AUTO_DONE));
+
+			sis900_read_mode(net_dev, &speed, &duplex);
+			if (duplex) {
+				sis900_set_mode(sis_priv, speed, duplex);
+				sis630_set_eq(net_dev, sis_priv->chipset_rev);
+				netif_carrier_on(net_dev);
+			}
+		}
 	} else {
 	/* Link ON -> OFF */
                 if (!(status & MII_STAT_LINK)){
-- 
1.8.0.2
