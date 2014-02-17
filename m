From: Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Subject: [PATCH] of_mdio: fix phy interrupt passing
Date: Mon, 17 Feb 2014 16:29:40 +0000
Message-ID: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-kernel-81qHHgoATdFT9dQujB1mzip2UmYkHbXO@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
	Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
To: grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The of_mdiobus_register_phy() is not setting phy->irq this causing
some drivers to incorrectly assume that the PHY does not have an
IRQ associated with it or install an interrupt handler for the
PHY.

Simplify the code setting irq and set the phy->irq at the same
time so that the case if mdio->irq is not NULL is easier to read.

This fixes the issue:
 net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI

to the correct:
 net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI

Signed-off-by: Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
---
 drivers/of/of_mdio.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 875b7b6..7b3e7b0 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -44,7 +44,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 {
 	struct phy_device *phy;
 	bool is_c45;
-	int rc, prev_irq;
+	int rc;
 	u32 max_speed = 0;
 
 	is_c45 = of_device_is_compatible(child,
@@ -55,11 +55,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 		return 1;
 
 	if (mdio->irq) {
-		prev_irq = mdio->irq[addr];
-		mdio->irq[addr] =
-			irq_of_parse_and_map(child, 0);
-		if (!mdio->irq[addr])
-			mdio->irq[addr] = prev_irq;
+		rc = irq_of_parse_and_map(child, 0);
+		if (rc > 0) {
+			mdio->irq[addr] = rc;
+			phy->irq = rc;
+		}
 	}
 
 	/* Associate the OF node with the device structure so it
-- 
1.8.5.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
