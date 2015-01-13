From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] i40e: avoid use of uninitialized v_budget in i40e_init_msix
Date: Tue, 13 Jan 2015 13:48:28 -0500
Message-ID: <1421174908-20445-1-git-send-email-linville@tuxdriver.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47927 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618AbbAMTAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:00:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This I40E_FCOE block increments v_budget before it has been initialized,
then v_budget gets overwritten a few lines later.  This patch just
reorders the code hunks in what I believe was the intended sequence.

Coverity: CID 1260099

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Compile tested only...

 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a5f2660d552d..5415d9fd7c63 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6881,17 +6881,17 @@ static int i40e_init_msix(struct i40e_pf *pf)
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED)
 		other_vecs++;
 
+	/* Scale down if necessary, and the rings will share vectors */
+	pf->num_lan_msix = min_t(int, pf->num_lan_msix,
+			(hw->func_caps.num_msix_vectors - other_vecs));
+	v_budget = pf->num_lan_msix + other_vecs;
+
 #ifdef I40E_FCOE
 	if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
 		pf->num_fcoe_msix = pf->num_fcoe_qps;
 		v_budget += pf->num_fcoe_msix;
 	}
-
 #endif
-	/* Scale down if necessary, and the rings will share vectors */
-	pf->num_lan_msix = min_t(int, pf->num_lan_msix,
-			(hw->func_caps.num_msix_vectors - other_vecs));
-	v_budget = pf->num_lan_msix + other_vecs;
 
 	pf->msix_entries = kcalloc(v_budget, sizeof(struct msix_entry),
 				   GFP_KERNEL);
-- 
2.1.0
