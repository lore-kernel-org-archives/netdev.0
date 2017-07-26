From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40evf: Use le32_to_cpu before evaluating HW desc fields
Date: Wed, 26 Jul 2017 03:31:21 -0700
Message-ID: <20170726103123.76743-13-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56012 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751471AbdGZKgP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:36:15 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

i40e hardware descriptor fields are in little-endian format. Driver
must use le32_to_cpu while evaluating these fields otherwise on
big-endian arch we end up evaluating incorrect values, cause errors
like:
i40evf 0000:03:0a.0: Expected response 24 from PF, received 402653184
i40evf 0000:03:0a.1: Expected response 7 from PF, received 117440512

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7c213a347909..93536b9fc629 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1957,8 +1957,8 @@ static void i40evf_adminq_task(struct work_struct *work)
 		container_of(work, struct i40evf_adapter, adminq_task);
 	struct i40e_hw *hw = &adapter->hw;
 	struct i40e_arq_event_info event;
-	struct virtchnl_msg *v_msg;
-	i40e_status ret;
+	enum virtchnl_ops v_op;
+	i40e_status ret, v_ret;
 	u32 val, oldval;
 	u16 pending;
 
@@ -1970,15 +1970,15 @@ static void i40evf_adminq_task(struct work_struct *work)
 	if (!event.msg_buf)
 		goto out;
 
-	v_msg = (struct virtchnl_msg *)&event.desc;
 	do {
 		ret = i40evf_clean_arq_element(hw, &event, &pending);
-		if (ret || !v_msg->v_opcode)
+		v_op = (enum virtchnl_ops)le32_to_cpu(event.desc.cookie_high);
+		v_ret = (i40e_status)le32_to_cpu(event.desc.cookie_low);
+
+		if (ret || !v_op)
 			break; /* No event to process or error cleaning ARQ */
 
-		i40evf_virtchnl_completion(adapter, v_msg->v_opcode,
-					   (i40e_status)v_msg->v_retval,
-					   event.msg_buf,
+		i40evf_virtchnl_completion(adapter, v_op, v_ret, event.msg_buf,
 					   event.msg_len);
 		if (pending != 0)
 			memset(event.msg_buf, 0, I40EVF_MAX_AQ_BUF_SIZE);
-- 
2.13.3
