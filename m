From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 3/7] i40e: Sync link state between PF/VFs and Port representor netdevs
Date: Wed, 29 Mar 2017 17:22:51 -0700
Message-ID: <1490833375-2788-4-git-send-email-sridhar.samudrala@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42898 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753411AbdC3AW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:22:59 -0400
In-Reply-To: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables
- reflecting the link state of port netdev based on PF/VF admin state &
  link state of PF/VF based on admin state of the associated port netdev.
- bringing up/down the VF port netdev sends a notification to update VF
  link state.
- bringing up/down the VF will cause the link state update of VF port
  netdev.
- enable/disable VF link state via ndo_set_vf_link_state will update the
  admin state of associated VF port netdev.
- bringing up/down the PF port netdev updates the link state of PF based on
  the hw link info.
- bringing up/down the PF will update the link state of PF port netdev.

PF: p4p1, VFs: p4p1_0,p4p1_1  PF Port netdev: p4p1-pf
VF Port netdevs:p4p1-vf0, p4p1-vf1
# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:42:00.0 mode switchdev
# echo 2 > /sys/class/net/p4p1/device/sriov_numvfs

# ip link set p4p1 up
# ip link show p4p1-pf
29: p4p1-pf: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 02:25:9e:c6:a7:3f brd ff:ff:ff:ff:ff:ff

/* p4p1-pf DOWN ->  p4p1 NO-CARRIER */
# ip link show p4p1
27: p4p1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT qlen 1000
    link/ether 3c:fd:fe:a3:18:f8 brd ff:ff:ff:ff:ff:ff

# ip link set p4p1-pf up
# ip link show p4p1-pf
29: p4p1-pf: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 02:25:9e:c6:a7:3f brd ff:ff:ff:ff:ff:ff

/* p4p1-pf UP ->  p4p1 CARRIER ON */
# ip link show p4p1
27: p4p1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 3c:fd:fe:a3:18:f8 brd ff:ff:ff:ff:ff:ff

# ip link set p4p1-vf0 up
# ip link set p4p1_0 up

/* p4p1_0 UP -> p4p1-vf0 CARRIER ON */
# ip link show p4p1-vf0
30: p4p1-vf0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether d2:7c:19:e6:e2:ef brd ff:ff:ff:ff:ff:ff

/* p4p1-vf0 UP -> p4p1_0 CARRIER ON */
# ip link show p4p1_0
32: p4p1_0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether ba:29:a3:bb:a0:d5 brd ff:ff:ff:ff:ff:ff

# ip link set p4p1_1 up

/* p4p1-vf1 DOWN -> p4p1_1 NO-CARRIER */
# ip link show p4p1_1
33: p4p1_1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT qlen 1000
    link/ether 3e:fd:68:79:91:02 brd ff:ff:ff:ff:ff:ff

# ip link set p4p1_1 down
# ip link set p4p1-vf1 up

/* p4p1_1 DOWN -> p4p1-vf1 NO-CARRIER */
# ip link show p4p1-vf1
31: p4p1-vf1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT qlen 1000
    link/ether e2:a0:20:20:c8:b4 brd ff:ff:ff:ff:ff:ff

# ip link set p4p1-vf0 down

/* p4p1-vf0 DOWN -> p4p1_0 NO-CARRIER */
# ip link show p4p1_0
32: p4p1_0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT qlen 1000
    link/ether 52:36:3d:37:1e:73 brd ff:ff:ff:ff:ff:ff

# ip -d link show p4p1
27: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca27268 state DOWN mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state enable, trust off

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 106 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  21 +++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   1 +
 3 files changed, 122 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e441e39..683aa20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5316,7 +5316,8 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 	i40e_vsi_enable_irq(vsi);
 
 	if ((pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP) &&
-	    (vsi->netdev)) {
+	    (vsi->netdev) && (!pf->port_netdev ||
+			      (pf->port_netdev->flags & IFF_UP))) {
 		i40e_print_link_message(vsi, true);
 		netif_tx_start_all_queues(vsi->netdev);
 		netif_carrier_on(vsi->netdev);
@@ -5518,6 +5519,9 @@ int i40e_open(struct net_device *netdev)
 
 	udp_tunnel_get_rx_info(netdev);
 
+	if (pf->port_netdev)
+		netif_carrier_on(pf->port_netdev);
+
 	return 0;
 }
 
@@ -5667,9 +5671,13 @@ int i40e_close(struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
 
 	i40e_vsi_close(vsi);
 
+	if (pf->port_netdev)
+		netif_carrier_off(pf->port_netdev);
+
 	return 0;
 }
 
@@ -6181,10 +6189,15 @@ static void i40e_vsi_link_event(struct i40e_vsi *vsi, bool link_up)
 
 	switch (vsi->type) {
 	case I40E_VSI_MAIN:
+	{
+		struct i40e_pf *pf = vsi->back;
+		struct net_device *port_netdev = pf->port_netdev;
+
 		if (!vsi->netdev || !vsi->netdev_registered)
 			break;
 
-		if (link_up) {
+		if (link_up && (!port_netdev ||
+				(port_netdev->flags & IFF_UP))) {
 			netif_carrier_on(vsi->netdev);
 			netif_tx_wake_all_queues(vsi->netdev);
 		} else {
@@ -6192,7 +6205,7 @@ static void i40e_vsi_link_event(struct i40e_vsi *vsi, bool link_up)
 			netif_tx_stop_all_queues(vsi->netdev);
 		}
 		break;
-
+	}
 	case I40E_VSI_SRIOV:
 	case I40E_VSI_VMDQ2:
 	case I40E_VSI_CTRL:
@@ -10914,7 +10927,35 @@ static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
  **/
 static int i40e_port_netdev_open(struct net_device *dev)
 {
-	return 0;
+	struct i40e_port_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_pf *pf;
+	struct i40e_vf *vf;
+	struct i40e_vsi *vsi;
+	int err = 0;
+
+	switch (priv->type) {
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)priv->f;
+		vf->link_forced = true;
+		vf->link_up = true;
+		i40e_vc_notify_vf_link_state(vf);
+		break;
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)priv->f;
+		vsi = pf->vsi[pf->lan_vsi];
+		if (pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP) {
+			netif_carrier_on(vsi->netdev);
+			netif_tx_start_all_queues(vsi->netdev);
+		} else {
+			err = -ENETDOWN;
+		}
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
 }
 
 /**
@@ -10925,7 +10966,31 @@ static int i40e_port_netdev_open(struct net_device *dev)
  **/
 static int i40e_port_netdev_stop(struct net_device *dev)
 {
-	return 0;
+	struct i40e_port_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_pf *pf;
+	struct i40e_vf *vf;
+	struct i40e_vsi *vsi;
+	int err = 0;
+
+	switch (priv->type) {
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)priv->f;
+		vf->link_forced = true;
+		vf->link_up = false;
+		i40e_vc_notify_vf_link_state(vf);
+		break;
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)priv->f;
+		vsi = pf->vsi[pf->lan_vsi];
+		netif_carrier_off(vsi->netdev);
+		netif_tx_stop_all_queues(vsi->netdev);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
 }
 
 static const struct net_device_ops i40e_port_netdev_ops = {
@@ -11013,6 +11078,26 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
 		 ((type == I40E_PORT_NETDEV_PF) ? "PF" : "VF"),
 		 port_netdev->name);
 
+	switch (type) {
+	case I40E_PORT_NETDEV_PF:
+		/* Reset PF link as we are changing the mode to 'switchdev'.
+		 * Port netdev needs to be brought up to enable VF link.
+		 */
+		netif_carrier_off(vsi->netdev);
+		netif_tx_stop_all_queues(vsi->netdev);
+		if (pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP)
+			netif_carrier_on(port_netdev);
+		break;
+	case I40E_PORT_NETDEV_VF:
+		/* Reset VF link as we are changing the mode to 'switchdev'.
+		 * Port netdev needs to be brought up to enable VF link.
+		 */
+		vf->link_forced = true;
+		vf->link_up = false;
+		i40e_vc_notify_vf_link_state(vf);
+		break;
+	}
+
 	return 0;
 }
 
@@ -11027,10 +11112,12 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 {
 	struct i40e_pf *pf;
 	struct i40e_vf *vf;
+	struct i40e_vsi *vsi;
 
 	switch (type) {
 	case I40E_PORT_NETDEV_PF:
 		pf = (struct i40e_pf *)f;
+		vsi = pf->vsi[pf->lan_vsi];
 
 		if (!pf->port_netdev)
 			return;
@@ -11039,6 +11126,11 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 		unregister_netdev(pf->port_netdev);
 		free_netdev(pf->port_netdev);
 		pf->port_netdev = NULL;
+		/* In legacy mode, PF link is not controlled by Port netdev */
+		if (pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP) {
+			netif_carrier_on(vsi->netdev);
+			netif_tx_start_all_queues(vsi->netdev);
+		}
 		break;
 	case I40E_PORT_NETDEV_VF:
 		vf = (struct i40e_vf *)f;
@@ -11051,6 +11143,10 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 		unregister_netdev(vf->port_netdev);
 		free_netdev(vf->port_netdev);
 		vf->port_netdev = NULL;
+
+		/* In legacy mode, VF link is not controlled by Port netdev */
+		vf->link_forced = false;
+		i40e_vc_notify_vf_link_state(vf);
 		break;
 	default:
 		break;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index e89f4c4..7c2e7b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -68,7 +68,7 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
  *
  * send a link status message to a single VF
  **/
-static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf)
+void i40e_vc_notify_vf_link_state(struct i40e_vf *vf)
 {
 	struct i40e_virtchnl_pf_event pfe;
 	struct i40e_pf *pf = vf->pf;
@@ -1805,6 +1805,10 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	if (i40e_vsi_start_rings(pf->vsi[vf->lan_vsi_idx]))
 		aq_ret = I40E_ERR_TIMEOUT;
+
+	if ((aq_ret == 0) && vf->port_netdev)
+		netif_carrier_on(vf->port_netdev);
+
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
@@ -1844,6 +1848,9 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	i40e_vsi_stop_rings(pf->vsi[vf->lan_vsi_idx]);
 
+	if ((aq_ret == 0) && vf->port_netdev)
+		netif_carrier_off(vf->port_netdev);
+
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_DISABLE_QUEUES,
@@ -3080,6 +3087,7 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_virtchnl_pf_event pfe;
 	struct i40e_hw *hw = &pf->hw;
+	struct net_device *port_netdev;
 	struct i40e_vf *vf;
 	int abs_vf_id;
 	int ret = 0;
@@ -3121,6 +3129,17 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 		ret = -EINVAL;
 		goto error_out;
 	}
+
+	port_netdev = vf->port_netdev;
+	if (port_netdev) {
+		unsigned int flags = port_netdev->flags;
+
+		if (vf->link_up)
+			dev_change_flags(port_netdev, flags | IFF_UP);
+		else
+			dev_change_flags(port_netdev, flags & ~IFF_UP);
+	}
+
 	/* Notify the VF of its new link state */
 	i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
 			       0, (u8 *)&pfe, sizeof(pfe), NULL);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index b24d0c6..3e1f8f6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -146,5 +146,6 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
+void i40e_vc_notify_vf_link_state(struct i40e_vf *vf);
 
 #endif /* _I40E_VIRTCHNL_PF_H_ */
-- 
1.8.3.1
