From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 10/12] net: dsa: b53: Export b53_imp_vlan_setup()
Date: Mon, 18 Sep 2017 14:41:26 -0700
Message-ID: <20170918214128.27896-11-f.fainelli@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37705 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbdIRVmI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:42:08 -0400
Received: by mail-wm0-f68.google.com with SMTP id f4so2121043wmh.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:42:08 -0700 (PDT)
In-Reply-To: <20170918214128.27896-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm_sf2 and b53 do exactly the same thing, so share that piece.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c |  3 ++-
 drivers/net/dsa/b53/b53_priv.h   |  1 +
 drivers/net/dsa/bcm_sf2.c        | 23 +----------------------
 3 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 3f0e6cf5422f..84068697a509 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -484,7 +484,7 @@ static int b53_fast_age_vlan(struct b53_device *dev, u16 vid)
 	return b53_flush_arl(dev, FAST_AGE_VLAN);
 }
 
-static void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
+void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
 	struct b53_device *dev = ds->priv;
 	unsigned int i;
@@ -500,6 +500,7 @@ static void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 		b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), pvlan);
 	}
 }
+EXPORT_SYMBOL(b53_imp_vlan_setup);
 
 static int b53_enable_port(struct dsa_switch *ds, int port,
 			   struct phy_device *phy)
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 0ed59672ef07..df8bea4105e4 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -284,6 +284,7 @@ static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
 #endif
 
 /* Exported functions towards other drivers */
+void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port);
 void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
 void b53_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data);
 int b53_get_sset_count(struct dsa_switch *ds);
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 4e8ef4c07eab..08639674947a 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -40,27 +40,6 @@ static enum dsa_tag_protocol bcm_sf2_sw_get_tag_protocol(struct dsa_switch *ds)
 	return DSA_TAG_PROTO_BRCM;
 }
 
-static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	unsigned int i;
-	u32 reg;
-
-	/* Enable the IMP Port to be in the same VLAN as the other ports
-	 * on a per-port basis such that we only have Port i and IMP in
-	 * the same VLAN.
-	 */
-	for (i = 0; i < priv->hw_params.num_ports; i++) {
-		if (!((1 << i) & ds->enabled_port_mask))
-			continue;
-
-		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
-		reg |= (1 << cpu_port);
-		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
-	}
-}
-
-
 static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
@@ -240,7 +219,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	reg |= priv->dev->ports[port].vlan_ctl_mask;
 	core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(port));
 
-	bcm_sf2_imp_vlan_setup(ds, cpu_port);
+	b53_imp_vlan_setup(ds, cpu_port);
 
 	/* If EEE was enabled, restore it */
 	if (priv->dev->ports[port].eee.eee_enabled)
-- 
2.9.3
