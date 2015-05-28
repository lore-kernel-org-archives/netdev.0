From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40evf: skb->xmit_more support
Date: Thu, 28 May 2015 04:25:36 -0700
Message-ID: <1432812339-17129-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbbE1LZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:58 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Eric added support for skb->xmit_more in i40e, this ports that into
i40evf as well.

Support skb->xmit_more in i40evf is straightforward; we need to move
around i40e_maybe_stop_tx() call to correctly test netif_xmit_stopped()
before taking the decision to not kick the NIC.

Change-ID: Idddda6a2e4a7ab335631c91ced51f55b25eb8468
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 88 ++++++++++++++-------------
 1 file changed, 47 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 1c79a08..6450663 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1670,6 +1670,47 @@ linearize_chk_done:
 }
 
 /**
+ * __i40evf_maybe_stop_tx - 2nd level check for tx stop conditions
+ * @tx_ring: the ring to be checked
+ * @size:    the size buffer we want to assure is available
+ *
+ * Returns -EBUSY if a stop is needed, else 0
+ **/
+static inline int __i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
+{
+	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	/* Memory barrier before checking head and tail */
+	smp_mb();
+
+	/* Check again in a case another CPU has just made room available. */
+	if (likely(I40E_DESC_UNUSED(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! - use start_queue because it doesn't call schedule */
+	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	++tx_ring->tx_stats.restart_queue;
+	return 0;
+}
+
+/**
+ * i40evf_maybe_stop_tx - 1st level check for tx stop conditions
+ * @tx_ring: the ring to be checked
+ * @size:    the size buffer we want to assure is available
+ *
+ * Returns 0 if stop is not needed
+ **/
+#ifdef I40E_FCOE
+int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
+#else
+static int i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
+#endif
+{
+	if (likely(I40E_DESC_UNUSED(tx_ring) >= size))
+		return 0;
+	return __i40evf_maybe_stop_tx(tx_ring, size);
+}
+
+/**
  * i40e_tx_map - Build the Tx descriptor
  * @tx_ring:  ring to send buffer on
  * @skb:      send buffer
@@ -1806,8 +1847,12 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	tx_ring->next_to_use = i;
 
+	i40evf_maybe_stop_tx(tx_ring, DESC_NEEDED);
 	/* notify HW of packet */
-	writel(i, tx_ring->tail);
+	if (!skb->xmit_more ||
+	    netif_xmit_stopped(netdev_get_tx_queue(tx_ring->netdev,
+						   tx_ring->queue_index)))
+		writel(i, tx_ring->tail);
 
 	return;
 
@@ -1829,43 +1874,6 @@ dma_error:
 }
 
 /**
- * __i40e_maybe_stop_tx - 2nd level check for tx stop conditions
- * @tx_ring: the ring to be checked
- * @size:    the size buffer we want to assure is available
- *
- * Returns -EBUSY if a stop is needed, else 0
- **/
-static inline int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
-{
-	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
-	/* Memory barrier before checking head and tail */
-	smp_mb();
-
-	/* Check again in a case another CPU has just made room available. */
-	if (likely(I40E_DESC_UNUSED(tx_ring) < size))
-		return -EBUSY;
-
-	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
-	++tx_ring->tx_stats.restart_queue;
-	return 0;
-}
-
-/**
- * i40e_maybe_stop_tx - 1st level check for tx stop conditions
- * @tx_ring: the ring to be checked
- * @size:    the size buffer we want to assure is available
- *
- * Returns 0 if stop is not needed
- **/
-static int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
-{
-	if (likely(I40E_DESC_UNUSED(tx_ring) >= size))
-		return 0;
-	return __i40e_maybe_stop_tx(tx_ring, size);
-}
-
-/**
  * i40e_xmit_descriptor_count - calculate number of tx descriptors needed
  * @skb:     send buffer
  * @tx_ring: ring to send buffer on
@@ -1890,7 +1898,7 @@ static int i40e_xmit_descriptor_count(struct sk_buff *skb,
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
 	count += TXD_USE_COUNT(skb_headlen(skb));
-	if (i40e_maybe_stop_tx(tx_ring, count + 4 + 1)) {
+	if (i40evf_maybe_stop_tx(tx_ring, count + 4 + 1)) {
 		tx_ring->tx_stats.tx_busy++;
 		return 0;
 	}
@@ -1966,8 +1974,6 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
 		    td_cmd, td_offset);
 
-	i40e_maybe_stop_tx(tx_ring, DESC_NEEDED);
-
 	return NETDEV_TX_OK;
 
 out_drop:
-- 
2.1.0
