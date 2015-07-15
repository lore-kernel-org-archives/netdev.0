From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: do not use indirect reads and writes for 7445E0
Date: Wed, 15 Jul 2015 16:09:32 -0700
Message-ID: <1437001772-17511-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36288 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbbGOXLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 19:11:24 -0400
Received: by pachj5 with SMTP id hj5so31625977pac.3
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 16:11:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

7445E0 contains an ECO which disconnected the internal SF2 pseudo-PHY which was
known to conflict with the external pseudo-PHY of BCM53125 switches. This
motivated the need to utilize the internal SF2 MDIO controller via indirect
register reads/writes to control external Broadcom switches due to this address
conflict (both responded at address 30d).

For 7445E0, the internal pseudo-PHY of the SF2 switch got disconnected, and as
a consequence this prevents the internal SF2 MDIO bus controller from reading
data (reads back everything as 0) since the MDI line is tied low.

Fix this by making the indirect register reads and writes conditional to
7445D0, on 7445E0 we can utilize the SWITCH_MDIO controller (backed by
mdio-unimac and not the DSA created slave MII bus).

We utilize of_machine_is_compatible() here since this is the only way for use
to differentiate between these two chips in a way that does not violate layers
or becomes (too) vendor-specific.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 972982f8bea7..079897b3a955 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -696,9 +696,20 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	}
 
 	/* Include the pseudo-PHY address and the broadcast PHY address to
-	 * divert reads towards our workaround
+	 * divert reads towards our workaround. This is only required for
+	 * 7445D0, since 7445E0 disconnects the internal switch pseudo-PHY such
+	 * that we can use the regular SWITCH_MDIO master controller instead.
+	 *
+	 * By default, DSA initializes ds->phys_mii_mask to ds->phys_port_mask
+	 * to have a 1:1 mapping between Port address and PHY address in order
+	 * to utilize the slave_mii_bus instance to read from Port PHYs. This is
+	 * not what we want here, so we initialize phys_mii_mask 0 to always
+	 * utilize the "master" MDIO bus backed by the "mdio-unimac" driver.
 	 */
-	ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
+	if (of_machine_is_compatible("brcm,bcm7445d0"))
+		ds->phys_mii_mask |= ((1 << BRCM_PSEUDO_PHY_ADDR) | (1 << 0));
+	else
+		ds->phys_mii_mask = 0;
 
 	rev = reg_readl(priv, REG_SWITCH_REVISION);
 	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
-- 
2.1.0
