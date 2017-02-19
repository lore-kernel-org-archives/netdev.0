From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: fix disable overflow promiscuous mode
Date: Sat, 18 Feb 2017 22:33:29 -0800
Message-ID: <20170219063341.8039-2-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39180 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750862AbdBSGeK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:10 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

There exists a bug in which the driver is unable to exit overflow
promiscuous mode after having added "too many" mac filters.  It is
expected that after triggering overflow promiscuous, removing the
failed/extra filters should then disable overflow promiscuous mode.

The bug exists because we were intentionally skipping the sync_vsi_filter
path in cases where we were removing failed filters since they shouldn't
have been added to the firmware in the first place, however we still
need to go through the sync_vsi_filter code path to determine whether or
not it is ok to exit overflow promiscuous mode.  This patch fixes the
bug by making sure we go through the sync_vsi_filter path in cases of
failed filters.

Change-ID: I634d249ca3e5fa50729553137c295e73e7722143
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e83a8ca5dd65..fb8a52dd94cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1447,18 +1447,20 @@ void __i40e_del_filter(struct i40e_vsi *vsi, struct i40e_mac_filter *f)
 	if (!f)
 		return;
 
+	/* If the filter was never added to firmware then we can just delete it
+	 * directly and we don't want to set the status to remove or else an
+	 * admin queue command will unnecessarily fire.
+	 */
 	if ((f->state == I40E_FILTER_FAILED) ||
 	    (f->state == I40E_FILTER_NEW)) {
-		/* this one never got added by the FW. Just remove it,
-		 * no need to sync anything.
-		 */
 		hash_del(&f->hlist);
 		kfree(f);
 	} else {
 		f->state = I40E_FILTER_REMOVE;
-		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
-		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
 	}
+
+	vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
+	vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
 }
 
 /**
-- 
2.11.0
