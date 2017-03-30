From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 7/7] i40e: Add support to get switch id and port number for port netdevs
Date: Wed, 29 Mar 2017 17:22:55 -0700
Message-ID: <1490833375-2788-8-git-send-email-sridhar.samudrala@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25988 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933116AbdC3AXA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:23:00 -0400
In-Reply-To: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce switchdev_ops to PF and port netdevs to return the switch id via
SWITCHDEV_ATTR_ID_PORT_PARENT_ID attribute.
Also, ndo_get_phys_port_name() support is added to port netdevs to return
the port number.

PF: p4p1, VFs: p4p1_0,p4p1_1, VF port reps:p4p1-vf0, p4p1-vf1,
PF port rep: p4p1-pf
# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:42:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
# ip -d l show p4p1
27: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 3c:fd:fe:a3:18:f8 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 64 numrxqueues 64 gso_max_size 65536 gso_max_segs 65535 portid 3cfdfea318f8 switchid 3cfdfea318f8
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state disable, trust off
# ip -d l show p4p1-pf
29: p4p1-pf: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 42:7a:b5:dc:85:11 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535 portname 65535 switchid 3cfdfea318f8
# ip -d l show p4p1-vf0
30: p4p1-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 6e:ff:0b:5a:63:6d brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535 portname 0 switchid 3cfdfea318f8
# ip -d l show p4p1-vf1
31: p4p1-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:6e:ff:35:05:d5 brd ff:ff:ff:ff:ff:ff promiscuity 0 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535 portname 1 switchid 3cfdfea318f8

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 97 +++++++++++++++++++++++++++++
 2 files changed, 98 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 72e11b2..9eb2ba5 100644
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
index 4f0eebc..85f214d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4862,6 +4862,32 @@ static int i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi, u8 enabled_tc,
 	return 0;
 }
 
+static int i40e_switchdev_pf_attr_get(struct net_device *dev,
+				      struct switchdev_attr *attr)
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
+static const struct switchdev_ops i40e_switchdev_pf_ops = {
+	.switchdev_port_attr_get	= i40e_switchdev_pf_attr_get,
+};
+
 /**
  * i40e_vsi_config_netdev_tc - Setup the netdev TC configuration
  * @vsi: the VSI being configured
@@ -9364,6 +9390,9 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	netdev->netdev_ops = &i40e_netdev_ops;
 	netdev->watchdog_timeo = 5 * HZ;
 	i40e_set_ethtool_ops(netdev);
+#ifdef CONFIG_NET_SWITCHDEV
+	netdev->switchdev_ops = &i40e_switchdev_pf_ops;
+#endif
 
 	/* MTU range: 68 - 9706 */
 	netdev->min_mtu = ETH_MIN_MTU;
@@ -11111,6 +11140,32 @@ static int i40e_port_netdev_stop(struct net_device *dev)
 	return -EINVAL;
 }
 
+static int
+i40e_port_netdev_get_phys_port_name(struct net_device *dev, char *buf,
+				    size_t len)
+{
+	struct i40e_port_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vf *vf;
+	int ret;
+
+	switch (priv->type) {
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)priv->f;
+		ret = snprintf(buf, len, "%d", vf->vf_id);
+		break;
+	case I40E_PORT_NETDEV_PF:
+		ret = snprintf(buf, len, "%d", I40E_MAIN_VSI_PORT_ID);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	if (ret >= len)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
 static const struct net_device_ops i40e_port_netdev_ops = {
 	.ndo_open		= i40e_port_netdev_open,
 	.ndo_stop		= i40e_port_netdev_stop,
@@ -11118,6 +11173,44 @@ static int i40e_port_netdev_stop(struct net_device *dev)
 	.ndo_get_stats64	= i40e_port_netdev_get_stats64,
 	.ndo_has_offload_stats	= i40e_port_netdev_has_offload_stats,
 	.ndo_get_offload_stats	= i40e_port_netdev_get_offload_stats,
+	.ndo_get_phys_port_name	= i40e_port_netdev_get_phys_port_name,
+};
+
+static int i40e_switchdev_port_attr_get(struct net_device *dev,
+					struct switchdev_attr *attr)
+{
+	struct i40e_port_netdev_priv *priv = netdev_priv(dev);
+	struct i40e_vsi *vsi;
+	struct i40e_pf *pf;
+	struct i40e_vf *vf;
+
+	switch (priv->type) {
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)priv->f;
+		pf = vf->pf;
+		break;
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)priv->f;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	vsi = pf->vsi[pf->lan_vsi];
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
+		attr->u.ppid.id_len = ETH_ALEN;
+		ether_addr_copy(attr->u.ppid.id, vsi->netdev->dev_addr);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static const struct switchdev_ops i40e_switchdev_port_ops = {
+	.switchdev_port_attr_get	= i40e_switchdev_port_attr_get,
 };
 
 /**
@@ -11203,6 +11296,10 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
 	port_netdev->netdev_ops = &i40e_port_netdev_ops;
 	eth_hw_addr_random(port_netdev);
 
+#ifdef CONFIG_NET_SWITCHDEV
+	port_netdev->switchdev_ops = &i40e_switchdev_port_ops;
+#endif
+
 	netif_carrier_off(port_netdev);
 	netif_tx_stop_all_queues(port_netdev);
 
-- 
1.8.3.1
