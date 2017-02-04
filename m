From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 9/9] qla3xxx: add GRO support
Date: Sat,  4 Feb 2017 10:20:38 -0800
Message-ID: <20170204182038.3752-10-edumazet@google.com>
References: <20170204182038.3752-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35320 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdBDSVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 13:21:35 -0500
Received: by mail-pg0-f52.google.com with SMTP id 194so15904408pgd.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 10:21:35 -0800 (PST)
In-Reply-To: <20170204182038.3752-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 5c100ab86c0046ec72a011e5f806d6557ac7..6e28a0d1b6cee46f13573b97bf3818fac76a 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2025,7 +2025,7 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 	skb_checksum_none_assert(skb);
 	skb->protocol = eth_type_trans(skb, qdev->ndev);
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&qdev->napi, skb);
 	lrg_buf_cb2->skb = NULL;
 
 	if (qdev->device_id == QL3022_DEVICE_ID)
@@ -2095,7 +2095,7 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 	}
 	skb2->protocol = eth_type_trans(skb2, qdev->ndev);
 
-	netif_receive_skb(skb2);
+	napi_gro_receive(&qdev->napi, skb2);
 	ndev->stats.rx_packets++;
 	ndev->stats.rx_bytes += length;
 	lrg_buf_cb2->skb = NULL;
@@ -2105,8 +2105,7 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
 }
 
-static int ql_tx_rx_clean(struct ql3_adapter *qdev,
-			  int *tx_cleaned, int *rx_cleaned, int work_to_do)
+static int ql_tx_rx_clean(struct ql3_adapter *qdev, int budget)
 {
 	struct net_rsp_iocb *net_rsp;
 	struct net_device *ndev = qdev->ndev;
@@ -2114,7 +2113,7 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 
 	/* While there are entries in the completion queue. */
 	while ((le32_to_cpu(*(qdev->prsp_producer_index)) !=
-		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
+		qdev->rsp_consumer_index) && (work_done < budget)) {
 
 		net_rsp = qdev->rsp_current;
 		rmb();
@@ -2130,21 +2129,20 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		case OPCODE_OB_MAC_IOCB_FN2:
 			ql_process_mac_tx_intr(qdev, (struct ob_mac_iocb_rsp *)
 					       net_rsp);
-			(*tx_cleaned)++;
 			break;
 
 		case OPCODE_IB_MAC_IOCB:
 		case OPCODE_IB_3032_MAC_IOCB:
 			ql_process_mac_rx_intr(qdev, (struct ib_mac_iocb_rsp *)
 					       net_rsp);
-			(*rx_cleaned)++;
+			work_done++;
 			break;
 
 		case OPCODE_IB_IP_IOCB:
 		case OPCODE_IB_3032_IP_IOCB:
 			ql_process_macip_rx_intr(qdev, (struct ib_ip_iocb_rsp *)
 						 net_rsp);
-			(*rx_cleaned)++;
+			work_done++;
 			break;
 		default: {
 			u32 *tmp = (u32 *)net_rsp;
@@ -2169,7 +2167,6 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 			qdev->rsp_current++;
 		}
 
-		work_done = *tx_cleaned + *rx_cleaned;
 	}
 
 	return work_done;
@@ -2178,25 +2175,25 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 static int ql_poll(struct napi_struct *napi, int budget)
 {
 	struct ql3_adapter *qdev = container_of(napi, struct ql3_adapter, napi);
-	int rx_cleaned = 0, tx_cleaned = 0;
-	unsigned long hw_flags;
 	struct ql3xxx_port_registers __iomem *port_regs =
 		qdev->mem_map_registers;
+	int work_done;
 
-	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, budget);
+	work_done = ql_tx_rx_clean(qdev, budget);
 
-	if (tx_cleaned + rx_cleaned != budget) {
-		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-		__napi_complete(napi);
+	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&qdev->hw_lock, flags);
 		ql_update_small_bufq_prod_index(qdev);
 		ql_update_lrg_bufq_prod_index(qdev);
 		writel(qdev->rsp_consumer_index,
 			    &port_regs->CommonRegs.rspQConsumerIndex);
-		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+		spin_unlock_irqrestore(&qdev->hw_lock, flags);
 
 		ql_enable_interrupts(qdev);
 	}
-	return tx_cleaned + rx_cleaned;
+	return work_done;
 }
 
 static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
-- 
2.11.0.483.g087da7b7c-goog
