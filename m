From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] Revert "net: dsa: bcm_sf2: Defer port enabling to calling port_enable"
Date: Thu, 28 Sep 2017 11:19:06 -0700
Message-ID: <20170928181906.3156-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit e85ec74ace29 ("net: dsa: bcm_sf2: Defer port
enabling to calling port_enable") because this now makes an unbind
followed by a bind to fail connecting to the ingrated PHY.

What this patch missed is that we need the PHY to be enabled with
bcm_sf2_gphy_enable_set() before probing it on the MDIO bus. This is
correctly done in the ops->setup() function, but by the time
ops->port_enable() runs, this is too late. Upon unbind we would power
down the PHY, and so when we would bind again, the PHY would be left
powered off.

Fixes: e85ec74ace29 ("net: dsa: bcm_sf2: Defer port enabling to calling port_enable")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 898d5642b516..7aecc98d0a18 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -754,11 +754,14 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int port;
 
-	/* Disable unused ports and configure IMP port */
+	/* Enable all valid ports and disable those unused */
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
-		if (dsa_is_cpu_port(ds, port))
+		/* IMP port receives special treatment */
+		if ((1 << port) & ds->enabled_port_mask)
+			bcm_sf2_port_setup(ds, port, NULL);
+		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
-		else if (!((1 << port) & ds->enabled_port_mask))
+		else
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
-- 
2.9.3
