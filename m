From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] ixgbe: fix spinlock recursion with netpoll and busy poll
Date: Fri, 14 Mar 2014 02:47:12 -0700
Message-ID: <1394790446-31591-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>, stable <stable@vger.kernel.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32977 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755800AbaCNJr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:47:29 -0400
In-Reply-To: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves a hang with busy poll when used with netconsole.

The main change is the check for netpoll packets in ixgbe_poll() which
prevents a call to spin_lock_bh() while interrupts are disabled.

In addition it removes the call to netif_rx() since netif_receive_skb()
can deal with netpoll packets and also replaced the global adapter flag
with per-q_vector bool that indicates Rx packet from netpoll which
should help with performance.

CC: Arun Sharma <asharma@fb.com>
CC: stable <stable@vger.kernel.org>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 18 +++++++++---------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 2fff0fc..d34abbc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -386,6 +386,7 @@ struct ixgbe_q_vector {
 	int numa_node;
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[IFNAMSIZ + 9];
+	bool netpoll_rx;
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int state;
@@ -643,7 +644,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 4)
 #define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 5)
 #define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 6)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 7)
+
 #define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
 #define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 9)
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 10)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8bea6ca..06aab2c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1670,14 +1670,10 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-
-	if (ixgbe_qv_busy_polling(q_vector))
+	if (ixgbe_qv_busy_polling(q_vector) || q_vector->netpoll_rx)
 		netif_receive_skb(skb);
-	else if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(&q_vector->napi, skb);
 	else
-		netif_rx(skb);
+		napi_gro_receive(&q_vector->napi, skb);
 }
 
 /**
@@ -2159,6 +2155,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	u64_stats_update_end(&rx_ring->syncp);
 	q_vector->rx.total_packets += total_rx_packets;
 	q_vector->rx.total_bytes += total_rx_bytes;
+	q_vector->netpoll_rx = false;
 
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
@@ -2758,6 +2755,9 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	ixgbe_for_each_ring(ring, q_vector->tx)
 		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
+	if (test_bit(NAPI_STATE_NPSVC, &napi->state))
+		return budget;
+
 	if (!ixgbe_qv_lock_napi(q_vector))
 		return budget;
 
@@ -7273,14 +7273,14 @@ static void ixgbe_netpoll(struct net_device *netdev)
 	if (test_bit(__IXGBE_DOWN, &adapter->state))
 		return;
 
-	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		for (i = 0; i < adapter->num_q_vectors; i++)
+		for (i = 0; i < adapter->num_q_vectors; i++) {
+			adapter->q_vector[i]->netpoll_rx = true;
 			ixgbe_msix_clean_rings(0, adapter->q_vector[i]);
+		}
 	} else {
 		ixgbe_intr(adapter->pdev->irq, netdev);
 	}
-	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
 }
 
 #endif
-- 
1.8.3.1
