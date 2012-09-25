From: Marek Vasut <marex@denx.de>
Subject: [PATCH] net: phy: smsc: Implement PHY config_init for LAN87xx
Date: Tue, 25 Sep 2012 22:17:42 +0200
Message-ID: <1348604262-21522-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Otavio Salvador <otavio@ossystems.com.br>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:49384 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283Ab2IYURy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 16:17:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LAN8710/LAN8720 chips do have broken the "FlexPWR" smart power-saving
capability. Enabling it leads to the PHY not being able to detect Link when
cold-started without cable connected. Thus, make sure this is disabled.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Christian Hohnstaedt <chohnstaedt@innominate.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Fabio Estevam <fabio.estevam@freescale.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Otavio Salvador <otavio@ossystems.com.br>
---
 drivers/net/phy/smsc.c |   28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 6d61923..88e3991 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -56,6 +56,32 @@ static int smsc_phy_config_init(struct phy_device *phydev)
 	return smsc_phy_ack_interrupt (phydev);
 }
 
+static int lan87xx_config_init(struct phy_device *phydev)
+{
+	/*
+	 * Make sure the EDPWRDOWN bit is NOT set. Setting this bit on
+	 * LAN8710/LAN8720 PHY causes the PHY to misbehave, likely due
+	 * to a bug on the chip.
+	 *
+	 * When the system is powered on with the network cable being
+	 * disconnected all the way until after ifconfig ethX up is
+	 * issued for the LAN port with this PHY, connecting the cable
+	 * afterwards does not cause LINK change detection, while the
+	 * expected behavior is the Link UP being detected.
+	 */
+	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+	if (rc < 0)
+		return rc;
+
+	rc &= ~MII_LAN83C185_EDPWRDOWN;
+
+	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS, rc);
+	if (rc < 0)
+		return rc;
+
+	return smsc_phy_ack_interrupt(phydev);
+}
+
 static int lan911x_config_init(struct phy_device *phydev)
 {
 	return smsc_phy_ack_interrupt(phydev);
@@ -162,7 +188,7 @@ static struct phy_driver smsc_phy_driver[] = {
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.config_init	= smsc_phy_config_init,
+	.config_init	= lan87xx_config_init,
 
 	/* IRQ related */
 	.ack_interrupt	= smsc_phy_ack_interrupt,
-- 
1.7.10.4
