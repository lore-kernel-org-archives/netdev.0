From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] NET: fec: only enable napi if we are successful
Date: Tue, 18 Feb 2014 12:55:42 +0000
Message-ID: <E1WFkD8-0004pj-Pr@rmk-PC.arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, dmalek@jlc.net,
	gerg@snapgear.com, phdm@macqel.be,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:40165 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754902AbaBRMzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:55:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If napi is left enabled after a failed attempt to bring the interface
up, we BUG:

fec 2188000.ethernet eth0: no PHY, assuming direct connection to switch
libphy: PHY fixed-0:00 not found
fec 2188000.ethernet eth0: could not attach to PHY
------------[ cut here ]------------
kernel BUG at include/linux/netdevice.h:502!
Internal error: Oops - BUG: 0 [#1] SMP ARM
...
PC is at fec_enet_open+0x4d0/0x500
LR is at __dev_open+0xa4/0xfc

Only enable napi after we are past all the failure paths.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
No individual is apparently listed as a maintainer for this driver, so
I'm just guesing...

I noticed this error when there were other problems with the driver
which resulted in the phy not being found, but it would be a good idea
to fix this error too.

 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d4782b42401b..903362a7b584 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1778,8 +1778,6 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
-	napi_enable(&fep->napi);
-
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
@@ -1794,6 +1792,8 @@ fec_enet_open(struct net_device *ndev)
 		fec_enet_free_buffers(ndev);
 		return ret;
 	}
+
+	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
 	fep->opened = 1;
-- 
1.8.3.1
