From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [jkirsher/next-queue PATCH] ixgbe: Update adaptive ITR algorithm
Date: Mon, 25 Sep 2017 14:55:36 -0700
Message-ID: <20170925215225.15616.63705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:43314 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965180AbdIYVzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:55:39 -0400
Received: by mail-pg0-f52.google.com with SMTP id u18so4780287pgo.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 14:55:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The following change is meant to update the adaptive ITR algorithm to
better support the needs of the network. Specifically with this change what
I have done is make it so that our ITR algorithm will try to prevent either
starving a socket buffer for memory in the case of Tx, or overruing an Rx
socket buffer on receive.

In addition a side effect of the calculations used is that we should
function better with new features such as XDP which can handle small
packets at high rates without needing to lock us into NAPI polling mode.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

So I am putting this out to a wider distribution list than normal for a
patch like this in order to get feedback on if there are any areas I may
have overlooked. With this patch is should address many of the performance
limitations seen with pktgen and XDP in terms of workloads that the old
adaptive scheme wasn't handling.

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    7 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   11 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  215 +++++++++++++++++++------
 3 files changed, 178 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 56039d04b38d..555eb80d8a08 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -435,8 +435,15 @@ static inline unsigned int ixgbe_rx_pg_order(struct ixgbe_ring *ring)
 }
 #define ixgbe_rx_pg_size(_ring) (PAGE_SIZE << ixgbe_rx_pg_order(_ring))
 
+#define IXGBE_ITR_ADAPTIVE_MIN_INC	2
+#define IXGBE_ITR_ADAPTIVE_MIN_USECS	10
+#define IXGBE_ITR_ADAPTIVE_MAX_USECS	126
+#define IXGBE_ITR_ADAPTIVE_LATENCY	0x80
+#define IXGBE_ITR_ADAPTIVE_BULK		0x00
+
 struct ixgbe_ring_container {
 	struct ixgbe_ring *ring;	/* pointer to linked list of rings */
+	unsigned long next_update;	/* jiffies value of last update */
 	unsigned int total_bytes;	/* total bytes processed this int */
 	unsigned int total_packets;	/* total packets processed this int */
 	u16 work_limit;			/* total work allowed per interrupt */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index f1bfae0c41d0..8e2a957aca18 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -806,6 +806,7 @@ static void ixgbe_add_ring(struct ixgbe_ring *ring,
 	ring->next = head->ring;
 	head->ring = ring;
 	head->count++;
+	head->next_update = jiffies + 1;
 }
 
 /**
@@ -879,8 +880,11 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	/* initialize work limits */
 	q_vector->tx.work_limit = adapter->tx_work_limit;
 
-	/* initialize pointer to rings */
-	ring = q_vector->ring;
+	/* Initialize setting for adaptive ITR */
+	q_vector->tx.itr = IXGBE_ITR_ADAPTIVE_MAX_USECS |
+			   IXGBE_ITR_ADAPTIVE_LATENCY;
+	q_vector->rx.itr = IXGBE_ITR_ADAPTIVE_MAX_USECS |
+			   IXGBE_ITR_ADAPTIVE_LATENCY;
 
 	/* intialize ITR */
 	if (txr_count && !rxr_count) {
@@ -897,6 +901,9 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 			q_vector->itr = adapter->rx_itr_setting;
 	}
 
+	/* initialize pointer to rings */
+	ring = q_vector->ring;
+
 	while (txr_count) {
 		/* assign generic ring traits */
 		ring->dev = &adapter->pdev->dev;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3d3739f103af..44a96878075b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2517,50 +2517,174 @@ enum latency_range {
 static void ixgbe_update_itr(struct ixgbe_q_vector *q_vector,
 			     struct ixgbe_ring_container *ring_container)
 {
-	int bytes = ring_container->total_bytes;
-	int packets = ring_container->total_packets;
-	u32 timepassed_us;
-	u64 bytes_perint;
-	u8 itr_setting = ring_container->itr;
+	unsigned int itr = IXGBE_ITR_ADAPTIVE_MIN_USECS |
+			   IXGBE_ITR_ADAPTIVE_LATENCY;
+	unsigned int avg_wire_size, packets, bytes;
+	unsigned long next_update = jiffies;
 
-	if (packets == 0)
+	/* If we don't have any rings just leave ourselves set for maximum
+	 * possible latency so we take ourselves out of the equation.
+	 */
+	if (!ring_container->ring)
 		return;
 
-	/* simple throttlerate management
-	 *   0-10MB/s   lowest (100000 ints/s)
-	 *  10-20MB/s   low    (20000 ints/s)
-	 *  20-1249MB/s bulk   (12000 ints/s)
+	/* If we didn't update within up to 1 - 2 jiffies we can assume
+	 * that either packets are coming in so slow there hasn't been
+	 * any work, or that there is so much work that NAPI is dealing
+	 * with interrupt moderation and we don't need to do anything.
 	 */
-	/* what was last interrupt timeslice? */
-	timepassed_us = q_vector->itr >> 2;
-	if (timepassed_us == 0)
-		return;
+	if (time_after(next_update, ring_container->next_update))
+		goto clear_counts;
 
-	bytes_perint = bytes / timepassed_us; /* bytes/usec */
+	packets = ring_container->total_packets;
 
-	switch (itr_setting) {
-	case lowest_latency:
-		if (bytes_perint > 10)
-			itr_setting = low_latency;
-		break;
-	case low_latency:
-		if (bytes_perint > 20)
-			itr_setting = bulk_latency;
-		else if (bytes_perint <= 10)
-			itr_setting = lowest_latency;
+	/* We have no packets to actually measure against. This means
+	 * either one of the other queues on this vector is active or
+	 * we are a Tx queue doing TSO with too high of an interrupt rate.
+	 *
+	 * When this occurs just tick up our delay by the minimum value
+	 * and hope that this extra delay will prevent us from being called
+	 * without any work on our queue.
+	 */
+	if (!packets) {
+		itr = (q_vector->itr >> 2) + IXGBE_ITR_ADAPTIVE_MIN_INC;
+		if (itr > IXGBE_ITR_ADAPTIVE_MAX_USECS)
+			itr = IXGBE_ITR_ADAPTIVE_MAX_USECS;
+		itr += ring_container->itr & IXGBE_ITR_ADAPTIVE_LATENCY;
+		goto clear_counts;
+	}
+
+	bytes = ring_container->total_bytes;
+
+	/* If packets are less than 4 or bytes are less than 9000 assume
+	 * insufficient data to use bulk rate limiting approach. We are
+	 * likely latency driven.
+	 */
+	if (packets < 4 && bytes < 9000) {
+		itr = IXGBE_ITR_ADAPTIVE_LATENCY;
+		goto adjust_by_size;
+	}
+
+	/* Between 4 and 48 we can assume that our current interrupt delay
+	 * is only slightly too low. As such we should increase it by a small
+	 * fixed amount.
+	 */
+	if (packets < 48) {
+		itr = (q_vector->itr >> 2) + IXGBE_ITR_ADAPTIVE_MIN_INC;
+		if (itr > IXGBE_ITR_ADAPTIVE_MAX_USECS)
+			itr = IXGBE_ITR_ADAPTIVE_MAX_USECS;
+		goto clear_counts;
+	}
+
+	/* Between 48 and 96 is our "goldilocks" zone where we are working
+	 * out "just right". Just report that our current ITR is good for us.
+	 */
+	if (packets < 96) {
+		itr = q_vector->itr >> 2;
+		goto clear_counts;
+	}
+
+	/* If packet count is 96 or greater we are likely looking at a slight
+	 * overrun of the delay we want. Try halving our delay to see if that
+	 * will cut the number of packets in half per interrupt.
+	 */
+	if (packets < 256) {
+		itr = q_vector->itr >> 3;
+		if (itr < IXGBE_ITR_ADAPTIVE_MIN_USECS)
+			itr = IXGBE_ITR_ADAPTIVE_MIN_USECS;
+		goto clear_counts;
+	}
+
+	/* The paths below assume we are dealing with a bulk ITR since number
+	 * of packets is 256 or greater. We are just going to have to compute
+	 * a value and try to bring the count under control, though for smaller
+	 * packet sizes there isn't much we can do as NAPI polling will likely
+	 * be kicking in sooner rather than later.
+	 */
+	itr = IXGBE_ITR_ADAPTIVE_BULK;
+
+adjust_by_size:
+	/* If packet counts are 256 or greater we can assume we have a gross
+	 * overestimation of what the rate should be. Instead of trying to fine
+	 * tune it just use the formula below to try and dial in an exact value
+	 * give the current packet size of the frame.
+	 */
+	avg_wire_size = bytes / packets;
+
+	/* The following is a crude approximation of:
+	 *  wmem_default / (size + overhead) = desired_pkts_per_int
+	 *  rate / bits_per_byte / (size + ethernet overhead) = pkt_rate
+	 *  (desired_pkt_rate / pkt_rate) * usecs_per_sec = ITR value
+	 *
+	 * Assuming wmem_default is 212992 and overhead is 640 bytes per
+	 * packet, (256 skb, 64 headroom, 320 shared info), we can reduce the
+	 * formula down to
+	 *
+	 *  (170 * (size + 24)) / (size + 640) = ITR
+	 *
+	 * We first do some math on the packet size and then finally bitshift
+	 * by 8 after rounding up. We also have to account for PCIe link speed
+	 * difference as ITR scales based on this.
+	 */
+	if (avg_wire_size <= 60) {
+		/* Start at 50k ints/sec */
+		avg_wire_size = 5120;
+	} else if (avg_wire_size <= 316) {
+		/* 50K ints/sec to 16K ints/sec */
+		avg_wire_size *= 40;
+		avg_wire_size += 2720;
+	} else if (avg_wire_size <= 1084) {
+		/* 16K ints/sec to 9.2K ints/sec */
+		avg_wire_size *= 15;
+		avg_wire_size += 11452;
+	} else if (avg_wire_size <= 1980) {
+		/* 9.2K ints/sec to 8K ints/sec */
+		avg_wire_size *= 5;
+		avg_wire_size += 22420;
+	} else {
+		/* plateau at a limit of 8K ints/sec */
+		avg_wire_size = 32256;
+	}
+
+	/* If we are in low latency mode half our delay which doubles the rate
+	 * to somewhere between 100K to 16K ints/sec
+	 */
+	if (itr & IXGBE_ITR_ADAPTIVE_LATENCY)
+		avg_wire_size >>= 1;
+
+	/* Resultant value is 256 times larger than it needs to be. This
+	 * gives us room to adjust the value as needed to either increase
+	 * or decrease the value based on link speeds of 10G, 2.5G, 1G, etc.
+	 *
+	 * Use addition as we have already recorded the new latency flag
+	 * for the ITR value.
+	 */
+	switch (q_vector->adapter->link_speed) {
+	case IXGBE_LINK_SPEED_10GB_FULL:
+	case IXGBE_LINK_SPEED_100_FULL:
+	default:
+		itr += DIV_ROUND_UP(avg_wire_size,
+				    IXGBE_ITR_ADAPTIVE_MIN_INC * 256) *
+		       IXGBE_ITR_ADAPTIVE_MIN_INC;
 		break;
-	case bulk_latency:
-		if (bytes_perint <= 20)
-			itr_setting = low_latency;
+	case IXGBE_LINK_SPEED_2_5GB_FULL:
+	case IXGBE_LINK_SPEED_1GB_FULL:
+	case IXGBE_LINK_SPEED_10_FULL:
+		itr += DIV_ROUND_UP(avg_wire_size,
+				    IXGBE_ITR_ADAPTIVE_MIN_INC * 64) *
+		       IXGBE_ITR_ADAPTIVE_MIN_INC;
 		break;
 	}
 
-	/* clear work counters since we have the values we need */
+clear_counts:
+	/* write back value */
+	ring_container->itr = itr;
+
+	/* next update should occur within next jiffy */
+	ring_container->next_update = next_update + 1;
+
 	ring_container->total_bytes = 0;
 	ring_container->total_packets = 0;
-
-	/* write updated itr to ring container */
-	ring_container->itr = itr_setting;
 }
 
 /**
@@ -2602,34 +2726,19 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 
 static void ixgbe_set_itr(struct ixgbe_q_vector *q_vector)
 {
-	u32 new_itr = q_vector->itr;
-	u8 current_itr;
+	u32 new_itr;
 
 	ixgbe_update_itr(q_vector, &q_vector->tx);
 	ixgbe_update_itr(q_vector, &q_vector->rx);
 
-	current_itr = max(q_vector->rx.itr, q_vector->tx.itr);
+	/* use the smallest value of new ITR delay calculations */
+	new_itr = min(q_vector->rx.itr, q_vector->tx.itr);
 
-	switch (current_itr) {
-	/* counts and packets in update_itr are dependent on these numbers */
-	case lowest_latency:
-		new_itr = IXGBE_100K_ITR;
-		break;
-	case low_latency:
-		new_itr = IXGBE_20K_ITR;
-		break;
-	case bulk_latency:
-		new_itr = IXGBE_12K_ITR;
-		break;
-	default:
-		break;
-	}
+	/* Clear latency flag if set, shift into correct position */
+	new_itr &= ~IXGBE_ITR_ADAPTIVE_LATENCY;
+	new_itr <<= 2;
 
 	if (new_itr != q_vector->itr) {
-		/* do an exponential smoothing */
-		new_itr = (10 * new_itr * q_vector->itr) /
-			  ((9 * new_itr) + q_vector->itr);
-
 		/* save the algorithm value here */
 		q_vector->itr = new_itr;
 
