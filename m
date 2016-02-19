From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e/i40evf: Rewrite logic for 8 descriptor per packet check
Date: Fri, 19 Feb 2016 01:53:57 -0800
Message-ID: <1455875651-21696-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8261 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427403AbcBSJyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:15 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch is meant to rewrite the logic for how we determine if we can
transmit the frame or if it needs to be linearized.

The previous code for this function was using a mix of division and modulus
division as a part of computing if we need to take the slow path.  Instead
I have replaced this by simply working with a sliding window which will
tell us if the frame would be capable of causing a single packet to span
several descriptors.

The logic for the scan is fairly simple.  If any given group of 6 fragments
is less than gso_size - 1 then it is possible for us to have one byte
coming out of the first fragment, 6 fragments, and one or more bytes coming
out of the last fragment.  This gives us a total of 8 fragments
which exceeds what we can allow so we send such frames to be linearized.

Arguably the use of modulus might be more exact as the approach I propose
may generate some false positives.  However the likelihood of us taking much
of a hit for those false positives is fairly low, and I would rather not
add more overhead in the case where we are receiving a frame composed of 4K
pages.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c   |   6 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 105 +++++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  19 +++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 105 +++++++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  19 +++++
 5 files changed, 162 insertions(+), 92 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 518d72e..052df93 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1368,6 +1368,12 @@ static netdev_tx_t i40e_fcoe_xmit_frame(struct sk_buff *skb,
 		goto out_drop;
 
 	count = i40e_xmit_descriptor_count(skb);
+	if (i40e_chk_linearize(skb, count)) {
+		if (__skb_linearize(skb))
+			goto out_drop;
+		count = TXD_USE_COUNT(skb->len);
+		tx_ring->tx_stats.tx_linearize++;
+	}
 
 	/* need: 1 descriptor per page * PAGE_SIZE/I40E_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_head_len/I40E_MAX_DATA_PER_TXD,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f036570..5123646 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2593,59 +2593,71 @@ int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 }
 
 /**
- * i40e_chk_linearize - Check if there are more than 8 fragments per packet
+ * __i40e_chk_linearize - Check if there are more than 8 fragments per packet
  * @skb:      send buffer
- * @tx_flags: collected send information
  *
  * Note: Our HW can't scatter-gather more than 8 fragments to build
  * a packet on the wire and so we need to figure out the cases where we
  * need to linearize the skb.
  **/
-static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags)
+bool __i40e_chk_linearize(struct sk_buff *skb)
 {
-	struct skb_frag_struct *frag;
-	bool linearize = false;
-	unsigned int size = 0;
-	u16 num_frags;
-	u16 gso_segs;
+	const struct skb_frag_struct *frag, *stale;
+	int gso_size, nr_frags, sum;
 
-	num_frags = skb_shinfo(skb)->nr_frags;
-	gso_segs = skb_shinfo(skb)->gso_segs;
+	/* check to see if TSO is enabled, if so we may get a repreive */
+	gso_size = skb_shinfo(skb)->gso_size;
+	if (unlikely(!gso_size))
+		return true;
 
-	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
-		u16 j = 0;
+	/* no need to check if number of frags is less than 8 */
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	if (nr_frags < I40E_MAX_BUFFER_TXD)
+		return false;
 
-		if (num_frags < (I40E_MAX_BUFFER_TXD))
-			goto linearize_chk_done;
-		/* try the simple math, if we have too many frags per segment */
-		if (DIV_ROUND_UP((num_frags + gso_segs), gso_segs) >
-		    I40E_MAX_BUFFER_TXD) {
-			linearize = true;
-			goto linearize_chk_done;
-		}
-		frag = &skb_shinfo(skb)->frags[0];
-		/* we might still have more fragments per segment */
-		do {
-			size += skb_frag_size(frag);
-			frag++; j++;
-			if ((size >= skb_shinfo(skb)->gso_size) &&
-			    (j < I40E_MAX_BUFFER_TXD)) {
-				size = (size % skb_shinfo(skb)->gso_size);
-				j = (size) ? 1 : 0;
-			}
-			if (j == I40E_MAX_BUFFER_TXD) {
-				linearize = true;
-				break;
-			}
-			num_frags--;
-		} while (num_frags);
-	} else {
-		if (num_frags >= I40E_MAX_BUFFER_TXD)
-			linearize = true;
+	/* We need to walk through the list and validate that each group
+	 * of 6 fragments totals at least gso_size.  However we don't need
+	 * to perform such validation on the first or last 6 since the first
+	 * 6 cannot inherit any data from a descriptor before them, and the
+	 * last 6 cannot inherit any data from a descriptor after them.
+	 */
+	nr_frags -= I40E_MAX_BUFFER_TXD - 1;
+	frag = &skb_shinfo(skb)->frags[0];
+
+	/* Initialize size to the negative value of gso_size minus 1.  We
+	 * use this as the worst case scenerio in which the frag ahead
+	 * of us only provides one byte which is why we are limited to 6
+	 * descriptors for a single transmit as the header and previous
+	 * fragment are already consuming 2 descriptors.
+	 */
+	sum = 1 - gso_size;
+
+	/* Add size of frags 1 through 5 to create our initial sum */
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+
+	/* Walk through fragments adding latest fragment, testing it, and
+	 * then removing stale fragments from the sum.
+	 */
+	stale = &skb_shinfo(skb)->frags[0];
+	for (;;) {
+		sum += skb_frag_size(++frag);
+
+		/* if sum is negative we failed to make sufficient progress */
+		if (sum < 0)
+			return true;
+
+		/* use pre-decrement to avoid processing last fragment */
+		if (!--nr_frags)
+			break;
+
+		sum -= skb_frag_size(++stale);
 	}
 
-linearize_chk_done:
-	return linearize;
+	return false;
 }
 
 /**
@@ -2876,6 +2888,12 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	prefetch(skb->data);
 
 	count = i40e_xmit_descriptor_count(skb);
+	if (i40e_chk_linearize(skb, count)) {
+		if (__skb_linearize(skb))
+			goto out_drop;
+		count = TXD_USE_COUNT(skb->len);
+		tx_ring->tx_stats.tx_linearize++;
+	}
 
 	/* need: 1 descriptor per page * PAGE_SIZE/I40E_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_head_len/I40E_MAX_DATA_PER_TXD,
@@ -2916,11 +2934,6 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	if (tsyn)
 		tx_flags |= I40E_TX_FLAGS_TSYN;
 
-	if (i40e_chk_linearize(skb, tx_flags)) {
-		if (skb_linearize(skb))
-			goto out_drop;
-		tx_ring->tx_stats.tx_linearize++;
-	}
 	skb_tx_timestamp(skb);
 
 	/* always enable CRC insertion offload */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 5dbc958..5600970 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -337,6 +337,7 @@ int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector);
 u32 i40e_get_tx_pending(struct i40e_ring *ring, bool in_sw);
 int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size);
+bool __i40e_chk_linearize(struct sk_buff *skb);
 
 /**
  * i40e_get_head - Retrieve head from head writeback
@@ -392,4 +393,22 @@ static inline int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 		return 0;
 	return __i40e_maybe_stop_tx(tx_ring, size);
 }
+
+/**
+ * i40e_chk_linearize - Check if there are more than 8 fragments per packet
+ * @skb:      send buffer
+ * @count:    number of buffers used
+ *
+ * Note: Our HW can't scatter-gather more than 8 fragments to build
+ * a packet on the wire and so we need to figure out the cases where we
+ * need to linearize the skb.
+ **/
+static inline bool i40e_chk_linearize(struct sk_buff *skb, int count)
+{
+	/* we can only support up to 8 data buffers for a single send */
+	if (likely(count <= I40E_MAX_BUFFER_TXD))
+		return false;
+
+	return __i40e_chk_linearize(skb);
+}
 #endif /* _I40E_TXRX_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 9f38127..2369db5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1796,59 +1796,71 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 }
 
 /**
- * i40e_chk_linearize - Check if there are more than 8 fragments per packet
+ * __i40evf_chk_linearize - Check if there are more than 8 fragments per packet
  * @skb:      send buffer
- * @tx_flags: collected send information
  *
  * Note: Our HW can't scatter-gather more than 8 fragments to build
  * a packet on the wire and so we need to figure out the cases where we
  * need to linearize the skb.
  **/
-static bool i40e_chk_linearize(struct sk_buff *skb, u32 tx_flags)
+bool __i40evf_chk_linearize(struct sk_buff *skb)
 {
-	struct skb_frag_struct *frag;
-	bool linearize = false;
-	unsigned int size = 0;
-	u16 num_frags;
-	u16 gso_segs;
+	const struct skb_frag_struct *frag, *stale;
+	int gso_size, nr_frags, sum;
 
-	num_frags = skb_shinfo(skb)->nr_frags;
-	gso_segs = skb_shinfo(skb)->gso_segs;
+	/* check to see if TSO is enabled, if so we may get a repreive */
+	gso_size = skb_shinfo(skb)->gso_size;
+	if (unlikely(!gso_size))
+		return true;
 
-	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
-		u16 j = 0;
+	/* no need to check if number of frags is less than 8 */
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	if (nr_frags < I40E_MAX_BUFFER_TXD)
+		return false;
 
-		if (num_frags < (I40E_MAX_BUFFER_TXD))
-			goto linearize_chk_done;
-		/* try the simple math, if we have too many frags per segment */
-		if (DIV_ROUND_UP((num_frags + gso_segs), gso_segs) >
-		    I40E_MAX_BUFFER_TXD) {
-			linearize = true;
-			goto linearize_chk_done;
-		}
-		frag = &skb_shinfo(skb)->frags[0];
-		/* we might still have more fragments per segment */
-		do {
-			size += skb_frag_size(frag);
-			frag++; j++;
-			if ((size >= skb_shinfo(skb)->gso_size) &&
-			    (j < I40E_MAX_BUFFER_TXD)) {
-				size = (size % skb_shinfo(skb)->gso_size);
-				j = (size) ? 1 : 0;
-			}
-			if (j == I40E_MAX_BUFFER_TXD) {
-				linearize = true;
-				break;
-			}
-			num_frags--;
-		} while (num_frags);
-	} else {
-		if (num_frags >= I40E_MAX_BUFFER_TXD)
-			linearize = true;
+	/* We need to walk through the list and validate that each group
+	 * of 6 fragments totals at least gso_size.  However we don't need
+	 * to perform such validation on the first or last 6 since the first
+	 * 6 cannot inherit any data from a descriptor before them, and the
+	 * last 6 cannot inherit any data from a descriptor after them.
+	 */
+	nr_frags -= I40E_MAX_BUFFER_TXD - 1;
+	frag = &skb_shinfo(skb)->frags[0];
+
+	/* Initialize size to the negative value of gso_size minus 1.  We
+	 * use this as the worst case scenerio in which the frag ahead
+	 * of us only provides one byte which is why we are limited to 6
+	 * descriptors for a single transmit as the header and previous
+	 * fragment are already consuming 2 descriptors.
+	 */
+	sum = 1 - gso_size;
+
+	/* Add size of frags 1 through 5 to create our initial sum */
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+	sum += skb_frag_size(++frag);
+
+	/* Walk through fragments adding latest fragment, testing it, and
+	 * then removing stale fragments from the sum.
+	 */
+	stale = &skb_shinfo(skb)->frags[0];
+	for (;;) {
+		sum += skb_frag_size(++frag);
+
+		/* if sum is negative we failed to make sufficient progress */
+		if (sum < 0)
+			return true;
+
+		/* use pre-decrement to avoid processing last fragment */
+		if (!--nr_frags)
+			break;
+
+		sum -= skb_frag_size(++stale);
 	}
 
-linearize_chk_done:
-	return linearize;
+	return false;
 }
 
 /**
@@ -2095,6 +2107,12 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	prefetch(skb->data);
 
 	count = i40e_xmit_descriptor_count(skb);
+	if (i40e_chk_linearize(skb, count)) {
+		if (__skb_linearize(skb))
+			goto out_drop;
+		count = TXD_USE_COUNT(skb->len);
+		tx_ring->tx_stats.tx_linearize++;
+	}
 
 	/* need: 1 descriptor per page * PAGE_SIZE/I40E_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_head_len/I40E_MAX_DATA_PER_TXD,
@@ -2130,11 +2148,6 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (tso)
 		tx_flags |= I40E_TX_FLAGS_TSO;
 
-	if (i40e_chk_linearize(skb, tx_flags)) {
-		if (skb_linearize(skb))
-			goto out_drop;
-		tx_ring->tx_stats.tx_linearize++;
-	}
 	skb_tx_timestamp(skb);
 
 	/* always enable CRC insertion offload */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 1f719d0..c1dd8c5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -327,6 +327,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget);
 void i40evf_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector);
 u32 i40evf_get_tx_pending(struct i40e_ring *ring, bool in_sw);
 int __i40evf_maybe_stop_tx(struct i40e_ring *tx_ring, int size);
+bool __i40evf_chk_linearize(struct sk_buff *skb);
 
 /**
  * i40e_get_head - Retrieve head from head writeback
@@ -382,4 +383,22 @@ static inline int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 		return 0;
 	return __i40evf_maybe_stop_tx(tx_ring, size);
 }
+
+/**
+ * i40e_chk_linearize - Check if there are more than 8 fragments per packet
+ * @skb:      send buffer
+ * @count:    number of buffers used
+ *
+ * Note: Our HW can't scatter-gather more than 8 fragments to build
+ * a packet on the wire and so we need to figure out the cases where we
+ * need to linearize the skb.
+ **/
+static inline bool i40e_chk_linearize(struct sk_buff *skb, int count)
+{
+	/* we can only support up to 8 data buffers for a single send */
+	if (likely(count <= I40E_MAX_BUFFER_TXD))
+		return false;
+
+	return __i40evf_chk_linearize(skb);
+}
 #endif /* _I40E_TXRX_H_ */
-- 
2.5.0
