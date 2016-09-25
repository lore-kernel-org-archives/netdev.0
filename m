From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: check conflicting ntuple/sideband rules when re-enabling ATR
Date: Sat, 24 Sep 2016 23:42:39 -0700
Message-ID: <1474785769-54665-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47187 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965562AbcIYGmy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:54 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In i40e_fdir_check_and_reenable(), the driver performs some checks to
determine whether it is safe to re-enable FD Sideband and FD ATR
support. The current check will only determine if there is available
space in the flow director table. However, this ignores the fact that
ATR should be disabled when there are TCP/IPv4 sideband rules in effect.
Add the missing check, and update the info message printed when
I40E_DEBUG_FD is enabled.

Change-ID: Ibb9c63e5be95d63c53a498fdd5dbf69f54a00e08
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e1a2c9a..89b0418 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5939,13 +5939,17 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 				dev_info(&pf->pdev->dev, "FD Sideband/ntuple is being enabled since we have space in the table now\n");
 		}
 	}
-	/* Wait for some more space to be available to turn on ATR */
+
+	/* Wait for some more space to be available to turn on ATR. We also
+	 * must check that no existing ntuple rules for TCP are in effect
+	 */
 	if (fcnt_prog < (fcnt_avail - I40E_FDIR_BUFFER_HEAD_ROOM * 2)) {
 		if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
-		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED)) {
+		    (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED) &&
+		    (pf->fd_tcp_rule == 0)) {
 			pf->auto_disable_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 			if (I40E_DEBUG_FD & pf->hw.debug_mask)
-				dev_info(&pf->pdev->dev, "ATR is being enabled since we have space in the table now\n");
+				dev_info(&pf->pdev->dev, "ATR is being enabled since we have space in the table and there are no conflicting ntuple rules\n");
 		}
 	}
 
-- 
2.7.4
