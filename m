From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v2 4/6] net: fec: Increase buffer descriptor entry number
Date: Wed, 4 Jun 2014 15:39:29 +0800
Message-ID: <1401867571-11684-5-git-send-email-b38611@freescale.com>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>, <R49496@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0186.outbound.protection.outlook.com ([207.46.163.186]:28016
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751683AbaFDJC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 05:02:58 -0400
In-Reply-To: <1401867571-11684-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support SG, software TSO, let's increase BD entry number.

CC: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    6 +++---
 drivers/net/ethernet/freescale/fec_main.c |   21 ++++++++++++---------
 2 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 3b8d6d1..798ad88 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -240,14 +240,14 @@ struct bufdesc_ex {
  * the skbuffer directly.
  */
 
-#define FEC_ENET_RX_PAGES	8
+#define FEC_ENET_RX_PAGES	128
 #define FEC_ENET_RX_FRSIZE	2048
 #define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
 #define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
 #define FEC_ENET_TX_FRSIZE	2048
 #define FEC_ENET_TX_FRPPG	(PAGE_SIZE / FEC_ENET_TX_FRSIZE)
-#define TX_RING_SIZE		16	/* Must be power of two */
-#define TX_RING_MOD_MASK	15	/*   for this to work */
+#define TX_RING_SIZE		512	/* Must be power of two */
+#define TX_RING_MOD_MASK	511	/*   for this to work */
 
 #define BD_ENET_RX_INT          0x00800000
 #define BD_ENET_RX_PTP          ((ushort)0x0400)
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cf3c368..9de1660 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -173,10 +173,6 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #endif
 #endif /* CONFIG_M5272 */
 
-#if (((RX_RING_SIZE + TX_RING_SIZE) * 32) > PAGE_SIZE)
-#error "FEC: descriptor ring size constants too large"
-#endif
-
 /* Interrupt events/masks. */
 #define FEC_ENET_HBERR	((uint)0x80000000)	/* Heartbeat error */
 #define FEC_ENET_BABR	((uint)0x40000000)	/* Babbling receiver */
@@ -2061,9 +2057,20 @@ static int fec_enet_init(struct net_device *ndev)
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
 	struct bufdesc *cbd_base;
+	int bd_size;
+
+	/* init the tx & rx ring size */
+	fep->tx_ring_size = TX_RING_SIZE;
+	fep->rx_ring_size = RX_RING_SIZE;
+
+	if (fep->bufdesc_ex)
+		bd_size = sizeof(struct bufdesc_ex);
+	else
+		bd_size = sizeof(struct bufdesc);
+	bd_size *= (fep->tx_ring_size + fep->rx_ring_size);
 
 	/* Allocate memory for buffer descriptors. */
-	cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
+	cbd_base = dma_alloc_coherent(NULL, bd_size, &fep->bd_dma,
 				      GFP_KERNEL);
 	if (!cbd_base)
 		return -ENOMEM;
@@ -2077,10 +2084,6 @@ static int fec_enet_init(struct net_device *ndev)
 	/* make sure MAC we just acquired is programmed into the hw */
 	fec_set_mac_address(ndev, NULL);
 
-	/* init the tx & rx ring size */
-	fep->tx_ring_size = TX_RING_SIZE;
-	fep->rx_ring_size = RX_RING_SIZE;
-
 	/* Set receive and transmit descriptor base. */
 	fep->rx_bd_base = cbd_base;
 	if (fep->bufdesc_ex)
-- 
1.7.8
