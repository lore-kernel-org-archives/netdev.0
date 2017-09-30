From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Fix unqualified module message while bringing link up
Date: Fri, 29 Sep 2017 17:44:54 -0700
Message-ID: <20170930004507.20072-3-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23279 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752572AbdI3Apt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:49 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

In current driver, when ifconfig ethx up is done, the link state
doesn't transition to UP inside i40e_open(). It changes after AQ
command response is handled in i40e_handle_link_event().

When pf->hw.phy.link_info.link_info is DOWN inside i40e_open(),
The state is transient and invalid. So log message gets printed
based on incorrect info (i.e link_info and an_info).

This commit removes check for unqualified module inside
i40e_up_complete(). The existing check in i40e_handle_link_event()
logs the error message based on correct link state information.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6498da8806cb..b235a27232a8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5470,15 +5470,6 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 		i40e_print_link_message(vsi, true);
 		netif_tx_start_all_queues(vsi->netdev);
 		netif_carrier_on(vsi->netdev);
-	} else if (vsi->netdev) {
-		i40e_print_link_message(vsi, false);
-		/* need to check for qualified module here*/
-		if ((pf->hw.phy.link_info.link_info &
-			I40E_AQ_MEDIA_AVAILABLE) &&
-		    (!(pf->hw.phy.link_info.an_info &
-			I40E_AQ_QUALIFIED_MODULE)))
-			netdev_err(vsi->netdev,
-				   "the driver failed to link because an unqualified module was detected.");
 	}
 
 	/* replay FDIR SB filters */
-- 
2.14.1
