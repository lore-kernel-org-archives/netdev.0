From: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
Subject: [PATCH 1/2] gianfar: Deal with link state changes during GFAR_RESETTING dev state
Date: Mon, 13 Feb 2017 13:22:08 +0100
Message-ID: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
To: <claudiu.manoil@freescale.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graziadei <thomas.graziadei@omicronenergy.com>

The link state is not correctly set in the case that the network driver
is reconfigured while the link state changes. The phy informs the gianfar
driver, but gfar_update_link_state just exits and therefore looses the
change event. The network driver remains in the old state until a new link
event is sent.

A trace log from a possible scenario at bootup, when the link state in the
network driver stays down even though the phy reports an up link. The test
sends a SIOCSHWTSTAMP ioctl at the right moment (which calls reset_gfar):
         ip-1196 [000]  5.389270: phy_start: state: READY -> UP
kworker/0:2-1195 [000]  5.389784: phy_start_aneg: state: UP -> AN
kworker/0:2-1195 [000]  5.389788: phy_state_machine: state: UP -> AN
kworker/0:2-1195 [000]  6.828064: adjust_link: eth0, link 0 -> 0
kworker/0:2-1195 [000]  6.828599: phy_state_machine: state: AN -> NOLINK
       test-1470 [000]  7.460422: reset_gfar: before locking GFAR_RESETTING
       test-1470 [000]  7.470806: phy_stop: state: NOLINK -> HALTED
       test-1470 [000]  7.478806: phy_start: state: HALTED -> RESUMING
kworker/0:2-1195 [000]  7.479478: adjust_link: eth0, link 0 -> 1
kworker/0:2-1195 [000]  7.479482: phy_state_machine: state: RESUMING -> RUNNING
       test-1470 [000]  7.479826: reset_gfar: after locking GFAR_RESETTING

To resolve the issue adjust_link is called after every GFAR_RESETTING lock
section. Adjust_link itself checks if anything has changed and updates the
link accordingly.

Signed-off-by: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
---
 drivers/net/ethernet/freescale/gianfar.c         |  7 +++++++
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 15 +++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 957bfc2..b3b5c43 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2617,6 +2617,10 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 
 	clear_bit_unlock(GFAR_RESETTING, &priv->state);
 
+	// catch maybe missed link state changes
+	if (dev->flags & IFF_UP)
+		adjust_link(dev);
+
 	return 0;
 }
 
@@ -2631,6 +2635,9 @@ void reset_gfar(struct net_device *ndev)
 	startup_gfar(ndev);
 
 	clear_bit_unlock(GFAR_RESETTING, &priv->state);
+
+	// catch maybe missed link state changes
+	adjust_link(ndev);
 }
 
 /* gfar_reset_task gets scheduled when a packet has not been
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index a93e019..065f05e 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -330,6 +330,7 @@ static int gfar_scoalesce(struct net_device *dev,
 			  struct ethtool_coalesce *cvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 	int i, err = 0;
 
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
@@ -408,6 +409,10 @@ static int gfar_scoalesce(struct net_device *dev,
 
 	clear_bit_unlock(GFAR_RESETTING, &priv->state);
 
+	// catch maybe missed link state changes
+	if (dev->flags & IFF_UP)
+		phydev->adjust_link(dev);
+
 	return err;
 }
 
@@ -445,6 +450,7 @@ static int gfar_sringparam(struct net_device *dev,
 			   struct ethtool_ringparam *rvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 	int err = 0, i;
 
 	if (rvals->rx_pending > GFAR_RX_MAX_RING_SIZE)
@@ -482,6 +488,10 @@ static int gfar_sringparam(struct net_device *dev,
 
 	clear_bit_unlock(GFAR_RESETTING, &priv->state);
 
+	// catch maybe missed link state changes
+	if (dev->flags & IFF_UP)
+		phydev->adjust_link(dev);
+
 	return err;
 }
 
@@ -569,6 +579,7 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 {
 	netdev_features_t changed = dev->features ^ features;
 	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 	int err = 0;
 
 	if (!(changed & (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
@@ -590,6 +601,10 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 
 	clear_bit_unlock(GFAR_RESETTING, &priv->state);
 
+	// catch maybe missed link state changes
+	if (dev->flags & IFF_UP)
+		phydev->adjust_link(dev);
+
 	return err;
 }
 
-- 
2.7.4
