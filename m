From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: fix disabling overflow promiscuous mode
Date: Tue, 20 Jun 2017 18:17:59 -0700
Message-ID: <20170621011802.81768-13-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:48263 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753132AbdFUBSO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:14 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

There exists a bug in which the driver does not correctly exit overflow
promiscuous mode.  This can occur if "too many" mac filters are added,
putting the driver into overflow promiscuous mode, and the filters are
then removed.  When the failed filters are removed, the driver reports
exiting overflow promiscuous mode which is correct, however traffic
continues to be received as if in promiscuous mode still.

The bug occurs because the conditional for toggling promiscuous mode was
set to only execute when promiscuous mode was enabled and not when it
was disabled as well.  This patch fixes the conditional to correctly
execute when promiscuous mode is toggled and not just enabled.  Without
this patch, the driver is unable to correctly exit overflow promiscuous
mode.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8af6420826d1..b743eca879d5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2281,9 +2281,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				 i40e_aq_str(hw, hw->aq.asq_last_status));
 		}
 	}
-	if ((changed_flags & IFF_PROMISC) ||
-	    (promisc_changed &&
-	     test_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state))) {
+
+	if ((changed_flags & IFF_PROMISC) || promisc_changed) {
 		bool cur_promisc;
 
 		cur_promisc = (!!(vsi->current_netdev_flags & IFF_PROMISC) ||
-- 
2.12.2
