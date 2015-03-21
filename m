From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sat, 21 Mar 2015 08:46:45 -0700
Message-ID: <1426952815-4642-9-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bridge support is similar for all chips supported by the mv88e6xxx code,
so add the code there.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 271 ++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h |  28 +++++
 2 files changed, 292 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c2c0460..17aa74f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/if_bridge.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
@@ -644,6 +645,31 @@ int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 	return mv88e6xxx_wait(ds, REG_GLOBAL2, 0x14, 0x8000);
 }
 
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
+{
+	unsigned long timeout = jiffies + HZ / 10;
+
+	while (time_before(jiffies, timeout)) {
+		int ret;
+
+		ret = _mv88e6xxx_reg_read(ds, reg, offset);
+		if (ret < 0)
+			return ret;
+		if (!(ret & mask))
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+	return -ETIMEDOUT;
+}
+
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
+{
+	return _mv88e6xxx_wait(ds, REG_GLOBAL, 0x0b, ATU_BUSY);
+}
+
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum)
 {
 	int ret;
@@ -717,10 +743,236 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
+{
+	int ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0b, cmd);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_atu_wait(ds);
+}
+
+static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
+{
+	int ret;
+
+	ret = _mv88e6xxx_atu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_atu_cmd(ds, fid, ATU_CMD_FLUSH_NONSTATIC_FID);
+}
+
+static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int reg, ret;
+	u8 oldstate;
+
+	mutex_lock(&ps->smi_mutex);
+
+	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), 0x04);
+	if (reg < 0)
+		goto abort;
+
+	oldstate = reg & PSTATE_MASK;
+	if (oldstate != state) {
+		/* Flush forwarding database if we're moving a port
+		 * from Learning or Forwarding state to Disabled or
+		 * Blocking or Listening state.
+		 */
+		if (oldstate >= PSTATE_LEARNING && state <= PSTATE_BLOCKING) {
+			ret = _mv88e6xxx_flush_fid(ds, ps->fid[port]);
+			if (ret)
+				goto abort;
+		}
+		reg = (reg & ~PSTATE_MASK) | state;
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x04, reg);
+	}
+
+abort:
+	mutex_unlock(&ps->smi_mutex);
+	return ret;
+}
+
+/* Must be called with smi lock held */
+static int _mv88e6xxx_update_port_config(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u8 fid = ps->fid[port];
+	u16 reg = fid << 12;
+
+	if (dsa_is_cpu_port(ds, port))
+		reg |= ds->phys_port_mask;
+	else
+		reg |= (ps->bridge_mask[fid] |
+		       (1 << dsa_upstream_port(ds))) & ~(1 << port);
+
+	return _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x06, reg);
+}
+
+/* Must be called with smi lock held */
+static int _mv88e6xxx_update_bridge_config(struct dsa_switch *ds, int fid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int port;
+	u32 mask;
+	int ret;
+
+	mask = ds->phys_port_mask;
+	while (mask) {
+		port = __ffs(mask);
+		mask &= ~(1 << port);
+		if (ps->fid[port] != fid)
+			continue;
+
+		ret = _mv88e6xxx_update_port_config(ds, port);
+		if (ret)
+			return ret;
+	}
+
+	return _mv88e6xxx_flush_fid(ds, fid);
+}
+
+/* Bridge handling functions */
+
+int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret = 0;
+	u32 nmask;
+	int fid;
+
+	/* If the bridge group is not empty, join that group.
+	 * Otherwise create a new group.
+	 */
+	fid = ps->fid[port];
+	nmask = br_port_mask & ~(1 << port);
+	if (nmask)
+		fid = ps->fid[__ffs(nmask)];
+
+	nmask = ps->bridge_mask[fid] | (1 << port);
+	if (nmask != br_port_mask) {
+		netdev_err(ds->ports[port],
+			   "join: Bridge port mask mismatch fid=%d mask=0x%x expected 0x%x\n",
+			   fid, br_port_mask, nmask);
+		return -EINVAL;
+	}
+
+	mutex_lock(&ps->smi_mutex);
+
+	ps->bridge_mask[fid] = br_port_mask;
+
+	if (fid != ps->fid[port]) {
+		ps->fid_mask |= 1 << ps->fid[port];
+		ps->fid[port] = fid;
+		ret = _mv88e6xxx_update_bridge_config(ds, fid);
+	}
+
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u8 fid, newfid;
+	int ret;
+
+	fid = ps->fid[port];
+
+	if (ps->bridge_mask[fid] != br_port_mask) {
+		netdev_err(ds->ports[port],
+			   "leave: Bridge port mask mismatch fid=%d mask=0x%x expected 0x%x\n",
+			   fid, br_port_mask, ps->bridge_mask[fid]);
+		return -EINVAL;
+	}
+
+	/* If the port was the last port of a bridge, we are done.
+	 * Otherwise assign a new fid to the port, and fix up
+	 * the bridge configuration.
+	 */
+	if (br_port_mask == (1 << port))
+		return 0;
+
+	mutex_lock(&ps->smi_mutex);
+
+	newfid = __ffs(ps->fid_mask);
+	ps->fid[port] = newfid;
+	ps->fid_mask &= (1 << newfid);
+	ps->bridge_mask[fid] &= ~(1 << port);
+	ps->bridge_mask[newfid] = 1 << port;
+
+	ret = _mv88e6xxx_update_bridge_config(ds, fid);
+	if (!ret)
+		ret = _mv88e6xxx_update_bridge_config(ds, newfid);
+
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int stp_state;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		stp_state = PSTATE_DISABLED;
+		break;
+	case BR_STATE_BLOCKING:
+	case BR_STATE_LISTENING:
+		stp_state = PSTATE_BLOCKING;
+		break;
+	case BR_STATE_LEARNING:
+		stp_state = PSTATE_LEARNING;
+		break;
+	case BR_STATE_FORWARDING:
+	default:
+		stp_state = PSTATE_FORWARDING;
+		break;
+	}
+
+	netdev_dbg(ds->ports[port], "port state %d [%d]\n", state, stp_state);
+
+	/* mv88e6xxx_port_stp_update may be called with softirqs disabled,
+	 * so we can not update the port state directly but need to schedule it.
+	 */
+	ps->port_state[port] = stp_state;
+	set_bit(port, &ps->port_state_update_mask);
+	schedule_work(&ps->bridge_work);
+
+	return 0;
+}
+
+static void mv88e6xxx_bridge_work(struct work_struct *work)
+{
+	struct mv88e6xxx_priv_state *ps;
+	struct dsa_switch *ds;
+	int port;
+
+	ps = container_of(work, struct mv88e6xxx_priv_state, bridge_work);
+	ds = ((struct dsa_switch *)ps) - 1;
+
+	while (ps->port_state_update_mask) {
+		port = __ffs(ps->port_state_update_mask);
+		clear_bit(port, &ps->port_state_update_mask);
+		mv88e6xxx_set_port_state(ds, port, ps->port_state[port]);
+	}
+}
+
 int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int reg;
+	int ret, fid;
 
 	mutex_lock(&ps->smi_mutex);
 
@@ -736,13 +988,14 @@ int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the upstream port.
 	 */
-	reg = (port & 0xf) << 12;
-	if (dsa_is_cpu_port(ds, port))
-		reg |= ds->phys_port_mask;
-	else
-		reg |= 1 << dsa_upstream_port(ds);
+	fid = __ffs(ps->fid_mask);
+	ps->fid[port] = fid;
+	ps->fid_mask &= ~(1 << fid);
+
+	if (!dsa_is_cpu_port(ds, port))
+		ps->bridge_mask[fid] = 1 << port;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x06, reg);
+	ret = _mv88e6xxx_update_port_config(ds, port);
 	if (ret)
 		goto abort;
 
@@ -763,6 +1016,10 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	mutex_init(&ps->stats_mutex);
 	mutex_init(&ps->phy_mutex);
 
+	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
+
+	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
+
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a4df496..8e215eb 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -15,6 +15,20 @@
 #define REG_GLOBAL		0x1b
 #define REG_GLOBAL2		0x1c
 
+/* ATU commands */
+
+#define ATU_BUSY			0x8000
+
+#define ATU_CMD_FLUSH_NONSTATIC_FID	(ATU_BUSY | 0x6000)
+
+/* port states */
+
+#define PSTATE_MASK		0x03
+#define PSTATE_DISABLED		0x00
+#define PSTATE_BLOCKING		0x01
+#define PSTATE_LEARNING		0x02
+#define PSTATE_FORWARDING	0x03
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -49,6 +63,17 @@ struct mv88e6xxx_priv_state {
 	struct mutex eeprom_mutex;
 
 	int		id; /* switch product id */
+
+	/* hw bridging */
+
+	u32 fid_mask;
+	u8 fid[DSA_MAX_PORTS];
+	u16 bridge_mask[DSA_MAX_PORTS];
+
+	unsigned long port_state_update_mask;
+	u8 port_state[DSA_MAX_PORTS];
+
+	struct work_struct bridge_work;
 };
 
 struct mv88e6xxx_hw_stat {
@@ -93,6 +118,9 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
 int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e);
+int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
+int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
+int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.1.0
