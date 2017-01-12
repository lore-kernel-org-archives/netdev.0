From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v4 PATCH 7/7] i40e: Add support to get switch id and port number for VFPR netdevs
Date: Thu, 12 Jan 2017 14:35:10 -0800
Message-ID: <1484260510-9162-8-git-send-email-sridhar.samudrala@intel.com>
References: <1484260510-9162-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, scott.d.peterson@intel.com,
        gerlitz.or@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22463 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750816AbdALWfU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 17:35:20 -0500
In-Reply-To: <1484260510-9162-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce switchdev_ops to PF and VFPR netdevs to return the switch id
via SWITCHDEV_ATTR_ID_PORT_PARENT_ID attribute.
Also, ndo_get_phys_port_name() support is added to VFPR netdevs to
return the port number.

PF: enp5s0f0, VFs: enp5s2,enp5s2f1 VFPRs:enp5s0f0-vf0, enp5s0f0-vf1
# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
# ip -d l show enp5s0f0
32: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 72 numrxqueues 72 gso_max_size 65536 gso_max_segs 65535 portid 6805ca2e7268 switchid 6805ca2e7268
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
# ip -d l show enp5s0f0-vf0
34: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535 portname 0 switchid 6805ca2e7268
# ip -d l show enp5s0f0-vf1
35: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535 portname 1 switchid 6805ca2e7268

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 28 +++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 40 ++++++++++++++++++++++
 3 files changed, 69 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 95cfe46..61720d6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -56,6 +56,7 @@
 #include <linux/ptp_clock_kernel.h>
 #include <net/devlink.h>
 #include <net/dst_metadata.h>
+#include <net/switchdev.h>
 
 #include "i40e_type.h"
 #include "i40e_prototype.h"
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9212656..cd55665 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9650,6 +9650,31 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_xdp                = i40e_xdp,
 };
 
+static int i40e_pf_attr_get(struct net_device *dev, struct switchdev_attr *attr)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+
+	if (pf->eswitch_mode == DEVLINK_ESWITCH_MODE_LEGACY)
+		return -EOPNOTSUPP;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		attr->u.ppid.id_len = ETH_ALEN;
+		ether_addr_copy(attr->u.ppid.id, dev->dev_addr);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static const struct switchdev_ops i40e_pf_switchdev_ops = {
+	.switchdev_port_attr_get        = i40e_pf_attr_get,
+};
+
 /**
  * i40e_config_netdev - Setup the netdev flags
  * @vsi: the VSI being configured
@@ -9769,6 +9794,9 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 #ifdef I40E_FCOE
 	i40e_fcoe_config_netdev(netdev, vsi);
 #endif
+#ifdef CONFIG_NET_SWITCHDEV
+	netdev->switchdev_ops = &i40e_pf_switchdev_ops;
+#endif
 
 	/* MTU range: 68 - 9706 */
 	netdev->min_mtu = ETH_MIN_MTU;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1af8472..465154f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1154,6 +1154,22 @@ i40e_vfpr_netdev_get_offload_stats(int attr_id, const struct net_device *dev,
 	return -EINVAL;
 }
 
+static int
+i40e_vfpr_netdev_get_phys_port_name(struct net_device *dev, char *buf,
+				    size_t len)
+{
+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf = priv->vf;
+
+	int ret;
+
+	ret = snprintf(buf, len, "%d", vf->vf_id);
+	if (ret >= len)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
 static const struct net_device_ops i40e_vfpr_netdev_ops = {
 	.ndo_open		= i40e_vfpr_netdev_open,
 	.ndo_stop		= i40e_vfpr_netdev_stop,
@@ -1161,6 +1177,26 @@ static const struct net_device_ops i40e_vfpr_netdev_ops = {
 	.ndo_get_stats64        = i40e_vfpr_netdev_get_stats64,
 	.ndo_has_offload_stats  = i40e_vfpr_netdev_has_offload_stats,
 	.ndo_get_offload_stats  = i40e_vfpr_netdev_get_offload_stats,
+	.ndo_get_phys_port_name	= i40e_vfpr_netdev_get_phys_port_name,
+};
+
+static int i40e_vfpr_attr_get(struct net_device *dev,
+			      struct switchdev_attr *attr)
+{
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		attr->u.ppid.id_len = ETH_ALEN;
+		ether_addr_copy(attr->u.ppid.id, dev->dev_addr);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static const struct switchdev_ops i40e_vfpr_switchdev_ops = {
+	.switchdev_port_attr_get        = i40e_vfpr_attr_get,
 };
 
 /**
@@ -1235,6 +1271,10 @@ int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
 	vfpr_netdev->netdev_ops = &i40e_vfpr_netdev_ops;
 	eth_hw_addr_inherit(vfpr_netdev, vsi->netdev);
 
+#ifdef CONFIG_NET_SWITCHDEV
+	vfpr_netdev->switchdev_ops = &i40e_vfpr_switchdev_ops;
+#endif
+
 	netif_carrier_off(vfpr_netdev);
 	netif_tx_disable(vfpr_netdev);
 
-- 
2.5.5
