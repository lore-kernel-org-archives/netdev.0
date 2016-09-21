From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Sync link state between VFs and VF Port representors(VFPR)
Date: Tue, 20 Sep 2016 20:43:49 -0700
Message-ID: <1474429432-102772-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43488 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754855AbcIUDn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:59 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This patch enables
- reflecting the link state of VFPR based on VF admin state & link state
  of VF based on admin state of VFPR.
- bringing up/down the VFPR sends a notification to update VF link state.
- bringing up/down the VF will cause the link state update of VFPR.
- enable/disable VF link state via ndo_set_vf_link_state will update the
  admin state of associated VFPR.

    PF: enp5s0f0, VFs: enp5s2,enp5s2f1 VFPRs:enp5s0f0-vf0, enp5s0f0-vf1
    # modprobe i40e
    # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs

    # ip link set enp5s2 up
    # ip link set enp5s0f0-vf0 up
    # ip link set enp5s0f0-vf1 up

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

    /* enp5s2 UP -> enp5s0f0-vf1 CARRIER ON */
    # ip link show enp5s0f0-vf1
216: enp5s0f0-vf1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff

    /* enp5s0-vf0 DOWN -> enp5s2 NO_CARRIER */
    # ip link show enp5s2
218: enp5s2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000
    link/ether ea:4d:60:bc:6f:85 brd ff:ff:ff:ff:ff:ff

    # ip -d link show enp5s0f0
213: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state disable
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state enable

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 33 ++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b90abd3..795a294 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1013,11 +1013,25 @@ complete_reset:
 
 static int i40e_vf_netdev_open(struct net_device *dev)
 {
+	struct i40e_vf_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+
+	vf->link_forced = true;
+	vf->link_up = true;
+	i40e_vc_notify_vf_link_state(vf);
+
 	return 0;
 }
 
 static int i40e_vf_netdev_stop(struct net_device *dev)
 {
+	struct i40e_vf_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+
+	vf->link_forced = true;
+	vf->link_up = false;
+	i40e_vc_notify_vf_link_state(vf);
+
 	return 0;
 }
 
@@ -1907,6 +1921,10 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	if (i40e_vsi_control_rings(pf->vsi[vf->lan_vsi_idx], true))
 		aq_ret = I40E_ERR_TIMEOUT;
+
+	if ((0 == aq_ret) && vf->ctrl_netdev)
+		netif_carrier_on(vf->ctrl_netdev);
+
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
@@ -1947,6 +1965,9 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	if (i40e_vsi_control_rings(pf->vsi[vf->lan_vsi_idx], false))
 		aq_ret = I40E_ERR_TIMEOUT;
 
+	if ((0 == aq_ret) && vf->ctrl_netdev)
+		netif_carrier_off(vf->ctrl_netdev);
+
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_DISABLE_QUEUES,
@@ -3179,6 +3200,7 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 	struct i40e_virtchnl_pf_event pfe;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vf;
+	struct net_device *vf_netdev;
 	int abs_vf_id;
 	int ret = 0;
 
@@ -3219,6 +3241,17 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 		ret = -EINVAL;
 		goto error_out;
 	}
+
+	vf_netdev = vf->ctrl_netdev;
+	if (vf_netdev) {
+		unsigned int flags = vf_netdev->flags;
+
+		if (vf->link_up)
+			dev_change_flags(vf_netdev, flags | IFF_UP);
+		else
+			dev_change_flags(vf_netdev, flags & ~IFF_UP);
+	}
+
 	/* Notify the VF of its new link state */
 	i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
 			       0, (u8 *)&pfe, sizeof(pfe), NULL);
-- 
2.7.4
