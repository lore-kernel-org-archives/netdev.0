From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] i40e/i40evf: adjust interrupt throttle less frequently
Date: Fri, 16 Oct 2015 22:28:23 -0700
Message-ID: <1445059711-45992-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49921 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbbJQF2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:49 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The adaptive ITR (interrupt throttle rate) algorithm was adjusting
the hardware's interrupt rate too frequently.  This caused a lot
of variation in the interrupt rate for fairly constant workloads.

Change the code to have a counter and adjust only once every N
number of interrupts.

Change-ID: I0460f1f86571037484eca5aca36ac4d889cb8389
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h          |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 22 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     |  4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 23 +++++++++++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   |  4 ++--
 drivers/net/ethernet/intel/i40evf/i40evf.h      |  2 ++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  2 ++
 8 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index b7818be..7c2b2e8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -577,6 +577,8 @@ struct i40e_q_vector {
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[I40E_INT_NAME_STR_LEN];
 	bool arm_wb_state;
+#define ITR_COUNTDOWN_START 100
+	u8 itr_countdown;	/* when 0 should adjust ITR */
 } ____cacheline_internodealigned_in_smp;
 
 /* lan device */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 11dbb29..b105da1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3107,6 +3107,7 @@ static void i40e_vsi_configure_msix(struct i40e_vsi *vsi)
 	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
 		struct i40e_q_vector *q_vector = vsi->q_vectors[i];
 
+		q_vector->itr_countdown = ITR_COUNTDOWN_START;
 		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
 		q_vector->rx.latency_range = I40E_LOW_LATENCY;
 		wr32(hw, I40E_PFINT_ITRN(I40E_RX_ITR, vector - 1),
@@ -3202,6 +3203,7 @@ static void i40e_configure_msi_and_legacy(struct i40e_vsi *vsi)
 	u32 val;
 
 	/* set the ITR configuration */
+	q_vector->itr_countdown = ITR_COUNTDOWN_START;
 	q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
 	q_vector->rx.latency_range = I40E_LOW_LATENCY;
 	wr32(hw, I40E_PFINT_ITR0(I40E_RX_ITR), q_vector->rx.itr);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 7aea143..006f0fb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -845,10 +845,12 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 * The math works out because the divisor is in 10^(-6) which
 	 * turns the bytes/us input value into MB/s values, but
 	 * make sure to use usecs, as the register values written
-	 * are in 2 usec increments in the ITR registers.
+	 * are in 2 usec increments in the ITR registers, and make sure
+	 * to use the smoothed values that the countdown timer gives us.
 	 */
-	usecs = (rc->itr << 1);
+	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
 	bytes_per_int = rc->total_bytes / usecs;
+
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
@@ -1806,8 +1808,17 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 
 	vector = (q_vector->v_idx + vsi->base_vector);
 
+	/* avoid dynamic calculation if in countdown mode OR if
+	 * all dynamic is disabled
+	 */
 	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
 
+	if (q_vector->itr_countdown > 0 ||
+	    (!ITR_IS_DYNAMIC(vsi->rx_itr_setting) &&
+	     !ITR_IS_DYNAMIC(vsi->tx_itr_setting))) {
+		goto enable_int;
+	}
+
 	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
 		rx = i40e_set_new_dynamic_itr(&q_vector->rx);
 		rxval = i40e_buildreg_itr(I40E_RX_ITR, q_vector->rx.itr);
@@ -1845,8 +1856,15 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 		wr32(hw, INTREG(vector - 1), rxval);
 	}
 
+enable_int:
 	if (!test_bit(__I40E_DOWN, &vsi->state))
 		wr32(hw, INTREG(vector - 1), txval);
+
+	if (q_vector->itr_countdown)
+		q_vector->itr_countdown--;
+	else
+		q_vector->itr_countdown = ITR_COUNTDOWN_START;
+
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 0fe7eb7..6779fb7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -38,8 +38,8 @@
 #define I40E_ITR_8K                0x003E
 #define I40E_ITR_4K                0x007A
 #define I40E_MAX_INTRL             0x3B    /* reg uses 4 usec resolution */
-#define I40E_ITR_RX_DEF            I40E_ITR_8K
-#define I40E_ITR_TX_DEF            I40E_ITR_4K
+#define I40E_ITR_RX_DEF            I40E_ITR_20K
+#define I40E_ITR_TX_DEF            I40E_ITR_20K
 #define I40E_ITR_DYNAMIC           0x8000  /* use top bit as a flag */
 #define I40E_MIN_INT_RATE          250     /* ~= 1000000 / (I40E_MAX_ITR * 2) */
 #define I40E_MAX_INT_RATE          500000  /* == 1000000 / (I40E_MIN_ITR * 2) */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d76fe4a..47e9a90 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -348,10 +348,12 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 * The math works out because the divisor is in 10^(-6) which
 	 * turns the bytes/us input value into MB/s values, but
 	 * make sure to use usecs, as the register values written
-	 * are in 2 usec increments in the ITR registers.
+	 * are in 2 usec increments in the ITR registers, and make sure
+	 * to use the smoothed values that the countdown timer gives us.
 	 */
-	usecs = (rc->itr << 1);
+	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
 	bytes_per_int = rc->total_bytes / usecs;
+
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
@@ -1245,8 +1247,18 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	int vector;
 
 	vector = (q_vector->v_idx + vsi->base_vector);
+
+	/* avoid dynamic calculation if in countdown mode OR if
+	 * all dynamic is disabled
+	 */
 	rxval = txval = i40e_buildreg_itr(I40E_ITR_NONE, 0);
 
+	if (q_vector->itr_countdown > 0 ||
+	    (!ITR_IS_DYNAMIC(vsi->rx_itr_setting) &&
+	     !ITR_IS_DYNAMIC(vsi->tx_itr_setting))) {
+		goto enable_int;
+	}
+
 	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting)) {
 		rx = i40e_set_new_dynamic_itr(&q_vector->rx);
 		rxval = i40e_buildreg_itr(I40E_RX_ITR, q_vector->rx.itr);
@@ -1282,8 +1294,15 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 		wr32(hw, INTREG(vector - 1), rxval);
 	}
 
+enable_int:
 	if (!test_bit(__I40E_DOWN, &vsi->state))
 		wr32(hw, INTREG(vector - 1), txval);
+
+	if (q_vector->itr_countdown)
+		q_vector->itr_countdown--;
+	else
+		q_vector->itr_countdown = ITR_COUNTDOWN_START;
+
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index e2352b8..ebc1bf7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -38,8 +38,8 @@
 #define I40E_ITR_8K                0x003E
 #define I40E_ITR_4K                0x007A
 #define I40E_MAX_INTRL             0x3B    /* reg uses 4 usec resolution */
-#define I40E_ITR_RX_DEF            I40E_ITR_8K
-#define I40E_ITR_TX_DEF            I40E_ITR_4K
+#define I40E_ITR_RX_DEF            I40E_ITR_20K
+#define I40E_ITR_TX_DEF            I40E_ITR_20K
 #define I40E_ITR_DYNAMIC           0x8000  /* use top bit as a flag */
 #define I40E_MIN_INT_RATE          250     /* ~= 1000000 / (I40E_MAX_ITR * 2) */
 #define I40E_MAX_INT_RATE          500000  /* == 1000000 / (I40E_MIN_ITR * 2) */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 22841c6..22fc3d4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -112,6 +112,8 @@ struct i40e_q_vector {
 	struct i40e_ring_container tx;
 	u32 ring_mask;
 	u8 num_ringpairs;	/* total number of ring pairs in vector */
+#define ITR_COUNTDOWN_START 100
+	u8 itr_countdown;	/* when 0 or 1 update ITR */
 	int v_idx;	  /* vector index in list */
 	char name[IFNAMSIZ + 9];
 	bool arm_wb_state;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index ce99790..a44a42b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -357,6 +357,7 @@ i40evf_map_vector_to_rxq(struct i40evf_adapter *adapter, int v_idx, int r_idx)
 	q_vector->rx.ring = rx_ring;
 	q_vector->rx.count++;
 	q_vector->rx.latency_range = I40E_LOW_LATENCY;
+	q_vector->itr_countdown = ITR_COUNTDOWN_START;
 }
 
 /**
@@ -377,6 +378,7 @@ i40evf_map_vector_to_txq(struct i40evf_adapter *adapter, int v_idx, int t_idx)
 	q_vector->tx.ring = tx_ring;
 	q_vector->tx.count++;
 	q_vector->tx.latency_range = I40E_LOW_LATENCY;
+	q_vector->itr_countdown = ITR_COUNTDOWN_START;
 	q_vector->num_ringpairs++;
 	q_vector->ring_mask |= BIT(t_idx);
 }
-- 
2.4.3
