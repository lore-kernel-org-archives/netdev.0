From: John Crispin <john@phrozen.org>
Subject: [RFC 4/4] net-next: dsa: qca8k: add support for multiple cpu ports
Date: Wed,  4 Jan 2017 08:38:04 +0100
Message-ID: <1483515484-21793-5-git-send-email-john@phrozen.org>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60156 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934328AbdADHiR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 02:38:17 -0500
In-Reply-To: <1483515484-21793-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the subsystem now supporting multiple cpu ports, we need to make some
changes to the driver as it currently has the cpu port hardcoded as port0.
The patch moves the setup logic for the cpu port into one loop which
iterates over all cpu ports and sets them up. Additionally the bridge
join/leave logic needs a small fix to work with having a cpu port other
than 0.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/dsa/qca8k.c |  135 +++++++++++++++++++++++++++--------------------
 drivers/net/dsa/qca8k.h |    2 -
 2 files changed, 78 insertions(+), 59 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index b3df70d..1693388 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -486,11 +486,25 @@
 		qca8k_reg_clear(priv, QCA8K_REG_PORT_STATUS(port), mask);
 }
 
+static void
+qca8k_setup_flooding(struct qca8k_priv *priv, int port_mask, int enable)
+{
+	u32 mask = (port_mask << QCA8K_GLOBAL_FW_CTRL1_IGMP_DP_S) |
+		   (port_mask << QCA8K_GLOBAL_FW_CTRL1_BC_DP_S) |
+		   (port_mask << QCA8K_GLOBAL_FW_CTRL1_MC_DP_S) |
+		   (port_mask << QCA8K_GLOBAL_FW_CTRL1_UC_DP_S);
+
+	if (enable)
+		qca8k_reg_set(priv, QCA8K_REG_GLOBAL_FW_CTRL1, mask);
+	else
+		qca8k_reg_clear(priv, QCA8K_REG_GLOBAL_FW_CTRL1, mask);
+}
+
 static int
 qca8k_setup(struct dsa_switch *ds)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
-	int ret, i, phy_mode = -1;
+	int ret, i;
 
 	/* Make sure that port 0 is the cpu port */
 	if (!dsa_is_cpu_port(ds, 0)) {
@@ -506,29 +520,49 @@
 	if (IS_ERR(priv->regmap))
 		pr_warn("regmap initialization failed");
 
-	/* Initialize CPU port pad mode (xMII type, delays...) */
-	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
-	if (phy_mode < 0) {
-		pr_err("Can't find phy-mode for master device\n");
-		return phy_mode;
-	}
-	ret = qca8k_set_pad_ctrl(priv, QCA8K_CPU_PORT, phy_mode);
-	if (ret < 0)
-		return ret;
-
-	/* Enable CPU Port */
+	/* Tell the switch that port0 is a cpu port */
 	qca8k_reg_set(priv, QCA8K_REG_GLOBAL_FW_CTRL0,
 		      QCA8K_GLOBAL_FW_CTRL0_CPU_PORT_EN);
-	qca8k_port_set_status(priv, QCA8K_CPU_PORT, 1);
-	priv->port_sts[QCA8K_CPU_PORT].enabled = 1;
 
 	/* Enable MIB counters */
 	qca8k_mib_init(priv);
 
-	/* Enable QCA header mode on the cpu port */
-	qca8k_write(priv, QCA8K_REG_PORT_HDR_CTRL(QCA8K_CPU_PORT),
-		    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_TX_S |
-		    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_RX_S);
+	/* Setup the cpu ports */
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		struct net_device *netdev;
+		int phy_mode = -1;
+
+		if (!dsa_is_cpu_port(ds, i))
+			continue;
+
+		netdev = ds->dst->pd->chip->port_ethernet[i];
+		if (!netdev) {
+			pr_err("Can't find netdev for port%d\n", i);
+			return -ENODEV;
+		}
+
+		/* Initialize CPU port pad mode (xMII type, delays...) */
+		phy_mode = of_get_phy_mode(netdev->dev.parent->of_node);
+		if (phy_mode < 0) {
+			pr_err("Can't find phy-mode for port:%d\n", i);
+			return phy_mode;
+		}
+		ret = qca8k_set_pad_ctrl(priv, i, phy_mode);
+		if (ret < 0)
+			return ret;
+
+		/* Enable QCA header mode on the cpu port */
+		qca8k_write(priv,
+			    QCA8K_REG_PORT_HDR_CTRL(i),
+			    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_TX_S |
+			    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_RX_S);
+
+		qca8k_port_set_status(priv, i, 1);
+		priv->port_sts[i].enabled = 1;
+
+		/* Forward all unknown frames to CPU port for Linux processing */
+		qca8k_setup_flooding(priv, BIT(i), 1);
+	}
 
 	/* Disable forwarding by default on all ports */
 	for (i = 0; i < QCA8K_NUM_PORTS; i++)
@@ -540,43 +574,30 @@
 		if (ds->enabled_port_mask & BIT(i))
 			qca8k_port_set_status(priv, i, 0);
 
-	/* Forward all unknown frames to CPU port for Linux processing */
-	qca8k_write(priv, QCA8K_REG_GLOBAL_FW_CTRL1,
-		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_IGMP_DP_S |
-		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_BC_DP_S |
-		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_MC_DP_S |
-		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_UC_DP_S);
-
-	/* Setup connection between CPU port & user ports */
+	/* Setup user ports and connections to CPU ports */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		/* CPU port gets connected to all user ports of the switch */
-		if (dsa_is_cpu_port(ds, i)) {
-			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(QCA8K_CPU_PORT),
-				  QCA8K_PORT_LOOKUP_MEMBER,
-				  ds->enabled_port_mask);
-		}
+		int shift = 16 * (i % 2);
+		int cpu_port;
 
-		/* Invividual user ports get connected to CPU port only */
-		if (ds->enabled_port_mask & BIT(i)) {
-			int shift = 16 * (i % 2);
-
-			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(i),
-				  QCA8K_PORT_LOOKUP_MEMBER,
-				  BIT(QCA8K_CPU_PORT));
-
-			/* Enable ARP Auto-learning by default */
-			qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(i),
-				      QCA8K_PORT_LOOKUP_LEARN);
-
-			/* For port based vlans to work we need to set the
-			 * default egress vid
-			 */
-			qca8k_rmw(priv, QCA8K_EGRESS_VLAN(i),
-				  0xffff << shift, 1 << shift);
-			qca8k_write(priv, QCA8K_REG_PORT_VLAN_CTRL0(i),
-				    QCA8K_PORT_VLAN_CVID(1) |
-				    QCA8K_PORT_VLAN_SVID(1));
-		}
+		if (!(ds->enabled_port_mask & BIT(i)))
+			continue;
+
+		cpu_port = dsa_port_upstream_port(ds, i);
+		qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(i), BIT(cpu_port));
+		qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(cpu_port), BIT(i));
+
+		/* Enable ARP Auto-learning by default */
+		qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(i),
+			      QCA8K_PORT_LOOKUP_LEARN);
+
+		/* For port based vlans to work we need to set the
+		 * default egress vid
+		 */
+		qca8k_rmw(priv, QCA8K_EGRESS_VLAN(i),
+			  0xffff << shift, 1 << shift);
+		qca8k_write(priv, QCA8K_REG_PORT_VLAN_CTRL0(i),
+			    QCA8K_PORT_VLAN_CVID(1) |
+			    QCA8K_PORT_VLAN_SVID(1));
 	}
 
 	/* Flush the FDB table */
@@ -750,7 +771,7 @@
 		       struct net_device *bridge)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
-	int port_mask = BIT(QCA8K_CPU_PORT);
+	int port_mask = 0;
 	int i;
 
 	priv->port_sts[port].bridge_dev = bridge;
@@ -768,8 +789,7 @@
 			port_mask |= BIT(i);
 	}
 	/* Add all other ports to this ports portvlan mask */
-	qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(port),
-		  QCA8K_PORT_LOOKUP_MEMBER, port_mask);
+	qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(port), port_mask);
 
 	return 0;
 }
@@ -796,7 +816,8 @@
 	 * this port
 	 */
 	qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(port),
-		  QCA8K_PORT_LOOKUP_MEMBER, BIT(QCA8K_CPU_PORT));
+		  QCA8K_PORT_LOOKUP_MEMBER,
+		  BIT(dsa_port_upstream_port(ds, i)));
 }
 
 static int
diff --git a/drivers/net/dsa/qca8k.h b/drivers/net/dsa/qca8k.h
index 2014647..aca6abb 100644
--- a/drivers/net/dsa/qca8k.h
+++ b/drivers/net/dsa/qca8k.h
@@ -26,8 +26,6 @@
 
 #define QCA8K_NUM_FDB_RECORDS				2048
 
-#define QCA8K_CPU_PORT					0
-
 /* Global control registers */
 #define QCA8K_REG_MASK_CTRL				0x000
 #define   QCA8K_MASK_CTRL_ID_M				0xff
-- 
1.7.10.4
