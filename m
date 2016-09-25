From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40evf: enable adaptive interrupt throttling
Date: Sat, 24 Sep 2016 23:42:43 -0700
Message-ID: <1474785769-54665-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:18328 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965662AbcIYGmz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:55 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

All of the code to support adaptive interrupt throttling is already in
the interrupt handler, it just needs to be enabled. Fill out the data
structures properly to make it happen. Single-flow traffic tests may
show slightly lower throughput, but interrupts per second will drop by
about 75%.

Change-ID: I9cd7d42c025b906bf1bb85c6aeb6112684aa6471
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 064419e..302c974 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -370,6 +370,8 @@ i40evf_map_vector_to_rxq(struct i40evf_adapter *adapter, int v_idx, int r_idx)
 {
 	struct i40e_q_vector *q_vector = &adapter->q_vectors[v_idx];
 	struct i40e_ring *rx_ring = &adapter->rx_rings[r_idx];
+	struct i40e_vsi *vsi = &adapter->vsi;
+	struct i40e_hw *hw = &adapter->hw;
 
 	rx_ring->q_vector = q_vector;
 	rx_ring->next = q_vector->rx.ring;
@@ -377,7 +379,10 @@ i40evf_map_vector_to_rxq(struct i40evf_adapter *adapter, int v_idx, int r_idx)
 	q_vector->rx.ring = rx_ring;
 	q_vector->rx.count++;
 	q_vector->rx.latency_range = I40E_LOW_LATENCY;
+	q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
+	q_vector->ring_mask |= BIT(r_idx);
 	q_vector->itr_countdown = ITR_COUNTDOWN_START;
+	wr32(hw, I40E_VFINT_ITRN1(I40E_RX_ITR, v_idx - 1), q_vector->rx.itr);
 }
 
 /**
@@ -391,6 +396,8 @@ i40evf_map_vector_to_txq(struct i40evf_adapter *adapter, int v_idx, int t_idx)
 {
 	struct i40e_q_vector *q_vector = &adapter->q_vectors[v_idx];
 	struct i40e_ring *tx_ring = &adapter->tx_rings[t_idx];
+	struct i40e_vsi *vsi = &adapter->vsi;
+	struct i40e_hw *hw = &adapter->hw;
 
 	tx_ring->q_vector = q_vector;
 	tx_ring->next = q_vector->tx.ring;
@@ -398,9 +405,10 @@ i40evf_map_vector_to_txq(struct i40evf_adapter *adapter, int v_idx, int t_idx)
 	q_vector->tx.ring = tx_ring;
 	q_vector->tx.count++;
 	q_vector->tx.latency_range = I40E_LOW_LATENCY;
+	q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
 	q_vector->itr_countdown = ITR_COUNTDOWN_START;
 	q_vector->num_ringpairs++;
-	q_vector->ring_mask |= BIT(t_idx);
+	wr32(hw, I40E_VFINT_ITRN1(I40E_TX_ITR, v_idx - 1), q_vector->tx.itr);
 }
 
 /**
@@ -2269,10 +2277,8 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 	adapter->vsi.back = adapter;
 	adapter->vsi.base_vector = 1;
 	adapter->vsi.work_limit = I40E_DEFAULT_IRQ_WORK;
-	adapter->vsi.rx_itr_setting = (I40E_ITR_DYNAMIC |
-				       ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
-	adapter->vsi.tx_itr_setting = (I40E_ITR_DYNAMIC |
-				       ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
+	adapter->vsi.rx_itr_setting = (I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF);
+	adapter->vsi.tx_itr_setting = (I40E_ITR_DYNAMIC | I40E_ITR_TX_DEF);
 	vsi->netdev = adapter->netdev;
 	vsi->qs_handle = adapter->vsi_res->qset_handle;
 	if (vfres->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF) {
-- 
2.7.4
