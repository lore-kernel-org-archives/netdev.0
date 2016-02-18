From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: Fix PROMISC mode for Multi-function per port (MFP) devices
Date: Thu, 18 Feb 2016 01:04:03 -0800
Message-ID: <1455786252-71881-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39536 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425570AbcBRJE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:28 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch falls back to enabling unicast, multicast and
broadcast promiscuous mode when the driver must disable it's use
of "default port" aka defport mode (which is normally used to
provide a promiscuous mode), due to internal incompatibility
with Multiple Function per Port (aka MFP).

The situation that requires this patch is when Physical
Function 0 is the device being used, and it can support SR-IOV
when MFP is enabled, via the driver creating a VEB on an MFP
enabled adapter.

Change-ID: Ie90b00d0d58782a5dfcf2c3c9725a2eb90bd63d8
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index aa1c7ca..41d6d55 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2122,7 +2122,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		cur_promisc = (!!(vsi->current_netdev_flags & IFF_PROMISC) ||
 			       test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 					&vsi->state));
-		if (vsi->type == I40E_VSI_MAIN && pf->lan_veb != I40E_NO_VEB) {
+		if ((vsi->type == I40E_VSI_MAIN) &&
+		    (pf->lan_veb != I40E_NO_VEB) &&
+		    !(pf->flags & I40E_FLAG_MFP_ENABLED)) {
 			/* set defport ON for Main VSI instead of true promisc
 			 * this way we will get all unicast/multicast and VLAN
 			 * promisc behavior but will not get VF or VMDq traffic
-- 
2.5.0
