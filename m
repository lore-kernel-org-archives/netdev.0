From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT/RFC PATCH 4/8] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Mon, 23 Feb 2015 11:35:46 -0800
Message-ID: <1424720150-27564-5-git-send-email-linux@roeck-us.net>
References: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34297 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbbBWTgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:36:09 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPynX-003fLG-Ts
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 19:36:08 +0000
In-Reply-To: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge support is similar for all chips supported by the mv88e6xxx code,
so add the code there.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 297 ++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h |  15 +++
 2 files changed, 300 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d253f4e..5c97327 100644
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
+	return _mv88e6xxx_wait(ds, REG_GLOBAL, 0x0b, 0x8000);
+}
+
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum)
 {
 	int ret;
@@ -721,29 +747,271 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
+static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
 {
-	u16 reg;
+	int ret;
+
+	ret = _mv88e6xxx_atu_wait(ds);
+	if (ret < 0) {
+		netdev_err(ds->ports[fid], "ATU busy\n");
+		return ret;
+	}
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
+	if (ret < 0) {
+		netdev_err(ds->ports[fid],
+			   "Failed to set FID for flush operation\n");
+		return ret;
+	}
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0b, 0xe000);
+	if (ret < 0) {
+		netdev_err(ds->ports[fid],
+			   "Failed to flush forwarding database for FID %d\n",
+			   fid);
+		return ret;
+	}
+
+	return 0;
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
+	oldstate = reg & 3;
+	if (oldstate != state) {
+		/* Flush forwarding database if we're moving a port
+		 * from Learning or Forwarding state to Disabled or
+		 * Blocking or Listening state.
+		 */
+		if ((oldstate & 2) && !(state & 2)) {
+			ret = _mv88e6xxx_flush_fid(ds, ps->fid[port]);
+			if (ret)
+				goto abort;
+		}
+		reg = (reg & ~3) | state;
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
 
-	/* Port based VLAN map: give each port its own address
-	 * database, allow the CPU port to talk to each of the 'real'
-	 * ports, and allow each of the 'real' ports to only talk to
-	 * the upstream port.
-	 */
-	reg = (port & 0xf) << 12;
 	if (dsa_is_cpu_port(ds, port))
 		reg |= ds->phys_port_mask;
 	else
-		reg |= 1 << dsa_upstream_port(ds);
+		reg |= (ps->bridge_mask[fid] |
+		       (1 << dsa_upstream_port(ds))) & ~(1 << port);
+
+	netdev_dbg(ds->ports[port], "fid %d 0x06:=0x%x\n", fid, reg);
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
+		stp_state = 0;
+		break;
+	case BR_STATE_BLOCKING:
+	case BR_STATE_LISTENING:
+		stp_state = 1;
+		break;
+	case BR_STATE_LEARNING:
+		stp_state = 2;
+		break;
+	case BR_STATE_FORWARDING:
+	default:
+		stp_state = 3;
+		break;
+	}
+
+	netdev_dbg(ds->ports[port], "port state %d [%d]\n", state, stp_state);
+
+	/* mv88e6xxx_port_stp_update may be called with softirqs disabled,
+	 * so we can not update the port state directly but need to schedule it.
+	 */
+	spin_lock(&ps->bridge_lock);
+	ps->port_state[port] = stp_state;
+	ps->port_state_update_mask |= 1 << port;
+	schedule_work(&ps->bridge_work);
+	spin_unlock(&ps->bridge_lock);
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
+	spin_lock(&ps->bridge_lock);
+
+	while (ps->port_state_update_mask) {
+		port = __ffs(ps->port_state_update_mask);
+		mv88e6xxx_set_port_state(ds, port, ps->port_state[port]);
+		ps->port_state_update_mask &= ~(1 << port);
+	}
+
+	spin_unlock(&ps->bridge_lock);
+}
+
+int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret, fid;
 
-	REG_WRITE(REG_PORT(port), 0x06, reg);
+	mutex_lock(&ps->smi_mutex);
 
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	REG_WRITE(REG_PORT(port), 0x07, 0x0000);
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x07, 0x0000);
+	if (ret)
+		goto abort;
 
-	return 0;
+	/* Port based VLAN map: give each port its own address
+	 * database, allow the CPU port to talk to each of the 'real'
+	 * ports, and allow each of the 'real' ports to only talk to
+	 * the upstream port.
+	 */
+	fid = __ffs(ps->fid_mask);
+	ps->fid[port] = fid;
+	ps->fid_mask &= ~(1 << fid);
+
+	if (!dsa_is_cpu_port(ds, port))
+		ps->bridge_mask[fid] = 1 << port;
+
+	ret = _mv88e6xxx_update_port_config(ds, port);
+
+abort:
+	mutex_unlock(&ps->smi_mutex);
+	return ret;
 }
 
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
@@ -753,6 +1021,11 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	mutex_init(&ps->smi_mutex);
 	mutex_init(&ps->stats_mutex);
 	mutex_init(&ps->phy_mutex);
+	spin_lock_init(&ps->bridge_lock);
+
+	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
+
+	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a4df496..708131b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -49,6 +49,18 @@ struct mv88e6xxx_priv_state {
 	struct mutex eeprom_mutex;
 
 	int		id; /* switch product id */
+
+	/* hw bridging */
+
+	u32 fid_mask;
+	u8 fid[DSA_MAX_PORTS];
+	u16 bridge_mask[DSA_MAX_PORTS];
+
+	u32 port_state_update_mask;
+	u8 port_state[DSA_MAX_PORTS];
+
+	struct work_struct bridge_work;
+	spinlock_t bridge_lock;		/* protect access to hw bridge data */
 };
 
 struct mv88e6xxx_hw_stat {
@@ -93,6 +105,9 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
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
