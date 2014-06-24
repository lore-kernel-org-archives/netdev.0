From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: Add PF reset when Malicious driver event for PF
Date: Mon, 23 Jun 2014 17:47:27 -0700
Message-ID: <1403570858-13548-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58402 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370AbaFXArn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 20:47:43 -0400
In-Reply-To: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

As per the spec when the PF driver receives a Malicious driver event
the queue that caused the event is already stopped and it is expected
that the function that owns the queue will reset the queue.
In some cases it may not be possible to determine the queue and it is
suggested to reset the whole function.

This patch takes the later approach when the event is owned by the PF
that owns it.

Change-ID: I40f9764a6a5e068c0ef8438db00c5aa9c2c6c1c8
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0a68065..b751258 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5828,6 +5828,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	bool mdd_detected = false;
+	bool pf_mdd_detected = false;
 	struct i40e_vf *vf;
 	u32 reg;
 	int i;
@@ -5867,6 +5868,30 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 		mdd_detected = true;
 	}
 
+	if (mdd_detected) {
+		reg = rd32(hw, I40E_PF_MDET_TX);
+		if (reg & I40E_PF_MDET_TX_VALID_MASK) {
+			wr32(hw, I40E_PF_MDET_TX, 0xFFFF);
+			dev_info(&pf->pdev->dev,
+				 "MDD TX event is for this function 0x%08x requesting PF reset.\n",
+				 reg);
+			pf_mdd_detected = true;
+		}
+		reg = rd32(hw, I40E_PF_MDET_RX);
+		if (reg & I40E_PF_MDET_RX_VALID_MASK) {
+			wr32(hw, I40E_PF_MDET_RX, 0xFFFF);
+			dev_info(&pf->pdev->dev,
+				 "MDD RX event is for this function 0x%08x requesting PF reset.\n",
+				 reg);
+			pf_mdd_detected = true;
+		}
+		/* Queue belongs to the PF initiate a reset */
+		if (pf_mdd_detected) {
+			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+			i40e_service_event_schedule(pf);
+		}
+	}
+
 	/* see if one of the VFs needs its hand slapped */
 	for (i = 0; i < pf->num_alloc_vfs && mdd_detected; i++) {
 		vf = &(pf->vf[i]);
-- 
1.9.3
