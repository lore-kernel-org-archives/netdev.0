From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/17] drivers/net/intel: use napi_complete_done()
Date: Fri, 16 Oct 2015 05:10:12 -0700
Message-ID: <1444997425-3396-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14653 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754124AbbJPMKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:40 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As per Eric Dumazet's previous patches:
(see commit (24d2e4a50737) - tg3: use napi_complete_done())

Quoting verbatim:
Using napi_complete_done() instead of napi_complete() allows
us to use /sys/class/net/ethX/gro_flush_timeout

GRO layer can aggregate more packets if the flush is delayed a bit,
without having to set too big coalescing parameters that impact
latencies.
</end quote>

Tested
configuration: low latency via ethtool -C ethx adaptive-rx off
				rx-usecs 10 adaptive-tx off tx-usecs 15
workload: streaming rx using netperf TCP_MAERTS

igb:
MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET : demo
...
Interim result:  941.48 10^6bits/s over 1.000 seconds ending at 1440193171.589

Alignment      Offset         Bytes    Bytes       Recvs   Bytes    Sends
Local  Remote  Local  Remote  Xfered   Per                 Per
Recv   Send    Recv   Send             Recv (avg)          Send (avg)
    8       8      0       0 1176930056  1475.36    797726   16384.00  71905

MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET : demo
...
Interim result:  941.49 10^6bits/s over 0.997 seconds ending at 1440193142.763

Alignment      Offset         Bytes    Bytes       Recvs   Bytes    Sends
Local  Remote  Local  Remote  Xfered   Per                 Per
Recv   Send    Recv   Send             Recv (avg)          Send (avg)
    8       8      0       0 1175182320  50476.00     23282   16384.00  71816

i40e:
Hard to test because the traffic is incoming so fast (24Gb/s) that GRO
always receives 87kB, even at the highest interrupt rate.

Other drivers were only compile tested.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c     |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c        |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     | 21 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  8 ++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  8 ++++++--
 drivers/net/ethernet/intel/igb/igb_main.c         | 17 +++++++++++------
 drivers/net/ethernet/intel/igbvf/netdev.c         |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 14 +++++++++-----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 ++++++++------
 9 files changed, 55 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 74dc150..fd7be86 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3820,7 +3820,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
 			e1000_irq_enable(adapter);
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2e2ddec0..0a854a4 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2693,7 +2693,7 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
 	if (work_done < weight) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		if (!test_bit(__E1000_DOWN, &adapter->state)) {
 			if (adapter->msix_entries)
 				ew32(IMS, adapter->rx_ring->ims_val);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 537d81a..e76a44c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -593,9 +593,9 @@ static void fm10k_receive_skb(struct fm10k_q_vector *q_vector,
 	napi_gro_receive(&q_vector->napi, skb);
 }
 
-static bool fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
-			       struct fm10k_ring *rx_ring,
-			       int budget)
+static int fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
+			      struct fm10k_ring *rx_ring,
+			      int budget)
 {
 	struct sk_buff *skb = rx_ring->skb;
 	unsigned int total_bytes = 0, total_packets = 0;
@@ -662,7 +662,7 @@ static bool fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
 	q_vector->rx.total_packets += total_packets;
 	q_vector->rx.total_bytes += total_bytes;
 
-	return total_packets < budget;
+	return total_packets;
 }
 
 #define VXLAN_HLEN (sizeof(struct udphdr) + 8)
@@ -1422,7 +1422,7 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	struct fm10k_q_vector *q_vector =
 			       container_of(napi, struct fm10k_q_vector, napi);
 	struct fm10k_ring *ring;
-	int per_ring_budget;
+	int per_ring_budget, work_done = 0;
 	bool clean_complete = true;
 
 	fm10k_for_each_ring(ring, q_vector->tx)
@@ -1436,16 +1436,19 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	else
 		per_ring_budget = budget;
 
-	fm10k_for_each_ring(ring, q_vector->rx)
-		clean_complete &= fm10k_clean_rx_irq(q_vector, ring,
-						     per_ring_budget);
+	fm10k_for_each_ring(ring, q_vector->rx) {
+		int work = fm10k_clean_rx_irq(q_vector, ring, per_ring_budget);
+
+		work_done += work;
+		clean_complete &= !!(work < per_ring_budget);
+	}
 
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
 		return budget;
 
 	/* all work done, exit the polling mode */
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 
 	/* re-enable the q_vector */
 	fm10k_qv_enable(q_vector);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e1fac3b..512707c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1825,7 +1825,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	bool clean_complete = true;
 	bool arm_wb = false;
 	int budget_per_ring;
-	int cleaned;
+	int work_done = 0;
 
 	if (test_bit(__I40E_DOWN, &vsi->state)) {
 		napi_complete(napi);
@@ -1851,10 +1851,14 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	budget_per_ring = max(budget/q_vector->num_ringpairs, 1);
 
 	i40e_for_each_ring(ring, q_vector->rx) {
+		int cleaned;
+
 		if (ring_is_ps_enabled(ring))
 			cleaned = i40e_clean_rx_irq_ps(ring, budget_per_ring);
 		else
 			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
+
+		work_done += cleaned;
 		/* if we didn't clean as many as budgeted, we must be done */
 		clean_complete &= (budget_per_ring != cleaned);
 	}
@@ -1871,7 +1875,7 @@ tx_only:
 		q_vector->arm_wb_state = false;
 
 	/* Work is done so exit the polling mode and re-enable the interrupt */
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
 		i40e_update_enable_itr(vsi, q_vector);
 	} else { /* Legacy mode */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 5d3a8bd..97493a4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1266,7 +1266,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	bool clean_complete = true;
 	bool arm_wb = false;
 	int budget_per_ring;
-	int cleaned;
+	int work_done = 0;
 
 	if (test_bit(__I40E_DOWN, &vsi->state)) {
 		napi_complete(napi);
@@ -1292,10 +1292,14 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	budget_per_ring = max(budget/q_vector->num_ringpairs, 1);
 
 	i40e_for_each_ring(ring, q_vector->rx) {
+		int cleaned;
+
 		if (ring_is_ps_enabled(ring))
 			cleaned = i40e_clean_rx_irq_ps(ring, budget_per_ring);
 		else
 			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
+
+		work_done += cleaned;
 		/* if we didn't clean as many as budgeted, we must be done */
 		clean_complete &= (budget_per_ring != cleaned);
 	}
@@ -1312,7 +1316,7 @@ tx_only:
 		q_vector->arm_wb_state = false;
 
 	/* Work is done so exit the polling mode and re-enable the interrupt */
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	i40e_update_enable_itr(vsi, q_vector);
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7e62675..ea7b098 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -151,7 +151,7 @@ static void igb_setup_dca(struct igb_adapter *);
 #endif /* CONFIG_IGB_DCA */
 static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_tx_irq(struct igb_q_vector *);
-static bool igb_clean_rx_irq(struct igb_q_vector *, int);
+static int igb_clean_rx_irq(struct igb_q_vector *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -6364,6 +6364,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 						     struct igb_q_vector,
 						     napi);
 	bool clean_complete = true;
+	int work_done = 0;
 
 #ifdef CONFIG_IGB_DCA
 	if (q_vector->adapter->flags & IGB_FLAG_DCA_ENABLED)
@@ -6372,15 +6373,19 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	if (q_vector->tx.ring)
 		clean_complete = igb_clean_tx_irq(q_vector);
 
-	if (q_vector->rx.ring)
-		clean_complete &= igb_clean_rx_irq(q_vector, budget);
+	if (q_vector->rx.ring) {
+		int cleaned = igb_clean_rx_irq(q_vector, budget);
+
+		work_done += cleaned;
+		clean_complete &= (cleaned < budget);
+	}
 
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
 		return budget;
 
 	/* If not enough Rx work done, exit the polling mode */
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	igb_ring_irq_enable(q_vector);
 
 	return 0;
@@ -6904,7 +6909,7 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 }
 
-static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
+static int igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 {
 	struct igb_ring *rx_ring = q_vector->rx.ring;
 	struct sk_buff *skb = rx_ring->skb;
@@ -6978,7 +6983,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 	if (cleaned_count)
 		igb_alloc_rx_buffers(rx_ring, cleaned_count);
 
-	return total_packets < budget;
+	return total_packets;
 }
 
 static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index e86d41e..297af80 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1211,7 +1211,7 @@ static int igbvf_poll(struct napi_struct *napi, int budget)
 
 	/* If not enough Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 
 		if (adapter->requested_itr & 3)
 			igbvf_set_itr(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1b2ad39..9f8a7fd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2775,7 +2775,7 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 				container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *ring;
-	int per_ring_budget;
+	int per_ring_budget, work_done = 0;
 	bool clean_complete = true;
 
 #ifdef CONFIG_IXGBE_DCA
@@ -2796,9 +2796,13 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	else
 		per_ring_budget = budget;
 
-	ixgbe_for_each_ring(ring, q_vector->rx)
-		clean_complete &= (ixgbe_clean_rx_irq(q_vector, ring,
-				   per_ring_budget) < per_ring_budget);
+	ixgbe_for_each_ring(ring, q_vector->rx) {
+		int cleaned = ixgbe_clean_rx_irq(q_vector, ring,
+						 per_ring_budget);
+
+		work_done += cleaned;
+		clean_complete &= (cleaned < per_ring_budget);
+	}
 
 	ixgbe_qv_unlock_napi(q_vector);
 	/* If all work not completed, return budget and keep polling */
@@ -2806,7 +2810,7 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 		return budget;
 
 	/* all work done, exit the polling mode */
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	if (adapter->rx_itr_setting & 1)
 		ixgbe_set_itr(q_vector);
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 35da2d7..7570b5c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1008,7 +1008,7 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 		container_of(napi, struct ixgbevf_q_vector, napi);
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	struct ixgbevf_ring *ring;
-	int per_ring_budget;
+	int per_ring_budget, work_done = 0;
 	bool clean_complete = true;
 
 	ixgbevf_for_each_ring(ring, q_vector->tx)
@@ -1027,10 +1027,12 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	else
 		per_ring_budget = budget;
 
-	ixgbevf_for_each_ring(ring, q_vector->rx)
-		clean_complete &= (ixgbevf_clean_rx_irq(q_vector, ring,
-							per_ring_budget)
-				   < per_ring_budget);
+	ixgbevf_for_each_ring(ring, q_vector->rx) {
+		int cleaned = ixgbevf_clean_rx_irq(q_vector, ring,
+						   per_ring_budget);
+		work_done += cleaned;
+		clean_complete &= (cleaned < per_ring_budget);
+	}
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	ixgbevf_qv_unlock_napi(q_vector);
@@ -1040,7 +1042,7 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	if (!clean_complete)
 		return budget;
 	/* all work done, exit the polling mode */
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	if (adapter->rx_itr_setting & 1)
 		ixgbevf_set_itr(q_vector);
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
-- 
2.4.3
