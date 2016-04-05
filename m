From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] i40e/i40evf: Allow up to 12K bytes of data per Tx descriptor instead of 8K
Date: Tue,  5 Apr 2016 13:17:19 -0700
Message-ID: <1459887455-146634-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43343 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759270AbcDEURj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:39 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

>From what I can tell the practical limitation on the size of the Tx data
buffer is the fact that the Tx descriptor is limited to 14 bits.  As such
we cannot use 16K as is typically used on the other Intel drivers.  However
artificially limiting ourselves to 8K can be expensive as this means that
we will consume up to 10 descriptors (1 context, 1 for header, and 9 for
payload, non-8K aligned) in a single send.

I propose that we can reduce this by increasing the maximum data for a 4K
aligned block to 12K.  We can reduce the descriptors used for a 32K aligned
block by 1 by increasing the size like this.  In addition we still have the
4K - 1 of space that is still unused.  We can use this as a bit of extra
padding when dealing with data that is not aligned to 4K.

By aligning the descriptors after the first to 4K we can improve the
efficiency of PCIe accesses as we can avoid using byte enables and can fetch
full TLP transactions after the first fetch of the buffer.  This helps to
improve PCIe efficiency.  Below is the results of testing before and after
with this patch:

Recv   Send   Send                         Utilization      Service Demand
Socket Socket Message  Elapsed             Send     Recv    Send    Recv
Size   Size   Size     Time    Throughput  local    remote  local   remote
bytes  bytes  bytes    secs.   10^6bits/s  % S      % U     us/KB   us/KB
Before:
87380  16384  16384    10.00     33682.24  20.27    -1.00   0.592   -1.00
After:
87380  16384  16384    10.00     34204.08  20.54    -1.00   0.590   -1.00

So the net result of this patch is that we have a small gain in throughput
due to a reduction in overhead for putting together the frame.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c   |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 13 +++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 35 ++++++++++++++++++++++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 13 +++++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 35 ++++++++++++++++++++++++---
 5 files changed, 83 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 8ad162c..92d2208 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1371,7 +1371,7 @@ static netdev_tx_t i40e_fcoe_xmit_frame(struct sk_buff *skb,
 	if (i40e_chk_linearize(skb, count)) {
 		if (__skb_linearize(skb))
 			goto out_drop;
-		count = TXD_USE_COUNT(skb->len);
+		count = i40e_txd_use_count(skb->len);
 		tx_ring->tx_stats.tx_linearize++;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 084d0ab..9af1411 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2717,6 +2717,8 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	tx_bi = first;
 
 	for (frag = &skb_shinfo(skb)->frags[0];; frag++) {
+		unsigned int max_data = I40E_MAX_DATA_PER_TXD_ALIGNED;
+
 		if (dma_mapping_error(tx_ring->dev, dma))
 			goto dma_error;
 
@@ -2724,12 +2726,14 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		dma_unmap_len_set(tx_bi, len, size);
 		dma_unmap_addr_set(tx_bi, dma, dma);
 
+		/* align size to end of page */
+		max_data += -dma & (I40E_MAX_READ_REQ_SIZE - 1);
 		tx_desc->buffer_addr = cpu_to_le64(dma);
 
 		while (unlikely(size > I40E_MAX_DATA_PER_TXD)) {
 			tx_desc->cmd_type_offset_bsz =
 				build_ctob(td_cmd, td_offset,
-					   I40E_MAX_DATA_PER_TXD, td_tag);
+					   max_data, td_tag);
 
 			tx_desc++;
 			i++;
@@ -2740,9 +2744,10 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 				i = 0;
 			}
 
-			dma += I40E_MAX_DATA_PER_TXD;
-			size -= I40E_MAX_DATA_PER_TXD;
+			dma += max_data;
+			size -= max_data;
 
+			max_data = I40E_MAX_DATA_PER_TXD_ALIGNED;
 			tx_desc->buffer_addr = cpu_to_le64(dma);
 		}
 
@@ -2892,7 +2897,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	if (i40e_chk_linearize(skb, count)) {
 		if (__skb_linearize(skb))
 			goto out_drop;
-		count = TXD_USE_COUNT(skb->len);
+		count = i40e_txd_use_count(skb->len);
 		tx_ring->tx_stats.tx_linearize++;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index cdd5dc0..9e654e6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -146,10 +146,39 @@ enum i40e_dyn_idx_t {
 
 #define I40E_MAX_BUFFER_TXD	8
 #define I40E_MIN_TX_LEN		17
-#define I40E_MAX_DATA_PER_TXD	8192
+
+/* The size limit for a transmit buffer in a descriptor is (16K - 1).
+ * In order to align with the read requests we will align the value to
+ * the nearest 4K which represents our maximum read request size.
+ */
+#define I40E_MAX_READ_REQ_SIZE		4096
+#define I40E_MAX_DATA_PER_TXD		(16 * 1024 - 1)
+#define I40E_MAX_DATA_PER_TXD_ALIGNED \
+	(I40E_MAX_DATA_PER_TXD & ~(I40E_MAX_READ_REQ_SIZE - 1))
+
+/* This ugly bit of math is equivalent to DIV_ROUNDUP(size, X) where X is
+ * the value I40E_MAX_DATA_PER_TXD_ALIGNED.  It is needed due to the fact
+ * that 12K is not a power of 2 and division is expensive.  It is used to
+ * approximate the number of descriptors used per linear buffer.  Note
+ * that this will overestimate in some cases as it doesn't account for the
+ * fact that we will add up to 4K - 1 in aligning the 12K buffer, however
+ * the error should not impact things much as large buffers usually mean
+ * we will use fewer descriptors then there are frags in an skb.
+ */
+static inline unsigned int i40e_txd_use_count(unsigned int size)
+{
+	const unsigned int max = I40E_MAX_DATA_PER_TXD_ALIGNED;
+	const unsigned int reciprocal = ((1ull << 32) - 1 + (max / 2)) / max;
+	unsigned int adjust = ~(u32)0;
+
+	/* if we rounded up on the reciprocal pull down the adjustment */
+	if ((max * reciprocal) > adjust)
+		adjust = ~(u32)(reciprocal - 1);
+
+	return (u32)((((u64)size * reciprocal) + adjust) >> 32);
+}
 
 /* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), I40E_MAX_DATA_PER_TXD)
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 #define I40E_MIN_DESC_PENDING	4
 
@@ -377,7 +406,7 @@ static inline int i40e_xmit_descriptor_count(struct sk_buff *skb)
 	int count = 0, size = skb_headlen(skb);
 
 	for (;;) {
-		count += TXD_USE_COUNT(size);
+		count += i40e_txd_use_count(size);
 
 		if (!nr_frags--)
 			break;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index ebcc25c..5f9c1bb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1936,6 +1936,8 @@ static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	tx_bi = first;
 
 	for (frag = &skb_shinfo(skb)->frags[0];; frag++) {
+		unsigned int max_data = I40E_MAX_DATA_PER_TXD_ALIGNED;
+
 		if (dma_mapping_error(tx_ring->dev, dma))
 			goto dma_error;
 
@@ -1943,12 +1945,14 @@ static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		dma_unmap_len_set(tx_bi, len, size);
 		dma_unmap_addr_set(tx_bi, dma, dma);
 
+		/* align size to end of page */
+		max_data += -dma & (I40E_MAX_READ_REQ_SIZE - 1);
 		tx_desc->buffer_addr = cpu_to_le64(dma);
 
 		while (unlikely(size > I40E_MAX_DATA_PER_TXD)) {
 			tx_desc->cmd_type_offset_bsz =
 				build_ctob(td_cmd, td_offset,
-					   I40E_MAX_DATA_PER_TXD, td_tag);
+					   max_data, td_tag);
 
 			tx_desc++;
 			i++;
@@ -1959,9 +1963,10 @@ static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 				i = 0;
 			}
 
-			dma += I40E_MAX_DATA_PER_TXD;
-			size -= I40E_MAX_DATA_PER_TXD;
+			dma += max_data;
+			size -= max_data;
 
+			max_data = I40E_MAX_DATA_PER_TXD_ALIGNED;
 			tx_desc->buffer_addr = cpu_to_le64(dma);
 		}
 
@@ -2110,7 +2115,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	if (i40e_chk_linearize(skb, count)) {
 		if (__skb_linearize(skb))
 			goto out_drop;
-		count = TXD_USE_COUNT(skb->len);
+		count = i40e_txd_use_count(skb->len);
 		tx_ring->tx_stats.tx_linearize++;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index c1dd8c5..3ec0ea5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -146,10 +146,39 @@ enum i40e_dyn_idx_t {
 
 #define I40E_MAX_BUFFER_TXD	8
 #define I40E_MIN_TX_LEN		17
-#define I40E_MAX_DATA_PER_TXD	8192
+
+/* The size limit for a transmit buffer in a descriptor is (16K - 1).
+ * In order to align with the read requests we will align the value to
+ * the nearest 4K which represents our maximum read request size.
+ */
+#define I40E_MAX_READ_REQ_SIZE		4096
+#define I40E_MAX_DATA_PER_TXD		(16 * 1024 - 1)
+#define I40E_MAX_DATA_PER_TXD_ALIGNED \
+	(I40E_MAX_DATA_PER_TXD & ~(I40E_MAX_READ_REQ_SIZE - 1))
+
+/* This ugly bit of math is equivalent to DIV_ROUNDUP(size, X) where X is
+ * the value I40E_MAX_DATA_PER_TXD_ALIGNED.  It is needed due to the fact
+ * that 12K is not a power of 2 and division is expensive.  It is used to
+ * approximate the number of descriptors used per linear buffer.  Note
+ * that this will overestimate in some cases as it doesn't account for the
+ * fact that we will add up to 4K - 1 in aligning the 12K buffer, however
+ * the error should not impact things much as large buffers usually mean
+ * we will use fewer descriptors then there are frags in an skb.
+ */
+static inline unsigned int i40e_txd_use_count(unsigned int size)
+{
+	const unsigned int max = I40E_MAX_DATA_PER_TXD_ALIGNED;
+	const unsigned int reciprocal = ((1ull << 32) - 1 + (max / 2)) / max;
+	unsigned int adjust = ~(u32)0;
+
+	/* if we rounded up on the reciprocal pull down the adjustment */
+	if ((max * reciprocal) > adjust)
+		adjust = ~(u32)(reciprocal - 1);
+
+	return (u32)((((u64)size * reciprocal) + adjust) >> 32);
+}
 
 /* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), I40E_MAX_DATA_PER_TXD)
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 #define I40E_MIN_DESC_PENDING	4
 
@@ -359,7 +388,7 @@ static inline int i40e_xmit_descriptor_count(struct sk_buff *skb)
 	int count = 0, size = skb_headlen(skb);
 
 	for (;;) {
-		count += TXD_USE_COUNT(size);
+		count += i40e_txd_use_count(size);
 
 		if (!nr_frags--)
 			break;
-- 
2.5.5
