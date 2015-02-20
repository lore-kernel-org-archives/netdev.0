From: Jonas Johansson <jonasj76@gmail.com>
Subject: [PATCH net-next 2/2] mv88e6131: bonding: implement single device trunking
Date: Fri, 20 Feb 2015 11:51:13 +0100
Message-ID: <1424429473-4601-3-git-send-email-jonasj76@gmail.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
Cc: Jonas Johansson <jonas.johansson@westermo.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:36763 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbbBTKv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:51:29 -0500
Received: by labgq15 with SMTP id gq15so5324109lab.3
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 02:51:27 -0800 (PST)
In-Reply-To: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Johansson <jonas.johansson@westermo.se>

This patch will use the DSA hardware bonding support hooks to setup trunking
for the Marvell 88E6095 device. The implementation only handles trunking in
a single device.

Hooks:
 .bond_add_group: Add port to a bond group
 .bond_del_group: Remove port from a bond group
 .bond_attach: Attach/activate port in bond group
 .bond_detach: Detach/inactivate port in bond group

Procedure to add/remome port from bond group:
 Setup trunk learning (Port Association Vector)
 Setup loop prevention (VLAN Table)
 Setup load balancing (Trunk Mask Load Balance Table)

Procedure to attach/detach port:
 Change load balancing (Trunk Mask Load Balance Table)

Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
---
 drivers/net/dsa/mv88e6131.c | 254 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  14 +++
 2 files changed, 268 insertions(+)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 2540ef0..3ba7a0c 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -382,6 +382,256 @@ mv88e6131_get_ethtool_stats(struct dsa_switch *ds,
 				    mv88e6131_hw_stats, port, data);
 }
 
+/* Trunking */
+static int mv88e6131_bond_set_trunk_learning(struct dsa_switch *ds,
+					     int *ports, size_t num)
+{
+	u16 port_vec = 0;
+	int ret;
+	int i;
+
+	num = num < MAX_PORTS ? num : MAX_PORTS;
+
+	for (i = 0; i < num; i++)
+		port_vec |= 1 << ports[i];
+
+	for (i = 0; i < num; i++) {
+		ret = mv88e6xxx_reg_read(ds, REG_PORT(ports[i]), REG_PORT_PAV);
+		if (ret < 0)
+			continue;
+		ret = (ret & 0xf800) | (port_vec & 0x7ff);
+		mv88e6xxx_reg_write(ds, REG_PORT(ports[i]), REG_PORT_PAV, ret);
+	}
+
+	return 0;
+}
+
+static int mv88e6131_bond_set_loop_prevention(struct dsa_switch *ds,
+					      int *ports, size_t num)
+{
+	u16 port_vec = 0;
+	int ret;
+	int i;
+
+	num = num < MAX_PORTS ? num : MAX_PORTS;
+
+	for (i = 0; i < num; i++)
+		port_vec |= 1 << ports[i];
+
+	for (i = 0; i < num; i++) {
+		ret = mv88e6xxx_reg_read(ds, REG_PORT(ports[i]), REG_PORT_VLAN_MAP);
+		if (ret < 0)
+			continue;
+		ret &= ~port_vec & 0x7ff;
+		mv88e6xxx_reg_write(ds, REG_PORT(ports[i]), REG_PORT_VLAN_MAP, ret);
+	}
+
+	return 0;
+}
+
+static int mv88e6131_wait_trunk_mask(struct dsa_switch *ds)
+{
+	const int max_retries = 10;
+	int retries = 0;
+	int ret;
+
+	/* Wait for update Trunk Mask data */
+	while (1) {
+		ret = REG_READ(REG_GLOBAL2, REG_TRUNK_MASK);
+		if (!(ret & 0x8000))
+			return ret;
+		if (retries > max_retries) {
+			pr_warn("mv88e6131: Timeout waiting for "
+				"Trunk Mask Table Register Update\n");
+			return -EBUSY;
+		}
+		retries++;
+		usleep_range(20, 50);
+	};
+
+	return -EPERM;
+}
+
+static int mv88e6131_get_trunk_mask(struct dsa_switch *ds, int trunk_nr, u16 *mask)
+{
+	int ret;
+
+	if (trunk_nr > 0x7)
+		return -EINVAL;
+
+	ret = mv88e6131_wait_trunk_mask(ds);
+	if (ret < 0)
+		return ret;
+
+	/* Set MaskNum */
+	ret = (ret & 0x0fff) | (trunk_nr << 12);
+	REG_WRITE(REG_GLOBAL2, REG_TRUNK_MASK, ret);
+
+	/* Get TrunkMask */
+	ret = REG_READ(REG_GLOBAL2, REG_TRUNK_MASK);
+	*mask = ret & 0x7FF;
+
+	return 0;
+}
+
+static int mv88e6131_set_trunk_mask(struct dsa_switch *ds, int trunk_nr, u16 mask)
+{
+	int ret;
+
+	if (trunk_nr > 0x7)
+		return -EINVAL;
+
+	ret = mv88e6131_wait_trunk_mask(ds);
+	if (ret < 0)
+		return ret;
+
+	/* Write TrunkMask */
+	ret = 0x8000 | (ret & 0x7800) | (trunk_nr << 12) | (mask & 0x7ff);
+	REG_WRITE(REG_GLOBAL2, REG_TRUNK_MASK, ret);
+
+	return 0;
+}
+
+static int mv88e6131_bond_set_load_balancing(struct dsa_switch *ds,
+					     int *ports, bool *attached, size_t num)
+{
+	u16 mask;
+	u16 member_mask = 0;
+	int att_ports[MAX_PORTS];
+	int att_num = 0;
+	int ret;
+	int i;
+
+	num = num < MAX_PORTS ? num : MAX_PORTS;
+
+	for (i = 0; i < num; i++) {
+		member_mask |= 1 << ports[i];
+		if (attached[i])
+			att_ports[att_num++] = ports[i];
+	}
+
+	for (i = 0; i < 8; i++) {
+		ret = mv88e6131_get_trunk_mask(ds, i, &mask);
+		if (ret < 0)
+			continue;
+		mask &= ~member_mask;
+		if (att_num)
+			mask |= 1 << att_ports[i % att_num];
+		mv88e6131_set_trunk_mask(ds, i, mask);
+	}
+
+	return 0;
+}
+
+static int mv88e6131_bond_get_ports(struct dsa_switch *ds, int gid, int *ports, bool *attached, size_t sz)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int num = 0;
+	int p;
+
+	for (p = 0; (p < MAX_PORTS) && (num < sz) ; p++) {
+		if (ps->bond_port[p].gid == gid) {
+			ports[num] = p;
+			attached[num] = ps->bond_port[p].attached;
+			num++;
+		}
+	}
+
+	return num;
+}
+
+static int mv88e6131_bond_setup(struct dsa_switch *ds, int gid)
+{
+	int ports[MAX_PORTS];
+	bool attached[MAX_PORTS];
+	int num;
+	int err = 0;
+
+	num = mv88e6131_bond_get_ports(ds, gid, ports, attached, MAX_PORTS);
+
+	err = mv88e6131_bond_set_trunk_learning(ds, ports, num);
+	if (err)
+		return err;
+	err = mv88e6131_bond_set_loop_prevention(ds, ports, num);
+	if (err)
+		return err;
+	err = mv88e6131_bond_set_load_balancing(ds, ports, attached, num);
+	if (err)
+		return err;
+
+	return 0;
+
+}
+
+static int mv88e6131_bond_add_group(struct dsa_switch *ds, int port, int gid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	ps->bond_port[port].gid = gid;
+	ps->bond_port[port].attached = false;
+
+	return mv88e6131_bond_setup(ds, gid);
+}
+
+static int mv88e6131_bond_del_group(struct dsa_switch *ds, int port, int gid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	bool btmp;
+	int ret;
+
+	ps->bond_port[port].gid = 0;
+	ps->bond_port[port].attached = false;
+	mv88e6131_bond_setup(ds, gid);
+
+	/* Reset trunk learning */
+	ret = mv88e6xxx_reg_read(ds, REG_PORT(port), REG_PORT_PAV);
+	if (ret >= 0) {
+		ret = (ret & 0xf800) | ((1 << port) & 0x7ff);
+		mv88e6xxx_reg_write(ds, REG_PORT(port), REG_PORT_PAV, ret);
+	}
+	/* Reset loop prevention  */
+	ret = mv88e6xxx_reg_read(ds, REG_PORT(port), REG_PORT_VLAN_MAP);
+	if (ret >= 0) {
+		ret = (ret & 0xf800) | ((1 << dsa_upstream_port(ds)) & 0x7ff);
+		mv88e6xxx_reg_write(ds, REG_PORT(port), REG_PORT_VLAN_MAP, ret);
+	}
+	/* Reset load balancing */
+	btmp = true;
+	mv88e6131_bond_set_load_balancing(ds, &port, &btmp, 1);
+
+	return 0;
+}
+
+static int mv88e6131_bond_attach(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ports[MAX_PORTS];
+	bool attached[MAX_PORTS];
+	int gid = ps->bond_port[port].gid;
+	int num;
+
+	ps->bond_port[port].attached = true;
+	num = mv88e6131_bond_get_ports(ds, gid, ports, attached, MAX_PORTS);
+
+	return mv88e6131_bond_set_load_balancing(ds, ports, attached, num);
+}
+
+static int mv88e6131_bond_detach(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ports[MAX_PORTS];
+	bool attached[MAX_PORTS];
+	int gid = ps->bond_port[port].gid;
+	int num;
+
+	ps->bond_port[port].attached = false;
+	num = mv88e6131_bond_get_ports(ds, gid, ports, attached, MAX_PORTS);
+
+	return mv88e6131_bond_set_load_balancing(ds, ports, attached, num);
+}
+
+
+
 static int mv88e6131_get_sset_count(struct dsa_switch *ds)
 {
 	return ARRAY_SIZE(mv88e6131_hw_stats);
@@ -399,6 +649,10 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_strings		= mv88e6131_get_strings,
 	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
 	.get_sset_count		= mv88e6131_get_sset_count,
+	.bond_add_group		= mv88e6131_bond_add_group,
+	.bond_del_group		= mv88e6131_bond_del_group,
+	.bond_attach		= mv88e6131_bond_attach,
+	.bond_detach		= mv88e6131_bond_detach,
 };
 
 MODULE_ALIAS("platform:mv88e6085");
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 7294227..383b224 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -11,9 +11,19 @@
 #ifndef __MV88E6XXX_H
 #define __MV88E6XXX_H
 
+#define MAX_PORTS		11
+
 #define REG_PORT(p)		(0x10 + (p))
+#define REG_PORT_VLAN_MAP	0x6
+#define REG_PORT_PAV		0xb
 #define REG_GLOBAL		0x1b
 #define REG_GLOBAL2		0x1c
+#define REG_TRUNK_MASK		0x7
+
+struct mv88e6xxx_bond_port {
+	int gid;
+	bool attached;
+};
 
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
@@ -49,6 +59,10 @@ struct mv88e6xxx_priv_state {
 	struct mutex eeprom_mutex;
 
 	int		id; /* switch product id */
+
+	/* Contains bonding info for each port
+	 */
+	struct mv88e6xxx_bond_port	bond_port[MAX_PORTS];
 };
 
 struct mv88e6xxx_hw_stat {
-- 
2.1.0
