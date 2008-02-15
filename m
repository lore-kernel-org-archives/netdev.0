From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] fs_enet: Don't call phy_mii_ioctl() in atomic context.
Date: Fri, 15 Feb 2008 15:08:04 -0600
Message-ID: <20080215210804.GA14468@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Rune Torgersen <runet@innovsys.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:65427 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761710AbYBOVIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 16:08:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lock acquisition in fs_ioctl() does not appear to actually be necessary,
and thus is simply removed.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
This fixes the following bug:
http://ozlabs.org/pipermail/linuxppc-dev/2008-February/051564.html

 drivers/net/fs_enet/fs_enet-main.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 42d94ed..af869cf 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -946,16 +946,11 @@ static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct mii_ioctl_data *mii = (struct mii_ioctl_data *)&rq->ifr_data;
-	unsigned long flags;
-	int rc;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irqsave(&fep->lock, flags);
-	rc = phy_mii_ioctl(fep->phydev, mii, cmd);
-	spin_unlock_irqrestore(&fep->lock, flags);
-	return rc;
+	return phy_mii_ioctl(fep->phydev, mii, cmd);
 }
 
 extern int fs_mii_connect(struct net_device *dev);
-- 
1.5.3.8
