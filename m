From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/5] i40e: change log messages and error returns
Date: Fri,  8 Jan 2016 02:14:39 -0800
Message-ID: <1452248083-78628-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48697 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbcAHKOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 05:14:55 -0500
In-Reply-To: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When VFs are being reset, there is a brief window of time when they
cannot be configured because they don't have a VSI to configure. If
a script is quick, it can fall through that window. To avoid
defenestration, log a useful error message and return -EAGAIN.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 27 ++++++++++++++--------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index aa58a49..b8deb50 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2078,9 +2078,9 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev,
-			"Uninitialized VF %d\n", vf_id);
-		ret = -EINVAL;
+		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
+			vf_id);
+		ret = -EAGAIN;
 		goto error_param;
 	}
 
@@ -2162,8 +2162,9 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev, "Uninitialized VF %d\n", vf_id);
-		ret = -EINVAL;
+		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
+			vf_id);
+		ret = -EAGAIN;
 		goto error_pvid;
 	}
 
@@ -2282,8 +2283,9 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev, "Uninitialized VF %d.\n", vf_id);
-		ret = -EINVAL;
+		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
+			vf_id);
+		ret = -EAGAIN;
 		goto error;
 	}
 
@@ -2356,8 +2358,9 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 	/* first vsi is always the LAN vsi */
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev, "Uninitialized VF %d\n", vf_id);
-		ret = -EINVAL;
+		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
+			vf_id);
+		ret = -EAGAIN;
 		goto error_param;
 	}
 
@@ -2472,6 +2475,12 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable)
 	}
 
 	vf = &(pf->vf[vf_id]);
+	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
+		dev_err(&pf->pdev->dev, "VF %d still in reset. Try again.\n",
+			vf_id);
+		ret = -EAGAIN;
+		goto out;
+	}
 
 	if (enable == vf->spoofchk)
 		goto out;
-- 
2.5.0
