From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/6] net: dsa: bcm_sf2: add port_enable/disable callbacks
Date: Wed, 24 Sep 2014 17:05:20 -0700
Message-ID: <1411603522-8384-5-git-send-email-f.fainelli@gmail.com>
References: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:43282 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaIYAGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:06:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so1251751pad.14
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:06:03 -0700 (PDT)
In-Reply-To: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SF2 switch driver is already architected around per-port
enable/disable callbacks, so we just need a slight update to our
existing bcm_sf2_port_setup() resp. bcm_sf2_port_disable() functions to
be suitable as callbacks for port_enable/port_disable.

We need to shuffle a little the code that does the per-port VLAN
configuration/isolation since ports can now be brought up/down
separately, so we need to make sure that IMP (CPU, management) port is
always included in that specific port setup.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 60 +++++++++++++++++++++++++++++++----------------
 1 file changed, 40 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 58b8fef25b96..634e44ee8d0d 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -135,10 +135,29 @@ static char *bcm_sf2_sw_probe(struct device *host_dev, int sw_addr)
 	return "Broadcom Starfighter 2";
 }
 
-static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
+static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	unsigned int i;
+	u32 reg;
+
+	/* Enable the IMP Port to be in the same VLAN as the other ports
+	 * on a per-port basis such that we only have Port i and IMP in
+	 * the same VLAN.
+	 */
+	for (i = 0; i < priv->hw_params.num_ports; i++) {
+		if (!((1 << i) & ds->phys_port_mask))
+			continue;
+
+		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
+		reg |= (1 << cpu_port);
+		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
+	}
+}
+
+static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	u32 reg, val;
 
 	/* Enable the port memories */
@@ -199,24 +218,13 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 	reg = core_readl(priv, CORE_STS_OVERRIDE_IMP);
 	reg |= (MII_SW_OR | LINK_STS);
 	core_writel(priv, reg, CORE_STS_OVERRIDE_IMP);
-
-	/* Enable the IMP Port to be in the same VLAN as the other ports
-	 * on a per-port basis such that we only have Port i and IMP in
-	 * the same VLAN.
-	 */
-	for (i = 0; i < priv->hw_params.num_ports; i++) {
-		if (!((1 << i) & ds->phys_port_mask))
-			continue;
-
-		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
-		reg |= (1 << port);
-		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
-	}
 }
 
-static void bcm_sf2_port_setup(struct dsa_switch *ds, int port)
+static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
+			      struct phy_device *phy)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	s8 cpu_port = ds->dst[ds->index].cpu_port;
 	u32 reg;
 
 	/* Clear the memory power down */
@@ -236,9 +244,14 @@ static void bcm_sf2_port_setup(struct dsa_switch *ds, int port)
 	reg &= ~PORT_VLAN_CTRL_MASK;
 	reg |= (1 << port);
 	core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(port));
+
+	bcm_sf2_imp_vlan_setup(ds, cpu_port);
+
+	return 0;
 }
 
-static void bcm_sf2_port_disable(struct dsa_switch *ds, int port)
+static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
+				 struct phy_device *phy)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	u32 off, reg;
@@ -246,6 +259,11 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port)
 	if (priv->wol_ports_mask & (1 << port))
 		return;
 
+	if (port == 7) {
+		intrl2_1_mask_set(priv, P_IRQ_MASK(P7_IRQ_OFF));
+		intrl2_1_writel(priv, P_IRQ_MASK(P7_IRQ_OFF), INTRL2_CPU_CLEAR);
+	}
+
 	if (dsa_is_cpu_port(ds, port))
 		off = CORE_IMP_CTL;
 	else
@@ -363,11 +381,11 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
 		/* IMP port receives special treatment */
 		if ((1 << port) & ds->phys_port_mask)
-			bcm_sf2_port_setup(ds, port);
+			bcm_sf2_port_setup(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
 		else
-			bcm_sf2_port_disable(ds, port);
+			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
 	/* Include the pseudo-PHY address and the broadcast PHY address to
@@ -638,7 +656,7 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if ((1 << port) & ds->phys_port_mask ||
 		    dsa_is_cpu_port(ds, port))
-			bcm_sf2_port_disable(ds, port);
+			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
 	return 0;
@@ -694,7 +712,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if ((1 << port) & ds->phys_port_mask)
-			bcm_sf2_port_setup(ds, port);
+			bcm_sf2_port_setup(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
 	}
@@ -772,6 +790,8 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.resume			= bcm_sf2_sw_resume,
 	.get_wol		= bcm_sf2_sw_get_wol,
 	.set_wol		= bcm_sf2_sw_set_wol,
+	.port_enable		= bcm_sf2_port_setup,
+	.port_disable		= bcm_sf2_port_disable,
 };
 
 static int __init bcm_sf2_init(void)
-- 
1.9.1
