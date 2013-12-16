From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/12] i40e: use same number of queues as CPUs
Date: Mon, 16 Dec 2013 01:38:52 -0800
Message-ID: <1387186738-13666-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10462 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953Ab3LPJjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:39:09 -0500
In-Reply-To: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The current driver default sets the number of transmit/receive
queue pairs based on the current node's CPU count.

A better method is to use the total number of CPUs in the system
to suggest the number of queue pairs, which aligns better with
the behavior of ixgbe, and also with the expectations of the
kernel XPS and other subsystems in the stack.

Change-Id: If3e20c7f100f13e51d69762594d948f247ffe0c8
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e8bb2bb..1295adb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5401,7 +5401,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 	/* The number of vectors we'll request will be comprised of:
 	 *   - Add 1 for "other" cause for Admin Queue events, etc.
 	 *   - The number of LAN queue pairs
-	 *        already adjusted for the NUMA node
+	 *        already adjusted for the number of cpus in the system
 	 *        assumes symmetric Tx/Rx pairing
 	 *   - The number of VMDq pairs
 	 * Once we count this up, try the request.
@@ -5728,8 +5728,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 				 pf->hw.func_caps.num_tx_qp);
 	if (pf->hw.func_caps.rss) {
 		pf->flags |= I40E_FLAG_RSS_ENABLED;
-		pf->rss_size = min_t(int, pf->rss_size_max,
-				     nr_cpus_node(numa_node_id()));
+		pf->rss_size = min_t(int, pf->rss_size_max, num_online_cpus());
 	} else {
 		pf->rss_size = 1;
 	}
@@ -7054,7 +7053,7 @@ static u16 i40e_set_rss_size(struct i40e_pf *pf, int queues_left)
 	int num_tc0;
 
 	num_tc0 = min_t(int, queues_left, pf->rss_size_max);
-	num_tc0 = min_t(int, num_tc0, nr_cpus_node(numa_node_id()));
+	num_tc0 = min_t(int, num_tc0, num_online_cpus());
 	num_tc0 = rounddown_pow_of_two(num_tc0);
 
 	return num_tc0;
-- 
1.8.3.1
