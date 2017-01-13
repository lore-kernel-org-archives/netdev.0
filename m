From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] i40e: Invoke softirqs after napi_reschedule
Date: Thu, 12 Jan 2017 17:04:14 -0800
Message-ID: <20170113010414.22708-1-bpoirier@suse.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33336 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdAMBFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:05:17 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so5665022pfg.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:05:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following message is logged from time to time when using i40e:
NOHZ: local_softirq_pending 08

i40e may schedule napi from a workqueue. Afterwards, softirqs are not run
in a deterministic time frame. The problem is the same as what was
described in commit ec13ee80145c ("virtio_net: invoke softirqs after
__napi_schedule") and this patch applies the same fix to i40e.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ad4cf63..d65488c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4621,8 +4621,10 @@ static void i40e_detect_recover_hung_queue(int q_idx, struct i40e_vsi *vsi)
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
2.10.2
