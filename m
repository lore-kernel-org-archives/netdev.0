From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: Fix a boundary condition and turning off of ntuple
Date: Wed,  2 Jul 2014 19:40:25 -0700
Message-ID: <1404355233-30123-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56274 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbaGCClO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:14 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

When turning off ntuple with a FD table full situation,
the driver would have auto disabled FD filter additions.
Clear the auto disable flag for FD_SB so that when the
feature is turned on again using "ethtool -K ethx ntuple on"
we can start adding filters once again.

Change-ID: I036a32e7331bcae765b657c8abb4fa070940b163
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 88704c0..d9dcb8c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6885,9 +6885,11 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
 			i40e_fdir_filter_exit(pf);
 		}
 		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
-		/* if ATR was disabled it can be re-enabled. */
-		if (!(pf->flags & I40E_FLAG_FD_ATR_ENABLED))
-			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
+		pf->auto_disable_flags &= ~I40E_FLAG_FD_SB_ENABLED;
+		/* if ATR was auto disabled it can be re-enabled. */
+		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
+		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 	}
 	return need_reset;
 }
-- 
1.9.3
