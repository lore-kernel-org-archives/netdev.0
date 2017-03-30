From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 2/7] i40e: Introduce Port Representor netdevs and switchdev mode.
Date: Wed, 29 Mar 2017 17:22:50 -0700
Message-ID: <1490833375-2788-3-git-send-email-sridhar.samudrala@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25988 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752253AbdC3AW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:22:58 -0400
In-Reply-To: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port Representator netdevs are created for each PF and VF if the switch
mode is set to 'switchdev'. These netdevs can be used to control and
configure VFs and PFs when they are moved to a different namespace.
They enable exposing statistics, configure and monitor link state, mtu,
filters,fdb/vlan entries etc.

Sample script to create port representors
# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:42:00.0 mode switchdev
# echo 2 > /sys/class/net/p4p1/device/sriov_numvfs
# ip l show
122: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 3c:fd:fe:a3:18:f8 brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
124: p4p1-pf: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 72:8e:34:b2:d0:44 brd ff:ff:ff:ff:ff:ff
125: p4p1-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 02:57:a0:18:2b:ce brd ff:ff:ff:ff:ff:ff
126: p4p1-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 32:7c:77:5f:3e:e3 brd ff:ff:ff:ff:ff:ff
127: p4p1_0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000
    link/ether 26:51:28:54:69:43 brd ff:ff:ff:ff:ff:ff
128: p4p1_1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT qlen 1000

p4p1 is the PF. p4p1-pf is the port netdev for PF.
p4p1_0, p4p1_1 are VFs and p4p1-vf0, p4p1-vf1 are the port netdev's for the 2 VFs.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  19 +++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 187 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   9 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   6 +
 4 files changed, 220 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f788125c..c865803 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -320,6 +320,17 @@ struct i40e_flex_pit {
 	u8 pit_index;
 };
 
+enum i40e_port_netdev_type {
+	I40E_PORT_NETDEV_PF,
+	I40E_PORT_NETDEV_VF
+};
+
+/* Port representor netdev private structure */
+struct i40e_port_netdev_priv {
+	enum i40e_port_netdev_type type;	/* type - PF or VF */
+	void *f;				/* ptr to PF or VF struct */
+};
+
 /* struct that defines the Ethernet device */
 struct i40e_pf {
 	struct pci_dev *pdev;
@@ -328,6 +339,12 @@ struct i40e_pf {
 	struct msix_entry *msix_entries;
 	bool fc_autoneg_status;
 
+	/* PF Port representor netdev that allows control and configuration of
+	 * PFs when they are moved to a different namespace. Enables returning
+	 * PF stats, configuring/monitoring link state, fdb/vlans, filters etc.
+	 */
+	struct net_device *port_netdev;
+
 	u16 eeprom_version;
 	u16 num_vmdq_vsis;         /* num vmdq vsis this PF has set up */
 	u16 num_vmdq_qps;          /* num queue pairs per vmdq pool */
@@ -985,4 +1002,6 @@ bool i40e_dcb_need_reconfig(struct i40e_pf *pf,
 i40e_status i40e_set_npar_bw_setting(struct i40e_pf *pf);
 i40e_status i40e_commit_npar_bw_setting(struct i40e_pf *pf);
 void i40e_print_link_message(struct i40e_vsi *vsi, bool isup);
+int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type);
+void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type);
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index afcf14d..e441e39 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9985,6 +9985,11 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 					 ret);
 			}
 		}
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV) {
+			ret = i40e_alloc_port_netdev(pf, I40E_PORT_NETDEV_PF);
+			if (ret)
+				goto err_port_netdev;
+		}
 	case I40E_VSI_VMDQ2:
 		ret = i40e_config_netdev(vsi);
 		if (ret)
@@ -10037,6 +10042,9 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 		vsi->netdev = NULL;
 	}
 err_netdev:
+	if (pf->port_netdev)
+		i40e_free_port_netdev(pf, I40E_PORT_NETDEV_PF);
+err_port_netdev:
 	i40e_aq_delete_element(&pf->hw, vsi->seid, NULL);
 err_vsi:
 	i40e_vsi_clear(vsi);
@@ -10851,13 +10859,38 @@ static int i40e_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
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
+			vf = &pf->vf[i];
+			i40e_free_port_netdev(vf, I40E_PORT_NETDEV_VF);
+		}
+		i40e_free_port_netdev(pf, I40E_PORT_NETDEV_PF);
+		pf->eswitch_mode = mode;
+		break;
+	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
+		err = i40e_alloc_port_netdev(pf, I40E_PORT_NETDEV_PF);
+		if (err)
+			goto done;
+		for (i = 0; i < pf->num_alloc_vfs; i++) {
+			vf = &pf->vf[i];
+			err = i40e_alloc_port_netdev(vf, I40E_PORT_NETDEV_VF);
+			if (err) {
+				for (j = 0; j < i; j++) {
+					vf = &pf->vf[j];
+					i40e_free_port_netdev(vf,
+							I40E_PORT_NETDEV_VF);
+				}
+				i40e_free_port_netdev(pf, I40E_PORT_NETDEV_PF);
+				goto done;
+			}
+		}
 		pf->eswitch_mode = mode;
 		break;
 	default:
@@ -10874,6 +10907,157 @@ static int i40e_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
 };
 
 /**
+ * i40e_port_netdev_open
+ * @dev: network interface device structure
+ *
+ * Called when port netdevice is brought up.
+ **/
+static int i40e_port_netdev_open(struct net_device *dev)
+{
+	return 0;
+}
+
+/**
+ * i40e_port_netdev_stop
+ * @dev: network interface device structure
+ *
+ * Called when port netdevice is brought down.
+ **/
+static int i40e_port_netdev_stop(struct net_device *dev)
+{
+	return 0;
+}
+
+static const struct net_device_ops i40e_port_netdev_ops = {
+	.ndo_open		= i40e_port_netdev_open,
+	.ndo_stop		= i40e_port_netdev_stop,
+};
+
+/**
+ * i40e_alloc_port_netdev
+ * @f: pointer to the PF or VF structure
+ * @type: port netdev type
+ *
+ * Create Port representor netdev
+ **/
+int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
+{
+	struct net_device *port_netdev;
+	char netdev_name[IFNAMSIZ];
+	struct i40e_port_netdev_priv *priv;
+	struct i40e_pf *pf;
+	struct i40e_vf *vf;
+	struct i40e_vsi *vsi;
+	int err;
+
+	switch (type) {
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)f;
+		vsi = pf->vsi[pf->lan_vsi];
+
+		snprintf(netdev_name, IFNAMSIZ, "%s-pf", vsi->netdev->name);
+		port_netdev = alloc_netdev(sizeof(struct i40e_port_netdev_priv),
+					   netdev_name, NET_NAME_UNKNOWN,
+					   ether_setup);
+		if (!port_netdev) {
+			dev_err(&pf->pdev->dev,
+				"alloc_netdev failed for PF:%s port netdev\n",
+				vsi->netdev->name);
+			return -ENOMEM;
+		}
+		pf->port_netdev = port_netdev;
+		priv = netdev_priv(port_netdev);
+		priv->f = pf;
+		priv->type = I40E_PORT_NETDEV_PF;
+		break;
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)f;
+		pf = vf->pf;
+		vsi = pf->vsi[pf->lan_vsi];
+
+		snprintf(netdev_name, IFNAMSIZ, "%s-vf%d", vsi->netdev->name,
+			 vf->vf_id);
+		port_netdev = alloc_netdev(sizeof(struct i40e_port_netdev_priv),
+					   netdev_name, NET_NAME_UNKNOWN,
+					   ether_setup);
+		if (!port_netdev) {
+			dev_err(&pf->pdev->dev,
+				"alloc_netdev failed for VF%d port netdev\n",
+				vf->vf_id);
+			return -ENOMEM;
+		}
+		vf->port_netdev = port_netdev;
+		priv = netdev_priv(port_netdev);
+		priv->f = vf;
+		priv->type = I40E_PORT_NETDEV_VF;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	port_netdev->netdev_ops = &i40e_port_netdev_ops;
+	eth_hw_addr_random(port_netdev);
+
+	netif_carrier_off(port_netdev);
+	netif_tx_stop_all_queues(port_netdev);
+
+	err = register_netdev(port_netdev);
+	if (err) {
+		dev_err(&pf->pdev->dev, "register_netdev failed for port netdev: %s\n",
+			port_netdev->name);
+		free_netdev(port_netdev);
+		return err;
+	}
+
+	dev_info(&pf->pdev->dev, "%s Port representor %s created\n",
+		 ((type == I40E_PORT_NETDEV_PF) ? "PF" : "VF"),
+		 port_netdev->name);
+
+	return 0;
+}
+
+/**
+ * i40e_free_port_netdev
+ * @pf: pointer to the PF or VF structure
+ * @type: port netdev type
+ *
+ * Free Port representor netdev
+ **/
+void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
+{
+	struct i40e_pf *pf;
+	struct i40e_vf *vf;
+
+	switch (type) {
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)f;
+
+		if (!pf->port_netdev)
+			return;
+		dev_info(&pf->pdev->dev, "Freeing PF Port representor %s\n",
+			 pf->port_netdev->name);
+		unregister_netdev(pf->port_netdev);
+		free_netdev(pf->port_netdev);
+		pf->port_netdev = NULL;
+		break;
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)f;
+		pf = vf->pf;
+
+		if (!vf->port_netdev)
+			return;
+		dev_info(&pf->pdev->dev, "Freeing VF Port representor %s\n",
+			 vf->port_netdev->name);
+		unregister_netdev(vf->port_netdev);
+		free_netdev(vf->port_netdev);
+		vf->port_netdev = NULL;
+		break;
+	default:
+		break;
+	}
+}
+
+/**
  * i40e_probe - Device initialization routine
  * @pdev: PCI device information struct
  * @ent: entry in i40e_pci_tbl
@@ -11474,6 +11658,7 @@ static void i40e_remove(struct pci_dev *pdev)
 			i40e_switch_branch_release(pf->veb[i]);
 	}
 
+	i40e_free_port_netdev(pf, I40E_PORT_NETDEV_PF);
 	/* Now we can shutdown the PF's VSI, just before we kill
 	 * adminq and hmc.
 	 */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 65c95ff..e89f4c4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1081,6 +1081,9 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			i40e_free_vf_res(&pf->vf[i]);
 		/* disable qp mappings */
 		i40e_disable_vf_mappings(&pf->vf[i]);
+
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV)
+			i40e_free_port_netdev(&pf->vf[i], I40E_PORT_NETDEV_VF);
 	}
 
 	kfree(pf->vf);
@@ -1148,6 +1151,12 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		/* VF resources get allocated during reset */
 		i40e_reset_vf(&vfs[i], false);
 
+		if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_SWITCHDEV) {
+			ret = i40e_alloc_port_netdev(&vfs[i],
+						     I40E_PORT_NETDEV_VF);
+			if (ret)
+				goto err_alloc;
+		}
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 37af437..b24d0c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -76,6 +76,12 @@ enum i40e_vf_capabilities {
 struct i40e_vf {
 	struct i40e_pf *pf;
 
+	/* VF Port representor netdev that allows control and configuration
+	 * of VFs from the host. Enables returning VF stats, configuring link
+	 * state, mtu, fdb/vlans, filters etc.
+	 */
+	struct net_device *port_netdev;
+
 	/* VF id in the PF space */
 	s16 vf_id;
 	/* all VF vsis connect to the same parent */
-- 
1.8.3.1
