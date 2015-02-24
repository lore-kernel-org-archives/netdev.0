From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 2/3] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Tue, 24 Feb 2015 13:15:33 -0800
Message-ID: <1424812534-8936-3-git-send-email-f.fainelli@gmail.com>
References: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34078 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbbBXVT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:19:26 -0500
Received: by pdjg10 with SMTP id g10so36263673pdj.1
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:19:26 -0800 (PST)
In-Reply-To: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
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

We also take care of setting the correct STP state when slave network
devices are brought up/down while being bridge members.

Finally, when a port is leaving the bridge, we make sure we set in
BR_STATE_FORWARDING state, otherwise the bridge layer would leave it
disabled as a result of having left the bridge.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v3:
- add a NULL pointer check against ds->ports[port]

 include/net/dsa.h  |  10 ++++
 net/dsa/Kconfig    |   1 +
 net/dsa/dsa.c      |   7 +++
 net/dsa/dsa_priv.h |   4 ++
 net/dsa/slave.c    | 149 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 171 insertions(+)

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
index fc1813140be6..9c208f0dab08 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -826,6 +826,10 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
+static struct notifier_block dsa_netdevice_nb __read_mostly = {
+	.notifier_call	= dsa_slave_netdevice_event,
+};
+
 #ifdef CONFIG_PM_SLEEP
 static int dsa_suspend(struct device *d)
 {
@@ -884,6 +888,8 @@ static int __init dsa_init_module(void)
 {
 	int rc;
 
+	register_netdevice_notifier(&dsa_netdevice_nb);
+
 	rc = platform_driver_register(&dsa_driver);
 	if (rc)
 		return rc;
@@ -896,6 +902,7 @@ module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
+	unregister_netdevice_notifier(&dsa_netdevice_nb);
 	dev_remove_pack(&dsa_pack_type);
 	platform_driver_unregister(&dsa_driver);
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7eb1a6acd46c..d5f1f9b862ea 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -45,6 +45,8 @@ struct dsa_slave_priv {
 	int			old_link;
 	int			old_pause;
 	int			old_duplex;
+
+	struct net_device	*bridge_dev;
 };
 
 /* dsa.c */
@@ -57,6 +59,8 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, char *name);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
+int dsa_slave_netdevice_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr);
 
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5be4c928c9c9..b5a4d8974b76 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -10,10 +10,13 @@
 
 #include <linux/list.h>
 #include <linux/etherdevice.h>
+#include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
+#include <net/rtnetlink.h>
+#include <linux/if_bridge.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -60,11 +63,18 @@ static int dsa_slave_init(struct net_device *dev)
 	return 0;
 }
 
+static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
+{
+	return !!p->bridge_dev;
+}
+
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = p->parent->dst->master_netdev;
 	struct dsa_switch *ds = p->parent;
+	u8 stp_state = dsa_port_is_bridged(p) ?
+			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
 	if (!(master->flags & IFF_UP))
@@ -93,6 +103,9 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_promisc;
 	}
 
+	if (ds->drv->port_stp_update)
+		ds->drv->port_stp_update(ds, p->port, stp_state);
+
 	if (p->phy)
 		phy_start(p->phy);
 
@@ -133,6 +146,9 @@ static int dsa_slave_close(struct net_device *dev)
 	if (ds->drv->port_disable)
 		ds->drv->port_disable(ds, p->port, p->phy);
 
+	if (ds->drv->port_stp_update)
+		ds->drv->port_stp_update(ds, p->port, BR_STATE_DISABLED);
+
 	return 0;
 }
 
@@ -194,6 +210,95 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+/* Return a bitmask of all ports being currently bridged within a given bridge
+ * device. Note that on leave, the mask will still return the bitmask of ports
+ * currently bridged, prior to port removal, and this is exactly what we want.
+ */
+static u32 dsa_slave_br_port_mask(struct dsa_switch *ds,
+				  struct net_device *bridge)
+{
+	struct dsa_slave_priv *p;
+	unsigned int port;
+	u32 mask = 0;
+
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if (!((1 << port) & ds->phys_port_mask))
+			continue;
+
+		if (!ds->ports[port])
+			continue;
+
+		p = netdev_priv(ds->ports[port]);
+
+		if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT &&
+		    p->bridge_dev == bridge)
+			mask |= 1 << port;
+	}
+
+	return mask;
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
+static int dsa_slave_bridge_port_join(struct net_device *dev,
+				      struct net_device *br)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	p->bridge_dev = br;
+
+	if (ds->drv->port_join_bridge)
+		ret = ds->drv->port_join_bridge(ds, p->port,
+						dsa_slave_br_port_mask(ds, br));
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
+
+	if (ds->drv->port_leave_bridge)
+		ret = ds->drv->port_leave_bridge(ds, p->port,
+						 dsa_slave_br_port_mask(ds, p->bridge_dev));
+
+	p->bridge_dev = NULL;
+
+	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
+	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
+	 */
+	dsa_slave_stp_update(dev, BR_STATE_FORWARDING);
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
 static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -470,6 +575,8 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_switch_parent_id_get = dsa_slave_parent_id_get,
+	.ndo_switch_port_stp_update = dsa_slave_stp_update,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
@@ -684,3 +791,45 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	return 0;
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
+	struct net_device *dev;
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
