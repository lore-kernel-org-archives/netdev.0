From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ixgbe: get rid of custom busy polling code
Date: Thu, 02 Feb 2017 16:26:39 -0800
Message-ID: <1486081599.21871.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34894 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbdBCA0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 19:26:42 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so272474pfa.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 16:26:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In linux-4.5, busy polling was implemented in core
NAPI stack, meaning that all custom implementation can
be removed from drivers.

Not only we remove lot's of code, we also remove one lock
operation in fast path, and allow GRO to do its job.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  125 -------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   40 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |    5 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   59 ------
 4 files changed, 5 insertions(+), 224 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index aeedc812ee2707b412922afa8d54dfe9a0cf3591..e83444c34cf9c064a6ec2b072f49d098283edab6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -55,9 +55,6 @@
 
 #include <net/busy_poll.h>
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-#define BP_EXTENDED_STATS
-#endif
 /* common prefix used by pr_<> macros */
 #undef pr_fmt
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -201,11 +198,6 @@ struct ixgbe_rx_buffer {
 struct ixgbe_queue_stats {
 	u64 packets;
 	u64 bytes;
-#ifdef BP_EXTENDED_STATS
-	u64 yields;
-	u64 misses;
-	u64 cleaned;
-#endif  /* BP_EXTENDED_STATS */
 };
 
 struct ixgbe_tx_queue_stats {
@@ -399,127 +391,10 @@ struct ixgbe_q_vector {
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[IFNAMSIZ + 9];
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	atomic_t state;
-#endif  /* CONFIG_NET_RX_BUSY_POLL */
-
 	/* for dynamic allocation of rings associated with this q_vector */
 	struct ixgbe_ring ring[0] ____cacheline_internodealigned_in_smp;
 };
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-enum ixgbe_qv_state_t {
-	IXGBE_QV_STATE_IDLE = 0,
-	IXGBE_QV_STATE_NAPI,
-	IXGBE_QV_STATE_POLL,
-	IXGBE_QV_STATE_DISABLE
-};
-
-static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
-{
-	/* reset state to idle */
-	atomic_set(&q_vector->state, IXGBE_QV_STATE_IDLE);
-}
-
-/* called from the device poll routine to get ownership of a q_vector */
-static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
-{
-	int rc = atomic_cmpxchg(&q_vector->state, IXGBE_QV_STATE_IDLE,
-				IXGBE_QV_STATE_NAPI);
-#ifdef BP_EXTENDED_STATS
-	if (rc != IXGBE_QV_STATE_IDLE)
-		q_vector->tx.ring->stats.yields++;
-#endif
-
-	return rc == IXGBE_QV_STATE_IDLE;
-}
-
-/* returns true is someone tried to get the qv while napi had it */
-static inline void ixgbe_qv_unlock_napi(struct ixgbe_q_vector *q_vector)
-{
-	WARN_ON(atomic_read(&q_vector->state) != IXGBE_QV_STATE_NAPI);
-
-	/* flush any outstanding Rx frames */
-	if (q_vector->napi.gro_list)
-		napi_gro_flush(&q_vector->napi, false);
-
-	/* reset state to idle */
-	atomic_set(&q_vector->state, IXGBE_QV_STATE_IDLE);
-}
-
-/* called from ixgbe_low_latency_poll() */
-static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
-{
-	int rc = atomic_cmpxchg(&q_vector->state, IXGBE_QV_STATE_IDLE,
-				IXGBE_QV_STATE_POLL);
-#ifdef BP_EXTENDED_STATS
-	if (rc != IXGBE_QV_STATE_IDLE)
-		q_vector->rx.ring->stats.yields++;
-#endif
-	return rc == IXGBE_QV_STATE_IDLE;
-}
-
-/* returns true if someone tried to get the qv while it was locked */
-static inline void ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
-{
-	WARN_ON(atomic_read(&q_vector->state) != IXGBE_QV_STATE_POLL);
-
-	/* reset state to idle */
-	atomic_set(&q_vector->state, IXGBE_QV_STATE_IDLE);
-}
-
-/* true if a socket is polling, even if it did not get the lock */
-static inline bool ixgbe_qv_busy_polling(struct ixgbe_q_vector *q_vector)
-{
-	return atomic_read(&q_vector->state) == IXGBE_QV_STATE_POLL;
-}
-
-/* false if QV is currently owned */
-static inline bool ixgbe_qv_disable(struct ixgbe_q_vector *q_vector)
-{
-	int rc = atomic_cmpxchg(&q_vector->state, IXGBE_QV_STATE_IDLE,
-				IXGBE_QV_STATE_DISABLE);
-
-	return rc == IXGBE_QV_STATE_IDLE;
-}
-
-#else /* CONFIG_NET_RX_BUSY_POLL */
-static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
-{
-}
-
-static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
-{
-	return true;
-}
-
-static inline bool ixgbe_qv_unlock_napi(struct ixgbe_q_vector *q_vector)
-{
-	return false;
-}
-
-static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
-{
-	return false;
-}
-
-static inline bool ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
-{
-	return false;
-}
-
-static inline bool ixgbe_qv_busy_polling(struct ixgbe_q_vector *q_vector)
-{
-	return false;
-}
-
-static inline bool ixgbe_qv_disable(struct ixgbe_q_vector *q_vector)
-{
-	return true;
-}
-
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 #ifdef CONFIG_IXGBE_HWMON
 
 #define IXGBE_HWMON_TYPE_LOC		0
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 17589068da78617c8a3d9e81d07cfb307d2a7df8..ee28e54a4f75ede10aa91441405094776eb68107 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1179,12 +1179,6 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i] = 0;
 			data[i+1] = 0;
 			i += 2;
-#ifdef BP_EXTENDED_STATS
-			data[i] = 0;
-			data[i+1] = 0;
-			data[i+2] = 0;
-			i += 3;
-#endif
 			continue;
 		}
 
@@ -1194,12 +1188,6 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i+1] = ring->stats.bytes;
 		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 		i += 2;
-#ifdef BP_EXTENDED_STATS
-		data[i] = ring->stats.yields;
-		data[i+1] = ring->stats.misses;
-		data[i+2] = ring->stats.cleaned;
-		i += 3;
-#endif
 	}
 	for (j = 0; j < IXGBE_NUM_RX_QUEUES; j++) {
 		ring = adapter->rx_ring[j];
@@ -1207,12 +1195,6 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i] = 0;
 			data[i+1] = 0;
 			i += 2;
-#ifdef BP_EXTENDED_STATS
-			data[i] = 0;
-			data[i+1] = 0;
-			data[i+2] = 0;
-			i += 3;
-#endif
 			continue;
 		}
 
@@ -1222,12 +1204,6 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i+1] = ring->stats.bytes;
 		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 		i += 2;
-#ifdef BP_EXTENDED_STATS
-		data[i] = ring->stats.yields;
-		data[i+1] = ring->stats.misses;
-		data[i+2] = ring->stats.cleaned;
-		i += 3;
-#endif
 	}
 
 	for (j = 0; j < IXGBE_MAX_PACKET_BUFFERS; j++) {
@@ -1264,28 +1240,12 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "tx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
-#ifdef BP_EXTENDED_STATS
-			sprintf(p, "tx_queue_%u_bp_napi_yield", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "tx_queue_%u_bp_misses", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "tx_queue_%u_bp_cleaned", i);
-			p += ETH_GSTRING_LEN;
-#endif /* BP_EXTENDED_STATS */
 		}
 		for (i = 0; i < IXGBE_NUM_RX_QUEUES; i++) {
 			sprintf(p, "rx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
-#ifdef BP_EXTENDED_STATS
-			sprintf(p, "rx_queue_%u_bp_poll_yield", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rx_queue_%u_bp_misses", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rx_queue_%u_bp_cleaned", i);
-			p += ETH_GSTRING_LEN;
-#endif /* BP_EXTENDED_STATS */
 		}
 		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
 			sprintf(p, "tx_pb_%u_pxon", i);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 10d29678d65e22ee1552c3c04c507ad35313c16b..1b8be7d813bd992bc8e869f6c458d5197ac44fc4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -853,11 +853,6 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	netif_napi_add(adapter->netdev, &q_vector->napi,
 		       ixgbe_poll, 64);
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	/* initialize busy poll */
-	atomic_set(&q_vector->state, IXGBE_QV_STATE_DISABLE);
-
-#endif
 	/* tie q_vector and adapter together */
 	adapter->q_vector[v_idx] = q_vector;
 	q_vector->adapter = adapter;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3b3b52b62a5fefe530e7b32dcde6d04e643fd67d..86135c00d4b123eba1967845bf2ee3b3dd7663ec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1720,11 +1720,7 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
-	skb_mark_napi_id(skb, &q_vector->napi);
-	if (ixgbe_qv_busy_polling(q_vector))
-		netif_receive_skb(skb);
-	else
-		napi_gro_receive(&q_vector->napi, skb);
+	napi_gro_receive(&q_vector->napi, skb);
 }
 
 /**
@@ -2201,40 +2197,6 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	return total_rx_packets;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-/* must be called with local_bh_disable()d */
-static int ixgbe_low_latency_recv(struct napi_struct *napi)
-{
-	struct ixgbe_q_vector *q_vector =
-			container_of(napi, struct ixgbe_q_vector, napi);
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring  *ring;
-	int found = 0;
-
-	if (test_bit(__IXGBE_DOWN, &adapter->state))
-		return LL_FLUSH_FAILED;
-
-	if (!ixgbe_qv_lock_poll(q_vector))
-		return LL_FLUSH_BUSY;
-
-	ixgbe_for_each_ring(ring, q_vector->rx) {
-		found = ixgbe_clean_rx_irq(q_vector, ring, 4);
-#ifdef BP_EXTENDED_STATS
-		if (found)
-			ring->stats.cleaned += found;
-		else
-			ring->stats.misses++;
-#endif
-		if (found)
-			break;
-	}
-
-	ixgbe_qv_unlock_poll(q_vector);
-
-	return found;
-}
-#endif	/* CONFIG_NET_RX_BUSY_POLL */
-
 /**
  * ixgbe_configure_msix - Configure MSI-X hardware
  * @adapter: board private structure
@@ -2878,8 +2840,8 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 			clean_complete = false;
 	}
 
-	/* Exit if we are called by netpoll or busy polling is active */
-	if ((budget <= 0) || !ixgbe_qv_lock_napi(q_vector))
+	/* Exit if we are called by netpoll */
+	if (budget <= 0)
 		return budget;
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
@@ -2898,7 +2860,6 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 			clean_complete = false;
 	}
 
-	ixgbe_qv_unlock_napi(q_vector);
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
 		return budget;
@@ -4581,23 +4542,16 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
 
-	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
-		ixgbe_qv_init_lock(adapter->q_vector[q_idx]);
+	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
 		napi_enable(&adapter->q_vector[q_idx]->napi);
-	}
 }
 
 static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
 
-	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
+	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
 		napi_disable(&adapter->q_vector[q_idx]->napi);
-		while (!ixgbe_qv_disable(adapter->q_vector[q_idx])) {
-			pr_info("QV %d locked\n", q_idx);
-			usleep_range(1000, 20000);
-		}
-	}
 }
 
 static void ixgbe_clear_udp_tunnel_port(struct ixgbe_adapter *adapter, u32 mask)
@@ -9352,9 +9306,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= ixgbe_low_latency_recv,
-#endif
 #ifdef IXGBE_FCOE
 	.ndo_fcoe_ddp_setup = ixgbe_fcoe_ddp_get,
 	.ndo_fcoe_ddp_target = ixgbe_fcoe_ddp_target,
