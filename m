From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40e: Invoke softirqs after napi_reschedule
Date: Sat, 18 Feb 2017 22:33:41 -0800
Message-ID: <20170219063341.8039-14-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39180 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751216AbdBSGeO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:14 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

The following message is logged from time to time when using i40e:
NOHZ: local_softirq_pending 08

i40e may schedule napi from a workqueue. Afterwards, softirqs are not run
in a deterministic time frame. The problem is the same as what was
described in commit ec13ee80145c ("virtio_net: invoke softirqs after
__napi_schedule") and this patch applies the same fix to i40e.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b0215c1159fe..e8a8351c8ea9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4685,8 +4685,10 @@ static void i40e_detect_recover_hung_queue(int q_idx, struct i40e_vsi *vsi)
 	 */
 	if ((!tx_pending_hw) && i40e_get_tx_pending(tx_ring, true) &&
 	    (!(val & I40E_PFINT_DYN_CTLN_INTENA_MASK))) {
+		local_bh_disable();
 		if (napi_reschedule(&tx_ring->q_vector->napi))
 			tx_ring->tx_stats.tx_lost_interrupt++;
+		local_bh_enable();
 	}
 }
 
-- 
2.11.0
