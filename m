From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] i40e/i40evf: fix accidental write to ITR registers
Date: Mon,  9 Mar 2015 10:55:37 -0700
Message-ID: <1425923742-4488-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5904 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416AbbCIRzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:46 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Fix a bug introduced in the force writeback code, where the interrupt
rate was set to 0 (maximum) by accident.

The driver must correctly set the NOITR fields to avoid ITR update
as a side effect of triggering the software interrupt.

Change-ID: I290851ae04ef3811c43aab5ee33242029f26c1a3
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 +++
 3 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f5a50b9..6beab94 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -859,6 +859,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 static void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 {
 	u32 val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
+		  I40E_PFINT_DYN_CTLN_ITR_INDX_MASK | /* set noitr */
 		  I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK |
 		  I40E_PFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK;
 		  /* allow 00 to be written to the index */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d9f3db5..f41da5d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -371,6 +371,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 static void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 {
 	u32 val = I40E_VFINT_DYN_CTLN_INTENA_MASK |
+		  I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK | /* set noitr */
 		  I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
 		  I40E_VFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK;
 		  /* allow 00 to be written to the index */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 32d0a99..5ac777b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -244,6 +244,7 @@ void i40evf_irq_enable_queues(struct i40evf_adapter *adapter, u32 mask)
 		if (mask & (1 << (i - 1))) {
 			wr32(hw, I40E_VFINT_DYN_CTLN1(i - 1),
 			     I40E_VFINT_DYN_CTLN1_INTENA_MASK |
+			     I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK |
 			     I40E_VFINT_DYN_CTLN_CLEARPBA_MASK);
 		}
 	}
@@ -263,6 +264,7 @@ static void i40evf_fire_sw_int(struct i40evf_adapter *adapter, u32 mask)
 	if (mask & 1) {
 		dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTL01);
 		dyn_ctl |= I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
+			   I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK |
 			   I40E_VFINT_DYN_CTLN_CLEARPBA_MASK;
 		wr32(hw, I40E_VFINT_DYN_CTL01, dyn_ctl);
 	}
@@ -270,6 +272,7 @@ static void i40evf_fire_sw_int(struct i40evf_adapter *adapter, u32 mask)
 		if (mask & (1 << i)) {
 			dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTLN1(i - 1));
 			dyn_ctl |= I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
+				   I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK |
 				   I40E_VFINT_DYN_CTLN_CLEARPBA_MASK;
 			wr32(hw, I40E_VFINT_DYN_CTLN1(i - 1), dyn_ctl);
 		}
-- 
1.9.3
