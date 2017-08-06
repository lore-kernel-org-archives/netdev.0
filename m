From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 01/13] net: dsa: Change DSA slave FDB API to be switchdev independent
Date: Sun,  6 Aug 2017 16:15:39 +0300
Message-ID: <1502025351-41261-2-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44762 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751256AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support FDB add/del to be on a notifier chain the slave
API need to be changed to be switchdev independent.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c       | 12 +++++-------
 drivers/net/dsa/b53/b53_priv.h         |  8 +++-----
 drivers/net/dsa/microchip/ksz_common.c | 34 ++++++++++++++++------------------
 drivers/net/dsa/mt7530.c               | 14 ++++++--------
 drivers/net/dsa/mv88e6xxx/chip.c       | 12 +++++-------
 drivers/net/dsa/qca8k.c                | 15 ++++++---------
 include/net/dsa.h                      |  8 +++-----
 net/dsa/switch.c                       |  8 +++++---
 8 files changed, 49 insertions(+), 62 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 7f36d3e..5336179 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1214,8 +1214,7 @@ static int b53_arl_op(struct b53_device *dev, int op, int port,
 }
 
 int b53_fdb_prepare(struct dsa_switch *ds, int port,
-		    const struct switchdev_obj_port_fdb *fdb,
-		    struct switchdev_trans *trans)
+		    const unsigned char *addr, u16 vid)
 {
 	struct b53_device *priv = ds->priv;
 
@@ -1230,22 +1229,21 @@ int b53_fdb_prepare(struct dsa_switch *ds, int port,
 EXPORT_SYMBOL(b53_fdb_prepare);
 
 void b53_fdb_add(struct dsa_switch *ds, int port,
-		 const struct switchdev_obj_port_fdb *fdb,
-		 struct switchdev_trans *trans)
+		 const unsigned char *addr, u16 vid)
 {
 	struct b53_device *priv = ds->priv;
 
-	if (b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
+	if (b53_arl_op(priv, 0, port, addr, vid, true))
 		pr_err("%s: failed to add MAC address\n", __func__);
 }
 EXPORT_SYMBOL(b53_fdb_add);
 
 int b53_fdb_del(struct dsa_switch *ds, int port,
-		const struct switchdev_obj_port_fdb *fdb)
+		const unsigned char *addr, u16 vid)
 {
 	struct b53_device *priv = ds->priv;
 
-	return b53_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
+	return b53_arl_op(priv, 0, port, addr, vid, false);
 }
 EXPORT_SYMBOL(b53_fdb_del);
 
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 155a9c4..d417bca 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -397,13 +397,11 @@ int b53_vlan_dump(struct dsa_switch *ds, int port,
 		  struct switchdev_obj_port_vlan *vlan,
 		  switchdev_obj_dump_cb_t *cb);
 int b53_fdb_prepare(struct dsa_switch *ds, int port,
-		    const struct switchdev_obj_port_fdb *fdb,
-		    struct switchdev_trans *trans);
+		    const unsigned char *addr, u16 vid);
 void b53_fdb_add(struct dsa_switch *ds, int port,
-		 const struct switchdev_obj_port_fdb *fdb,
-		 struct switchdev_trans *trans);
+		 const unsigned char *addr, u16 vid);
 int b53_fdb_del(struct dsa_switch *ds, int port,
-		const struct switchdev_obj_port_fdb *fdb);
+		const unsigned char *addr, u16 vid);
 int b53_fdb_dump(struct dsa_switch *ds, int port,
 		 struct switchdev_obj_port_fdb *fdb,
 		 switchdev_obj_dump_cb_t *cb);
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index b313ecd..db82808 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -679,8 +679,7 @@ static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
 }
 
 static int ksz_port_fdb_prepare(struct dsa_switch *ds, int port,
-				const struct switchdev_obj_port_fdb *fdb,
-				struct switchdev_trans *trans)
+				const unsigned char *addr, u16 vid)
 {
 	/* nothing needed */
 
@@ -707,8 +706,7 @@ struct alu_struct {
 };
 
 static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
-			     const struct switchdev_obj_port_fdb *fdb,
-			     struct switchdev_trans *trans)
+			     const unsigned char *addr, u16 vid)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 alu_table[4];
@@ -717,12 +715,12 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
 	mutex_lock(&dev->alu_mutex);
 
 	/* find any entry with mac & vid */
-	data = fdb->vid << ALU_FID_INDEX_S;
-	data |= ((fdb->addr[0] << 8) | fdb->addr[1]);
+	data = vid << ALU_FID_INDEX_S;
+	data |= ((addr[0] << 8) | addr[1]);
 	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
 
-	data = ((fdb->addr[2] << 24) | (fdb->addr[3] << 16));
-	data |= ((fdb->addr[4] << 8) | fdb->addr[5]);
+	data = ((addr[2] << 24) | (addr[3] << 16));
+	data |= ((addr[4] << 8) | addr[5]);
 	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
 
 	/* start read operation */
@@ -740,12 +738,12 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
 	/* update ALU entry */
 	alu_table[0] = ALU_V_STATIC_VALID;
 	alu_table[1] |= BIT(port);
-	if (fdb->vid)
+	if (vid)
 		alu_table[1] |= ALU_V_USE_FID;
-	alu_table[2] = (fdb->vid << ALU_V_FID_S);
-	alu_table[2] |= ((fdb->addr[0] << 8) | fdb->addr[1]);
-	alu_table[3] = ((fdb->addr[2] << 24) | (fdb->addr[3] << 16));
-	alu_table[3] |= ((fdb->addr[4] << 8) | fdb->addr[5]);
+	alu_table[2] = (vid << ALU_V_FID_S);
+	alu_table[2] |= ((addr[0] << 8) | addr[1]);
+	alu_table[3] = ((addr[2] << 24) | (addr[3] << 16));
+	alu_table[3] |= ((addr[4] << 8) | addr[5]);
 
 	write_table(ds, alu_table);
 
@@ -760,7 +758,7 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
 }
 
 static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
-			    const struct switchdev_obj_port_fdb *fdb)
+			    const unsigned char *addr, u16 vid)
 {
 	struct ksz_device *dev = ds->priv;
 	u32 alu_table[4];
@@ -770,12 +768,12 @@ static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
 	mutex_lock(&dev->alu_mutex);
 
 	/* read any entry with mac & vid */
-	data = fdb->vid << ALU_FID_INDEX_S;
-	data |= ((fdb->addr[0] << 8) | fdb->addr[1]);
+	data = vid << ALU_FID_INDEX_S;
+	data |= ((addr[0] << 8) | addr[1]);
 	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
 
-	data = ((fdb->addr[2] << 24) | (fdb->addr[3] << 16));
-	data |= ((fdb->addr[4] << 8) | fdb->addr[5]);
+	data = ((addr[2] << 24) | (addr[3] << 16));
+	data |= ((addr[4] << 8) | addr[5]);
 	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
 
 	/* start read operation */
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418..430e3ab 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -802,8 +802,7 @@ mt7530_port_bridge_leave(struct dsa_switch *ds, int port,
 
 static int
 mt7530_port_fdb_prepare(struct dsa_switch *ds, int port,
-			const struct switchdev_obj_port_fdb *fdb,
-			struct switchdev_trans *trans)
+			const unsigned char *addr, u16 vid)
 {
 	struct mt7530_priv *priv = ds->priv;
 	int ret;
@@ -813,7 +812,7 @@ mt7530_port_fdb_prepare(struct dsa_switch *ds, int port,
 	 * is called while the entry is still available.
 	 */
 	mutex_lock(&priv->reg_mutex);
-	mt7530_fdb_write(priv, fdb->vid, 0, fdb->addr, -1, STATIC_ENT);
+	mt7530_fdb_write(priv, vid, 0, addr, -1, STATIC_ENT);
 	ret = mt7530_fdb_cmd(priv, MT7530_FDB_WRITE, 0);
 	mutex_unlock(&priv->reg_mutex);
 
@@ -822,28 +821,27 @@ mt7530_port_fdb_prepare(struct dsa_switch *ds, int port,
 
 static void
 mt7530_port_fdb_add(struct dsa_switch *ds, int port,
-		    const struct switchdev_obj_port_fdb *fdb,
-		    struct switchdev_trans *trans)
+		    const unsigned char *addr, u16 vid)
 {
 	struct mt7530_priv *priv = ds->priv;
 	u8 port_mask = BIT(port);
 
 	mutex_lock(&priv->reg_mutex);
-	mt7530_fdb_write(priv, fdb->vid, port_mask, fdb->addr, -1, STATIC_ENT);
+	mt7530_fdb_write(priv, vid, port_mask, addr, -1, STATIC_ENT);
 	mt7530_fdb_cmd(priv, MT7530_FDB_WRITE, 0);
 	mutex_unlock(&priv->reg_mutex);
 }
 
 static int
 mt7530_port_fdb_del(struct dsa_switch *ds, int port,
-		    const struct switchdev_obj_port_fdb *fdb)
+		    const unsigned char *addr, u16 vid)
 {
 	struct mt7530_priv *priv = ds->priv;
 	int ret;
 	u8 port_mask = BIT(port);
 
 	mutex_lock(&priv->reg_mutex);
-	mt7530_fdb_write(priv, fdb->vid, port_mask, fdb->addr, -1, STATIC_EMP);
+	mt7530_fdb_write(priv, vid, port_mask, addr, -1, STATIC_EMP);
 	ret = mt7530_fdb_cmd(priv, MT7530_FDB_WRITE, 0);
 	mutex_unlock(&priv->reg_mutex);
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 521738c..8236975 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1407,8 +1407,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 }
 
 static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
-				      const struct switchdev_obj_port_fdb *fdb,
-				      struct switchdev_trans *trans)
+				      const unsigned char *addr, u16 vid)
 {
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
@@ -1417,13 +1416,12 @@ static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 }
 
 static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-				   const struct switchdev_obj_port_fdb *fdb,
-				   struct switchdev_trans *trans)
+				   const unsigned char *addr, u16 vid)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 
 	mutex_lock(&chip->reg_lock);
-	if (mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
+	if (mv88e6xxx_port_db_load_purge(chip, port, addr, vid,
 					 MV88E6XXX_G1_ATU_DATA_STATE_UC_STATIC))
 		dev_err(ds->dev, "p%d: failed to load unicast MAC address\n",
 			port);
@@ -1431,13 +1429,13 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 }
 
 static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-				  const struct switchdev_obj_port_fdb *fdb)
+				  const unsigned char *addr, u16 vid)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
+	err = mv88e6xxx_port_db_load_purge(chip, port, addr, vid,
 					   MV88E6XXX_G1_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&chip->reg_lock);
 
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 36c169b..2fb5df9 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -778,8 +778,7 @@ qca8k_port_fdb_insert(struct qca8k_priv *priv, const u8 *addr,
 
 static int
 qca8k_port_fdb_prepare(struct dsa_switch *ds, int port,
-		       const struct switchdev_obj_port_fdb *fdb,
-		       struct switchdev_trans *trans)
+		       const unsigned char *addr, u16 vid)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 
@@ -788,33 +787,31 @@ qca8k_port_fdb_prepare(struct dsa_switch *ds, int port,
 	 * when port_fdb_add is called an entry is still available. Otherwise
 	 * the last free entry might have been used up by auto learning
 	 */
-	return qca8k_port_fdb_insert(priv, fdb->addr, 0, fdb->vid);
+	return qca8k_port_fdb_insert(priv, addr, 0, vid);
 }
 
 static void
 qca8k_port_fdb_add(struct dsa_switch *ds, int port,
-		   const struct switchdev_obj_port_fdb *fdb,
-		   struct switchdev_trans *trans)
+		   const unsigned char *addr, u16 vid)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	u16 port_mask = BIT(port);
 
 	/* Update the FDB entry adding the port_mask */
-	qca8k_port_fdb_insert(priv, fdb->addr, port_mask, fdb->vid);
+	qca8k_port_fdb_insert(priv, addr, port_mask, vid);
 }
 
 static int
 qca8k_port_fdb_del(struct dsa_switch *ds, int port,
-		   const struct switchdev_obj_port_fdb *fdb)
+		   const unsigned char *addr, u16 vid)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	u16 port_mask = BIT(port);
-	u16 vid = fdb->vid;
 
 	if (!vid)
 		vid = 1;
 
-	return qca8k_fdb_del(priv, fdb->addr, port_mask, vid);
+	return qca8k_fdb_del(priv, addr, port_mask, vid);
 }
 
 static int
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 0b1a062..ba11005 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -386,13 +386,11 @@ struct dsa_switch_ops {
 	 * Forwarding database
 	 */
 	int	(*port_fdb_prepare)(struct dsa_switch *ds, int port,
-				    const struct switchdev_obj_port_fdb *fdb,
-				    struct switchdev_trans *trans);
+				    const unsigned char *addr, u16 vid);
 	void	(*port_fdb_add)(struct dsa_switch *ds, int port,
-				const struct switchdev_obj_port_fdb *fdb,
-				struct switchdev_trans *trans);
+				const unsigned char *addr, u16 vid);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
-				const struct switchdev_obj_port_fdb *fdb);
+				const unsigned char *addr, u16 vid);
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_fdb *fdb,
 				  switchdev_obj_dump_cb_t *cb);
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index 97e2e9c..a9edfba 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -94,10 +94,11 @@ static int dsa_switch_fdb_add(struct dsa_switch *ds,
 		if (!ds->ops->port_fdb_prepare || !ds->ops->port_fdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_fdb_prepare(ds, info->port, fdb, trans);
+		return ds->ops->port_fdb_prepare(ds, info->port, fdb->addr,
+						 fdb->vid);
 	}
 
-	ds->ops->port_fdb_add(ds, info->port, fdb, trans);
+	ds->ops->port_fdb_add(ds, info->port, fdb->addr, fdb->vid);
 
 	return 0;
 }
@@ -114,7 +115,8 @@ static int dsa_switch_fdb_del(struct dsa_switch *ds,
 	if (!ds->ops->port_fdb_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_fdb_del(ds, info->port, fdb);
+	return ds->ops->port_fdb_del(ds, info->port, fdb->addr,
+				     fdb->vid);
 }
 
 static int dsa_switch_mdb_add(struct dsa_switch *ds,
-- 
2.4.11
