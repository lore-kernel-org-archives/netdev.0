From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 4/4] net: dsa: mv88e6xxx: add support to add/del VLANs
Date: Wed, 24 Jun 2015 14:50:59 -0400
Message-ID: <1435171859-27012-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1435171859-27012-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:54227 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbbFXSvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 14:51:20 -0400
In-Reply-To: <1435171859-27012-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit implements the port_vlan_add and port_vlan_del functions in
the dsa_switch_driver structure for Marvell 88E6xxx compatible switches.

This allows to access a switch VLAN Table Unit from standard userspace
commands such as "bridge vlan add" and "bridge vlan del".

A configuration like "VID 10: 1t 2t 4u" can be achieved like this:

    bridge vlan add dev swp1 vid 10 master
    bridge vlan add dev swp2 vid 10 master
    bridge vlan add dev swp4 vid 10 master untagged pvid

Removing the port 3 from VLAN 10 is done with:

    bridge vlan del dev swp2 vid 10

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |   2 +
 drivers/net/dsa/mv88e6xxx.c | 192 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |   3 +
 3 files changed, 197 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index c35f57f..0e00494 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -397,6 +397,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_add		= mv88e6xxx_port_fdb_add,
 	.fdb_del		= mv88e6xxx_port_fdb_del,
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 31d28ca..37fe81e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1488,6 +1488,198 @@ unlock:
 	return ret;
 }
 
+static int _mv88e6xxx_stu_loadpurge(struct dsa_switch *ds, u8 sid, bool valid)
+{
+	int ret, data;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	data = sid & GLOBAL_VTU_SID_MASK;
+	if (valid)
+		data |= GLOBAL_VTU_VID_VALID;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, data);
+	if (ret < 0)
+		return ret;
+
+	/* Unused (yet) data registers */
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3, 0);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7, 0);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_8_11, 0);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+}
+
+static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
+				    struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 data = 0;
+	int ret, i;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	if (entry->valid) {
+		/* Set Data Register, ports 0-3, offsets 0, 4, 8, 12 */
+		for (data = i = 0; i < 4; ++i)
+			data |= entry->tags[i] << (i * 4);
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_0_3,
+					   data);
+		if (ret < 0)
+			return ret;
+
+		/* Set Data Register, ports 4-6, offsets 0, 4, 8 */
+		for (data = 0, i = 4; i < 7; ++i)
+			data |= entry->tags[i] << ((i - 4) * 4);
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_4_7,
+					   data);
+		if (ret < 0)
+			return ret;
+
+		/* Unused Data Register */
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_DATA_8_11,
+					   0);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID,
+					   entry->sid & GLOBAL_VTU_SID_MASK);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_FID,
+					   entry->fid & GLOBAL_VTU_FID_MASK);
+		if (ret < 0)
+			return ret;
+
+		/* Valid bit set means load, unset means purge */
+		data = GLOBAL_VTU_VID_VALID;
+	}
+
+	data |= entry->vid & GLOBAL_VTU_VID_MASK;
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, data);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+}
+
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+			    u16 bridge_flags)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int prev_vid = vid ? vid - 1 : 4095;
+	int i, ret;
+
+	/* The DSA port-based VLAN setup reserves FID 0 to DSA_MAX_PORTS;
+	 * we will use the next FIDs for 802.1Q;
+	 * thus, warn when requesting one of the last DSA_MAX_PORTS VLANs.
+	 */
+	if (vid > 4095 - DSA_MAX_PORTS)
+		netdev_warn(ds->ports[port], "using a reserved port FID\n");
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	/* If the VLAN does not exist, re-initialize the entry for addition */
+	if (entry.vid != vid || !entry.valid) {
+		memset(&entry, 0, sizeof(entry));
+		entry.valid = true;
+		entry.vid = vid;
+		entry.fid = DSA_MAX_PORTS + vid;
+		entry.sid = 0; /* We don't use 802.1s (yet) */
+
+		/* A VTU entry must have a valid STU entry (undocumented).
+		 * The default STU pointer for a VTU entry is 0. If per VLAN
+		 * spanning tree is not used then only one STU entry is needed
+		 * to cover all VTU entries. Thus, validate the STU entry 0.
+		 */
+		ret = _mv88e6xxx_stu_loadpurge(ds, 0, true);
+		if (ret < 0)
+			goto unlock;
+
+		for (i = 0; i < ps->num_ports; ++i)
+			entry.tags[i] = dsa_is_cpu_port(ds, i) ?
+				GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED :
+				GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+	}
+
+	entry.tags[port] = bridge_flags & BRIDGE_VLAN_INFO_UNTAGGED ?
+		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
+		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
+
+	ret = _mv88e6xxx_vtu_loadpurge(ds, &entry);
+
+	/* Set port default VID */
+	if (bridge_flags & BRIDGE_VLAN_INFO_PVID)
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_DEFAULT_VLAN,
+					   vid & PORT_DEFAULT_VLAN_MASK);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int i, ret, prev_vid = vid ? vid - 1 : 4095;
+	bool keep = false;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_vtu_getnext(ds, prev_vid, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	if (entry.vid != vid || !entry.valid) {
+		ret = -ENOENT;
+		goto unlock;
+	}
+
+	entry.tags[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
+
+	/* keep the VLAN unless all ports are excluded */
+	for (i = 0; i < ps->num_ports; ++i) {
+		if (dsa_is_cpu_port(ds, i))
+			continue;
+
+		if (entry.tags[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
+			keep = true;
+			break;
+		}
+	}
+
+	entry.valid = keep;
+	ret = _mv88e6xxx_vtu_loadpurge(ds, &entry);
+	if (ret < 0)
+		goto unlock;
+
+	/* TODO reset PVID if it was this vid? */
+
+	if (!keep)
+		ret = _mv88e6xxx_update_bridge_config(ds, entry.fid);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 7b75c2b..616171c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -440,6 +440,9 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+			    u16 bridge_flags);
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds,int port, u16 vid);
 int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds,int port, u16 vid,
 			     u16 *bridge_flags);
 extern struct dsa_switch_driver mv88e6131_switch_driver;
-- 
2.4.4
