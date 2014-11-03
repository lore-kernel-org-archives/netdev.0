From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] i40e: properly parse MDET registers
Date: Mon,  3 Nov 2014 06:56:39 -0800
Message-ID: <1415026599-16232-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44881 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbaKCO44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:56 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Fix a few problems with our parsing of the MDET registers:
* Queue IDs are longer than 8 bits
* Queue IDs are absolute for the device and the base queue must be
  subtracted out.
* VF IDs are longer than 8 bits
* Use the MASK define to mask the event value, instead of the SHIFT
  define.

Change-ID: I3dc7237f480c02e1192a2a8ea782f8a02ab2a8b7
Reported-by: Marc Neustadter <marc.neustadter@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1b0c437..1a98e23 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6174,12 +6174,13 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 	if (reg & I40E_GL_MDET_TX_VALID_MASK) {
 		u8 pf_num = (reg & I40E_GL_MDET_TX_PF_NUM_MASK) >>
 				I40E_GL_MDET_TX_PF_NUM_SHIFT;
-		u8 vf_num = (reg & I40E_GL_MDET_TX_VF_NUM_MASK) >>
+		u16 vf_num = (reg & I40E_GL_MDET_TX_VF_NUM_MASK) >>
 				I40E_GL_MDET_TX_VF_NUM_SHIFT;
 		u8 event = (reg & I40E_GL_MDET_TX_EVENT_MASK) >>
 				I40E_GL_MDET_TX_EVENT_SHIFT;
-		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK) >>
-				I40E_GL_MDET_TX_QUEUE_SHIFT;
+		u16 queue = ((reg & I40E_GL_MDET_TX_QUEUE_MASK) >>
+				I40E_GL_MDET_TX_QUEUE_SHIFT) -
+				pf->hw.func_caps.base_queue;
 		if (netif_msg_tx_err(pf))
 			dev_info(&pf->pdev->dev, "Malicious Driver Detection event 0x%02x on TX queue %d pf number 0x%02x vf number 0x%02x\n",
 				 event, queue, pf_num, vf_num);
@@ -6192,8 +6193,9 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 				I40E_GL_MDET_RX_FUNCTION_SHIFT;
 		u8 event = (reg & I40E_GL_MDET_RX_EVENT_MASK) >>
 				I40E_GL_MDET_RX_EVENT_SHIFT;
-		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK) >>
-				I40E_GL_MDET_RX_QUEUE_SHIFT;
+		u16 queue = ((reg & I40E_GL_MDET_RX_QUEUE_MASK) >>
+				I40E_GL_MDET_RX_QUEUE_SHIFT) -
+				pf->hw.func_caps.base_queue;
 		if (netif_msg_rx_err(pf))
 			dev_info(&pf->pdev->dev, "Malicious Driver Detection event 0x%02x on RX queue %d of function 0x%02x\n",
 				 event, queue, func);
-- 
1.9.3
