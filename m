From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/16] i40evf: make early init sequence even more robust
Date: Sat,  6 Dec 2014 05:02:06 -0800
Message-ID: <1417870933-17248-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671AbaLFNC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:59 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When multiple VFs attempt to initialize simultaneously, the firmware may
delay or drop messages. Make the init code more adept at handling these
situations by a) reinitializing the admin queue if the firmware fails to
process a request, and b) resending a request if the PF doesn't answer.

Once the request has been sent again, the PF might end up getting both
requests and send the configuration information to the driver twice.
This will cause the VF to complain about receiving an unexpected message
from the PF. Since this is not fatal, reduce the warning level of the
log messages that are generated in response to this event.

Change-ID: I9370a1a2fde2ad3934fa25ccfd0545edfbbb4805
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     |  9 +++++++--
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 16 +++++-----------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8e01009..62456f8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2045,6 +2045,8 @@ static void i40evf_init_task(struct work_struct *work)
 	case __I40EVF_INIT_VERSION_CHECK:
 		if (!i40evf_asq_done(hw)) {
 			dev_err(&pdev->dev, "Admin queue command never completed\n");
+			i40evf_shutdown_adminq(hw);
+			adapter->state = __I40EVF_STARTUP;
 			goto err;
 		}
 
@@ -2078,8 +2080,11 @@ static void i40evf_init_task(struct work_struct *work)
 				goto err;
 		}
 		err = i40evf_get_vf_config(adapter);
-		if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK)
-			goto restart;
+		if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
+			dev_info(&pdev->dev, "Resending VF config request\n");
+			err = i40evf_send_vf_config_msg(adapter);
+			goto err;
+		}
 		if (err) {
 			dev_err(&pdev->dev, "Unable to get VF config (%d)\n",
 				err);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 07c13b0..5fde5a7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -715,15 +715,9 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		}
 		return;
 	}
-	if (v_opcode != adapter->current_op) {
-		dev_err(&adapter->pdev->dev, "%s: Pending op is %d, received %d\n",
-			__func__, adapter->current_op, v_opcode);
-		/* We're probably completely screwed at this point, but clear
-		 * the current op and try to carry on....
-		 */
-		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
-		return;
-	}
+	if (v_opcode != adapter->current_op)
+		dev_info(&adapter->pdev->dev, "Pending op is %d, received %d\n",
+			 adapter->current_op, v_opcode);
 	if (v_retval) {
 		dev_err(&adapter->pdev->dev, "%s: PF returned error %d to our request %d\n",
 			__func__, v_retval, v_opcode);
@@ -775,8 +769,8 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_MAP_VECTORS);
 		break;
 	default:
-		dev_warn(&adapter->pdev->dev, "%s: Received unexpected message %d from PF\n",
-			 __func__, v_opcode);
+		dev_info(&adapter->pdev->dev, "Received unexpected message %d from PF\n",
+			 v_opcode);
 		break;
 	} /* switch v_opcode */
 	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
-- 
1.9.3
