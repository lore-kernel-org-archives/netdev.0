From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 4/11] ibm_newemac: Workaround reset timeout when no link
Date: Wed, 05 Dec 2007 11:14:27 +1100
Message-ID: <20071205001537.3EE69DDFCB@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51342 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbXLEAPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 19:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With some PHYs, when the link goes away, the EMAC reset fails due
to the loss of the RX clock I believe.

The old EMAC driver worked around that using some internal chip-specific
clock force bits that are different on various 44x implementations.

This is an attempt at doing it differently, by avoiding the reset when
there is no link, but forcing loopback mode instead. It seems to work
on my Taishan 440GX based board so far.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: Stefan Roese <sr@denx.de>
---

 drivers/net/ibm_newemac/core.c |   20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2007-11-20 14:46:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.c	2007-11-20 14:46:58.000000000 +1100
@@ -464,26 +464,34 @@ static int emac_configure(struct emac_in
 {
 	struct emac_regs __iomem *p = dev->emacp;
 	struct net_device *ndev = dev->ndev;
-	int tx_size, rx_size;
+	int tx_size, rx_size, link = netif_carrier_ok(dev->ndev);
 	u32 r, mr1 = 0;
 
 	DBG(dev, "configure" NL);
 
-	if (emac_reset(dev) < 0)
+	if (!link) {
+		out_be32(&p->mr1, in_be32(&p->mr1)
+			 | EMAC_MR1_FDE | EMAC_MR1_ILE);
+		udelay(100);
+	} else if (emac_reset(dev) < 0)
 		return -ETIMEDOUT;
 
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_reset(dev->tah_dev);
 
-	DBG(dev, " duplex = %d, pause = %d, asym_pause = %d\n",
-	    dev->phy.duplex, dev->phy.pause, dev->phy.asym_pause);
+	DBG(dev, " link = %d duplex = %d, pause = %d, asym_pause = %d\n",
+	    link, dev->phy.duplex, dev->phy.pause, dev->phy.asym_pause);
 
 	/* Default fifo sizes */
 	tx_size = dev->tx_fifo_size;
 	rx_size = dev->rx_fifo_size;
 
+	/* No link, force loopback */
+	if (!link)
+		mr1 = EMAC_MR1_FDE | EMAC_MR1_ILE;
+
 	/* Check for full duplex */
-	if (dev->phy.duplex == DUPLEX_FULL)
+	else if (dev->phy.duplex == DUPLEX_FULL)
 		mr1 |= EMAC_MR1_FDE | EMAC_MR1_MWSW_001;
 
 	/* Adjust fifo sizes, mr1 and timeouts based on link speed */
@@ -1165,9 +1173,9 @@ static void emac_link_timer(struct work_
 		link_poll_interval = PHY_POLL_LINK_ON;
 	} else {
 		if (netif_carrier_ok(dev->ndev)) {
-			emac_reinitialize(dev);
 			netif_carrier_off(dev->ndev);
 			netif_tx_disable(dev->ndev);
+			emac_reinitialize(dev);
 			emac_print_link_status(dev);
 		}
 		link_poll_interval = PHY_POLL_LINK_OFF;
