From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e: only enable PTP interrupt cause if PTP is enabled
Date: Thu, 15 Jan 2015 04:19:19 -0800
Message-ID: <1421324368-6860-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696AbbAOMTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:34 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We should not blindly enable the PTP interrupt flags for all PFs. We
should only enable the PTP interrupt in PFs which have enabled
PTP.

Change-ID: I051a17cae4c199a2f3cf7852266e27eda6630525
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c3a353d..0cc0266 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2819,8 +2819,9 @@ static void i40e_vsi_configure_msix(struct i40e_vsi *vsi)
  * i40e_enable_misc_int_causes - enable the non-queue interrupts
  * @hw: ptr to the hardware info
  **/
-static void i40e_enable_misc_int_causes(struct i40e_hw *hw)
+static void i40e_enable_misc_int_causes(struct i40e_pf *pf)
 {
+	struct i40e_hw *hw = &pf->hw;
 	u32 val;
 
 	/* clear things first */
@@ -2832,11 +2833,13 @@ static void i40e_enable_misc_int_causes(struct i40e_hw *hw)
 	      I40E_PFINT_ICR0_ENA_GRST_MASK          |
 	      I40E_PFINT_ICR0_ENA_PCI_EXCEPTION_MASK |
 	      I40E_PFINT_ICR0_ENA_GPIO_MASK          |
-	      I40E_PFINT_ICR0_ENA_TIMESYNC_MASK      |
 	      I40E_PFINT_ICR0_ENA_HMC_ERR_MASK       |
 	      I40E_PFINT_ICR0_ENA_VFLR_MASK          |
 	      I40E_PFINT_ICR0_ENA_ADMINQ_MASK;
 
+	if (pf->flags & I40E_FLAG_PTP)
+		val |= I40E_PFINT_ICR0_ENA_TIMESYNC_MASK;
+
 	wr32(hw, I40E_PFINT_ICR0_ENA, val);
 
 	/* SW_ITR_IDX = 0, but don't change INTENA */
@@ -2866,7 +2869,7 @@ static void i40e_configure_msi_and_legacy(struct i40e_vsi *vsi)
 	q_vector->tx.latency_range = I40E_LOW_LATENCY;
 	wr32(hw, I40E_PFINT_ITR0(I40E_TX_ITR), q_vector->tx.itr);
 
-	i40e_enable_misc_int_causes(hw);
+	i40e_enable_misc_int_causes(pf);
 
 	/* FIRSTQ_INDX = 0, FIRSTQ_TYPE = 0 (rx) */
 	wr32(hw, I40E_PFINT_LNKLST0, 0);
@@ -7137,7 +7140,7 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 		}
 	}
 
-	i40e_enable_misc_int_causes(hw);
+	i40e_enable_misc_int_causes(pf);
 
 	/* associate no queues to the misc vector */
 	wr32(hw, I40E_PFINT_LNKLST0, I40E_QUEUE_END_OF_LIST);
-- 
1.9.3
