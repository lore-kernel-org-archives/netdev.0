From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: phy: bcm7xxx: re-advertise all supported modes out of suspend
Date: Thu, 14 Aug 2014 16:52:52 -0700
Message-ID: <1408060373-5996-3-git-send-email-f.fainelli@gmail.com>
References: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58588 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaHNXxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 19:53:17 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so2523088pab.12
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 16:53:17 -0700 (PDT)
In-Reply-To: <1408060373-5996-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BCM7xxx internal Gigabit PHYs on 28nm process platforms come out
reset without any half-duplex or "hub" compatible advertised modes,
which was causing auto-negotiation issues coming out of S3
suspend/resume, we just could not establish a link with a half-duplex
only link partner.

Make sure that the resume function properly re-configures the PHY device
to advertise all supported modes.

Fixes: b560a58c45c6 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 2b40548c85d5..a8ca03ff4f1e 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -157,6 +157,23 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	return bcm7xxx_28nm_afe_config_init(phydev);
 }
 
+static int bcm7xxx_28nm_resume(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Re-apply workarounds coming out suspend/resume */
+	ret = bcm7xxx_28nm_config_init(phydev);
+	if (ret)
+		return ret;
+
+	/* 28nm Gigabit PHYs come out of reset without any half-duplex
+	 * or "hub" compliant advertised mode, fix that. This does not
+	 * cause any problems with the PHY library since genphy_config_aneg()
+	 * gracefully handles auto-negotiated and forced modes.
+	 */
+	return genphy_config_aneg(phydev);
+}
+
 static int phy_set_clr_bits(struct phy_device *dev, int location,
 					int set_mask, int clr_mask)
 {
@@ -258,7 +275,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.suspend	= bcm7xxx_suspend,
-	.resume		= bcm7xxx_28nm_afe_config_init,
+	.resume		= bcm7xxx_28nm_resume,
 	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM7439,
@@ -271,7 +288,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.suspend	= bcm7xxx_suspend,
-	.resume		= bcm7xxx_28nm_afe_config_init,
+	.resume		= bcm7xxx_28nm_resume,
 	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_ID_BCM7445,
@@ -284,7 +301,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.suspend	= bcm7xxx_suspend,
-	.resume		= bcm7xxx_28nm_config_init,
+	.resume		= bcm7xxx_28nm_afe_config_init,
 	.driver		= { .owner = THIS_MODULE },
 }, {
 	.phy_id		= PHY_BCM_OUI_4,
-- 
1.9.1
