From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: octeon: use phydev from struct net_device
Date: Sat, 30 Jul 2016 16:14:43 +0200
Message-ID: <1469888084-2887-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: gregkh@linuxfoundation.org, aaro.koskinen@iki.fi, nevola@gmail.com,
 andrew@lunn.ch, davem@davemloft.net, bhumirks@gmail.com,
 okash.khawaja@gmail.com, david.daney@cavium.com,
 cristina.moraru09@gmail.com, aybuke.147@gmail.com,
 kevin@darbyshire-bryant.me.uk, bhaktipriya96@gmail.com, joe@perches.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/staging/octeon/ethernet-mdio.c   |   48 ++++++++++++-----------------
 drivers/staging/octeon/ethernet-rgmii.c  |    2 +-
 drivers/staging/octeon/ethernet.c        |   12 +++----
 drivers/staging/octeon/octeon-ethernet.h |    1 -
 4 files changed, 26 insertions(+), 37 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index e13a4ab..661b97b 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -36,36 +36,30 @@ static void cvm_oct_get_drvinfo(struct net_device *dev,
 
 static int cvm_oct_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct octeon_ethernet *priv = netdev_priv(dev);
-
-	if (priv->phydev)
-		return phy_ethtool_gset(priv->phydev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_gset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
 
 static int cvm_oct_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct octeon_ethernet *priv = netdev_priv(dev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (priv->phydev)
-		return phy_ethtool_sset(priv->phydev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_sset(dev->phydev, cmd);
 
 	return -EINVAL;
 }
 
 static int cvm_oct_nway_reset(struct net_device *dev)
 {
-	struct octeon_ethernet *priv = netdev_priv(dev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (priv->phydev)
-		return phy_start_aneg(priv->phydev);
+	if (dev->phydev)
+		return phy_start_aneg(dev->phydev);
 
 	return -EINVAL;
 }
@@ -88,15 +82,13 @@ const struct ethtool_ops cvm_oct_ethtool_ops = {
  */
 int cvm_oct_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct octeon_ethernet *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(priv->phydev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 void cvm_oct_note_carrier(struct octeon_ethernet *priv,
@@ -119,9 +111,9 @@ void cvm_oct_adjust_link(struct net_device *dev)
 	cvmx_helper_link_info_t link_info;
 
 	link_info.u64		= 0;
-	link_info.s.link_up	= priv->phydev->link ? 1 : 0;
-	link_info.s.full_duplex = priv->phydev->duplex ? 1 : 0;
-	link_info.s.speed	= priv->phydev->speed;
+	link_info.s.link_up	= dev->phydev->link ? 1 : 0;
+	link_info.s.full_duplex = dev->phydev->duplex ? 1 : 0;
+	link_info.s.speed	= dev->phydev->speed;
 	priv->link_info		= link_info.u64;
 
 	/*
@@ -130,8 +122,8 @@ void cvm_oct_adjust_link(struct net_device *dev)
 	if (priv->poll)
 		priv->poll(dev);
 
-	if (priv->last_link != priv->phydev->link) {
-		priv->last_link = priv->phydev->link;
+	if (priv->last_link != dev->phydev->link) {
+		priv->last_link = dev->phydev->link;
 		cvmx_helper_link_set(priv->port, link_info);
 		cvm_oct_note_carrier(priv, link_info);
 	}
@@ -151,9 +143,8 @@ int cvm_oct_common_stop(struct net_device *dev)
 
 	priv->poll = NULL;
 
-	if (priv->phydev)
-		phy_disconnect(priv->phydev);
-	priv->phydev = NULL;
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
 
 	if (priv->last_link) {
 		link_info.u64 = 0;
@@ -176,6 +167,7 @@ int cvm_oct_phy_setup_device(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
 	struct device_node *phy_node;
+	struct phy_device *phydev = NULL;
 
 	if (!priv->of_node)
 		goto no_phy;
@@ -193,14 +185,14 @@ int cvm_oct_phy_setup_device(struct net_device *dev)
 	if (!phy_node)
 		goto no_phy;
 
-	priv->phydev = of_phy_connect(dev, phy_node, cvm_oct_adjust_link, 0,
-				      PHY_INTERFACE_MODE_GMII);
+	phydev = of_phy_connect(dev, phy_node, cvm_oct_adjust_link, 0,
+				PHY_INTERFACE_MODE_GMII);
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	priv->last_link = 0;
-	phy_start_aneg(priv->phydev);
+	phy_start_aneg(phydev);
 
 	return 0;
 no_phy:
diff --git a/drivers/staging/octeon/ethernet-rgmii.c b/drivers/staging/octeon/ethernet-rgmii.c
index 91b148c..48846df 100644
--- a/drivers/staging/octeon/ethernet-rgmii.c
+++ b/drivers/staging/octeon/ethernet-rgmii.c
@@ -145,7 +145,7 @@ int cvm_oct_rgmii_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	if (priv->phydev) {
+	if (dev->phydev) {
 		/*
 		 * In phydev mode, we need still periodic polling for the
 		 * preamble error checking, and we also need to call this
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index e9cd5f2..45d5763 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -457,10 +457,8 @@ int cvm_oct_common_init(struct net_device *dev)
 
 void cvm_oct_common_uninit(struct net_device *dev)
 {
-	struct octeon_ethernet *priv = netdev_priv(dev);
-
-	if (priv->phydev)
-		phy_disconnect(priv->phydev);
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
 }
 
 int cvm_oct_common_open(struct net_device *dev,
@@ -484,10 +482,10 @@ int cvm_oct_common_open(struct net_device *dev,
 	if (octeon_is_simulation())
 		return 0;
 
-	if (priv->phydev) {
-		int r = phy_read_status(priv->phydev);
+	if (dev->phydev) {
+		int r = phy_read_status(dev->phydev);
 
-		if (r == 0 && priv->phydev->link == 0)
+		if (r == 0 && dev->phydev->link == 0)
 			netif_carrier_off(dev);
 		cvm_oct_adjust_link(dev);
 	} else {
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 6275c15..d533aef 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -40,7 +40,6 @@ struct octeon_ethernet {
 	struct sk_buff_head tx_free_list[16];
 	/* Device statistics */
 	struct net_device_stats stats;
-	struct phy_device *phydev;
 	unsigned int last_speed;
 	unsigned int last_link;
 	/* Last negotiated link state */
-- 
1.7.4.4
