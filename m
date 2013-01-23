From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] net: phy: icplus: Use the RGMII interface mode to configure clock delays
Date: Wed, 23 Jan 2013 11:22:36 +0100
Message-ID: <1358936557-31540-1-git-send-email-peppe.cavallaro@st.com>
Cc: Stuart Menefy <stuart.menefy@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:34721 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754509Ab3AWKWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 05:22:49 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id F0E131D5
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 10:22:46 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 724FE2B79
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 10:22:46 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stuart Menefy <stuart.menefy@st.com>

Like several other PHY devices which support RGMII, the IC+1001 allows
additional delays to by added to the RX_CLK and TX_CLK signals to
compensate for skew between the clock and data signals. Previously this
was always enabled, but this change makes use of the different RGMII
interface modes to allow the user to specify whether this should be
enabled.

Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index d5199cb..c0e0924 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -36,8 +36,9 @@ MODULE_LICENSE("GPL");
 
 /* IP101A/G - IP1001 */
 #define IP10XX_SPEC_CTRL_STATUS		16	/* Spec. Control Register */
+#define IP1001_RXPHASE_SEL		(1<<0)	/* Add delay on RX_CLK */
+#define IP1001_TXPHASE_SEL		(1<<1)	/* Add delay on TX_CLK */
 #define IP1001_SPEC_CTRL_STATUS_2	20	/* IP1001 Spec. Control Reg 2 */
-#define IP1001_PHASE_SEL_MASK		3	/* IP1001 RX/TXPHASE_SEL */
 #define IP1001_APS_ON			11	/* IP1001 APS Mode  bit */
 #define IP101A_G_APS_ON			2	/* IP101A/G APS Mode bit */
 #define IP101A_G_IRQ_CONF_STATUS	0x11	/* Conf Info IRQ & Status Reg */
@@ -143,14 +144,24 @@ static int ip1001_config_init(struct phy_device *phydev)
 	if (c < 0)
 		return c;
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
-		/* Additional delay (2ns) used to adjust RX clock phase
-		 * at RGMII interface */
+	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
+
 		c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
 		if (c < 0)
 			return c;
 
-		c |= IP1001_PHASE_SEL_MASK;
+		c &= ~(IP1001_RXPHASE_SEL | IP1001_TXPHASE_SEL);
+
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+			c |= (IP1001_RXPHASE_SEL | IP1001_TXPHASE_SEL);
+		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+			c |= IP1001_RXPHASE_SEL;
+		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+			c |= IP1001_TXPHASE_SEL;
+
 		c = phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
 		if (c < 0)
 			return c;
-- 
1.7.4.4
