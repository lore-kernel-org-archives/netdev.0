From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e/i40evf: Add support for writeback on ITR feature for X722
Date: Wed,  5 Aug 2015 16:52:06 -0700
Message-ID: <1438818735-38115-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36603 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740AbbHEXwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:20 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

X722 fixes an issue from X710 where TX descriptor WB would not happen if
the interrupts were disabled. In order for the write backs to happen a
bit needs to be set in the dynamic interrupt control register called
WB_ON_ITR. With this feature, the SW driver need not arm SW interrupts to
work around the issue in X710.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 46 +++++++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 38 ++++++++++++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  2 ++
 drivers/net/ethernet/intel/i40evf/i40evf.h    |  1 +
 7 files changed, 74 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 66d0780..0f97883 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -560,6 +560,7 @@ struct i40e_q_vector {
 	cpumask_t affinity_mask;
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[I40E_INT_NAME_STR_LEN];
+	bool arm_wb_state;
 } ____cacheline_internodealigned_in_smp;
 
 /* lan device */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2e84165..28f547c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7071,6 +7071,8 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 		tx_ring->count = vsi->num_desc;
 		tx_ring->size = 0;
 		tx_ring->dcb_tc = 0;
+		if (vsi->back->flags & I40E_FLAG_WB_ON_ITR_CAPABLE)
+			tx_ring->flags = I40E_TXR_FLAGS_WB_ON_ITR;
 		vsi->tx_rings[i] = tx_ring;
 
 		rx_ring = &tx_ring[1];
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 330e4ef..7d0a5ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -853,15 +853,40 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
  **/
 static void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 {
-	u32 val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
-		  I40E_PFINT_DYN_CTLN_ITR_INDX_MASK | /* set noitr */
-		  I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK |
-		  I40E_PFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK;
-		  /* allow 00 to be written to the index */
-
-	wr32(&vsi->back->hw,
-	     I40E_PFINT_DYN_CTLN(q_vector->v_idx + vsi->base_vector - 1),
-	     val);
+	u16 flags = q_vector->tx.ring[0].flags;
+
+	if (flags & I40E_TXR_FLAGS_WB_ON_ITR) {
+		u32 val;
+
+		if (q_vector->arm_wb_state)
+			return;
+
+		val = I40E_PFINT_DYN_CTLN_WB_ON_ITR_MASK;
+
+		wr32(&vsi->back->hw,
+		     I40E_PFINT_DYN_CTLN(q_vector->v_idx +
+					 vsi->base_vector - 1),
+		     val);
+		q_vector->arm_wb_state = true;
+	} else if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
+		u32 val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+			  I40E_PFINT_DYN_CTLN_ITR_INDX_MASK | /* set noitr */
+			  I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK |
+			  I40E_PFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK;
+			  /* allow 00 to be written to the index */
+
+		wr32(&vsi->back->hw,
+		     I40E_PFINT_DYN_CTLN(q_vector->v_idx +
+					 vsi->base_vector - 1), val);
+	} else {
+		u32 val = I40E_PFINT_DYN_CTL0_INTENA_MASK |
+			  I40E_PFINT_DYN_CTL0_ITR_INDX_MASK | /* set noitr */
+			  I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK |
+			  I40E_PFINT_DYN_CTL0_SW_ITR_INDX_ENA_MASK;
+			/* allow 00 to be written to the index */
+
+		wr32(&vsi->back->hw, I40E_PFINT_DYN_CTL0, val);
+	}
 }
 
 /**
@@ -1918,6 +1943,9 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 		return budget;
 	}
 
+	if (vsi->back->flags & I40E_TXR_FLAGS_WB_ON_ITR)
+		q_vector->arm_wb_state = false;
+
 	/* Work is done so exit the polling mode and re-enable the interrupt */
 	napi_complete(napi);
 	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 8b618d0..0e40994 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -265,6 +265,8 @@ struct i40e_ring {
 	bool ring_active;		/* is ring online or not */
 	bool arm_wb;		/* do something to arm write back */
 
+	u16 flags;
+#define I40E_TXR_FLAGS_WB_ON_ITR	BIT(0)
 	/* stats structs */
 	struct i40e_queue_stats	stats;
 	struct u64_stats_sync syncp;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 60f88e4..6dbcbca 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -366,15 +366,32 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
  **/
 static void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 {
-	u32 val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
-		  I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK | /* set noitr */
-		  I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
-		  I40E_VFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK;
-		  /* allow 00 to be written to the index */
-
-	wr32(&vsi->back->hw,
-	     I40E_VFINT_DYN_CTLN1(q_vector->v_idx + vsi->base_vector - 1),
-	     val);
+	u16 flags = q_vector->tx.ring[0].flags;
+
+	if (flags & I40E_TXR_FLAGS_WB_ON_ITR) {
+		u32 val;
+
+		if (q_vector->arm_wb_state)
+			return;
+
+		val = I40E_VFINT_DYN_CTLN1_WB_ON_ITR_MASK;
+
+		wr32(&vsi->back->hw,
+		     I40E_VFINT_DYN_CTLN1(q_vector->v_idx +
+					  vsi->base_vector - 1),
+		     val);
+		q_vector->arm_wb_state = true;
+	} else {
+		u32 val = I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+			  I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK | /* set noitr */
+			  I40E_VFINT_DYN_CTLN1_SWINT_TRIG_MASK |
+			  I40E_VFINT_DYN_CTLN1_SW_ITR_INDX_ENA_MASK;
+			  /* allow 00 to be written to the index */
+
+		wr32(&vsi->back->hw,
+		     I40E_VFINT_DYN_CTLN1(q_vector->v_idx +
+					  vsi->base_vector - 1), val);
+	}
 }
 
 /**
@@ -1372,6 +1389,9 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 		return budget;
 	}
 
+	if (vsi->back->flags & I40E_TXR_FLAGS_WB_ON_ITR)
+		q_vector->arm_wb_state = false;
+
 	/* Work is done so exit the polling mode and re-enable the interrupt */
 	napi_complete(napi);
 	i40e_update_enable_itr(vsi, q_vector);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index b2f9b82..17bb59d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -262,6 +262,8 @@ struct i40e_ring {
 	bool ring_active;		/* is ring online or not */
 	bool arm_wb;		/* do something to arm write back */
 
+	u16 flags;
+#define I40E_TXR_FLAGS_WB_ON_ITR	BIT(0)
 	/* stats structs */
 	struct i40e_queue_stats	stats;
 	struct u64_stats_sync syncp;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index fa421d6..3817cbb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -117,6 +117,7 @@ struct i40e_q_vector {
 	u8 num_ringpairs;	/* total number of ring pairs in vector */
 	int v_idx;	  /* vector index in list */
 	char name[IFNAMSIZ + 9];
+	bool arm_wb_state;
 	cpumask_var_t affinity_mask;
 };
 
-- 
2.4.3
