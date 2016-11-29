From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [patch net / RFC] net: fec: increase frame size limitation to actually available buffer
Date: Tue, 29 Nov 2016 21:35:28 +0300
Message-ID: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:33284 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbcK2Sfj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:35:39 -0500
Received: by mail-lf0-f41.google.com with SMTP id c13so128412986lfg.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:35:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fec driver uses Rx buffers of 2k, but programs hardware to limit
incoming frames to 1522 bytes. This raises issues when FEC device
is used with DSA (since DSA tag can make frame larger), and also
disallows manual sending and receiving larger frames.

This patch removes the limitation, allowing Rx size up to entire buffer.
At the same time possible Tx size is increased as well, because hardware
uses the same register field to limit Rx and Tx.

Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 33 +++++++++++--------------------
 1 file changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 73ac35780611..c09789a71024 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -171,30 +171,12 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #endif
 #endif /* CONFIG_M5272 */
 
-/* The FEC stores dest/src/type/vlan, data, and checksum for receive packets.
- */
-#define PKT_MAXBUF_SIZE		1522
-#define PKT_MINBUF_SIZE		64
-#define PKT_MAXBLR_SIZE		1536
-
 /* FEC receive acceleration */
 #define FEC_RACC_IPDIS		(1 << 1)
 #define FEC_RACC_PRODIS		(1 << 2)
 #define FEC_RACC_SHIFT16	BIT(7)
 #define FEC_RACC_OPTIONS	(FEC_RACC_IPDIS | FEC_RACC_PRODIS)
 
-/*
- * The 5270/5271/5280/5282/532x RX control register also contains maximum frame
- * size bits. Other FEC hardware does not, so we need to take that into
- * account when setting it.
- */
-#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
-#define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
-#else
-#define	OPT_FRAME_SIZE	0
-#endif
-
 /* FEC MII MMFR bits definition */
 #define FEC_MMFR_ST		(1 << 30)
 #define FEC_MMFR_OP_READ	(2 << 28)
@@ -847,7 +829,8 @@ static void fec_enet_enable_ring(struct net_device *ndev)
 	for (i = 0; i < fep->num_rx_queues; i++) {
 		rxq = fep->rx_queue[i];
 		writel(rxq->bd.dma, fep->hwp + FEC_R_DES_START(i));
-		writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
+		writel(FEC_ENET_RX_FRSIZE - fep->rx_align,
+		       fep->hwp + FEC_R_BUFF_SIZE(i));
 
 		/* enable DMA1/2 */
 		if (i)
@@ -895,9 +878,17 @@ fec_restart(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	u32 val;
 	u32 temp_mac[2];
-	u32 rcntl = OPT_FRAME_SIZE | 0x04;
+	u32 rcntl = 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
 
+	/* The 5270/5271/5280/5282/532x RX control register also contains
+	 * maximum frame * size bits. Other FEC hardware does not.
+	 */
+#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
+	rcntl |= (FEC_ENET_RX_FRSIZE - fep->rx_align) << 16;
+#endif
+
 	/* Whack a reset.  We should wait for this.
 	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
 	 * instead of reset MAC itself.
@@ -953,7 +944,7 @@ fec_restart(struct net_device *ndev)
 		else
 			val &= ~FEC_RACC_OPTIONS;
 		writel(val, fep->hwp + FEC_RACC);
-		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
+		writel(FEC_ENET_RX_FRSIZE - fep->rx_align, fep->hwp + FEC_FTRL);
 	}
 #endif
 
-- 
2.1.4
