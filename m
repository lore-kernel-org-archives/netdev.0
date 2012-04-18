From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] icplus: fix interrupt for IC+ 101A/G and 1001LF
Date: Wed, 18 Apr 2012 09:16:40 +0200
Message-ID: <1334733400-29340-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:38869 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220Ab2DRHQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 03:16:53 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8F40D123
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:16:46 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 061FA1F05
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:16:46 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes and adds the irq handler for the
IC+ 101A/G where we need to read the reg17 to clean
the irq.
Also remove the flag for the 1001LF where no interrupt
can be used for this device.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index f08c85a..5ac46f5 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -40,6 +40,7 @@ MODULE_LICENSE("GPL");
 #define IP1001_PHASE_SEL_MASK		3	/* IP1001 RX/TXPHASE_SEL */
 #define IP1001_APS_ON			11	/* IP1001 APS Mode  bit */
 #define IP101A_G_APS_ON			2	/* IP101A/G APS Mode bit */
+#define IP101A_G_IRQ_CONF_STATUS	0x11	/* Conf Info IRQ & Status Reg */
 
 static int ip175c_config_init(struct phy_device *phydev)
 {
@@ -185,6 +186,15 @@ static int ip175c_config_aneg(struct phy_device *phydev)
 	return 0;
 }
 
+static int ip101a_g_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, IP101A_G_IRQ_CONF_STATUS);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 static struct phy_driver ip175c_driver = {
 	.phy_id		= 0x02430d80,
 	.name		= "ICPlus IP175C",
@@ -204,7 +214,6 @@ static struct phy_driver ip1001_driver = {
 	.phy_id_mask	= 0x0ffffff0,
 	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause,
-	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &ip1001_config_init,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
@@ -220,6 +229,7 @@ static struct phy_driver ip101a_g_driver = {
 	.features	= PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
+	.ack_interrupt	= ip101a_g_ack_interrupt,
 	.config_init	= &ip101a_g_config_init,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
-- 
1.7.4.4
