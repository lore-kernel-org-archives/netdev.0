From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/11] net: dsa: make EEE ops optional
Date: Mon, 31 Jul 2017 18:17:09 -0400
Message-ID: <20170731221719.16695-2-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even though EEE implies the port's PHY and MAC of both ends, a switch
may not need to do anything to configure the port's MAC.

This makes it impossible for the DSA layer to distinguish e.g. this case
from a disabled EEE when a driver returns 0 from the get EEE operation.

For this reason, make the EEE ops optional and call them only when
provided. Calling it first allows a switch driver to stop the whole
operation at runtime if a given switch does not support the EEE setting.

If both the MAC operation and PHY are not present, -ENODEV is returned.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 44 ++++++++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9507bd38cf04..518145ced434 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -646,38 +646,42 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
-	int ret;
+	int err = -ENODEV;
 
-	if (!ds->ops->set_eee)
-		return -EOPNOTSUPP;
+	if (ds->ops->set_eee) {
+		err = ds->ops->set_eee(ds, p->dp->index, p->phy, e);
+		if (err)
+			return err;
+	}
 
-	ret = ds->ops->set_eee(ds, p->dp->index, p->phy, e);
-	if (ret)
-		return ret;
+	if (p->phy) {
+		err = phy_ethtool_set_eee(p->phy, e);
+		if (err)
+			return err;
+	}
 
-	if (p->phy)
-		ret = phy_ethtool_set_eee(p->phy, e);
-
-	return ret;
+	return err;
 }
 
 static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
-	int ret;
+	int err = -ENODEV;
 
-	if (!ds->ops->get_eee)
-		return -EOPNOTSUPP;
+	if (ds->ops->get_eee) {
+		err = ds->ops->get_eee(ds, p->dp->index, e);
+		if (err)
+			return err;
+	}
 
-	ret = ds->ops->get_eee(ds, p->dp->index, e);
-	if (ret)
-		return ret;
+	if (p->phy) {
+		err = phy_ethtool_get_eee(p->phy, e);
+		if (err)
+			return err;
+	}
 
-	if (p->phy)
-		ret = phy_ethtool_get_eee(p->phy, e);
-
-	return ret;
+	return err;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
2.13.3
