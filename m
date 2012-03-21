From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] net: phy: smsc: energy saving does not work without interrupts
Date: Wed, 21 Mar 2012 13:08:27 +0100
Message-ID: <1332331707-2350-1-git-send-email-w.sang@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51313 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab2CUMIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 08:08:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We discovered link detection failures using this PHY with the Freescale FEC
which does not have interrupt support yet. Disabling the energy saving mode
makes all go well. It should be possible to make this mode work without
interrupts by adding some code dealing with the ENERGYON flag. Since adding
interrupt support to the FEC driver seems to be the better solution for us, I
want to at least make sure the PHY works reliably always. So, disable energy
saving if there is no interrupt support.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---

Giuseppe: Did you test with interrupts? Do you agree?

If Giuseppe is fine with the patch, this should probably be tagged for stable.

 drivers/net/phy/smsc.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index fc3e7e9..6dcf57a 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -43,16 +43,18 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
-	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
-	if (rc < 0)
-		return rc;
-
-	/* Enable energy detect mode for this SMSC Transceivers */
-	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
-		       rc | MII_LAN83C185_EDPWRDOWN);
-	if (rc < 0)
-		return rc;
-
+	/* TODO: add code to make EDPWRDOWN work without interrupts */
+	if (PHY_INTERRUPT_ENABLED == phydev->interrupts) {
+		int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+		if (rc < 0)
+			return rc;
+
+		/* Enable energy detect mode for this SMSC Transceivers */
+		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
+			       rc | MII_LAN83C185_EDPWRDOWN);
+		if (rc < 0)
+			return rc;
+	}
 	return smsc_phy_ack_interrupt (phydev);
 }
 
-- 
1.7.9.1
