From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] net: phy: avoid suspending twice a PHY
Date: Mon, 26 Jan 2015 22:05:40 -0800
Message-ID: <1422338740-18418-5-git-send-email-f.fainelli@gmail.com>
References: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36398 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbA0GGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 01:06:06 -0500
Received: by mail-pd0-f169.google.com with SMTP id g10so16880092pdj.0
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 22:06:05 -0800 (PST)
In-Reply-To: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of a call to ndo_close() a netdevice driver may call
phy_disconnect() -> phy_detach() -> phy_suspend(), such that the PHY is
suspsended at this point and a netdevice driver may clock gate the
backing peripheral providing MDIO bus accessses as well.

Update mdio_bus_phy_may_suspend() to return whether a PHY is allowed to
be suspended and conversely resumed if and only if it was not previously
suspended before while it is currently in detached (netdev pointer is
NULL) state.

This fixes bus errors seen during S2/S3 suspend/resume cycles for
netdevice drivers such as GENET which clock gates the entire Ethernet
MAC, including the MDIO bus block.

Acked-by: Fugang Duan <B38611@freescale.com>
Tested-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changess in v2:
- added Fugang's tags

 drivers/net/phy/mdio_bus.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 20447741893a..095ef3fe369a 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -443,9 +443,13 @@ static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
 	if (!drv || !phydrv->suspend)
 		return false;
 
-	/* PHY not attached? May suspend. */
+	/* PHY not attached? May suspend if the PHY has not already been
+	 * suspended as part of a prior call to phy_disconnect() ->
+	 * phy_detach() -> phy_suspend() because the parent netdev might be the
+	 * MDIO bus driver and clock gated at this point.
+	 */
 	if (!netdev)
-		return true;
+		return !phydev->suspended;
 
 	/* Don't suspend PHY if the attched netdev parent may wakeup.
 	 * The parent may point to a PCI device, as in tg3 driver.
-- 
2.1.0
