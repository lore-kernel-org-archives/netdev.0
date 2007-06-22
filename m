From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 5/9] pasemi_mac: Enable L2 caching of packet headers
Date: Fri, 22 Jun 2007 15:05:32 -0500
Message-ID: <20070622200532.GF11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59220 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbXFVUHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:07:18 -0400
Content-Disposition: inline; filename=pasemi_mac-cache-headers
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable settings to target L2 for the first few cachelines of the packet,
since we'll access them to get to the various headers.


Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -216,7 +216,7 @@ static int pasemi_mac_setup_rx_resources
 			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 2));
 
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id),
-			   PAS_DMA_RXCHAN_CFG_HBU(1));
+			   PAS_DMA_RXCHAN_CFG_HBU(2));
 
 	write_dma_reg(mac, PAS_DMA_RXINT_BASEL(mac->dma_if),
 			   PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
@@ -225,6 +225,9 @@ static int pasemi_mac_setup_rx_resources
 			   PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
 			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
+	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if),
+			   PAS_DMA_RXINT_CFG_DHL(2));
+
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
 
Index: netdev-2.6/drivers/net/pasemi_mac.h
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.h
+++ netdev-2.6/drivers/net/pasemi_mac.h
@@ -218,6 +218,14 @@ enum {
 #define    PAS_DMA_RXINT_RCMDSTA_ACT	0x00010000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
+#define PAS_DMA_RXINT_CFG(i)		(0x204+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_CFG_DHL_M	0x07000000
+#define    PAS_DMA_RXINT_CFG_DHL_S	24
+#define    PAS_DMA_RXINT_CFG_DHL(x)	(((x) << PAS_DMA_RXINT_CFG_DHL_S) & \
+					 PAS_DMA_RXINT_CFG_DHL_M)
+#define    PAS_DMA_RXINT_CFG_WIF	0x00000002
+#define    PAS_DMA_RXINT_CFG_WIL	0x00000001
+
 #define PAS_DMA_RXINT_INCR(i)		(0x210+(i)*_PAS_DMA_RXINT_STRIDE)
 #define    PAS_DMA_RXINT_INCR_INCR_M	0x0000ffff
 #define    PAS_DMA_RXINT_INCR_INCR_S	0

--
