From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: support VF link state ndo
Date: Mon, 17 Mar 2014 05:45:01 -0700
Message-ID: <1395060316-16897-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9205 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756229AbaCQMpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:45:21 -0400
In-Reply-To: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This netdev op allows the PF driver to control the virtual link state of
the VF devices. This can be used to deny naughty VF drivers access to
the wire, or to allow VFs (regardless of temperament) to communicate
with each other over the device's internal switch even though external
link is down.

Add the actual ndo function, and modify vc_notify_link_state to check
the link status of each VF before sending a message in the case when
physical link changes state.

Change-ID: Ib5a6924da78c540789f21d26b5e8086d71c29384
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 86 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 +
 3 files changed, 85 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c66a11e..c7b236f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6547,6 +6547,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_vf_vlan	= i40e_ndo_set_vf_port_vlan,
 	.ndo_set_vf_tx_rate	= i40e_ndo_set_vf_bw,
 	.ndo_get_vf_config	= i40e_ndo_get_vf_config,
+	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 #ifdef CONFIG_I40E_VXLAN
 	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
 	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 7839343..f018238 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1920,15 +1920,28 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
 void i40e_vc_notify_link_state(struct i40e_pf *pf)
 {
 	struct i40e_virtchnl_pf_event pfe;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_vf *vf = pf->vf;
+	struct i40e_link_status *ls = &pf->hw.phy.link_info;
+	int i;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
-	pfe.event_data.link_event.link_status =
-	    pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP;
-	pfe.event_data.link_event.link_speed = pf->hw.phy.link_info.link_speed;
-
-	i40e_vc_vf_broadcast(pf, I40E_VIRTCHNL_OP_EVENT, I40E_SUCCESS,
-			     (u8 *)&pfe, sizeof(struct i40e_virtchnl_pf_event));
+	for (i = 0; i < pf->num_alloc_vfs; i++) {
+		if (vf->link_forced) {
+			pfe.event_data.link_event.link_status = vf->link_up;
+			pfe.event_data.link_event.link_speed =
+				(vf->link_up ? I40E_LINK_SPEED_40GB : 0);
+		} else {
+			pfe.event_data.link_event.link_status =
+				ls->link_info & I40E_AQ_LINK_UP;
+			pfe.event_data.link_event.link_speed = ls->link_speed;
+		}
+		i40e_aq_send_msg_to_vf(hw, vf->vf_id, I40E_VIRTCHNL_OP_EVENT,
+				       0, (u8 *)&pfe, sizeof(pfe),
+				       NULL);
+		vf++;
+	}
 }
 
 /**
@@ -2193,3 +2206,64 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 error_param:
 	return ret;
 }
+
+/**
+ * i40e_ndo_set_vf_link_state
+ * @netdev: network interface device structure
+ * @vf_id: vf identifier
+ * @link: required link state
+ *
+ * Set the link state of a specified VF, regardless of physical link state
+ **/
+int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_virtchnl_pf_event pfe;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_vf *vf;
+	int ret = 0;
+
+	/* validate the request */
+	if (vf_id >= pf->num_alloc_vfs) {
+		dev_err(&pf->pdev->dev, "Invalid VF Identifier %d\n", vf_id);
+		ret = -EINVAL;
+		goto error_out;
+	}
+
+	vf = &(pf->vf[vf_id]);
+
+	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
+	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
+
+	switch (link) {
+	case IFLA_VF_LINK_STATE_AUTO:
+		vf->link_forced = false;
+		pfe.event_data.link_event.link_status =
+			pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP;
+		pfe.event_data.link_event.link_speed =
+			pf->hw.phy.link_info.link_speed;
+		break;
+	case IFLA_VF_LINK_STATE_ENABLE:
+		vf->link_forced = true;
+		vf->link_up = true;
+		pfe.event_data.link_event.link_status = true;
+		pfe.event_data.link_event.link_speed = I40E_LINK_SPEED_40GB;
+		break;
+	case IFLA_VF_LINK_STATE_DISABLE:
+		vf->link_forced = true;
+		vf->link_up = false;
+		pfe.event_data.link_event.link_status = false;
+		pfe.event_data.link_event.link_speed = 0;
+		break;
+	default:
+		ret = -EINVAL;
+		goto error_out;
+	}
+	/* Notify the VF of its new link state */
+	i40e_aq_send_msg_to_vf(hw, vf->vf_id, I40E_VIRTCHNL_OP_EVENT,
+			       0, (u8 *)&pfe, sizeof(pfe), NULL);
+
+error_out:
+	return ret;
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index bedf0ba..389c47f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -98,6 +98,8 @@ struct i40e_vf {
 
 	unsigned long vf_caps;	/* vf's adv. capabilities */
 	unsigned long vf_states;	/* vf's runtime states */
+	bool link_forced;
+	bool link_up;		/* only valid if vf link is forced */
 };
 
 void i40e_free_vfs(struct i40e_pf *pf);
@@ -116,6 +118,8 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int tx_rate);
 int i40e_ndo_get_vf_config(struct net_device *netdev,
 			   int vf_id, struct ifla_vf_info *ivi);
+int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link);
+
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
 
-- 
1.8.3.1
