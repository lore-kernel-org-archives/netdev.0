From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: b53: Export b53_configure_vlan()
Date: Fri, 27 Oct 2017 15:56:01 -0700
Message-ID: <20171027225601.32194-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:46398 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ0W4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 18:56:06 -0400
Received: by mail-qk0-f193.google.com with SMTP id k123so10169976qke.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 15:56:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm_sf2 and b53 replicate the same operations: clear all VLANs and set
their ports to the default VLAN tag (1 for these devices) so export the
b53 function doing just that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c |  6 ++++--
 drivers/net/dsa/b53/b53_priv.h   |  1 +
 drivers/net/dsa/bcm_sf2.c        | 41 +---------------------------------------
 3 files changed, 6 insertions(+), 42 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index c74a50112551..fa37f501f10b 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -613,8 +613,9 @@ static void b53_enable_mib(struct b53_device *dev)
 	b53_write8(dev, B53_MGMT_PAGE, B53_GLOBAL_CONFIG, gc);
 }
 
-static int b53_configure_vlan(struct b53_device *dev)
+int b53_configure_vlan(struct dsa_switch *ds)
 {
+	struct b53_device *dev = ds->priv;
 	struct b53_vlan vl = { 0 };
 	int i;
 
@@ -637,6 +638,7 @@ static int b53_configure_vlan(struct b53_device *dev)
 
 	return 0;
 }
+EXPORT_SYMBOL(b53_configure_vlan);
 
 static void b53_switch_reset_gpio(struct b53_device *dev)
 {
@@ -751,7 +753,7 @@ static int b53_apply_config(struct b53_device *priv)
 	/* disable switching */
 	b53_set_forwarding(priv, 0);
 
-	b53_configure_vlan(priv);
+	b53_configure_vlan(priv->ds);
 
 	/* enable switching */
 	b53_set_forwarding(priv, 1);
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 603c66d240d8..daaaa1ecb996 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -285,6 +285,7 @@ static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
 
 /* Exported functions towards other drivers */
 void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port);
+int b53_configure_vlan(struct dsa_switch *ds);
 void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
 void b53_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data);
 int b53_get_sset_count(struct dsa_switch *ds);
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 7f47400e557e..2d6867f4008c 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -738,45 +738,6 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 	return p->ethtool_ops->set_wol(p, wol);
 }
 
-static int bcm_sf2_vlan_op_wait(struct bcm_sf2_priv *priv)
-{
-	unsigned int timeout = 10;
-	u32 reg;
-
-	do {
-		reg = core_readl(priv, CORE_ARLA_VTBL_RWCTRL);
-		if (!(reg & ARLA_VTBL_STDN))
-			return 0;
-
-		usleep_range(1000, 2000);
-	} while (timeout--);
-
-	return -ETIMEDOUT;
-}
-
-static int bcm_sf2_vlan_op(struct bcm_sf2_priv *priv, u8 op)
-{
-	core_writel(priv, ARLA_VTBL_STDN | op, CORE_ARLA_VTBL_RWCTRL);
-
-	return bcm_sf2_vlan_op_wait(priv);
-}
-
-static void bcm_sf2_sw_configure_vlan(struct dsa_switch *ds)
-{
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	unsigned int port;
-
-	/* Clear all VLANs */
-	bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_CLEAR);
-
-	for (port = 0; port < priv->hw_params.num_ports; port++) {
-		if (!dsa_is_user_port(ds, port))
-			continue;
-
-		core_writel(priv, 1, CORE_DEFAULT_1Q_TAG_P(port));
-	}
-}
-
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
@@ -793,7 +754,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
-	bcm_sf2_sw_configure_vlan(ds);
+	b53_configure_vlan(ds);
 	bcm_sf2_enable_acb(ds);
 
 	return 0;
-- 
2.9.3
