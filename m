From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 5/7] net: hns: optimizate irq proccess for HNS V2
Date: Thu, 24 Mar 2016 19:08:04 +0800
Message-ID: <1458817686-159708-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sheng Li <lisheng011@huawei.com>

In hns V1, common_poll should check and clean fbd pkts, because it
can not pend irq to clean them if there is no new pkt comes in.
But hns V2 hw fixes this bug, and will pend irq itself to do this.
So, for hns V2, we set ring_data->fini_process to NULL.

Signed-off-by: Sheng Li <lisheng011@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index f0c9a41..66d1652 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -956,8 +956,8 @@ static int hns_nic_common_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
 			ring_data->ring, 0);
-
-		ring_data->fini_process(ring_data);
+		if (ring_data->fini_process)
+			ring_data->fini_process(ring_data);
 		return 0;
 	}
 
@@ -1720,6 +1720,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 {
 	struct hnae_handle *h = priv->ae_handle;
 	struct hns_nic_ring_data *rd;
+	bool is_ver1 = AE_IS_VER1(priv->enet_ver);
 	int i;
 
 	if (h->q_num > NIC_MAX_Q_PER_VF) {
@@ -1737,7 +1738,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		rd->queue_index = i;
 		rd->ring = &h->qs[i]->tx_ring;
 		rd->poll_one = hns_nic_tx_poll_one;
-		rd->fini_process = hns_nic_tx_fini_pro;
+		rd->fini_process = is_ver1 ? hns_nic_tx_fini_pro : NULL;
 
 		netif_napi_add(priv->netdev, &rd->napi,
 			       hns_nic_common_poll, NIC_TX_CLEAN_MAX_NUM);
@@ -1749,7 +1750,7 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		rd->ring = &h->qs[i - h->q_num]->rx_ring;
 		rd->poll_one = hns_nic_rx_poll_one;
 		rd->ex_process = hns_nic_rx_up_pro;
-		rd->fini_process = hns_nic_rx_fini_pro;
+		rd->fini_process = is_ver1 ? hns_nic_rx_fini_pro : NULL;
 
 		netif_napi_add(priv->netdev, &rd->napi,
 			       hns_nic_common_poll, NIC_RX_CLEAN_MAX_NUM);
-- 
1.9.1
