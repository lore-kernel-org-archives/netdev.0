From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/11] i40e: Do not disable/enable FCoE VSI with DCB reconfig
Date: Tue, 18 Nov 2014 01:25:29 -0800
Message-ID: <1416302731-11327-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11632 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbaKRJZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 04:25:58 -0500
In-Reply-To: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

FCoE VSI Tx queue disable times out when reconfiguring as a result of
DCB TC configuration change event.

The hardware allows us to skip disabling and enabling of Tx queues for
VSIs with single TC enabled. As FCoE VSI is configured to have only
single TC we skip it from disable/enable flow.

Change-ID: Ia73ff3df8785ba2aa3db91e6f2c9005e61ebaec2
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-By: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3e55cef..c3107dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3862,6 +3862,15 @@ static void i40e_quiesce_vsi(struct i40e_vsi *vsi)
 	if (test_bit(__I40E_DOWN, &vsi->state))
 		return;
 
+	/* No need to disable FCoE VSI when Tx suspended */
+	if ((test_bit(__I40E_PORT_TX_SUSPENDED, &vsi->back->state)) &&
+	    vsi->type == I40E_VSI_FCOE) {
+		dev_dbg(&vsi->back->pdev->dev,
+			"%s: VSI seid %d skipping FCoE VSI disable\n",
+			 __func__, vsi->seid);
+		return;
+	}
+
 	set_bit(__I40E_NEEDS_RESTART, &vsi->state);
 	if (vsi->netdev && netif_running(vsi->netdev)) {
 		vsi->netdev->netdev_ops->ndo_stop(vsi->netdev);
@@ -3953,7 +3962,8 @@ static int i40e_pf_wait_txq_disabled(struct i40e_pf *pf)
 	int v, ret = 0;
 
 	for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
-		if (pf->vsi[v]) {
+		/* No need to wait for FCoE VSI queues */
+		if (pf->vsi[v] && pf->vsi[v]->type != I40E_VSI_FCOE) {
 			ret = i40e_vsi_wait_txq_disabled(pf->vsi[v]);
 			if (ret)
 				break;
-- 
1.9.3
