From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 02/13] net: dsa: Remove prepare phase for FDB
Date: Sun,  6 Aug 2017 16:15:40 +0300
Message-ID: <1502025351-41261-3-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44773 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751333AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The prepare phase for FDB add is unneeded because most of DSA devices
can have failures during bus transactions (SPI, I2C, etc.), thus, the
prepare phase cannot guarantee success of the commit stage.

The support for learning FDB through notification chain, which will be
introduced in the following patches, will provide the ability to notify
back the bridge about successful offload.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c       | 17 +++--------------
 drivers/net/dsa/b53/b53_priv.h         |  6 ++----
 drivers/net/dsa/bcm_sf2.c              |  1 -
 drivers/net/dsa/microchip/ksz_common.c | 24 ++++++++++--------------
 drivers/net/dsa/mt7530.c               | 25 ++++---------------------
 drivers/net/dsa/mv88e6xxx/chip.c       | 23 +++++++----------------
 drivers/net/dsa/qca8k.c                | 18 +-----------------
 include/net/dsa.h                      |  4 +---
 net/dsa/dsa_priv.h                     |  4 +---
 net/dsa/port.c                         |  4 +---
 net/dsa/slave.c                        |  4 +++-
 net/dsa/switch.c                       | 14 +++-----------
 12 files changed, 36 insertions(+), 108 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 5336179..3cf4f0a 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1213,8 +1213,8 @@ static int b53_arl_op(struct b53_device *dev, int op, int port,
 	return b53_arl_rw_op(dev, 0);
 }
 
-int b53_fdb_prepare(struct dsa_switch *ds, int port,
-		    const unsigned char *addr, u16 vid)
+int b53_fdb_add(struct dsa_switch *ds, int port,
+		const unsigned char *addr, u16 vid)
 {
 	struct b53_device *priv = ds->priv;
 
@@ -1224,17 +1224,7 @@ int b53_fdb_prepare(struct dsa_switch *ds, int port,
 	if (is5325(priv) || is5365(priv))
 		return -EOPNOTSUPP;
 
-	return 0;
-}
-EXPORT_SYMBOL(b53_fdb_prepare);
-
-void b53_fdb_add(struct dsa_switch *ds, int port,
-		 const unsigned char *addr, u16 vid)
-{
-	struct b53_device *priv = ds->priv;
-
-	if (b53_arl_op(priv, 0, port, addr, vid, true))
-		pr_err("%s: failed to add MAC address\n", __func__);
+	return b53_arl_op(priv, 0, port, addr, vid, true);
 }
 EXPORT_SYMBOL(b53_fdb_add);
 
@@ -1563,7 +1553,6 @@ static const struct dsa_switch_ops b53_switch_ops = {
 	.port_vlan_add		= b53_vlan_add,
 	.port_vlan_del		= b53_vlan_del,
 	.port_vlan_dump		= b53_vlan_dump,
-	.port_fdb_prepare	= b53_fdb_prepare,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index d417bca..f29c892 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -396,10 +396,8 @@ int b53_vlan_del(struct dsa_switch *ds, int port,
 int b53_vlan_dump(struct dsa_switch *ds, int port,
 		  struct switchdev_obj_port_vlan *vlan,
 		  switchdev_obj_dump_cb_t *cb);
-int b53_fdb_prepare(struct dsa_switch *ds, int port,
-		    const unsigned char *addr, u16 vid);
-void b53_fdb_add(struct dsa_switch *ds, int port,
-		 const unsigned char *addr, u16 vid);
+int b53_fdb_add(struct dsa_switch *ds, int port,
+		const unsigned char *addr, u16 vid);
 int b53_fdb_del(struct dsa_switch *ds, int port,
 		const unsigned char *addr, u16 vid);
 int b53_fdb_dump(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 558667c..1907b27 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1022,7 +1022,6 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.port_vlan_add		= b53_vlan_add,
 	.port_vlan_del		= b53_vlan_del,
 	.port_vlan_dump		= b53_vlan_dump,
-	.port_fdb_prepare	= b53_fdb_prepare,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index db82808..b55f364 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -678,14 +678,6 @@ static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int ksz_port_fdb_prepare(struct dsa_switch *ds, int port,
-				const unsigned char *addr, u16 vid)
-{
-	/* nothing needed */
-
-	return 0;
-}
-
 struct alu_struct {
 	/* entry 1 */
 	u8	is_static:1;
@@ -705,12 +697,13 @@ struct alu_struct {
 	u8	mac[ETH_ALEN];
 };
 
-static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
-			     const unsigned char *addr, u16 vid)
+static int ksz_port_fdb_add(struct dsa_switch *ds, int port,
+			    const unsigned char *addr, u16 vid)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 alu_table[4];
 	u32 data;
+	int ret = 0;
 
 	mutex_lock(&dev->alu_mutex);
 
@@ -727,7 +720,8 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
 	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
 
 	/* wait to be finished */
-	if (wait_alu_ready(dev, ALU_START, 1000) < 0) {
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0) {
 		dev_dbg(dev->dev, "Failed to read ALU\n");
 		goto exit;
 	}
@@ -750,11 +744,14 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
 	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
 
 	/* wait to be finished */
-	if (wait_alu_ready(dev, ALU_START, 1000) < 0)
-		dev_dbg(dev->dev, "Failed to read ALU\n");
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0)
+		dev_dbg(dev->dev, "Failed to write ALU\n");
 
 exit:
 	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
 }
 
 static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
@@ -1128,7 +1125,6 @@ static const struct dsa_switch_ops ksz_switch_ops = {
 	.port_vlan_add		= ksz_port_vlan_add,
 	.port_vlan_del		= ksz_port_vlan_del,
 	.port_vlan_dump		= ksz_port_vlan_dump,
-	.port_fdb_prepare	= ksz_port_fdb_prepare,
 	.port_fdb_dump		= ksz_port_fdb_dump,
 	.port_fdb_add		= ksz_port_fdb_add,
 	.port_fdb_del		= ksz_port_fdb_del,
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 430e3ab..f92aae8 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -801,35 +801,19 @@ mt7530_port_bridge_leave(struct dsa_switch *ds, int port,
 }
 
 static int
-mt7530_port_fdb_prepare(struct dsa_switch *ds, int port,
-			const unsigned char *addr, u16 vid)
-{
-	struct mt7530_priv *priv = ds->priv;
-	int ret;
-
-	/* Because auto-learned entrie shares the same FDB table.
-	 * an entry is reserved with no port_mask to make sure fdb_add
-	 * is called while the entry is still available.
-	 */
-	mutex_lock(&priv->reg_mutex);
-	mt7530_fdb_write(priv, vid, 0, addr, -1, STATIC_ENT);
-	ret = mt7530_fdb_cmd(priv, MT7530_FDB_WRITE, 0);
-	mutex_unlock(&priv->reg_mutex);
-
-	return ret;
-}
-
-static void
 mt7530_port_fdb_add(struct dsa_switch *ds, int port,
 		    const unsigned char *addr, u16 vid)
 {
 	struct mt7530_priv *priv = ds->priv;
+	int ret;
 	u8 port_mask = BIT(port);
 
 	mutex_lock(&priv->reg_mutex);
 	mt7530_fdb_write(priv, vid, port_mask, addr, -1, STATIC_ENT);
-	mt7530_fdb_cmd(priv, MT7530_FDB_WRITE, 0);
+	ret = mt7530_fdb_cmd(priv, MT7530_FDB_WRITE, 0);
 	mutex_unlock(&priv->reg_mutex);
+
+	return ret;
 }
 
 static int
@@ -1013,7 +997,6 @@ static struct dsa_switch_ops mt7530_switch_ops = {
 	.port_stp_state_set	= mt7530_stp_state_set,
 	.port_bridge_join	= mt7530_port_bridge_join,
 	.port_bridge_leave	= mt7530_port_bridge_leave,
-	.port_fdb_prepare	= mt7530_port_fdb_prepare,
 	.port_fdb_add		= mt7530_port_fdb_add,
 	.port_fdb_del		= mt7530_port_fdb_del,
 	.port_fdb_dump		= mt7530_port_fdb_dump,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8236975..68cc1f6 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1406,26 +1406,18 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	return mv88e6xxx_g1_atu_loadpurge(chip, vlan.fid, &entry);
 }
 
-static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
-				      const unsigned char *addr, u16 vid)
-{
-	/* We don't need any dynamic resource from the kernel (yet),
-	 * so skip the prepare phase.
-	 */
-	return 0;
-}
-
-static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-				   const unsigned char *addr, u16 vid)
+static int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+				  const unsigned char *addr, u16 vid)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
+	int err;
 
 	mutex_lock(&chip->reg_lock);
-	if (mv88e6xxx_port_db_load_purge(chip, port, addr, vid,
-					 MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC))
-		dev_err(ds->dev, "p%d: failed to load unicast MAC address\n",
-			port);
+	err = mv88e6xxx_port_db_load_purge(chip, port, addr, vid,
+					   MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC);
 	mutex_unlock(&chip->reg_lock);
+
+	return err;
 }
 
 static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
@@ -3905,7 +3897,6 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
-	.port_fdb_prepare       = mv88e6xxx_port_fdb_prepare,
 	.port_fdb_add           = mv88e6xxx_port_fdb_add,
 	.port_fdb_del           = mv88e6xxx_port_fdb_del,
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 2fb5df9..f8ef823 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -777,28 +777,13 @@ qca8k_port_fdb_insert(struct qca8k_priv *priv, const u8 *addr,
 }
 
 static int
-qca8k_port_fdb_prepare(struct dsa_switch *ds, int port,
-		       const unsigned char *addr, u16 vid)
-{
-	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
-
-	/* The FDB table for static and auto learned entries is the same. We
-	 * need to reserve an entry with no port_mask set to make sure that
-	 * when port_fdb_add is called an entry is still available. Otherwise
-	 * the last free entry might have been used up by auto learning
-	 */
-	return qca8k_port_fdb_insert(priv, addr, 0, vid);
-}
-
-static void
 qca8k_port_fdb_add(struct dsa_switch *ds, int port,
 		   const unsigned char *addr, u16 vid)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	u16 port_mask = BIT(port);
 
-	/* Update the FDB entry adding the port_mask */
-	qca8k_port_fdb_insert(priv, addr, port_mask, vid);
+	return qca8k_port_fdb_insert(priv, addr, port_mask, vid);
 }
 
 static int
@@ -866,7 +851,6 @@ static const struct dsa_switch_ops qca8k_switch_ops = {
 	.port_stp_state_set	= qca8k_port_stp_state_set,
 	.port_bridge_join	= qca8k_port_bridge_join,
 	.port_bridge_leave	= qca8k_port_bridge_leave,
-	.port_fdb_prepare	= qca8k_port_fdb_prepare,
 	.port_fdb_add		= qca8k_port_fdb_add,
 	.port_fdb_del		= qca8k_port_fdb_del,
 	.port_fdb_dump		= qca8k_port_fdb_dump,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index ba11005..446fc43 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -385,9 +385,7 @@ struct dsa_switch_ops {
 	/*
 	 * Forwarding database
 	 */
-	int	(*port_fdb_prepare)(struct dsa_switch *ds, int port,
-				    const unsigned char *addr, u16 vid);
-	void	(*port_fdb_add)(struct dsa_switch *ds, int port,
+	int	(*port_fdb_add)(struct dsa_switch *ds, int port,
 				const unsigned char *addr, u16 vid);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
 				const unsigned char *addr, u16 vid);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7aa0656..330078d 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -44,7 +44,6 @@ struct dsa_notifier_bridge_info {
 /* DSA_NOTIFIER_FDB_* */
 struct dsa_notifier_fdb_info {
 	const struct switchdev_obj_port_fdb *fdb;
-	struct switchdev_trans *trans;
 	int sw_index;
 	int port;
 };
@@ -123,8 +122,7 @@ int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
 int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 			 struct switchdev_trans *trans);
 int dsa_port_fdb_add(struct dsa_port *dp,
-		     const struct switchdev_obj_port_fdb *fdb,
-		     struct switchdev_trans *trans);
+		     const struct switchdev_obj_port_fdb *fdb);
 int dsa_port_fdb_del(struct dsa_port *dp,
 		     const struct switchdev_obj_port_fdb *fdb);
 int dsa_port_fdb_dump(struct dsa_port *dp, struct switchdev_obj_port_fdb *fdb,
diff --git a/net/dsa/port.c b/net/dsa/port.c
index efc3bce..bd271b9 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -147,13 +147,11 @@ int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 }
 
 int dsa_port_fdb_add(struct dsa_port *dp,
-		     const struct switchdev_obj_port_fdb *fdb,
-		     struct switchdev_trans *trans)
+		     const struct switchdev_obj_port_fdb *fdb)
 {
 	struct dsa_notifier_fdb_info info = {
 		.sw_index = dp->ds->index,
 		.port = dp->index,
-		.trans = trans,
 		.fdb = fdb,
 	};
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 83252e8..4f06984 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -251,7 +251,9 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj), trans);
+		if (switchdev_trans_ph_prepare(trans))
+			return 0;
+		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index a9edfba..eb20e0f 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -84,23 +84,15 @@ static int dsa_switch_fdb_add(struct dsa_switch *ds,
 			      struct dsa_notifier_fdb_info *info)
 {
 	const struct switchdev_obj_port_fdb *fdb = info->fdb;
-	struct switchdev_trans *trans = info->trans;
 
 	/* Do not care yet about other switch chips of the fabric */
 	if (ds->index != info->sw_index)
 		return 0;
 
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
-			return -EOPNOTSUPP;
-
-		return ds->ops->port_fdb_prepare(ds, info->port, fdb->addr,
-						 fdb->vid);
-	}
-
-	ds->ops->port_fdb_add(ds, info->port, fdb->addr, fdb->vid);
+	if (!ds->ops->port_fdb_add)
+		return -EOPNOTSUPP;
 
-	return 0;
+	return ds->ops->port_fdb_add(ds, info->port, fdb->addr, fdb->vid);
 }
 
 static int dsa_switch_fdb_del(struct dsa_switch *ds,
-- 
2.4.11
