From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/3] i40e: fix sideband flow director vector allocation
Date: Mon,  3 Oct 2016 19:25:03 -0700
Message-ID: <1475547903-22168-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35976 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751664AbcJDCZG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 22:25:06 -0400
In-Reply-To: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

Currently if the MSI-X vector limit is reached the sideband flow
director gets disabled. A bit too early to make that decision, as
vectors may get re-distributed. So move the check further back.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ca7dd43..0044c29 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7641,7 +7641,6 @@ static int i40e_init_msix(struct i40e_pf *pf)
 			vectors_left--;
 		} else {
 			pf->num_fdsb_msix = 0;
-			pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 		}
 	}
 
@@ -7738,7 +7737,6 @@ static int i40e_init_msix(struct i40e_pf *pf)
 		pf->num_fcoe_qps = 0;
 		pf->num_fcoe_msix = 0;
 #endif
-		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 
 		/* partition out the remaining vectors */
 		switch (vec) {
@@ -7770,6 +7768,10 @@ static int i40e_init_msix(struct i40e_pf *pf)
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
@@ -7785,6 +7787,11 @@ static int i40e_init_msix(struct i40e_pf *pf)
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
