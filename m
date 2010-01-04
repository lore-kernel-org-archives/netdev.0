From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [RESEND PATCH] phy: SMSC device Energy Detect power-down mode
Date: Mon,  4 Jan 2010 11:44:33 +0100
Message-ID: <1262601873-7105-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:45924 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753184Ab0ADKoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 05:44:46 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6806927B
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2010 10:44:43 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E466B1019
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2010 10:44:42 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMSC Ethernet Transceivers (LAN88710, LAN8710, LAN8720, LAN8187,
LAN8700, LAN83C185) provide a mechanism to conserve power when
the device is not connected to an active link partner
(Energy Detect Mode).
So this patch enables the Energy Detect power-down mode
for these Transceivers.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/smsc.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 5123bb9..ed2644a 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -25,6 +25,7 @@
 
 #define MII_LAN83C185_ISF 29 /* Interrupt Source Flags */
 #define MII_LAN83C185_IM  30 /* Interrupt Mask */
+#define MII_LAN83C185_CTRL_STATUS 17 /* Mode/Status Register */
 
 #define MII_LAN83C185_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
 #define MII_LAN83C185_ISF_INT2 (1<<2) /* Parallel Detection Fault */
@@ -37,8 +38,10 @@
 #define MII_LAN83C185_ISF_INT_ALL (0x0e)
 
 #define MII_LAN83C185_ISF_INT_PHYLIB_EVENTS \
-	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4)
+	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4 | \
+	 MII_LAN83C185_ISF_INT7)
 
+#define MII_LAN83C185_EDPWRDOWN	(1 << 13) /* EDPWRDOWN */
 
 static int smsc_phy_config_intr(struct phy_device *phydev)
 {
@@ -59,9 +62,23 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
+	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+	if (rc < 0)
+		return rc;
+
+	/* Enable energy detect mode for this SMSC Transceivers */
+	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
+		       rc | MII_LAN83C185_EDPWRDOWN);
+	if (rc < 0)
+		return rc;
+
 	return smsc_phy_ack_interrupt (phydev);
 }
 
+static int lan911x_config_init(struct phy_device *phydev)
+{
+	return smsc_phy_ack_interrupt(phydev);
+}
 
 static struct phy_driver lan83c185_driver = {
 	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
@@ -147,7 +164,7 @@ static struct phy_driver lan911x_int_driver = {
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.config_init	= smsc_phy_config_init,
+	.config_init	= lan911x_config_init,
 
 	/* IRQ related */
 	.ack_interrupt	= smsc_phy_ack_interrupt,
-- 
1.6.0.4

