From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V5 net-next 4/5] net:hns: Add support of ethtool TSO set  option for Hip06 in HNS
Date: Thu, 26 Nov 2015 07:14:09 +0000
Message-ID: <1448522050-5576-5-git-send-email-salil.mehta@huawei.com>
References: <1448522050-5576-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448522050-5576-1-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil <salil.mehta@huawei.com>

This patch adds the support of ethtool TSO option to support
Hip06 SoC to HNS

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: lisheng <lisheng011@huawei.com>
---
PATCH V5:
- No change over the previous patch

PATCH V4:
This fixes the comments given by Sergei Shtylyov over the PATCH V3:
 Link: https://lkml.org/lkml/2015/11/20/358

PATCH V3/V2:
- No change over the initial patch

PATCH V1:
- Initial version of Ethtool support of TSO by Lisheng
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   47 +++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index c025a71..cad2663 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1384,6 +1384,51 @@ static int hns_nic_change_mtu(struct net_device *ndev, int new_mtu)
 	return ret;
 }
 
+static int hns_nic_set_features(struct net_device *netdev,
+				netdev_features_t features)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	switch (priv->enet_ver) {
+	case AE_VERSION_1:
+		if (features & (NETIF_F_TSO | NETIF_F_TSO6))
+			netdev_info(netdev, "enet v1 do not support tso!\n");
+		break;
+	default:
+		if (features & (NETIF_F_TSO | NETIF_F_TSO6)) {
+			priv->ops.fill_desc = fill_tso_desc;
+			priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tso;
+			/* The chip only support 7*4096 */
+			netif_set_gso_max_size(netdev, 7 * 4096);
+			h->dev->ops->set_tso_stats(h, 1);
+		} else {
+			priv->ops.fill_desc = fill_v2_desc;
+			priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
+			h->dev->ops->set_tso_stats(h, 0);
+		}
+		break;
+	}
+	netdev->features = features;
+	return 0;
+}
+
+static netdev_features_t hns_nic_fix_features(
+		struct net_device *netdev, netdev_features_t features)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+
+	switch (priv->enet_ver) {
+	case AE_VERSION_1:
+		features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
+				NETIF_F_HW_VLAN_CTAG_FILTER);
+		break;
+	default:
+		break;
+	}
+	return features;
+}
+
 /**
  * nic_set_multicast_list - set mutl mac address
  * @netdev: net device
@@ -1479,6 +1524,8 @@ static const struct net_device_ops hns_nic_netdev_ops = {
 	.ndo_set_mac_address = hns_nic_net_set_mac_address,
 	.ndo_change_mtu = hns_nic_change_mtu,
 	.ndo_do_ioctl = hns_nic_do_ioctl,
+	.ndo_set_features = hns_nic_set_features,
+	.ndo_fix_features = hns_nic_fix_features,
 	.ndo_get_stats64 = hns_nic_get_stats64,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = hns_nic_poll_controller,
-- 
1.7.9.5
