From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/5] net: dsa: return -ENODEV is there is no slave PHY
Date: Tue, 26 Sep 2017 17:15:31 -0400
Message-ID: <20170926211535.21273-2-vivien.didelot@savoirfairelinux.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of returning -EOPNOTSUPP when a slave device has no PHY,
directly return -ENODEV as ethtool and phylib do.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bd51ef56ec5b..79c5a0cd9923 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -266,10 +266,10 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	if (p->phy != NULL)
-		return phy_mii_ioctl(p->phy, ifr, cmd);
+	if (!p->phy)
+		return -ENODEV;
 
-	return -EOPNOTSUPP;
+	return phy_mii_ioctl(p->phy, ifr, cmd);
 }
 
 static int dsa_slave_port_attr_set(struct net_device *dev,
@@ -429,7 +429,7 @@ dsa_slave_get_link_ksettings(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
 	if (!p->phy)
-		return -EOPNOTSUPP;
+		return -ENODEV;
 
 	phy_ethtool_ksettings_get(p->phy, cmd);
 
@@ -442,10 +442,10 @@ dsa_slave_set_link_ksettings(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	if (p->phy != NULL)
-		return phy_ethtool_ksettings_set(p->phy, cmd);
+	if (!p->phy)
+		return -ENODEV;
 
-	return -EOPNOTSUPP;
+	return phy_ethtool_ksettings_set(p->phy, cmd);
 }
 
 static void dsa_slave_get_drvinfo(struct net_device *dev,
@@ -481,22 +481,22 @@ static int dsa_slave_nway_reset(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	if (p->phy != NULL)
-		return genphy_restart_aneg(p->phy);
+	if (!p->phy)
+		return -ENODEV;
 
-	return -EOPNOTSUPP;
+	return genphy_restart_aneg(p->phy);
 }
 
 static u32 dsa_slave_get_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	if (p->phy != NULL) {
-		genphy_update_link(p->phy);
-		return p->phy->link;
-	}
+	if (!p->phy)
+		return -ENODEV;
 
-	return -EOPNOTSUPP;
+	genphy_update_link(p->phy);
+
+	return p->phy->link;
 }
 
 static int dsa_slave_get_eeprom_len(struct net_device *dev)
-- 
2.14.1
