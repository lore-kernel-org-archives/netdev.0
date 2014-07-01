From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: FD filter replay logic bug fix
Date: Tue,  1 Jul 2014 04:35:04 -0700
Message-ID: <1404214511-26868-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756629AbaGALfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:17 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

With the auto_disable flags added there was a bug that was causing the
replay logic to not work correctly.
This patch fixes the issue so that we call a replay after a sideband
reset correctly.

Change-ID: I005fe1ac361188ee5b19517a83c922038cba1b00
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5cc27fb..babb7e6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -445,14 +445,16 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		 */
 		if (fcnt_prog >= (fcnt_avail - I40E_FDIR_BUFFER_FULL_MARGIN)) {
 			/* Turn off ATR first */
-			if (pf->flags & I40E_FLAG_FD_ATR_ENABLED) {
-				pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
+			if ((pf->flags & I40E_FLAG_FD_ATR_ENABLED) &&
+			    !(pf->auto_disable_flags &
+			      I40E_FLAG_FD_ATR_ENABLED)) {
 				dev_warn(&pdev->dev, "FD filter space full, ATR for further flows will be turned off\n");
 				pf->auto_disable_flags |=
 						       I40E_FLAG_FD_ATR_ENABLED;
 				pf->flags |= I40E_FLAG_FDIR_REQUIRES_REINIT;
-			} else if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
-				pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
+			} else if ((pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
+				   !(pf->auto_disable_flags &
+				     I40E_FLAG_FD_SB_ENABLED)) {
 				dev_warn(&pdev->dev, "FD filter space full, new ntuple rules will not be added\n");
 				pf->auto_disable_flags |=
 							I40E_FLAG_FD_SB_ENABLED;
-- 
1.9.3
