From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] i40e/i40evf: don't trust VF to reset itself
Date: Fri, 13 Oct 2017 14:52:49 -0700
Message-ID: <20171013215249.61286-10-jeffrey.t.kirsher@intel.com>
References: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:20274 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752834AbdJMVxU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 17:53:20 -0400
In-Reply-To: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

When using 'ethtool -L' on a VF to change number of requested queues
from PF, we shouldn't trust the VF to reset itself after making the
request.  Doing it that way opens the door for a potentially malicious
VF to do nasty things to the PF which should never be the case.

This makes it such that after VF makes a successful request, PF will
then reset the VF to institute required changes.  Only if the request
fails will PF send a message back to VF letting it know the request was
unsuccessful.

Testing-hints:
There should be no real functional changes.  This is simply hardening
against a potentially malicious VF.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c  | 9 +++++++--
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 7 +++----
 include/linux/avf/virtchnl.h                        | 4 ++--
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ce0981e2f605..f8a794b72462 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2045,8 +2045,9 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
  * @msglen: msg length
  *
  * VFs get a default number of queues but can use this message to request a
- * different number.  Will respond with either the number requested or the
- * maximum we can support.
+ * different number.  If the request is successful, PF will reset the VF and
+ * return 0.  If unsuccessful, PF will send message informing VF of number of
+ * available queues and return result of sending VF a message.
  **/
 static int i40e_vc_request_queues_msg(struct i40e_vf *vf, u8 *msg, int msglen)
 {
@@ -2077,7 +2078,11 @@ static int i40e_vc_request_queues_msg(struct i40e_vf *vf, u8 *msg, int msglen)
 			 pf->queues_left);
 		vfres->num_queue_pairs = pf->queues_left + cur_pairs;
 	} else {
+		/* successful request */
 		vf->num_req_queues = req_pairs;
+		i40e_vc_notify_vf_reset(vf);
+		i40e_reset_vf(vf, false);
+		return 0;
 	}
 
 	return i40e_vc_send_msg_to_vf(vf, VIRTCHNL_OP_REQUEST_QUEUES, 0,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 2bb81c39d85f..46c8b8a3907c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -407,6 +407,7 @@ int i40evf_request_queues(struct i40evf_adapter *adapter, int num)
 	vfres.num_queue_pairs = num;
 
 	adapter->current_op = VIRTCHNL_OP_REQUEST_QUEUES;
+	adapter->flags |= I40EVF_FLAG_REINIT_ITR_NEEDED;
 	return i40evf_send_pf_msg(adapter, VIRTCHNL_OP_REQUEST_QUEUES,
 				  (u8 *)&vfres, sizeof(vfres));
 }
@@ -1098,15 +1099,13 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 	case VIRTCHNL_OP_REQUEST_QUEUES: {
 		struct virtchnl_vf_res_request *vfres =
 			(struct virtchnl_vf_res_request *)msg;
-		if (vfres->num_queue_pairs == adapter->num_req_queues) {
-			adapter->flags |= I40EVF_FLAG_REINIT_ITR_NEEDED;
-			i40evf_schedule_reset(adapter);
-		} else {
+		if (vfres->num_queue_pairs != adapter->num_req_queues) {
 			dev_info(&adapter->pdev->dev,
 				 "Requested %d queues, PF can support %d\n",
 				 adapter->num_req_queues,
 				 vfres->num_queue_pairs);
 			adapter->num_req_queues = 0;
+			adapter->flags &= ~I40EVF_FLAG_REINIT_ITR_NEEDED;
 		}
 		}
 		break;
diff --git a/include/linux/avf/virtchnl.h b/include/linux/avf/virtchnl.h
index 60e5d90cb18a..3ce61342fa31 100644
--- a/include/linux/avf/virtchnl.h
+++ b/include/linux/avf/virtchnl.h
@@ -333,8 +333,8 @@ struct virtchnl_vsi_queue_config_info {
  * additional queues must be negotiated.  This is a best effort request as it
  * is possible the PF does not have enough queues left to support the request.
  * If the PF cannot support the number requested it will respond with the
- * maximum number it is able to support; otherwise it will respond with the
- * number requested.
+ * maximum number it is able to support.  If the request is successful, PF will
+ * then reset the VF to institute required changes.
  */
 
 /* VF resource request */
-- 
2.14.2
