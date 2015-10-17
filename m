From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e/i40evf: change dynamic interrupt thresholds
Date: Fri, 16 Oct 2015 22:28:22 -0700
Message-ID: <1445059711-45992-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18468 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109AbbJQF2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:45 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The dynamic algorithm, while now working, doesn't have good
performance in 40G mode.

One part of this patch addresses the high CPU utilization of some small
streaming workloads that the driver should reduce CPU in.

It also changes the minimum ITR that the dynamic algorithm
will settle on, causing our minimum latency to go from 12us
to about 14us, when using adaptive mode.

It also changes the BULK interrupt rate to allow maximum throughput
on a 40Gb connection with a single thread of transmit, clamping
interrupt rate to 8000 for TX makes single thread traffic go too
slow.

The new ULTRA bulk setting is introduced and is used
when the Rx packet rate on this queue exceeds 40000 packets per
second.  This value of 40000 was chosen because the automatic tuning
of minimum ITR=20us means that a single queue can't quite achieve
that many packets per second from a round-robin test.

Change-ID: Icce8faa128688ca5fd2c4229bdd9726877a92ea2
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 27 +++++++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  3 +++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 27 +++++++++++++++++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  3 +++
 4 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c96e581..7aea143 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -828,6 +828,7 @@ void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 {
 	enum i40e_latency_range new_latency_range = rc->latency_range;
+	struct i40e_q_vector *qv = rc->ring->q_vector;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
 	int usecs;
@@ -836,9 +837,10 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		return false;
 
 	/* simple throttlerate management
-	 *   0-10MB/s   lowest (100000 ints/s)
+	 *   0-10MB/s   lowest (50000 ints/s)
 	 *  10-20MB/s   low    (20000 ints/s)
-	 *  20-1249MB/s bulk   (8000 ints/s)
+	 *  20-1249MB/s bulk   (18000 ints/s)
+	 *  > 40000 Rx packets per second (8000 ints/s)
 	 *
 	 * The math works out because the divisor is in 10^(-6) which
 	 * turns the bytes/us input value into MB/s values, but
@@ -859,24 +861,37 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 			new_latency_range = I40E_LOWEST_LATENCY;
 		break;
 	case I40E_BULK_LATENCY:
-		if (bytes_per_int <= 20)
-			new_latency_range = I40E_LOW_LATENCY;
-		break;
+	case I40E_ULTRA_LATENCY:
 	default:
 		if (bytes_per_int <= 20)
 			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	}
+
+	/* this is to adjust RX more aggressively when streaming small
+	 * packets.  The value of 40000 was picked as it is just beyond
+	 * what the hardware can receive per second if in low latency
+	 * mode.
+	 */
+#define RX_ULTRA_PACKET_RATE 40000
+
+	if ((((rc->total_packets * 1000000) / usecs) > RX_ULTRA_PACKET_RATE) &&
+	    (&qv->rx == rc))
+		new_latency_range = I40E_ULTRA_LATENCY;
+
 	rc->latency_range = new_latency_range;
 
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
-		new_itr = I40E_ITR_100K;
+		new_itr = I40E_ITR_50K;
 		break;
 	case I40E_LOW_LATENCY:
 		new_itr = I40E_ITR_20K;
 		break;
 	case I40E_BULK_LATENCY:
+		new_itr = I40E_ITR_18K;
+		break;
+	case I40E_ULTRA_LATENCY:
 		new_itr = I40E_ITR_8K;
 		break;
 	default:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 7c0ed84..0fe7eb7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -32,7 +32,9 @@
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
 #define I40E_MIN_ITR               0x0001  /* reg uses 2 usec resolution */
 #define I40E_ITR_100K              0x0005
+#define I40E_ITR_50K               0x000A
 #define I40E_ITR_20K               0x0019
+#define I40E_ITR_18K               0x001B
 #define I40E_ITR_8K                0x003E
 #define I40E_ITR_4K                0x007A
 #define I40E_MAX_INTRL             0x3B    /* reg uses 4 usec resolution */
@@ -296,6 +298,7 @@ enum i40e_latency_range {
 	I40E_LOWEST_LATENCY = 0,
 	I40E_LOW_LATENCY = 1,
 	I40E_BULK_LATENCY = 2,
+	I40E_ULTRA_LATENCY = 3,
 };
 
 struct i40e_ring_container {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7d98042..d76fe4a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -331,6 +331,7 @@ static void i40evf_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector
 static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 {
 	enum i40e_latency_range new_latency_range = rc->latency_range;
+	struct i40e_q_vector *qv = rc->ring->q_vector;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
 	int usecs;
@@ -339,9 +340,10 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		return false;
 
 	/* simple throttlerate management
-	 *   0-10MB/s   lowest (100000 ints/s)
+	 *   0-10MB/s   lowest (50000 ints/s)
 	 *  10-20MB/s   low    (20000 ints/s)
-	 *  20-1249MB/s bulk   (8000 ints/s)
+	 *  20-1249MB/s bulk   (18000 ints/s)
+	 *  > 40000 Rx packets per second (8000 ints/s)
 	 *
 	 * The math works out because the divisor is in 10^(-6) which
 	 * turns the bytes/us input value into MB/s values, but
@@ -362,24 +364,37 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 			new_latency_range = I40E_LOWEST_LATENCY;
 		break;
 	case I40E_BULK_LATENCY:
-		if (bytes_per_int <= 20)
-			new_latency_range = I40E_LOW_LATENCY;
-		break;
+	case I40E_ULTRA_LATENCY:
 	default:
 		if (bytes_per_int <= 20)
 			new_latency_range = I40E_LOW_LATENCY;
 		break;
 	}
+
+	/* this is to adjust RX more aggressively when streaming small
+	 * packets.  The value of 40000 was picked as it is just beyond
+	 * what the hardware can receive per second if in low latency
+	 * mode.
+	 */
+#define RX_ULTRA_PACKET_RATE 40000
+
+	if ((((rc->total_packets * 1000000) / usecs) > RX_ULTRA_PACKET_RATE) &&
+	    (&qv->rx == rc))
+		new_latency_range = I40E_ULTRA_LATENCY;
+
 	rc->latency_range = new_latency_range;
 
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
-		new_itr = I40E_ITR_100K;
+		new_itr = I40E_ITR_50K;
 		break;
 	case I40E_LOW_LATENCY:
 		new_itr = I40E_ITR_20K;
 		break;
 	case I40E_BULK_LATENCY:
+		new_itr = I40E_ITR_18K;
+		break;
+	case I40E_ULTRA_LATENCY:
 		new_itr = I40E_ITR_8K;
 		break;
 	default:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 03275eb..e2352b8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -32,7 +32,9 @@
 #define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
 #define I40E_MIN_ITR               0x0001  /* reg uses 2 usec resolution */
 #define I40E_ITR_100K              0x0005
+#define I40E_ITR_50K               0x000A
 #define I40E_ITR_20K               0x0019
+#define I40E_ITR_18K               0x001B
 #define I40E_ITR_8K                0x003E
 #define I40E_ITR_4K                0x007A
 #define I40E_MAX_INTRL             0x3B    /* reg uses 4 usec resolution */
@@ -291,6 +293,7 @@ enum i40e_latency_range {
 	I40E_LOWEST_LATENCY = 0,
 	I40E_LOW_LATENCY = 1,
 	I40E_BULK_LATENCY = 2,
+	I40E_ULTRA_LATENCY = 3,
 };
 
 struct i40e_ring_container {
-- 
2.4.3
