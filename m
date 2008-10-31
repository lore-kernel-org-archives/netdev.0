From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH 2/2] gianfar: Don't reset TBI<->SerDes link if it's already up
Date: Thu, 30 Oct 2008 18:17:07 -0700
Message-ID: <1225415827-8167-2-git-send-email-tpiepho@freescale.com>
References: <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp>
Cc: linuxppc-dev@ozlabs.org, Nate Case <ncase@xes-inc.com>,
	Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48247 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbYJaBRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 21:17:51 -0400
In-Reply-To: <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp>
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
index 249541a..83a5cb6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -591,6 +591,14 @@ static void gfar_configure_serdes(struct net_device *dev)
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
 
@@ -601,6 +609,7 @@ static void gfar_configure_serdes(struct net_device *dev)
 	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
 
+	done:
 	if (bus)
 		mutex_unlock(&bus->mdio_lock);
 }
-- 
1.5.4.1

