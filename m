From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2 for-next 3/8] net: hns: add fini_process for v2 napi process
Date: Thu, 29 Sep 2016 18:09:11 +0100
Message-ID: <20160929170916.631972-4-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160929170916.631972-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>

This patch adds fini_process for v2, it handles the packets recevied
by the hardware in the napi porcess. With this patch, the hardware irq
numbers will drop 50% per sec.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Reviewed-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   45 +++++++++++++++++++++----
 1 file changed, 38 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 32ff270..e6bfc51 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -823,6 +823,8 @@ static void hns_nic_rx_fini_pro(struct hns_nic_ring_data *ring_data)
 	struct hnae_ring *ring = ring_data->ring;
 	int num = 0;
 
+	ring_data->ring->q->handle->dev->ops->toggle_ring_irq(ring, 0);
+
 	/* for hardware bug fixed */
 	num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
 
@@ -834,6 +836,20 @@ static void hns_nic_rx_fini_pro(struct hns_nic_ring_data *ring_data)
 	}
 }
 
+static void hns_nic_rx_fini_pro_v2(struct hns_nic_ring_data *ring_data)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	int num = 0;
+
+	num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
+
+	if (num == 0)
+		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
+			ring, 0);
+	else
+		napi_schedule(&ring_data->napi);
+}
+
 static inline void hns_nic_reclaim_one_desc(struct hnae_ring *ring,
 					    int *bytes, int *pkts)
 {
@@ -935,7 +951,11 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
-	int head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
+	int head;
+
+	ring_data->ring->q->handle->dev->ops->toggle_ring_irq(ring, 0);
+
+	head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
 
 	if (head != ring->next_to_clean) {
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
@@ -945,6 +965,18 @@ static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 	}
 }
 
+static void hns_nic_tx_fini_pro_v2(struct hns_nic_ring_data *ring_data)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	int head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
+
+	if (head == ring->next_to_clean)
+		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
+			ring, 0);
+	else
+		napi_schedule(&ring_data->napi);
+}
+
 static void hns_nic_tx_clr_all_bufs(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
@@ -976,10 +1008,7 @@ static int hns_nic_common_poll(struct napi_struct *napi, int budget)
 
 	if (clean_complete >= 0 && clean_complete < budget) {
 		napi_complete(napi);
-		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
-			ring_data->ring, 0);
-		if (ring_data->fini_process)
-			ring_data->fini_process(ring_data);
+		ring_data->fini_process(ring_data);
 		return 0;
 	}
 
@@ -1755,7 +1784,8 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		rd->queue_index = i;
 		rd->ring = &h->qs[i]->tx_ring;
 		rd->poll_one = hns_nic_tx_poll_one;
-		rd->fini_process = is_ver1 ? hns_nic_tx_fini_pro : NULL;
+		rd->fini_process = is_ver1 ? hns_nic_tx_fini_pro :
+			hns_nic_tx_fini_pro_v2;
 
 		netif_napi_add(priv->netdev, &rd->napi,
 			       hns_nic_common_poll, NIC_TX_CLEAN_MAX_NUM);
@@ -1767,7 +1797,8 @@ static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
 		rd->ring = &h->qs[i - h->q_num]->rx_ring;
 		rd->poll_one = hns_nic_rx_poll_one;
 		rd->ex_process = hns_nic_rx_up_pro;
-		rd->fini_process = is_ver1 ? hns_nic_rx_fini_pro : NULL;
+		rd->fini_process = is_ver1 ? hns_nic_rx_fini_pro :
+			hns_nic_rx_fini_pro_v2;
 
 		netif_napi_add(priv->netdev, &rd->napi,
 			       hns_nic_common_poll, NIC_RX_CLEAN_MAX_NUM);
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
