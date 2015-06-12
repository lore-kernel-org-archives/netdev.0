From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/3] dsa: mv88e6xxx: Allow speed/duplex of port to be configured
Date: Fri, 12 Jun 2015 19:18:56 +0200
Message-ID: <1434129537-15252-2-git-send-email-andrew@lunn.ch>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55367 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698AbbFLRYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2015 13:24:42 -0400
In-Reply-To: <1434129537-15252-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code sets user ports to perform auto negotiation using the
phy. CPU and DSA ports are configured to full duplex and maximum speed
the switch supports.

There are however use cases where the CPU has a slower port, and when
user ports have SFP modules with fixed speed. In these cases, allow
port settings to be read from a fixed_phy devices.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123_61_65.c |  1 +
 drivers/net/dsa/mv88e6131.c       |  1 +
 drivers/net/dsa/mv88e6171.c       |  1 +
 drivers/net/dsa/mv88e6352.c       |  1 +
 drivers/net/dsa/mv88e6xxx.c       | 56 +++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  2 ++
 net/dsa/slave.c                   |  4 ++-
 7 files changed, 65 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 71a29a7ce538..3de2a6d73fdc 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -129,6 +129,7 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.adjust_link		= mv88e6xxx_adjust_link,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6xxx_get_temp,
 #endif
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 32f4a08e9bc9..3e8386529965 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -182,6 +182,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.adjust_link		= mv88e6xxx_adjust_link,
 };
 
 MODULE_ALIAS("platform:mv88e6085");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 1c7808495a9d..8803e20ebc52 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -108,6 +108,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.adjust_link		= mv88e6xxx_adjust_link,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
 #endif
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 632815c10a40..7a2deddbe270 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -374,6 +374,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.adjust_link		= mv88e6xxx_adjust_link,
 	.set_eee		= mv88e6xxx_set_eee,
 	.get_eee		= mv88e6xxx_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7fba330ce702..3defccb59d42 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -10,6 +10,7 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/if_bridge.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
@@ -543,6 +544,61 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 	return false;
 }
 
+/* We expect the switch to perform auto negotiation if there is a real
+ * phy. However, in the case of a fixed link phy, we force the port
+ * settings from the fixed link settings.
+ */
+void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
+			   struct phy_device *phydev)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u32 ret, reg;
+
+	if (!phy_is_pseudo_fixed_link(phydev))
+		return;
+
+	mutex_lock(&ps->smi_mutex);
+
+	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
+	if (ret < 0)
+		goto out;
+
+	reg = ret & ~(PORT_PCS_CTRL_LINK_UP |
+		      PORT_PCS_CTRL_FORCE_LINK |
+		      PORT_PCS_CTRL_DUPLEX_FULL |
+		      PORT_PCS_CTRL_FORCE_DUPLEX |
+		      PORT_PCS_CTRL_UNFORCED);
+
+	reg |= PORT_PCS_CTRL_FORCE_LINK;
+	if (phydev->link)
+			reg |= PORT_PCS_CTRL_LINK_UP;
+
+	if (mv88e6xxx_6065_family(ds) && phydev->speed > SPEED_100)
+		goto out;
+
+	switch (phydev->speed) {
+	case SPEED_1000:
+		reg |= PORT_PCS_CTRL_1000;
+		break;
+	case SPEED_100:
+		reg |= PORT_PCS_CTRL_100;
+		break;
+	case SPEED_10:
+		reg |= PORT_PCS_CTRL_10;
+	default:
+		goto out;
+	}
+
+	reg |= PORT_PCS_CTRL_FORCE_DUPLEX;
+	if (phydev->duplex == DUPLEX_FULL)
+		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
+
+	_mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_PCS_CTRL, reg);
+
+out:
+	mutex_unlock(&ps->smi_mutex);
+}
+
 /* Must be called with SMI mutex held */
 static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e10ccdb4ffbc..5273ecb700ed 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -373,6 +373,8 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 				 uint64_t *data);
 int mv88e6xxx_get_sset_count(struct dsa_switch *ds);
 int mv88e6xxx_get_sset_count_basic(struct dsa_switch *ds);
+void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
+			   struct phy_device *phydev);
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 04ffad311704..c32e4050b9bd 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -816,8 +816,10 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		}
 	}
 
-	if (p->phy && phy_is_fixed)
+	if (p->phy && phy_is_fixed) {
 		fixed_phy_set_link_update(p->phy, dsa_slave_fixed_link_update);
+		p->phy->is_pseudo_fixed_link = true;
+	}
 
 	/* We could not connect to a designated PHY, so use the switch internal
 	 * MDIO bus instead
-- 
2.1.4
