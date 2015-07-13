From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e/i40evf: Add support for pre-allocated pages for PD
Date: Mon, 13 Jul 2015 02:08:35 -0700
Message-ID: <1436778517-16254-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Faisal Latif <faisal.latif@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40574 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406AbbGMJIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 05:08:48 -0400
In-Reply-To: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Faisal Latif <faisal.latif@intel.com>

The i40e_add_pd_table_entry() routine is being modified to handle both
cases where a backing page is passed and where backing page is allocated
in i40e_add_pd_table_entry().

For PBLE resource management, it is more efficient for it to manage its
backing pages. For VF, PBLE backing page addresses will be send to PF
driver for PBLE resource.

The i40e_remove_pd_bp() is also modified to not free pre-allocated pages and
free only ones which were allocated in i40e_add_pd_table_entry().

Change-ID: Ie673f0403f22979e9406f5a94048dceb91bcf9a8
Signed-off-by: Faisal Latif <faisal.latif@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_hmc.c     | 30 +++++++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_hmc.h     |  4 +++-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h   |  4 +++-
 4 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
index 9b987cc..b89856a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
@@ -116,6 +116,7 @@ exit:
  * @hw: pointer to our HW structure
  * @hmc_info: pointer to the HMC configuration information structure
  * @pd_index: which page descriptor index to manipulate
+ * @rsrc_pg: if not NULL, use preallocated page instead of allocating new one.
  *
  * This function:
  *	1. Initializes the pd entry
@@ -129,12 +130,14 @@ exit:
  **/
 i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
 					      struct i40e_hmc_info *hmc_info,
-					      u32 pd_index)
+					      u32 pd_index,
+					      struct i40e_dma_mem *rsrc_pg)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_pd_table *pd_table;
 	struct i40e_hmc_pd_entry *pd_entry;
 	struct i40e_dma_mem mem;
+	struct i40e_dma_mem *page = &mem;
 	u32 sd_idx, rel_pd_idx;
 	u64 *pd_addr;
 	u64 page_desc;
@@ -155,18 +158,24 @@ i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
 	pd_table = &hmc_info->sd_table.sd_entry[sd_idx].u.pd_table;
 	pd_entry = &pd_table->pd_entry[rel_pd_idx];
 	if (!pd_entry->valid) {
-		/* allocate a 4K backing page */
-		ret_code = i40e_allocate_dma_mem(hw, &mem, i40e_mem_bp,
-						 I40E_HMC_PAGED_BP_SIZE,
-						 I40E_HMC_PD_BP_BUF_ALIGNMENT);
-		if (ret_code)
-			goto exit;
+		if (rsrc_pg) {
+			pd_entry->rsrc_pg = true;
+			page = rsrc_pg;
+		} else {
+			/* allocate a 4K backing page */
+			ret_code = i40e_allocate_dma_mem(hw, page, i40e_mem_bp,
+						I40E_HMC_PAGED_BP_SIZE,
+						I40E_HMC_PD_BP_BUF_ALIGNMENT);
+			if (ret_code)
+				goto exit;
+			pd_entry->rsrc_pg = false;
+		}
 
-		pd_entry->bp.addr = mem;
+		pd_entry->bp.addr = *page;
 		pd_entry->bp.sd_pd_index = pd_index;
 		pd_entry->bp.entry_type = I40E_SD_TYPE_PAGED;
 		/* Set page address and valid bit */
-		page_desc = mem.pa | 0x1;
+		page_desc = page->pa | 0x1;
 
 		pd_addr = (u64 *)pd_table->pd_page_addr.va;
 		pd_addr += rel_pd_idx;
@@ -240,7 +249,8 @@ i40e_status i40e_remove_pd_bp(struct i40e_hw *hw,
 	I40E_INVALIDATE_PF_HMC_PD(hw, sd_idx, idx);
 
 	/* free memory here */
-	ret_code = i40e_free_dma_mem(hw, &(pd_entry->bp.addr));
+	if (!pd_entry->rsrc_pg)
+		ret_code = i40e_free_dma_mem(hw, &pd_entry->bp.addr);
 	if (ret_code)
 		goto exit;
 	if (!pd_table->ref_cnt)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
index 732a026..386416b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
@@ -62,6 +62,7 @@ struct i40e_hmc_bp {
 struct i40e_hmc_pd_entry {
 	struct i40e_hmc_bp bp;
 	u32 sd_index;
+	bool rsrc_pg;
 	bool valid;
 };
 
@@ -218,7 +219,8 @@ i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
 
 i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
 					      struct i40e_hmc_info *hmc_info,
-					      u32 pd_index);
+					      u32 pd_index,
+					      struct i40e_dma_mem *rsrc_pg);
 i40e_status i40e_remove_pd_bp(struct i40e_hw *hw,
 					struct i40e_hmc_info *hmc_info,
 					u32 idx);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 0079ad7..d399eaf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -387,7 +387,7 @@ static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
 				/* update the pd table entry */
 				ret_code = i40e_add_pd_table_entry(hw,
 								info->hmc_info,
-								i);
+								i, NULL);
 				if (ret_code) {
 					pd_error = true;
 					break;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_hmc.h b/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
index 931c880..adc6f71 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
@@ -62,6 +62,7 @@ struct i40e_hmc_bp {
 struct i40e_hmc_pd_entry {
 	struct i40e_hmc_bp bp;
 	u32 sd_index;
+	bool rsrc_pg;
 	bool valid;
 };
 
@@ -218,7 +219,8 @@ i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
 
 i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
 					      struct i40e_hmc_info *hmc_info,
-					      u32 pd_index);
+					      u32 pd_index,
+					      struct i40e_dma_mem *rsrc_pg);
 i40e_status i40e_remove_pd_bp(struct i40e_hw *hw,
 					struct i40e_hmc_info *hmc_info,
 					u32 idx);
-- 
2.4.3
