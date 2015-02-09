From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: avoid use of uninitialized v_budget in i40e_init_msix
Date: Mon,  9 Feb 2015 02:43:48 -0800
Message-ID: <1423478641-3138-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John W Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16331 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759985AbbBIKoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:05 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John W Linville <linville@tuxdriver.com>

This I40E_FCOE block increments v_budget before it has been initialized,
then v_budget gets overwritten a few lines later.  This patch just
reorders the code hunks in what I believe was the intended sequence.

Coverity: CID 1260099

Signed-off-by: John W Linville <linville@tuxdriver.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e774a23..9efb69a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6933,17 +6933,17 @@ static int i40e_init_msix(struct i40e_pf *pf)
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
1.9.3
