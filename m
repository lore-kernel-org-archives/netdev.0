From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] i40e: Fix RSS to not be limited by the number of CPUs
Date: Tue, 28 Jun 2016 21:40:56 -0700
Message-ID: <1467175262-54719-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266AbcF2EnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:18 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Limiting qcount to pf->num_lan_msix, effectively limits the RSS queues
to only use the number of CPUs, and ignore all other queues. We don't
want to do this. If the user has changed the RSS settings to use more
queues then CPUS, we want to trust they know what they are doing and
let them. More importantly, if we tell them that is what we did, we want
to actually do it and allow traffic into all of the queues we have
allocated. This does not change the default setting to initially
allocate only the number of CPUS of queue pairs.

Change-ID: Ie941a96e806e4bcd016addb4e17affb46770ada5
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 52d9d28..a32be7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1579,14 +1579,8 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 	vsi->tc_config.numtc = numtc;
 	vsi->tc_config.enabled_tc = enabled_tc ? enabled_tc : 1;
 	/* Number of queues per enabled TC */
-	/* In MFP case we can have a much lower count of MSIx
-	 * vectors available and so we need to lower the used
-	 * q count.
-	 */
-	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
-		qcount = min_t(int, vsi->alloc_queue_pairs, pf->num_lan_msix);
-	else
-		qcount = vsi->alloc_queue_pairs;
+	qcount = vsi->alloc_queue_pairs;
+
 	num_tc_qps = qcount / numtc;
 	num_tc_qps = min_t(int, num_tc_qps, i40e_pf_get_max_q_per_tc(pf));
 
-- 
2.5.5
