From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 08/20] net: dsa: bcm_sf2: use bridge device from dsa_port
Date: Wed, 27 Apr 2016 18:30:05 -0400
Message-ID: <1461796217-18893-9-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the DSA layer exposes the DSA port structures to drivers, use
that to retrieve the port bridge membership and thus get rid of the
private bridge_dev pointer.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c | 30 ++++++++++++++----------------
 drivers/net/dsa/bcm_sf2.h |  2 --
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index f7b53fa..6e3b844 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -495,25 +495,24 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, struct dsa_port *dp,
 			      struct net_device *bridge)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	unsigned int i;
+	struct dsa_port *intp;
 	u32 reg, p_ctl;
 
-	priv->port_sts[dp->port].bridge_dev = bridge;
 	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(dp->port));
 
-	for (i = 0; i < priv->hw_params.num_ports; i++) {
-		if (priv->port_sts[i].bridge_dev != bridge)
+	dsa_switch_for_each_port(ds, intp, priv->hw_params.num_ports) {
+		if (intp->br != bridge)
 			continue;
 
 		/* Add this local port to the remote port VLAN control
 		 * membership and update the remote port bitmask
 		 */
-		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
+		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(intp->port));
 		reg |= 1 << dp->port;
-		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
-		priv->port_sts[i].vlan_ctl_mask = reg;
+		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(intp->port));
+		priv->port_sts[intp->port].vlan_ctl_mask = reg;
 
-		p_ctl |= 1 << i;
+		p_ctl |= 1 << intp->port;
 	}
 
 	/* Configure the local port VLAN control membership to include
@@ -529,29 +528,28 @@ static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, struct dsa_port *dp,
 				struct net_device *bridge)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	unsigned int i;
+	struct dsa_port *intp;
 	u32 reg, p_ctl;
 
 	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(dp->port));
 
-	for (i = 0; i < priv->hw_params.num_ports; i++) {
+	dsa_switch_for_each_port(ds, intp, priv->hw_params.num_ports) {
 		/* Don't touch the remaining ports */
-		if (priv->port_sts[i].bridge_dev != bridge)
+		if (intp->br != bridge)
 			continue;
 
-		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
+		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(intp->port));
 		reg &= ~(1 << dp->port);
-		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
+		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(intp->port));
 		priv->port_sts[dp->port].vlan_ctl_mask = reg;
 
 		/* Prevent self removal to preserve isolation */
-		if (dp->port != i)
-			p_ctl &= ~(1 << i);
+		if (dp != intp)
+			p_ctl &= ~(1 << intp->port);
 	}
 
 	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(dp->port));
 	priv->port_sts[dp->port].vlan_ctl_mask = p_ctl;
-	priv->port_sts[dp->port].bridge_dev = NULL;
 }
 
 static void bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 200b1f5..6bba1c9 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -50,8 +50,6 @@ struct bcm_sf2_port_status {
 	struct ethtool_eee eee;
 
 	u32 vlan_ctl_mask;
-
-	struct net_device *bridge_dev;
 };
 
 struct bcm_sf2_arl_entry {
-- 
2.8.0
