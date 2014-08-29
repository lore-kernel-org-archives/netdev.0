From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: make warning less verbose
Date: Fri, 29 Aug 2014 02:30:11 -0700
Message-ID: <1409304620-23251-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbaH2Ja0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:26 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver is un-necessarily printing a warning that is only marginally
useful to the user.  Make the warning only print if extended driver
string printing is enabled, other messages related to a reset event
will still continue to print.

Change-ID: I5e8beca6516a2f176cd2e72b0ac2b3b909e6c953
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2fccd06..55a31ab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6148,9 +6148,9 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 				I40E_GL_MDET_TX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK) >>
 				I40E_GL_MDET_TX_QUEUE_SHIFT;
-		dev_info(&pf->pdev->dev,
-			 "Malicious Driver Detection event 0x%02x on TX queue %d pf number 0x%02x vf number 0x%02x\n",
-			 event, queue, pf_num, vf_num);
+		if (netif_msg_tx_err(pf))
+			dev_info(&pf->pdev->dev, "Malicious Driver Detection event 0x%02x on TX queue %d pf number 0x%02x vf number 0x%02x\n",
+				 event, queue, pf_num, vf_num);
 		wr32(hw, I40E_GL_MDET_TX, 0xffffffff);
 		mdd_detected = true;
 	}
@@ -6162,9 +6162,9 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 				I40E_GL_MDET_RX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK) >>
 				I40E_GL_MDET_RX_QUEUE_SHIFT;
-		dev_info(&pf->pdev->dev,
-			 "Malicious Driver Detection event 0x%02x on RX queue %d of function 0x%02x\n",
-			 event, queue, func);
+		if (netif_msg_rx_err(pf))
+			dev_info(&pf->pdev->dev, "Malicious Driver Detection event 0x%02x on RX queue %d of function 0x%02x\n",
+				 event, queue, func);
 		wr32(hw, I40E_GL_MDET_RX, 0xffffffff);
 		mdd_detected = true;
 	}
@@ -6173,17 +6173,13 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 		reg = rd32(hw, I40E_PF_MDET_TX);
 		if (reg & I40E_PF_MDET_TX_VALID_MASK) {
 			wr32(hw, I40E_PF_MDET_TX, 0xFFFF);
-			dev_info(&pf->pdev->dev,
-				 "MDD TX event is for this function 0x%08x, requesting PF reset.\n",
-				 reg);
+			dev_info(&pf->pdev->dev, "TX driver issue detected, PF reset issued\n");
 			pf_mdd_detected = true;
 		}
 		reg = rd32(hw, I40E_PF_MDET_RX);
 		if (reg & I40E_PF_MDET_RX_VALID_MASK) {
 			wr32(hw, I40E_PF_MDET_RX, 0xFFFF);
-			dev_info(&pf->pdev->dev,
-				 "MDD RX event is for this function 0x%08x, requesting PF reset.\n",
-				 reg);
+			dev_info(&pf->pdev->dev, "RX driver issue detected, PF reset issued\n");
 			pf_mdd_detected = true;
 		}
 		/* Queue belongs to the PF, initiate a reset */
@@ -6200,14 +6196,16 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 		if (reg & I40E_VP_MDET_TX_VALID_MASK) {
 			wr32(hw, I40E_VP_MDET_TX(i), 0xFFFF);
 			vf->num_mdd_events++;
-			dev_info(&pf->pdev->dev, "MDD TX event on VF %d\n", i);
+			dev_info(&pf->pdev->dev, "TX driver issue detected on VF %d\n",
+				 i);
 		}
 
 		reg = rd32(hw, I40E_VP_MDET_RX(i));
 		if (reg & I40E_VP_MDET_RX_VALID_MASK) {
 			wr32(hw, I40E_VP_MDET_RX(i), 0xFFFF);
 			vf->num_mdd_events++;
-			dev_info(&pf->pdev->dev, "MDD RX event on VF %d\n", i);
+			dev_info(&pf->pdev->dev, "RX driver issue detected on VF %d\n",
+				 i);
 		}
 
 		if (vf->num_mdd_events > I40E_DEFAULT_NUM_MDD_EVENTS_ALLOWED) {
-- 
1.9.3
