From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH net-next] net-next/hinic: Set Rxq irq to specific cpu for NUMA
Date: Wed, 27 Sep 2017 01:57:50 +0800
Message-ID: <1506448670-51213-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set Rxq irq to specific cpu for allocating and receiving the skb from
the same node.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_rx.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.c b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
index 1d4f712..e2e5cdc 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_rx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
@@ -26,6 +26,7 @@
 #include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
 #include <linux/prefetch.h>
+#include <linux/cpumask.h>
 #include <asm/barrier.h>
 
 #include "hinic_common.h"
@@ -171,11 +172,10 @@ static int rx_alloc_pkts(struct hinic_rxq *rxq)
 	struct hinic_sge sge;
 	dma_addr_t dma_addr;
 	struct sk_buff *skb;
-	int i, alloc_more;
 	u16 prod_idx;
+	int i;
 
 	free_wqebbs = hinic_get_rq_free_wqebbs(rxq->rq);
-	alloc_more = 0;
 
 	/* Limit the allocation chunks */
 	if (free_wqebbs > nic_dev->rx_weight)
@@ -185,7 +185,6 @@ static int rx_alloc_pkts(struct hinic_rxq *rxq)
 		skb = rx_alloc_skb(rxq, &dma_addr);
 		if (!skb) {
 			netdev_err(rxq->netdev, "Failed to alloc Rx skb\n");
-			alloc_more = 1;
 			goto skb_out;
 		}
 
@@ -195,7 +194,6 @@ static int rx_alloc_pkts(struct hinic_rxq *rxq)
 					  &prod_idx);
 		if (!rq_wqe) {
 			rx_free_skb(rxq, skb, dma_addr);
-			alloc_more = 1;
 			goto skb_out;
 		}
 
@@ -211,9 +209,7 @@ static int rx_alloc_pkts(struct hinic_rxq *rxq)
 		hinic_rq_update(rxq->rq, prod_idx);
 	}
 
-	if (alloc_more)
-		tasklet_schedule(&rxq->rx_task);
-
+	tasklet_schedule(&rxq->rx_task);
 	return i;
 }
 
@@ -357,7 +353,7 @@ static int rxq_recv(struct hinic_rxq *rxq, int budget)
 	}
 
 	if (pkts)
-		tasklet_schedule(&rxq->rx_task); /* hinic_rx_alloc_pkts */
+		tasklet_schedule(&rxq->rx_task); /* rx_alloc_pkts */
 
 	u64_stats_update_begin(&rxq->rxq_stats.syncp);
 	rxq->rxq_stats.pkts += pkts;
@@ -417,6 +413,8 @@ static int rx_request_irq(struct hinic_rxq *rxq)
 	struct hinic_dev *nic_dev = netdev_priv(rxq->netdev);
 	struct hinic_hwdev *hwdev = nic_dev->hwdev;
 	struct hinic_rq *rq = rxq->rq;
+	struct hinic_qp *qp;
+	struct cpumask mask;
 	int err;
 
 	rx_add_napi(rxq);
@@ -432,7 +430,9 @@ static int rx_request_irq(struct hinic_rxq *rxq)
 		return err;
 	}
 
-	return 0;
+	qp = container_of(rq, struct hinic_qp, rq);
+	cpumask_set_cpu(qp->q_id % num_online_cpus(), &mask);
+	return irq_set_affinity_hint(rq->irq, &mask);
 }
 
 static void rx_free_irq(struct hinic_rxq *rxq)
-- 
1.9.1
