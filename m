From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH] gianfar: Don't reset TBI<->SerDes link if it's already up
Date: Wed, 24 Sep 2008 13:23:59 -0700
Message-ID: <1222287839-6545-1-git-send-email-tpiepho@freescale.com>
Cc: afleming@freescale.com, Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:38785 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbYIXU0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 16:26:43 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m8OKQf6B021339
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 13:26:41 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link may be up already via the chip's reset strapping, or though action
of U-Boot, or from the last time the interface was brought up.  Resetting
the link causes it to go down for several seconds.  This can significantly
increase the time from power-on to DHCP completion and a device being
accessible to the network.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1a4a85b..dd7d8e5 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -578,6 +578,14 @@ static void gfar_configure_serdes(struct net_device *dev)
 	if (bus)
 		mutex_lock(&bus->mdio_lock);
 
+	/* If the link is already up, we must already be ok, and don't need to
+	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
+	 * everything for us?  Resetting it takes the link down and requires
+	 * several seconds for it to come back.
+	 */
+	if (gfar_local_mdio_read(regs, tbipa, MII_BMSR) & BMSR_LSTATUS)
+		goto done;
+
 	/* Single clk mode, mii mode off(for serdes communication) */
 	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
 
@@ -588,6 +596,7 @@ static void gfar_configure_serdes(struct net_device *dev)
 	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
 
+	done:
 	if (bus)
 		mutex_unlock(&bus->mdio_lock);
 }
-- 
1.5.4.1

