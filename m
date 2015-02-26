From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 06/13] i40e: Fix the case where per TC queue count was higher than queues enabled
Date: Thu, 26 Feb 2015 07:03:42 -0800
Message-ID: <1424963029-4612-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40565 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684AbbBZPD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:56 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

When the driver or hardware gets less interrupt vectors than the actual
number of CPU cores, limit the queue count for the priority queue
traffic class (TC) queues.

This will fix a warning with multiple function mode where systems
regularly have more cores than vectors.

Also add extra comment for readability.

Change-ID: I4f02226263aa3995e1f5ee5503eac0cd6ee12fbd
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young  <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6bb6376..a926e3b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1512,7 +1512,12 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 	vsi->tc_config.numtc = numtc;
 	vsi->tc_config.enabled_tc = enabled_tc ? enabled_tc : 1;
 	/* Number of queues per enabled TC */
-	num_tc_qps = vsi->alloc_queue_pairs/numtc;
+	/* In MFP case we can have a much lower count of MSIx
+	 * vectors available and so we need to lower the used
+	 * q count.
+	 */
+	qcount = min_t(int, vsi->alloc_queue_pairs, pf->num_lan_msix);
+	num_tc_qps = qcount / numtc;
 	num_tc_qps = min_t(int, num_tc_qps, I40E_MAX_QUEUES_PER_TC);
 
 	/* Setup queue offset/count for all TCs for given VSI */
-- 
1.9.3
