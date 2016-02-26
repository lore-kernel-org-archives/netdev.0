From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 9/9] net: dsa: mv88e6xxx: support VLAN filtering
Date: Fri, 26 Feb 2016 13:16:08 -0500
Message-ID: <1456510568-13679-10-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement port_vlan_filtering in the driver to toggle the related port
802.1Q mode between DISABLED and SECURE, on user request.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  1 +
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 39 +++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 4 files changed, 43 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index dd1ebaf..d72ccbd 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -106,6 +106,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_port_bridge_join,
 	.port_leave_bridge	= mv88e6xxx_port_bridge_leave,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
+	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index bbca36a..a41fa50 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -327,6 +327,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_port_bridge_join,
 	.port_leave_bridge	= mv88e6xxx_port_bridge_leave,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 27a19dc..d11c9d5 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1712,6 +1712,45 @@ unlock:
 	return err;
 }
 
+static const char * const mv88e6xxx_port_8021q_mode_names[] = {
+	[PORT_CONTROL_2_8021Q_DISABLED] = "Disabled",
+	[PORT_CONTROL_2_8021Q_FALLBACK] = "Fallback",
+	[PORT_CONTROL_2_8021Q_CHECK] = "Check",
+	[PORT_CONTROL_2_8021Q_SECURE] = "Secure",
+};
+
+int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
+				  bool vlan_filtering)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 old, new = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
+		PORT_CONTROL_2_8021Q_DISABLED;
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+
+	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL_2);
+	if (ret < 0)
+		goto unlock;
+
+	old = ret & PORT_CONTROL_2_8021Q_MASK;
+
+	ret &= ~PORT_CONTROL_2_8021Q_MASK;
+	ret |= new & PORT_CONTROL_2_8021Q_MASK;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2, ret);
+	if (ret < 0)
+		goto unlock;
+
+	netdev_dbg(ds->ports[port], "802.1Q Mode: %s (was %s)\n",
+		   mv88e6xxx_port_8021q_mode_names[new],
+		   mv88e6xxx_port_8021q_mode_names[old]);
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 85a4166..d7b088d 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -490,6 +490,8 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge);
 int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
+int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
+				  bool vlan_filtering);
 int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans);
-- 
2.7.1
