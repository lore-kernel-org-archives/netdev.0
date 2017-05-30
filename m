From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 3/3] net-next: dsa: mt7530: add multi cpu port support
Date: Tue, 30 May 2017 12:44:19 +0200
Message-ID: <20170530104419.6052-3-john@phrozen.org>
References: <20170530104419.6052-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:50253 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750867AbdE3Kov (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 06:44:51 -0400
In-Reply-To: <20170530104419.6052-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MT7530 switches have 2 CPU ports. Inside an MT7623a these are connected
to GMAC1 and GMAC2. The code currently has the CPU hard coded to 6. Change
this to using the new dsa_port_upstream_port() api. In case port 5 is not
setup as a cpu port, we configure the RGMII passthrough mode allowing GMAC2
to connect to an external PHY.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/dsa/mt7530.c | 45 +++++++++++++++++++++++++++++----------------
 drivers/net/dsa/mt7530.h |  1 -
 2 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 4d2f45153ede..370e0833474b 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -632,6 +632,9 @@ static int
 mt7530_cpu_port_enable(struct mt7530_priv *priv,
 		       int port)
 {
+	u8 port_mask = 0;
+	int i;
+
 	/* Enable Mediatek header mode on the cpu port */
 	mt7530_write(priv, MT7530_PVC_P(port),
 		     PORT_SPEC_TAG);
@@ -648,8 +651,12 @@ mt7530_cpu_port_enable(struct mt7530_priv *priv,
 	/* CPU port gets connected to all user ports of
 	 * the switch
 	 */
+	for (i = 0; i < MT7530_NUM_PORTS; i++)
+		if ((priv->ds->enabled_port_mask & BIT(i)) &&
+		    (dsa_port_upstream_port(priv->ds, i) == port))
+			port_mask |= BIT(i);
 	mt7530_write(priv, MT7530_PCR_P(port),
-		     PCR_MATRIX(priv->ds->enabled_port_mask));
+		     PCR_MATRIX(port_mask));
 
 	return 0;
 }
@@ -659,6 +666,7 @@ mt7530_port_enable(struct dsa_switch *ds, int port,
 		   struct phy_device *phy)
 {
 	struct mt7530_priv *priv = ds->priv;
+	u8 upstream = dsa_port_upstream_port(ds, port);
 
 	mutex_lock(&priv->reg_mutex);
 
@@ -669,7 +677,7 @@ mt7530_port_enable(struct dsa_switch *ds, int port,
 	 * restore the port matrix if the port is the member of a certain
 	 * bridge.
 	 */
-	priv->ports[port].pm |= PCR_MATRIX(BIT(MT7530_CPU_PORT));
+	priv->ports[port].pm |= PCR_MATRIX(BIT(upstream));
 	priv->ports[port].enable = true;
 	mt7530_rmw(priv, MT7530_PCR_P(port), PCR_MATRIX_MASK,
 		   priv->ports[port].pm);
@@ -732,7 +740,8 @@ mt7530_port_bridge_join(struct dsa_switch *ds, int port,
 			struct net_device *bridge)
 {
 	struct mt7530_priv *priv = ds->priv;
-	u32 port_bitmap = BIT(MT7530_CPU_PORT);
+	u8 upstream = dsa_port_upstream_port(ds, port);
+	u32 port_bitmap = BIT(upstream);
 	int i;
 
 	mutex_lock(&priv->reg_mutex);
@@ -770,6 +779,7 @@ mt7530_port_bridge_leave(struct dsa_switch *ds, int port,
 			 struct net_device *bridge)
 {
 	struct mt7530_priv *priv = ds->priv;
+	u8 upstream = dsa_port_upstream_port(ds, port);
 	int i;
 
 	mutex_lock(&priv->reg_mutex);
@@ -794,8 +804,8 @@ mt7530_port_bridge_leave(struct dsa_switch *ds, int port,
 	 */
 	if (priv->ports[port].enable)
 		mt7530_rmw(priv, MT7530_PCR_P(port), PCR_MATRIX_MASK,
-			   PCR_MATRIX(BIT(MT7530_CPU_PORT)));
-	priv->ports[port].pm = PCR_MATRIX(BIT(MT7530_CPU_PORT));
+			   PCR_MATRIX(BIT(upstream)));
+	priv->ports[port].pm = PCR_MATRIX(BIT(upstream));
 
 	mutex_unlock(&priv->reg_mutex);
 }
@@ -892,15 +902,7 @@ mt7530_port_fdb_dump(struct dsa_switch *ds, int port,
 static enum dsa_tag_protocol
 mtk_get_tag_protocol(struct dsa_switch *ds)
 {
-	struct mt7530_priv *priv = ds->priv;
-
-	if (!dsa_is_cpu_port(ds, MT7530_CPU_PORT)) {
-		dev_warn(priv->dev,
-			 "port not matched with tagging CPU port\n");
-		return DSA_TAG_PROTO_NONE;
-	} else {
-		return DSA_TAG_PROTO_MTK;
-	}
+	return DSA_TAG_PROTO_MTK;
 }
 
 static int
@@ -971,10 +973,21 @@ mt7530_setup(struct dsa_switch *ds)
 		     SYS_CTRL_PHY_RST | SYS_CTRL_SW_RST |
 		     SYS_CTRL_REG_RST);
 
-	/* Enable Port 6 only; P5 as GMAC5 which currently is not supported */
+	/* Enable Port 6. Port 5 is setup in passthrough mode if it is not a CPU
+	 * port
+	 */
 	val = mt7530_read(priv, MT7530_MHWTRAP);
-	val &= ~MHWTRAP_P6_DIS & ~MHWTRAP_PHY_ACCESS;
+	val &= ~MHWTRAP_P5_DIS & ~MHWTRAP_P6_DIS & ~MHWTRAP_PHY_ACCESS;
 	val |= MHWTRAP_MANUAL;
+	if (!dsa_is_cpu_port(ds, 5)) {
+		val |= MHWTRAP_P5_DIS;
+		val |= MHWTRAP_P5_MAC_SEL;
+		val |= MHWTRAP_P5_RGMII_MODE;
+	} else if (0) {
+		val &= ~MHWTRAP_P5_DIS;
+		val &= ~MHWTRAP_P5_MAC_SEL;
+		val &= ~MHWTRAP_P5_RGMII_MODE;
+	}
 	mt7530_write(priv, MT7530_MHWTRAP, val);
 
 	/* Enable and reset MIB counters */
diff --git a/drivers/net/dsa/mt7530.h b/drivers/net/dsa/mt7530.h
index b83d76b99802..728e0c3a8883 100644
--- a/drivers/net/dsa/mt7530.h
+++ b/drivers/net/dsa/mt7530.h
@@ -15,7 +15,6 @@
 #define __MT7530_H
 
 #define MT7530_NUM_PORTS		7
-#define MT7530_CPU_PORT			6
 #define MT7530_NUM_FDB_RECORDS		2048
 
 #define	NUM_TRGMII_CTRL			5
-- 
2.11.0
