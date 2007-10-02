From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [5/11] pasemi_mac: workaround for erratum 5971
Date: Tue, 2 Oct 2007 16:26:30 -0500
Message-ID: <20071002212630.GF2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46681 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149AbXJBVW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:22:27 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: workaround for erratum 5971

Implement workarounds for erratum 5971, where L2 hints aren't considered
properly unless the way hint is enabled on the interface. Since L2 isn't
setup to dedicate a way to headers, we need to reset the packet count
by hand so it won't run out of credits.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -239,7 +239,9 @@ static int pasemi_mac_setup_rx_resources
 			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
 	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if),
-			   PAS_DMA_RXINT_CFG_DHL(2));
+			   PAS_DMA_RXINT_CFG_DHL(3) |
+			   PAS_DMA_RXINT_CFG_L2 |
+			   PAS_DMA_RXINT_CFG_LW);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
@@ -589,6 +591,11 @@ static int pasemi_mac_clean_rx(struct pa
 		n += 2;
 	}
 
+	if (n > RX_RING_SIZE) {
+		/* Errata 5971 workaround: L2 target of headers */
+		write_iob_reg(mac, PAS_IOB_COM_PKTHDRCNT, 0);
+		n &= (RX_RING_SIZE-1);
+	}
 	mac->rx->next_to_clean = n;
 	pasemi_mac_replenish_rx_ring(mac->netdev, limit-count);
 
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -210,6 +210,8 @@ enum {
 #define    PAS_DMA_RXINT_CFG_DHL_S	24
 #define    PAS_DMA_RXINT_CFG_DHL(x)	(((x) << PAS_DMA_RXINT_CFG_DHL_S) & \
 					 PAS_DMA_RXINT_CFG_DHL_M)
+#define    PAS_DMA_RXINT_CFG_LW		0x00200000
+#define    PAS_DMA_RXINT_CFG_L2		0x00100000
 #define    PAS_DMA_RXINT_CFG_WIF	0x00000002
 #define    PAS_DMA_RXINT_CFG_WIL	0x00000001
 
@@ -315,6 +317,12 @@ enum {
 #define    PAS_STATUS_SOFT		0x4000000000000000ull
 #define    PAS_STATUS_INT		0x8000000000000000ull
 
+#define PAS_IOB_COM_PKTHDRCNT		0x120
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR1_M	0x0fff0000
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR1_S	16
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR0_M	0x00000fff
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR0_S	0
+
 #define PAS_IOB_DMA_RXCH_CFG(i)		(0x1100 + (i)*4)
 #define    PAS_IOB_DMA_RXCH_CFG_CNTTH_M		0x00000fff
 #define    PAS_IOB_DMA_RXCH_CFG_CNTTH_S		0
