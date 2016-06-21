From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 09/19] net: hns: fix the wrong speed for bond
Date: Tue, 21 Jun 2016 11:56:29 +0800
Message-ID: <1466481399-70080-10-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42933 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbcFUDiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 23:38:19 -0400
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

For debug-ports,there are two non-synchronized processes:
Speed-Auto-Negotiation and Link-Update-Status. The two
processes are towed by two different state machines.
Bond reads the speed when link up, but the speed maybe
not update the right value at that time.That make for bond's
wrong speed. Thus only one state machine should be used and
if phy_state_machine is used, it does not need to do
hns_nic_update_link_status().

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c    | 43 +++++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |  2 +-
 2 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 00e529f..cef9d12 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -991,8 +991,26 @@ static void hns_nic_adjust_link(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
+	int state = 1;
+
+	if (priv->phy) {
+		h->dev->ops->adjust_link(h, ndev->phydev->speed,
+					 ndev->phydev->duplex);
+		state = priv->phy->link;
+	}
+	state = state && h->dev->ops->get_status(h);
 
-	h->dev->ops->adjust_link(h, ndev->phydev->speed, ndev->phydev->duplex);
+	if (state != priv->link) {
+		if (state) {
+			netif_carrier_on(ndev);
+			netif_tx_wake_all_queues(ndev);
+			netdev_info(ndev, "link up\n");
+		} else {
+			netif_carrier_off(ndev);
+			netdev_info(ndev, "link down\n");
+		}
+		priv->link = state;
+	}
 }
 
 /**
@@ -1577,27 +1595,14 @@ static void hns_nic_update_link_status(struct net_device *netdev)
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 
 	struct hnae_handle *h = priv->ae_handle;
-	int state = 1;
 
-	if (priv->phy) {
-		if (!genphy_update_link(priv->phy))
-			state = priv->phy->link;
-		else
-			state = 0;
-	}
-	state = state && h->dev->ops->get_status(h);
+	if (h->phy_dev) {
+		if (h->phy_if != PHY_INTERFACE_MODE_XGMII)
+			return;
 
-	if (state != priv->link) {
-		if (state) {
-			netif_carrier_on(netdev);
-			netif_tx_wake_all_queues(netdev);
-			netdev_info(netdev, "link up\n");
-		} else {
-			netif_carrier_off(netdev);
-			netdev_info(netdev, "link down\n");
-		}
-		priv->link = state;
+		(void)genphy_read_status(h->phy_dev);
 	}
+	hns_nic_adjust_link(netdev);
 }
 
 /* for dumping key regs*/
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 5b3dccb..564ae1e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -49,7 +49,7 @@ static u32 hns_nic_get_link(struct net_device *net_dev)
 	h = priv->ae_handle;
 
 	if (priv->phy) {
-		if (!genphy_update_link(priv->phy))
+		if (!genphy_read_status(priv->phy))
 			link_stat = priv->phy->link;
 		else
 			link_stat = 0;
-- 
1.9.1
