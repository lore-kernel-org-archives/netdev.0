From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e/i40evf: use DECLARE_BITMAP for state
Date: Fri,  6 Oct 2017 10:57:19 -0700
Message-ID: <20171006175727.868-8-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12575 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752591AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

When using set_bit and friends, we should be using actual
bitmaps, and fix all the locations where we might access
it.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    | 3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  | 3 ++-
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 8f326f87a815..6f2725fc50a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -278,8 +278,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 rx_ring->netdev,
 			 rx_ring->rx_bi);
 		dev_info(&pf->pdev->dev,
-			 "    rx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
-			 i, rx_ring->state,
+			 "    rx_rings[%i]: state = %lu, queue_index = %d, reg_idx = %d\n",
+			 i, *rx_ring->state,
 			 rx_ring->queue_index,
 			 rx_ring->reg_idx);
 		dev_info(&pf->pdev->dev,
@@ -334,8 +334,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 tx_ring->netdev,
 			 tx_ring->tx_bi);
 		dev_info(&pf->pdev->dev,
-			 "    tx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
-			 i, tx_ring->state,
+			 "    tx_rings[%i]: state = %lu, queue_index = %d, reg_idx = %d\n",
+			 i, *tx_ring->state,
 			 tx_ring->queue_index,
 			 tx_ring->reg_idx);
 		dev_info(&pf->pdev->dev,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 85132eee9f64..49401be7a2f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2891,7 +2891,7 @@ static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
 		return;
 
 	if ((vsi->tc_config.numtc <= 1) &&
-	    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state)) {
+	    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, ring->state)) {
 		cpu = cpumask_local_spread(ring->q_vector->v_idx, -1);
 		netif_set_xps_queue(ring->netdev, get_cpu_mask(cpu),
 				    ring->queue_index);
@@ -3010,7 +3010,7 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	struct i40e_hmc_obj_rxq rx_ctx;
 	i40e_status err = 0;
 
-	ring->state = 0;
+	bitmap_zero(ring->state, __I40E_RING_STATE_NBITS);
 
 	/* clear the context structure first */
 	memset(&rx_ctx, 0, sizeof(rx_ctx));
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 2f848bc5e391..a4e3e665a1a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -342,6 +342,7 @@ struct i40e_rx_queue_stats {
 enum i40e_ring_state_t {
 	__I40E_TX_FDIR_INIT_DONE,
 	__I40E_TX_XPS_INIT_DONE,
+	__I40E_RING_STATE_NBITS /* must be last */
 };
 
 /* some useful defines for virtchannel interface, which
@@ -366,7 +367,7 @@ struct i40e_ring {
 		struct i40e_tx_buffer *tx_bi;
 		struct i40e_rx_buffer *rx_bi;
 	};
-	unsigned long state;
+	DECLARE_BITMAP(state, __I40E_RING_STATE_NBITS);
 	u16 queue_index;		/* Queue number of ring */
 	u8 dcb_tc;			/* Traffic class of ring */
 	u8 __iomem *tail;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 0d9f98bc07bd..d8ca802a71a9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -325,6 +325,7 @@ struct i40e_rx_queue_stats {
 enum i40e_ring_state_t {
 	__I40E_TX_FDIR_INIT_DONE,
 	__I40E_TX_XPS_INIT_DONE,
+	__I40E_RING_STATE_NBITS /* must be last */
 };
 
 /* some useful defines for virtchannel interface, which
@@ -348,7 +349,7 @@ struct i40e_ring {
 		struct i40e_tx_buffer *tx_bi;
 		struct i40e_rx_buffer *rx_bi;
 	};
-	unsigned long state;
+	DECLARE_BITMAP(state, __I40E_RING_STATE_NBITS);
 	u16 queue_index;		/* Queue number of ring */
 	u8 dcb_tc;			/* Traffic class of ring */
 	u8 __iomem *tail;
-- 
2.14.2
