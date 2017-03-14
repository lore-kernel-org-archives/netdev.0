From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 09/12] net: bcmgenet: return EOPNOTSUPP for unknown ioctl commands
Date: Mon, 13 Mar 2017 17:41:39 -0700
Message-ID: <20170314004142.4746-10-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit changes the ioctl handling behavior to return the
EOPNOTSUPP error code instead of the EINVAL error code when an
unknown ioctl command value is detected.

It also removes some redundant parsing of the ioctl command value
and allows the SIOCSHWTSTAMP value to be handled.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d90d366b286f..3b49c14128e2 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1062,27 +1062,14 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 static int bcmgenet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	int val = 0;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		if (!priv->phydev)
-			val = -ENODEV;
-		else
-			val = phy_mii_ioctl(priv->phydev, rq, cmd);
-		break;
-
-	default:
-		val = -EINVAL;
-		break;
-	}
+	if (!priv->phydev)
+		return -ENODEV;
 
-	return val;
+	return phy_mii_ioctl(priv->phydev, rq, cmd);
 }
 
 static struct enet_cb *bcmgenet_get_txcb(struct bcmgenet_priv *priv,
-- 
2.11.1
