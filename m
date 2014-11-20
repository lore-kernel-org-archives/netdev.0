From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/15] i40e: don't overload fields
Date: Thu, 20 Nov 2014 15:09:08 -0800
Message-ID: <1416524953-15161-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55349 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757639AbaKTXJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:21 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Overloading the msg_size field in the arq_event_info struct is just a
bad idea. It leads to repeated bugs when the structure is used in a
loop, since the input value (buffer size) is overwritten by the output
value (actual message length).

Fix this by splitting the field into two and renaming to indicate the
actual function of each field.

Since the arq_event struct has now changed, we need to change the drivers
to support this. Note that we no longer need to initialize the buffer size
each time we go through a loop as this value is no longer destroyed by
arq processing.

In the process, we also fix a bug in i40evf_verify_api_ver where the
buffer size was not correctly reinitialized each time through the loop.

Change-ID: Ic7f9633cdd6f871f93e698dfb095e29c696f5581
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Ashish Shah <ashish.n.shah@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c       |  6 +++---
 drivers/net/ethernet/intel/i40e/i40e_adminq.h       |  3 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c         |  7 +++----
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c     |  6 +++---
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h     |  3 ++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     |  7 +++----
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 11 +++++------
 7 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index f7f6206..5bb4914 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -980,10 +980,10 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 
 	e->desc = *desc;
 	datalen = le16_to_cpu(desc->datalen);
-	e->msg_size = min(datalen, e->msg_size);
-	if (e->msg_buf != NULL && (e->msg_size != 0))
+	e->msg_len = min(datalen, e->buf_len);
+	if (e->msg_buf != NULL && (e->msg_len != 0))
 		memcpy(e->msg_buf, hw->aq.arq.r.arq_bi[desc_idx].va,
-		       e->msg_size);
+		       e->msg_len);
 
 	i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE, "AQRX: desc and buffer:\n");
 	i40e_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc, e->msg_buf,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index df0bd09..003a227 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -76,7 +76,8 @@ struct i40e_asq_cmd_details {
 /* ARQ event information */
 struct i40e_arq_event_info {
 	struct i40e_aq_desc desc;
-	u16 msg_size;
+	u16 msg_len;
+	u16 buf_len;
 	u8 *msg_buf;
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c998d82..3ebab03 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5750,13 +5750,12 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	if (oldval != val)
 		wr32(&pf->hw, pf->hw.aq.asq.len, val);
 
-	event.msg_size = I40E_MAX_AQ_BUF_SIZE;
-	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
+	event.buf_len = I40E_MAX_AQ_BUF_SIZE;
+	event.msg_buf = kzalloc(event.buf_len, GFP_KERNEL);
 	if (!event.msg_buf)
 		return;
 
 	do {
-		event.msg_size = I40E_MAX_AQ_BUF_SIZE; /* reinit each time */
 		ret = i40e_clean_arq_element(hw, &event, &pending);
 		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK)
 			break;
@@ -5777,7 +5776,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 					le32_to_cpu(event.desc.cookie_high),
 					le32_to_cpu(event.desc.cookie_low),
 					event.msg_buf,
-					event.msg_size);
+					event.msg_len);
 			break;
 		case i40e_aqc_opc_lldp_update_mib:
 			dev_dbg(&pf->pdev->dev, "ARQ: Update LLDP MIB event received\n");
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 500ca21..d7e446f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -929,10 +929,10 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 
 	e->desc = *desc;
 	datalen = le16_to_cpu(desc->datalen);
-	e->msg_size = min(datalen, e->msg_size);
-	if (e->msg_buf != NULL && (e->msg_size != 0))
+	e->msg_len = min(datalen, e->buf_len);
+	if (e->msg_buf != NULL && (e->msg_len != 0))
 		memcpy(e->msg_buf, hw->aq.arq.r.arq_bi[desc_idx].va,
-		       e->msg_size);
+		       e->msg_len);
 
 	if (i40e_is_nvm_update_op(&e->desc))
 		hw->aq.nvm_busy = false;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index f40cfac..0d58378 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -76,7 +76,8 @@ struct i40e_asq_cmd_details {
 /* ARQ event information */
 struct i40e_arq_event_info {
 	struct i40e_aq_desc desc;
-	u16 msg_size;
+	u16 msg_len;
+	u16 buf_len;
 	u8 *msg_buf;
 };
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4892278..d378e13 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1632,8 +1632,8 @@ static void i40evf_adminq_task(struct work_struct *work)
 	if (adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED)
 		return;
 
-	event.msg_size = I40EVF_MAX_AQ_BUF_SIZE;
-	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
+	event.buf_len = I40EVF_MAX_AQ_BUF_SIZE;
+	event.msg_buf = kzalloc(event.buf_len, GFP_KERNEL);
 	if (!event.msg_buf)
 		return;
 
@@ -1645,10 +1645,9 @@ static void i40evf_adminq_task(struct work_struct *work)
 
 		i40evf_virtchnl_completion(adapter, v_msg->v_opcode,
 					   v_msg->v_retval, event.msg_buf,
-					   event.msg_size);
+					   event.msg_len);
 		if (pending != 0) {
 			memset(event.msg_buf, 0, I40EVF_MAX_AQ_BUF_SIZE);
-			event.msg_size = I40EVF_MAX_AQ_BUF_SIZE;
 		}
 	} while (pending);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 49bfdb5..422dd2d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -92,8 +92,8 @@ int i40evf_verify_api_ver(struct i40evf_adapter *adapter)
 	enum i40e_virtchnl_ops op;
 	i40e_status err;
 
-	event.msg_size = I40EVF_MAX_AQ_BUF_SIZE;
-	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
+	event.buf_len = I40EVF_MAX_AQ_BUF_SIZE;
+	event.msg_buf = kzalloc(event.buf_len, GFP_KERNEL);
 	if (!event.msg_buf) {
 		err = -ENOMEM;
 		goto out;
@@ -169,15 +169,14 @@ int i40evf_get_vf_config(struct i40evf_adapter *adapter)
 
 	len =  sizeof(struct i40e_virtchnl_vf_resource) +
 		I40E_MAX_VF_VSI * sizeof(struct i40e_virtchnl_vsi_resource);
-	event.msg_size = len;
-	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
+	event.buf_len = len;
+	event.msg_buf = kzalloc(event.buf_len, GFP_KERNEL);
 	if (!event.msg_buf) {
 		err = -ENOMEM;
 		goto out;
 	}
 
 	while (1) {
-		event.msg_size = len;
 		/* When the AQ is empty, i40evf_clean_arq_element will return
 		 * nonzero and this loop will terminate.
 		 */
@@ -191,7 +190,7 @@ int i40evf_get_vf_config(struct i40evf_adapter *adapter)
 	}
 
 	err = (i40e_status)le32_to_cpu(event.desc.cookie_low);
-	memcpy(adapter->vf_res, event.msg_buf, min(event.msg_size, len));
+	memcpy(adapter->vf_res, event.msg_buf, min(event.msg_len, len));
 
 	i40e_vf_parse_hw_config(hw, adapter->vf_res);
 out_alloc:
-- 
1.9.3
