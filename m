From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbe: Reorder the ring to q_vector mapping to improve performance
Date: Fri,  4 May 2012 03:35:12 -0700
Message-ID: <1336127716-20383-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7953 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755203Ab2EDKfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:35:21 -0400
In-Reply-To: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change reorders the mapping of rings to q_vectors in the case that the
number of rings exceeds the number of q_vectors.  Previously we would
allocate the first R/N queues to the first q_vector where R is the number
of rings and N is the number of q_vectors.  Instead of doing this we can do
a better job of interleaving the rings to the CPUs by assigning every Nth
ring to the q_vector.

The below tables illustrate this change for the R = 16 N = 4 case.
          Before patch  After patch
q_vector:  0  1  2  3    0  1  2  3
Rings:     0  4  8 12    0  1  2  3
           1  5  9 13    4  5  6  7
           3  6 10 14    8  9 10 11
           4  7 11 15   12 13 14 15

This should improve the performance for both DCB or ATR when the number of
rings exceeds the number of q_vectors allocated by the adapter.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |   35 ++++++++++++++-----------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index ed1b47d..af1a531 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -523,11 +523,17 @@ static void ixgbe_add_ring(struct ixgbe_ring *ring,
 /**
  * ixgbe_alloc_q_vector - Allocate memory for a single interrupt vector
  * @adapter: board private structure to initialize
+ * @v_count: q_vectors allocated on adapter, used for ring interleaving
  * @v_idx: index of vector in adapter struct
+ * @txr_count: total number of Tx rings to allocate
+ * @txr_idx: index of first Tx ring to allocate
+ * @rxr_count: total number of Rx rings to allocate
+ * @rxr_idx: index of first Rx ring to allocate
  *
  * We allocate one q_vector.  If allocation fails we return -ENOMEM.
  **/
-static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter, int v_idx,
+static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
+				int v_count, int v_idx,
 				int txr_count, int txr_idx,
 				int rxr_count, int rxr_idx)
 {
@@ -598,7 +604,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter, int v_idx,
 
 		/* update count and index */
 		txr_count--;
-		txr_idx++;
+		txr_idx += v_count;
 
 		/* push pointer to next ring */
 		ring++;
@@ -641,7 +647,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter, int v_idx,
 
 		/* update count and index */
 		rxr_count--;
-		rxr_idx++;
+		rxr_idx += v_count;
 
 		/* push pointer to next ring */
 		ring++;
@@ -700,24 +706,23 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		q_vectors = 1;
 
 	if (q_vectors >= (rxr_remaining + txr_remaining)) {
-		for (; rxr_remaining; v_idx++, q_vectors--) {
-			int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors);
-			err = ixgbe_alloc_q_vector(adapter, v_idx,
-						   0, 0, rqpv, rxr_idx);
+		for (; rxr_remaining; v_idx++) {
+			err = ixgbe_alloc_q_vector(adapter, q_vectors, v_idx,
+						   0, 0, 1, rxr_idx);
 
 			if (err)
 				goto err_out;
 
 			/* update counts and index */
-			rxr_remaining -= rqpv;
-			rxr_idx += rqpv;
+			rxr_remaining--;
+			rxr_idx++;
 		}
 	}
 
-	for (; q_vectors; v_idx++, q_vectors--) {
-		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors);
-		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors);
-		err = ixgbe_alloc_q_vector(adapter, v_idx,
+	for (; v_idx < q_vectors; v_idx++) {
+		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - v_idx);
+		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - v_idx);
+		err = ixgbe_alloc_q_vector(adapter, q_vectors, v_idx,
 					   tqpv, txr_idx,
 					   rqpv, rxr_idx);
 
@@ -726,9 +731,9 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 
 		/* update counts and index */
 		rxr_remaining -= rqpv;
-		rxr_idx += rqpv;
 		txr_remaining -= tqpv;
-		txr_idx += tqpv;
+		rxr_idx++;
+		txr_idx++;
 	}
 
 	return 0;
-- 
1.7.7.6
