From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 13/13] i40evf: program RSS LUT correctly
Date: Fri, 11 Apr 2014 06:53:03 -0700
Message-ID: <1397224383-19269-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47069 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758773AbaDKNxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:14 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

A recent change broke the RSS LUT programming, causing it to be
programmed with all 0. Correct this by actually assigning the
incremented value back to the counter variable so that the increment
will be remembered by the calling function.

While we're at it, add a proper kernel-doc function comment to our
helper function.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e35e66f..2797548 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1412,6 +1412,14 @@ restart_watchdog:
 	schedule_work(&adapter->adminq_task);
 }
 
+/**
+ * i40evf_configure_rss - increment to next available tx queue
+ * @adapter: board private structure
+ * @j: queue counter
+ *
+ * Helper function for RSS programming to increment through available
+ * queus. Returns the next queue value.
+ **/
 static int next_queue(struct i40evf_adapter *adapter, int j)
 {
 	j += 1;
@@ -1451,10 +1459,14 @@ static void i40evf_configure_rss(struct i40evf_adapter *adapter)
 	/* Populate the LUT with max no. of queues in round robin fashion */
 	j = adapter->vsi_res->num_queue_pairs;
 	for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
-		lut = next_queue(adapter, j);
-		lut |= next_queue(adapter, j) << 8;
-		lut |= next_queue(adapter, j) << 16;
-		lut |= next_queue(adapter, j) << 24;
+		j = next_queue(adapter, j);
+		lut = j;
+		j = next_queue(adapter, j);
+		lut |= j << 8;
+		j = next_queue(adapter, j);
+		lut |= j << 16;
+		j = next_queue(adapter, j);
+		lut |= j << 24;
 		wr32(hw, I40E_VFQF_HLUT(i), lut);
 	}
 	i40e_flush(hw);
-- 
1.9.0
