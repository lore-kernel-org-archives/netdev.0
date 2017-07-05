From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next RFC 10/12] net: dsa: Move FDB dump implementation inside DSA
Date: Wed,  5 Jul 2017 18:36:28 +0300
Message-ID: <1499268990-19251-11-git-send-email-arkadis@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49289 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751797AbdGEPdd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:33:33 -0400
In-Reply-To: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From all switchdev devices only DSA requires special FDB dump. This is due
to lack of ability for syncing the hardware learned FDBs with the bridge.
Due to this it is removed from switchdev and moved inside DSA.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 drivers/net/dsa/b53/b53_common.c       | 19 ++++---
 drivers/net/dsa/b53/b53_priv.h         |  3 +-
 drivers/net/dsa/microchip/ksz_common.c | 14 +++--
 drivers/net/dsa/mt7530.c               | 15 +++---
 drivers/net/dsa/mv88e6xxx/chip.c       | 40 ++++++---------
 drivers/net/dsa/qca8k.c                | 14 +++--
 include/net/dsa.h                      | 15 ++++--
 include/net/switchdev.h                | 12 -----
 net/dsa/dsa_priv.h                     |  2 -
 net/dsa/port.c                         | 11 ----
 net/dsa/slave.c                        | 93 ++++++++++++++++++++++++++--------
 net/switchdev/switchdev.c              | 84 ------------------------------
 12 files changed, 128 insertions(+), 194 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 6020e88..9d41dc6 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1227,25 +1227,24 @@ static void b53_arl_search_rd(struct b53_device *dev, u8 idx,
 }
 
 static int b53_fdb_copy(int port, const struct b53_arl_entry *ent,
-			struct switchdev_obj_port_fdb *fdb,
-			switchdev_obj_dump_cb_t *cb)
+			struct dsa_slave_dump_ctx *dump)
 {
+	u16 ndm_state;
+
 	if (!ent->is_valid)
 		return 0;
 
 	if (port != ent->port)
 		return 0;
 
-	ether_addr_copy(fdb->addr, ent->mac);
-	fdb->vid = ent->vid;
-	fdb->ndm_state = ent->is_static ? NUD_NOARP : NUD_REACHABLE;
+	ndm_state = ent->is_static ? NUD_NOARP : NUD_REACHABLE;
 
-	return cb(&fdb->obj);
+	return dsa_slave_port_fdb_do_dump(dump, ent->mac, ent->vid,
+					  ndm_state);
 }
 
 int b53_fdb_dump(struct dsa_switch *ds, int port,
-		 struct switchdev_obj_port_fdb *fdb,
-		 switchdev_obj_dump_cb_t *cb)
+		 struct dsa_slave_dump_ctx *dump)
 {
 	struct b53_device *priv = ds->priv;
 	struct b53_arl_entry results[2];
@@ -1263,13 +1262,13 @@ int b53_fdb_dump(struct dsa_switch *ds, int port,
 			return ret;
 
 		b53_arl_search_rd(priv, 0, &results[0]);
-		ret = b53_fdb_copy(port, &results[0], fdb, cb);
+		ret = b53_fdb_copy(port, &results[0], dump);
 		if (ret)
 			return ret;
 
 		if (priv->num_arl_entries > 2) {
 			b53_arl_search_rd(priv, 1, &results[1]);
-			ret = b53_fdb_copy(port, &results[1], fdb, cb);
+			ret = b53_fdb_copy(port, &results[1], dump);
 			if (ret)
 				return ret;
 
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index af5d6c1..5cc94d9 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -398,8 +398,7 @@ int b53_fdb_add(struct dsa_switch *ds, int port,
 int b53_fdb_del(struct dsa_switch *ds, int port,
 		const unsigned char *addr, u16 vid);
 int b53_fdb_dump(struct dsa_switch *ds, int port,
-		 struct switchdev_obj_port_fdb *fdb,
-		 switchdev_obj_dump_cb_t *cb);
+		 struct dsa_slave_dump_ctx *dump);
 int b53_mirror_add(struct dsa_switch *ds, int port,
 		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress);
 void b53_mirror_del(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 4de9d90..94be26e 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -805,8 +805,7 @@ static void convert_alu(struct alu_struct *alu, u32 *alu_table)
 }
 
 static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
-			     struct switchdev_obj_port_fdb *fdb,
-			     switchdev_obj_dump_cb_t *cb)
+			     struct dsa_slave_dump_ctx *dump)
 {
 	struct ksz_device *dev = ds->priv;
 	int ret = 0;
@@ -814,6 +813,7 @@ static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
 	u32 alu_table[4];
 	struct alu_struct alu;
 	int timeout;
+	u16 ndm_state;
 
 	mutex_lock(&dev->alu_mutex);
 
@@ -841,14 +841,12 @@ static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
 		convert_alu(&alu, alu_table);
 
 		if (alu.port_forward & BIT(port)) {
-			fdb->vid = alu.fid;
 			if (alu.is_static)
-				fdb->ndm_state = NUD_NOARP;
+				ndm_state = NUD_NOARP;
 			else
-				fdb->ndm_state = NUD_REACHABLE;
-			ether_addr_copy(fdb->addr, alu.mac);
-
-			ret = cb(&fdb->obj);
+				ndm_state = NUD_REACHABLE;
+			ret = dsa_slave_port_fdb_do_dump(dump, alu.mac,
+							 alu.fid, ndm_state);
 			if (ret)
 				goto exit;
 		}
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index f92aae8..41afa4c 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -834,12 +834,12 @@ mt7530_port_fdb_del(struct dsa_switch *ds, int port,
 
 static int
 mt7530_port_fdb_dump(struct dsa_switch *ds, int port,
-		     struct switchdev_obj_port_fdb *fdb,
-		     switchdev_obj_dump_cb_t *cb)
+		     struct dsa_slave_dump_ctx *dump)
 {
 	struct mt7530_priv *priv = ds->priv;
 	struct mt7530_fdb _fdb = { 0 };
 	int cnt = MT7530_NUM_FDB_RECORDS;
+	u16 ndm_state;
 	int ret = 0;
 	u32 rsp = 0;
 
@@ -853,11 +853,12 @@ mt7530_port_fdb_dump(struct dsa_switch *ds, int port,
 		if (rsp & ATC_SRCH_HIT) {
 			mt7530_fdb_read(priv, &_fdb);
 			if (_fdb.port_mask & BIT(port)) {
-				ether_addr_copy(fdb->addr, _fdb.mac);
-				fdb->vid = _fdb.vid;
-				fdb->ndm_state = _fdb.noarp ?
-						NUD_NOARP : NUD_REACHABLE;
-				ret = cb(&fdb->obj);
+				ndm_state = _fdb.noarp ?
+					    NUD_NOARP : NUD_REACHABLE;
+				ret = dsa_slave_port_fdb_do_dump(dump,
+								 _fdb.mac,
+								 _fdb.vid,
+								 ndm_state);
 				if (ret < 0)
 					break;
 			}
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 97b77b9..6dccecd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1410,10 +1410,10 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 
 static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 				      u16 fid, u16 vid, int port,
-				      struct switchdev_obj *obj,
-				      switchdev_obj_dump_cb_t *cb)
+				      struct dsa_slave_dump_ctx *dump)
 {
 	struct mv88e6xxx_atu_entry addr;
+	u16 ndm_state;
 	int err;
 
 	addr.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
@@ -1430,24 +1430,16 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 		if (addr.trunk || (addr.portvec & BIT(port)) == 0)
 			continue;
 
-		if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
-			struct switchdev_obj_port_fdb *fdb;
-
-			if (!is_unicast_ether_addr(addr.mac))
-				continue;
+		if (!is_unicast_ether_addr(addr.mac))
+			continue;
 
-			fdb = SWITCHDEV_OBJ_PORT_FDB(obj);
-			fdb->vid = vid;
-			ether_addr_copy(fdb->addr, addr.mac);
-			if (addr.state == MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC)
-				fdb->ndm_state = NUD_NOARP;
-			else
-				fdb->ndm_state = NUD_REACHABLE;
-		} else {
-			return -EOPNOTSUPP;
-		}
+		if (addr.state == MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC)
+			ndm_state = NUD_NOARP;
+		else
+			ndm_state = NUD_REACHABLE;
 
-		err = cb(obj);
+		err = dsa_slave_port_fdb_do_dump(dump, addr.mac, vid,
+						 ndm_state);
 		if (err)
 			return err;
 	} while (!is_broadcast_ether_addr(addr.mac));
@@ -1456,8 +1448,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 }
 
 static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
-				  struct switchdev_obj *obj,
-				  switchdev_obj_dump_cb_t *cb)
+				  struct dsa_slave_dump_ctx *dump)
 {
 	struct mv88e6xxx_vtu_entry vlan = {
 		.vid = chip->info->max_vid,
@@ -1470,7 +1461,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_port_db_dump_fid(chip, fid, 0, port, obj, cb);
+	err = mv88e6xxx_port_db_dump_fid(chip, fid, 0, port, dump);
 	if (err)
 		return err;
 
@@ -1484,7 +1475,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 			break;
 
 		err = mv88e6xxx_port_db_dump_fid(chip, vlan.fid, vlan.vid, port,
-						 obj, cb);
+						 dump);
 		if (err)
 			return err;
 	} while (vlan.vid < chip->info->max_vid);
@@ -1493,14 +1484,13 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 }
 
 static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
-				   struct switchdev_obj_port_fdb *fdb,
-				   switchdev_obj_dump_cb_t *cb)
+				   struct dsa_slave_dump_ctx *dump)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_port_db_dump(chip, port, &fdb->obj, cb);
+	err = mv88e6xxx_port_db_dump(chip, port, dump);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 9c3de3d..c6f7dfb 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -853,27 +853,25 @@ qca8k_port_fdb_del(struct dsa_switch *ds, int port,
 
 static int
 qca8k_port_fdb_dump(struct dsa_switch *ds, int port,
-		    struct switchdev_obj_port_fdb *fdb,
-		    switchdev_obj_dump_cb_t *cb)
+		    struct dsa_slave_dump_ctx *dump)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	struct qca8k_fdb _fdb = { 0 };
 	int cnt = QCA8K_NUM_FDB_RECORDS;
+	u16 ndm_state;
 	int ret = 0;
 
 	mutex_lock(&priv->reg_mutex);
 	while (cnt-- && !qca8k_fdb_next(priv, &_fdb, port)) {
 		if (!_fdb.aging)
 			break;
-
-		ether_addr_copy(fdb->addr, _fdb.mac);
-		fdb->vid = _fdb.vid;
 		if (_fdb.aging == QCA8K_ATU_STATUS_STATIC)
-			fdb->ndm_state = NUD_NOARP;
+			ndm_state = NUD_NOARP;
 		else
-			fdb->ndm_state = NUD_REACHABLE;
+			ndm_state = NUD_REACHABLE;
 
-		ret = cb(&fdb->obj);
+		ret = dsa_slave_port_fdb_do_dump(dump, _fdb.mac,
+						 _fdb.vid, ndm_state);
 		if (ret)
 			break;
 	}
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2d85ad2..6a99869 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -277,6 +277,13 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 		return ds->rtable[dst->cpu_dp->ds->index];
 }
 
+struct dsa_slave_dump_ctx {
+	struct net_device *dev;
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+	int idx;
+};
+
 struct dsa_switch_ops {
 	/*
 	 * Legacy probing.
@@ -392,9 +399,7 @@ struct dsa_switch_ops {
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
 				const unsigned char *addr, u16 vid);
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
-				 struct switchdev_obj_port_fdb *fdb,
-				  switchdev_obj_dump_cb_t *cb);
-
+				 struct dsa_slave_dump_ctx *dump);
 	/*
 	 * Multicast database
 	 */
@@ -457,6 +462,10 @@ static inline bool netdev_uses_dsa(struct net_device *dev)
 struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n);
 void dsa_unregister_switch(struct dsa_switch *ds);
 int dsa_register_switch(struct dsa_switch *ds);
+int dsa_slave_port_fdb_do_dump(struct dsa_slave_dump_ctx *dump,
+			       const unsigned char *addr, u16 vid,
+			       u16 ndm_state);
+
 #ifdef CONFIG_PM_SLEEP
 int dsa_switch_suspend(struct dsa_switch *ds);
 int dsa_switch_resume(struct dsa_switch *ds);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8ae9e3b..d2637a6 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -208,9 +208,6 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev, const unsigned char *addr,
 			   u16 vid);
-int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-			    struct net_device *dev,
-			    struct net_device *filter_dev, int *idx);
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
@@ -309,15 +306,6 @@ static inline int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
-					  struct netlink_callback *cb,
-					  struct net_device *dev,
-					  struct net_device *filter_dev,
-					  int *idx)
-{
-       return *idx;
-}
-
 static inline bool switchdev_port_same_parent_id(struct net_device *a,
 						 struct net_device *b)
 {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 85f53a0..ab4a6a9 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -124,8 +124,6 @@ int dsa_port_fdb_add(struct dsa_port *dp, const unsigned char *addr,
 		     u16 vid);
 int dsa_port_fdb_del(struct dsa_port *dp, const unsigned char *addr,
 		     u16 vid);
-int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
-		      switchdev_obj_dump_cb_t *cb);
 int dsa_port_mdb_add(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb,
 		     struct switchdev_trans *trans);
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 7378782..659676b 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -173,17 +173,6 @@ int dsa_port_fdb_del(struct dsa_port *dp, const unsigned char *addr,
 	return dsa_port_notify(dp, DSA_NOTIFIER_FDB_DEL, &info);
 }
 
-int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
-		      switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_fdb_dump)
-		return ds->ops->port_fdb_dump(ds, dp->index, fdb, cb);
-
-	return -EOPNOTSUPP;
-}
-
 int dsa_port_mdb_add(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb,
 		     struct switchdev_trans *trans)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index acbc0f2..515369f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -199,6 +199,76 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 	return 0;
 }
 
+int dsa_slave_port_fdb_do_dump(struct dsa_slave_dump_ctx *dump,
+			       const unsigned char *addr, u16 vid,
+			       u16 ndm_state)
+{
+	u32 portid = NETLINK_CB(dump->cb->skb).portid;
+	u32 seq = dump->cb->nlh->nlmsg_seq;
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	if (dump->idx < dump->cb->args[2])
+		goto skip;
+
+	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
+			sizeof(*ndm), NLM_F_MULTI);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family  = AF_BRIDGE;
+	ndm->ndm_pad1    = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags   = NTF_SELF;
+	ndm->ndm_type    = 0;
+	ndm->ndm_ifindex = dump->dev->ifindex;
+	ndm->ndm_state   = ndm_state;
+
+	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, addr))
+		goto nla_put_failure;
+
+	if (vid && nla_put_u16(dump->skb, NDA_VLAN, vid))
+		goto nla_put_failure;
+
+	nlmsg_end(dump->skb, nlh);
+
+skip:
+	dump->idx++;
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(dump->skb, nlh);
+	return -EMSGSIZE;
+}
+EXPORT_SYMBOL_GPL(dsa_slave_port_fdb_do_dump);
+
+int dsa_slave_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			    struct net_device *dev,
+			    struct net_device *filter_dev, int *idx)
+{
+	struct dsa_slave_dump_ctx dump = {
+		.dev = dev,
+		.skb = skb,
+		.cb = cb,
+		.idx = *idx,
+	};
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch *ds = dp->ds;
+	int err;
+
+	if (!ds->ops->port_fdb_dump) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	err = ds->ops->port_fdb_dump(ds, dp->index, &dump);
+out:
+	*idx = dump.idx;
+	return err;
+}
+
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -287,26 +357,6 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 	return err;
 }
 
-static int dsa_slave_port_obj_dump(struct net_device *dev,
-				   struct switchdev_obj *obj,
-				   switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
-	int err;
-
-	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_port_fdb_dump(dp, SWITCHDEV_OBJ_PORT_FDB(obj), cb);
-		break;
-	default:
-		err = -EOPNOTSUPP;
-		break;
-	}
-
-	return err;
-}
-
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
@@ -912,7 +962,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
-	.ndo_fdb_dump		= switchdev_port_fdb_dump,
+	.ndo_fdb_dump		= dsa_slave_port_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -929,7 +979,6 @@ static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
 	.switchdev_port_obj_add		= dsa_slave_port_obj_add,
 	.switchdev_port_obj_del		= dsa_slave_port_obj_del,
-	.switchdev_port_obj_dump	= dsa_slave_port_obj_dump,
 };
 
 static struct device_type dsa_type = {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 25dc67e..3d32981 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1009,90 +1009,6 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
 
-struct switchdev_fdb_dump {
-	struct switchdev_obj_port_fdb fdb;
-	struct net_device *dev;
-	struct sk_buff *skb;
-	struct netlink_callback *cb;
-	int idx;
-};
-
-static int switchdev_port_fdb_dump_cb(struct switchdev_obj *obj)
-{
-	struct switchdev_obj_port_fdb *fdb = SWITCHDEV_OBJ_PORT_FDB(obj);
-	struct switchdev_fdb_dump *dump =
-		container_of(fdb, struct switchdev_fdb_dump, fdb);
-	u32 portid = NETLINK_CB(dump->cb->skb).portid;
-	u32 seq = dump->cb->nlh->nlmsg_seq;
-	struct nlmsghdr *nlh;
-	struct ndmsg *ndm;
-
-	if (dump->idx < dump->cb->args[2])
-		goto skip;
-
-	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
-			sizeof(*ndm), NLM_F_MULTI);
-	if (!nlh)
-		return -EMSGSIZE;
-
-	ndm = nlmsg_data(nlh);
-	ndm->ndm_family  = AF_BRIDGE;
-	ndm->ndm_pad1    = 0;
-	ndm->ndm_pad2    = 0;
-	ndm->ndm_flags   = NTF_SELF;
-	ndm->ndm_type    = 0;
-	ndm->ndm_ifindex = dump->dev->ifindex;
-	ndm->ndm_state   = fdb->ndm_state;
-
-	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, fdb->addr))
-		goto nla_put_failure;
-
-	if (fdb->vid && nla_put_u16(dump->skb, NDA_VLAN, fdb->vid))
-		goto nla_put_failure;
-
-	nlmsg_end(dump->skb, nlh);
-
-skip:
-	dump->idx++;
-	return 0;
-
-nla_put_failure:
-	nlmsg_cancel(dump->skb, nlh);
-	return -EMSGSIZE;
-}
-
-/**
- *	switchdev_port_fdb_dump - Dump port FDB (MAC/VLAN) entries
- *
- *	@skb: netlink skb
- *	@cb: netlink callback
- *	@dev: port device
- *	@filter_dev: filter device
- *	@idx:
- *
- *	Dump FDB entries from switch device.
- */
-int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-			    struct net_device *dev,
-			    struct net_device *filter_dev, int *idx)
-{
-	struct switchdev_fdb_dump dump = {
-		.fdb.obj.orig_dev = dev,
-		.fdb.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
-		.dev = dev,
-		.skb = skb,
-		.cb = cb,
-		.idx = *idx,
-	};
-	int err;
-
-	err = switchdev_port_obj_dump(dev, &dump.fdb.obj,
-				      switchdev_port_fdb_dump_cb);
-	*idx = dump.idx;
-	return err;
-}
-EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
-
 bool switchdev_port_same_parent_id(struct net_device *a,
 				   struct net_device *b)
 {
-- 
2.4.11
