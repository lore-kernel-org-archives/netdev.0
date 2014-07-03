From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: tolerate lost interrupts
Date: Wed,  2 Jul 2014 19:40:23 -0700
Message-ID: <1404355233-30123-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56267 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbaGCClK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:10 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the AQ interrupt gets lost for some reason, VF communications will
stall as the VFs have no way of reaching the PF, which is essentially
deaf. The VFs end up waiting forever for a reply that will never come.

To alleviate this condition, go ahead and check the ARQ every time we
run the service task. Remove the check for a pending event, and get rid
of a chatty error message that is now meaningless.

Change-ID: I0fc9d18169cd45c98f60188aef872cd6cee9a027
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 440b671..88704c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5314,9 +5314,6 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	u32 oldval;
 	u32 val;
 
-	if (!test_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state))
-		return;
-
 	/* check for error indications */
 	val = rd32(&pf->hw, pf->hw.aq.arq.len);
 	oldval = val;
@@ -5360,10 +5357,9 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	do {
 		event.msg_size = I40E_MAX_AQ_BUF_SIZE; /* reinit each time */
 		ret = i40e_clean_arq_element(hw, &event, &pending);
-		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
-			dev_info(&pf->pdev->dev, "No ARQ event found\n");
+		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK)
 			break;
-		} else if (ret) {
+		else if (ret) {
 			dev_info(&pf->pdev->dev, "ARQ event error %d\n", ret);
 			break;
 		}
-- 
1.9.3
