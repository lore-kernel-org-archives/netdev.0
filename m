From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 21/22] i40e: Implementation of ERROR state for NVM update state machine
Date: Mon, 31 Oct 2016 15:29:51 -0700
Message-ID: <1477952992-125662-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Maciej Sosin <maciej.sosin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28490 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947527AbcJaWaF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:30:05 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Sosin <maciej.sosin@intel.com>

This patch adds I40E_NVMUPD_STATE_ERROR state for NVM update.
Without this patch driver has no possibility to return NVM image write
failure.This state is being set when ARQ rises error.
arq_last_status is also updated every time when ARQ event comes,
not only on error cases.

Change-ID: I67ce43ba22a240773c2821b436e96054db0b7c81
Signed-off-by: Maciej Sosin <maciej.sosin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      | 16 ++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h     |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |  4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |  1 +
 5 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 738b42a..56fb272 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -964,11 +964,11 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	desc = I40E_ADMINQ_DESC(hw->aq.arq, ntc);
 	desc_idx = ntc;
 
+	hw->aq.arq_last_status =
+		(enum i40e_admin_queue_err)le16_to_cpu(desc->retval);
 	flags = le16_to_cpu(desc->flags);
 	if (flags & I40E_AQ_FLAG_ERR) {
 		ret_code = I40E_ERR_ADMIN_QUEUE_ERROR;
-		hw->aq.arq_last_status =
-			(enum i40e_admin_queue_err)le16_to_cpu(desc->retval);
 		i40e_debug(hw,
 			   I40E_DEBUG_AQ_MESSAGE,
 			   "AQRX: Event received with error 0x%X.\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 954efe3..38ee18f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -722,9 +722,20 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 			*((u16 *)&bytes[2]) = hw->nvm_wait_opcode;
 		}
 
+		/* Clear error status on read */
+		if (hw->nvmupd_state == I40E_NVMUPD_STATE_ERROR)
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+
 		return 0;
 	}
 
+	/* Clear status even it is not read and log */
+	if (hw->nvmupd_state == I40E_NVMUPD_STATE_ERROR) {
+		i40e_debug(hw, I40E_DEBUG_NVM,
+			   "Clearing I40E_NVMUPD_STATE_ERROR state without reading\n");
+		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+	}
+
 	switch (hw->nvmupd_state) {
 	case I40E_NVMUPD_STATE_INIT:
 		status = i40e_nvmupd_state_init(hw, cmd, bytes, perrno);
@@ -1074,6 +1085,11 @@ void i40e_nvmupd_check_wait_event(struct i40e_hw *hw, u16 opcode)
 		}
 		hw->nvm_wait_opcode = 0;
 
+		if (hw->aq.arq_last_status) {
+			hw->nvmupd_state = I40E_NVMUPD_STATE_ERROR;
+			return;
+		}
+
 		switch (hw->nvmupd_state) {
 		case I40E_NVMUPD_STATE_INIT_WAIT:
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index bd5f13b..d9a2660 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -366,6 +366,7 @@ enum i40e_nvmupd_state {
 	I40E_NVMUPD_STATE_WRITING,
 	I40E_NVMUPD_STATE_INIT_WAIT,
 	I40E_NVMUPD_STATE_WRITE_WAIT,
+	I40E_NVMUPD_STATE_ERROR
 };
 
 /* nvm_access definition and its masks/shifts need to be accessible to
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 44f7ed7..9638515 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -912,11 +912,11 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 	desc = I40E_ADMINQ_DESC(hw->aq.arq, ntc);
 	desc_idx = ntc;
 
+	hw->aq.arq_last_status =
+		(enum i40e_admin_queue_err)le16_to_cpu(desc->retval);
 	flags = le16_to_cpu(desc->flags);
 	if (flags & I40E_AQ_FLAG_ERR) {
 		ret_code = I40E_ERR_ADMIN_QUEUE_ERROR;
-		hw->aq.arq_last_status =
-			(enum i40e_admin_queue_err)le16_to_cpu(desc->retval);
 		i40e_debug(hw,
 			   I40E_DEBUG_AQ_MESSAGE,
 			   "AQRX: Event received with error 0x%X.\n",
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 97f96e0..ca7afe5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -348,6 +348,7 @@ enum i40e_nvmupd_state {
 	I40E_NVMUPD_STATE_WRITING,
 	I40E_NVMUPD_STATE_INIT_WAIT,
 	I40E_NVMUPD_STATE_WRITE_WAIT,
+	I40E_NVMUPD_STATE_ERROR
 };
 
 /* nvm_access definition and its masks/shifts need to be accessible to
-- 
2.7.4
