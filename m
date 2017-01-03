From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [net-next PATCH v2 2/6] i40e: Introduce VF Port Representator(VFPR) netdevs.
Date: Tue,  3 Jan 2017 10:07:50 -0800
Message-ID: <1483466874-2962-3-git-send-email-sridhar.samudrala@intel.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47457 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760282AbdACSLB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 13:11:01 -0500
In-Reply-To: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF Port Representator netdevs are created for each VF if the switch mode
is set to 'switchdev'. These netdevs can be used to control and configure
VFs from PFs namespace. They enable exposing VF statistics, configure and
monitor link state, mtu, filters, fdb/vlan entries etc. of VFs.
Broadcast filters are not enabled in switchdev mode.

Sample script to create VF port representors
# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
# ip l show
297: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
     link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
     vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
     vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
299: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
300: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  21 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 154 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  14 ++
 3 files changed, 182 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c01a620..17428f0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10938,15 +10938,34 @@ static int i40e_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 {
 	struct i40e_pf *pf = devlink_priv(devlink);
-	int err = 0;
+	struct i40e_vf *vf;
+	int i, j, err = 0;
 
 	if (mode == pf->eswitch_mode)
 		goto done;
 
 	switch (mode) {
 	case DEVLINK_ESWITCH_MODE_LEGACY:
+		for (i = 0; i < pf->num_alloc_vfs; i++) {
+			vf = &(pf->vf[i]);
+			i40e_free_vfpr_netdev(vf);
+		}
 		pf->eswitch_mode = mode;
 		break;
+	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
+		for (i = 0; i < pf->num_alloc_vfs; i++) {
+			vf = &(pf->vf[i]);
+			err = i40e_alloc_vfpr_netdev(vf, i);
+			if (err) {
+				for (j = 0; j < i; j++) {
+					vf = &(pf->vf[j]);
+					i40e_free_vfpr_netdev(vf);
+				}
+				goto done;
+			}
+		}
+                pf->eswitch_mode = mode;
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a6198b7..63da829 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -697,12 +697,16 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 					 "Could not add MAC filter %pM for VF %d\n",
 					vf->default_lan_addr.addr, vf->vf_id);
 		}
-		eth_broadcast_addr(broadcast);
-		f = i40e_add_filter(vsi, broadcast,
-				    vf->port_vlan_id ? vf->port_vlan_id : -1);
-		if (!f)
-			dev_info(&pf->pdev->dev,
-				 "Could not allocate VF broadcast filter\n");
+
+		/* Add VF broadcast filter only in 'legacy' mode */
+		if (vsi->back->eswitch_mode == DEVLINK_ESWITCH_MODE_LEGACY) {
+			eth_broadcast_addr(broadcast);
+			f = i40e_add_filter(vsi, broadcast,
+					    vf->port_vlan_id ? vf->port_vlan_id : -1);
+			if (!f)
+				dev_info(&pf->pdev->dev,
+					 "Could not allocate VF broadcast filter\n");
+		}
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(0, vf->vf_id),
 				  (u32)hena);
@@ -1020,6 +1024,136 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 }
 
 /**
+ * i40e_vfpr_netdev_open
+ * @dev: network interface device structure
+ *
+ * Called when vfpr netdevice is brought up.
+ **/
+static int i40e_vfpr_netdev_open(struct net_device *dev)
+{
+	return 0;
+}
+
+/**
+ * i40e_vfpr_netdev_stop
+ * @dev: network interface device structure
+ *
+ * Called when vfpr netdevice is brought down.
+ **/
+static int i40e_vfpr_netdev_stop(struct net_device *dev)
+{
+	return 0;
+}
+
+static const struct net_device_ops i40e_vfpr_netdev_ops = {
+	.ndo_open       	= i40e_vfpr_netdev_open,
+	.ndo_stop       	= i40e_vfpr_netdev_stop,
+};
+
+/**
+ * i40e_update_vf_broadcast_filter
+ * @vf: pointer to the VF structure
+ * @enable: boolean flag indicating add/delete
+ *
+ * add/delete VFs broadcast filter
+ **/
+void i40e_update_vf_broadcast_filter(struct i40e_vf *vf, bool enable)
+{
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi = pf->vsi[vf->lan_vsi_idx];
+	u8 broadcast[ETH_ALEN];
+	int err;
+
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+	eth_broadcast_addr(broadcast);
+	if (enable)
+		i40e_add_filter(vsi, broadcast, vf->port_vlan_id ? vf->port_vlan_id : -1);
+	else
+		i40e_del_filter(vsi, broadcast, vf->port_vlan_id ? vf->port_vlan_id : -1);
+	spin_unlock_bh(&vsi->mac_filter_hash_lock);
+
+	/* update broadcast filter */
+	err = i40e_sync_vsi_filters(vsi);
+	if (err)
+		dev_err(&pf->pdev->dev, "Unable to program bcast filter\n");
+}
+
+/**
+ * i40e_alloc_vfpr_netdev
+ * @vf: pointer to the VF structure
+ * @vf_num: VF number
+ *
+ * Create VF Port representor netdev
+ **/
+int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
+{
+	struct net_device *vfpr_netdev;
+	char netdev_name[IFNAMSIZ];
+	struct i40e_vfpr_netdev_priv *priv;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	int err;
+
+	snprintf(netdev_name, IFNAMSIZ, "%s-vf%d", vsi->netdev->name, vf_num);
+	vfpr_netdev = alloc_netdev(sizeof(struct i40e_vfpr_netdev_priv),
+				   netdev_name, NET_NAME_UNKNOWN, ether_setup);
+	if (!vfpr_netdev) {
+		dev_err(&pf->pdev->dev, "alloc_netdev failed for vf:%d\n",
+			vf_num);
+		return -ENOMEM;
+	}
+
+	pf->vf[vf_num].vfpr_netdev = vfpr_netdev;
+
+	priv = netdev_priv(vfpr_netdev);
+	priv->vf = &(pf->vf[vf_num]);
+
+	vfpr_netdev->netdev_ops = &i40e_vfpr_netdev_ops;
+
+	netif_carrier_off(vfpr_netdev);
+	netif_tx_disable(vfpr_netdev);
+
+	err = register_netdev(vfpr_netdev);
+	if (err) {
+		dev_err(&pf->pdev->dev, "register_netdev failed for vf: %s\n",
+			vf->vfpr_netdev->name);
+		free_netdev(vfpr_netdev);
+		return err;
+	}
+
+	dev_info(&pf->pdev->dev, "VF Port representor(%s) created for VF %d\n",
+		 vf->vfpr_netdev->name, vf_num);
+
+	/* Delete broadcast filter for VF */
+	i40e_update_vf_broadcast_filter(vf, false);
+
+	return 0;
+}
+
+/**
+ * i40e_free_vfpr_netdev
+ * @vf: pointer to the VF structure
+ *
+ * Free VF Port representor netdev
+ **/
+void i40e_free_vfpr_netdev(struct i40e_vf *vf)
+{
+	struct i40e_pf *pf = vf->pf;
+
+	if (!vf->vfpr_netdev)
+		return;
+
+	dev_info(&pf->pdev->dev, "Freeing VF Port representor(%s)\n",
+		 vf->vfpr_netdev->name);
+
+	unregister_netdev(vf->vfpr_netdev);
+	free_netdev(vf->vfpr_netdev);
+
+	/* Add broadcast filter to VF */
+	i40e_update_vf_broadcast_filter(vf, true);
+}
+
+/**
  * i40e_free_vfs
  * @pf: pointer to the PF structure
  *
@@ -1060,6 +1194,9 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			i40e_free_vf_res(&pf->vf[i]);
 		/* disable qp mappings */
 		i40e_disable_vf_mappings(&pf->vf[i]);
+
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV)
+			i40e_free_vfpr_netdev(&pf->vf[i]);
 	}
 
 	kfree(pf->vf);
@@ -1127,6 +1264,11 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		/* VF resources get allocated during reset */
 		i40e_reset_vf(&vfs[i], false);
 
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV) {
+			ret = i40e_alloc_vfpr_netdev(&vfs[i], i);
+			if (ret)
+				goto err_alloc;
+		}
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 4012d06..25ce93c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -72,10 +72,21 @@ enum i40e_vf_capabilities {
 	I40E_VIRTCHNL_VF_CAP_IWARP,
 };
 
+/* VF Port representator netdev private structure */
+struct i40e_vfpr_netdev_priv {
+	struct i40e_vf *vf;
+};
+
 /* VF information structure */
 struct i40e_vf {
 	struct i40e_pf *pf;
 
+	/* VF Port representator netdev that allows control and configuration
+	 * of VFs from the host. Enables returning VF stats, configuring link
+	 * state, mtu, fdb/vlans etc.
+	 */
+	struct net_device *vfpr_netdev;
+
 	/* VF id in the PF space */
 	s16 vf_id;
 	/* all VF vsis connect to the same parent */
@@ -142,4 +153,7 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable);
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
 
+int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num);
+void i40e_free_vfpr_netdev(struct i40e_vf *vf);
+
 #endif /* _I40E_VIRTCHNL_PF_H_ */
-- 
2.5.5
