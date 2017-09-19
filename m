From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 12/12] net: dsa: bcm_sf2: Utilize b53_{enable,disable}_port
Date: Mon, 18 Sep 2017 19:19:47 -0700
Message-ID: <20170919021947.8971-13-f.fainelli@gmail.com>
References: <20170919021947.8971-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34810 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdISC2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 22:28:04 -0400
Received: by mail-wm0-f67.google.com with SMTP id i131so2509701wma.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 19:28:03 -0700 (PDT)
In-Reply-To: <20170919021947.8971-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export b53_{enable,disable}_port and use these two functions in
bcm_sf2_port_setup and bcm_sf2_port_disable. The generic functions
cannot be used without wrapping because we need to manage additional
switch integration details (PHY, Broadcom tag etc.).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c |  8 ++++----
 drivers/net/dsa/b53/b53_priv.h   |  2 ++
 drivers/net/dsa/bcm_sf2.c        | 26 ++------------------------
 3 files changed, 8 insertions(+), 28 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index c3f1cd2c33ea..a9f2a5b55a5e 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -502,8 +502,7 @@ void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 }
 EXPORT_SYMBOL(b53_imp_vlan_setup);
 
-static int b53_enable_port(struct dsa_switch *ds, int port,
-			   struct phy_device *phy)
+int b53_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
 {
 	struct b53_device *dev = ds->priv;
 	unsigned int cpu_port = dev->cpu_port;
@@ -530,9 +529,9 @@ static int b53_enable_port(struct dsa_switch *ds, int port,
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_enable_port);
 
-static void b53_disable_port(struct dsa_switch *ds, int port,
-			     struct phy_device *phy)
+void b53_disable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
 {
 	struct b53_device *dev = ds->priv;
 	u8 reg;
@@ -542,6 +541,7 @@ static void b53_disable_port(struct dsa_switch *ds, int port,
 	reg |= PORT_CTRL_RX_DISABLE | PORT_CTRL_TX_DISABLE;
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
 }
+EXPORT_SYMBOL(b53_disable_port);
 
 void b53_brcm_hdr_setup(struct dsa_switch *ds, int port)
 {
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index df8bea4105e4..8b5ba78edfd2 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -311,6 +311,8 @@ int b53_mirror_add(struct dsa_switch *ds, int port,
 		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress);
 void b53_mirror_del(struct dsa_switch *ds, int port,
 		    struct dsa_mall_mirror_tc_entry *mirror);
+int b53_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy);
+void b53_disable_port(struct dsa_switch *ds, int port, struct phy_device *phy);
 void b53_brcm_hdr_setup(struct dsa_switch *ds, int port);
 void b53_eee_enable_set(struct dsa_switch *ds, int port, bool enable);
 int b53_eee_init(struct dsa_switch *ds, int port, struct phy_device *phy);
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 08639674947a..0072a959db5b 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -163,7 +163,6 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	s8 cpu_port = ds->dst->cpu_dp->index;
 	unsigned int i;
 	u32 reg;
 
@@ -184,9 +183,6 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 		reg |= i << (PRT_TO_QID_SHIFT * i);
 	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
 
-	/* Clear the Rx and Tx disable bits and set to no spanning tree */
-	core_writel(priv, 0, CORE_G_PCTL_PORT(port));
-
 	/* Re-enable the GPHY and re-apply workarounds */
 	if (priv->int_phy_mask & 1 << port && priv->hw_params.num_gphy == 1) {
 		bcm_sf2_gphy_enable_set(ds, true);
@@ -209,23 +205,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	if (port == priv->moca_port)
 		bcm_sf2_port_intr_enable(priv, port);
 
-	/* Set this port, and only this one to be in the default VLAN,
-	 * if member of a bridge, restore its membership prior to
-	 * bringing down this port.
-	 */
-	reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
-	reg &= ~PORT_VLAN_CTRL_MASK;
-	reg |= (1 << port);
-	reg |= priv->dev->ports[port].vlan_ctl_mask;
-	core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(port));
-
-	b53_imp_vlan_setup(ds, cpu_port);
-
-	/* If EEE was enabled, restore it */
-	if (priv->dev->ports[port].eee.eee_enabled)
-		b53_eee_enable_set(ds, port, true);
-
-	return 0;
+	return b53_enable_port(ds, port, phy);
 }
 
 static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
@@ -248,9 +228,7 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 	else
 		off = CORE_G_PCTL_PORT(port);
 
-	reg = core_readl(priv, off);
-	reg |= RX_DIS | TX_DIS;
-	core_writel(priv, reg, off);
+	b53_disable_port(ds, port, phy);
 
 	/* Power down the port memory */
 	reg = core_readl(priv, CORE_MEM_PSM_VDD_CTRL);
-- 
2.9.3
