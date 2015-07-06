From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 3/3] net: dsa: mv88e6xxx: add switchdev VLAN operations
Date: Sun,  5 Jul 2015 22:14:53 -0400
Message-ID: <1436148893-14379-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:54990 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbbGFCPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 22:15:05 -0400
In-Reply-To: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit implements the switchdev operations to add, delete and dump
VLANs for the Marvell 88E6352 and compatible switch chips.

This allows to access the switch VLAN Table Unit from standard userspace
commands such as "bridge vlan".

A configuration like "1t 2t 3t 4u" for VLAN 10 is achieved like this:

    # bridge vlan add dev swp1 vid 10 master
    # bridge vlan add dev swp2 vid 10 master
    # bridge vlan add dev swp3 vid 10 master
    # bridge vlan add dev swp4 vid 10 master untagged pvid

This calls port_vlan_add() for each command. Removing the port 3 from
VLAN 10 is done with:

    # bridge vlan del dev swp3 vid 10

This calls port_vlan_del() for port 3. Dumping VLANs is done with:

    # bridge vlan show
    port    vlan ids
    swp0    None
    swp0
    swp1     10

    swp1     10

    swp2     10

    swp2     10

    swp3    None
    swp3
    swp4     10 PVID Egress Untagged

    swp4     10 PVID Egress Untagged

    br0     None

This calls port_vlan_dump() for each ports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123_61_65.c |   3 +
 drivers/net/dsa/mv88e6131.c       |   3 +
 drivers/net/dsa/mv88e6171.c       |   3 +
 drivers/net/dsa/mv88e6352.c       |   3 +
 drivers/net/dsa/mv88e6xxx.c       | 152 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |   5 ++
 6 files changed, 169 insertions(+)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 71a29a7..8e679ff 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -134,6 +134,9 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6123");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 32f4a08..c4d914b 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -182,6 +182,9 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6085");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 1c78084..7701ce6 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -119,6 +119,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.fdb_add		= mv88e6xxx_port_fdb_add,
 	.fdb_del		= mv88e6xxx_port_fdb_del,
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 632815c..b981be4a 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -392,6 +392,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_add		= mv88e6xxx_port_fdb_add,
 	.fdb_del		= mv88e6xxx_port_fdb_del,
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_del		= mv88e6xxx_port_vlan_del,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ffd9fc6..d5812ba 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1544,6 +1544,158 @@ static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
 }
 
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+			    u16 bridge_flags)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int prev_vid = vid ? vid - 1 : 0xfff;
+	int i, ret;
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
+		entry.fid = vid; /* We use one FID per VLAN at the moment */
+		entry.sid = 0; /* We don't use 802.1s (yet) */
+
+		/* The DSA port-based VLAN setup also reserves one FID per port;
+		 * thus, warn when requesting one of the first num_ports VIDs.
+		 */
+		if (entry.fid < ps->num_ports)
+			netdev_warn(ds->ports[vid], "using reserved FID\n");
+
+		if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+		    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+			/* A VTU entry need a valid STU entry (undocumented).
+			 * The default STU pointer for a VTU entry is 0. If per
+			 * VLAN spanning tree is not used then only one STU
+			 * entry is needed to cover all VTU entries. Thus,
+			 * validate the STU entry 0.
+			 */
+			ret = _mv88e6xxx_stu_loadpurge(ds, 0, true);
+			if (ret < 0)
+				goto unlock;
+		}
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
+	int i, ret, prev_vid = vid ? vid - 1 : 0xfff;
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
+	/* TODO reset PVID if it was this VID? */
+
+	if (!keep)
+		ret = _mv88e6xxx_update_bridge_config(ds, entry.fid);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port, u16 vid,
+			     u16 *bridge_flags)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int prev_vid = vid ? vid - 1 : 0xfff;
+	int ret;
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
+	switch (entry.tags[port]) {
+	case GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED:
+		*bridge_flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+		break;
+	case GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED:
+		break;
+	default:
+		ret = -EINVAL;
+		goto unlock;
+	}
+
+	/* check PVID */
+	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_DEFAULT_VLAN);
+	if (ret < 0)
+		goto unlock;
+
+	if ((ret & PORT_DEFAULT_VLAN_MASK) == vid)
+		*bridge_flags |= BRIDGE_VLAN_INFO_PVID;
+
+	ret = 0;
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
index 65645b7..be8b6cc 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -440,6 +440,11 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
+			    u16 bridge_flags);
+int mv88e6xxx_port_vlan_del(struct dsa_switch *ds,int port, u16 vid);
+int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds,int port, u16 vid,
+			     u16 *bridge_flags);
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
-- 
2.4.5
