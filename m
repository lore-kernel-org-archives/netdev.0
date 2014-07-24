From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e/i40evf: ARQ copy desc data even for failed commands
Date: Thu, 24 Jul 2014 06:13:21 -0700
Message-ID: <1406207604-31653-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36526 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759228AbaGXNOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:06 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

Copy desc and buffer data even for ARQ events which return error status.
Previously, a check for NVM related AQ commands which is done later in this
function would not recognize that such a command was received and would
not clear nvm_busy flag. This would block access to NVM until a driver reset.
This will fix that.

Change-ID: If69ad74e165b56081c0686b97402511d2e2880c0
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 14 +++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 14 +++++++-------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 1e21fbb..c6d767c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -979,15 +979,15 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 			   I40E_DEBUG_AQ_MESSAGE,
 			   "AQRX: Event received with error 0x%X.\n",
 			   hw->aq.arq_last_status);
-	} else {
-		e->desc = *desc;
-		datalen = le16_to_cpu(desc->datalen);
-		e->msg_size = min(datalen, e->msg_size);
-		if (e->msg_buf != NULL && (e->msg_size != 0))
-			memcpy(e->msg_buf, hw->aq.arq.r.arq_bi[desc_idx].va,
-			       e->msg_size);
 	}
 
+	e->desc = *desc;
+	datalen = le16_to_cpu(desc->datalen);
+	e->msg_size = min(datalen, e->msg_size);
+	if (e->msg_buf != NULL && (e->msg_size != 0))
+		memcpy(e->msg_buf, hw->aq.arq.r.arq_bi[desc_idx].va,
+		       e->msg_size);
+
 	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE, "AQRX: desc and buffer:\n");
 	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, e->msg_buf);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index ee3a934..3291d2c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -927,15 +927,15 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 			   I40E_DEBUG_AQ_MESSAGE,
 			   "AQRX: Event received with error 0x%X.\n",
 			   hw->aq.arq_last_status);
-	} else {
-		e->desc = *desc;
-		datalen = le16_to_cpu(desc->datalen);
-		e->msg_size = min(datalen, e->msg_size);
-		if (e->msg_buf != NULL && (e->msg_size != 0))
-			memcpy(e->msg_buf, hw->aq.arq.r.arq_bi[desc_idx].va,
-			       e->msg_size);
 	}
 
+	e->desc = *desc;
+	datalen = le16_to_cpu(desc->datalen);
+	e->msg_size = min(datalen, e->msg_size);
+	if (e->msg_buf != NULL && (e->msg_size != 0))
+		memcpy(e->msg_buf, hw->aq.arq.r.arq_bi[desc_idx].va,
+		       e->msg_size);
+
 	if (i40e_is_nvm_update_op(&e->desc))
 		hw->aq.nvm_busy = false;
 
-- 
1.9.3
