From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] i40e: Update flow director error messages to reduce user confusion
Date: Wed, 27 Aug 2014 02:26:36 -0700
Message-ID: <1409131606-15011-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64393 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932307AbaH0J0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:26:51 -0400
In-Reply-To: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes the wording of the flow director add/remove and
asynchronous failure messages to include fd_id to try and add some
way to track the operations on a given fd_id.  Its not perfect, but
its better than what we had as PCTYPE can apply to several different
filter requests.

This patch also removes a redundant message when filter
addition fails due to full condition.

Change-ID: Icf58b0603d4f162d9fc542f11a74866a907049f2
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 33 ++++++++++++++---------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a51aa37..a6cc8d6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -224,15 +224,14 @@ static int i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 	ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
 	if (ret) {
 		dev_info(&pf->pdev->dev,
-			 "Filter command send failed for PCTYPE %d (ret = %d)\n",
-			 fd_data->pctype, ret);
+			 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
+			 fd_data->pctype, fd_data->fd_id, ret);
 		err = true;
 	} else {
 		dev_info(&pf->pdev->dev,
-			 "Filter OK for PCTYPE %d (ret = %d)\n",
-			 fd_data->pctype, ret);
+			 "PCTYPE:%d, Filter send OK for fd_id:%d\n",
+			 fd_data->pctype, fd_data->fd_id);
 	}
-
 	return err ? -EOPNOTSUPP : 0;
 }
 
@@ -287,12 +286,13 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 
 	if (ret) {
 		dev_info(&pf->pdev->dev,
-			 "Filter command send failed for PCTYPE %d (ret = %d)\n",
-			 fd_data->pctype, ret);
+			 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
+			 fd_data->pctype, fd_data->fd_id, ret);
 		err = true;
 	} else {
-		dev_info(&pf->pdev->dev, "Filter OK for PCTYPE %d (ret = %d)\n",
-			 fd_data->pctype, ret);
+		dev_info(&pf->pdev->dev,
+			 "PCTYPE:%d, Filter send OK for fd_id:%d\n",
+			 fd_data->pctype, fd_data->fd_id);
 	}
 
 	return err ? -EOPNOTSUPP : 0;
@@ -355,13 +355,13 @@ static int i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 
 		if (ret) {
 			dev_info(&pf->pdev->dev,
-				 "Filter command send failed for PCTYPE %d (ret = %d)\n",
-				 fd_data->pctype, ret);
+				 "PCTYPE:%d, Filter command send failed for fd_id:%d (ret = %d)\n",
+				 fd_data->pctype, fd_data->fd_id, ret);
 			err = true;
 		} else {
 			dev_info(&pf->pdev->dev,
-				 "Filter OK for PCTYPE %d (ret = %d)\n",
-				 fd_data->pctype, ret);
+				 "PCTYPE:%d, Filter send OK for fd_id:%d\n",
+				 fd_data->pctype, fd_data->fd_id);
 		}
 	}
 
@@ -443,8 +443,6 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		I40E_RX_PROG_STATUS_DESC_QW1_ERROR_SHIFT;
 
 	if (error == (0x1 << I40E_RX_PROG_STATUS_DESC_FD_TBL_FULL_SHIFT)) {
-		dev_warn(&pdev->dev, "ntuple filter loc = %d, could not be added\n",
-			 rx_desc->wb.qword0.hi_dword.fd_id);
 
 		/* filter programming failed most likely due to table full */
 		fcnt_prog = i40e_get_cur_guaranteed_fd_count(pf);
@@ -471,12 +469,13 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 				pf->flags |= I40E_FLAG_FDIR_REQUIRES_REINIT;
 			}
 		} else {
-			dev_info(&pdev->dev, "FD filter programming error\n");
+			dev_info(&pdev->dev,
+				 "FD filter programming failed due to incorrect filter parameters\n");
 		}
 	} else if (error ==
 			  (0x1 << I40E_RX_PROG_STATUS_DESC_NO_FD_ENTRY_SHIFT)) {
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
-			dev_info(&pdev->dev, "ntuple filter loc = %d, could not be removed\n",
+			dev_info(&pdev->dev, "ntuple filter fd_id = %d, could not be removed\n",
 				 rx_desc->wb.qword0.hi_dword.fd_id);
 	}
 }
-- 
1.9.3
