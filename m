From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] i40e: clean whole mac filter list
Date: Sat, 12 Dec 2015 00:33:31 -0800
Message-ID: <1449909213-33795-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52824 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588AbbLLIdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 03:33:42 -0500
In-Reply-To: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Clean the whole mac filter list when resetting after an intermediate
add or delete push to the firmware.  The code had evolved from using
a list from the stack to a heap allocation, but the memset() didn't
follow the change correctly.  This now cleans the whole list rather
that just part of the first element.

Change-ID: I4cd03d5a103b7407dd8556a3a231e800f2d6f2d5
Reported-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 35d787e..8ebf72b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1916,11 +1916,12 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 	/* Now process 'del_list' outside the lock */
 	if (!list_empty(&tmp_del_list)) {
+		int del_list_size;
 		filter_list_len = pf->hw.aq.asq_buf_size /
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
-		del_list = kcalloc(filter_list_len,
-			    sizeof(struct i40e_aqc_remove_macvlan_element_data),
-			    GFP_KERNEL);
+		del_list_size = filter_list_len *
+			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
+		del_list = kzalloc(del_list_size, GFP_KERNEL);
 		if (!del_list) {
 			i40e_cleanup_add_list(&tmp_add_list);
 
@@ -1955,7 +1956,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 								NULL);
 				aq_err = pf->hw.aq.asq_last_status;
 				num_del = 0;
-				memset(del_list, 0, sizeof(*del_list));
+				memset(del_list, 0, del_list_size);
 
 				if (aq_ret && aq_err != I40E_AQ_RC_ENOENT) {
 					retval = -EIO;
@@ -1991,13 +1992,14 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	}
 
 	if (!list_empty(&tmp_add_list)) {
+		int add_list_size;
 
 		/* do all the adds now */
 		filter_list_len = pf->hw.aq.asq_buf_size /
 			       sizeof(struct i40e_aqc_add_macvlan_element_data),
-		add_list = kcalloc(filter_list_len,
-			       sizeof(struct i40e_aqc_add_macvlan_element_data),
-			       GFP_KERNEL);
+		add_list_size = filter_list_len *
+			       sizeof(struct i40e_aqc_add_macvlan_element_data);
+		add_list = kzalloc(add_list_size, GFP_KERNEL);
 		if (!add_list) {
 			/* Purge element from temporary lists */
 			i40e_cleanup_add_list(&tmp_add_list);
@@ -2036,7 +2038,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 				if (aq_ret)
 					break;
-				memset(add_list, 0, sizeof(*add_list));
+				memset(add_list, 0, add_list_size);
 			}
 			/* Entries from tmp_add_list were cloned from MAC
 			 * filter list, hence clean those cloned entries
-- 
2.5.0
