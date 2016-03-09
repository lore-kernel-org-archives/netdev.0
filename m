From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 2/2] net: dsa: support SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF
Date: Wed,  9 Mar 2016 12:42:48 -0500
Message-ID: <1457545368-20647-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58645 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397AbcCIRnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:43:10 -0500
In-Reply-To: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new dsa_slave_bridge_if function to handle the
SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF switchdev attribute.

Thus remove the code related to the netdev notifier block.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c      |   7 ----
 net/dsa/dsa_priv.h |   2 -
 net/dsa/slave.c    | 113 ++++++++++++++---------------------------------------
 3 files changed, 30 insertions(+), 92 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fa4daba..cfb678b 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -977,10 +977,6 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
-static struct notifier_block dsa_netdevice_nb __read_mostly = {
-	.notifier_call	= dsa_slave_netdevice_event,
-};
-
 #ifdef CONFIG_PM_SLEEP
 static int dsa_suspend(struct device *d)
 {
@@ -1047,8 +1043,6 @@ static int __init dsa_init_module(void)
 {
 	int rc;
 
-	register_netdevice_notifier(&dsa_netdevice_nb);
-
 	rc = platform_driver_register(&dsa_driver);
 	if (rc)
 		return rc;
@@ -1061,7 +1055,6 @@ module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
-	unregister_netdevice_notifier(&dsa_netdevice_nb);
 	dev_remove_pack(&dsa_pack_type);
 	platform_driver_unregister(&dsa_driver);
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1d1a546..34d1951 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -64,8 +64,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
-int dsa_slave_netdevice_event(struct notifier_block *unused,
-			      unsigned long event, void *ptr);
 
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 27bf03d..90ef149 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -305,16 +305,38 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_stp_update(struct net_device *dev, u8 state)
+static int dsa_slave_bridge_if(struct net_device *dev,
+			       const struct switchdev_attr *attr,
+			       struct switchdev_trans *trans)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
+	int err;
 
-	if (ds->drv->port_stp_update)
-		ret = ds->drv->port_stp_update(ds, p->port, state);
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (!ds->drv->port_join_bridge || !ds->drv->port_leave_bridge)
+			return -EOPNOTSUPP;
+		return 0;
+	}
 
-	return ret;
+	if (attr->u.join) {
+		err = ds->drv->port_join_bridge(ds, p->port, attr->orig_dev);
+		if (!err)
+			p->bridge_dev = attr->orig_dev;
+	} else {
+		err = ds->drv->port_leave_bridge(ds, p->port);
+
+		/* When a port leaves a bridge, the bridge layer sets its STP
+		 * state to DISABLED. Restore FORWARDING to keep it functional.
+		 */
+		if (ds->drv->port_stp_update)
+			ds->drv->port_stp_update(ds, p->port,
+						 BR_STATE_FORWARDING);
+
+		p->bridge_dev = NULL;
+	}
+
+	return err;
 }
 
 static int dsa_slave_vlan_filtering(struct net_device *dev,
@@ -354,6 +376,9 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
 		ret = dsa_slave_vlan_filtering(dev, attr, trans);
 		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF:
+		ret = dsa_slave_bridge_if(dev, attr, trans);
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
@@ -439,41 +464,6 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
-static int dsa_slave_bridge_port_join(struct net_device *dev,
-				      struct net_device *br)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
-
-	p->bridge_dev = br;
-
-	if (ds->drv->port_join_bridge)
-		ret = ds->drv->port_join_bridge(ds, p->port, br);
-
-	return ret;
-}
-
-static int dsa_slave_bridge_port_leave(struct net_device *dev)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
-
-
-	if (ds->drv->port_leave_bridge)
-		ret = ds->drv->port_leave_bridge(ds, p->port);
-
-	p->bridge_dev = NULL;
-
-	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
-	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
-	 */
-	dsa_slave_stp_update(dev, BR_STATE_FORWARDING);
-
-	return ret;
-}
-
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
@@ -1136,46 +1126,3 @@ void dsa_slave_destroy(struct net_device *slave_dev)
 	unregister_netdev(slave_dev);
 	free_netdev(slave_dev);
 }
-
-static bool dsa_slave_dev_check(struct net_device *dev)
-{
-	return dev->netdev_ops == &dsa_slave_netdev_ops;
-}
-
-static int dsa_slave_master_changed(struct net_device *dev)
-{
-	struct net_device *master = netdev_master_upper_dev_get(dev);
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	int err = 0;
-
-	if (master && master->rtnl_link_ops &&
-	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
-		err = dsa_slave_bridge_port_join(dev, master);
-	else if (dsa_port_is_bridged(p))
-		err = dsa_slave_bridge_port_leave(dev);
-
-	return err;
-}
-
-int dsa_slave_netdevice_event(struct notifier_block *unused,
-			      unsigned long event, void *ptr)
-{
-	struct net_device *dev;
-	int err = 0;
-
-	switch (event) {
-	case NETDEV_CHANGEUPPER:
-		dev = netdev_notifier_info_to_dev(ptr);
-		if (!dsa_slave_dev_check(dev))
-			goto out;
-
-		err = dsa_slave_master_changed(dev);
-		if (err && err != -EOPNOTSUPP)
-			netdev_warn(dev, "failed to reflect master change\n");
-
-		break;
-	}
-
-out:
-	return NOTIFY_DONE;
-}
-- 
2.7.2
