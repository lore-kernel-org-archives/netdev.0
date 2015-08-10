From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 8/8] net: dsa: add support for switchdev FDB objects
Date: Mon, 10 Aug 2015 09:09:53 -0400
Message-ID: <1439212193-7673-9-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the switchdev_port_obj_{add,del,dump} functions in DSA to
support the SWITCHDEV_OBJ_PORT_FDB objects.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 142 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 81 insertions(+), 61 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3d341b6..2767584 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -200,74 +200,38 @@ out:
 	return 0;
 }
 
-static int dsa_slave_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			     struct net_device *dev,
-			     const unsigned char *addr, u16 vid, u16 nlm_flags)
+static int dsa_slave_port_fdb_add(struct net_device *dev,
+				  struct switchdev_obj *obj)
 {
+	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (ds->drv->port_fdb_add)
-		ret = ds->drv->port_fdb_add(ds, p->port, addr, vid);
+	if (obj->trans == SWITCHDEV_TRANS_PREPARE)
+		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
+	else if (obj->trans == SWITCHDEV_TRANS_COMMIT)
+		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
 	return ret;
 }
 
-static int dsa_slave_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
-			     struct net_device *dev,
-			     const unsigned char *addr, u16 vid)
+static int dsa_slave_port_fdb_del(struct net_device *dev,
+				  struct switchdev_obj *obj)
 {
+	struct switchdev_obj_fdb *fdb = &obj->u.fdb;
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
 	if (ds->drv->port_fdb_del)
-		ret = ds->drv->port_fdb_del(ds, p->port, addr, vid);
+		ret = ds->drv->port_fdb_del(ds, p->port, fdb->addr, fdb->vid);
 
 	return ret;
 }
 
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
+static int dsa_slave_port_fdb_dump(struct net_device *dev,
+				   struct switchdev_obj *obj)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
@@ -278,7 +242,7 @@ static int dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	if (!ds->drv->port_fdb_getnext)
 		return -EOPNOTSUPP;
 
-	for (; ; idx++) {
+	for (;;) {
 		bool is_static;
 
 		ret = ds->drv->port_fdb_getnext(ds, p->port, addr, &vid,
@@ -286,19 +250,16 @@ static int dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		if (ret < 0)
 			break;
 
-		if (idx < cb->args[0])
-			continue;
+		obj->u.fdb.addr = addr;
+		obj->u.fdb.vid = vid;
+		obj->u.fdb.ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
 
-		ret = dsa_slave_fill_info(dev, skb, addr, vid,
-					  is_static,
-					  NETLINK_CB(cb->skb).portid,
-					  cb->nlh->nlmsg_seq,
-					  RTM_NEWNEIGH, NLM_F_MULTI);
+		ret = obj->cb(dev, obj);
 		if (ret < 0)
 			break;
 	}
 
-	return idx;
+	return ret == -ENOENT ? 0 : ret;
 }
 
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -366,6 +327,62 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	return ret;
 }
 
+static int dsa_slave_port_obj_add(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err;
+
+	/* For the prepare phase, ensure the full set of changes is feasable in
+	 * one go in order to signal a failure properly. If an operation is not
+	 * supported, return -EOPNOTSUPP.
+	 */
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
@@ -767,9 +784,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
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
@@ -782,6 +799,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
 	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
+	.switchdev_port_obj_add		= dsa_slave_port_obj_add,
+	.switchdev_port_obj_del		= dsa_slave_port_obj_del,
+	.switchdev_port_obj_dump	= dsa_slave_port_obj_dump,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
-- 
2.5.0
