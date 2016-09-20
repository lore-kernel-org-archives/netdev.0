From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: hisilicon: hns: use phydev from struct net_device
Date: Tue, 20 Sep 2016 22:30:11 +0200
Message-ID: <1474403412-18748-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lisheng011@huawei.com,
        xieqianqian@huawei.com, arnd@arndb.de, lipeng321@huawei.com,
        andrew@lunn.ch, chenny.xu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c    |   23 ++++++---------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h    |    1 -
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |   33 ++++++++++------------
 3 files changed, 24 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index d7e1f8c..059aaed 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -994,10 +994,10 @@ static void hns_nic_adjust_link(struct net_device *ndev)
 	struct hnae_handle *h = priv->ae_handle;
 	int state = 1;
 
-	if (priv->phy) {
+	if (ndev->phydev) {
 		h->dev->ops->adjust_link(h, ndev->phydev->speed,
 					 ndev->phydev->duplex);
-		state = priv->phy->link;
+		state = ndev->phydev->link;
 	}
 	state = state && h->dev->ops->get_status(h);
 
@@ -1022,7 +1022,6 @@ static void hns_nic_adjust_link(struct net_device *ndev)
  */
 int hns_nic_init_phy(struct net_device *ndev, struct hnae_handle *h)
 {
-	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct phy_device *phy_dev = h->phy_dev;
 	int ret;
 
@@ -1046,8 +1045,6 @@ int hns_nic_init_phy(struct net_device *ndev, struct hnae_handle *h)
 	if (h->phy_if == PHY_INTERFACE_MODE_XGMII)
 		phy_dev->autoneg = false;
 
-	priv->phy = phy_dev;
-
 	return 0;
 }
 
@@ -1224,8 +1221,8 @@ static int hns_nic_net_up(struct net_device *ndev)
 	if (ret)
 		goto out_start_err;
 
-	if (priv->phy)
-		phy_start(priv->phy);
+	if (ndev->phydev)
+		phy_start(ndev->phydev);
 
 	clear_bit(NIC_STATE_DOWN, &priv->state);
 	(void)mod_timer(&priv->service_timer, jiffies + SERVICE_TIMER_HZ);
@@ -1259,8 +1256,8 @@ static void hns_nic_net_down(struct net_device *ndev)
 	netif_tx_disable(ndev);
 	priv->link = 0;
 
-	if (priv->phy)
-		phy_stop(priv->phy);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 
 	ops = priv->ae_handle->dev->ops;
 
@@ -1359,8 +1356,7 @@ static void hns_nic_net_timeout(struct net_device *ndev)
 static int hns_nic_do_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			    int cmd)
 {
-	struct hns_nic_priv *priv = netdev_priv(netdev);
-	struct phy_device *phy_dev = priv->phy;
+	struct phy_device *phy_dev = netdev->phydev;
 
 	if (!netif_running(netdev))
 		return -EINVAL;
@@ -2017,9 +2013,8 @@ static int hns_nic_dev_remove(struct platform_device *pdev)
 		hns_nic_uninit_ring_data(priv);
 	priv->ring_data = NULL;
 
-	if (priv->phy)
-		phy_disconnect(priv->phy);
-	priv->phy = NULL;
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
 
 	if (!IS_ERR_OR_NULL(priv->ae_handle))
 		hnae_put_handle(priv->ae_handle);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index 44bb301..5b412de 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -59,7 +59,6 @@ struct hns_nic_priv {
 	u32 port_id;
 	int phy_mode;
 	int phy_led_val;
-	struct phy_device *phy;
 	struct net_device *netdev;
 	struct device *dev;
 	struct hnae_handle *ae_handle;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 5eb3245..0e2c174 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -48,9 +48,9 @@ static u32 hns_nic_get_link(struct net_device *net_dev)
 
 	h = priv->ae_handle;
 
-	if (priv->phy) {
-		if (!genphy_read_status(priv->phy))
-			link_stat = priv->phy->link;
+	if (net_dev->phydev) {
+		if (!genphy_read_status(net_dev->phydev))
+			link_stat = net_dev->phydev->link;
 		else
 			link_stat = 0;
 	}
@@ -67,8 +67,7 @@ static void hns_get_mdix_mode(struct net_device *net_dev,
 			      struct ethtool_cmd *cmd)
 {
 	int mdix_ctrl, mdix, retval, is_resolved;
-	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct phy_device *phy_dev = priv->phy;
+	struct phy_device *phy_dev = net_dev->phydev;
 
 	if (!phy_dev || !phy_dev->mdio.bus) {
 		cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_INVALID;
@@ -144,8 +143,8 @@ static int hns_nic_get_settings(struct net_device *net_dev,
 	ethtool_cmd_speed_set(cmd, speed);
 	cmd->duplex = duplex;
 
-	if (priv->phy)
-		(void)phy_ethtool_gset(priv->phy, cmd);
+	if (net_dev->phydev)
+		(void)phy_ethtool_gset(net_dev->phydev, cmd);
 
 	link_stat = hns_nic_get_link(net_dev);
 	if (!link_stat) {
@@ -215,13 +214,13 @@ static int hns_nic_set_settings(struct net_device *net_dev,
 		    cmd->duplex != DUPLEX_FULL)
 			return -EINVAL;
 	} else if (h->phy_if == PHY_INTERFACE_MODE_SGMII) {
-		if (!priv->phy && cmd->autoneg == AUTONEG_ENABLE)
+		if (!net_dev->phydev && cmd->autoneg == AUTONEG_ENABLE)
 			return -EINVAL;
 
 		if (speed == SPEED_1000 && cmd->duplex == DUPLEX_HALF)
 			return -EINVAL;
-		if (priv->phy)
-			return phy_ethtool_sset(priv->phy, cmd);
+		if (net_dev->phydev)
+			return phy_ethtool_sset(net_dev->phydev, cmd);
 
 		if ((speed != SPEED_10 && speed != SPEED_100 &&
 		     speed != SPEED_1000) || (cmd->duplex != DUPLEX_HALF &&
@@ -305,7 +304,7 @@ static int __lb_setup(struct net_device *ndev,
 {
 	int ret = 0;
 	struct hns_nic_priv *priv = netdev_priv(ndev);
-	struct phy_device *phy_dev = priv->phy;
+	struct phy_device *phy_dev = ndev->phydev;
 	struct hnae_handle *h = priv->ae_handle;
 
 	switch (loop) {
@@ -910,7 +909,7 @@ void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 		memcpy(buff, hns_nic_test_strs[MAC_INTERNALLOOP_SERDES],
 		       ETH_GSTRING_LEN);
 		buff += ETH_GSTRING_LEN;
-		if ((priv->phy) && (!priv->phy->is_c45))
+		if ((netdev->phydev) && (!netdev->phydev->is_c45))
 			memcpy(buff, hns_nic_test_strs[MAC_INTERNALLOOP_PHY],
 			       ETH_GSTRING_LEN);
 
@@ -996,7 +995,7 @@ int hns_get_sset_count(struct net_device *netdev, int stringset)
 		if (priv->ae_handle->phy_if == PHY_INTERFACE_MODE_XGMII)
 			cnt--;
 
-		if ((!priv->phy) || (priv->phy->is_c45))
+		if ((!netdev->phydev) || (netdev->phydev->is_c45))
 			cnt--;
 
 		return cnt;
@@ -1015,8 +1014,7 @@ int hns_get_sset_count(struct net_device *netdev, int stringset)
 int hns_phy_led_set(struct net_device *netdev, int value)
 {
 	int retval;
-	struct hns_nic_priv *priv = netdev_priv(netdev);
-	struct phy_device *phy_dev = priv->phy;
+	struct phy_device *phy_dev = netdev->phydev;
 
 	retval = phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_LED);
 	retval |= phy_write(phy_dev, HNS_LED_FC_REG, value);
@@ -1039,7 +1037,7 @@ int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
-	struct phy_device *phy_dev = priv->phy;
+	struct phy_device *phy_dev = netdev->phydev;
 	int ret;
 
 	if (phy_dev)
@@ -1159,8 +1157,7 @@ static int hns_get_regs_len(struct net_device *net_dev)
 static int hns_nic_nway_reset(struct net_device *netdev)
 {
 	int ret = 0;
-	struct hns_nic_priv *priv = netdev_priv(netdev);
-	struct phy_device *phy = priv->phy;
+	struct phy_device *phy = netdev->phydev;
 
 	if (netif_running(netdev)) {
 		if (phy)
-- 
1.7.4.4
