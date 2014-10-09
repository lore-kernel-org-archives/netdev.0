From: Bruno Thomsen <bth@kamstrup.dk>
Subject: [PATCH] phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Thu, 9 Oct 2014 16:48:14 +0200
Message-ID: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <s.hauer@pengutronix.de>,
	<bruno.thomsen@gmail.com>, <bth@kamstrup.dk>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kamstrup.com ([93.167.225.188]:62688 "EHLO
	mail.kamstrup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbaJIOy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 10:54:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug: Unable to send and receive Ethernet packets with Micrel PHY.

Affected devices:
KSZ8031RNL (commercial temp)
KSZ8031RNLI (industrial temp)

Description:
PHY device is correctly detected during probe.
PHY power-up default is 25MHz crystal clock input
and output 50MHz RMII clock to MAC.
Reconfiguration of PHY to input 50MHz RMII clock from MAC
causes PHY to become unresponsive if clock source is changed
after Operation Mode Strap Override (OMSO) register setup.

Cause:
Long lead times on parts where clock setup match circuit design
forces the usage of similar parts with wrong default setup.

Solution:
Swapped KSZ8031 register setup and added phy_write return code validation.

Tested with Freescale i.MX28 Fast Ethernet Controler (fec).

Signed-off-by: Bruno Thomsen <bth@kamstrup.dk>
---
 drivers/net/phy/micrel.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 011dbda..ec3f646 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -194,8 +194,10 @@ static int ksz8021_config_init(struct phy_device *phydev)
 	if (rc)
 		dev_err(&phydev->dev, "failed to set led mode\n");
 
-	phy_write(phydev, MII_KSZPHY_OMSO, val);
 	rc = ksz_config_flags(phydev);
+	if (rc < 0)
+		return rc;
+	rc = phy_write(phydev, MII_KSZPHY_OMSO, val);
 	return rc < 0 ? rc : 0;
 }
 
-- 
1.9.1
