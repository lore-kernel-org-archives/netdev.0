From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/5] ixgbe: Introduce MSI-X queue vector code
Date: Mon, 03 Mar 2008 15:03:45 -0800
Message-ID: <20080303230345.25151.48298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

This code abstracts the per-queue MSI-X interrupt vector into
a queue vector layer. This abstraction is needed since there can
be many more queues than available MSI-X vectors in a machine.

The MSI-X irq vectors are remapped to a shared queue vector which
can point to several (both RX and TX) hardware queues. The NAPI
algorithm then cleans the appropriate ring/queues on interrupt
or poll.

The remapping is a delicate and complex calculation to make sure
that we're not unbalancing the irq load, and spreads the irqs
as much as possible, and may combine RX and TX flows onto the
same queue vector.

This effectively enables receive flow hashing across vectors
and helps irq load balance across CPUs.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |   69 ++
 drivers/net/ixgbe/ixgbe_main.c | 1107 ++++++++++++++++++++++++++++------------
 2 files changed, 826 insertions(+), 350 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d0bf206..2077477 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -120,7 +120,6 @@ struct ixgbe_queue_stats {
 };
 
 struct ixgbe_ring {
-	struct ixgbe_adapter *adapter;	/* backlink */
 	void *desc;			/* descriptor ring memory */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
 	unsigned int size;		/* length in bytes */
@@ -128,6 +127,7 @@ struct ixgbe_ring {
 	unsigned int next_to_use;
 	unsigned int next_to_clean;
 
+	int queue_index; /* needed for multiqueue queue management */
 	union {
 		struct ixgbe_tx_buffer *tx_buffer_info;
 		struct ixgbe_rx_buffer *rx_buffer_info;
@@ -137,7 +137,13 @@ struct ixgbe_ring {
 	u16 tail;
 
 
+	u16 reg_idx; /* holds the special value that gets the hardware register
+		      * offset associated with this ring, which is different
+		      * for DCE and RSS modes */
 	struct ixgbe_queue_stats stats;
+	u8 v_idx; /* maps directly to the index for this ring in the hardware
+		   * vector array, can also be used for finding the bit in EICR
+		   * and friends that represents the vector for this ring */
 
 	u32 eims_value;
 	u16 itr_register;
@@ -146,6 +152,31 @@ struct ixgbe_ring {
 	u16 work_limit;                /* max work per interrupt */
 };
 
+#define RING_F_VMDQ 1
+#define RING_F_RSS  2
+#define IXGBE_MAX_RSS_INDICES  16
+#define IXGBE_MAX_VMDQ_INDICES 16
+struct ixgbe_ring_feature {
+	int indices;
+	int mask;
+};
+
+#define MAX_RX_QUEUES 64
+#define MAX_TX_QUEUES 32
+
+/* MAX_MSIX_Q_VECTORS of these are allocated,
+ * but we only use one per queue-specific vector.
+ */
+struct ixgbe_q_vector {
+	struct ixgbe_adapter *adapter;
+	struct napi_struct napi;
+	DECLARE_BITMAP(rxr_idx, MAX_RX_QUEUES); /* Rx ring indices */
+	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
+	u8 rxr_count;     /* Rx ring count assigned to this vector */
+	u8 txr_count;     /* Tx ring count assigned to this vector */
+	u32 eitr;
+};
+
 /* Helper macros to switch between ints/sec and what the register uses.
  * And yes, it's the same math going both ways.
  */
@@ -166,6 +197,14 @@ struct ixgbe_ring {
 
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
 
+#define OTHER_VECTOR 1
+#define NON_Q_VECTORS (OTHER_VECTOR)
+
+#define MAX_MSIX_Q_VECTORS 16
+#define MIN_MSIX_Q_VECTORS 2
+#define MAX_MSIX_COUNT (MAX_MSIX_Q_VECTORS + NON_Q_VECTORS)
+#define MIN_MSIX_COUNT (MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
+
 /* board specific private data structure */
 struct ixgbe_adapter {
 	struct timer_list watchdog_timer;
@@ -173,10 +212,11 @@ struct ixgbe_adapter {
 	u16 bd_number;
 	u16 rx_buf_len;
 	struct work_struct reset_task;
+	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
+	char name[MAX_MSIX_COUNT][IFNAMSIZ + 5];
 
 	/* TX */
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
-	struct napi_struct napi;
 	u64 restart_queue;
 	u64 lsc_int;
 	u64 hw_tso_ctxt;
@@ -192,22 +232,26 @@ struct ixgbe_adapter {
 	u64 non_eop_descs;
 	int num_tx_queues;
 	int num_rx_queues;
+	int num_msix_vectors;
+	struct ixgbe_ring_feature ring_feature[3];
 	struct msix_entry *msix_entries;
 
 	u64 rx_hdr_split;
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
+	/* Some features need tri-state capability,
+	 * thus the additional *_CAPABLE flags.
+	 */
 	u32 flags;
-#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
+#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1 << 0)
 #define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 1)
-#define IXGBE_FLAG_MSIX_ENABLED			(u32)(1 << 2)
-#define IXGBE_FLAG_RX_PS_ENABLED		(u32)(1 << 3)
-#define IXGBE_FLAG_IN_NETPOLL			(u32)(1 << 4)
-
-	/* Interrupt Throttle Rate */
-	u32 rx_eitr;
-	u32 tx_eitr;
+#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 2)
+#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 3)
+#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 4)
+#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 5)
+#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 6)
+#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 7)
 
 	/* OS defined structs */
 	struct net_device *netdev;
@@ -218,7 +262,10 @@ struct ixgbe_adapter {
 	struct ixgbe_hw hw;
 	u16 msg_enable;
 	struct ixgbe_hw_stats stats;
-	char lsc_name[IFNAMSIZ + 5];
+
+	/* Interrupt Throttle Rate */
+	u32 rx_eitr;
+	u32 tx_eitr;
 
 	unsigned long state;
 	u64 tx_busy;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c2095ce..fecc8ea 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -559,7 +559,7 @@ next_desc:
 	return cleaned;
 }
 
-#define IXGBE_MAX_INTR 10
+static int ixgbe_clean_rxonly(struct napi_struct *, int);
 /**
  * ixgbe_configure_msix - Configure MSI-X hardware
  * @adapter: board private structure
@@ -569,28 +569,57 @@ next_desc:
  **/
 static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 {
-	int i, vector = 0;
+	struct ixgbe_q_vector *q_vector;
+	int i, j, q_vectors, v_idx, r_idx;
+	u32 mask;
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(i),
-			       IXGBE_MSIX_VECTOR(vector));
-		writel(EITR_INTS_PER_SEC_TO_REG(adapter->tx_eitr),
-		       adapter->hw.hw_addr + adapter->tx_ring[i].itr_register);
-		vector++;
-	}
+	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(i),
-			       IXGBE_MSIX_VECTOR(vector));
-		writel(EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr),
-		       adapter->hw.hw_addr + adapter->rx_ring[i].itr_register);
-		vector++;
+	/* Populate the IVAR table and set the ITR values to the
+	 * corresponding register.
+	 */
+	for (v_idx = 0; v_idx < q_vectors; v_idx++) {
+		q_vector = &adapter->q_vector[v_idx];
+		/* XXX for_each_bit(...) */
+		r_idx = find_first_bit(q_vector->rxr_idx,
+				      adapter->num_rx_queues);
+
+		for (i = 0; i < q_vector->rxr_count; i++) {
+			j = adapter->rx_ring[r_idx].reg_idx;
+			ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(j), v_idx);
+			r_idx = find_next_bit(q_vector->rxr_idx,
+					      adapter->num_rx_queues,
+					      r_idx + 1);
+		}
+		r_idx = find_first_bit(q_vector->txr_idx,
+				       adapter->num_tx_queues);
+
+		for (i = 0; i < q_vector->txr_count; i++) {
+			j = adapter->tx_ring[r_idx].reg_idx;
+			ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(j), v_idx);
+			r_idx = find_next_bit(q_vector->txr_idx,
+					      adapter->num_tx_queues,
+					      r_idx + 1);
+		}
+
+		/* if this is a tx only vector use half the irq (tx) rate */
+		if (q_vector->txr_count && !q_vector->rxr_count)
+			q_vector->eitr = adapter->tx_eitr;
+		else
+			/* rx only or mixed */
+			q_vector->eitr = adapter->rx_eitr;
+
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
+				EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
-	vector = adapter->num_tx_queues + adapter->num_rx_queues;
-	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX,
-		       IXGBE_MSIX_VECTOR(vector));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(vector), 1950);
+	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX, v_idx);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx), 1950);
+
+	/* set up to autoclear timer, lsc, and the vectors */
+	mask = IXGBE_EIMS_ENABLE_MASK;
+	mask &= ~IXGBE_EIMS_OTHER;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC, mask);
 }
 
 static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
@@ -614,153 +643,241 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 
 static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 {
-	struct ixgbe_ring *txr = data;
-	struct ixgbe_adapter *adapter = txr->adapter;
+	struct ixgbe_q_vector *q_vector = data;
+	struct ixgbe_adapter  *adapter = q_vector->adapter;
+	struct ixgbe_ring     *txr;
+	int i, r_idx;
+
+	if (!q_vector->txr_count)
+		return IRQ_HANDLED;
+
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->txr_count; i++) {
+		txr = &(adapter->tx_ring[r_idx]);
+		ixgbe_clean_tx_irq(adapter, txr);
+		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+				      r_idx + 1);
+	}
 
-	ixgbe_clean_tx_irq(adapter, txr);
 
 	return IRQ_HANDLED;
 }
 
+/**
+ * ixgbe_msix_clean_rx - single unshared vector rx clean (all queues)
+ * @irq: unused
+ * @data: pointer to our q_vector struct for this interrupt vector
+ **/
 static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 {
-	struct ixgbe_ring *rxr = data;
-	struct ixgbe_adapter *adapter = rxr->adapter;
+	struct ixgbe_q_vector *q_vector = data;
+	struct ixgbe_adapter  *adapter = q_vector->adapter;
+	struct ixgbe_ring  *rxr;
+	int r_idx;
+
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	if (!q_vector->rxr_count)
+		return IRQ_HANDLED;
+
+	rxr = &(adapter->rx_ring[r_idx]);
+	/* disable interrupts on this vector only */
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->v_idx);
+	netif_rx_schedule(adapter->netdev, &q_vector->napi);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
+{
+	ixgbe_msix_clean_rx(irq, data);
+	ixgbe_msix_clean_tx(irq, data);
 
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->eims_value);
-	netif_rx_schedule(adapter->netdev, &adapter->napi);
 	return IRQ_HANDLED;
 }
 
+/**
+ * ixgbe_clean_rxonly - msix (aka one shot) rx clean routine
+ * @napi: napi struct with our devices info in it
+ * @budget: amount of work driver is allowed to do this pass, in packets
+ *
+ **/
 static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 {
-	struct ixgbe_adapter *adapter = container_of(napi,
-					struct ixgbe_adapter, napi);
-	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_q_vector *q_vector =
+			       container_of(napi, struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_ring *rxr;
 	int work_done = 0;
-	struct ixgbe_ring *rxr = adapter->rx_ring;
+	long r_idx;
 
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	rxr = &(adapter->rx_ring[r_idx]);
 
 	ixgbe_clean_rx_irq(adapter, rxr, &work_done, budget);
 
-	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((work_done < budget) || !netif_running(netdev)) {
-quit_polling:
-		netif_rx_complete(netdev, napi);
+	/* If all Rx work done, exit the polling mode */
+	if (work_done < budget) {
+		netif_rx_complete(adapter->netdev, napi);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
-					rxr->eims_value);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rxr->v_idx);
 	}
 
 	return work_done;
 }
 
+static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
+				     int r_idx)
+{
+	a->q_vector[v_idx].adapter = a;
+	set_bit(r_idx, a->q_vector[v_idx].rxr_idx);
+	a->q_vector[v_idx].rxr_count++;
+	a->rx_ring[r_idx].v_idx = 1 << v_idx;
+}
+
+static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
+				     int r_idx)
+{
+	a->q_vector[v_idx].adapter = a;
+	set_bit(r_idx, a->q_vector[v_idx].txr_idx);
+	a->q_vector[v_idx].txr_count++;
+	a->tx_ring[r_idx].v_idx = 1 << v_idx;
+}
+
 /**
- * ixgbe_setup_msix - Initialize MSI-X interrupts
+ * ixgbe_map_rings_to_vectors - Maps descriptor rings to vectors
+ * @adapter: board private structure to initialize
+ * @vectors: allotted vector count for descriptor rings
  *
- * ixgbe_setup_msix allocates MSI-X vectors and requests
- * interrutps from the kernel.
+ * This function maps descriptor rings to the queue-specific vectors
+ * we were allotted through the MSI-X enabling code.  Ideally, we'd have
+ * one vector per ring/queue, but on a constrained vector budget, we
+ * group the rings as "efficiently" as possible.  You would add new
+ * mapping configurations in here.
  **/
-static int ixgbe_setup_msix(struct ixgbe_adapter *adapter)
-{
-	struct net_device *netdev = adapter->netdev;
-	int i, int_vector = 0, err = 0;
-	int max_msix_count;
+static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter,
+				      int vectors)
+{
+	int v_start = 0;
+	int rxr_idx = 0, txr_idx = 0;
+	int rxr_remaining = adapter->num_rx_queues;
+	int txr_remaining = adapter->num_tx_queues;
+	int i, j;
+	int rqpv, tqpv;
+	int err = 0;
+
+	/* No mapping required if MSI-X is disabled. */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
+		goto out;
 
-	/* +1 for the LSC interrupt */
-	max_msix_count = adapter->num_rx_queues + adapter->num_tx_queues + 1;
-	adapter->msix_entries = kcalloc(max_msix_count,
-					sizeof(struct msix_entry), GFP_KERNEL);
-	if (!adapter->msix_entries)
-		return -ENOMEM;
+	/*
+	 * The ideal configuration...
+	 * We have enough vectors to map one per queue.
+	 */
+	if (vectors == adapter->num_rx_queues + adapter->num_tx_queues) {
+		for (; rxr_idx < rxr_remaining; v_start++, rxr_idx++)
+			map_vector_to_rxq(adapter, v_start, rxr_idx);
 
-	for (i = 0; i < max_msix_count; i++)
-		adapter->msix_entries[i].entry = i;
+		for (; txr_idx < txr_remaining; v_start++, txr_idx++)
+			map_vector_to_txq(adapter, v_start, txr_idx);
 
-	err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-			      max_msix_count);
-	if (err)
 		goto out;
+	}
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		sprintf(adapter->tx_ring[i].name, "%s-tx%d", netdev->name, i);
-		err = request_irq(adapter->msix_entries[int_vector].vector,
-				  &ixgbe_msix_clean_tx,
-				  0,
-				  adapter->tx_ring[i].name,
-				  &(adapter->tx_ring[i]));
-		if (err) {
-			DPRINTK(PROBE, ERR,
-				"request_irq failed for MSIX interrupt "
-				"Error: %d\n", err);
-			goto release_irqs;
+	/*
+	 * If we don't have enough vectors for a 1-to-1
+	 * mapping, we'll have to group them so there are
+	 * multiple queues per vector.
+	 */
+	/* Re-adjusting *qpv takes care of the remainder. */
+	for (i = v_start; i < vectors; i++) {
+		rqpv = DIV_ROUND_UP(rxr_remaining, vectors - i);
+		for (j = 0; j < rqpv; j++) {
+			map_vector_to_rxq(adapter, i, rxr_idx);
+			rxr_idx++;
+			rxr_remaining--;
+		}
+	}
+	for (i = v_start; i < vectors; i++) {
+		tqpv = DIV_ROUND_UP(txr_remaining, vectors - i);
+		for (j = 0; j < tqpv; j++) {
+			map_vector_to_txq(adapter, i, txr_idx);
+			txr_idx++;
+			txr_remaining--;
 		}
-		adapter->tx_ring[i].eims_value =
-		    (1 << IXGBE_MSIX_VECTOR(int_vector));
-		adapter->tx_ring[i].itr_register = IXGBE_EITR(int_vector);
-		int_vector++;
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		if (strlen(netdev->name) < (IFNAMSIZ - 5))
-			sprintf(adapter->rx_ring[i].name,
-				"%s-rx%d", netdev->name, i);
-		else
-			memcpy(adapter->rx_ring[i].name,
-			       netdev->name, IFNAMSIZ);
-		err = request_irq(adapter->msix_entries[int_vector].vector,
-				  &ixgbe_msix_clean_rx, 0,
-				  adapter->rx_ring[i].name,
-				  &(adapter->rx_ring[i]));
+out:
+	return err;
+}
+
+/**
+ * ixgbe_request_msix_irqs - Initialize MSI-X interrupts
+ * @adapter: board private structure
+ *
+ * ixgbe_request_msix_irqs allocates MSI-X vectors and requests
+ * interrupts from the kernel.
+ **/
+static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	irqreturn_t (*handler)(int, void *);
+	int i, vector, q_vectors, err;
+
+	/* Decrement for Other and TCP Timer vectors */
+	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	/* Map the Tx/Rx rings to the vectors we were allotted. */
+	err = ixgbe_map_rings_to_vectors(adapter, q_vectors);
+	if (err)
+		goto out;
+
+#define SET_HANDLER(_v) ((!(_v)->rxr_count) ? &ixgbe_msix_clean_tx : \
+			 (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
+			 &ixgbe_msix_clean_many)
+	for (vector = 0; vector < q_vectors; vector++) {
+		handler = SET_HANDLER(&adapter->q_vector[vector]);
+		sprintf(adapter->name[vector], "%s:v%d-%s",
+			netdev->name, vector,
+			(handler == &ixgbe_msix_clean_rx) ? "Rx" :
+			 ((handler == &ixgbe_msix_clean_tx) ? "Tx" : "TxRx"));
+		err = request_irq(adapter->msix_entries[vector].vector,
+				  handler, 0, adapter->name[vector],
+				  &(adapter->q_vector[vector]));
 		if (err) {
 			DPRINTK(PROBE, ERR,
 				"request_irq failed for MSIX interrupt "
 				"Error: %d\n", err);
-			goto release_irqs;
+			goto free_queue_irqs;
 		}
-
-		adapter->rx_ring[i].eims_value =
-		    (1 << IXGBE_MSIX_VECTOR(int_vector));
-		adapter->rx_ring[i].itr_register = IXGBE_EITR(int_vector);
-		int_vector++;
 	}
 
-	sprintf(adapter->lsc_name, "%s-lsc", netdev->name);
-	err = request_irq(adapter->msix_entries[int_vector].vector,
-			  &ixgbe_msix_lsc, 0, adapter->lsc_name, netdev);
+	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
+	err = request_irq(adapter->msix_entries[vector].vector,
+			  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {
 		DPRINTK(PROBE, ERR,
 			"request_irq for msix_lsc failed: %d\n", err);
-		goto release_irqs;
+		goto free_queue_irqs;
 	}
 
-	/* FIXME: implement netif_napi_remove() instead */
-	adapter->napi.poll = ixgbe_clean_rxonly;
-	adapter->flags |= IXGBE_FLAG_MSIX_ENABLED;
 	return 0;
 
-release_irqs:
-	int_vector--;
-	for (; int_vector >= adapter->num_tx_queues; int_vector--)
-		free_irq(adapter->msix_entries[int_vector].vector,
-			 &(adapter->rx_ring[int_vector -
-					    adapter->num_tx_queues]));
-
-	for (; int_vector >= 0; int_vector--)
-		free_irq(adapter->msix_entries[int_vector].vector,
-			 &(adapter->tx_ring[int_vector]));
-out:
+free_queue_irqs:
+	for (i = vector - 1; i >= 0; i--)
+		free_irq(adapter->msix_entries[--vector].vector,
+			 &(adapter->q_vector[i]));
+	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
+	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
+out:
 	return err;
 }
 
+static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter);
+
 /**
- * ixgbe_intr - Interrupt Handler
+ * ixgbe_intr - legacy mode Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  * @pt_regs: CPU registers structure
@@ -772,8 +889,10 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
 
-	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
 
+	/* for NAPI, using EIAM to auto-mask tx/rx interrupt bits on read
+	 * therefore no explict interrupt disable is necessary */
+	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
 	if (!eicr)
 		return IRQ_NONE;	/* Not our interrupt */
 
@@ -782,16 +901,29 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 	}
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
-		/* Disable interrupts and register for poll. The flush of the
-		 * posted write is intentionally left out. */
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
-		__netif_rx_schedule(netdev, &adapter->napi);
+
+
+	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
+		/* would disable interrupts here but EIAM disabled it */
+		__netif_rx_schedule(netdev, &adapter->q_vector[0].napi);
 	}
 
 	return IRQ_HANDLED;
 }
 
+static inline void ixgbe_reset_q_vectors(struct ixgbe_adapter *adapter)
+{
+	int i, q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	for (i = 0; i < q_vectors; i++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
+		bitmap_zero(q_vector->rxr_idx, MAX_RX_QUEUES);
+		bitmap_zero(q_vector->txr_idx, MAX_TX_QUEUES);
+		q_vector->rxr_count = 0;
+		q_vector->txr_count = 0;
+	}
+}
+
 /**
  * ixgbe_request_irq - initialize interrupts
  * @adapter: board private structure
@@ -799,40 +931,24 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
  * Attempts to configure interrupts using the best available
  * capabilities of the hardware and kernel.
  **/
-static int ixgbe_request_irq(struct ixgbe_adapter *adapter, u32 *num_rx_queues)
+static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int flags, err;
-	irq_handler_t handler = ixgbe_intr;
-
-	flags = IRQF_SHARED;
-
-	err = ixgbe_setup_msix(adapter);
-	if (!err)
-		goto request_done;
-
-	/*
-	 * if we can't do MSI-X, fall through and try MSI
-	 * No need to reallocate memory since we're decreasing the number of
-	 * queues. We just won't use the other ones, also it is freed correctly
-	 * on ixgbe_remove.
-	 */
-	*num_rx_queues = 1;
+	int err;
 
-	/* do MSI */
-	err = pci_enable_msi(adapter->pdev);
-	if (!err) {
-		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
-		flags &= ~IRQF_SHARED;
-		handler = &ixgbe_intr;
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		err = ixgbe_request_msix_irqs(adapter);
+	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
+		err = request_irq(adapter->pdev->irq, &ixgbe_intr, 0,
+				  netdev->name, netdev);
+	} else {
+		err = request_irq(adapter->pdev->irq, &ixgbe_intr, IRQF_SHARED,
+				  netdev->name, netdev);
 	}
 
-	err = request_irq(adapter->pdev->irq, handler, flags,
-			  netdev->name, netdev);
 	if (err)
 		DPRINTK(PROBE, ERR, "request_irq failed, Error %d\n", err);
 
-request_done:
 	return err;
 }
 
@@ -841,28 +957,22 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		int i;
+		int i, q_vectors;
 
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			free_irq(adapter->msix_entries[i].vector,
-				 &(adapter->tx_ring[i]));
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			free_irq(adapter->msix_entries[i +
-						adapter->num_tx_queues].vector,
-				&(adapter->rx_ring[i]));
-		i = adapter->num_rx_queues + adapter->num_tx_queues;
+		q_vectors = adapter->num_msix_vectors;
+
+		i = q_vectors - 1;
 		free_irq(adapter->msix_entries[i].vector, netdev);
-		pci_disable_msix(adapter->pdev);
-		kfree(adapter->msix_entries);
-		adapter->msix_entries = NULL;
-		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
-		return;
-	}
 
-	free_irq(adapter->pdev->irq, netdev);
-	if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
-		pci_disable_msi(adapter->pdev);
-		adapter->flags &= ~IXGBE_FLAG_MSI_ENABLED;
+		i--;
+		for (; i >= 0; i--) {
+			free_irq(adapter->msix_entries[i].vector,
+				 &(adapter->q_vector[i]));
+		}
+
+		ixgbe_reset_q_vectors(adapter);
+	} else {
+		free_irq(adapter->pdev->irq, netdev);
 	}
 }
 
@@ -874,7 +984,13 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 {
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
-	synchronize_irq(adapter->pdev->irq);
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		int i;
+		for (i = 0; i < adapter->num_msix_vectors; i++)
+			synchronize_irq(adapter->msix_entries[i].vector);
+	} else {
+		synchronize_irq(adapter->pdev->irq);
+	}
 }
 
 /**
@@ -883,12 +999,9 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 {
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC,
-				(IXGBE_EIMS_ENABLE_MASK &
-				 ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC)));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
-			IXGBE_EIMS_ENABLE_MASK);
+	u32 mask;
+	mask = IXGBE_EIMS_ENABLE_MASK;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
 
@@ -898,20 +1011,18 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 {
-	int i;
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (adapter->rx_eitr)
-		IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
-				EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr));
-
-	/* for re-triggering the interrupt in non-NAPI mode */
-	adapter->rx_ring[0].eims_value = (1 << IXGBE_MSIX_VECTOR(0));
-	adapter->tx_ring[0].eims_value = (1 << IXGBE_MSIX_VECTOR(0));
+	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
+			EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr));
 
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(0), 0);
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(i), i);
+	ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(0), 0);
+
+	map_vector_to_rxq(adapter, 0, 0);
+	map_vector_to_txq(adapter, 0, 0);
+
+	DPRINTK(HW, INFO, "Legacy interrupt IVAR setup done\n");
 }
 
 /**
@@ -924,23 +1035,29 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 {
 	u64 tdba;
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 i, tdlen;
+	u32 i, j, tdlen, txctrl;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
+		j = adapter->tx_ring[i].reg_idx;
 		tdba = adapter->tx_ring[i].dma;
 		tdlen = adapter->tx_ring[i].count *
-		    sizeof(union ixgbe_adv_tx_desc);
-		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(i), (tdba & DMA_32BIT_MASK));
-		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(i), (tdba >> 32));
-		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(i), tdlen);
-		IXGBE_WRITE_REG(hw, IXGBE_TDH(i), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_TDT(i), 0);
-		adapter->tx_ring[i].head = IXGBE_TDH(i);
-		adapter->tx_ring[i].tail = IXGBE_TDT(i);
+			sizeof(union ixgbe_adv_tx_desc);
+		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(j),
+				(tdba & DMA_32BIT_MASK));
+		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(j), (tdba >> 32));
+		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
+		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
+		adapter->tx_ring[i].head = IXGBE_TDH(j);
+		adapter->tx_ring[i].tail = IXGBE_TDT(j);
+		/* Disable Tx Head Writeback RO bit, since this hoses
+		 * bookkeeping if things aren't delivered in order.
+		 */
+		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), txctrl);
 	}
-
-	IXGBE_WRITE_REG(hw, IXGBE_TIPG, IXGBE_TIPG_FIBER_DEFAULT);
 }
 
 #define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
@@ -959,13 +1076,12 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	int i, j;
 	u32 rdlen, rxctrl, rxcsum;
 	u32 random[10];
-	u32 reta, mrqc;
-	int i;
 	u32 fctrl, hlreg0;
-	u32 srrctl;
 	u32 pages;
+	u32 reta = 0, mrqc, srrctl;
 
 	/* Decide whether to use packet split mode or not */
 	if (netdev->mtu > ETH_DATA_LEN)
@@ -985,6 +1101,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 
 	fctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
 	fctrl |= IXGBE_FCTRL_BAM;
+	fctrl |= IXGBE_FCTRL_DPF; /* discard pause frames when FC enabled */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, fctrl);
 
 	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
@@ -1036,37 +1153,23 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].tail = IXGBE_RDT(i);
 	}
 
-	if (adapter->num_rx_queues > 1) {
-		/* Random 40bytes used as random key in RSS hash function */
-		get_random_bytes(&random[0], 40);
-
-		switch (adapter->num_rx_queues) {
-		case 8:
-		case 4:
-			/* Bits [3:0] in each byte refers the Rx queue no */
-			reta = 0x00010203;
-			break;
-		case 2:
-			reta = 0x00010001;
-			break;
-		default:
-			reta = 0x00000000;
-			break;
-		}
-
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
-		for (i = 0; i < 32; i++) {
-			IXGBE_WRITE_REG_ARRAY(hw, IXGBE_RETA(0), i, reta);
-			if (adapter->num_rx_queues > 4) {
-				i++;
-				IXGBE_WRITE_REG_ARRAY(hw, IXGBE_RETA(0), i,
-						      0x04050607);
-			}
+		for (i = 0, j = 0; i < 128; i++, j++) {
+			if (j == adapter->ring_feature[RING_F_RSS].indices)
+				j = 0;
+			/* reta = 4-byte sliding window of
+			 * 0x00..(indices-1)(indices-1)00..etc. */
+			reta = (reta << 8) | (j * 0x11);
+			if ((i & 3) == 3)
+				IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
 		}
 
 		/* Fill out hash function seeds */
+		/* XXX use a random constant here to glue certain flows */
+		get_random_bytes(&random[0], 40);
 		for (i = 0; i < 10; i++)
-			IXGBE_WRITE_REG_ARRAY(hw, IXGBE_RSSRK(0), i, random[i]);
+			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), random[i]);
 
 		mrqc = IXGBE_MRQC_RSSEN
 		    /* Perform hash on these packet types */
@@ -1080,26 +1183,23 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		    | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
 		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
 		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
+	}
 
-		/* Multiqueue and packet checksumming are mutually exclusive. */
-		rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
+	rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
+
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED ||
+	    adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED) {
+		/* Disable indicating checksum in descriptor, enables
+		 * RSS hash */
 		rxcsum |= IXGBE_RXCSUM_PCSD;
-		IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
-	} else {
-		/* Enable Receive Checksum Offload for TCP and UDP */
-		rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
-		if (adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED) {
-			/* Enable IPv4 payload checksum for UDP fragments
-			 * Must be used in conjunction with packet-split. */
-			rxcsum |= IXGBE_RXCSUM_IPPCSE;
-		} else {
-			/* don't need to clear IPPCSE as it defaults to 0 */
-		}
-		IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 	}
-	/* Enable Receives */
-	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl);
-	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	if (!(rxcsum & IXGBE_RXCSUM_PCSD)) {
+		/* Enable IPv4 payload checksum for UDP fragments
+		 * if PCSD is not set */
+		rxcsum |= IXGBE_RXCSUM_IPPCSE;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 }
 
 static void ixgbe_vlan_rx_register(struct net_device *netdev,
@@ -1219,6 +1319,43 @@ static void ixgbe_set_multi(struct net_device *netdev)
 
 }
 
+static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
+{
+	int q_idx;
+	struct ixgbe_q_vector *q_vector;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	/* legacy and MSI only use one vector */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
+		q_vectors = 1;
+
+	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		q_vector = &adapter->q_vector[q_idx];
+		if (!q_vector->rxr_count)
+			continue;
+		napi_enable(&q_vector->napi);
+	}
+}
+
+static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
+{
+	int q_idx;
+	struct ixgbe_q_vector *q_vector;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	/* legacy and MSI only use one vector */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
+		q_vectors = 1;
+
+	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		q_vector = &adapter->q_vector[q_idx];
+		if (!q_vector->rxr_count)
+			continue;
+		napi_disable(&q_vector->napi);
+	}
+}
+
+
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1238,30 +1375,35 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int i;
-	u32 gpie = 0;
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 txdctl, rxdctl, mhadd;
+	int i, j = 0;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	u32 txdctl, rxdctl, mhadd;
+	u32 gpie;
 
 	ixgbe_get_hw_control(adapter);
 
-	if (adapter->flags & (IXGBE_FLAG_MSIX_ENABLED |
-			      IXGBE_FLAG_MSI_ENABLED)) {
+	if ((adapter->flags & IXGBE_FLAG_MSIX_ENABLED) ||
+	    (adapter->flags & IXGBE_FLAG_MSI_ENABLED)) {
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 			gpie = (IXGBE_GPIE_MSIX_MODE | IXGBE_GPIE_EIAME |
 				IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD);
 		} else {
 			/* MSI only */
-			gpie = (IXGBE_GPIE_EIAME |
-				IXGBE_GPIE_PBA_SUPPORT);
+			gpie = 0;
 		}
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_GPIE, gpie);
-		gpie = IXGBE_READ_REG(&adapter->hw, IXGBE_GPIE);
+		/* XXX: to interrupt immediately for EICS writes, enable this */
+		/* gpie |= IXGBE_GPIE_EIMEN; */
+		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 	}
 
-	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+		/* legacy interrupts, use EIAM to auto-mask when reading EICR,
+		 * specifically only auto mask tx and rx interrupts */
+		IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);
+	}
 
+	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
 	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
 		mhadd &= ~IXGBE_MHADD_MFS_MASK;
 		mhadd |= max_frame << IXGBE_MHADD_MFS_SHIFT;
@@ -1270,15 +1412,21 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	}
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		txdctl = IXGBE_READ_REG(&adapter->hw, IXGBE_TXDCTL(i));
+		j = adapter->tx_ring[i].reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		txdctl |= IXGBE_TXDCTL_ENABLE;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_TXDCTL(i), txdctl);
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rxdctl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(i));
+		j = adapter->rx_ring[i].reg_idx;
+		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
+		/* enable PTHRESH=32 descriptors (half the internal cache)
+		 * and HTHRESH=0 descriptors (to minimize latency on fetch),
+		 * this also removes a pesky rx_no_buffer_count increment */
+		rxdctl |= 0x0020;
 		rxdctl |= IXGBE_RXDCTL_ENABLE;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(i), rxdctl);
+		IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), rxdctl);
 	}
 	/* enable all receives */
 	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
@@ -1291,7 +1439,11 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		ixgbe_configure_msi_and_legacy(adapter);
 
 	clear_bit(__IXGBE_DOWN, &adapter->state);
-	napi_enable(&adapter->napi);
+	ixgbe_napi_enable_all(adapter);
+
+	/* clear any pending interrupts, may auto mask */
+	IXGBE_READ_REG(hw, IXGBE_EICR);
+
 	ixgbe_irq_enable(adapter);
 
 	/* bring the link up in the watchdog, this could race with our first
@@ -1333,7 +1485,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 err, num_rx_queues = adapter->num_rx_queues;
+	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
@@ -1349,7 +1501,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	if (netif_running(netdev)) {
-		err = ixgbe_request_irq(adapter, &num_rx_queues);
+		err = ixgbe_request_irq(adapter);
 		if (err)
 			return err;
 	}
@@ -1449,27 +1601,27 @@ static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
 }
 
 /**
- * ixgbe_clean_all_tx_rings - Free Tx Buffers for all queues
+ * ixgbe_clean_all_rx_rings - Free Rx Buffers for all queues
  * @adapter: board private structure
  **/
-static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
+static void ixgbe_clean_all_rx_rings(struct ixgbe_adapter *adapter)
 {
 	int i;
 
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbe_clean_tx_ring(adapter, &adapter->tx_ring[i]);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbe_clean_rx_ring(adapter, &adapter->rx_ring[i]);
 }
 
 /**
- * ixgbe_clean_all_rx_rings - Free Rx Buffers for all queues
+ * ixgbe_clean_all_tx_rings - Free Tx Buffers for all queues
  * @adapter: board private structure
  **/
-static void ixgbe_clean_all_rx_rings(struct ixgbe_adapter *adapter)
+static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 {
 	int i;
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbe_clean_rx_ring(adapter, &adapter->rx_ring[i]);
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		ixgbe_clean_tx_ring(adapter, &adapter->tx_ring[i]);
 }
 
 void ixgbe_down(struct ixgbe_adapter *adapter)
@@ -1493,10 +1645,9 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	msleep(10);
 
-	napi_disable(&adapter->napi);
-
 	ixgbe_irq_disable(adapter);
 
+	ixgbe_napi_disable_all(adapter);
 	del_timer_sync(&adapter->watchdog_timer);
 
 	netif_carrier_off(netdev);
@@ -1547,27 +1698,28 @@ static void ixgbe_shutdown(struct pci_dev *pdev)
 }
 
 /**
- * ixgbe_clean - NAPI Rx polling callback
- * @adapter: board private structure
+ * ixgbe_poll - NAPI Rx polling callback
+ * @napi: structure for representing this polling device
+ * @budget: how many packets driver is allowed to clean
+ *
+ * This function is used for legacy and MSI, NAPI mode
  **/
-static int ixgbe_clean(struct napi_struct *napi, int budget)
+static int ixgbe_poll(struct napi_struct *napi, int budget)
 {
-	struct ixgbe_adapter *adapter = container_of(napi,
-					struct ixgbe_adapter, napi);
-	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_q_vector *q_vector = container_of(napi,
+					  struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_cleaned = 0, work_done = 0;
 
-	/* In non-MSIX case, there is no multi-Tx/Rx queue */
 	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
-	ixgbe_clean_rx_irq(adapter, &adapter->rx_ring[0], &work_done,
-			   budget);
+	ixgbe_clean_rx_irq(adapter, adapter->rx_ring, &work_done, budget);
 
 	if (tx_cleaned)
 		work_done = budget;
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(adapter->netdev, napi);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable(adapter);
 	}
@@ -1597,6 +1749,132 @@ static void ixgbe_reset_task(struct work_struct *work)
 	ixgbe_reinit_locked(adapter);
 }
 
+static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
+				       int vectors)
+{
+	int err, vector_threshold;
+
+	/* We'll want at least 3 (vector_threshold):
+	 * 1) TxQ[0] Cleanup
+	 * 2) RxQ[0] Cleanup
+	 * 3) Other (Link Status Change, etc.)
+	 * 4) TCP Timer (optional)
+	 */
+	vector_threshold = MIN_MSIX_COUNT;
+
+	/* The more we get, the more we will assign to Tx/Rx Cleanup
+	 * for the separate queues...where Rx Cleanup >= Tx Cleanup.
+	 * Right now, we simply care about how many we'll get; we'll
+	 * set them up later while requesting irq's.
+	 */
+	while (vectors >= vector_threshold) {
+		err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
+				      vectors);
+		if (!err) /* Success in acquiring all requested vectors. */
+			break;
+		else if (err < 0)
+			vectors = 0; /* Nasty failure, quit now */
+		else /* err == number of vectors we should try again with */
+			vectors = err;
+	}
+
+	if (vectors < vector_threshold) {
+		/* Can't allocate enough MSI-X interrupts?  Oh well.
+		 * This just means we'll go with either a single MSI
+		 * vector or fall back to legacy interrupts.
+		 */
+		DPRINTK(HW, DEBUG, "Unable to allocate MSI-X interrupts\n");
+		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
+		kfree(adapter->msix_entries);
+		adapter->msix_entries = NULL;
+		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+		adapter->num_tx_queues = 1;
+		adapter->num_rx_queues = 1;
+	} else {
+		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
+		adapter->num_msix_vectors = vectors;
+	}
+}
+
+static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+{
+	int nrq, ntq;
+	int feature_mask = 0, rss_i, rss_m;
+
+	/* Number of supported queues */
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
+		rss_i = adapter->ring_feature[RING_F_RSS].indices;
+		rss_m = 0;
+		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
+
+		switch (adapter->flags & feature_mask) {
+		case (IXGBE_FLAG_RSS_ENABLED):
+			rss_m = 0xF;
+			nrq = rss_i;
+			ntq = 1;
+			break;
+		case 0:
+		default:
+			rss_i = 0;
+			rss_m = 0;
+			nrq = 1;
+			ntq = 1;
+			break;
+		}
+
+		adapter->ring_feature[RING_F_RSS].indices = rss_i;
+		adapter->ring_feature[RING_F_RSS].mask = rss_m;
+		break;
+	default:
+		nrq = 1;
+		ntq = 1;
+		break;
+	}
+
+	adapter->num_rx_queues = nrq;
+	adapter->num_tx_queues = ntq;
+}
+
+/**
+ * ixgbe_cache_ring_register - Descriptor ring to register mapping
+ * @adapter: board private structure to initialize
+ *
+ * Once we know the feature-set enabled for the device, we'll cache
+ * the register offset the descriptor ring is assigned to.
+ **/
+static void __devinit ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
+{
+	/* TODO: Remove all uses of the indices in the cases where multiple
+	 *       features are OR'd together, if the feature set makes sense.
+	 */
+	int feature_mask = 0, rss_i;
+	int i, txr_idx, rxr_idx;
+
+	/* Number of supported queues */
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
+		rss_i = adapter->ring_feature[RING_F_RSS].indices;
+		txr_idx = 0;
+		rxr_idx = 0;
+		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
+		switch (adapter->flags & feature_mask) {
+		case (IXGBE_FLAG_RSS_ENABLED):
+			for (i = 0; i < adapter->num_rx_queues; i++)
+				adapter->rx_ring[i].reg_idx = i;
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				adapter->tx_ring[i].reg_idx = i;
+			break;
+		case 0:
+		default:
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+}
+
 /**
  * ixgbe_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
@@ -1612,25 +1890,163 @@ static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
 				   sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
-		return -ENOMEM;
-
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		adapter->tx_ring[i].count = IXGBE_DEFAULT_TXD;
+		goto err_tx_ring_allocation;
 
 	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
 				   sizeof(struct ixgbe_ring), GFP_KERNEL);
-	if (!adapter->rx_ring) {
-		kfree(adapter->tx_ring);
-		return -ENOMEM;
-	}
+	if (!adapter->rx_ring)
+		goto err_rx_ring_allocation;
 
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		adapter->tx_ring[i].count = IXGBE_DEFAULT_TXD;
+		adapter->tx_ring[i].queue_index = i;
+	}
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i].adapter = adapter;
-		adapter->rx_ring[i].itr_register = IXGBE_EITR(i);
 		adapter->rx_ring[i].count = IXGBE_DEFAULT_RXD;
+		adapter->rx_ring[i].queue_index = i;
+	}
+
+	ixgbe_cache_ring_register(adapter);
+
+	return 0;
+
+err_rx_ring_allocation:
+	kfree(adapter->tx_ring);
+err_tx_ring_allocation:
+	return -ENOMEM;
+}
+
+/**
+ * ixgbe_set_interrupt_capability - set MSI-X or MSI if supported
+ * @adapter: board private structure to initialize
+ *
+ * Attempt to configure the interrupts using the best available
+ * capabilities of the hardware and the kernel.
+ **/
+static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
+						    *adapter)
+{
+	int err = 0;
+	int vector, v_budget;
+
+	/*
+	 * It's easy to be greedy for MSI-X vectors, but it really
+	 * doesn't do us much good if we have a lot more vectors
+	 * than CPU's.  So let's be conservative and only ask for
+	 * (roughly) twice the number of vectors as there are CPU's.
+	 */
+	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
+		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
+
+	/*
+	 * At the same time, hardware can only support a maximum of
+	 * MAX_MSIX_COUNT vectors.  With features such as RSS and VMDq,
+	 * we can easily reach upwards of 64 Rx descriptor queues and
+	 * 32 Tx queues.  Thus, we cap it off in those rare cases where
+	 * the cpu count also exceeds our vector limit.
+	 */
+	v_budget = min(v_budget, MAX_MSIX_COUNT);
+
+	/* A failure in MSI-X entry allocation isn't fatal, but it does
+	 * mean we disable MSI-X capabilities of the adapter. */
+	adapter->msix_entries = kcalloc(v_budget,
+					sizeof(struct msix_entry), GFP_KERNEL);
+	if (!adapter->msix_entries) {
+		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+		ixgbe_set_num_queues(adapter);
+		kfree(adapter->tx_ring);
+		kfree(adapter->rx_ring);
+		err = ixgbe_alloc_queues(adapter);
+		if (err) {
+			DPRINTK(PROBE, ERR, "Unable to allocate memory "
+					    "for queues\n");
+			goto out;
+		}
+
+		goto try_msi;
+	}
+
+	for (vector = 0; vector < v_budget; vector++)
+		adapter->msix_entries[vector].entry = vector;
+
+	ixgbe_acquire_msix_vectors(adapter, v_budget);
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+		goto out;
+
+try_msi:
+	err = pci_enable_msi(adapter->pdev);
+	if (!err) {
+		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
+	} else {
+		DPRINTK(HW, DEBUG, "Unable to allocate MSI interrupt, "
+				   "falling back to legacy.  Error: %d\n", err);
+		/* reset err */
+		err = 0;
+	}
+
+out:
+
+	return err;
+}
+
+static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
+{
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
+		pci_disable_msix(adapter->pdev);
+		kfree(adapter->msix_entries);
+		adapter->msix_entries = NULL;
+	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
+		adapter->flags &= ~IXGBE_FLAG_MSI_ENABLED;
+		pci_disable_msi(adapter->pdev);
+	}
+	return;
+}
+
+/**
+ * ixgbe_init_interrupt_scheme - Determine proper interrupt scheme
+ * @adapter: board private structure to initialize
+ *
+ * We determine which interrupt scheme to use based on...
+ * - Kernel support (MSI, MSI-X)
+ *   - which can be user-defined (via MODULE_PARAM)
+ * - Hardware queue count (num_*_queues)
+ *   - defined by miscellaneous hardware support/features (RSS, etc.)
+ **/
+static int __devinit ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
+{
+	int err;
+
+	/* Number of supported queues */
+	ixgbe_set_num_queues(adapter);
+
+	err = ixgbe_alloc_queues(adapter);
+	if (err) {
+		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
+		goto err_alloc_queues;
+	}
+
+	err = ixgbe_set_interrupt_capability(adapter);
+	if (err) {
+		DPRINTK(PROBE, ERR, "Unable to setup interrupt capabilities\n");
+		goto err_set_interrupt;
 	}
 
+	DPRINTK(DRV, INFO, "Multiqueue %s: Rx Queue count = %u, "
+			   "Tx Queue count = %u\n",
+		(adapter->num_rx_queues > 1) ? "Enabled" :
+		"Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
+
+	set_bit(__IXGBE_DOWN, &adapter->state);
+
 	return 0;
+
+err_set_interrupt:
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+err_alloc_queues:
+	return err;
 }
 
 /**
@@ -1645,11 +2061,18 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
+	unsigned int rss;
+
+	/* Set capability flags */
+	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
+	adapter->ring_feature[RING_F_RSS].indices = rss;
+	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 
 	/* default flow control settings */
 	hw->fc.original_type = ixgbe_fc_full;
 	hw->fc.type = ixgbe_fc_full;
 
+	/* select 10G link by default */
 	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
 	if (hw->mac.ops.reset(hw)) {
 		dev_err(&pdev->dev, "HW Init failed\n");
@@ -1667,16 +2090,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
-	/* Set the default values */
-	adapter->num_rx_queues = IXGBE_DEFAULT_RXQ;
-	adapter->num_tx_queues = 1;
+	/* enable rx csum by default */
 	adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
 
-	if (ixgbe_alloc_queues(adapter)) {
-		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
-		return -ENOMEM;
-	}
-
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -1716,7 +2132,6 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 		return -ENOMEM;
 	}
 
-	txdr->adapter = adapter;
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
 	txdr->work_limit = txdr->count;
@@ -1735,7 +2150,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 			     struct ixgbe_ring *rxdr)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	int size, desc_len;
+	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rxdr->count;
 	rxdr->rx_buffer_info = vmalloc(size);
@@ -1746,10 +2161,8 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	}
 	memset(rxdr->rx_buffer_info, 0, size);
 
-	desc_len = sizeof(union ixgbe_adv_rx_desc);
-
 	/* Round up to nearest 4K */
-	rxdr->size = rxdr->count * desc_len;
+	rxdr->size = rxdr->count * sizeof(union ixgbe_adv_rx_desc);
 	rxdr->size = ALIGN(rxdr->size, 4096);
 
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
@@ -1763,7 +2176,6 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 
 	rxdr->next_to_clean = 0;
 	rxdr->next_to_use = 0;
-	rxdr->adapter = adapter;
 
 	return 0;
 }
@@ -1841,8 +2253,7 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_setup_all_tx_resources - wrapper to allocate Tx resources
- *				  (Descriptors) for all queues
+ * ixgbe_setup_all_tx_resources - allocate all queues Tx resources
  * @adapter: board private structure
  *
  * If this function returns with an error, then it's possible one or
@@ -1868,8 +2279,7 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_setup_all_rx_resources - wrapper to allocate Rx resources
- *				  (Descriptors) for all queues
+ * ixgbe_setup_all_rx_resources - allocate all queues Rx resources
  * @adapter: board private structure
  *
  * If this function returns with an error, then it's possible one or
@@ -1911,6 +2321,9 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	    (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
 		return -EINVAL;
 
+	DPRINTK(PROBE, INFO, "changing MTU from %d to %d\n",
+		netdev->mtu, new_mtu);
+	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
 	if (netif_running(netdev))
@@ -1935,23 +2348,16 @@ static int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int err;
-	u32 num_rx_queues = adapter->num_rx_queues;
 
 	/* disallow open during test */
 	if (test_bit(__IXGBE_TESTING, &adapter->state))
 		return -EBUSY;
 
-try_intr_reinit:
 	/* allocate transmit descriptors */
 	err = ixgbe_setup_all_tx_resources(adapter);
 	if (err)
 		goto err_setup_tx;
 
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
-		num_rx_queues = 1;
-		adapter->num_rx_queues = num_rx_queues;
-	}
-
 	/* allocate receive descriptors */
 	err = ixgbe_setup_all_rx_resources(adapter);
 	if (err)
@@ -1959,31 +2365,10 @@ try_intr_reinit:
 
 	ixgbe_configure(adapter);
 
-	err = ixgbe_request_irq(adapter, &num_rx_queues);
+	err = ixgbe_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
 
-	/* ixgbe_request might have reduced num_rx_queues */
-	if (num_rx_queues < adapter->num_rx_queues) {
-		/* We didn't get MSI-X, so we need to release everything,
-		 * set our Rx queue count to num_rx_queues, and redo the
-		 * whole init process.
-		 */
-		ixgbe_free_irq(adapter);
-		if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
-			pci_disable_msi(adapter->pdev);
-			adapter->flags &= ~IXGBE_FLAG_MSI_ENABLED;
-		}
-		ixgbe_free_all_rx_resources(adapter);
-		ixgbe_free_all_tx_resources(adapter);
-		adapter->num_rx_queues = num_rx_queues;
-
-		/* Reset the hardware, and start over. */
-		ixgbe_reset(adapter);
-
-		goto try_intr_reinit;
-	}
-
 	err = ixgbe_up_complete(adapter);
 	if (err)
 		goto err_up;
@@ -2154,10 +2539,23 @@ static void ixgbe_watchdog(unsigned long data)
 
 	ixgbe_update_stats(adapter);
 
-	/* Reset the timer */
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		/* Cause software interrupt to ensure rx rings are cleaned */
+		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+			u32 eics =
+			 (1 << (adapter->num_msix_vectors - NON_Q_VECTORS)) - 1;
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, eics);
+		} else {
+			/* for legacy and MSI interrupts don't set any bits that
+			 * are enabled for EIAM, because this operation would
+			 * set *both* EIMS and EICS for any bit in EIAM */
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
+				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+		}
+		/* Reset the timer */
 		mod_timer(&adapter->watchdog_timer,
 			  round_jiffies(jiffies + 2 * HZ));
+	}
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
@@ -2604,6 +3002,31 @@ static void ixgbe_netpoll(struct net_device *netdev)
 #endif
 
 /**
+ * ixgbe_napi_add_all - prep napi structs for use
+ * @adapter: private struct
+ * helper function to napi_add each possible q_vector->napi
+ */
+static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
+{
+	int i, q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	int (*poll)(struct napi_struct *, int);
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		poll = &ixgbe_clean_rxonly;
+	} else {
+		poll = &ixgbe_poll;
+		/* only one q_vector for legacy modes */
+		q_vectors = 1;
+	}
+
+	for (i = 0; i < q_vectors; i++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
+		netif_napi_add(adapter->netdev, &q_vector->napi,
+			       (*poll), 64);
+	}
+}
+
+/**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in ixgbe_pci_tbl
@@ -2696,7 +3119,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	ixgbe_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgbe_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-	netif_napi_add(netdev, &adapter->napi, ixgbe_clean, 64);
 	netdev->vlan_rx_register = ixgbe_vlan_rx_register;
 	netdev->vlan_rx_add_vid = ixgbe_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = ixgbe_vlan_rx_kill_vid;
@@ -2719,6 +3141,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* Setup hw api */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
+	hw->mac.type  = ii->mac;
 
 	err = ii->get_invariants(hw);
 	if (err)
@@ -2770,9 +3193,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;
 
-	/* Interrupt Throttle Rate */
-	adapter->rx_eitr = (1000000 / IXGBE_DEFAULT_ITR_RX_USECS);
-	adapter->tx_eitr = (1000000 / IXGBE_DEFAULT_ITR_TX_USECS);
+	err = ixgbe_init_interrupt_scheme(adapter);
+	if (err)
+		goto err_sw_init;
 
 	/* print bus type/speed/width info */
 	pci_read_config_word(pdev, IXGBE_PCI_LINK_STATUS, &link_status);
@@ -2809,6 +3232,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
+	ixgbe_napi_add_all(adapter);
+
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
@@ -2823,6 +3248,7 @@ err_register:
 	ixgbe_release_hw_control(adapter);
 err_hw_init:
 err_sw_init:
+	ixgbe_reset_interrupt_capability(adapter);
 err_eeprom:
 	iounmap(hw->hw_addr);
 err_ioremap:
@@ -2856,14 +3282,17 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	ixgbe_release_hw_control(adapter);
+	ixgbe_reset_interrupt_capability(adapter);
 
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
+	ixgbe_release_hw_control(adapter);
 
 	iounmap(adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 
+	DPRINTK(PROBE, INFO, "complete\n");
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+
 	free_netdev(netdev);
 
 	pci_disable_device(pdev);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
