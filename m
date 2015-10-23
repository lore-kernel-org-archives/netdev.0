From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: Unhardcode port numbers
Date: Fri, 23 Oct 2015 12:11:08 -0700
Message-ID: <1445627468-16084-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35858 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbbJWTLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 15:11:44 -0400
Received: by pacfv9 with SMTP id fv9so131334396pac.3
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 12:11:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the current driver mostly supports BCM7445 which has a hardcoded
location for its MoCA port on port 7 and port 0 for its internal PHY,
this is not necessarily true for all other chips out there such as
BCM3390 for instance.

Walk the list of ports from Device Tree, get their port number ("reg"
property), and then parse the "phy-mode" property and initialize two
internal variables: moca_port and a bitmask of internal PHYs. Since we
use interrupts for the MoCA port, we introduce two helper functions to
enable/disable interrupts and do this at the appropriate bank (INTRL2_0
or INTRL2_1).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 102 +++++++++++++++++++++++++++++++++++++++++-----
 drivers/net/dsa/bcm_sf2.h |   6 +++
 2 files changed, 97 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 9d56515f4c4d..0a284e204644 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -21,6 +21,7 @@
 #include <linux/of.h>
 #include <linux/of_irq.h>
 #include <linux/of_address.h>
+#include <linux/of_net.h>
 #include <net/dsa.h>
 #include <linux/ethtool.h>
 #include <linux/if_bridge.h>
@@ -264,6 +265,50 @@ static void bcm_sf2_gphy_enable_set(struct dsa_switch *ds, bool enable)
 	}
 }
 
+static inline void bcm_sf2_port_intr_enable(struct bcm_sf2_priv *priv,
+					    int port)
+{
+	unsigned int off;
+
+	switch (port) {
+	case 7:
+		off = P7_IRQ_OFF;
+		break;
+	case 0:
+		/* Port 0 interrupts are located on the first bank */
+		intrl2_0_mask_clear(priv, P_IRQ_MASK(P0_IRQ_OFF));
+		return;
+	default:
+		off = P_IRQ_OFF(port);
+		break;
+	}
+
+	intrl2_1_mask_clear(priv, P_IRQ_MASK(off));
+}
+
+static inline void bcm_sf2_port_intr_disable(struct bcm_sf2_priv *priv,
+					     int port)
+{
+	unsigned int off;
+
+	switch (port) {
+	case 7:
+		off = P7_IRQ_OFF;
+		break;
+	case 0:
+		/* Port 0 interrupts are located on the first bank */
+		intrl2_0_mask_set(priv, P_IRQ_MASK(P0_IRQ_OFF));
+		intrl2_0_writel(priv, P_IRQ_MASK(P0_IRQ_OFF), INTRL2_CPU_CLEAR);
+		return;
+	default:
+		off = P_IRQ_OFF(port);
+		break;
+	}
+
+	intrl2_1_mask_set(priv, P_IRQ_MASK(off));
+	intrl2_1_writel(priv, P_IRQ_MASK(off), INTRL2_CPU_CLEAR);
+}
+
 static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
@@ -280,7 +325,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	core_writel(priv, 0, CORE_G_PCTL_PORT(port));
 
 	/* Re-enable the GPHY and re-apply workarounds */
-	if (port == 0 && priv->hw_params.num_gphy == 1) {
+	if (priv->int_phy_mask & 1 << port && priv->hw_params.num_gphy == 1) {
 		bcm_sf2_gphy_enable_set(ds, true);
 		if (phy) {
 			/* if phy_stop() has been called before, phy
@@ -297,9 +342,9 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 		}
 	}
 
-	/* Enable port 7 interrupts to get notified */
-	if (port == 7)
-		intrl2_1_mask_clear(priv, P_IRQ_MASK(P7_IRQ_OFF));
+	/* Enable MoCA port interrupts to get notified */
+	if (port == priv->moca_port)
+		bcm_sf2_port_intr_enable(priv, port);
 
 	/* Set this port, and only this one to be in the default VLAN,
 	 * if member of a bridge, restore its membership prior to
@@ -329,12 +374,10 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 	if (priv->wol_ports_mask & (1 << port))
 		return;
 
-	if (port == 7) {
-		intrl2_1_mask_set(priv, P_IRQ_MASK(P7_IRQ_OFF));
-		intrl2_1_writel(priv, P_IRQ_MASK(P7_IRQ_OFF), INTRL2_CPU_CLEAR);
-	}
+	if (port == priv->moca_port)
+		bcm_sf2_port_intr_disable(priv, port);
 
-	if (port == 0 && priv->hw_params.num_gphy == 1)
+	if (priv->int_phy_mask & 1 << port && priv->hw_params.num_gphy == 1)
 		bcm_sf2_gphy_enable_set(ds, false);
 
 	if (dsa_is_cpu_port(ds, port))
@@ -615,6 +658,42 @@ static void bcm_sf2_intr_disable(struct bcm_sf2_priv *priv)
 	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
 }
 
+static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
+				   struct device_node *dn)
+{
+	struct device_node *port;
+	const char *phy_mode_str;
+	int mode;
+	unsigned int port_num;
+	int ret;
+
+	priv->moca_port = -1;
+
+	for_each_available_child_of_node(dn, port) {
+		if (of_property_read_u32(port, "reg", &port_num))
+			continue;
+
+		/* Internal PHYs get assigned a specific 'phy-mode' property
+		 * value: "internal" to help flag them before MDIO probing
+		 * has completed, since they might be turned off at that
+		 * time
+		 */
+		mode = of_get_phy_mode(port);
+		if (mode < 0) {
+			ret = of_property_read_string(port, "phy-mode",
+						      &phy_mode_str);
+			if (ret < 0)
+				continue;
+
+			if (!strcasecmp(phy_mode_str, "internal"))
+				priv->int_phy_mask |= 1 << port_num;
+		}
+
+		if (mode == PHY_INTERFACE_MODE_MOCA)
+			priv->moca_port = port_num;
+	}
+}
+
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
@@ -633,6 +712,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	 * level
 	 */
 	dn = ds->pd->of_node->parent;
+	bcm_sf2_identify_ports(priv, ds->pd->of_node);
 
 	priv->irq0 = irq_of_parse_and_map(dn, 0);
 	priv->irq1 = irq_of_parse_and_map(dn, 1);
@@ -913,7 +993,7 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 
 	status->link = 0;
 
-	/* Port 7 is special as we do not get link status from CORE_LNKSTS,
+	/* MoCA port is special as we do not get link status from CORE_LNKSTS,
 	 * which means that we need to force the link at the port override
 	 * level to get the data to flow. We do use what the interrupt handler
 	 * did determine before.
@@ -921,7 +1001,7 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 	 * For the other ports, we just force the link status, since this is
 	 * a fixed PHY device.
 	 */
-	if (port == 7) {
+	if (port == priv->moca_port) {
 		status->link = priv->port_sts[port].link;
 		/* For MoCA interfaces, also force a link down notification
 		 * since some version of the user-space daemon (mocad) use
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 789d7b7737da..49289988aebe 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -78,6 +78,12 @@ struct bcm_sf2_priv {
 
 	/* Mask of ports enabled for Wake-on-LAN */
 	u32				wol_ports_mask;
+
+	/* MoCA port location */
+	int				moca_port;
+
+	/* Bitmask of ports having an integrated PHY */
+	unsigned int			int_phy_mask;
 };
 
 struct bcm_sf2_hw_stats {
-- 
2.1.0
