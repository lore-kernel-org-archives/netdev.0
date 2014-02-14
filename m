From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 12/14] i40e: tighten up ring enable/disable flow
Date: Fri, 14 Feb 2014 14:58:06 -0800
Message-ID: <1392418688-23895-13-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23819 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbaBNXB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:27 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Change the do/while to a for loop, so we don't hit the delay each
time, even when the register is ready for action.
Don't bother to set or clear the QENA_STAT bit as it is
read-only.

Change-ID: Ie464718804dd79f6d726f291caa9b0c872b49978
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 32 ++++++++++++++---------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 628e917..4a19073 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3108,13 +3108,13 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 
 	pf_q = vsi->base_queue;
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
-		j = 1000;
-		do {
-			usleep_range(1000, 2000);
+		for (j = 0; j < 50; j++) {
 			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
-		} while (j-- && ((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT)
-			       ^ (tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
-
+			if (((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT) & 1) ==
+			    ((tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT) & 1))
+				break;
+			usleep_range(1000, 2000);
+		}
 		/* Skip if the queue is already in the requested state */
 		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
 			continue;
@@ -3124,8 +3124,7 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		/* turn on/off the queue */
 		if (enable) {
 			wr32(hw, I40E_QTX_HEAD(pf_q), 0);
-			tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK |
-				  I40E_QTX_ENA_QENA_STAT_MASK;
+			tx_reg |= I40E_QTX_ENA_QENA_REQ_MASK;
 		} else {
 			tx_reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
 		}
@@ -3172,12 +3171,13 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 
 	pf_q = vsi->base_queue;
 	for (i = 0; i < vsi->num_queue_pairs; i++, pf_q++) {
-		j = 1000;
-		do {
-			usleep_range(1000, 2000);
+		for (j = 0; j < 50; j++) {
 			rx_reg = rd32(hw, I40E_QRX_ENA(pf_q));
-		} while (j-- && ((rx_reg >> I40E_QRX_ENA_QENA_REQ_SHIFT)
-			       ^ (rx_reg >> I40E_QRX_ENA_QENA_STAT_SHIFT)) & 1);
+			if (((rx_reg >> I40E_QRX_ENA_QENA_REQ_SHIFT) & 1) ==
+			    ((rx_reg >> I40E_QRX_ENA_QENA_STAT_SHIFT) & 1))
+				break;
+			usleep_range(1000, 2000);
+		}
 
 		if (enable) {
 			/* is STAT set ? */
@@ -3191,11 +3191,9 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 
 		/* turn on/off the queue */
 		if (enable)
-			rx_reg |= I40E_QRX_ENA_QENA_REQ_MASK |
-				  I40E_QRX_ENA_QENA_STAT_MASK;
+			rx_reg |= I40E_QRX_ENA_QENA_REQ_MASK;
 		else
-			rx_reg &= ~(I40E_QRX_ENA_QENA_REQ_MASK |
-				  I40E_QRX_ENA_QENA_STAT_MASK);
+			rx_reg &= ~I40E_QRX_ENA_QENA_REQ_MASK;
 		wr32(hw, I40E_QRX_ENA(pf_q), rx_reg);
 
 		/* wait for the change to finish */
-- 
1.8.5.GIT
