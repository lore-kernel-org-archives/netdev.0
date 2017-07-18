From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next 07/11] net: dsa: Remove support for bypass bridge port attributes/vlan set
Date: Tue, 18 Jul 2017 17:20:20 +0300
Message-ID: <1500387624-4361-8-git-send-email-arkadis@mellanox.com>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36114 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752218AbdGROQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 10:16:59 -0400
In-Reply-To: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge port attributes/vlan for DSA devices should be set only
from bridge code. Furthermore, The vlans are synced totally with the
bridge so there is no need for special dump support.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 drivers/net/dsa/b53/b53_common.c       | 44 --------------------------
 drivers/net/dsa/b53/b53_priv.h         |  3 --
 drivers/net/dsa/bcm_sf2.c              |  1 -
 drivers/net/dsa/dsa_loop.c             | 38 -----------------------
 drivers/net/dsa/microchip/ksz_common.c | 41 -------------------------
 drivers/net/dsa/mv88e6xxx/chip.c       | 56 ----------------------------------
 include/net/dsa.h                      |  4 ---
 net/dsa/dsa_priv.h                     |  4 ---
 net/dsa/port.c                         | 12 --------
 net/dsa/slave.c                        |  6 ----
 10 files changed, 209 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index c414b43..6020e88 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1053,49 +1053,6 @@ int b53_vlan_del(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL(b53_vlan_del);
 
-int b53_vlan_dump(struct dsa_switch *ds, int port,
-		  struct switchdev_obj_port_vlan *vlan,
-		  switchdev_obj_dump_cb_t *cb)
-{
-	struct b53_device *dev = ds->priv;
-	u16 vid, vid_start = 0, pvid;
-	struct b53_vlan *vl;
-	int err = 0;
-
-	if (is5325(dev) || is5365(dev))
-		vid_start = 1;
-
-	b53_read16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port), &pvid);
-
-	/* Use our software cache for dumps, since we do not have any HW
-	 * operation returning only the used/valid VLANs
-	 */
-	for (vid = vid_start; vid < dev->num_vlans; vid++) {
-		vl = &dev->vlans[vid];
-
-		if (!vl->valid)
-			continue;
-
-		if (!(vl->members & BIT(port)))
-			continue;
-
-		vlan->vid_begin = vlan->vid_end = vid;
-		vlan->flags = 0;
-
-		if (vl->untag & BIT(port))
-			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-		if (pvid == vid)
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL(b53_vlan_dump);
-
 /* Address Resolution Logic routines */
 static int b53_arl_op_wait(struct b53_device *dev)
 {
@@ -1552,7 +1509,6 @@ static const struct dsa_switch_ops b53_switch_ops = {
 	.port_vlan_prepare	= b53_vlan_prepare,
 	.port_vlan_add		= b53_vlan_add,
 	.port_vlan_del		= b53_vlan_del,
-	.port_vlan_dump		= b53_vlan_dump,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index f29c892..af5d6c1 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -393,9 +393,6 @@ void b53_vlan_add(struct dsa_switch *ds, int port,
 		  struct switchdev_trans *trans);
 int b53_vlan_del(struct dsa_switch *ds, int port,
 		 const struct switchdev_obj_port_vlan *vlan);
-int b53_vlan_dump(struct dsa_switch *ds, int port,
-		  struct switchdev_obj_port_vlan *vlan,
-		  switchdev_obj_dump_cb_t *cb);
 int b53_fdb_add(struct dsa_switch *ds, int port,
 		const unsigned char *addr, u16 vid);
 int b53_fdb_del(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index a26e99d..824a137 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1033,7 +1033,6 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.port_vlan_prepare	= b53_vlan_prepare,
 	.port_vlan_add		= b53_vlan_add,
 	.port_vlan_del		= b53_vlan_del,
-	.port_vlan_dump		= b53_vlan_dump,
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index fdd8f38..76d6660 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -257,43 +257,6 @@ static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
-				   struct switchdev_obj_port_vlan *vlan,
-				   switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_loop_priv *ps = ds->priv;
-	struct mii_bus *bus = ps->bus;
-	struct dsa_loop_vlan *vl;
-	u16 vid, vid_start = 0;
-	int err = 0;
-
-	dev_dbg(ds->dev, "%s\n", __func__);
-
-	/* Just do a sleeping operation to make lockdep checks effective */
-	mdiobus_read(bus, ps->port_base + port, MII_BMSR);
-
-	for (vid = vid_start; vid < DSA_LOOP_VLANS; vid++) {
-		vl = &ps->vlans[vid];
-
-		if (!(vl->members & BIT(port)))
-			continue;
-
-		vlan->vid_begin = vlan->vid_end = vid;
-		vlan->flags = 0;
-
-		if (vl->untagged & BIT(port))
-			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-		if (ps->pvid == vid)
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	}
-
-	return err;
-}
-
 static struct dsa_switch_ops dsa_loop_driver = {
 	.get_tag_protocol	= dsa_loop_get_protocol,
 	.setup			= dsa_loop_setup,
@@ -310,7 +273,6 @@ static struct dsa_switch_ops dsa_loop_driver = {
 	.port_vlan_prepare	= dsa_loop_port_vlan_prepare,
 	.port_vlan_add		= dsa_loop_port_vlan_add,
 	.port_vlan_del		= dsa_loop_port_vlan_del,
-	.port_vlan_dump		= dsa_loop_port_vlan_dump,
 };
 
 static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index b55f364..a53ce59 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -638,46 +638,6 @@ static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
-			      struct switchdev_obj_port_vlan *vlan,
-			      switchdev_obj_dump_cb_t *cb)
-{
-	struct ksz_device *dev = ds->priv;
-	u16 vid;
-	u16 data;
-	struct vlan_table *vlan_cache;
-	int err = 0;
-
-	mutex_lock(&dev->vlan_mutex);
-
-	/* use dev->vlan_cache due to lack of searching valid vlan entry */
-	for (vid = vlan->vid_begin; vid < dev->num_vlans; vid++) {
-		vlan_cache = &dev->vlan_cache[vid];
-
-		if (!(vlan_cache->table[0] & VLAN_VALID))
-			continue;
-
-		vlan->vid_begin = vid;
-		vlan->vid_end = vid;
-		vlan->flags = 0;
-		if (vlan_cache->table[2] & BIT(port)) {
-			if (vlan_cache->table[1] & BIT(port))
-				vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-			ksz_pread16(dev, port, REG_PORT_DEFAULT_VID, &data);
-			if (vid == (data & 0xFFFFF))
-				vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-
-			err = cb(&vlan->obj);
-			if (err)
-				break;
-		}
-	}
-
-	mutex_unlock(&dev->vlan_mutex);
-
-	return err;
-}
-
 struct alu_struct {
 	/* entry 1 */
 	u8	is_static:1;
@@ -1124,7 +1084,6 @@ static const struct dsa_switch_ops ksz_switch_ops = {
 	.port_vlan_prepare	= ksz_port_vlan_prepare,
 	.port_vlan_add		= ksz_port_vlan_add,
 	.port_vlan_del		= ksz_port_vlan_del,
-	.port_vlan_dump		= ksz_port_vlan_dump,
 	.port_fdb_dump		= ksz_port_fdb_dump,
 	.port_fdb_add		= ksz_port_fdb_add,
 	.port_fdb_del		= ksz_port_fdb_del,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index fba68c8..9cc6269 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1040,61 +1040,6 @@ static int mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	return chip->info->ops->vtu_loadpurge(chip, entry);
 }
 
-static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
-				    struct switchdev_obj_port_vlan *vlan,
-				    switchdev_obj_dump_cb_t *cb)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	struct mv88e6xxx_vtu_entry next = {
-		.vid = chip->info->max_vid,
-	};
-	u16 pvid;
-	int err;
-
-	if (!chip->info->max_vid)
-		return -EOPNOTSUPP;
-
-	mutex_lock(&chip->reg_lock);
-
-	err = mv88e6xxx_port_get_pvid(chip, port, &pvid);
-	if (err)
-		goto unlock;
-
-	do {
-		err = mv88e6xxx_vtu_getnext(chip, &next);
-		if (err)
-			break;
-
-		if (!next.valid)
-			break;
-
-		if (next.member[port] ==
-		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER)
-			continue;
-
-		/* reinit and dump this VLAN obj */
-		vlan->vid_begin = next.vid;
-		vlan->vid_end = next.vid;
-		vlan->flags = 0;
-
-		if (next.member[port] ==
-		    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_UNTAGGED)
-			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-
-		if (next.vid == pvid)
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	} while (next.vid < chip->info->max_vid);
-
-unlock:
-	mutex_unlock(&chip->reg_lock);
-
-	return err;
-}
-
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
@@ -3858,7 +3803,6 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
-	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 	.port_fdb_add           = mv88e6xxx_port_fdb_add,
 	.port_fdb_del           = mv88e6xxx_port_fdb_del,
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4835b0e..9171b11 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -384,10 +384,6 @@ struct dsa_switch_ops {
 				 struct switchdev_trans *trans);
 	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
 				 const struct switchdev_obj_port_vlan *vlan);
-	int	(*port_vlan_dump)(struct dsa_switch *ds, int port,
-				  struct switchdev_obj_port_vlan *vlan,
-				  switchdev_obj_dump_cb_t *cb);
-
 	/*
 	 * Forwarding database
 	 */
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2b2f124..421df4f 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -138,10 +138,6 @@ int dsa_port_vlan_add(struct dsa_port *dp,
 		      struct switchdev_trans *trans);
 int dsa_port_vlan_del(struct dsa_port *dp,
 		      const struct switchdev_obj_port_vlan *vlan);
-int dsa_port_vlan_dump(struct dsa_port *dp,
-		       struct switchdev_obj_port_vlan *vlan,
-		       switchdev_obj_dump_cb_t *cb);
-
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 86e0585..ce19216 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -246,15 +246,3 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 
 	return dsa_port_notify(dp, DSA_NOTIFIER_VLAN_DEL, &info);
 }
-
-int dsa_port_vlan_dump(struct dsa_port *dp,
-		       struct switchdev_obj_port_vlan *vlan,
-		       switchdev_obj_dump_cb_t *cb)
-{
-	struct dsa_switch *ds = dp->ds;
-
-	if (ds->ops->port_vlan_dump)
-		return ds->ops->port_vlan_dump(ds, dp->index, vlan, cb);
-
-	return -EOPNOTSUPP;
-}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bf93fbc..ec4e758 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -302,9 +302,6 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_dump(dp, SWITCHDEV_OBJ_PORT_MDB(obj), cb);
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = dsa_port_vlan_dump(dp, SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
-		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -926,9 +923,6 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
 	.ndo_poll_controller	= dsa_slave_poll_controller,
 #endif
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
-	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
 	.ndo_setup_tc		= dsa_slave_setup_tc,
 };
-- 
2.4.11
