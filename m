From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e/i40evf: avoid dynamic ITR updates when polling or low packet rate
Date: Sun, 27 Aug 2017 17:16:03 -0700
Message-ID: <20170828001603.75876-16-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36375 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751613AbdH1AQW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:22 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The dynamic ITR algorithm depends on a calculation of usecs which
assumes that the interrupts have been firing constantly at the interrupt
throttle rate. This is not guaranteed because we could have a low packet
rate, or have been polling in software.

We'll estimate whether this is the case by using jiffies to determine if
we've been too long. If the time difference of jiffies is larger we are
guaranteed to have an incorrect calculation. If the time difference of
jiffies is smaller we might have been polling some but the difference
shouldn't affect the calculation too much.

This ensures that we don't get stuck in BULK latency during certain rare
situations where we receive bursts of packets that force us into NAPI
polling.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 22 +++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 22 +++++++++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  1 +
 4 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f00f233092e9..1519dfb851d0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -961,11 +961,25 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
-	int usecs;
+	unsigned int usecs, estimated_usecs;
 
 	if (rc->total_packets == 0 || !rc->itr)
 		return false;
 
+	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
+	bytes_per_int = rc->total_bytes / usecs;
+
+	/* The calculations in this algorithm depend on interrupts actually
+	 * firing at the ITR rate. This may not happen if the packet rate is
+	 * really low, or if we've been napi polling. Check to make sure
+	 * that's not the case before we continue.
+	 */
+	estimated_usecs = jiffies_to_usecs(jiffies - rc->last_itr_update);
+	if (estimated_usecs > usecs) {
+		new_latency_range = I40E_LOW_LATENCY;
+		goto reset_latency;
+	}
+
 	/* simple throttlerate management
 	 *   0-10MB/s   lowest (50000 ints/s)
 	 *  10-20MB/s   low    (20000 ints/s)
@@ -977,9 +991,6 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 * are in 2 usec increments in the ITR registers, and make sure
 	 * to use the smoothed values that the countdown timer gives us.
 	 */
-	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
-	bytes_per_int = rc->total_bytes / usecs;
-
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
@@ -998,6 +1009,7 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	}
 
+reset_latency:
 	rc->latency_range = new_latency_range;
 
 	switch (new_latency_range) {
@@ -1016,12 +1028,12 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 
 	rc->total_bytes = 0;
 	rc->total_packets = 0;
+	rc->last_itr_update = jiffies;
 
 	if (new_itr != rc->itr) {
 		rc->itr = new_itr;
 		return true;
 	}
-
 	return false;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index e6456e8a899c..2f848bc5e391 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -461,6 +461,7 @@ struct i40e_ring_container {
 	struct i40e_ring *ring;
 	unsigned int total_bytes;	/* total bytes processed this int */
 	unsigned int total_packets;	/* total packets processed this int */
+	unsigned long last_itr_update;	/* jiffies of last ITR update */
 	u16 count;
 	enum i40e_latency_range latency_range;
 	u16 itr;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 2f7d9f4a6746..c32c62462c84 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -359,11 +359,25 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
-	int usecs;
+	unsigned int usecs, estimated_usecs;
 
 	if (rc->total_packets == 0 || !rc->itr)
 		return false;
 
+	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
+	bytes_per_int = rc->total_bytes / usecs;
+
+	/* The calculations in this algorithm depend on interrupts actually
+	 * firing at the ITR rate. This may not happen if the packet rate is
+	 * really low, or if we've been napi polling. Check to make sure
+	 * that's not the case before we continue.
+	 */
+	estimated_usecs = jiffies_to_usecs(jiffies - rc->last_itr_update);
+	if (estimated_usecs > usecs) {
+		new_latency_range = I40E_LOW_LATENCY;
+		goto reset_latency;
+	}
+
 	/* simple throttlerate management
 	 *   0-10MB/s   lowest (50000 ints/s)
 	 *  10-20MB/s   low    (20000 ints/s)
@@ -375,9 +389,6 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 * are in 2 usec increments in the ITR registers, and make sure
 	 * to use the smoothed values that the countdown timer gives us.
 	 */
-	usecs = (rc->itr << 1) * ITR_COUNTDOWN_START;
-	bytes_per_int = rc->total_bytes / usecs;
-
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
@@ -396,6 +407,7 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 		break;
 	}
 
+reset_latency:
 	rc->latency_range = new_latency_range;
 
 	switch (new_latency_range) {
@@ -414,12 +426,12 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 
 	rc->total_bytes = 0;
 	rc->total_packets = 0;
+	rc->last_itr_update = jiffies;
 
 	if (new_itr != rc->itr) {
 		rc->itr = new_itr;
 		return true;
 	}
-
 	return false;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index fb506c9f5a6e..0d9f98bc07bd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -432,6 +432,7 @@ struct i40e_ring_container {
 	struct i40e_ring *ring;
 	unsigned int total_bytes;	/* total bytes processed this int */
 	unsigned int total_packets;	/* total packets processed this int */
+	unsigned long last_itr_update;	/* jiffies of last ITR update */
 	u16 count;
 	enum i40e_latency_range latency_range;
 	u16 itr;
-- 
2.14.1
