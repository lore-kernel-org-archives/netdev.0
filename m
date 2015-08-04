From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/4] net: dsa: add support for switchdev FDB objects
Date: Tue,  4 Aug 2015 02:30:58 -0400
Message-ID: <1438669859-29800-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1438669859-29800-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438669859-29800-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the fdb_{add,del,getnext} function pointer in favor of new
port_fdb_{add,del,getnext}.

Implement the switchdev_port_obj_{add,del,dump} functions in DSA to
support the SWITCHDEV_OBJ_PORT_FDB objects.

These functions are called from switchdev_port_bridge_{get,set,del}link.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |   3 -
 drivers/net/dsa/mv88e6352.c |   3 -
 include/net/dsa.h           |  16 ++--
 net/dsa/slave.c             | 221 ++++++++++++++++++++++++--------------------
 4 files changed, 129 insertions(+), 114 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 1c78084..cfa21ed 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -116,9 +116,6 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_join_bridge       = mv88e6xxx_join_bridge,
 	.port_leave_bridge      = mv88e6xxx_leave_bridge,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
-	.fdb_add		= mv88e6xxx_port_fdb_add,
-	.fdb_del		= mv88e6xxx_port_fdb_del,
-	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index af210ef..eb4630f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -341,9 +341,6 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
-	.fdb_add		= mv88e6xxx_port_fdb_add,
-	.fdb_del		= mv88e6xxx_port_fdb_del,
-	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63b..a090c8a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -296,12 +296,16 @@ struct dsa_switch_driver {
 				     u32 br_port_mask);
 	int	(*port_stp_update)(struct dsa_switch *ds, int port,
 				   u8 state);
-	int	(*fdb_add)(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-	int	(*fdb_del)(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-	int	(*fdb_getnext)(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static);
+
+	/*
+	 * Forwarding database
+	 */
+	int	(*port_fdb_add)(struct dsa_switch *ds, int port, u16 vid,
+				u8 addr[ETH_ALEN]);
+	int	(*port_fdb_del)(struct dsa_switch *ds, int port, u16 vid,
+				u8 addr[ETH_ALEN]);
+	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port, u16 *vid,
+				    u8 addr[ETH_ALEN], bool *is_static);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0010c69..0f99a17 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -19,6 +19,7 @@
 #include <net/switchdev.h>
 #include <linux/if_bridge.h>
 #include <linux/netpoll.h>
+#include <linux/if_vlan.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -200,105 +201,6 @@ out:
 	return 0;
 }
 
-static int dsa_slave_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			     struct net_device *dev,
-			     const unsigned char *addr, u16 vid, u16 nlm_flags)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
-
-	if (ds->drv->fdb_add)
-		ret = ds->drv->fdb_add(ds, p->port, addr, vid);
-
-	return ret;
-}
-
-static int dsa_slave_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
-			     struct net_device *dev,
-			     const unsigned char *addr, u16 vid)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
-
-	if (ds->drv->fdb_del)
-		ret = ds->drv->fdb_del(ds, p->port, addr, vid);
-
-	return ret;
-}
-
-static int dsa_slave_fill_info(struct net_device *dev, struct sk_buff *skb,
-			       const unsigned char *addr, u16 vid,
-			       bool is_static,
-			       u32 portid, u32 seq, int type,
-			       unsigned int flags)
-{
-	struct nlmsghdr *nlh;
-	struct ndmsg *ndm;
-
-	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
-	if (!nlh)
-		return -EMSGSIZE;
-
-	ndm = nlmsg_data(nlh);
-	ndm->ndm_family	 = AF_BRIDGE;
-	ndm->ndm_pad1    = 0;
-	ndm->ndm_pad2    = 0;
-	ndm->ndm_flags	 = NTF_EXT_LEARNED;
-	ndm->ndm_type	 = 0;
-	ndm->ndm_ifindex = dev->ifindex;
-	ndm->ndm_state   = is_static ? NUD_NOARP : NUD_REACHABLE;
-
-	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
-		goto nla_put_failure;
-
-	if (vid && nla_put_u16(skb, NDA_VLAN, vid))
-		goto nla_put_failure;
-
-	nlmsg_end(skb, nlh);
-	return 0;
-
-nla_put_failure:
-	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
-}
-
-/* Dump information about entries, in response to GETNEIGH */
-static int dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-			      struct net_device *dev,
-			      struct net_device *filter_dev, int idx)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-	unsigned char addr[ETH_ALEN] = { 0 };
-	int ret;
-
-	if (!ds->drv->fdb_getnext)
-		return -EOPNOTSUPP;
-
-	for (; ; idx++) {
-		bool is_static;
-
-		ret = ds->drv->fdb_getnext(ds, p->port, addr, &is_static);
-		if (ret < 0)
-			break;
-
-		if (idx < cb->args[0])
-			continue;
-
-		ret = dsa_slave_fill_info(dev, skb, addr, 0,
-					  is_static,
-					  NETLINK_CB(cb->skb).portid,
-					  cb->nlh->nlmsg_seq,
-					  RTM_NEWNEIGH, NLM_F_MULTI);
-		if (ret < 0)
-			break;
-	}
-
-	return idx;
-}
-
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -364,6 +266,115 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	return ret;
 }
 
+static int dsa_slave_port_fdb_add(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int err;
+
+	if (obj->trans == SWITCHDEV_TRANS_PREPARE)
+		err = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
+	else if (obj->trans == SWITCHDEV_TRANS_COMMIT)
+		err = ds->drv->port_fdb_add(ds, p->port, fdb->vid, fdb->addr);
+	else
+		err = -EOPNOTSUPP;
+
+	return err;
+}
+
+static int dsa_slave_port_fdb_del(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (!ds->drv->port_fdb_del)
+		return -EOPNOTSUPP;
+
+	return ds->drv->port_fdb_del(ds, p->port, fdb->vid, fdb->addr);
+}
+
+static int dsa_slave_port_fdb_dump(struct net_device *dev,
+				   struct switchdev_obj *obj)
+{
+	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int err;
+
+	if (!ds->drv->port_fdb_getnext)
+		return -EOPNOTSUPP;
+
+	memset(fdb, 0, sizeof(*fdb));
+
+	for (;;) {
+		err = ds->drv->port_fdb_getnext(ds, p->port, &fdb->vid,
+						fdb->addr, &fdb->is_static);
+		if (err)
+			break;
+
+		err = obj->cb(dev, obj);
+		if (err)
+			break;
+	}
+
+	return err == -ENOENT ? 0 : err;
+}
+
+static int dsa_slave_port_obj_add(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_FDB:
+		err = dsa_slave_port_fdb_add(dev, obj);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_del(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_FDB:
+		err = dsa_slave_port_fdb_del(dev, obj);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_dump(struct net_device *dev,
+				   struct switchdev_obj *obj)
+{
+	int err;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_FDB:
+		err = dsa_slave_port_fdb_dump(dev, obj);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
@@ -765,9 +776,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
-	.ndo_fdb_add		= dsa_slave_fdb_add,
-	.ndo_fdb_del		= dsa_slave_fdb_del,
-	.ndo_fdb_dump		= dsa_slave_fdb_dump,
+	.ndo_fdb_add		= switchdev_port_fdb_add,
+	.ndo_fdb_del		= switchdev_port_fdb_del,
+	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -775,11 +786,17 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
 	.ndo_poll_controller	= dsa_slave_poll_controller,
 #endif
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
 	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
+	.switchdev_port_obj_add		= dsa_slave_port_obj_add,
+	.switchdev_port_obj_del		= dsa_slave_port_obj_del,
+	.switchdev_port_obj_dump	= dsa_slave_port_obj_dump,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
-- 
2.4.6
