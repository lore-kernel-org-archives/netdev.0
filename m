From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] ixgbe: Correct check for change in FCoE priority
Date: Thu, 13 Oct 2011 00:15:04 -0700
Message-ID: <1318490112-5092-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55428 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542Ab1JMHPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 03:15:17 -0400
In-Reply-To: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Correct a check for change in FCoE priority when IEEE mode DCB is in use.
In IEEE mode a different function has to be used to get the FCoE priority
mask. Also, the check for the mask assumed that only one priority was set.
In case there should be more than one, check just the bit.

These changes help avoid link flapping issues that can come up when IEEE
DCB is in use.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index be66bb6..3631d63 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -318,7 +318,15 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 			      .selector = DCB_APP_IDTYPE_ETHTYPE,
 			      .protocol = ETH_P_FCOE,
 			     };
-	u8 up = dcb_getapp(netdev, &app);
+	u8 up;
+
+	/* In IEEE mode, use the IEEE Ethertype selector value */
+	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE) {
+		app.selector = IEEE_8021QAZ_APP_SEL_ETHERTYPE;
+		up = dcb_ieee_getapp_mask(netdev, &app);
+	} else {
+		up = dcb_getapp(netdev, &app);
+	}
 #endif
 
 	/* Fail command if not in CEE mode */
@@ -331,7 +339,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		return DCB_NO_HW_CHG;
 
 #ifdef IXGBE_FCOE
-	if (up && (up != (1 << adapter->fcoe.up)))
+	if (up && !(up & (1 << adapter->fcoe.up)))
 		adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
 
 	/*
-- 
1.7.6.4
