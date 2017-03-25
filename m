From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] i40e: Drop FCoE code that always evaluates to false or 0
Date: Sat, 25 Mar 2017 01:13:03 -0700
Message-ID: <20170325081305.31835-10-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:13298 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751111AbdCYINL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:11 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since FCoE isn't supported by the i40e products there isn't much point in
carrying around code that will always evaluate to false. This patch goes
through and strips out the code in several spots so that we don't go around
carrying variables and/or code that is always going to evaluate to false or
0.

Change-ID: I39d1d779c66c638b75525839db2b6208fdc809d7
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  3 ---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 17 +++--------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  1 -
 3 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ee298adbb6db..d7e84f99eb2d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -502,9 +502,6 @@ struct i40e_pf {
 	 */
 	u16 dcbx_cap;
 
-	u32 fcoe_hmc_filt_num;
-	u32 fcoe_hmc_cntx_num;
-
 	struct i40e_filter_control_settings filter_settings;
 
 	struct ptp_clock *ptp_clock;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f4258ec3a68c..781edfc86baf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4371,14 +4371,6 @@ static void i40e_quiesce_vsi(struct i40e_vsi *vsi)
 	if (test_bit(__I40E_DOWN, &vsi->state))
 		return;
 
-	/* No need to disable FCoE VSI when Tx suspended */
-	if ((test_bit(__I40E_PORT_TX_SUSPENDED, &vsi->back->state)) &&
-	    vsi->type == I40E_VSI_FCOE) {
-		dev_dbg(&vsi->back->pdev->dev,
-			 "VSI seid %d skipping FCoE VSI disable\n", vsi->seid);
-		return;
-	}
-
 	set_bit(__I40E_NEEDS_RESTART, &vsi->state);
 	if (vsi->netdev && netif_running(vsi->netdev))
 		vsi->netdev->netdev_ops->ndo_stop(vsi->netdev);
@@ -4481,8 +4473,7 @@ static int i40e_pf_wait_queues_disabled(struct i40e_pf *pf)
 	int v, ret = 0;
 
 	for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
-		/* No need to wait for FCoE VSI queues */
-		if (pf->vsi[v] && pf->vsi[v]->type != I40E_VSI_FCOE) {
+		if (pf->vsi[v]) {
 			ret = i40e_vsi_wait_queues_disabled(pf->vsi[v]);
 			if (ret)
 				break;
@@ -6970,8 +6961,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 		goto end_core_reset;
 
 	ret = i40e_init_lan_hmc(hw, hw->func_caps.num_tx_qp,
-				hw->func_caps.num_rx_qp,
-				pf->fcoe_hmc_cntx_num, pf->fcoe_hmc_filt_num);
+				hw->func_caps.num_rx_qp, 0, 0);
 	if (ret) {
 		dev_info(&pf->pdev->dev, "init_lan_hmc failed: %d\n", ret);
 		goto end_core_reset;
@@ -11016,8 +11006,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	err = i40e_init_lan_hmc(hw, hw->func_caps.num_tx_qp,
-				hw->func_caps.num_rx_qp,
-				pf->fcoe_hmc_cntx_num, pf->fcoe_hmc_filt_num);
+				hw->func_caps.num_rx_qp, 0, 0);
 	if (err) {
 		dev_info(&pdev->dev, "init_lan_hmc failed: %d\n", err);
 		goto err_init_lan_hmc;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 4012d069939a..37af437daa5d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -87,7 +87,6 @@ struct i40e_vf {
 	u16 stag;
 
 	struct i40e_virtchnl_ether_addr default_lan_addr;
-	struct i40e_virtchnl_ether_addr default_fcoe_addr;
 	u16 port_vlan_id;
 	bool pf_set_mac;	/* The VMM admin set the VF MAC address */
 	bool trusted;
-- 
2.12.0
