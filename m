From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] gianfar: Reduce logging noise seen due to phy polling if link is down
Date: Mon,  2 Mar 2015 12:03:27 -0800
Message-ID: <1425326607-21464-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:49410 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbbCBUDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:03:32 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YSWYt-001IFY-Cd
	for netdev@vger.kernel.org; Mon, 02 Mar 2015 20:03:31 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6ce29b0e2a04 ("gianfar: Avoid unnecessary reg accesses in adjust_link()")
eliminates unnecessary calls to adjust_link for phy devices which don't support
interrupts and need polling. As part of that work, the 'new_state' local flag,
which was used to reduce logging noise on the console, was eliminated.

Unfortunately, that means that a 'Link is Down' log message will now be
issued continuously if a link is configured as UP, the link state is down,
and the associated phy requires polling. This occurs because priv->oldduplex
is -1 in this case, which always differs from phydev->duplex. In addition,
phydev->speed may also differ from priv->oldspeed.  gfar_update_link_state()
is therefore called each time a phy is polled, even if the link state did not
change.

Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/freescale/gianfar.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 43df788..178e540 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3162,8 +3162,8 @@ static void adjust_link(struct net_device *dev)
 	struct phy_device *phydev = priv->phydev;
 
 	if (unlikely(phydev->link != priv->oldlink ||
-		     phydev->duplex != priv->oldduplex ||
-		     phydev->speed != priv->oldspeed))
+		     (phydev->link && (phydev->duplex != priv->oldduplex ||
+				       phydev->speed != priv->oldspeed))))
 		gfar_update_link_state(priv);
 }
 
-- 
2.1.0
