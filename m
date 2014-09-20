From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 12/29] fm10k: Add interrupt support
Date: Sat, 20 Sep 2014 19:48:51 -0400
Message-ID: <20140920234835.2977.45825.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1542 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298AbaITX5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:57:36 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds interrupt support for the fm10k interfaces.  The
interfaces themselves only support MSI-X, so neither MSI or legacy
interrupts are used.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Moved use of container_of macro out of interface declaration.

 drivers/net/ethernet/intel/fm10k/fm10k.h        |   59 +++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |  401 ++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   11 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  502 +++++++++++++++++++++++
 4 files changed, 973 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c26dc75..3f83eeb 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -31,6 +31,45 @@
 
 #define FM10K_MAX_JUMBO_FRAME_SIZE	15358	/* Maximum supported size 15K */
 
+struct fm10k_ring_container {
+	unsigned int total_bytes;	/* total bytes processed this int */
+	unsigned int total_packets;	/* total packets processed this int */
+	u16 work_limit;			/* total work allowed per interrupt */
+	u16 itr;			/* interrupt throttle rate value */
+	u8 count;			/* total number of rings in vector */
+};
+
+#define FM10K_ITR_MAX		0x0FFF	/* maximum value for ITR */
+#define FM10K_ITR_10K		100	/* 100us */
+#define FM10K_ITR_20K		50	/* 50us */
+#define FM10K_ITR_ADAPTIVE	0x8000	/* adaptive interrupt moderation flag */
+
+#define FM10K_ITR_ENABLE	(FM10K_ITR_AUTOMASK | FM10K_ITR_MASK_CLEAR)
+
+#define MAX_Q_VECTORS 256
+#define MIN_Q_VECTORS	1
+enum fm10k_non_q_vectors {
+	FM10K_MBX_VECTOR,
+	NON_Q_VECTORS_PF
+};
+
+#define NON_Q_VECTORS(hw)	(((hw)->mac.type == fm10k_mac_pf) ? \
+						NON_Q_VECTORS_PF : \
+						0)
+#define MIN_MSIX_COUNT(hw)	(MIN_Q_VECTORS + NON_Q_VECTORS(hw))
+
+struct fm10k_q_vector {
+	struct fm10k_intfc *interface;
+	u32 __iomem *itr;	/* pointer to ITR register for this vector */
+	u16 v_idx;		/* index of q_vector within interface array */
+	struct fm10k_ring_container rx, tx;
+
+	struct napi_struct napi;
+	char name[IFNAMSIZ + 9];
+
+	struct rcu_head rcu;	/* to avoid race with update stats on free */
+};
+
 enum fm10k_ring_f_enum {
 	RING_F_RSS,
 	RING_F_QOS,
@@ -66,15 +105,29 @@ struct fm10k_intfc {
 #define FM10K_FLAG_SWPRI_CONFIG			(u32)(1 << 4)
 	int xcast_mode;
 
+	/* Tx fast path data */
+	int num_tx_queues;
+	u16 tx_itr;
+
+	/* Rx fast path data */
+	int num_rx_queues;
+	u16 rx_itr;
+
 	u64 rx_overrun_pf;
 	u64 rx_overrun_vf;
 
+	/* Queueing vectors */
+	struct fm10k_q_vector *q_vector[MAX_Q_VECTORS];
+	struct msix_entry *msix_entries;
+	int num_q_vectors;	/* current number of q_vectors for device */
 	struct fm10k_ring_feature ring_feature[RING_F_ARRAY_SIZE];
 
 	struct fm10k_hw_stats stats;
 	struct fm10k_hw hw;
 	u32 __iomem *uc_addr;
 	u16 msg_enable;
+	u16 tx_ring_count;
+	u16 rx_ring_count;
 
 	u32 reta[FM10K_RETA_SIZE];
 	u32 rssrk[FM10K_RSSRK_SIZE];
@@ -126,8 +179,14 @@ static inline int fm10k_mbx_trylock(struct fm10k_intfc *interface)
 /* main */
 extern char fm10k_driver_name[];
 extern const char fm10k_driver_version[];
+int fm10k_init_queueing_scheme(struct fm10k_intfc *interface);
+void fm10k_clear_queueing_scheme(struct fm10k_intfc *interface);
 
 /* PCI */
+void fm10k_mbx_free_irq(struct fm10k_intfc *);
+int fm10k_mbx_request_irq(struct fm10k_intfc *);
+void fm10k_qv_free_irq(struct fm10k_intfc *interface);
+int fm10k_qv_request_irq(struct fm10k_intfc *interface);
 int fm10k_register_pci_driver(void);
 void fm10k_unregister_pci_driver(void);
 void fm10k_up(struct fm10k_intfc *interface);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 6ca0614..b0a2ba1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -66,3 +66,404 @@ static void __exit fm10k_exit_module(void)
 	fm10k_unregister_pci_driver();
 }
 module_exit(fm10k_exit_module);
+
+/**
+ * fm10k_update_itr - update the dynamic ITR value based on packet size
+ *
+ *      Stores a new ITR value based on strictly on packet size.  The
+ *      divisors and thresholds used by this function were determined based
+ *      on theoretical maximum wire speed and testing data, in order to
+ *      minimize response time while increasing bulk throughput.
+ *
+ * @ring_container: Container for rings to have ITR updated
+ **/
+static void fm10k_update_itr(struct fm10k_ring_container *ring_container)
+{
+	unsigned int avg_wire_size, packets;
+
+	/* Only update ITR if we are using adaptive setting */
+	if (!(ring_container->itr & FM10K_ITR_ADAPTIVE))
+		goto clear_counts;
+
+	packets = ring_container->total_packets;
+	if (!packets)
+		goto clear_counts;
+
+	avg_wire_size = ring_container->total_bytes / packets;
+
+	/* Add 24 bytes to size to account for CRC, preamble, and gap */
+	avg_wire_size += 24;
+
+	/* Don't starve jumbo frames */
+	if (avg_wire_size > 3000)
+		avg_wire_size = 3000;
+
+	/* Give a little boost to mid-size frames */
+	if ((avg_wire_size > 300) && (avg_wire_size < 1200))
+		avg_wire_size /= 3;
+	else
+		avg_wire_size /= 2;
+
+	/* write back value and retain adaptive flag */
+	ring_container->itr = avg_wire_size | FM10K_ITR_ADAPTIVE;
+
+clear_counts:
+	ring_container->total_bytes = 0;
+	ring_container->total_packets = 0;
+}
+
+static void fm10k_qv_enable(struct fm10k_q_vector *q_vector)
+{
+	/* Enable auto-mask and clear the current mask */
+	u32 itr = FM10K_ITR_ENABLE;
+
+	/* Update Tx ITR */
+	fm10k_update_itr(&q_vector->tx);
+
+	/* Update Rx ITR */
+	fm10k_update_itr(&q_vector->rx);
+
+	/* Store Tx itr in timer slot 0 */
+	itr |= (q_vector->tx.itr & FM10K_ITR_MAX);
+
+	/* Shift Rx itr to timer slot 1 */
+	itr |= (q_vector->rx.itr & FM10K_ITR_MAX) << FM10K_ITR_INTERVAL1_SHIFT;
+
+	/* Write the final value to the ITR register */
+	writel(itr, q_vector->itr);
+}
+
+static int fm10k_poll(struct napi_struct *napi, int budget)
+{
+	struct fm10k_q_vector *q_vector =
+			       container_of(napi, struct fm10k_q_vector, napi);
+
+	/* all work done, exit the polling mode */
+	napi_complete(napi);
+
+	/* re-enable the q_vector */
+	fm10k_qv_enable(q_vector);
+
+	return 0;
+}
+
+/**
+ * fm10k_set_num_queues: Allocate queues for device, feature dependent
+ * @interface: board private structure to initialize
+ *
+ * This is the top level queue allocation routine.  The order here is very
+ * important, starting with the "most" number of features turned on at once,
+ * and ending with the smallest set of features.  This way large combinations
+ * can be allocated if they're turned on, and smaller combinations are the
+ * fallthrough conditions.
+ *
+ **/
+static void fm10k_set_num_queues(struct fm10k_intfc *interface)
+{
+	/* Start with base case */
+	interface->num_rx_queues = 1;
+	interface->num_tx_queues = 1;
+}
+
+/**
+ * fm10k_alloc_q_vector - Allocate memory for a single interrupt vector
+ * @interface: board private structure to initialize
+ * @v_count: q_vectors allocated on interface, used for ring interleaving
+ * @v_idx: index of vector in interface struct
+ * @txr_count: total number of Tx rings to allocate
+ * @txr_idx: index of first Tx ring to allocate
+ * @rxr_count: total number of Rx rings to allocate
+ * @rxr_idx: index of first Rx ring to allocate
+ *
+ * We allocate one q_vector.  If allocation fails we return -ENOMEM.
+ **/
+static int fm10k_alloc_q_vector(struct fm10k_intfc *interface,
+				unsigned int v_count, unsigned int v_idx,
+				unsigned int txr_count, unsigned int txr_idx,
+				unsigned int rxr_count, unsigned int rxr_idx)
+{
+	struct fm10k_q_vector *q_vector;
+	int ring_count, size;
+
+	ring_count = txr_count + rxr_count;
+	size = sizeof(struct fm10k_q_vector);
+
+	/* allocate q_vector and rings */
+	q_vector = kzalloc(size, GFP_KERNEL);
+	if (!q_vector)
+		return -ENOMEM;
+
+	/* initialize NAPI */
+	netif_napi_add(interface->netdev, &q_vector->napi,
+		       fm10k_poll, NAPI_POLL_WEIGHT);
+
+	/* tie q_vector and interface together */
+	interface->q_vector[v_idx] = q_vector;
+	q_vector->interface = interface;
+	q_vector->v_idx = v_idx;
+
+	/* save Tx ring container info */
+	q_vector->tx.itr = interface->tx_itr;
+	q_vector->tx.count = txr_count;
+
+	/* save Rx ring container info */
+	q_vector->rx.itr = interface->rx_itr;
+	q_vector->rx.count = rxr_count;
+
+	return 0;
+}
+
+/**
+ * fm10k_free_q_vector - Free memory allocated for specific interrupt vector
+ * @interface: board private structure to initialize
+ * @v_idx: Index of vector to be freed
+ *
+ * This function frees the memory allocated to the q_vector.  In addition if
+ * NAPI is enabled it will delete any references to the NAPI struct prior
+ * to freeing the q_vector.
+ **/
+static void fm10k_free_q_vector(struct fm10k_intfc *interface, int v_idx)
+{
+	struct fm10k_q_vector *q_vector = interface->q_vector[v_idx];
+
+	interface->q_vector[v_idx] = NULL;
+	netif_napi_del(&q_vector->napi);
+	kfree_rcu(q_vector, rcu);
+}
+
+/**
+ * fm10k_alloc_q_vectors - Allocate memory for interrupt vectors
+ * @interface: board private structure to initialize
+ *
+ * We allocate one q_vector per queue interrupt.  If allocation fails we
+ * return -ENOMEM.
+ **/
+static int fm10k_alloc_q_vectors(struct fm10k_intfc *interface)
+{
+	unsigned int q_vectors = interface->num_q_vectors;
+	unsigned int rxr_remaining = interface->num_rx_queues;
+	unsigned int txr_remaining = interface->num_tx_queues;
+	unsigned int rxr_idx = 0, txr_idx = 0, v_idx = 0;
+	int err;
+
+	if (q_vectors >= (rxr_remaining + txr_remaining)) {
+		for (; rxr_remaining; v_idx++) {
+			err = fm10k_alloc_q_vector(interface, q_vectors, v_idx,
+						   0, 0, 1, rxr_idx);
+			if (err)
+				goto err_out;
+
+			/* update counts and index */
+			rxr_remaining--;
+			rxr_idx++;
+		}
+	}
+
+	for (; v_idx < q_vectors; v_idx++) {
+		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - v_idx);
+		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - v_idx);
+
+		err = fm10k_alloc_q_vector(interface, q_vectors, v_idx,
+					   tqpv, txr_idx,
+					   rqpv, rxr_idx);
+
+		if (err)
+			goto err_out;
+
+		/* update counts and index */
+		rxr_remaining -= rqpv;
+		txr_remaining -= tqpv;
+		rxr_idx++;
+		txr_idx++;
+	}
+
+	return 0;
+
+err_out:
+	interface->num_tx_queues = 0;
+	interface->num_rx_queues = 0;
+	interface->num_q_vectors = 0;
+
+	while (v_idx--)
+		fm10k_free_q_vector(interface, v_idx);
+
+	return -ENOMEM;
+}
+
+/**
+ * fm10k_free_q_vectors - Free memory allocated for interrupt vectors
+ * @interface: board private structure to initialize
+ *
+ * This function frees the memory allocated to the q_vectors.  In addition if
+ * NAPI is enabled it will delete any references to the NAPI struct prior
+ * to freeing the q_vector.
+ **/
+static void fm10k_free_q_vectors(struct fm10k_intfc *interface)
+{
+	int v_idx = interface->num_q_vectors;
+
+	interface->num_tx_queues = 0;
+	interface->num_rx_queues = 0;
+	interface->num_q_vectors = 0;
+
+	while (v_idx--)
+		fm10k_free_q_vector(interface, v_idx);
+}
+
+/**
+ * f10k_reset_msix_capability - reset MSI-X capability
+ * @interface: board private structure to initialize
+ *
+ * Reset the MSI-X capability back to its starting state
+ **/
+static void fm10k_reset_msix_capability(struct fm10k_intfc *interface)
+{
+	pci_disable_msix(interface->pdev);
+	kfree(interface->msix_entries);
+	interface->msix_entries = NULL;
+}
+
+/**
+ * f10k_init_msix_capability - configure MSI-X capability
+ * @interface: board private structure to initialize
+ *
+ * Attempt to configure the interrupts using the best available
+ * capabilities of the hardware and the kernel.
+ **/
+static int fm10k_init_msix_capability(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	int v_budget, vector;
+
+	/* It's easy to be greedy for MSI-X vectors, but it really
+	 * doesn't do us much good if we have a lot more vectors
+	 * than CPU's.  So let's be conservative and only ask for
+	 * (roughly) the same number of vectors as there are CPU's.
+	 * the default is to use pairs of vectors
+	 */
+	v_budget = max(interface->num_rx_queues, interface->num_tx_queues);
+	v_budget = min_t(u16, v_budget, num_online_cpus());
+
+	/* account for vectors not related to queues */
+	v_budget += NON_Q_VECTORS(hw);
+
+	/* At the same time, hardware can only support a maximum of
+	 * hw.mac->max_msix_vectors vectors.  With features
+	 * such as RSS and VMDq, we can easily surpass the number of Rx and Tx
+	 * descriptor queues supported by our device.  Thus, we cap it off in
+	 * those rare cases where the cpu count also exceeds our vector limit.
+	 */
+	v_budget = min_t(int, v_budget, hw->mac.max_msix_vectors);
+
+	/* A failure in MSI-X entry allocation is fatal. */
+	interface->msix_entries = kcalloc(v_budget, sizeof(struct msix_entry),
+					  GFP_KERNEL);
+	if (!interface->msix_entries)
+		return -ENOMEM;
+
+	/* populate entry values */
+	for (vector = 0; vector < v_budget; vector++)
+		interface->msix_entries[vector].entry = vector;
+
+	/* Attempt to enable MSI-X with requested value */
+	v_budget = pci_enable_msix_range(interface->pdev,
+					 interface->msix_entries,
+					 MIN_MSIX_COUNT(hw),
+					 v_budget);
+	if (v_budget < 0) {
+		kfree(interface->msix_entries);
+		interface->msix_entries = NULL;
+		return -ENOMEM;
+	}
+
+	/* record the number of queues available for q_vectors */
+	interface->num_q_vectors = v_budget - NON_Q_VECTORS(hw);
+
+	return 0;
+}
+
+static void fm10k_init_reta(struct fm10k_intfc *interface)
+{
+	u16 i, rss_i = interface->ring_feature[RING_F_RSS].indices;
+	u32 reta, base;
+
+	/* If the netdev is initialized we have to maintain table if possible */
+	if (interface->netdev->reg_state) {
+		for (i = FM10K_RETA_SIZE; i--;) {
+			reta = interface->reta[i];
+			if ((((reta << 24) >> 24) < rss_i) &&
+			    (((reta << 16) >> 24) < rss_i) &&
+			    (((reta <<  8) >> 24) < rss_i) &&
+			    (((reta)       >> 24) < rss_i))
+				continue;
+			goto repopulate_reta;
+		}
+
+		/* do nothing if all of the elements are in bounds */
+		return;
+	}
+
+repopulate_reta:
+	/* Populate the redirection table 4 entries at a time.  To do this
+	 * we are generating the results for n and n+2 and then interleaving
+	 * those with the results with n+1 and n+3.
+	 */
+	for (i = FM10K_RETA_SIZE; i--;) {
+		/* first pass generates n and n+2 */
+		base = ((i * 0x00040004) + 0x00020000) * rss_i;
+		reta = (base & 0x3F803F80) >> 7;
+
+		/* second pass generates n+1 and n+3 */
+		base += 0x00010001 * rss_i;
+		reta |= (base & 0x3F803F80) << 1;
+
+		interface->reta[i] = reta;
+	}
+}
+
+/**
+ * fm10k_init_queueing_scheme - Determine proper queueing scheme
+ * @interface: board private structure to initialize
+ *
+ * We determine which queueing scheme to use based on...
+ * - Hardware queue count (num_*_queues)
+ *   - defined by miscellaneous hardware support/features (RSS, etc.)
+ **/
+int fm10k_init_queueing_scheme(struct fm10k_intfc *interface)
+{
+	int err;
+
+	/* Number of supported queues */
+	fm10k_set_num_queues(interface);
+
+	/* Configure MSI-X capability */
+	err = fm10k_init_msix_capability(interface);
+	if (err) {
+		dev_err(&interface->pdev->dev,
+			"Unable to initialize MSI-X capability\n");
+		return err;
+	}
+
+	/* Allocate memory for queues */
+	err = fm10k_alloc_q_vectors(interface);
+	if (err)
+		return err;
+
+	/* Initialize RSS redirection table */
+	fm10k_init_reta(interface);
+
+	return 0;
+}
+
+/**
+ * fm10k_clear_queueing_scheme - Clear the current queueing scheme settings
+ * @interface: board private structure to clear queueing scheme on
+ *
+ * We go through and clear queueing specific resources and reset the structure
+ * to pre-load conditions
+ **/
+void fm10k_clear_queueing_scheme(struct fm10k_intfc *interface)
+{
+	fm10k_free_q_vectors(interface);
+	fm10k_reset_msix_capability(interface);
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index ca84898..487efcb 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -57,6 +57,12 @@ static void fm10k_request_glort_range(struct fm10k_intfc *interface)
 int fm10k_open(struct net_device *netdev)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
+	int err;
+
+	/* allocate interrupt resources */
+	err = fm10k_qv_request_irq(interface);
+	if (err)
+		goto err_req_irq;
 
 	/* setup GLORT assignment for this port */
 	fm10k_request_glort_range(interface);
@@ -64,6 +70,9 @@ int fm10k_open(struct net_device *netdev)
 	fm10k_up(interface);
 
 	return 0;
+
+err_req_irq:
+	return err;
 }
 
 /**
@@ -83,6 +92,8 @@ int fm10k_close(struct net_device *netdev)
 
 	fm10k_down(interface);
 
+	fm10k_qv_free_irq(interface);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index b6d5e72..2257ab1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -87,6 +87,470 @@ static int fm10k_hw_ready(struct fm10k_intfc *interface)
 	return FM10K_REMOVED(hw->hw_addr) ? -ENODEV : 0;
 }
 
+static void fm10k_napi_enable_all(struct fm10k_intfc *interface)
+{
+	struct fm10k_q_vector *q_vector;
+	int q_idx;
+
+	for (q_idx = 0; q_idx < interface->num_q_vectors; q_idx++) {
+		q_vector = interface->q_vector[q_idx];
+		napi_enable(&q_vector->napi);
+	}
+}
+
+static irqreturn_t fm10k_msix_clean_rings(int irq, void *data)
+{
+	struct fm10k_q_vector *q_vector = data;
+
+	if (q_vector->rx.count || q_vector->tx.count)
+		napi_schedule(&q_vector->napi);
+
+	return IRQ_HANDLED;
+}
+
+#define FM10K_ERR_MSG(type) case (type): error = #type; break
+static void fm10k_print_fault(struct fm10k_intfc *interface, int type,
+			      struct fm10k_fault *fault)
+{
+	struct pci_dev *pdev = interface->pdev;
+	char *error;
+
+	switch (type) {
+	case FM10K_PCA_FAULT:
+		switch (fault->type) {
+		default:
+			error = "Unknown PCA error";
+			break;
+		FM10K_ERR_MSG(PCA_NO_FAULT);
+		FM10K_ERR_MSG(PCA_UNMAPPED_ADDR);
+		FM10K_ERR_MSG(PCA_BAD_QACCESS_PF);
+		FM10K_ERR_MSG(PCA_BAD_QACCESS_VF);
+		FM10K_ERR_MSG(PCA_MALICIOUS_REQ);
+		FM10K_ERR_MSG(PCA_POISONED_TLP);
+		FM10K_ERR_MSG(PCA_TLP_ABORT);
+		}
+		break;
+	case FM10K_THI_FAULT:
+		switch (fault->type) {
+		default:
+			error = "Unknown THI error";
+			break;
+		FM10K_ERR_MSG(THI_NO_FAULT);
+		FM10K_ERR_MSG(THI_MAL_DIS_Q_FAULT);
+		}
+		break;
+	case FM10K_FUM_FAULT:
+		switch (fault->type) {
+		default:
+			error = "Unknown FUM error";
+			break;
+		FM10K_ERR_MSG(FUM_NO_FAULT);
+		FM10K_ERR_MSG(FUM_UNMAPPED_ADDR);
+		FM10K_ERR_MSG(FUM_BAD_VF_QACCESS);
+		FM10K_ERR_MSG(FUM_ADD_DECODE_ERR);
+		FM10K_ERR_MSG(FUM_RO_ERROR);
+		FM10K_ERR_MSG(FUM_QPRC_CRC_ERROR);
+		FM10K_ERR_MSG(FUM_CSR_TIMEOUT);
+		FM10K_ERR_MSG(FUM_INVALID_TYPE);
+		FM10K_ERR_MSG(FUM_INVALID_LENGTH);
+		FM10K_ERR_MSG(FUM_INVALID_BE);
+		FM10K_ERR_MSG(FUM_INVALID_ALIGN);
+		}
+		break;
+	default:
+		error = "Undocumented fault";
+		break;
+	}
+
+	dev_warn(&pdev->dev,
+		 "%s Address: 0x%llx SpecInfo: 0x%x Func: %02x.%0x\n",
+		 error, fault->address, fault->specinfo,
+		 PCI_SLOT(fault->func), PCI_FUNC(fault->func));
+}
+
+static void fm10k_report_fault(struct fm10k_intfc *interface, u32 eicr)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_fault fault = { 0 };
+	int type, err;
+
+	for (eicr &= FM10K_EICR_FAULT_MASK, type = FM10K_PCA_FAULT;
+	     eicr;
+	     eicr >>= 1, type += FM10K_FAULT_SIZE) {
+		/* only check if there is an error reported */
+		if (!(eicr & 0x1))
+			continue;
+
+		/* retrieve fault info */
+		err = hw->mac.ops.get_fault(hw, type, &fault);
+		if (err) {
+			dev_err(&interface->pdev->dev,
+				"error reading fault\n");
+			continue;
+		}
+
+		fm10k_print_fault(interface, type, &fault);
+	}
+}
+
+static void fm10k_reset_drop_on_empty(struct fm10k_intfc *interface, u32 eicr)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	const u32 rxdctl = FM10K_RXDCTL_WRITE_BACK_MIN_DELAY;
+	u32 maxholdq;
+	int q;
+
+	if (!(eicr & FM10K_EICR_MAXHOLDTIME))
+		return;
+
+	maxholdq = fm10k_read_reg(hw, FM10K_MAXHOLDQ(7));
+	if (maxholdq)
+		fm10k_write_reg(hw, FM10K_MAXHOLDQ(7), maxholdq);
+	for (q = 255;;) {
+		if (maxholdq & (1 << 31)) {
+			if (q < FM10K_MAX_QUEUES_PF) {
+				interface->rx_overrun_pf++;
+				fm10k_write_reg(hw, FM10K_RXDCTL(q), rxdctl);
+			} else {
+				interface->rx_overrun_vf++;
+			}
+		}
+
+		maxholdq *= 2;
+		if (!maxholdq)
+			q &= ~(32 - 1);
+
+		if (!q)
+			break;
+
+		if (q-- % 32)
+			continue;
+
+		maxholdq = fm10k_read_reg(hw, FM10K_MAXHOLDQ(q / 32));
+		if (maxholdq)
+			fm10k_write_reg(hw, FM10K_MAXHOLDQ(q / 32), maxholdq);
+	}
+}
+
+static irqreturn_t fm10k_msix_mbx_pf(int irq, void *data)
+{
+	struct fm10k_intfc *interface = data;
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 eicr;
+
+	/* unmask any set bits related to this interrupt */
+	eicr = fm10k_read_reg(hw, FM10K_EICR);
+	fm10k_write_reg(hw, FM10K_EICR, eicr & (FM10K_EICR_MAILBOX |
+						FM10K_EICR_SWITCHREADY |
+						FM10K_EICR_SWITCHNOTREADY));
+
+	/* report any faults found to the message log */
+	fm10k_report_fault(interface, eicr);
+
+	/* reset any queues disabled due to receiver overrun */
+	fm10k_reset_drop_on_empty(interface, eicr);
+
+	/* service mailboxes */
+	if (fm10k_mbx_trylock(interface)) {
+		mbx->ops.process(hw, mbx);
+		fm10k_mbx_unlock(interface);
+	}
+
+	/* re-enable mailbox interrupt and indicate 20us delay */
+	fm10k_write_reg(hw, FM10K_ITR(FM10K_MBX_VECTOR),
+			FM10K_ITR_ENABLE | FM10K_MBX_INT_DELAY);
+
+	return IRQ_HANDLED;
+}
+
+void fm10k_mbx_free_irq(struct fm10k_intfc *interface)
+{
+	struct msix_entry *entry = &interface->msix_entries[FM10K_MBX_VECTOR];
+	struct fm10k_hw *hw = &interface->hw;
+	int itr_reg;
+
+	/* disconnect the mailbox */
+	hw->mbx.ops.disconnect(hw, &hw->mbx);
+
+	/* disable Mailbox cause */
+	if (hw->mac.type == fm10k_mac_pf) {
+		fm10k_write_reg(hw, FM10K_EIMR,
+				FM10K_EIMR_DISABLE(PCA_FAULT) |
+				FM10K_EIMR_DISABLE(FUM_FAULT) |
+				FM10K_EIMR_DISABLE(MAILBOX) |
+				FM10K_EIMR_DISABLE(SWITCHREADY) |
+				FM10K_EIMR_DISABLE(SWITCHNOTREADY) |
+				FM10K_EIMR_DISABLE(SRAMERROR) |
+				FM10K_EIMR_DISABLE(VFLR) |
+				FM10K_EIMR_DISABLE(MAXHOLDTIME));
+		itr_reg = FM10K_ITR(FM10K_MBX_VECTOR);
+	}
+
+	fm10k_write_reg(hw, itr_reg, FM10K_ITR_MASK_SET);
+
+	free_irq(entry->vector, interface);
+}
+
+/* generic error handler for mailbox issues */
+static s32 fm10k_mbx_error(struct fm10k_hw *hw, u32 **results,
+			   struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_intfc *interface;
+	struct pci_dev *pdev;
+
+	interface = container_of(hw, struct fm10k_intfc, hw);
+	pdev = interface->pdev;
+
+	dev_err(&pdev->dev, "Unknown message ID %u\n",
+		**results & FM10K_TLV_ID_MASK);
+
+	return 0;
+}
+
+static s32 fm10k_lport_map(struct fm10k_hw *hw, u32 **results,
+			   struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_intfc *interface;
+	u32 dglort_map = hw->mac.dglort_map;
+	s32 err;
+
+	err = fm10k_msg_lport_map_pf(hw, results, mbx);
+	if (err)
+		return err;
+
+	interface = container_of(hw, struct fm10k_intfc, hw);
+
+	/* we need to reset if port count was just updated */
+	if (dglort_map != hw->mac.dglort_map)
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+
+	return 0;
+}
+
+static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
+			     struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_intfc *interface;
+	u16 glort, pvid;
+	u32 pvid_update;
+	s32 err;
+
+	err = fm10k_tlv_attr_get_u32(results[FM10K_PF_ATTR_ID_UPDATE_PVID],
+				     &pvid_update);
+	if (err)
+		return err;
+
+	/* extract values from the pvid update */
+	glort = FM10K_MSG_HDR_FIELD_GET(pvid_update, UPDATE_PVID_GLORT);
+	pvid = FM10K_MSG_HDR_FIELD_GET(pvid_update, UPDATE_PVID_PVID);
+
+	/* if glort is not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort))
+		return FM10K_ERR_PARAM;
+
+	/* verify VID is valid */
+	if (pvid >= FM10K_VLAN_TABLE_VID_MAX)
+		return FM10K_ERR_PARAM;
+
+	interface = container_of(hw, struct fm10k_intfc, hw);
+
+	/* we need to reset if default VLAN was just updated */
+	if (pvid != hw->mac.default_vid)
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+
+	hw->mac.default_vid = pvid;
+
+	return 0;
+}
+
+static const struct fm10k_msg_data pf_mbx_data[] = {
+	FM10K_PF_MSG_ERR_HANDLER(XCAST_MODES, fm10k_msg_err_pf),
+	FM10K_PF_MSG_ERR_HANDLER(UPDATE_MAC_FWD_RULE, fm10k_msg_err_pf),
+	FM10K_PF_MSG_LPORT_MAP_HANDLER(fm10k_lport_map),
+	FM10K_PF_MSG_ERR_HANDLER(LPORT_CREATE, fm10k_msg_err_pf),
+	FM10K_PF_MSG_ERR_HANDLER(LPORT_DELETE, fm10k_msg_err_pf),
+	FM10K_PF_MSG_UPDATE_PVID_HANDLER(fm10k_update_pvid),
+	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_mbx_error),
+};
+
+static int fm10k_mbx_request_irq_pf(struct fm10k_intfc *interface)
+{
+	struct msix_entry *entry = &interface->msix_entries[FM10K_MBX_VECTOR];
+	struct net_device *dev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int err;
+
+	/* Use timer0 for interrupt moderation on the mailbox */
+	u32 mbx_itr = FM10K_INT_MAP_TIMER0 | entry->entry;
+	u32 other_itr = FM10K_INT_MAP_IMMEDIATE | entry->entry;
+
+	/* register mailbox handlers */
+	err = hw->mbx.ops.register_handlers(&hw->mbx, pf_mbx_data);
+	if (err)
+		return err;
+
+	/* request the IRQ */
+	err = request_irq(entry->vector, fm10k_msix_mbx_pf, 0,
+			  dev->name, interface);
+	if (err) {
+		netif_err(interface, probe, dev,
+			  "request_irq for msix_mbx failed: %d\n", err);
+		return err;
+	}
+
+	/* Enable interrupts w/ no moderation for "other" interrupts */
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_PCIeFault), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_SwitchUpDown), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_SRAM), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_MaxHoldTime), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_VFLR), other_itr);
+
+	/* Enable interrupts w/ moderation for mailbox */
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_Mailbox), mbx_itr);
+
+	/* Enable individual interrupt causes */
+	fm10k_write_reg(hw, FM10K_EIMR, FM10K_EIMR_ENABLE(PCA_FAULT) |
+					FM10K_EIMR_ENABLE(FUM_FAULT) |
+					FM10K_EIMR_ENABLE(MAILBOX) |
+					FM10K_EIMR_ENABLE(SWITCHREADY) |
+					FM10K_EIMR_ENABLE(SWITCHNOTREADY) |
+					FM10K_EIMR_ENABLE(SRAMERROR) |
+					FM10K_EIMR_ENABLE(VFLR) |
+					FM10K_EIMR_ENABLE(MAXHOLDTIME));
+
+	/* enable interrupt */
+	fm10k_write_reg(hw, FM10K_ITR(entry->entry), FM10K_ITR_ENABLE);
+
+	return 0;
+}
+
+int fm10k_mbx_request_irq(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	int err;
+
+	/* enable Mailbox cause */
+	err = fm10k_mbx_request_irq_pf(interface);
+
+	/* connect mailbox */
+	if (!err)
+		err = hw->mbx.ops.connect(hw, &hw->mbx);
+
+	return err;
+}
+
+/**
+ * fm10k_qv_free_irq - release interrupts associated with queue vectors
+ * @interface: board private structure
+ *
+ * Release all interrupts associated with this interface
+ **/
+void fm10k_qv_free_irq(struct fm10k_intfc *interface)
+{
+	int vector = interface->num_q_vectors;
+	struct fm10k_hw *hw = &interface->hw;
+	struct msix_entry *entry;
+
+	entry = &interface->msix_entries[NON_Q_VECTORS(hw) + vector];
+
+	while (vector) {
+		struct fm10k_q_vector *q_vector;
+
+		vector--;
+		entry--;
+		q_vector = interface->q_vector[vector];
+
+		if (!q_vector->tx.count && !q_vector->rx.count)
+			continue;
+
+		/* disable interrupts */
+
+		writel(FM10K_ITR_MASK_SET, q_vector->itr);
+
+		free_irq(entry->vector, q_vector);
+	}
+}
+
+/**
+ * fm10k_qv_request_irq - initialize interrupts for queue vectors
+ * @interface: board private structure
+ *
+ * Attempts to configure interrupts using the best available
+ * capabilities of the hardware and kernel.
+ **/
+int fm10k_qv_request_irq(struct fm10k_intfc *interface)
+{
+	struct net_device *dev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	struct msix_entry *entry;
+	int ri = 0, ti = 0;
+	int vector, err;
+
+	entry = &interface->msix_entries[NON_Q_VECTORS(hw)];
+
+	for (vector = 0; vector < interface->num_q_vectors; vector++) {
+		struct fm10k_q_vector *q_vector = interface->q_vector[vector];
+
+		/* name the vector */
+		if (q_vector->tx.count && q_vector->rx.count) {
+			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
+				 "%s-TxRx-%d", dev->name, ri++);
+			ti++;
+		} else if (q_vector->rx.count) {
+			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
+				 "%s-rx-%d", dev->name, ri++);
+		} else if (q_vector->tx.count) {
+			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
+				 "%s-tx-%d", dev->name, ti++);
+		} else {
+			/* skip this unused q_vector */
+			continue;
+		}
+
+		/* Assign ITR register to q_vector */
+		q_vector->itr = &interface->uc_addr[FM10K_ITR(entry->entry)];
+
+		/* request the IRQ */
+		err = request_irq(entry->vector, &fm10k_msix_clean_rings, 0,
+				  q_vector->name, q_vector);
+		if (err) {
+			netif_err(interface, probe, dev,
+				  "request_irq failed for MSIX interrupt Error: %d\n",
+				  err);
+			goto err_out;
+		}
+
+		/* Enable q_vector */
+		writel(FM10K_ITR_ENABLE, q_vector->itr);
+
+		entry++;
+	}
+
+	return 0;
+
+err_out:
+	/* wind through the ring freeing all entries and vectors */
+	while (vector) {
+		struct fm10k_q_vector *q_vector;
+
+		entry--;
+		vector--;
+		q_vector = interface->q_vector[vector];
+
+		if (!q_vector->tx.count && !q_vector->rx.count)
+			continue;
+
+		/* disable interrupts */
+
+		writel(FM10K_ITR_MASK_SET, q_vector->itr);
+
+		free_irq(entry->vector, q_vector);
+	}
+
+	return err;
+}
+
 void fm10k_up(struct fm10k_intfc *interface)
 {
 	struct fm10k_hw *hw = &interface->hw;
@@ -100,6 +564,9 @@ void fm10k_up(struct fm10k_intfc *interface)
 	/* clear down bit to indicate we are ready to go */
 	clear_bit(__FM10K_DOWN, &interface->state);
 
+	/* enable polling cleanups */
+	fm10k_napi_enable_all(interface);
+
 	/* re-establish Rx filters */
 	fm10k_restore_rx_state(interface);
 
@@ -107,6 +574,17 @@ void fm10k_up(struct fm10k_intfc *interface)
 	netif_tx_start_all_queues(interface->netdev);
 }
 
+static void fm10k_napi_disable_all(struct fm10k_intfc *interface)
+{
+	struct fm10k_q_vector *q_vector;
+	int q_idx;
+
+	for (q_idx = 0; q_idx < interface->num_q_vectors; q_idx++) {
+		q_vector = interface->q_vector[q_idx];
+		napi_disable(&q_vector->napi);
+	}
+}
+
 void fm10k_down(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
@@ -128,6 +606,9 @@ void fm10k_down(struct fm10k_intfc *interface)
 	/* allow 10ms for device to quiesce */
 	usleep_range(10000, 20000);
 
+	/* disable polling routines */
+	fm10k_napi_disable_all(interface);
+
 	/* Disable DMA engine for Tx/Rx */
 	hw->mac.ops.stop_hw(hw);
 }
@@ -226,6 +707,10 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
 	}
 
+	/* set default interrupt moderation */
+	interface->tx_itr = FM10K_ITR_10K;
+	interface->rx_itr = FM10K_ITR_ADAPTIVE | FM10K_ITR_20K;
+
 	/* initialize vxlan_port list */
 	INIT_LIST_HEAD(&interface->vxlan_port);
 
@@ -341,6 +826,14 @@ static int fm10k_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	err = fm10k_init_queueing_scheme(interface);
+	if (err)
+		goto err_sw_init;
+
+	err = fm10k_mbx_request_irq(interface);
+	if (err)
+		goto err_mbx_interrupt;
+
 	/* final check of hardware state before registering the interface */
 	err = fm10k_hw_ready(interface);
 	if (err)
@@ -377,6 +870,9 @@ static int fm10k_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	fm10k_mbx_free_irq(interface);
+err_mbx_interrupt:
+	fm10k_clear_queueing_scheme(interface);
 err_sw_init:
 	iounmap(interface->uc_addr);
 err_ioremap:
@@ -408,6 +904,12 @@ static void fm10k_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
+	/* disable mailbox interrupt */
+	fm10k_mbx_free_irq(interface);
+
+	/* free interrupts */
+	fm10k_clear_queueing_scheme(interface);
+
 	iounmap(interface->uc_addr);
 
 	free_netdev(netdev);
