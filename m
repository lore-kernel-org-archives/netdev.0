From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH net 2/6] net: hns: fixes the hw interrupt bug in using napi
Date: Fri, 4 Mar 2016 09:09:54 +0800
Message-ID: <1457053798-93513-3-git-send-email-huangdaode@hisilicon.com>
References: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In V1 chip, common_poll should check and clean fbd pkts, because it
can not pend irq to clean them if there is no new pkt comes in.
But V2 chip hw fixes this bug, and will pend irq itself to do this.
So, for V2 chip, we set ring_data->fini_process to NULL.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 9d46d57..6250a42 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -946,8 +946,8 @@ static int hns_nic_common_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
 			ring_data->ring, 0);
-
-		ring_data->fini_process(ring_data);
+		if (ring_data->fini_process)
+			ring_data->fini_process(ring_data);
 		return 0;
 	}
 
@@ -1710,6 +1710,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 {
 	struct hnae_handle *h = priv->ae_handle;
 	struct hns_nic_ring_data *rd;
+	bool is_ver1 = AE_IS_VER1(priv->enet_ver);
 	int i;
 
 	if (h->q_num > NIC_MAX_Q_PER_VF) {
@@ -1727,7 +1728,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		rd->queue_index = i;
 		rd->ring = &h->qs[i]->tx_ring;
 		rd->poll_one = hns_nic_tx_poll_one;
-		rd->fini_process = hns_nic_tx_fini_pro;
+		rd->fini_process = is_ver1 ? hns_nic_tx_fini_pro : NULL;
 
 		netif_napi_add(priv->netdev, &rd->napi,
 			       hns_nic_common_poll, NIC_TX_CLEAN_MAX_NUM);
@@ -1739,7 +1740,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		rd->ring = &h->qs[i - h->q_num]->rx_ring;
 		rd->poll_one = hns_nic_rx_poll_one;
 		rd->ex_process = hns_nic_rx_up_pro;
-		rd->fini_process = hns_nic_rx_fini_pro;
+		rd->fini_process = is_ver1 ? hns_nic_rx_fini_pro : NULL;
 
 		netif_napi_add(priv->netdev, &rd->napi,
 			       hns_nic_common_poll, NIC_RX_CLEAN_MAX_NUM);
-- 
1.9.1
