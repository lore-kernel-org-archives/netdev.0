From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 07/13] i40e: Fix the Tx ring qset handle when DCB reconfigures
Date: Thu, 26 Feb 2015 07:03:43 -0800
Message-ID: <1424963029-4612-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Parikh, Neerav" <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40565 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbbBZPD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:57 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Parikh, Neerav" <neerav.parikh@intel.com>

When DCB is reconfigured to single TC the driver did not reset the
Tx ring Qset handle to the correct mapping; which caused Tx queue
disable timeouts.

Change-ID: I4da5915ec92a83c281b478d653fae6ef1b72edfe
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a926e3b..bd4494d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2689,8 +2689,15 @@ static void i40e_vsi_config_dcb_rings(struct i40e_vsi *vsi)
 	u16 qoffset, qcount;
 	int i, n;
 
-	if (!(vsi->back->flags & I40E_FLAG_DCB_ENABLED))
-		return;
+	if (!(vsi->back->flags & I40E_FLAG_DCB_ENABLED)) {
+		/* Reset the TC information */
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			rx_ring = vsi->rx_rings[i];
+			tx_ring = vsi->tx_rings[i];
+			rx_ring->dcb_tc = 0;
+			tx_ring->dcb_tc = 0;
+		}
+	}
 
 	for (n = 0; n < I40E_MAX_TRAFFIC_CLASS; n++) {
 		if (!(vsi->tc_config.enabled_tc & (1 << n)))
-- 
1.9.3
