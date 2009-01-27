From: y@pengutronix.de
Subject: [PATCH] fec: use dma_alloc_coherent for descriptor ring
Date: Tue, 27 Jan 2009 11:24:04 +0100
Message-ID: <39069.8476731361$1233051959@news.gmane.org>
References: <1233051848-5994-1-git-send-email-y>
 <1233051848-5994-2-git-send-email-y>
 <1233051848-5994-3-git-send-email-y>
 <1233051848-5994-4-git-send-email-y>
 <1233051848-5994-5-git-send-email-y>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42864 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbZA0KY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:24:29 -0500
In-Reply-To: <1233051848-5994-5-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 1087c4d..d7ba07c 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -186,6 +186,7 @@ struct fec_enet_private {
 
 	/* CPM dual port RAM relative addresses.
 	*/
+	dma_addr_t	bd_dma;
 	cbd_t	*rx_bd_base;		/* Address of Rx and Tx buffers. */
 	cbd_t	*tx_bd_base;
 	cbd_t	*cur_rx, *cur_tx;		/* The next free ring entry */
@@ -2107,7 +2108,7 @@ int __init fec_enet_init(struct net_device *dev)
 
 	/* Allocate memory for buffer descriptors.
 	*/
-	mem_addr = __get_free_page(GFP_KERNEL);
+	mem_addr = (unsigned long)dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma, GFP_KERNEL);
 	if (mem_addr == 0) {
 		printk("FEC: allocate descriptor memory failed?\n");
 		return -ENOMEM;
@@ -2202,8 +2203,8 @@ int __init fec_enet_init(struct net_device *dev)
 
 	/* Set receive and transmit descriptor base.
 	*/
-	fecp->fec_r_des_start = __pa((uint)(fep->rx_bd_base));
-	fecp->fec_x_des_start = __pa((uint)(fep->tx_bd_base));
+	fecp->fec_r_des_start = fep->bd_dma;
+	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE;
 
 	/* Install our interrupt handlers. This varies depending on
 	 * the architecture.
@@ -2291,8 +2292,8 @@ fec_restart(struct net_device *dev, int duplex)
 
 	/* Set receive and transmit descriptor base.
 	*/
-	fecp->fec_r_des_start = __pa((uint)(fep->rx_bd_base));
-	fecp->fec_x_des_start = __pa((uint)(fep->tx_bd_base));
+	fecp->fec_r_des_start = fep->bd_dma;
+	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE;
 
 	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
 	fep->cur_rx = fep->rx_bd_base;
-- 
1.5.6.5

