From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 02/12] phylib: do not filter phy_mii_ioctl()
Date: Tue, 15 Jun 2010 18:07:46 +0200
Message-ID: <4cd127a2aa2c40a1b573e079e0624f10d1d94867.1276615626.git.richard.cochran@omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43726 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307Ab0FOQGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:06:55 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so266600fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:06:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two maverick drivers filter the ioctl commands passed to phy_mii_ioctl().
This is unnecessary since phylib will check the command in any case.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/cpmac.c              |    5 +----
 drivers/net/stmmac/stmmac_main.c |   22 ++++++++--------------
 2 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index d4c5ca4..0e47ca1 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -846,11 +846,8 @@ static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		return -EINVAL;
 	if (!priv->phy)
 		return -EINVAL;
-	if ((cmd == SIOCGMIIPHY) || (cmd == SIOCGMIIREG) ||
-	    (cmd == SIOCSMIIREG))
-		return phy_mii_ioctl(priv->phy, ifr, cmd);
 
-	return -EOPNOTSUPP;
+	return phy_mii_ioctl(priv->phy, ifr, cmd);
 }
 
 static int cpmac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 6af7471..acf0616 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1437,24 +1437,18 @@ static void stmmac_poll_controller(struct net_device *dev)
 static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int ret = -EOPNOTSUPP;
+	int ret;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		if (!priv->phydev)
-			return -EINVAL;
-
-		spin_lock(&priv->lock);
-		ret = phy_mii_ioctl(priv->phydev, rq, cmd);
-		spin_unlock(&priv->lock);
-	default:
-		break;
-	}
+	if (!priv->phydev)
+		return -EINVAL;
+
+	spin_lock(&priv->lock);
+	ret = phy_mii_ioctl(priv->phydev, rq, cmd);
+	spin_unlock(&priv->lock);
+
 	return ret;
 }
 
-- 
1.6.3.3

