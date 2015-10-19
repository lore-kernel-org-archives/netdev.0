From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/17] i40e/i40evf: fix bug in throttle rate math
Date: Mon, 19 Oct 2015 15:49:21 -0700
Message-ID: <1445294971-44714-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbbJSWtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:36 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was using a value expressed in 2us increments
for the divisor to figure out our bytes/usec values.

Fix the usecs variable to contain a value in microseconds.

Change-ID: I5c20493103c295d6f201947bb908add7040b7c41
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 9 ++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 9 ++++++++-
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 889d25d..c96e581 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -830,6 +830,7 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
+	int usecs;
 
 	if (rc->total_packets == 0 || !rc->itr)
 		return false;
@@ -838,8 +839,14 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 *   0-10MB/s   lowest (100000 ints/s)
 	 *  10-20MB/s   low    (20000 ints/s)
 	 *  20-1249MB/s bulk   (8000 ints/s)
+	 *
+	 * The math works out because the divisor is in 10^(-6) which
+	 * turns the bytes/us input value into MB/s values, but
+	 * make sure to use usecs, as the register values written
+	 * are in 2 usec increments in the ITR registers.
 	 */
-	bytes_per_int = rc->total_bytes / rc->itr;
+	usecs = (rc->itr << 1);
+	bytes_per_int = rc->total_bytes / usecs;
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 597e096..7d98042 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -333,6 +333,7 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	enum i40e_latency_range new_latency_range = rc->latency_range;
 	u32 new_itr = rc->itr;
 	int bytes_per_int;
+	int usecs;
 
 	if (rc->total_packets == 0 || !rc->itr)
 		return false;
@@ -341,8 +342,14 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	 *   0-10MB/s   lowest (100000 ints/s)
 	 *  10-20MB/s   low    (20000 ints/s)
 	 *  20-1249MB/s bulk   (8000 ints/s)
+	 *
+	 * The math works out because the divisor is in 10^(-6) which
+	 * turns the bytes/us input value into MB/s values, but
+	 * make sure to use usecs, as the register values written
+	 * are in 2 usec increments in the ITR registers.
 	 */
-	bytes_per_int = rc->total_bytes / rc->itr;
+	usecs = (rc->itr << 1);
+	bytes_per_int = rc->total_bytes / usecs;
 	switch (new_latency_range) {
 	case I40E_LOWEST_LATENCY:
 		if (bytes_per_int > 10)
-- 
2.4.3
