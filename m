From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e: Fix for extra Flow Director filter in table after error
Date: Thu,  8 Oct 2015 18:32:44 -0700
Message-ID: <1444354374-24351-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54300 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503AbbJIBc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:58 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where the PF's fdir filter table would have an
entry that the hw was unable to add. This notification happens in the hot
path, so instead of trying to fix it then, we note the location in the
failure case and delete it during regular fdir subtask callback. Without
this patch, a case can occur where an invalid entry gets replayed and a
valid one is not.

Change-ID: I67831c183b5d0309876de807cc434809b74c9cb7
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  3 ++-
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7a3c939..a662e39 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -410,6 +410,7 @@ struct i40e_pf {
 	u32 npar_min_bw;
 
 	u32 ioremap_len;
+	u32 fd_inv;
 };
 
 struct i40e_mac_filter {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2c59214..94953568 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5614,7 +5614,9 @@ u32 i40e_get_global_fd_count(struct i40e_pf *pf)
  **/
 void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 {
+	struct i40e_fdir_filter *filter;
 	u32 fcnt_prog, fcnt_avail;
+	struct hlist_node *node;
 
 	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
 		return;
@@ -5643,6 +5645,18 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 				dev_info(&pf->pdev->dev, "ATR is being enabled since we have space in the table now\n");
 		}
 	}
+
+	/* if hw had a problem adding a filter, delete it */
+	if (pf->fd_inv > 0) {
+		hlist_for_each_entry_safe(filter, node,
+					  &pf->fdir_filter_list, fdir_node) {
+			if (filter->fd_id == pf->fd_inv) {
+				hlist_del(&filter->fdir_node);
+				kfree(filter);
+				pf->fdir_pf_active_filters--;
+			}
+		}
+	}
 }
 
 #define I40E_MIN_FD_FLUSH_INTERVAL 10
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 889ed10..8ab7ab1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -465,10 +465,11 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		I40E_RX_PROG_STATUS_DESC_QW1_ERROR_SHIFT;
 
 	if (error == BIT(I40E_RX_PROG_STATUS_DESC_FD_TBL_FULL_SHIFT)) {
+		pf->fd_inv = le32_to_cpu(rx_desc->wb.qword0.hi_dword.fd_id);
 		if ((rx_desc->wb.qword0.hi_dword.fd_id != 0) ||
 		    (I40E_DEBUG_FD & pf->hw.debug_mask))
 			dev_warn(&pdev->dev, "ntuple filter loc = %d, could not be added\n",
-				 rx_desc->wb.qword0.hi_dword.fd_id);
+				 pf->fd_inv);
 
 		/* Check if the programming error is for ATR.
 		 * If so, auto disable ATR and set a state for
-- 
2.4.3
