From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH net-next] net-next/hinic: Fix a case of Tx Queue is Stopped forever
Date: Wed, 27 Sep 2017 02:11:33 +0800
Message-ID: <1506449493-83395-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the following scenario:
1. tx_free_poll is running on cpu X
2. xmit function is running on cpu Y and fails to get sq wqe
3. tx_free_poll frees wqes on cpu X and checks the queue is not stopped
4. xmit function stops the queue after failed to get sq wqe
5. The queue is stopped forever

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_tx.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.c b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
index abe3e38..9128858 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_tx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
@@ -212,10 +212,19 @@ netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	sq_wqe = hinic_sq_get_wqe(txq->sq, wqe_size, &prod_idx);
 	if (!sq_wqe) {
-		tx_unmap_skb(nic_dev, skb, txq->sges);
-
 		netif_stop_subqueue(netdev, qp->q_id);
 
+		/* Check for the case free_tx_poll is called in another cpu
+		 * and we stopped the subqueue after free_tx_poll check.
+		 */
+		sq_wqe = hinic_sq_get_wqe(txq->sq, wqe_size, &prod_idx);
+		if (sq_wqe) {
+			netif_wake_subqueue(nic_dev->netdev, qp->q_id);
+			goto process_sq_wqe;
+		}
+
+		tx_unmap_skb(nic_dev, skb, txq->sges);
+
 		u64_stats_update_begin(&txq->txq_stats.syncp);
 		txq->txq_stats.tx_busy++;
 		u64_stats_update_end(&txq->txq_stats.syncp);
@@ -223,6 +232,7 @@ netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		goto flush_skbs;
 	}
 
+process_sq_wqe:
 	hinic_sq_prepare_wqe(txq->sq, prod_idx, sq_wqe, txq->sges, nr_sges);
 
 	hinic_sq_write_wqe(txq->sq, prod_idx, sq_wqe, skb, wqe_size);
-- 
1.9.1
