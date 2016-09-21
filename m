From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: Add support for switchdev API for Switch ID
Date: Tue, 20 Sep 2016 20:43:47 -0700
Message-ID: <1474429432-102772-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:8873 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754846AbcIUDn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:58 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

This patch adds support for switchdev ops on the VF Port representors
and the PF uplink, the only operation implemented is the port attribute
API to get the port parent ID or the switch ID. The switch ID is used
to identify the net_devices attached to the same HW switch.

The switch ID returned for the VF Port representors and the PF uplink
is the phys_port_id.

102: enp9s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 68:05:ca:35:77:50 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 64 numrxqueues 64 portid 6805ca357750 switchid 6805ca357750
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
103: enp9s0f1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 68:05:ca:35:77:51 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 64 numrxqueues 64 portid 6805ca357751 switchid 6805ca357751
104: enp9s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 1 numrxqueues 1 switchid 6805ca357750
105: enp9s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 1 numrxqueues 1 switchid 6805ca357750
    inet6 fe80::200:ff:fe00:0/64 scope link tentative
       valid_lft forever preferred_lft forever

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 17 +++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 57 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  2 +
 4 files changed, 77 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f531f91..22657ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -54,6 +54,7 @@
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
 #include <net/devlink.h>
+#include <net/switchdev.h>
 
 #include "i40e_type.h"
 #include "i40e_prototype.h"
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3fdaf36..3bbf07f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9102,6 +9102,20 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
 };
 
+static int i40e_sw_attr_get(struct net_device *dev, struct switchdev_attr *attr)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_pf *pf = np->vsi->back;
+	int err = 0;
+
+	err = __i40e_sw_attr_get(pf, attr);
+	return err;
+}
+
+static const struct switchdev_ops i40e_switchdev_ops = {
+	.switchdev_port_attr_get	= i40e_sw_attr_get,
+};
+
 /**
  * i40e_config_netdev - Setup the netdev flags
  * @vsi: the VSI being configured
@@ -9199,6 +9213,9 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	netdev->netdev_ops = &i40e_netdev_ops;
 	netdev->watchdog_timeo = 5 * HZ;
 	i40e_set_ethtool_ops(netdev);
+#ifdef CONFIG_NET_SWITCHDEV
+	netdev->switchdev_ops = &i40e_switchdev_ops;
+#endif
 #ifdef I40E_FCOE
 	i40e_fcoe_config_netdev(netdev, vsi);
 #endif
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index da68b00..b90abd3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1027,6 +1027,60 @@ static const struct net_device_ops i40e_vf_netdev_ops = {
 };
 
 /**
+ * __i40e_sw_attr_get
+ * @pf: pointer to the PF structure
+ * @attr: pointer to switchdev_attr structure
+ *
+ * Get switchdev port attributes
+ **/
+int __i40e_sw_attr_get(struct i40e_pf *pf, struct switchdev_attr *attr)
+{
+	struct i40e_hw *hw = &pf->hw;
+
+	if (!(pf->flags & I40E_FLAG_SRIOV_ENABLED))
+		return -EOPNOTSUPP;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		if (!(pf->flags & I40E_FLAG_PORT_ID_VALID))
+			return -EOPNOTSUPP;
+
+		attr->u.ppid.id_len = min_t(int, sizeof(hw->mac.port_addr),
+					    sizeof(attr->u.ppid.id));
+		memcpy(&attr->u.ppid.id, hw->mac.port_addr,
+		       attr->u.ppid.id_len);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_vf_netdev_sw_attr_get
+ * @dev: target device
+ * @attr: pointer to switchdev_attr structure
+ *
+ * Handler for switchdev API to get port attributes for VF Port Representor
+ **/
+static int i40e_vf_netdev_sw_attr_get(struct net_device *dev,
+				      struct switchdev_attr *attr)
+{
+	struct i40e_vf_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+	struct i40e_pf *pf = vf->pf;
+	int err = 0;
+
+	err = __i40e_sw_attr_get(pf, attr);
+	return err;
+}
+
+static const struct switchdev_ops i40e_vf_netdev_switchdev_ops = {
+	.switchdev_port_attr_get	= i40e_vf_netdev_sw_attr_get,
+};
+
+/**
  * i40e_alloc_vf_netdev
  * @vf: pointer to the VF structure
  * @vf_num: VF number
@@ -1058,6 +1112,9 @@ int i40e_alloc_vf_netdev(struct i40e_vf *vf, u16 vf_num)
 
 	netdev->netdev_ops = &i40e_vf_netdev_ops;
 	i40e_set_vf_netdev_ethtool_ops(netdev);
+#ifdef CONFIG_NET_SWITCHDEV
+	netdev->switchdev_ops = &i40e_vf_netdev_switchdev_ops;
+#endif
 
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 1d54b95..049ae59 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -156,4 +156,6 @@ void i40e_vc_notify_reset(struct i40e_pf *pf);
 int i40e_alloc_vf_netdev(struct i40e_vf *vf, u16 vf_num);
 void i40e_free_vf_netdev(struct i40e_vf *vf);
 
+int __i40e_sw_attr_get(struct i40e_pf *pf, struct switchdev_attr *attr);
+
 #endif /* _I40E_VIRTCHNL_PF_H_ */
-- 
2.7.4
