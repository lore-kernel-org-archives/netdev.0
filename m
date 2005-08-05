From: Wade Farnsworth <wfarnsworth@mvista.com>
Subject: [PATCH] emac: add support for platform-specific unsupported PHY
	features
Date: 05 Aug 2005 16:32:05 -0700
Message-ID: <1123284725.27880.26.camel@rhino.az.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-H6kjIo0tyo+58bZb74rl"
Cc: Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com,
        Matt Porter <mporter@kernel.crashing.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--=-H6kjIo0tyo+58bZb74rl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello,

This patch adds support to the ibm_emac driver for platform-specific
unsupported PHY features.

The patch attempts to determine the highest speed and duplex when
autonegotiation is unsupported.

-Wade Farnsworth

Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>

--=-H6kjIo0tyo+58bZb74rl
Content-Disposition: attachment; filename=ibm-emac-phy-feat-unsupp-core.patch
Content-Type: text/x-patch; name=ibm-emac-phy-feat-unsupp-core.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff -upr linux-2.6/drivers/net/ibm_emac/ibm_emac_core.c linux-2.6-dev/drivers/net/ibm_emac/ibm_emac_core.c
--- linux-2.6/drivers/net/ibm_emac/ibm_emac_core.c	2005-08-03 13:33:42.000000000 -0700
+++ linux-2.6-dev/drivers/net/ibm_emac/ibm_emac_core.c	2005-08-02 10:42:59.000000000 -0700
@@ -1876,6 +1876,9 @@ static int emac_init_device(struct ocp_d
 		rc = -ENODEV;
 		goto bail;
 	}
+	
+	/* Disable any PHY features not supported by the platform */
+	ep->phy_mii.def->features &= ~emacdata->feat_unsupp;
 
 	/* Setup initial PHY config & startup aneg */
 	if (ep->phy_mii.def->ops->init)
@@ -1883,6 +1886,38 @@ static int emac_init_device(struct ocp_d
 	netif_carrier_off(ndev);
 	if (ep->phy_mii.def->features & SUPPORTED_Autoneg)
 		ep->want_autoneg = 1;
+	else {
+		ep->want_autoneg = 0;
+		
+		/* Select highest supported speed/duplex */
+		if (ep->phy_mii.def->features & SUPPORTED_10000baseT_Full) {
+			ep->phy_mii.speed = SPEED_10000;
+			ep->phy_mii.duplex = DUPLEX_FULL;
+		} else if (ep->phy_mii.def->features & 
+			   SUPPORTED_1000baseT_Full) {
+			ep->phy_mii.speed = SPEED_1000;
+			ep->phy_mii.duplex = DUPLEX_FULL;
+		} else if (ep->phy_mii.def->features & 
+			   SUPPORTED_1000baseT_Half) {
+			ep->phy_mii.speed = SPEED_1000;
+			ep->phy_mii.duplex = DUPLEX_HALF;
+		} else if (ep->phy_mii.def->features & 
+			   SUPPORTED_100baseT_Full) {
+			ep->phy_mii.speed = SPEED_100;
+			ep->phy_mii.duplex = DUPLEX_FULL;
+		} else if (ep->phy_mii.def->features & 
+			   SUPPORTED_100baseT_Half) {
+			ep->phy_mii.speed = SPEED_100;
+			ep->phy_mii.duplex = DUPLEX_HALF;
+		} else if (ep->phy_mii.def->features & 
+			   SUPPORTED_10baseT_Full) {
+			ep->phy_mii.speed = SPEED_10;
+			ep->phy_mii.duplex = DUPLEX_FULL;
+		} else {
+			ep->phy_mii.speed = SPEED_10;
+			ep->phy_mii.duplex = DUPLEX_HALF;
+		}
+	}
 	emac_start_link(ep, NULL);
 
 	/* read the MAC Address */

--=-H6kjIo0tyo+58bZb74rl--
