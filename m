From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH net] net: hns: Bugfix for Tx timeout handling in hns driver
Date: Wed, 12 Jul 2017 19:09:59 +0800
Message-ID: <1499857799-16124-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <tremyfr@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When hns port type is not debug mode, netif_tx_disable is called
when there is a tx timeout, which requires system reboot to return
to normal state. This patch fix this problem by resetting the net
dev.

Fixes: b5996f11ea54 ("net: add Hisilicon Network Subsystem basic ethernet support")
Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index fe166e0..3987699 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1378,13 +1378,20 @@ void hns_nic_net_reset(struct net_device *ndev)
 void hns_nic_net_reinit(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
+	enum hnae_port_type type = priv->ae_handle->port_type;
 
 	netif_trans_update(priv->netdev);
 	while (test_and_set_bit(NIC_STATE_REINITING, &priv->state))
 		usleep_range(1000, 2000);
 
 	hns_nic_net_down(netdev);
-	hns_nic_net_reset(netdev);
+
+	/* Only do hns_nic_net_reset in debug mode
+	 * because of hardware limitation.
+	 */
+	if (type == HNAE_PORT_DEBUG)
+		hns_nic_net_reset(netdev);
+
 	(void)hns_nic_net_up(netdev);
 	clear_bit(NIC_STATE_REINITING, &priv->state);
 }
@@ -1997,13 +2004,8 @@ static void hns_nic_reset_subtask(struct hns_nic_priv *priv)
 	rtnl_lock();
 	/* put off any impending NetWatchDogTimeout */
 	netif_trans_update(priv->netdev);
+	hns_nic_net_reinit(priv->netdev);
 
-	if (type == HNAE_PORT_DEBUG) {
-		hns_nic_net_reinit(priv->netdev);
-	} else {
-		netif_carrier_off(priv->netdev);
-		netif_tx_disable(priv->netdev);
-	}
 	rtnl_unlock();
 }
 
-- 
1.9.1
