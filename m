From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 1/2] net: hns: fixes the issue by using ethtool -s
Date: Fri, 16 Oct 2015 17:03:19 +0800
Message-ID: <1444986200-39566-2-git-send-email-yankejian@huawei.com>
References: <1444986200-39566-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <davem@davemloft.net>,
	<chenny.xu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444986200-39566-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenny Xu <chenny.xu@huawei.com>

  before this patch, hns driver only permits user to set the net device
by using ethtool -s when the device is link up. it is obviously not so
good. it needs to be set no matter it is link up or down. so this patch
fixes this issue.

Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: lisheng <lisheng011@huawei.com>
Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: Chenny Xu <chenny.xu@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 39 ++++++++----------------
 1 file changed, 12 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 2550208..e31c10b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -194,9 +194,7 @@ static int hns_nic_set_settings(struct net_device *net_dev,
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_handle *h;
-	int link_stat;
 	u32 speed;
-	u8 duplex, autoneg;
 
 	if (!netif_running(net_dev))
 		return -ESRCH;
@@ -206,48 +204,35 @@ static int hns_nic_set_settings(struct net_device *net_dev,
 		return -ENODEV;
 
 	h = priv->ae_handle;
-	link_stat = hns_nic_get_link(net_dev);
-	duplex = cmd->duplex;
 	speed = ethtool_cmd_speed(cmd);
-	autoneg = cmd->autoneg;
-
-	if (!link_stat) {
-		if (duplex != (u8)DUPLEX_UNKNOWN || speed != (u32)SPEED_UNKNOWN)
-			return -EINVAL;
-
-		if (h->phy_if == PHY_INTERFACE_MODE_SGMII && h->phy_node) {
-			priv->phy->autoneg = autoneg;
-			return phy_start_aneg(priv->phy);
-		}
-	}
 
 	if (h->phy_if == PHY_INTERFACE_MODE_XGMII) {
-		if (autoneg != AUTONEG_DISABLE)
-			return -EINVAL;
-
-		if (speed != SPEED_10000 || duplex != DUPLEX_FULL)
+		if (cmd->autoneg == AUTONEG_ENABLE || speed != SPEED_10000 ||
+		    cmd->duplex != DUPLEX_FULL)
 			return -EINVAL;
 	} else if (h->phy_if == PHY_INTERFACE_MODE_SGMII) {
-		if (!h->phy_node && autoneg != AUTONEG_DISABLE)
+		if (!priv->phy && cmd->autoneg == AUTONEG_ENABLE)
 			return -EINVAL;
 
-		if (speed == SPEED_1000 && duplex == DUPLEX_HALF)
+		if (speed == SPEED_1000 && cmd->duplex == DUPLEX_HALF)
 			return -EINVAL;
+		if (priv->phy)
+			return phy_ethtool_sset(priv->phy, cmd);
 
-		if (speed != SPEED_10 && speed != SPEED_100 &&
-		    speed != SPEED_1000)
+		if ((speed != SPEED_10 && speed != SPEED_100 &&
+		     speed != SPEED_1000) || (cmd->duplex != DUPLEX_HALF &&
+		     cmd->duplex != DUPLEX_FULL))
 			return -EINVAL;
 	} else {
 		netdev_err(net_dev, "Not supported!");
 		return -ENOTSUPP;
 	}
 
-	if (priv->phy) {
-		return phy_ethtool_sset(priv->phy, cmd);
-	} else if (h->dev->ops->adjust_link && link_stat) {
-		h->dev->ops->adjust_link(h, speed, duplex);
+	if (h->dev->ops->adjust_link) {
+		h->dev->ops->adjust_link(h, (int)speed, cmd->duplex);
 		return 0;
 	}
+
 	netdev_err(net_dev, "Not supported!");
 	return -ENOTSUPP;
 }
-- 
1.9.1
