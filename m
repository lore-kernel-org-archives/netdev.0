From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [net-next PATCH 3/6] i40e: Sync link state between VFs and VFPRs
Date: Thu, 29 Dec 2016 22:21:00 -0800
Message-ID: <1483078863-22026-4-git-send-email-sridhar.samudrala@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19681 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750895AbcL2V2K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 16:28:10 -0500
In-Reply-To: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables
- reflecting the link state of VFPR based on VF admin state & link state
  of VF based on admin state of VFPR.
- bringing up/down the VFPR sends a notification to update VF link state.
- bringing up/down the VF will cause the link state update of VFPR.
- enable/disable VF link state via ndo_set_vf_link_state will update the
  admin state of associated VFPR.

PF: enp5s0f0, VFs: enp5s2,enp5s2f1 VFPRs:enp5s0f0-vf0, enp5s0f0-vf1
# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs

# ip link set enp5s2 up
# ip link set enp5s0f0-vf0 up
# ip link set enp5s0f0-vf1 up

/* enp5s2 UP -> enp5s0f0-vf0 CARRIER ON */
# ip link show enp5s0f0-vf0
215: enp5s0f0-vf0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff

/* enp5s0f0-vf0 UP -> enp5s2 CARRIER ON */
# ip link show enp5s2
218: enp5s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
     link/ether ea:4d:60:bc:6f:85 brd ff:ff:ff:ff:ff:ff

/* enp5s2f1 DOWN -> enp5s0f0-vf1 NO-CARRIER */
# ip link show enp5s0f0-vf1
216: enp5s0f0-vf1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff

# ip link set enp5s0f0-vf0 down
# ip link set enp5s2f1 up

/* enp5s0-vf0 DOWN -> enp5s2 NO_CARRIER */
# ip link show enp5s2
218: enp5s2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000
     link/ether ea:4d:60:bc:6f:85 brd ff:ff:ff:ff:ff:ff

# ip -d link show enp5s0f0
213: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca27268 state DOWN mode DEFAULT group default qlen 1000
     link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64
     vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
     vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state enable, trust off

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 44 ++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 6c5b296..3ea7235 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1031,6 +1031,13 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
  **/
 static int i40e_vfpr_netdev_open(struct net_device *dev)
 {
+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+
+	vf->link_forced = true;
+	vf->link_up = true;
+	i40e_vc_notify_vf_link_state(vf);
+
 	return 0;
 }
 
@@ -1042,6 +1049,13 @@ static int i40e_vfpr_netdev_open(struct net_device *dev)
  **/
 static int i40e_vfpr_netdev_stop(struct net_device *dev)
 {
+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+
+	vf->link_forced = true;
+	vf->link_up = false;
+	i40e_vc_notify_vf_link_state(vf);
+
 	return 0;
 }
 
@@ -1127,6 +1141,13 @@ int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
 	/* Delete broadcast filter for VF */
 	i40e_update_vf_broadcast_filter(vf, false);
 
+	/* Reset VF link as we are changing the mode to 'switchdev'. VFPR netdev
+	 * needs to be brought up to enable VF link.
+	 */
+	vf->link_forced = true;
+	vf->link_up = false;
+	i40e_vc_notify_vf_link_state(vf);
+
 	return 0;
 }
 
@@ -1151,6 +1172,10 @@ void i40e_free_vfpr_netdev(struct i40e_vf *vf)
 
 	/* Add broadcast filter to VF */
 	i40e_update_vf_broadcast_filter(vf, true);
+
+	/* In legacy mode, VF link is not controlled by VFPR */
+	vf->link_forced = false;
+	i40e_vc_notify_vf_link_state(vf);
 }
 
 /**
@@ -1907,6 +1932,10 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	if (i40e_vsi_start_rings(pf->vsi[vf->lan_vsi_idx]))
 		aq_ret = I40E_ERR_TIMEOUT;
+
+	if ((0 == aq_ret) && vf->vfpr_netdev)
+		netif_carrier_on(vf->vfpr_netdev);
+
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
@@ -1946,6 +1975,9 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	i40e_vsi_stop_rings(pf->vsi[vf->lan_vsi_idx]);
 
+	if ((0 == aq_ret) && vf->vfpr_netdev)
+		netif_carrier_off(vf->vfpr_netdev);
+
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_DISABLE_QUEUES,
@@ -3186,6 +3218,7 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_virtchnl_pf_event pfe;
+	struct net_device *vfpr_netdev;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vf;
 	int abs_vf_id;
@@ -3228,6 +3261,17 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 		ret = -EINVAL;
 		goto error_out;
 	}
+
+	vfpr_netdev = vf->vfpr_netdev;
+	if (vfpr_netdev) {
+		unsigned int flags = vfpr_netdev->flags;
+
+		if (vf->link_up)
+			dev_change_flags(vfpr_netdev, flags | IFF_UP);
+		else
+			dev_change_flags(vfpr_netdev, flags & ~IFF_UP);
+	}
+
 	/* Notify the VF of its new link state */
 	i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
 			       0, (u8 *)&pfe, sizeof(pfe), NULL);
-- 
2.5.5
