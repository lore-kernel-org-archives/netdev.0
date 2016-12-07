From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/20] i40e: simplify txd use count calculation
Date: Tue,  6 Dec 2016 23:33:36 -0800
Message-ID: <20161207073354.88568-3-jeffrey.t.kirsher@intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26483 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752784AbcLGHer (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 02:34:47 -0500
In-Reply-To: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The i40e_txd_use_count function was fast but confusing. In the comments,
it even admits that it's ugly. So replace it with a new function that is
(very) slightly faster and has extensive commenting to help the thicker
among us (including the author, who will forget in a week) understand
how it works.

Change-ID: Ifb533f13786a0bf39cb29f77969a5be2c83d9a87
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 45 +++++++++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 45 +++++++++++++++++----------
 2 files changed, 56 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index de8550f..e065321 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -173,26 +173,37 @@ static inline bool i40e_test_staterr(union i40e_rx_desc *rx_desc,
 #define I40E_MAX_DATA_PER_TXD_ALIGNED \
 	(I40E_MAX_DATA_PER_TXD & ~(I40E_MAX_READ_REQ_SIZE - 1))
 
-/* This ugly bit of math is equivalent to DIV_ROUNDUP(size, X) where X is
- * the value I40E_MAX_DATA_PER_TXD_ALIGNED.  It is needed due to the fact
- * that 12K is not a power of 2 and division is expensive.  It is used to
- * approximate the number of descriptors used per linear buffer.  Note
- * that this will overestimate in some cases as it doesn't account for the
- * fact that we will add up to 4K - 1 in aligning the 12K buffer, however
- * the error should not impact things much as large buffers usually mean
- * we will use fewer descriptors then there are frags in an skb.
+/**
+ * i40e_txd_use_count  - estimate the number of descriptors needed for Tx
+ * @size: transmit request size in bytes
+ *
+ * Due to hardware alignment restrictions (4K alignment), we need to
+ * assume that we can have no more than 12K of data per descriptor, even
+ * though each descriptor can take up to 16K - 1 bytes of aligned memory.
+ * Thus, we need to divide by 12K. But division is slow! Instead,
+ * we decompose the operation into shifts and one relatively cheap
+ * multiply operation.
+ *
+ * To divide by 12K, we first divide by 4K, then divide by 3:
+ *     To divide by 4K, shift right by 12 bits
+ *     To divide by 3, multiply by 85, then divide by 256
+ *     (Divide by 256 is done by shifting right by 8 bits)
+ * Finally, we add one to round up. Because 256 isn't an exact multiple of
+ * 3, we'll underestimate near each multiple of 12K. This is actually more
+ * accurate as we have 4K - 1 of wiggle room that we can fit into the last
+ * segment.  For our purposes this is accurate out to 1M which is orders of
+ * magnitude greater than our largest possible GSO size.
+ *
+ * This would then be implemented as:
+ *     return (((size >> 12) * 85) >> 8) + 1;
+ *
+ * Since multiplication and division are commutative, we can reorder
+ * operations into:
+ *     return ((size * 85) >> 20) + 1;
  */
 static inline unsigned int i40e_txd_use_count(unsigned int size)
 {
-	const unsigned int max = I40E_MAX_DATA_PER_TXD_ALIGNED;
-	const unsigned int reciprocal = ((1ull << 32) - 1 + (max / 2)) / max;
-	unsigned int adjust = ~(u32)0;
-
-	/* if we rounded up on the reciprocal pull down the adjustment */
-	if ((max * reciprocal) > adjust)
-		adjust = ~(u32)(reciprocal - 1);
-
-	return (u32)((((u64)size * reciprocal) + adjust) >> 32);
+	return ((size * 85) >> 20) + 1;
 }
 
 /* Tx Descriptors needed, worst case */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index a586e19..a5fc789 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -173,26 +173,37 @@ static inline bool i40e_test_staterr(union i40e_rx_desc *rx_desc,
 #define I40E_MAX_DATA_PER_TXD_ALIGNED \
 	(I40E_MAX_DATA_PER_TXD & ~(I40E_MAX_READ_REQ_SIZE - 1))
 
-/* This ugly bit of math is equivalent to DIV_ROUNDUP(size, X) where X is
- * the value I40E_MAX_DATA_PER_TXD_ALIGNED.  It is needed due to the fact
- * that 12K is not a power of 2 and division is expensive.  It is used to
- * approximate the number of descriptors used per linear buffer.  Note
- * that this will overestimate in some cases as it doesn't account for the
- * fact that we will add up to 4K - 1 in aligning the 12K buffer, however
- * the error should not impact things much as large buffers usually mean
- * we will use fewer descriptors then there are frags in an skb.
+/**
+ * i40e_txd_use_count  - estimate the number of descriptors needed for Tx
+ * @size: transmit request size in bytes
+ *
+ * Due to hardware alignment restrictions (4K alignment), we need to
+ * assume that we can have no more than 12K of data per descriptor, even
+ * though each descriptor can take up to 16K - 1 bytes of aligned memory.
+ * Thus, we need to divide by 12K. But division is slow! Instead,
+ * we decompose the operation into shifts and one relatively cheap
+ * multiply operation.
+ *
+ * To divide by 12K, we first divide by 4K, then divide by 3:
+ *     To divide by 4K, shift right by 12 bits
+ *     To divide by 3, multiply by 85, then divide by 256
+ *     (Divide by 256 is done by shifting right by 8 bits)
+ * Finally, we add one to round up. Because 256 isn't an exact multiple of
+ * 3, we'll underestimate near each multiple of 12K. This is actually more
+ * accurate as we have 4K - 1 of wiggle room that we can fit into the last
+ * segment.  For our purposes this is accurate out to 1M which is orders of
+ * magnitude greater than our largest possible GSO size.
+ *
+ * This would then be implemented as:
+ *     return (((size >> 12) * 85) >> 8) + 1;
+ *
+ * Since multiplication and division are commutative, we can reorder
+ * operations into:
+ *     return ((size * 85) >> 20) + 1;
  */
 static inline unsigned int i40e_txd_use_count(unsigned int size)
 {
-	const unsigned int max = I40E_MAX_DATA_PER_TXD_ALIGNED;
-	const unsigned int reciprocal = ((1ull << 32) - 1 + (max / 2)) / max;
-	unsigned int adjust = ~(u32)0;
-
-	/* if we rounded up on the reciprocal pull down the adjustment */
-	if ((max * reciprocal) > adjust)
-		adjust = ~(u32)(reciprocal - 1);
-
-	return (u32)((((u64)size * reciprocal) + adjust) >> 32);
+	return ((size * 85) >> 20) + 1;
 }
 
 /* Tx Descriptors needed, worst case */
-- 
2.9.3
