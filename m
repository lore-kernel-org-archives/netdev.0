From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: Reprogram port offloads after reset
Date: Sun, 30 Apr 2017 06:24:42 -0700
Message-ID: <20170430132451.68494-5-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15380 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163500AbdD3NY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:57 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch corrects a major oversight in that we were not reprogramming the
ports after a reset.  As a result we completely lost all of the Rx tunnel
offloads on receive including Rx checksum, RSS on inner headers, and ATR.

The fix for this is pretty standard as all we needed to do is reset the
filter bits to pending for all active filters and schedule the sync event.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 063044268170..f44affc7e08c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7331,6 +7331,23 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_sync_udp_filters - Trigger a sync event for existing UDP filters
+ * @pf: board private structure
+ **/
+static void i40e_sync_udp_filters(struct i40e_pf *pf)
+{
+	int i;
+
+	/* loop through and set pending bit for all active UDP filters */
+	for (i = 0; i < I40E_MAX_PF_UDP_OFFLOAD_PORTS; i++) {
+		if (pf->udp_ports[i].port)
+			pf->pending_udp_bitmap |= BIT_ULL(i);
+	}
+
+	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
+}
+
+/**
  * i40e_sync_udp_filters_subtask - Sync the VSI filter list with HW
  * @pf: board private structure
  **/
@@ -10738,6 +10755,9 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 
 	i40e_ptp_init(pf);
 
+	/* repopulate tunnel port filters */
+	i40e_sync_udp_filters(pf);
+
 	return ret;
 }
 
-- 
2.12.2
