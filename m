From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 3/3] gianfar: Enable device wakeup when appropriate
Date: Fri, 31 Jul 2015 18:38:33 +0300
Message-ID: <1438357113-8312-4-git-send-email-claudiu.manoil@freescale.com>
References: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0132.outbound.protection.outlook.com ([157.56.111.132]:18030
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754087AbbGaPja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2015 11:39:30 -0400
In-Reply-To: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The wol_en flag is 0 by default anyway, and we have the
following inconsistency: a MAGIC packet wol capable eth
interface is registered as a wake-up source but unable
to wake-up the system as wol_en is 0 (wake-on flag set to 'd').
Calling set_wakeup_enable() at netdev open is just redundant
because wol_en is 0 by default.
Let only ethtool call set_wakeup_enable() for now.

The bflock is obviously obsoleted, its utility has been corroded
over time.  The bitfield flags used today in gianfar are accessed
only on the init/ config path, with no real possibility of
concurrency - nothing that would justify smth. like bflock.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c         | 8 ++------
 drivers/net/ethernet/freescale/gianfar.h         | 3 ---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 5 +----
 3 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 084c25d..2b7610f 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1360,7 +1360,6 @@ static int gfar_probe(struct platform_device *ofdev)
 	priv->dev = &ofdev->dev;
 	SET_NETDEV_DEV(dev, &ofdev->dev);
 
-	spin_lock_init(&priv->bflock);
 	INIT_WORK(&priv->reset_task, gfar_reset_task);
 
 	platform_set_drvdata(ofdev, priv);
@@ -1454,9 +1453,8 @@ static int gfar_probe(struct platform_device *ofdev)
 		goto register_fail;
 	}
 
-	device_init_wakeup(&dev->dev,
-			   priv->device_flags &
-			   FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+	device_set_wakeup_capable(&dev->dev, priv->device_flags &
+				  FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	/* fill out IRQ number and name fields */
 	for (i = 0; i < priv->num_grps; i++) {
@@ -2133,8 +2131,6 @@ static int gfar_enet_open(struct net_device *dev)
 	if (err)
 		return err;
 
-	device_set_wakeup_enable(&dev->dev, priv->wol_en);
-
 	return err;
 }
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index daa1d37..5545e41 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1145,9 +1145,6 @@ struct gfar_private {
 	int oldduplex;
 	int oldlink;
 
-	/* Bitfield update lock */
-	spinlock_t bflock;
-
 	uint32_t msg_enable;
 
 	struct work_struct reset_task;
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index fda12fb..3c0a8f8 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -653,7 +653,6 @@ static void gfar_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	unsigned long flags;
 
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
 	    wol->wolopts != 0)
@@ -664,9 +663,7 @@ static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	device_set_wakeup_enable(&dev->dev, wol->wolopts & WAKE_MAGIC);
 
-	spin_lock_irqsave(&priv->bflock, flags);
-	priv->wol_en =  !!device_may_wakeup(&dev->dev);
-	spin_unlock_irqrestore(&priv->bflock, flags);
+	priv->wol_en = !!device_may_wakeup(&dev->dev);
 
 	return 0;
 }
-- 
1.7.11.7
