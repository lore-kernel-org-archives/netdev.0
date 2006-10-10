From: akpm@osdl.org
Subject: [patch 4/7] Remove unnecessary check in drivers/net/depca.c
Date: Tue, 10 Oct 2006 14:33:28 -0700
Message-ID: <200610102133.k9ALXScG024971@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, snakebyte@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51097 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030444AbWJJVdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 17:33:35 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Sesterhenn <snakebyte@gmx.de>

This was spotted by coverity (cid #793).  All callers dereference dev
before calling this functions, and we dereference it earlier in the
function, when initializing lp.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/depca.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff -puN drivers/net/depca.c~remove-unnecessary-check-in-drivers-net-depcac drivers/net/depca.c
--- a/drivers/net/depca.c~remove-unnecessary-check-in-drivers-net-depcac
+++ a/drivers/net/depca.c
@@ -1252,24 +1252,22 @@ static void set_multicast_list(struct ne
 	struct depca_private *lp = (struct depca_private *) dev->priv;
 	u_long ioaddr = dev->base_addr;
 
-	if (dev) {
-		netif_stop_queue(dev);
-		while (lp->tx_old != lp->tx_new);	/* Wait for the ring to empty */
+	netif_stop_queue(dev);
+	while (lp->tx_old != lp->tx_new);	/* Wait for the ring to empty */
 
-		STOP_DEPCA;	/* Temporarily stop the depca.  */
-		depca_init_ring(dev);	/* Initialize the descriptor rings */
-
-		if (dev->flags & IFF_PROMISC) {	/* Set promiscuous mode */
-			lp->init_block.mode |= PROM;
-		} else {
-			SetMulticastFilter(dev);
-			lp->init_block.mode &= ~PROM;	/* Unset promiscuous mode */
-		}
+	STOP_DEPCA;	/* Temporarily stop the depca.  */
+	depca_init_ring(dev);	/* Initialize the descriptor rings */
 
-		LoadCSRs(dev);	/* Reload CSR3 */
-		InitRestartDepca(dev);	/* Resume normal operation. */
-		netif_start_queue(dev);	/* Unlock the TX ring */
+	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous mode */
+		lp->init_block.mode |= PROM;
+	} else {
+		SetMulticastFilter(dev);
+		lp->init_block.mode &= ~PROM;	/* Unset promiscuous mode */
 	}
+
+	LoadCSRs(dev);	/* Reload CSR3 */
+	InitRestartDepca(dev);	/* Resume normal operation. */
+	netif_start_queue(dev);	/* Unlock the TX ring */
 }
 
 /*
_
