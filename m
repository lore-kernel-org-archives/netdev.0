From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 5/9] net: dsa: forward hardware timestamping ioctls to switch driver
Date: Thu, 28 Sep 2017 10:25:37 -0500
Message-ID: <1506612341-18061-6-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "Vivien Didelot" <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support to the dsa slave network device so that
switch drivers can implement the SIOC[GS]HWTSTAMP ioctls and the
ethtool timestamp-info interface.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 include/net/dsa.h | 15 +++++++++++++++
 net/dsa/slave.c   | 39 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8dee216..1163af1 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -19,6 +19,7 @@
 #include <linux/workqueue.h>
 #include <linux/of.h>
 #include <linux/ethtool.h>
+#include <linux/net_tstamp.h>
 #include <net/devlink.h>
 #include <net/switchdev.h>
 
@@ -329,6 +330,12 @@ struct dsa_switch_ops {
 			   struct ethtool_wolinfo *w);
 
 	/*
+	 * ethtool timestamp info
+	 */
+	int	(*get_ts_info)(struct dsa_switch *ds, int port,
+			       struct ethtool_ts_info *ts);
+
+	/*
 	 * Suspend and resume
 	 */
 	int	(*suspend)(struct dsa_switch *ds);
@@ -434,6 +441,14 @@ struct dsa_switch_ops {
 					 int port, struct net_device *br);
 	void	(*crosschip_bridge_leave)(struct dsa_switch *ds, int sw_index,
 					  int port, struct net_device *br);
+
+	/*
+	 * PTP functionality
+	 */
+	int	(*port_hwtstamp_get)(struct dsa_switch *ds, int port,
+				     struct ifreq *ifr);
+	int	(*port_hwtstamp_set)(struct dsa_switch *ds, int port,
+				     struct ifreq *ifr);
 };
 
 struct dsa_switch_driver {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bf8800d..2cf6a83 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -264,10 +264,34 @@ dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->dp->ds;
+	int port = p->dp->index;
+
 	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(dev->phydev, ifr, cmd);
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		if (dev->phydev)
+			return phy_mii_ioctl(dev->phydev, ifr, cmd);
+		else
+			return -EOPNOTSUPP;
+	case SIOCGHWTSTAMP:
+		if (ds->ops->port_hwtstamp_get)
+			return ds->ops->port_hwtstamp_get(ds, port, ifr);
+		else
+			return -EOPNOTSUPP;
+	case SIOCSHWTSTAMP:
+		if (ds->ops->port_hwtstamp_set)
+			return ds->ops->port_hwtstamp_set(ds, port, ifr);
+		else
+			return -EOPNOTSUPP;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static int dsa_slave_port_attr_set(struct net_device *dev,
@@ -876,6 +900,18 @@ static int dsa_slave_set_rxnfc(struct net_device *dev,
 	return ds->ops->set_rxnfc(ds, p->dp->index, nfc);
 }
 
+static int dsa_slave_get_ts_info(struct net_device *dev,
+				 struct ethtool_ts_info *ts)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->dp->ds;
+
+	if (!ds->ops->get_ts_info)
+		return -EOPNOTSUPP;
+
+	return ds->ops->get_ts_info(ds, p->dp->index, ts);
+}
+
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_drvinfo		= dsa_slave_get_drvinfo,
 	.get_regs_len		= dsa_slave_get_regs_len,
@@ -896,6 +932,7 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 	.get_rxnfc		= dsa_slave_get_rxnfc,
 	.set_rxnfc		= dsa_slave_set_rxnfc,
+	.get_ts_info		= dsa_slave_get_ts_info,
 };
 
 static const struct net_device_ops dsa_slave_netdev_ops = {
-- 
2.1.4
