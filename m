From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Sun, 19 May 2013 13:25:51 +0300
Message-ID: <20130519102551.12527.21152.stgit@ladj378.jer.intel.com>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Don Skidmore <donanld.c.skidmore@intel.com>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Dave Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Add the ixgbe driver code implementing ndo_ll_poll.
It should be easy for other drivers to do something similar
in order to enable support for CONFIG_INET_LL_RX_POLL

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   96 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   80 +++++++++++++++++++--
 2 files changed, 168 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index ca93238..72be661 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -356,9 +356,105 @@ struct ixgbe_q_vector {
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[IFNAMSIZ + 9];
 
+#ifdef CONFIG_INET_LL_RX_POLL
+	unsigned int state;
+#define IXGBE_QV_STATE_IDLE        0
+#define IXGBE_QV_STATE_NAPI	   1    /* NAPI owns this QV */
+#define IXGBE_QV_STATE_POLL	   2    /* poll owns this QV */
+#define IXGBE_QV_LOCKED (IXGBE_QV_STATE_NAPI | IXGBE_QV_STATE_POLL)
+#define IXGBE_QV_STATE_NAPI_YIELD  4    /* NAPI yielded this QV */
+#define IXGBE_QV_STATE_POLL_YIELD  8    /* poll yielded this QV */
+#define IXGBE_QV_YIELD (IXGBE_QV_STATE_NAPI_YIELD | IXGBE_QV_STATE_POLL_YIELD)
+#define IXGBE_QV_USER_PEND (IXGBE_QV_STATE_POLL | IXGBE_QV_STATE_POLL_YIELD)
+	spinlock_t lock;
+#endif  /* CONFIG_INET_LL_RX_POLL */
+
 	/* for dynamic allocation of rings associated with this q_vector */
 	struct ixgbe_ring ring[0] ____cacheline_internodealigned_in_smp;
 };
+#ifdef CONFIG_INET_LL_RX_POLL
+static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
+{
+
+	spin_lock_init(&q_vector->lock);
+	q_vector->state = IXGBE_QV_STATE_IDLE;
+}
+
+/* called from the device poll rutine to get ownership of a q_vector */
+static inline int ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
+{
+	int rc = true;
+	spin_lock(&q_vector->lock);
+	if (q_vector->state & IXGBE_QV_LOCKED) {
+		WARN_ON(q_vector->state & IXGBE_QV_STATE_NAPI);
+		q_vector->state |= IXGBE_QV_STATE_NAPI_YIELD;
+		rc = false;
+	} else
+		/* we don't care if someone yielded */
+		q_vector->state = IXGBE_QV_STATE_NAPI;
+	spin_unlock(&q_vector->lock);
+	return rc;
+}
+
+/* returns true is someone tried to get the qv while napi had it */
+static inline int ixgbe_qv_unlock_napi(struct ixgbe_q_vector *q_vector)
+{
+	int rc = false;
+	spin_lock(&q_vector->lock);
+	WARN_ON(q_vector->state & (IXGBE_QV_STATE_POLL |
+			       IXGBE_QV_STATE_NAPI_YIELD));
+
+	if (q_vector->state & IXGBE_QV_STATE_POLL_YIELD)
+		rc = true;
+	q_vector->state = IXGBE_QV_STATE_IDLE;
+	spin_unlock(&q_vector->lock);
+	return rc;
+}
+
+/* called from ixgbe_low_latency_poll() */
+static inline int ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
+{
+	int rc = true;
+	spin_lock_bh(&q_vector->lock);
+	if ((q_vector->state & IXGBE_QV_LOCKED)) {
+		q_vector->state |= IXGBE_QV_STATE_POLL_YIELD;
+		rc = false;
+	} else
+		/* preserve yield marks */
+		q_vector->state |= IXGBE_QV_STATE_POLL;
+	spin_unlock_bh(&q_vector->lock);
+	return rc;
+}
+
+/* returns true if someone tried to get the qv while it was locked */
+static inline int ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
+{
+	int rc = false;
+	spin_lock_bh(&q_vector->lock);
+	WARN_ON(q_vector->state & (IXGBE_QV_STATE_NAPI));
+
+	if (q_vector->state & IXGBE_QV_STATE_POLL_YIELD)
+		rc = true;
+	q_vector->state = IXGBE_QV_STATE_IDLE;
+	spin_unlock_bh(&q_vector->lock);
+	return rc;
+}
+
+/* true if a socket is polling, even if it did not get the lock */
+static inline int ixgbe_qv_ll_polling(struct ixgbe_q_vector *q_vector)
+{
+	WARN_ON(!(q_vector->state & IXGBE_QV_LOCKED));
+	return q_vector->state & IXGBE_QV_USER_PEND;
+}
+#else
+#define ixgbe_qv_init_lock(qv) do {} while (0)
+#define ixgbe_qv_lock_napi(qv) 1
+#define ixgbe_qv_unlock_napi(qv) 0
+#define ixgbe_qv_lock_poll(qv) 0
+#define ixgbe_qv_unlock_poll(qv) 0
+#define ixgbe_qv_ll_polling(qv) 0
+#endif /* CONFIG_INET_LL_RX_POLL */
+
 #ifdef CONFIG_IXGBE_HWMON
 
 #define IXGBE_HWMON_TYPE_LOC		0
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d30fbdd..628b7b1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -47,6 +47,7 @@
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
+#include <net/ll_poll.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -144,6 +145,14 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+#ifdef CONFIG_INET_LL_RX_POLL
+static int allow_unsafe_removal;
+static int unsafe_to_remove;
+module_param(allow_unsafe_removal, int, 0);
+MODULE_PARM_DESC(allow_unsafe_removal,
+	"Allow removal of module after low latency receive was used");
+#endif
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
@@ -1504,7 +1513,9 @@ static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+	if (ixgbe_qv_ll_polling(q_vector))
+		netif_receive_skb(skb);
+	else if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
 		napi_gro_receive(&q_vector->napi, skb);
 	else
 		netif_rx(skb);
@@ -1892,9 +1903,9 @@ dma_sync:
  * expensive overhead for IOMMU access this provides a means of avoiding
  * it by maintaining the mapping of the page to the syste.
  *
- * Returns true if all work is completed without reaching budget
+ * Returns amount of work completed
  **/
-static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
+static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *rx_ring,
 			       const int budget)
 {
@@ -1976,6 +1987,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 #endif /* IXGBE_FCOE */
+		skb_mark_ll(skb, &q_vector->napi);
 		ixgbe_rx_skb(q_vector, skb);
 
 		/* update budget accounting */
@@ -1992,9 +2004,45 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
 
-	return (total_rx_packets < budget);
+	return total_rx_packets;
 }
 
+#ifdef CONFIG_INET_LL_RX_POLL
+/* must be called with local_bh_disable()d */
+static int ixgbe_low_latency_recv(struct napi_struct *napi)
+{
+	struct ixgbe_q_vector *q_vector =
+			container_of(napi, struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_ring  *ring;
+	int found;
+
+	if (unlikely(!unsafe_to_remove)) {
+		unsafe_to_remove = 1;
+		if (!allow_unsafe_removal) {
+			pr_info("module may no longer be removed\n");
+			try_module_get(THIS_MODULE);
+		}
+	}
+
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		return LL_FLUSH_FAILED;
+
+	if (!ixgbe_qv_lock_poll(q_vector))
+		return LL_FLUSH_BUSY;
+
+	ixgbe_for_each_ring(ring, q_vector->rx) {
+		found = ixgbe_clean_rx_irq(q_vector, ring, 4);
+		if (found)
+			break;
+	}
+
+	ixgbe_qv_unlock_poll(q_vector);
+
+	return LL_FLUSH_DONE;
+}
+#endif	/* CONFIG_INET_LL_RX_POLL */
+
 /**
  * ixgbe_configure_msix - Configure MSI-X hardware
  * @adapter: board private structure
@@ -2550,6 +2598,9 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	ixgbe_for_each_ring(ring, q_vector->tx)
 		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
+	if (!ixgbe_qv_lock_napi(q_vector))
+		return budget;
+
 	/* attempt to distribute budget to each queue fairly, but don't allow
 	 * the budget to go below 1 because we'll exit polling */
 	if (q_vector->rx.count > 1)
@@ -2558,9 +2609,10 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 		per_ring_budget = budget;
 
 	ixgbe_for_each_ring(ring, q_vector->rx)
-		clean_complete &= ixgbe_clean_rx_irq(q_vector, ring,
-						     per_ring_budget);
+		clean_complete &= (ixgbe_clean_rx_irq(q_vector, ring,
+				   per_ring_budget) < per_ring_budget);
 
+	ixgbe_qv_unlock_napi(q_vector);
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
 		return budget;
@@ -3747,16 +3799,25 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
 
-	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
+	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
+		ixgbe_qv_init_lock(adapter->q_vector[q_idx]);
 		napi_enable(&adapter->q_vector[q_idx]->napi);
+	}
 }
 
 static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
 
-	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++)
+	local_bh_disable(); /* for ixgbe_qv_lock_napi() */
+	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
 		napi_disable(&adapter->q_vector[q_idx]->napi);
+		while (!ixgbe_qv_lock_napi(adapter->q_vector[q_idx])) {
+			pr_info("QV %d locked\n", q_idx);
+			mdelay(1);
+		}
+	}
+	local_bh_enable();
 }
 
 #ifdef CONFIG_IXGBE_DCB
@@ -7177,6 +7238,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
+#ifdef CONFIG_INET_LL_RX_POLL
+	.ndo_ll_poll		= ixgbe_low_latency_recv,
+#endif
 #ifdef IXGBE_FCOE
 	.ndo_fcoe_ddp_setup = ixgbe_fcoe_ddp_get,
 	.ndo_fcoe_ddp_target = ixgbe_fcoe_ddp_target,


------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
