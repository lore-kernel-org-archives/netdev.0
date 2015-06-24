From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 3/4] net: dsa: mv88e6xxx: add support to dump VLANs
Date: Wed, 24 Jun 2015 14:50:58 -0400
Message-ID: <1435171859-27012-4-git-send-email-vivien.didelot@savoirfairelinux.com>
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
Received: from mail.savoirfairelinux.com ([209.172.62.77]:53122 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbbFXSvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 14:51:20 -0400
In-Reply-To: <1435171859-27012-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit implements the port_vlan_dump function in the
dsa_switch_driver structure for Marvell 88E6xxx compatible switches.

This allows to access a switch VLAN Table Unit from standard userspace
commands such as "bridge vlan show".

A populated VTU can give the following output:

    # bridge vlan
    port	vlan ids
    swp0	None
    swp0
    swp1	None
    swp1
    swp2	1000
		1200

    swp2	1000
		1200

    swp3	550 PVID Egress Untagged

    swp3	550 PVID Egress Untagged

    swp4	1200

    swp4	1200

    br0	None

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 3 files changed, 47 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index b524bd3..c35f57f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -397,6 +397,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_add		= mv88e6xxx_port_fdb_add,
 	.fdb_del		= mv88e6xxx_port_fdb_del,
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d6adeff..31d28ca 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1444,6 +1444,50 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
 	return 0;
 }
 
+int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port, u16 vid,
+			     u16 *bridge_flags)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_entry entry = { 0 };
+	int prev_vid = vid ? vid - 1 : 4095;
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
+		/* fall through... */
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
index 798b6b8..7b75c2b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -440,6 +440,8 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds,int port, u16 vid,
+			     u16 *bridge_flags);
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
-- 
2.4.4
