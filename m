From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Detection and recovery of TX queue hung logic moved to service_task from tx_timeout
Date: Thu,  3 Dec 2015 05:25:49 -0800
Message-ID: <1449149160-105219-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19487 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754659AbbLCN0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:04 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

This patch contains following changes:
   - detection and recovery logic (issue SW interrupt) has been moved to
     service_task from timeout function.
   - added some more debug info from tx_timeout.

Logic to detect and recover TX queue hung is now two step process:
  - service_task detects TX queue hung and sets a bit(hung_detected) if
    it was not set.
  - if bit was set (means this is back-back hung condition detected),
    issue SW interrupt and clear the bit.
  - napi_poll clears the bit unconditionally since it cleans TX/RX queues.

Change-ID: Ieed03a48927c845a988b3ff375090bf37caeb903
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 36 ++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 21 ++++++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 15 +++++++++++
 5 files changed, 64 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0b9537b..dde7ae7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -579,6 +579,9 @@ struct i40e_q_vector {
 
 	u8 num_ringpairs;	/* total number of ring pairs in vector */
 
+#define I40E_Q_VECTOR_HUNG_DETECT 0 /* Bit Index for hung detection logic */
+	unsigned long hung_detected; /* Set/Reset for hung_detection logic */
+
 	cpumask_t affinity_mask;
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[I40E_INT_NAME_STR_LEN];
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9e6268b..e19a579 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4368,17 +4368,41 @@ static void i40e_detect_recover_hung_queue(int q_idx, struct i40e_vsi *vsi)
 	else
 		val = rd32(&pf->hw, I40E_PFINT_DYN_CTL0);
 
+	/* Bail out if interrupts are disabled because napi_poll
+	 * execution in-progress or will get scheduled soon.
+	 * napi_poll cleans TX and RX queues and updates 'next_to_clean'.
+	 */
+	if (!(val & I40E_PFINT_DYN_CTLN_INTENA_MASK))
+		return;
+
 	head = i40e_get_head(tx_ring);
 
 	tx_pending = i40e_get_tx_pending(tx_ring);
 
-	/* Interrupts are disabled and TX pending is non-zero,
-	 * trigger the SW interrupt (don't wait). Worst case
-	 * there will be one extra interrupt which may result
-	 * into not cleaning any queues because queues are cleaned.
+	/* HW is done executing descriptors, updated HEAD write back,
+	 * but SW hasn't processed those descriptors. If interrupt is
+	 * not generated from this point ON, it could result into
+	 * dev_watchdog detecting timeout on those netdev_queue,
+	 * hence proactively trigger SW interrupt.
 	 */
-	if (tx_pending && (!(val & I40E_PFINT_DYN_CTLN_INTENA_MASK)))
-		i40e_force_wb(vsi, tx_ring->q_vector);
+	if (tx_pending) {
+		/* NAPI Poll didn't run and clear since it was set */
+		if (test_and_clear_bit(I40E_Q_VECTOR_HUNG_DETECT,
+				       &tx_ring->q_vector->hung_detected)) {
+			netdev_info(vsi->netdev, "VSI_seid %d, Hung TX queue %d, tx_pending: %d, NTC:0x%x, HWB: 0x%x, NTU: 0x%x, TAIL: 0x%x\n",
+				    vsi->seid, q_idx, tx_pending,
+				    tx_ring->next_to_clean, head,
+				    tx_ring->next_to_use,
+				    readl(tx_ring->tail));
+			netdev_info(vsi->netdev, "VSI_seid %d, Issuing force_wb for TX queue %d, Interrupt Reg: 0x%x\n",
+				    vsi->seid, q_idx, val);
+			i40e_force_wb(vsi, tx_ring->q_vector);
+		} else {
+			/* First Chance - detected possible hung */
+			set_bit(I40E_Q_VECTOR_HUNG_DETECT,
+				&tx_ring->q_vector->hung_detected);
+		}
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 7371df7..1d7d01c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1891,6 +1891,8 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 		return 0;
 	}
 
+	/* Clear hung_detected bit */
+	clear_bit(I40E_Q_VECTOR_HUNG_DETECT, &q_vector->hung_detected);
 	/* Since the actual Tx work is minimal, we can give the Tx a larger
 	 * budget and be more aggressive about cleaning up the Tx descriptors.
 	 */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 11561b6..06b6636 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -127,17 +127,24 @@ void i40evf_free_tx_resources(struct i40e_ring *tx_ring)
 }
 
 /**
- * i40e_get_head - Retrieve head from head writeback
- * @tx_ring:  tx ring to fetch head of
+ * i40evf_get_tx_pending - how many Tx descriptors not processed
+ * @tx_ring: the ring of descriptors
  *
- * Returns value of Tx ring head based on value stored
- * in head write-back location
+ * Since there is no access to the ring head register
+ * in XL710, we need to use our local copies
  **/
-static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
+u32 i40evf_get_tx_pending(struct i40e_ring *ring)
 {
-	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
+	u32 head, tail;
 
-	return le32_to_cpu(*(volatile __le32 *)head);
+	head = i40e_get_head(ring);
+	tail = readl(ring->tail);
+
+	if (head != tail)
+		return (head < tail) ?
+			tail - head : (tail + ring->count - head);
+
+	return 0;
 }
 
 #define WB_STRIDE 0x3
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 929ddd9..e29bb3e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -324,4 +324,19 @@ int i40evf_setup_rx_descriptors(struct i40e_ring *rx_ring);
 void i40evf_free_tx_resources(struct i40e_ring *tx_ring);
 void i40evf_free_rx_resources(struct i40e_ring *rx_ring);
 int i40evf_napi_poll(struct napi_struct *napi, int budget);
+u32 i40evf_get_tx_pending(struct i40e_ring *ring);
+
+/**
+ * i40e_get_head - Retrieve head from head writeback
+ * @tx_ring: Tx ring to fetch head of
+ *
+ * Returns value of Tx ring head based on value stored
+ * in head write-back location
+ **/
+static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
+{
+	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
+
+	return le32_to_cpu(*(volatile __le32 *)head);
+}
 #endif /* _I40E_TXRX_H_ */
-- 
2.5.0
