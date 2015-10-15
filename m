From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] i40e: reset the invalid msg counter in vf when a valid msg is received
Date: Thu, 15 Oct 2015 14:43:19 -0700
Message-ID: <1444945404-30654-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jingjing Wu <jingjing.wu@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4493 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbbJOVnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 17:43:32 -0400
In-Reply-To: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingjing Wu <jingjing.wu@intel.com>

When the number of invalid messages from a VF is exceeded, the VF
will be disabled, due to the invalid messages.  This happens if
other VF drivers (like DPDK) send a message through the driver's
mailbox (aka virtchannel) interface, but the message is not
supported by the i40e pf driver, such as CONFIG_PROMISCUOUS_MODE.

This patch changes the num_invalid_msgs in struct i40e_vf to record
the continuous invalid msgs, and it will be reset when a valid msg
is received.

Change-ID: Iaec42fd3dcdd281476b3518be23261dd46fc3718
Signed-off-by: Jingjing Wu <jingjing.wu@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index fd99cd2..a35a204 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1102,6 +1102,8 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 		}
 	} else {
 		vf->num_valid_msgs++;
+		/* reset the invalid counter, if a valid message is received. */
+		vf->num_invalid_msgs = 0;
 	}
 
 	aq_ret = i40e_aq_send_msg_to_vf(hw, abs_vf_id,	v_opcode, v_retval,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 7fe94e8..da44995 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -96,7 +96,8 @@ struct i40e_vf {
 
 	u8 num_queue_pairs;	/* num of qps assigned to VF vsis */
 	u64 num_mdd_events;	/* num of mdd events detected */
-	u64 num_invalid_msgs;	/* num of malformed or invalid msgs detected */
+	/* num of continuous malformed or invalid msgs detected */
+	u64 num_invalid_msgs;
 	u64 num_valid_msgs;	/* num of valid msgs detected */
 
 	unsigned long vf_caps;	/* vf's adv. capabilities */
-- 
2.4.3
