From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/11] net: dsa: restore VLAN dump
Date: Mon, 14 Aug 2017 18:22:41 -0400
Message-ID: <20170814222242.10643-11-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit defines a dsa_vlan_dump_cb_t callback, similar to the FDB
dump callback and partly reverts commit a0b6b8c9fa3c ("net: dsa: Remove
support for vlan dump from DSA's drivers") to restore the DSA drivers
VLAN dump operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c       | 41 ++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h         |  2 ++
 drivers/net/dsa/bcm_sf2.c              |  1 +
 drivers/net/dsa/dsa_loop.c             | 38 ++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz_common.c | 41 ++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/chip.c       | 49 ++++++++++++++++++++++++++++++++++
 include/net/dsa.h                      |  5 ++++
 7 files changed, 177 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 274f3679f33d..be0c5fa8bd9b 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1053,6 +1053,46 @@ int b53_vlan_del(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL(b53_vlan_del);
 
+int b53_vlan_dump(struct dsa_switch *ds, int port, dsa_vlan_dump_cb_t *cb,
+		  void *data)
+{
+	struct b53_device *dev = ds->priv;
+	u16 vid, vid_start = 0, pvid;
+	struct b53_vlan *vl;
+	bool untagged;
+	int err = 0;
+
+	if (is5325(dev) || is5365(dev))
+		vid_start = 1;
+
+	b53_read16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port), &pvid);
+
+	/* Use our software cache for dumps, since we do not have any HW
+	 * operation returning only the used/valid VLANs
+	 */
+	for (vid = vid_start; vid < dev->num_vlans; vid++) {
+		vl = &dev->vlans[vid];
+
+		if (!vl->valid)
+			continue;
+
+		if (!(vl->members & BIT(port)))
+			continue;
+
+		untagged = false;
+
+		if (vl->untag & BIT(port))
+			untagged = true;
+
+		err = cb(vid, pvid == vid, untagged, data);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(b53_vlan_dump);
+
 /* Address Resolution Logic routines */
 static int b53_arl_op_wait(struct b53_device *dev)
 {
@@ -1503,6 +1543,7 @@ static const struct dsa_switch_ops b53_switch_ops = {
 	.port_vlan_prepare	= b53_vlan_prepare,
 	.port_vlan_add		= b53_vlan_add,
 	.port_vlan_del		= b53_vlan_del,
+	.port_vlan_dump		= b53_vlan_dump,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 01bd8cbe9a3f..2b3e59d80fdb 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -393,6 +393,8 @@ void b53_vlan_add(struct dsa_switch *ds, int port,
 		  struct switchdev_trans *trans);
 int b53_vlan_del(struct dsa_switch *ds, int port,
 		 const struct switchdev_obj_port_vlan *vlan);
+int b53_vlan_dump(struct dsa_switch *ds, int port, dsa_vlan_dump_cb_t *cb,
+		  void *data);
 int b53_fdb_add(struct dsa_switch *ds, int port,
 		const unsigned char *addr, u16 vid);
 int b53_fdb_del(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index bbcb4053e04e..1907b27297c3 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1021,6 +1021,7 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.port_vlan_prepare	= b53_vlan_prepare,
 	.port_vlan_add		= b53_vlan_add,
 	.port_vlan_del		= b53_vlan_del,
+	.port_vlan_dump		= b53_vlan_dump,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index 7819a9fe8321..0407533f725f 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -257,6 +257,43 @@ static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
+				   dsa_vlan_dump_cb_t *cb, void *data)
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	struct mii_bus *bus = ps->bus;
+	struct dsa_loop_vlan *vl;
+	u16 vid, vid_start = 0;
+	bool pvid, untagged;
+	int err = 0;
+
+	dev_dbg(ds->dev, "%s\n", __func__);
+
+	/* Just do a sleeping operation to make lockdep checks effective */
+	mdiobus_read(bus, ps->port_base + port, MII_BMSR);
+
+	for (vid = vid_start; vid < DSA_LOOP_VLANS; vid++) {
+		vl = &ps->vlans[vid];
+
+		if (!(vl->members & BIT(port)))
+			continue;
+
+		untagged = false;
+		pvid = false;
+
+		if (vl->untagged & BIT(port))
+			untagged = true;
+		if (ps->pvid == vid)
+			pvid = true;
+
+		err = cb(vid, pvid, untagged, data);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static const struct dsa_switch_ops dsa_loop_driver = {
 	.get_tag_protocol	= dsa_loop_get_protocol,
 	.setup			= dsa_loop_setup,
@@ -273,6 +310,7 @@ static const struct dsa_switch_ops dsa_loop_driver = {
 	.port_vlan_prepare	= dsa_loop_port_vlan_prepare,
 	.port_vlan_add		= dsa_loop_port_vlan_add,
 	.port_vlan_del		= dsa_loop_port_vlan_del,
+	.port_vlan_dump		= dsa_loop_port_vlan_dump,
 };
 
 static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 56cd6d365352..52c7849acc3c 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -638,6 +638,46 @@ static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
+			      dsa_vlan_dump_cb_t *cb, void *data)
+{
+	struct ksz_device *dev = ds->priv;
+	struct vlan_table *vlan_cache;
+	bool pvid, untagged;
+	u16 val;
+	int vid;
+	int err = 0;
+
+	mutex_lock(&dev->vlan_mutex);
+
+	/* use dev->vlan_cache due to lack of searching valid vlan entry */
+	for (vid = 0; vid < dev->num_vlans; vid++) {
+		vlan_cache = &dev->vlan_cache[vid];
+
+		if (!(vlan_cache->table[0] & VLAN_VALID))
+			continue;
+
+		untagged = false;
+		pvid = false;
+
+		if (vlan_cache->table[2] & BIT(port)) {
+			if (vlan_cache->table[1] & BIT(port))
+				untagged = true;
+			ksz_pread16(dev, port, REG_PORT_DEFAULT_VID, &val);
+			if (vid == (val & 0xFFFFF))
+				pvid = true;
+
+			err = cb(vid, pvid, untagged, data);
+			if (err)
+				break;
+		}
+	}
+
+	mutex_unlock(&dev->vlan_mutex);
+
+	return err;
+}
+
 struct alu_struct {
 	/* entry 1 */
 	u8	is_static:1;
@@ -1068,6 +1108,7 @@ static const struct dsa_switch_ops ksz_switch_ops = {
 	.port_vlan_prepare	= ksz_port_vlan_prepare,
 	.port_vlan_add		= ksz_port_vlan_add,
 	.port_vlan_del		= ksz_port_vlan_del,
+	.port_vlan_dump		= ksz_port_vlan_dump,
 	.port_fdb_dump		= ksz_port_fdb_dump,
 	.port_fdb_add		= ksz_port_fdb_add,
 	.port_fdb_del		= ksz_port_fdb_del,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2ad32734b6f6..dc762e85c556 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1011,6 +1011,54 @@ static int mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	return chip->info->ops->vtu_loadpurge(chip, entry);
 }
 
+static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
+				    dsa_vlan_dump_cb_t *cb, void *data)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+	struct mv88e6xxx_vtu_entry next = {
+		.vid = chip->info->max_vid,
+	};
+	bool untagged;
+	u16 pvid;
+	int err;
+
+	if (!chip->info->max_vid)
+		return -EOPNOTSUPP;
+
+	mutex_lock(&chip->reg_lock);
+
+	err = mv88e6xxx_port_get_pvid(chip, port, &pvid);
+	if (err)
+		goto unlock;
+
+	do {
+		err = mv88e6xxx_vtu_getnext(chip, &next);
+		if (err)
+			break;
+
+		if (!next.valid)
+			break;
+
+		if (next.member[port] ==
+		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+			continue;
+
+		untagged = false;
+		if (next.member[port] ==
+		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNTAGGED)
+			untagged = true;
+
+		err = cb(next.vid, next.vid == pvid, untagged, data);
+		if (err)
+			break;
+	} while (next.vid < chip->info->max_vid);
+
+unlock:
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
@@ -3820,6 +3868,7 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 	.port_fdb_add           = mv88e6xxx_port_fdb_add,
 	.port_fdb_del           = mv88e6xxx_port_fdb_del,
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 1fd419031948..317e0cd4bf70 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -291,6 +291,8 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 /* FDB (and MDB) dump callback */
 typedef int dsa_fdb_dump_cb_t(const unsigned char *addr, u16 vid,
 			      bool is_static, void *data);
+typedef int dsa_vlan_dump_cb_t(u16 vid, bool pvid, bool untagged, void *data);
+
 struct dsa_switch_ops {
 	/*
 	 * Legacy probing.
@@ -397,6 +399,9 @@ struct dsa_switch_ops {
 				 struct switchdev_trans *trans);
 	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
 				 const struct switchdev_obj_port_vlan *vlan);
+	int	(*port_vlan_dump)(struct dsa_switch *ds, int port,
+				  dsa_vlan_dump_cb_t *cb, void *data);
+
 	/*
 	 * Forwarding database
 	 */
-- 
2.14.0
