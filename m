From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: mv88e6xxx: isolate unbridged ports
Date: Wed,  4 Nov 2015 17:23:40 -0500
Message-ID: <1446675820-25608-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA documentation specifies that each port must be capable of
forwarding frames to the CPU port. The last changes on bridging support
for the mv88e6xxx driver broke this requirement for non-bridged ports.

So as for the bridged ports, reserve a few VLANs (4000+) in the switch
to isolate ports that have not been bridged yet.

By default, a port will be isolated with the CPU and DSA ports. When the
port joins a bridge, it will leave its reserved port. When it is removed
from a bridge, it will join its reserved VLAN again.

Fixes: 5fe7f68016ff ("net: dsa: mv88e6xxx: fix hardware bridging")
Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  2 ++
 drivers/net/dsa/mv88e6352.c |  2 ++
 drivers/net/dsa/mv88e6xxx.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 4 files changed, 48 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 54aa000..6e18213 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -103,6 +103,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_join_bridge	= mv88e6xxx_port_bridge_join,
+	.port_leave_bridge	= mv88e6xxx_port_bridge_leave,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index ff846d0..cc6c545 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -323,6 +323,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_eeprom		= mv88e6352_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_join_bridge	= mv88e6xxx_port_bridge_join,
+	.port_leave_bridge	= mv88e6xxx_port_bridge_leave,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
 	.port_pvid_get		= mv88e6xxx_port_pvid_get,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 04cff58..b06dba0 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1462,6 +1462,10 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans)
 {
+	/* We reserve a few VLANs to isolate unbridged ports */
+	if (vlan->vid_end >= 4000)
+		return -EOPNOTSUPP;
+
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
 	 */
@@ -1870,6 +1874,36 @@ unlock:
 	return err;
 }
 
+int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	const u16 pvid = 4000 + ds->index * DSA_MAX_PORTS + port;
+	int err;
+
+	/* The port joined a bridge, so leave its reserved VLAN */
+	mutex_lock(&ps->smi_mutex);
+	err = _mv88e6xxx_port_vlan_del(ds, port, pvid);
+	if (!err)
+		err = _mv88e6xxx_port_pvid_set(ds, port, 0);
+	mutex_unlock(&ps->smi_mutex);
+	return err;
+}
+
+int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	const u16 pvid = 4000 + ds->index * DSA_MAX_PORTS + port;
+	int err;
+
+	/* The port left the bridge, so join its reserved VLAN */
+	mutex_lock(&ps->smi_mutex);
+	err = _mv88e6xxx_port_vlan_add(ds, port, pvid, true);
+	if (!err)
+		err = _mv88e6xxx_port_pvid_set(ds, port, pvid);
+	mutex_unlock(&ps->smi_mutex);
+	return err;
+}
+
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
 	struct mv88e6xxx_priv_state *ps;
@@ -2140,6 +2174,14 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 		ret = mv88e6xxx_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
+
+		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
+			continue;
+
+		/* setup the unbridged state */
+		ret = mv88e6xxx_port_bridge_leave(ds, i, 0);
+		if (ret < 0)
+			return ret;
 	}
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index fb9a873..21c8daa 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -468,6 +468,8 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
 int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e);
+int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members);
+int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
 int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
-- 
2.6.2
