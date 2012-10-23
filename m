From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] ixgbe: Enable support for VF API version 1.1 in the PF.
Date: Mon, 22 Oct 2012 21:26:17 -0700
Message-ID: <1350966385-19020-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35959 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292Ab2JWE03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 00:26:29 -0400
In-Reply-To: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change switches on the last few bits for us enabling version 1.1 VF
support in the PF.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Robert Garrett <RobertX.Garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 29 +++++++++++++++++++-------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 8bf467b..96876b7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -371,14 +371,26 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 					     IXGBE_FCOE_JUMBO_FRAME_SIZE);
 
 #endif /* CONFIG_FCOE */
-		/*
-		 * If the PF or VF are running w/ jumbo frames enabled we
-		 * need to shut down the VF Rx path as we cannot support
-		 * jumbo frames on legacy VFs
-		 */
-		if ((pf_max_frame > ETH_FRAME_LEN) ||
-		    (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)))
-			err = -EINVAL;
+		switch (adapter->vfinfo[vf].vf_api) {
+		case ixgbe_mbox_api_11:
+			/*
+			 * Version 1.1 supports jumbo frames on VFs if PF has
+			 * jumbo frames enabled which means legacy VFs are
+			 * disabled
+			 */
+			if (pf_max_frame > ETH_FRAME_LEN)
+				break;
+		default:
+			/*
+			 * If the PF or VF are running w/ jumbo frames enabled
+			 * we need to shut down the VF Rx path as we cannot
+			 * support jumbo frames on legacy VFs
+			 */
+			if ((pf_max_frame > ETH_FRAME_LEN) ||
+			    (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)))
+				err = -EINVAL;
+			break;
+		}
 
 		/* determine VF receive enable location */
 		vf_shift = vf % 32;
@@ -740,6 +752,7 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
 
 	switch (api) {
 	case ixgbe_mbox_api_10:
+	case ixgbe_mbox_api_11:
 		adapter->vfinfo[vf].vf_api = api;
 		return 0;
 	default:
-- 
1.7.11.7
