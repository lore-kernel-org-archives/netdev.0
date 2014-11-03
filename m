From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] i40e: scale msix vector use when more cores than vectors
Date: Mon,  3 Nov 2014 06:56:35 -0800
Message-ID: <1415026599-16232-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44881 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698AbaKCO44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:56 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When there are more cores than vectors available to the PF, scale back
the LAN msix usage to force queue/vector sharing and leave some vectors
for Flow Director, VMDq, etc.

Change-ID: Ie0317732eb85ad8d851d7da7d9af86b1bf8c21ad
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f95c04a..83fee7f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6699,6 +6699,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 {
 	i40e_status err = 0;
 	struct i40e_hw *hw = &pf->hw;
+	int other_vecs = 0;
 	int v_budget, i;
 	int vec;
 
@@ -6724,10 +6725,10 @@ static int i40e_init_msix(struct i40e_pf *pf)
 	 */
 	pf->num_lan_msix = pf->num_lan_qps - (pf->rss_size_max - pf->rss_size);
 	pf->num_vmdq_msix = pf->num_vmdq_qps;
-	v_budget = 1 + pf->num_lan_msix;
-	v_budget += (pf->num_vmdq_vsis * pf->num_vmdq_msix);
+	other_vecs = 1;
+	other_vecs += (pf->num_vmdq_vsis * pf->num_vmdq_msix);
 	if (pf->flags & I40E_FLAG_FD_SB_ENABLED)
-		v_budget++;
+		other_vecs++;
 
 #ifdef I40E_FCOE
 	if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
@@ -6737,7 +6738,9 @@ static int i40e_init_msix(struct i40e_pf *pf)
 
 #endif
 	/* Scale down if necessary, and the rings will share vectors */
-	v_budget = min_t(int, v_budget, hw->func_caps.num_msix_vectors);
+	pf->num_lan_msix = min_t(int, pf->num_lan_msix,
+			(hw->func_caps.num_msix_vectors - other_vecs));
+	v_budget = pf->num_lan_msix + other_vecs;
 
 	pf->msix_entries = kcalloc(v_budget, sizeof(struct msix_entry),
 				   GFP_KERNEL);
-- 
1.9.3
