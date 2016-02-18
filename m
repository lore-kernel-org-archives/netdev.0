From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Removal of code which relies on BASE VEB SEID
Date: Thu, 18 Feb 2016 01:04:04 -0800
Message-ID: <1455786252-71881-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14291 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425719AbcBRJE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:29 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

Fixed mapping of SEID is removed from specification. Hence
this patch removes code which was using hard coded base VEB SEID.

Changed FCoE code to use "hw->pf_id" to obtain correct "idx"
and verified.

Removed defines for BASE VSI/VEB SEID and BASE_PF_SEID since it
is not used anymore.

Change-ID: Id507cf4b1fae1c0145e3f08ae9ea5846ea5840de
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  3 ---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 16 +++-------------
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  2 +-
 3 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 5d8e159..e0758dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -64,9 +64,6 @@
 #include "i40e_dcb.h"
 
 /* Useful i40e defaults */
-#define I40E_BASE_PF_SEID     16
-#define I40E_BASE_VSI_SEID    512
-#define I40E_BASE_VEB_SEID    288
 #define I40E_MAX_VEB          16
 
 #define I40E_MAX_NUM_DESCRIPTORS      4096
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 631c2d6..2a44f2e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -61,13 +61,9 @@ static struct i40e_veb *i40e_dbg_find_veb(struct i40e_pf *pf, int seid)
 {
 	int i;
 
-	if ((seid < I40E_BASE_VEB_SEID) ||
-	    (seid > (I40E_BASE_VEB_SEID + I40E_MAX_VEB)))
-		dev_info(&pf->pdev->dev, "%d: bad seid\n", seid);
-	else
-		for (i = 0; i < I40E_MAX_VEB; i++)
-			if (pf->veb[i] && pf->veb[i]->seid == seid)
-				return pf->veb[i];
+	for (i = 0; i < I40E_MAX_VEB; i++)
+		if (pf->veb[i] && pf->veb[i]->seid == seid)
+			return pf->veb[i];
 	return NULL;
 }
 
@@ -691,12 +687,6 @@ static void i40e_dbg_dump_veb_seid(struct i40e_pf *pf, int seid)
 {
 	struct i40e_veb *veb;
 
-	if ((seid < I40E_BASE_VEB_SEID) ||
-	    (seid >= (I40E_MAX_VEB + I40E_BASE_VEB_SEID))) {
-		dev_info(&pf->pdev->dev, "%d: bad seid\n", seid);
-		return;
-	}
-
 	veb = i40e_dbg_find_veb(pf, seid);
 	if (!veb) {
 		dev_info(&pf->pdev->dev, "can't find veb %d\n", seid);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 41d6d55..adb2a04 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -768,7 +768,7 @@ static void i40e_update_fcoe_stats(struct i40e_vsi *vsi)
 	if (vsi->type != I40E_VSI_FCOE)
 		return;
 
-	idx = (pf->pf_seid - I40E_BASE_PF_SEID) + I40E_FCOE_PF_STAT_OFFSET;
+	idx = hw->pf_id + I40E_FCOE_PF_STAT_OFFSET;
 	fs = &vsi->fcoe_stats;
 	ofs = &vsi->fcoe_stats_offsets;
 
-- 
2.5.0
