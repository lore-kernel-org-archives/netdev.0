From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] macb: Remove inappropriate spinlocks around mii calls
Date: Fri, 16 Feb 2007 15:59:06 +0100
Message-ID: <11716379462542-git-send-email-hskinnemoen@atmel.com>
Cc: netdev@vger.kernel.org, Andrew Victor <andrew@sanpeople.com>,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:62100 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945893AbXBPPCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 10:02:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove spin_lock_irqsave() around mii_ethtool_gset, mii_ethtool_sset
and generic_mii_ioctl. These are unnecessary and harmful because
the mii calls may call back into the mdio functions, which may sleep.

Pointed out by David Brownell.

Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |   24 +++---------------------
 1 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index a41418b..2e9571b 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -881,27 +881,15 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
-	int ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&bp->lock, flags);
-	ret = mii_ethtool_gset(&bp->mii, cmd);
-	spin_unlock_irqrestore(&bp->lock, flags);
 
-	return ret;
+	return mii_ethtool_gset(&bp->mii, cmd);
 }
 
 static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
-	int ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&bp->lock, flags);
-	ret = mii_ethtool_sset(&bp->mii, cmd);
-	spin_unlock_irqrestore(&bp->lock, flags);
 
-	return ret;
+	return mii_ethtool_sset(&bp->mii, cmd);
 }
 
 static void macb_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -930,17 +918,11 @@ static struct ethtool_ops macb_ethtool_ops = {
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct macb *bp = netdev_priv(dev);
-	int ret;
-	unsigned long flags;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irqsave(&bp->lock, flags);
-	ret = generic_mii_ioctl(&bp->mii, if_mii(rq), cmd, NULL);
-	spin_unlock_irqrestore(&bp->lock, flags);
-
-	return ret;
+	return generic_mii_ioctl(&bp->mii, if_mii(rq), cmd, NULL);
 }
 
 static ssize_t macb_mii_show(const struct device *_dev, char *buf,
-- 
1.4.4.4

