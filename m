From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 3/3] net: dsa: mv88e6xxx: setup PVT
Date: Wed, 20 Apr 2016 16:26:09 -0400
Message-ID: <1461183969-24610-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of allowing any external frame to egress any internal port,
configure the Cross-chip Port VLAN Table (PVT) to forbid that.

When an external source port joins or leaves a bridge crossing this
switch, mask it in the PVT to allow or forbid frames to egress.

Add support for the cross-chip bridge notification to the 6352 family.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |   1 +
 drivers/net/dsa/mv88e6xxx.c | 137 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h |   2 +
 3 files changed, 138 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 4afc24d..03ab309 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -364,6 +364,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
+	.cross_chip_bridge	= mv88e6xxx_cross_chip_bridge,
 };
 
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e35bc9f..dccefdb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -481,6 +481,14 @@ static bool mv88e6xxx_has_stu(struct dsa_switch *ds)
 	return false;
 }
 
+static bool mv88e6xxx_has_pvt(struct dsa_switch *ds)
+{
+	if (mv88e6xxx_6185_family(ds))
+		return false;
+
+	return true;
+}
+
 /* We expect the switch to perform auto negotiation if there is a real
  * phy. However, in the case of a fixed link phy, we force the port
  * settings from the fixed link settings.
@@ -2228,8 +2236,69 @@ static int _mv88e6xxx_pvt_cmd(struct dsa_switch *ds, int src_dev, int src_port,
 	return _mv88e6xxx_pvt_wait(ds);
 }
 
+static int _mv88e6xxx_pvt_read(struct dsa_switch *ds, int src_dev, int src_port,
+			       u16 *data)
+{
+	int ret;
+
+	ret = _mv88e6xxx_pvt_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_pvt_cmd(ds, src_dev, src_port,
+				GLOBAL2_PVT_ADDR_OP_READ);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_PVT_DATA);
+	if (ret < 0)
+		return ret;
+
+	*data = ret;
+
+	return 0;
+}
+
+static int _mv88e6xxx_pvt_write(struct dsa_switch *ds, int src_dev,
+				int src_port, u16 data)
+{
+	int err;
+
+	err = _mv88e6xxx_pvt_wait(ds);
+	if (err)
+		return err;
+
+	err = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_PVT_DATA, data);
+	if (err)
+		return err;
+
+        return _mv88e6xxx_pvt_cmd(ds, src_dev, src_port,
+				GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN);
+}
+
+static int _mv88e6xxx_pvt_map(struct dsa_switch *ds, int src_dev, int src_port,
+			      struct net_device *bridge)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 pvlan = 0;
+	int port;
+
+	for (port = 0; port < ps->info->num_ports; ++port) {
+		/* Frames from external ports can egress DSA and CPU ports */
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+			pvlan |= BIT(port);
+
+		/* Frames can egress bridge group members */
+		if (bridge && ps->ports[port].bridge_dev == bridge)
+			pvlan |= BIT(port);
+	}
+
+	return _mv88e6xxx_pvt_write(ds, src_dev, src_port, pvlan);
+}
+
 static int _mv88e6xxx_pvt_init(struct dsa_switch *ds)
 {
+	int src_dev, src_port;
 	int err;
 
 	/* Clear 5 Bit Port for usage with Marvell Link Street devices:
@@ -2240,8 +2309,21 @@ static int _mv88e6xxx_pvt_init(struct dsa_switch *ds)
 	if (err)
 		return err;
 
-	/* Allow any external frame to egress any internal port */
-	return _mv88e6xxx_pvt_cmd(ds, 0, 0, GLOBAL2_PVT_ADDR_OP_INIT_ONES);
+	/* Forbid every port of potential neighbor switches to egress frames on
+	 * the normal ports of this switch.
+	 */
+	for (src_dev = 0; src_dev < 32; ++src_dev) {
+		if (src_dev == ds->index)
+			continue;
+
+		for (src_port = 0; src_port < 16; ++src_port) {
+			err = _mv88e6xxx_pvt_map(ds, src_dev, src_port, NULL);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
 }
 
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
@@ -2286,6 +2368,35 @@ unlock:
 	return err;
 }
 
+static int _mv88e6xxx_pvt_unmap_local(struct dsa_switch *ds, int port)
+{
+	u16 pvlan;
+	int src_dev, src_port, err;
+
+	for (src_dev = 0; src_dev < 32; ++src_dev) {
+		if (src_dev == ds->index)
+			continue;
+
+		for (src_port = 0; src_port < 16; ++src_port) {
+			err = _mv88e6xxx_pvt_read(ds, src_dev, src_port,
+						  &pvlan);
+			if (err)
+				return err;
+
+			/* Forbid external normal frames to egress this port */
+			if (pvlan & BIT(port)) {
+				err = _mv88e6xxx_pvt_write(ds, src_dev,
+							   src_port,
+							   pvlan & ~BIT(port));
+				if (err)
+					return err;
+			}
+		}
+	}
+
+	return 0;
+}
+
 void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -2308,6 +2419,28 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 			if (_mv88e6xxx_port_based_vlan_map(ds, i))
 				netdev_warn(ds->ports[i], "failed to remap\n");
 
+	if (mv88e6xxx_has_pvt(ds) && _mv88e6xxx_pvt_unmap_local(ds, port))
+		netdev_err(ds->ports[port], "failed to unmap\n");
+
+	mutex_unlock(&ps->smi_mutex);
+}
+
+void mv88e6xxx_cross_chip_bridge(struct dsa_switch *ds, int sw_index,
+				 int sw_port, struct net_device *bridge)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (!mv88e6xxx_has_pvt(ds))
+		return;
+
+	/* Update the Cross-chip Port VLAN Table (PVT) entry for this external
+	 * source port to map which internal ports frames are allowed to egress.
+	 */
+
+	mutex_lock(&ps->smi_mutex);
+	if (_mv88e6xxx_pvt_map(ds, sw_index, sw_port, bridge))
+		dev_err(ds->master_dev, "failed to access PVT for sw%dp%d\n",
+			sw_index, sw_port);
 	mutex_unlock(&ps->smi_mutex);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index dd63377..ea214f2 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -523,6 +523,8 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 			    struct switchdev_obj_port_fdb *fdb,
 			    int (*cb)(struct switchdev_obj *obj));
+void mv88e6xxx_cross_chip_bridge(struct dsa_switch *ds, int sw_index,
+				 int sw_port, struct net_device *bridge);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
-- 
2.8.0
