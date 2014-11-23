From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: init maximum receive buffer size for ring1 and ring2
Date: Sun, 23 Nov 2014 17:23:06 +0800
Message-ID: <1416734586-26634-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <festevam@gmail.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0144.outbound.protection.outlook.com ([65.55.169.144]:29471
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753129AbaKWJyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2014 04:54:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i.MX6SX fec support three rx ring1, the current driver lost to init
ring1 and ring2 maximum receive buffer size, that cause receving
frame date length error. The driver reports "rcv is not +last" error
log in user case.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |   11 +++++++++--
 drivers/net/ethernet/freescale/fec_main.c |    4 +---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 7aa9388..469691a 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -53,11 +53,13 @@
 #define FEC_R_FSTART		0x150 /* FIFO receive start reg */
 #define FEC_R_DES_START_1	0x160 /* Receive descriptor ring 1 */
 #define FEC_X_DES_START_1	0x164 /* Transmit descriptor ring 1 */
+#define FEC_R_BUFF_SIZE_1	0x168 /* Maximum receive buff ring1 size */
 #define FEC_R_DES_START_2	0x16c /* Receive descriptor ring 2 */
 #define FEC_X_DES_START_2	0x170 /* Transmit descriptor ring 2 */
+#define FEC_R_BUFF_SIZE_2	0x174 /* Maximum receive buff ring2 size */
 #define FEC_R_DES_START_0	0x180 /* Receive descriptor ring */
 #define FEC_X_DES_START_0	0x184 /* Transmit descriptor ring */
-#define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
+#define FEC_R_BUFF_SIZE_0	0x188 /* Maximum receive buff size */
 #define FEC_R_FIFO_RSFL		0x190 /* Receive FIFO section full threshold */
 #define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold */
 #define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold */
@@ -165,7 +167,9 @@
 #define FEC_X_DES_START_0	0x3d4 /* Transmit descriptor ring */
 #define FEC_X_DES_START_1	FEC_X_DES_START_0
 #define FEC_X_DES_START_2	FEC_X_DES_START_0
-#define FEC_R_BUFF_SIZE		0x3d8 /* Maximum receive buff size */
+#define FEC_R_BUFF_SIZE_0	0x3d8 /* Maximum receive buff size */
+#define FEC_R_BUFF_SIZE_1	FEC_R_BUFF_SIZE_0
+#define FEC_R_BUFF_SIZE_2	FEC_R_BUFF_SIZE_0
 #define FEC_FIFO_RAM		0x400 /* FIFO RAM buffer */
 /* Not existed in real chip
  * Just for pass build.
@@ -285,6 +289,9 @@ struct bufdesc_ex {
 #define FEC_X_DES_START(X)	(((X) == 1) ? FEC_X_DES_START_1 : \
 				(((X) == 2) ? \
 					FEC_X_DES_START_2 : FEC_X_DES_START_0))
+#define FEC_R_BUFF_SIZE(X)	(((X) == 1) ? FEC_R_BUFF_SIZE_1 : \
+				(((X) == 2) ? \
+					FEC_R_BUFF_SIZE_2 : FEC_R_BUFF_SIZE_0))
 #define FEC_R_DES_ACTIVE(X)	(((X) == 1) ? FEC_R_DES_ACTIVE_1 : \
 				(((X) == 2) ? \
 				   FEC_R_DES_ACTIVE_2 : FEC_R_DES_ACTIVE_0))
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1b6d26b..d2955ce 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -867,6 +867,7 @@ static void fec_enet_enable_ring(struct net_device *ndev)
 	for (i = 0; i < fep->num_rx_queues; i++) {
 		rxq = fep->rx_queue[i];
 		writel(rxq->bd_dma, fep->hwp + FEC_R_DES_START(i));
+		writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
 
 		/* enable DMA1/2 */
 		if (i)
@@ -941,9 +942,6 @@ fec_restart(struct net_device *ndev)
 	/* Clear any outstanding interrupt. */
 	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
-	/* Set maximum receive buffer size. */
-	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
-
 	fec_enet_bd_init(ndev);
 
 	fec_enet_enable_ring(ndev);
-- 
1.7.8
