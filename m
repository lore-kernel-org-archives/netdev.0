From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: Patch to support trusted VF
Date: Wed,  6 Apr 2016 20:29:32 -0700
Message-ID: <1459999779-22254-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26073 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbcDGD3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:45 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch adds hook to support changing a VF from not-trusted
to trusted and vice-versa. Fixed the wrappers and function prototype.
Changed the dmesg to reflex the current state better. This patch also
disables turning on/off trusted VF in MFP mode.

Change-ID: Ibcd910935c01f0be1f3fdd6d427230291ee92ebe
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 42 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  2 ++
 3 files changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 86abd08..627acf0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9069,6 +9069,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_get_vf_config	= i40e_ndo_get_vf_config,
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofchk,
+	.ndo_set_vf_trust	= i40e_ndo_set_vf_trust,
 #if IS_ENABLED(CONFIG_VXLAN)
 	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
 	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index f2a9c14..b353966 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2763,3 +2763,45 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable)
 out:
 	return ret;
 }
+
+/**
+ * i40e_ndo_set_vf_trust
+ * @netdev: network interface device structure of the pf
+ * @vf_id: VF identifier
+ * @setting: trust setting
+ *
+ * Enable or disable VF trust setting
+ **/
+int i40e_ndo_set_vf_trust(struct net_device *netdev, int vf_id, bool setting)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vf *vf;
+	int ret = 0;
+
+	/* validate the request */
+	if (vf_id >= pf->num_alloc_vfs) {
+		dev_err(&pf->pdev->dev, "Invalid VF Identifier %d\n", vf_id);
+		return -EINVAL;
+	}
+
+	if (pf->flags & I40E_FLAG_MFP_ENABLED) {
+		dev_err(&pf->pdev->dev, "Trusted VF not supported in MFP mode.\n");
+		return -EINVAL;
+	}
+
+	vf = &pf->vf[vf_id];
+
+	if (!vf)
+		return -EINVAL;
+	if (setting == vf->trusted)
+		goto out;
+
+	vf->trusted = setting;
+	i40e_vc_notify_vf_reset(vf);
+	i40e_reset_vf(vf, false);
+	dev_info(&pf->pdev->dev, "VF %u is now %strusted\n",
+		 vf_id, setting ? "" : "un");
+out:
+	return ret;
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index e7b2fba..838cbd2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -88,6 +88,7 @@ struct i40e_vf {
 	struct i40e_virtchnl_ether_addr default_fcoe_addr;
 	u16 port_vlan_id;
 	bool pf_set_mac;	/* The VMM admin set the VF MAC address */
+	bool trusted;
 
 	/* VSI indices - actual VSI pointers are maintained in the PF structure
 	 * When assigned, these will be non-zero, because VSI 0 is always
@@ -127,6 +128,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 			      int vf_id, u16 vlan_id, u8 qos);
 int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 		       int max_tx_rate);
+int i40e_ndo_set_vf_trust(struct net_device *netdev, int vf_id, bool setting);
 int i40e_ndo_get_vf_config(struct net_device *netdev,
 			   int vf_id, struct ifla_vf_info *ivi);
 int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link);
-- 
2.5.5
