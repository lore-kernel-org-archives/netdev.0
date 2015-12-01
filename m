From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 20/26] mlxsw: pci: Implement LAG processing for received packets
Date: Tue,  1 Dec 2015 14:48:58 +0100
Message-ID: <1448977744-17930-21-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34377 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756288AbbLANtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:33 -0500
Received: by wmvv187 with SMTP id v187so207547437wmv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:32 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Completion queue element for receive queue provides information if the
packet was received via LAG port. Extract this info and pass it along
to core.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 19 ++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/pci.h |  4 +++-
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 8ca66a0..d2102e5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -686,12 +686,14 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	if (q->consumer_counter++ != consumer_counter_limit)
 		dev_dbg_ratelimited(&pdev->dev, "Consumer counter does not match limit in RDQ\n");
 
-	/* We do not support lag now */
-	if (mlxsw_pci_cqe_lag_get(cqe))
-		goto drop;
-
-	rx_info.is_lag = false;
-	rx_info.u.sys_port = mlxsw_pci_cqe_system_port_get(cqe);
+	if (mlxsw_pci_cqe_lag_get(cqe)) {
+		rx_info.is_lag = true;
+		rx_info.u.lag_id = mlxsw_pci_cqe_lag_id_get(cqe);
+		rx_info.lag_port_index = mlxsw_pci_cqe_lag_port_index_get(cqe);
+	} else {
+		rx_info.is_lag = false;
+		rx_info.u.sys_port = mlxsw_pci_cqe_system_port_get(cqe);
+	}
 
 	rx_info.trap_id = mlxsw_pci_cqe_trap_id_get(cqe);
 
@@ -701,7 +703,6 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 	skb_put(skb, byte_count);
 	mlxsw_core_skb_receive(mlxsw_pci->core, skb, &rx_info);
 
-put_new_skb:
 	memset(wqe, 0, q->elem_size);
 	err = mlxsw_pci_rdq_skb_alloc(mlxsw_pci, elem_info);
 	if (err)
@@ -710,10 +711,6 @@ put_new_skb:
 	q->producer_counter++;
 	mlxsw_pci_queue_doorbell_producer_ring(mlxsw_pci, q);
 	return;
-
-drop:
-	dev_kfree_skb_any(skb);
-	goto put_new_skb;
 }
 
 static char *mlxsw_pci_cq_sw_cqe_get(struct mlxsw_pci_queue *q)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index 142f33d..9121060 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -129,13 +129,15 @@ MLXSW_ITEM64_INDEXED(pci, wqe, address, 0x08, 0, 64, 0x8, 0x0, false);
  */
 MLXSW_ITEM32(pci, cqe, lag, 0x00, 23, 1);
 
-/* pci_cqe_system_port
+/* pci_cqe_system_port/lag_id
  * When lag=0: System port on which the packet was received
  * When lag=1:
  * bits [15:4] LAG ID on which the packet was received
  * bits [3:0] sub_port on which the packet was received
  */
 MLXSW_ITEM32(pci, cqe, system_port, 0x00, 0, 16);
+MLXSW_ITEM32(pci, cqe, lag_id, 0x00, 4, 12);
+MLXSW_ITEM32(pci, cqe, lag_port_index, 0x00, 0, 4);
 
 /* pci_cqe_wqe_counter
  * WQE count of the WQEs completed on the associated dqn
-- 
1.9.3
