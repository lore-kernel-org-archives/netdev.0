From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: force link for all fixed PHY devices
Date: Thu, 11 Dec 2014 18:12:42 -0800
Message-ID: <1418350362-29183-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:50888 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758186AbaLLCNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 21:13:01 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so6212050pad.23
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 18:13:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ports of the switch that we define as "fixed PHYs" such as MoCA, we
would have our Port 7 special handling that would allow us to assert the
link status indication.

For other ports, such as e.g: RGMII_1 connected to a cable modem, we
would rely on whatever the bootloader has left configured, which is a
bad assumption to make, we really need to force the link status
indication here.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 4f4c2a7888e5..feb29c4526f7 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -684,10 +684,9 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 					 struct fixed_phy_status *status)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	u32 link, duplex, pause, speed;
+	u32 duplex, pause, speed;
 	u32 reg;
 
-	link = core_readl(priv, CORE_LNKSTS);
 	duplex = core_readl(priv, CORE_DUPSTS);
 	pause = core_readl(priv, CORE_PAUSESTS);
 	speed = core_readl(priv, CORE_SPDSTS);
@@ -701,22 +700,26 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 	 * which means that we need to force the link at the port override
 	 * level to get the data to flow. We do use what the interrupt handler
 	 * did determine before.
+	 *
+	 * For the other ports, we just force the link status, since this is
+	 * a fixed PHY device.
 	 */
 	if (port == 7) {
 		status->link = priv->port_sts[port].link;
-		reg = core_readl(priv, CORE_STS_OVERRIDE_GMIIP_PORT(7));
-		reg |= SW_OVERRIDE;
-		if (status->link)
-			reg |= LINK_STS;
-		else
-			reg &= ~LINK_STS;
-		core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(7));
 		status->duplex = 1;
 	} else {
-		status->link = !!(link & (1 << port));
+		status->link = 1;
 		status->duplex = !!(duplex & (1 << port));
 	}
 
+	reg = core_readl(priv, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+	reg |= SW_OVERRIDE;
+	if (status->link)
+		reg |= LINK_STS;
+	else
+		reg &= ~LINK_STS;
+	core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+
 	switch (speed) {
 	case SPDSTS_10:
 		status->speed = SPEED_10;
-- 
2.1.0
