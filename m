From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v3] net: dummy: Introduce dummy virtual functions
Date: Wed, 23 Nov 2016 13:41:25 +0100
Message-ID: <20161123124125.3374-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46195 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934685AbcKWMl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 07:41:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea for this was born when testing VF support in iproute2 which was
impeded by hardware requirements. In fact, not every VF-capable hardware
driver implements all netdev ops, so testing the interface is still hard
to do even with a well-sorted hardware shelf.

To overcome this and allow for testing the user-kernel interface, this
patch allows to turn dummy into a PF with a configurable amount of VFs.

Due to the assumption that all PFs are PCI devices, this implementation
is not completely straightforward: In order to allow for
rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
attached to the dummy netdev. This has to happen at the right spot so
register_netdevice() does not get confused. This patch abuses
ndo_fix_features callback for that. In ndo_uninit callback, the fake
parent is removed again for the same purpose.

Joint work with Sabrina Dubroca.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Fixed oops on reboot (need to initialize parent device mutex).
- Got rid of potential mem leak noticed by Eric Dumazet.
- Dropped stray newline insertion.

Changes since v1:
- Fixed issues reported by kbuild test robot:
  - pci_dev->sriov is only present if CONFIG_PCI_ATS is active.
  - pci_bus_type does not exist if CONFIG_PCI is not defined.
---
 drivers/net/dummy.c | 205 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 203 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 69fc8409a9733..829eb552c63c5 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -34,6 +34,8 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
+#include <linux/pci.h>
+#include "../pci/pci.h"		/* for struct pci_sriov */
 #include <linux/rtnetlink.h>
 #include <net/rtnetlink.h>
 #include <linux/u64_stats_sync.h>
@@ -42,6 +44,37 @@
 #define DRV_VERSION	"1.0"
 
 static int numdummies = 1;
+static int num_vfs;
+
+static struct pci_sriov pdev_sriov;
+
+static struct pci_dev pci_pdev = {
+	.is_physfn = 0,
+#ifdef CONFIG_PCI_ATS
+	.sriov = &pdev_sriov,
+#endif
+#ifdef CONFIG_PCI
+	.dev.bus = &pci_bus_type,
+#endif
+};
+
+struct vf_data_storage {
+	unsigned char vf_mac[ETH_ALEN];
+	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
+	u16 pf_qos;
+	__be16 vlan_proto;
+	u16 min_tx_rate;
+	u16 max_tx_rate;
+	u8 spoofchk_enabled;
+	bool rss_query_enabled;
+	u8 trusted;
+	int link_state;
+};
+
+struct dummy_priv {
+	int num_vfs;
+	struct vf_data_storage *vfinfo;
+};
 
 /* fake multicast ability */
 static void set_multicast_list(struct net_device *dev)
@@ -91,15 +124,31 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int dummy_dev_init(struct net_device *dev)
 {
+	struct dummy_priv *priv = netdev_priv(dev);
+
 	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
 	if (!dev->dstats)
 		return -ENOMEM;
 
+	priv->num_vfs = num_vfs;
+	priv->vfinfo = NULL;
+
+	if (!num_vfs)
+		return 0;
+
+	priv->vfinfo = kcalloc(num_vfs, sizeof(struct vf_data_storage),
+			       GFP_KERNEL);
+	if (!priv->vfinfo) {
+		free_percpu(dev->dstats);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
 static void dummy_dev_uninit(struct net_device *dev)
 {
+	dev->dev.parent = NULL;
 	free_percpu(dev->dstats);
 }
 
@@ -112,6 +161,134 @@ static int dummy_change_carrier(struct net_device *dev, bool new_carrier)
 	return 0;
 }
 
+/* fake, just to set fake PCI parent after netdev_register_kobject() */
+static netdev_features_t dummy_fix_features(struct net_device *dev,
+					    netdev_features_t features)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (priv->num_vfs) {
+		dev->dev.parent = &pci_pdev.dev;
+		if (!pci_pdev.is_physfn) {
+			mutex_init(&pci_pdev.dev.mutex);
+			pci_pdev.is_physfn = 1;
+		}
+	}
+
+	return features;
+}
+
+static int dummy_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (!is_valid_ether_addr(mac) || (vf >= priv->num_vfs))
+		return -EINVAL;
+
+	memcpy(priv->vfinfo[vf].vf_mac, mac, ETH_ALEN);
+
+	return 0;
+}
+
+static int dummy_set_vf_vlan(struct net_device *dev, int vf,
+			     u16 vlan, u8 qos, __be16 vlan_proto)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if ((vf >= priv->num_vfs) || (vlan > 4095) || (qos > 7))
+		return -EINVAL;
+
+	priv->vfinfo[vf].pf_vlan = vlan;
+	priv->vfinfo[vf].pf_qos = qos;
+	priv->vfinfo[vf].vlan_proto = vlan_proto;
+
+	return 0;
+}
+
+static int dummy_set_vf_rate(struct net_device *dev, int vf, int min, int max)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (vf >= priv->num_vfs)
+		return -EINVAL;
+
+	priv->vfinfo[vf].min_tx_rate = min;
+	priv->vfinfo[vf].max_tx_rate = max;
+
+	return 0;
+}
+
+static int dummy_set_vf_spoofchk(struct net_device *dev, int vf, bool val)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (vf >= priv->num_vfs)
+		return -EINVAL;
+
+	priv->vfinfo[vf].spoofchk_enabled = val;
+
+	return 0;
+}
+
+static int dummy_set_vf_rss_query_en(struct net_device *dev, int vf, bool val)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (vf >= priv->num_vfs)
+		return -EINVAL;
+
+	priv->vfinfo[vf].rss_query_enabled = val;
+
+	return 0;
+}
+
+static int dummy_set_vf_trust(struct net_device *dev, int vf, bool val)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (vf >= priv->num_vfs)
+		return -EINVAL;
+
+	priv->vfinfo[vf].trusted = val;
+
+	return 0;
+}
+
+static int dummy_get_vf_config(struct net_device *dev,
+			       int vf, struct ifla_vf_info *ivi)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (vf >= priv->num_vfs)
+		return -EINVAL;
+
+	ivi->vf = vf;
+	memcpy(&ivi->mac, priv->vfinfo[vf].vf_mac, ETH_ALEN);
+	ivi->vlan = priv->vfinfo[vf].pf_vlan;
+	ivi->qos = priv->vfinfo[vf].pf_qos;
+	ivi->spoofchk = priv->vfinfo[vf].spoofchk_enabled;
+	ivi->linkstate = priv->vfinfo[vf].link_state;
+	ivi->min_tx_rate = priv->vfinfo[vf].min_tx_rate;
+	ivi->max_tx_rate = priv->vfinfo[vf].max_tx_rate;
+	ivi->rss_query_en = priv->vfinfo[vf].rss_query_enabled;
+	ivi->trusted = priv->vfinfo[vf].trusted;
+	ivi->vlan_proto = priv->vfinfo[vf].vlan_proto;
+
+	return 0;
+}
+
+static int dummy_set_vf_link_state(struct net_device *dev, int vf, int state)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	if (vf >= priv->num_vfs)
+		return -EINVAL;
+
+	priv->vfinfo[vf].link_state = state;
+
+	return 0;
+}
+
 static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_init		= dummy_dev_init,
 	.ndo_uninit		= dummy_dev_uninit,
@@ -121,6 +298,15 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_get_stats64	= dummy_get_stats64,
 	.ndo_change_carrier	= dummy_change_carrier,
+	.ndo_fix_features	= dummy_fix_features,
+	.ndo_set_vf_mac		= dummy_set_vf_mac,
+	.ndo_set_vf_vlan	= dummy_set_vf_vlan,
+	.ndo_set_vf_rate	= dummy_set_vf_rate,
+	.ndo_set_vf_spoofchk	= dummy_set_vf_spoofchk,
+	.ndo_set_vf_trust	= dummy_set_vf_trust,
+	.ndo_get_vf_config	= dummy_get_vf_config,
+	.ndo_set_vf_link_state	= dummy_set_vf_link_state,
+	.ndo_set_vf_rss_query_en = dummy_set_vf_rss_query_en,
 };
 
 static void dummy_get_drvinfo(struct net_device *dev,
@@ -134,6 +320,14 @@ static const struct ethtool_ops dummy_ethtool_ops = {
 	.get_drvinfo            = dummy_get_drvinfo,
 };
 
+static void dummy_free_netdev(struct net_device *dev)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	kfree(priv->vfinfo);
+	free_netdev(dev);
+}
+
 static void dummy_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -141,7 +335,7 @@ static void dummy_setup(struct net_device *dev)
 	/* Initialize the device structure. */
 	dev->netdev_ops = &dummy_netdev_ops;
 	dev->ethtool_ops = &dummy_ethtool_ops;
-	dev->destructor = free_netdev;
+	dev->destructor = dummy_free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
 	dev->flags |= IFF_NOARP;
@@ -169,6 +363,7 @@ static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 	.kind		= DRV_NAME,
+	.priv_size	= sizeof(struct dummy_priv),
 	.setup		= dummy_setup,
 	.validate	= dummy_validate,
 };
@@ -177,12 +372,16 @@ static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 
+module_param(num_vfs, int, 0);
+MODULE_PARM_DESC(num_vfs, "Number of dummy VFs per dummy device");
+
 static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
 	int err;
 
-	dev_dummy = alloc_netdev(0, "dummy%d", NET_NAME_UNKNOWN, dummy_setup);
+	dev_dummy = alloc_netdev(sizeof(struct dummy_priv),
+				 "dummy%d", NET_NAME_UNKNOWN, dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
 
@@ -201,6 +400,8 @@ static int __init dummy_init_module(void)
 {
 	int i, err = 0;
 
+	pdev_sriov.num_VFs = num_vfs;
+
 	rtnl_lock();
 	err = __rtnl_link_register(&dummy_link_ops);
 	if (err < 0)
-- 
2.10.0
