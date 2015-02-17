From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 11:26:35 -0800
Message-ID: <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:46958 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbbBQT1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 14:27:36 -0500
Received: by pdjy10 with SMTP id y10so45722621pdj.13
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 11:27:35 -0800 (PST)
In-Reply-To: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support bridging offloads in DSA switch drivers, select
NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
NDOs that we are required to implement.

To facilitate the integratation at the DSA driver level, we implement 3
types of operations:

- port_join_bridge
- port_leave_bridge
- port_stp_update

DSA will resolve which switch ports that are currently bridge port
members as some Switch hardware/drivers need to know about that to limit
the register programming to just the relevant registers (especially for
slow MDIO buses).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  |  10 +++++
 net/dsa/Kconfig    |   1 +
 net/dsa/dsa.c      |   7 ++++
 net/dsa/dsa_priv.h |   2 +
 net/dsa/slave.c    | 117 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 137 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ed3c34bbb67a..92be34791963 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -275,6 +275,16 @@ struct dsa_switch_driver {
 	int	(*get_regs_len)(struct dsa_switch *ds, int port);
 	void	(*get_regs)(struct dsa_switch *ds, int port,
 			    struct ethtool_regs *regs, void *p);
+
+	/*
+	 * Bridge integration
+	 */
+	int	(*port_join_bridge)(struct dsa_switch *ds, int port,
+				    u32 br_port_mask);
+	int	(*port_leave_bridge)(struct dsa_switch *ds, int port,
+				     u32 br_port_mask);
+	int	(*port_stp_update)(struct dsa_switch *ds, int port,
+				   u8 state);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 5f8ac404535b..b45206e8dd3e 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -8,6 +8,7 @@ config NET_DSA
 	tristate
 	depends on HAVE_NET_DSA
 	select PHYLIB
+	select NET_SWITCHDEV
 
 if NET_DSA
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 2173402d87e0..293e0c3cc445 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -830,6 +830,10 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
+static struct notifier_block dsa_netdevice_nb __read_mostly = {
+	.notifier_call	= dsa_slave_netdevice_event,
+};
+
 #ifdef CONFIG_PM_SLEEP
 static int dsa_suspend(struct device *d)
 {
@@ -888,6 +892,8 @@ static int __init dsa_init_module(void)
 {
 	int rc;
 
+	register_netdevice_notifier(&dsa_netdevice_nb);
+
 	rc = platform_driver_register(&dsa_driver);
 	if (rc)
 		return rc;
@@ -900,6 +906,7 @@ module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
+	unregister_netdevice_notifier(&dsa_netdevice_nb);
 	dev_remove_pack(&dsa_pack_type);
 	platform_driver_unregister(&dsa_driver);
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index dc9756d3154c..e6f4301e719e 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -58,6 +58,8 @@ struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    int port, char *name);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
+int dsa_slave_netdevice_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr);
 
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d104ae15836f..ea31b9be320f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -10,10 +10,12 @@
 
 #include <linux/list.h>
 #include <linux/etherdevice.h>
+#include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
+#include <net/rtnetlink.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -194,6 +196,77 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+/* Return a bitmask of all ports being currently bridged. Note that on
+ * leave, the mask will still return the bitmask of ports currently bridged,
+ * prior to port removal, and this is exactly what we want.
+ */
+static u32 dsa_slave_br_port_mask(struct dsa_switch *ds)
+{
+	unsigned int port;
+	u32 mask = 0;
+
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if (!((1 << port) & ds->phys_port_mask))
+			continue;
+
+		if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT)
+			mask |= 1 << port;
+	}
+
+       return mask;
+}
+
+static int dsa_slave_bridge_port_join(struct net_device *dev,
+				      struct net_device *bridge)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->drv->port_join_bridge)
+		ret = ds->drv->port_join_bridge(ds, p->port,
+						dsa_slave_br_port_mask(ds));
+
+	return ret;
+}
+
+static int dsa_slave_bridge_port_leave(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->drv->port_leave_bridge)
+		ret = ds->drv->port_leave_bridge(ds, p->port,
+						 dsa_slave_br_port_mask(ds));
+
+	return ret;
+}
+
+static int dsa_slave_parent_id_get(struct net_device *dev,
+				   struct netdev_phys_item_id *psid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	psid->id_len = sizeof(ds->index);
+	memcpy(&psid->id, &ds->index, psid->id_len);
+
+	return 0;
+}
+
+static int dsa_slave_stp_update(struct net_device *dev, u8 state)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->drv->port_stp_update)
+		ret = ds->drv->port_stp_update(ds, p->port, state);
+
+	return ret;
+}
+
 static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -470,6 +543,8 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_switch_parent_id_get = dsa_slave_parent_id_get,
+	.ndo_switch_port_stp_update = dsa_slave_stp_update,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
@@ -678,3 +753,45 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	return slave_dev;
 }
+
+static bool dsa_slave_dev_check(struct net_device *dev)
+{
+	return dev->netdev_ops == &dsa_slave_netdev_ops;
+}
+
+static int dsa_slave_master_changed(struct net_device *dev)
+{
+	struct net_device *master = netdev_master_upper_dev_get(dev);
+	int err = 0;
+
+	if (master && master->rtnl_link_ops &&
+	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
+		err = dsa_slave_bridge_port_join(dev, master);
+	else
+		err = dsa_slave_bridge_port_leave(dev);
+
+	return err;
+}
+
+int dsa_slave_netdevice_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr)
+{
+	struct netdevice_dev *dev;
+	int err = 0;
+
+	switch (event) {
+	case NETDEV_CHANGEUPPER:
+		dev = netdev_notifier_info_to_dev(ptr);
+		if (!dsa_slave_dev_check(dev))
+			goto out;
+
+		err = dsa_slave_master_changed(dev);
+		if (err)
+			netdev_warn(dev, "failed to reflect master change\n");
+
+		break;
+	}
+
+out:
+	return NOTIFY_DONE;
+}
-- 
2.1.0
