From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH v2] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 16:15:37 -0700
Message-ID: <20160330231116.12643.59554.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36391 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbcC3XPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 19:15:39 -0400
Received: by mail-pf0-f179.google.com with SMTP id e128so32730187pfe.3
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 16:15:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a bug introduced based on my interpretation of the
XL710 datasheet.  Specifically section 8.4.1 states that "A single transmit
packet may span up to 8 buffers (up to 8 data descriptors per packet
including both the header and payload buffers)."  It then later goes on to
say that each segment for a TSO obeys the previous rule, however it then
refers to TSO header and the segment payload buffers.

I believe the actual limit for fragments with TSO and a skbuff that has
payload data in the header portion of the buffer is actually only 7
fragments as the skb->data portion counts as 2 buffers, one for the TSO
header, and one for a segment payload buffer.

Fixes: 2d37490b82af ("i40e/i40evf: Rewrite logic for 8 descriptor per packet check")
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: I realized that I overlooked the check in the inline function and as a
    result we were still allowing for cases where 8 descriptors were being
    used per packet and this would result in 9 DMA buffers.  I updated the
    code so that we only allow 8 in the case of a single send, otherwise we
    go into the function that walks the frags to verify each block.

I have tested this using rds-stress and it seems to run traffic without
throwing any errors.

 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |   49 ++++++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |   10 ++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |   49 ++++++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |   10 ++++-
 4 files changed, 62 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5d5fa5359a1d..6bf705add321 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2597,35 +2597,34 @@ int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 }
 
 /**
- * __i40e_chk_linearize - Check if there are more than 8 fragments per packet
+ * __i40e_chk_linearize - Check if there are more than 8 buffers per packet
  * @skb:      send buffer
  *
- * Note: Our HW can't scatter-gather more than 8 fragments to build
- * a packet on the wire and so we need to figure out the cases where we
- * need to linearize the skb.
+ * Note: Our HW can't DMA more than 8 buffers to build a packet on the wire
+ * and so we need to figure out the cases where we need to linearize the skb.
+ *
+ * For TSO we need to count the TSO header and segment payload separately.
+ * As such we need to check cases where we have 7 fragments or more as we
+ * can potentially require 9 DMA transactions, 1 for the TSO header, 1 for
+ * the segment payload in the first descriptor, and another 7 for the
+ * fragments.
  **/
 bool __i40e_chk_linearize(struct sk_buff *skb)
 {
 	const struct skb_frag_struct *frag, *stale;
-	int gso_size, nr_frags, sum;
-
-	/* check to see if TSO is enabled, if so we may get a repreive */
-	gso_size = skb_shinfo(skb)->gso_size;
-	if (unlikely(!gso_size))
-		return true;
+	int nr_frags, sum;
 
-	/* no need to check if number of frags is less than 8 */
+	/* no need to check if number of frags is less than 7 */
 	nr_frags = skb_shinfo(skb)->nr_frags;
-	if (nr_frags < I40E_MAX_BUFFER_TXD)
+	if (nr_frags < (I40E_MAX_BUFFER_TXD - 1))
 		return false;
 
 	/* We need to walk through the list and validate that each group
 	 * of 6 fragments totals at least gso_size.  However we don't need
-	 * to perform such validation on the first or last 6 since the first
-	 * 6 cannot inherit any data from a descriptor before them, and the
-	 * last 6 cannot inherit any data from a descriptor after them.
+	 * to perform such validation on the last 6 since the last 6 cannot
+	 * inherit any data from a descriptor after them.
 	 */
-	nr_frags -= I40E_MAX_BUFFER_TXD - 1;
+	nr_frags -= I40E_MAX_BUFFER_TXD - 2;
 	frag = &skb_shinfo(skb)->frags[0];
 
 	/* Initialize size to the negative value of gso_size minus 1.  We
@@ -2634,21 +2633,21 @@ bool __i40e_chk_linearize(struct sk_buff *skb)
 	 * descriptors for a single transmit as the header and previous
 	 * fragment are already consuming 2 descriptors.
 	 */
-	sum = 1 - gso_size;
+	sum = 1 - skb_shinfo(skb)->gso_size;
 
-	/* Add size of frags 1 through 5 to create our initial sum */
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
+	/* Add size of frags 0 through 4 to create our initial sum */
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
 
 	/* Walk through fragments adding latest fragment, testing it, and
 	 * then removing stale fragments from the sum.
 	 */
 	stale = &skb_shinfo(skb)->frags[0];
 	for (;;) {
-		sum += skb_frag_size(++frag);
+		sum += skb_frag_size(frag++);
 
 		/* if sum is negative we failed to make sufficient progress */
 		if (sum < 0)
@@ -2658,7 +2657,7 @@ bool __i40e_chk_linearize(struct sk_buff *skb)
 		if (!--nr_frags)
 			break;
 
-		sum -= skb_frag_size(++stale);
+		sum -= skb_frag_size(stale++);
 	}
 
 	return false;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 681e9bca37db..c864932bd844 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -442,10 +442,14 @@ static inline int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
  **/
 static inline bool i40e_chk_linearize(struct sk_buff *skb, int count)
 {
-	/* we can only support up to 8 data buffers for a single send */
-	if (likely(count <= I40E_MAX_BUFFER_TXD))
+	/* Both TSO and single send will work if count is less than 8 */
+	if (likely(count < I40E_MAX_BUFFER_TXD))
 		return false;
 
-	return __i40e_chk_linearize(skb);
+	if (skb_is_gso(skb))
+		return __i40e_chk_linearize(skb);
+
+	/* we can support up to 8 data buffers for a single send */
+	return count != I40E_MAX_BUFFER_TXD;
 }
 #endif /* _I40E_TXRX_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 04aabc52ba0d..519256bb63e8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1799,35 +1799,34 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 }
 
 /**
- * __i40evf_chk_linearize - Check if there are more than 8 fragments per packet
+ * __i40evf_chk_linearize - Check if there are more than 8 buffers per packet
  * @skb:      send buffer
  *
- * Note: Our HW can't scatter-gather more than 8 fragments to build
- * a packet on the wire and so we need to figure out the cases where we
- * need to linearize the skb.
+ * Note: Our HW can't DMA more than 8 buffers to build a packet on the wire
+ * and so we need to figure out the cases where we need to linearize the skb.
+ *
+ * For TSO we need to count the TSO header and segment payload separately.
+ * As such we need to check cases where we have 7 fragments or more as we
+ * can potentially require 9 DMA transactions, 1 for the TSO header, 1 for
+ * the segment payload in the first descriptor, and another 7 for the
+ * fragments.
  **/
 bool __i40evf_chk_linearize(struct sk_buff *skb)
 {
 	const struct skb_frag_struct *frag, *stale;
-	int gso_size, nr_frags, sum;
-
-	/* check to see if TSO is enabled, if so we may get a repreive */
-	gso_size = skb_shinfo(skb)->gso_size;
-	if (unlikely(!gso_size))
-		return true;
+	int nr_frags, sum;
 
-	/* no need to check if number of frags is less than 8 */
+	/* no need to check if number of frags is less than 7 */
 	nr_frags = skb_shinfo(skb)->nr_frags;
-	if (nr_frags < I40E_MAX_BUFFER_TXD)
+	if (nr_frags < (I40E_MAX_BUFFER_TXD - 1))
 		return false;
 
 	/* We need to walk through the list and validate that each group
 	 * of 6 fragments totals at least gso_size.  However we don't need
-	 * to perform such validation on the first or last 6 since the first
-	 * 6 cannot inherit any data from a descriptor before them, and the
-	 * last 6 cannot inherit any data from a descriptor after them.
+	 * to perform such validation on the last 6 since the last 6 cannot
+	 * inherit any data from a descriptor after them.
 	 */
-	nr_frags -= I40E_MAX_BUFFER_TXD - 1;
+	nr_frags -= I40E_MAX_BUFFER_TXD - 2;
 	frag = &skb_shinfo(skb)->frags[0];
 
 	/* Initialize size to the negative value of gso_size minus 1.  We
@@ -1836,21 +1835,21 @@ bool __i40evf_chk_linearize(struct sk_buff *skb)
 	 * descriptors for a single transmit as the header and previous
 	 * fragment are already consuming 2 descriptors.
 	 */
-	sum = 1 - gso_size;
+	sum = 1 - skb_shinfo(skb)->gso_size;
 
-	/* Add size of frags 1 through 5 to create our initial sum */
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
-	sum += skb_frag_size(++frag);
+	/* Add size of frags 0 through 4 to create our initial sum */
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
+	sum += skb_frag_size(frag++);
 
 	/* Walk through fragments adding latest fragment, testing it, and
 	 * then removing stale fragments from the sum.
 	 */
 	stale = &skb_shinfo(skb)->frags[0];
 	for (;;) {
-		sum += skb_frag_size(++frag);
+		sum += skb_frag_size(frag++);
 
 		/* if sum is negative we failed to make sufficient progress */
 		if (sum < 0)
@@ -1860,7 +1859,7 @@ bool __i40evf_chk_linearize(struct sk_buff *skb)
 		if (!--nr_frags)
 			break;
 
-		sum -= skb_frag_size(++stale);
+		sum -= skb_frag_size(stale++);
 	}
 
 	return false;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 6cf116972f62..396c3893ce8a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -424,10 +424,14 @@ static inline int i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
  **/
 static inline bool i40e_chk_linearize(struct sk_buff *skb, int count)
 {
-	/* we can only support up to 8 data buffers for a single send */
-	if (likely(count <= I40E_MAX_BUFFER_TXD))
+	/* Both TSO and single send will work if count is less than 8 */
+	if (likely(count < I40E_MAX_BUFFER_TXD))
 		return false;
 
-	return __i40evf_chk_linearize(skb);
+	if (skb_is_gso(skb))
+		return __i40evf_chk_linearize(skb);
+
+	/* we can support up to 8 data buffers for a single send */
+	return count != I40E_MAX_BUFFER_TXD;
 }
 #endif /* _I40E_TXRX_H_ */
