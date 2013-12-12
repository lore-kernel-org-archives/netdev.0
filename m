From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: init flow control settings to disabled
Date: Thu, 12 Dec 2013 04:40:42 -0800
Message-ID: <1386852051-27907-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26106 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab3LLMlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 07:41:01 -0500
In-Reply-To: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Refactor flow control set up and disable L2 flow
control by default.

Change-Id: I2fe257b80df6d9a1e37deb4df118da8f8467040d
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 +++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 59 +++++++++++++++++++++++---
 2 files changed, 60 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9c380a8..fcb6def 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -276,12 +276,14 @@ static void i40e_get_pauseparam(struct net_device *netdev,
 		((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
 		  AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	pause->rx_pause = 0;
-	pause->tx_pause = 0;
-	if (hw_link_info->an_info & I40E_AQ_LINK_PAUSE_RX)
+	if (hw->fc.current_mode == I40E_FC_RX_PAUSE) {
 		pause->rx_pause = 1;
-	if (hw_link_info->an_info & I40E_AQ_LINK_PAUSE_TX)
+	} else if (hw->fc.current_mode == I40E_FC_TX_PAUSE) {
 		pause->tx_pause = 1;
+	} else if (hw->fc.current_mode == I40E_FC_FULL) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
+	}
 }
 
 static u32 i40e_get_msglevel(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ea9ef27..02873dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6924,6 +6924,7 @@ int i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
  **/
 static int i40e_setup_pf_switch(struct i40e_pf *pf)
 {
+	u32 rxfc, txfc, rxfc_reg;
 	int ret;
 
 	/* find out what's out there already */
@@ -6994,20 +6995,65 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf)
 	i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
 	i40e_link_event(pf);
 
-	/* Initialize user-specifics link properties */
+	/* Initialize user-specific link properties */
 	pf->fc_autoneg_status = ((pf->hw.phy.link_info.an_info &
 				  I40E_AQ_AN_COMPLETED) ? true : false);
-	pf->hw.fc.requested_mode = I40E_FC_DEFAULT;
-	if (pf->hw.phy.link_info.an_info &
-	   (I40E_AQ_LINK_PAUSE_TX | I40E_AQ_LINK_PAUSE_RX))
+	/* requested_mode is set in probe or by ethtool */
+	if (!pf->fc_autoneg_status)
+		goto no_autoneg;
+
+	if ((pf->hw.phy.link_info.an_info & I40E_AQ_LINK_PAUSE_TX) &&
+	    (pf->hw.phy.link_info.an_info & I40E_AQ_LINK_PAUSE_RX))
 		pf->hw.fc.current_mode = I40E_FC_FULL;
 	else if (pf->hw.phy.link_info.an_info & I40E_AQ_LINK_PAUSE_TX)
 		pf->hw.fc.current_mode = I40E_FC_TX_PAUSE;
 	else if (pf->hw.phy.link_info.an_info & I40E_AQ_LINK_PAUSE_RX)
 		pf->hw.fc.current_mode = I40E_FC_RX_PAUSE;
 	else
-		pf->hw.fc.current_mode = I40E_FC_DEFAULT;
+		pf->hw.fc.current_mode = I40E_FC_NONE;
+
+	/* sync the flow control settings with the auto-neg values */
+	switch (pf->hw.fc.current_mode) {
+	case I40E_FC_FULL:
+		txfc = 1;
+		rxfc = 1;
+		break;
+	case I40E_FC_TX_PAUSE:
+		txfc = 1;
+		rxfc = 0;
+		break;
+	case I40E_FC_RX_PAUSE:
+		txfc = 0;
+		rxfc = 1;
+		break;
+	case I40E_FC_NONE:
+	case I40E_FC_DEFAULT:
+		txfc = 0;
+		rxfc = 0;
+		break;
+	case I40E_FC_PFC:
+		/* TBD */
+		break;
+	/* no default case, we have to handle all possibilities here */
+	}
+
+	wr32(&pf->hw, I40E_PRTDCB_FCCFG, txfc << I40E_PRTDCB_FCCFG_TFCE_SHIFT);
+
+	rxfc_reg = rd32(&pf->hw, I40E_PRTDCB_MFLCN) &
+		   ~I40E_PRTDCB_MFLCN_RFCE_MASK;
+	rxfc_reg |= (rxfc << I40E_PRTDCB_MFLCN_RFCE_SHIFT);
+
+	wr32(&pf->hw, I40E_PRTDCB_MFLCN, rxfc_reg);
 
+	goto fc_complete;
+
+no_autoneg:
+	/* disable L2 flow control, user can turn it on if they wish */
+	wr32(&pf->hw, I40E_PRTDCB_FCCFG, 0);
+	wr32(&pf->hw, I40E_PRTDCB_MFLCN, rd32(&pf->hw, I40E_PRTDCB_MFLCN) &
+					 ~I40E_PRTDCB_MFLCN_RFCE_MASK);
+
+fc_complete:
 	return ret;
 }
 
@@ -7301,6 +7347,9 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_pf_reset;
 	}
 
+	/* set up a default setting for link flow control */
+	pf->hw.fc.requested_mode = I40E_FC_NONE;
+
 	err = i40e_init_adminq(hw);
 	dev_info(&pdev->dev, "%s\n", i40e_fw_version_str(hw));
 	if (((hw->nvm.version & I40E_NVM_VERSION_HI_MASK)
-- 
1.8.3.1
