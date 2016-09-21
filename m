From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Introduce VF port representor/control netdevs
Date: Tue, 20 Sep 2016 20:43:38 -0700
Message-ID: <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33017 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754750AbcIUDnz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:55 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This patch enables creation of a VF Port representor/Control netdev
associated with each VF. These netdevs can be used to control and configure
VFs from PFs namespace. They enable exposing VF statistics, configuring
link state, mtu, fdb/vlan entries etc.

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
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 88 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 14 ++++
 2 files changed, 102 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index da34235..11f6970 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1003,6 +1003,90 @@ complete_reset:
 	clear_bit(__I40E_VF_DISABLE, &pf->state);
 }
 
+static int i40e_vf_netdev_open(struct net_device *dev)
+{
+	return 0;
+}
+
+static int i40e_vf_netdev_stop(struct net_device *dev)
+{
+	return 0;
+}
+
+static const struct net_device_ops i40e_vf_netdev_ops = {
+	.ndo_open = i40e_vf_netdev_open,
+	.ndo_stop = i40e_vf_netdev_stop,
+};
+
+/**
+ * i40e_alloc_vf_netdev
+ * @vf: pointer to the VF structure
+ * @vf_num: VF number
+ *
+ * Create VF representor/control netdev
+ **/
+int i40e_alloc_vf_netdev(struct i40e_vf *vf, u16 vf_num)
+{
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	struct i40e_vf_netdev_priv *priv;
+	char netdev_name[IFNAMSIZ];
+	struct net_device *netdev;
+	int err;
+
+	snprintf(netdev_name, IFNAMSIZ, "%s-vf%d", vsi->netdev->name, vf_num);
+	netdev = alloc_netdev(sizeof(struct i40e_vf_netdev_priv), netdev_name,
+			      NET_NAME_UNKNOWN, ether_setup);
+	if (!netdev) {
+		dev_err(&pf->pdev->dev, "alloc_netdev failed for vf:%d\n",
+			vf_num);
+		return -ENOMEM;
+	}
+
+	pf->vf[vf_num].ctrl_netdev = netdev;
+
+	priv = netdev_priv(netdev);
+	priv->vf = &(pf->vf[vf_num]);
+
+	netdev->netdev_ops = &i40e_vf_netdev_ops;
+
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
+	err = register_netdev(netdev);
+	if (err) {
+		dev_err(&pf->pdev->dev, "register_netdev failed for vf: %s\n",
+			vf->ctrl_netdev->name);
+		free_netdev(netdev);
+		return err;
+	}
+
+	dev_info(&pf->pdev->dev, "VF representor(%s) created for VF %d\n",
+		 vf->ctrl_netdev->name, vf_num);
+
+	return 0;
+}
+
+/**
+ * i40e_free_vf_netdev
+ * @vf: pointer to the VF structure
+ *
+ * Free VF representor/control netdev
+ **/
+void i40e_free_vf_netdev(struct i40e_vf *vf)
+{
+	struct i40e_pf *pf = vf->pf;
+
+	if (!vf->ctrl_netdev)
+		return;
+
+	dev_info(&pf->pdev->dev, "Freeing VF representor(%s)\n",
+		 vf->ctrl_netdev->name);
+
+	unregister_netdev(vf->ctrl_netdev);
+	free_netdev(vf->ctrl_netdev);
+}
+
 /**
  * i40e_free_vfs
  * @pf: pointer to the PF structure
@@ -1045,6 +1129,8 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			i40e_free_vf_res(&pf->vf[i]);
 		/* disable qp mappings */
 		i40e_disable_vf_mappings(&pf->vf[i]);
+
+		i40e_free_vf_netdev(&pf->vf[i]);
 	}
 
 	kfree(pf->vf);
@@ -1112,6 +1198,8 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		/* VF resources get allocated during reset */
 		i40e_reset_vf(&vfs[i], false);
 
+		i40e_alloc_vf_netdev(&vfs[i], i);
+
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 8751741..1d54b95 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -72,10 +72,21 @@ enum i40e_vf_capabilities {
 	I40E_VIRTCHNL_VF_CAP_IWARP,
 };
 
+/* VF Ctrl netdev private structure */
+struct i40e_vf_netdev_priv {
+	struct i40e_vf *vf;
+};
+
 /* VF information structure */
 struct i40e_vf {
 	struct i40e_pf *pf;
 
+	/* VF Port representor netdev that allows control and configuration
+	 * of VFs from the host. Enables returning VF stats, configuring link
+	 * state, mtu, fdb/vlans etc.
+	 */
+	struct net_device *ctrl_netdev;
+
 	/* VF id in the PF space */
 	s16 vf_id;
 	/* all VF vsis connect to the same parent */
@@ -142,4 +153,7 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable);
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
 
+int i40e_alloc_vf_netdev(struct i40e_vf *vf, u16 vf_num);
+void i40e_free_vf_netdev(struct i40e_vf *vf);
+
 #endif /* _I40E_VIRTCHNL_PF_H_ */
-- 
2.7.4
