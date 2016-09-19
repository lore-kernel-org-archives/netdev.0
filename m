From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 3/3] i40e: fix sideband flow director vector allocation
Date: Mon, 19 Sep 2016 13:37:51 +0200
Message-ID: <1474285071-28218-4-git-send-email-sassmann@kpanic.de>
References: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757532AbcISLiU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 07:38:20 -0400
In-Reply-To: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if the MSI-X vector limit is reached the sideband flow
director gets disabled. A bit too early to make that decision, as
vectors may get re-distributed. So move the check further back.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4727c02..19341fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7645,7 +7645,6 @@ static int i40e_init_msix(struct i40e_pf *pf)
 			vectors_left--;
 		} else {
 			pf->num_fdsb_msix = 0;
-			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 		}
 	}
 
@@ -7742,7 +7741,6 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->num_fcoe_qps = 0;
 		pf->num_fcoe_msix = 0;
 #endif
-		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 
 		/* partition out the remaining vectors */
 		switch (vec) {
@@ -7774,6 +7772,10 @@ static int i40e_init_msix(struct i40e_pf *pf)
 				pf->num_vmdq_vsis = min_t(int, (vec / 2),
 						  I40E_DEFAULT_NUM_VMDQ_VSI);
 			}
+			if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
+				pf->num_fdsb_msix = 1;
+				vec--;
+			}
 			pf->num_lan_msix = min_t(int,
 			       (vec - (pf->num_iwarp_msix + pf->num_vmdq_vsis)),
 							      pf->num_lan_msix);
@@ -7789,6 +7791,11 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		}
 	}
 
+	if ((pf->flags & I40E_FLAG_FD_SB_ENABLED) &&
+	    (pf->num_fdsb_msix == 0)) {
+		dev_info(&pf->pdev->dev, "Sideband Flowdir disabled, not enough MSI-X vectors\n");
+		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
+	}
 	if ((pf->flags & I40E_FLAG_VMDQ_ENABLED) &&
 	    (pf->num_vmdq_msix == 0)) {
 		dev_info(&pf->pdev->dev, "VMDq disabled, not enough MSI-X vectors\n");
-- 
2.7.4
