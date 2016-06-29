From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] i40e: Add a call to set the client interface down
Date: Tue, 28 Jun 2016 21:40:50 -0700
Message-ID: <1467175262-54719-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbcF2EnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:17 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We were failing to set the client interface down when we put the VSI
down. Add this call so that the client doesn't get an open called with
no close.

Also remove an un-needed delay. The VF should not be affected at all by
i40e_down.

Change-ID: I1135dffef534bf84e6fed57cf51bcf590e6cfaf7
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9a26ecc..a2b4012 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5181,12 +5181,6 @@ static void i40e_vsi_reinit_locked(struct i40e_vsi *vsi)
 		usleep_range(1000, 2000);
 	i40e_down(vsi);
 
-	/* Give a VF some time to respond to the reset.  The
-	 * two second wait is based upon the watchdog cycle in
-	 * the VF driver.
-	 */
-	if (vsi->type == I40E_VSI_SRIOV)
-		msleep(2000);
 	i40e_up(vsi);
 	clear_bit(__I40E_CONFIG_BUSY, &pf->state);
 }
@@ -5229,6 +5223,9 @@ void i40e_down(struct i40e_vsi *vsi)
 		i40e_clean_tx_ring(vsi->tx_rings[i]);
 		i40e_clean_rx_ring(vsi->rx_rings[i]);
 	}
+
+	i40e_notify_client_of_netdev_close(vsi, false);
+
 }
 
 /**
@@ -5931,7 +5928,6 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
 			dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
 	}
-
 }
 
 /**
-- 
2.5.5
