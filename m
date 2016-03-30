From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Tue, 29 Mar 2016 23:44:35 -0700
Message-ID: <20160330064213.12927.46852.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jesse.brandeburg@intel.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32797 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbcC3Goi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 02:44:38 -0400
Received: by mail-pa0-f50.google.com with SMTP id zm5so32937995pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 23:44:37 -0700 (PDT)
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

This patch has been sanity checked only.  I cannot yet guarantee it
resolves the original issue that was reported.  I'll try to get a
reproduction environment setup tomorrow but I don't know how long that
should take.

 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |   40 ++++++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |   40 ++++++++++++++-----------
 2 files changed, 44 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5d5fa5359a1d..97437f04d99d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2597,12 +2597,17 @@ int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
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
@@ -2614,18 +2619,17 @@ bool __i40e_chk_linearize(struct sk_buff *skb)
 	if (unlikely(!gso_size))
 		return true;
 
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
@@ -2636,19 +2640,19 @@ bool __i40e_chk_linearize(struct sk_buff *skb)
 	 */
 	sum = 1 - gso_size;
 
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
@@ -2658,7 +2662,7 @@ bool __i40e_chk_linearize(struct sk_buff *skb)
 		if (!--nr_frags)
 			break;
 
-		sum -= skb_frag_size(++stale);
+		sum -= skb_frag_size(stale++);
 	}
 
 	return false;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 04aabc52ba0d..240e4a1b2507 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1799,12 +1799,17 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
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
@@ -1816,18 +1821,17 @@ bool __i40evf_chk_linearize(struct sk_buff *skb)
 	if (unlikely(!gso_size))
 		return true;
 
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
@@ -1838,19 +1842,19 @@ bool __i40evf_chk_linearize(struct sk_buff *skb)
 	 */
 	sum = 1 - gso_size;
 
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
@@ -1860,7 +1864,7 @@ bool __i40evf_chk_linearize(struct sk_buff *skb)
 		if (!--nr_frags)
 			break;
 
-		sum -= skb_frag_size(++stale);
+		sum -= skb_frag_size(stale++);
 	}
 
 	return false;
