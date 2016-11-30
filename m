From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [patch net / RFC] net: fec: increase frame size limitation to
 actually available buffer
Date: Wed, 30 Nov 2016 02:37:50 +0000
Message-ID: <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        "Andrew Lunn" <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0075.outbound.protection.outlook.com ([104.47.2.75]:20370
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756148AbcK3KJU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 05:09:20 -0500
In-Reply-To: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com> Sent: Wednesday, =
November 30, 2016 2:35 AM
 >To: David S. Miller <davem@davemloft.net>; Andy Duan
 ><fugang.duan@nxp.com>; Troy Kisky <troy.kisky@boundarydevices.com>;
 >Andrew Lunn <andrew@lunn.ch>; Eric Nelson <eric@nelint.com>; Philippe
 >Reynes <tremyfr@gmail.com>; Johannes Berg <johannes@sipsolutions.net>;
 >netdev@vger.kernel.org
 >Cc: Chris Healy <cphealy@gmail.com>; Fabio Estevam
 ><fabio.estevam@nxp.com>; linux-kernel@vger.kernel.org; Nikita
 >Yushchenko <nikita.yoush@cogentembedded.com>
 >Subject: [patch net / RFC] net: fec: increase frame size limitation to ac=
tually
 >available buffer
 >
 >Fec driver uses Rx buffers of 2k, but programs hardware to limit incoming
 >frames to 1522 bytes. This raises issues when FEC device is used with DSA
 >(since DSA tag can make frame larger), and also disallows manual sending =
and
 >receiving larger frames.
 >
 >This patch removes the limitation, allowing Rx size up to entire buffer.
 >At the same time possible Tx size is increased as well, because hardware =
uses
 >the same register field to limit Rx and Tx.
 >
 >Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
 >---
 > drivers/net/ethernet/freescale/fec_main.c | 33 +++++++++++--------------=
--
 >----
 > 1 file changed, 12 insertions(+), 21 deletions(-)
 >
 >diff --git a/drivers/net/ethernet/freescale/fec_main.c
 >b/drivers/net/ethernet/freescale/fec_main.c
 >index 73ac35780611..c09789a71024 100644
 >--- a/drivers/net/ethernet/freescale/fec_main.c
 >+++ b/drivers/net/ethernet/freescale/fec_main.c
 >@@ -171,30 +171,12 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet
 >MAC address");  #endif  #endif /* CONFIG_M5272 */
 >
 >-/* The FEC stores dest/src/type/vlan, data, and checksum for receive
 >packets.
 >- */
 >-#define PKT_MAXBUF_SIZE		1522
 >-#define PKT_MINBUF_SIZE		64
 >-#define PKT_MAXBLR_SIZE		1536
 >-
 > /* FEC receive acceleration */
 > #define FEC_RACC_IPDIS		(1 << 1)
 > #define FEC_RACC_PRODIS		(1 << 2)
 > #define FEC_RACC_SHIFT16	BIT(7)
 > #define FEC_RACC_OPTIONS	(FEC_RACC_IPDIS | FEC_RACC_PRODIS)
 >
 >-/*
 >- * The 5270/5271/5280/5282/532x RX control register also contains maximu=
m
 >frame
 >- * size bits. Other FEC hardware does not, so we need to take that into
 >- * account when setting it.
 >- */
 >-#if defined(CONFIG_M523x) || defined(CONFIG_M527x) ||
 >defined(CONFIG_M528x) || \
 >-    defined(CONFIG_M520x) || defined(CONFIG_M532x) ||
 >defined(CONFIG_ARM)
 >-#define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
 >-#else
 >-#define	OPT_FRAME_SIZE	0
 >-#endif
 >-
 > /* FEC MII MMFR bits definition */
 > #define FEC_MMFR_ST		(1 << 30)
 > #define FEC_MMFR_OP_READ	(2 << 28)
 >@@ -847,7 +829,8 @@ static void fec_enet_enable_ring(struct net_device
 >*ndev)
 > 	for (i =3D 0; i < fep->num_rx_queues; i++) {
 > 		rxq =3D fep->rx_queue[i];
 > 		writel(rxq->bd.dma, fep->hwp + FEC_R_DES_START(i));
 >-		writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
 >+		writel(FEC_ENET_RX_FRSIZE - fep->rx_align,
 >+		       fep->hwp + FEC_R_BUFF_SIZE(i));
 >
 > 		/* enable DMA1/2 */
 > 		if (i)
 >@@ -895,9 +878,17 @@ fec_restart(struct net_device *ndev)
 > 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 > 	u32 val;
 > 	u32 temp_mac[2];
 >-	u32 rcntl =3D OPT_FRAME_SIZE | 0x04;
 >+	u32 rcntl =3D 0x04;
 > 	u32 ecntl =3D 0x2; /* ETHEREN */
 >
 >+	/* The 5270/5271/5280/5282/532x RX control register also contains
 >+	 * maximum frame * size bits. Other FEC hardware does not.
 >+	 */
 >+#if defined(CONFIG_M523x) || defined(CONFIG_M527x) ||
 >defined(CONFIG_M528x) || \
 >+    defined(CONFIG_M520x) || defined(CONFIG_M532x) ||
 >defined(CONFIG_ARM)
 >+	rcntl |=3D (FEC_ENET_RX_FRSIZE - fep->rx_align) << 16; #endif
 >+
 > 	/* Whack a reset.  We should wait for this.
 > 	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
 > 	 * instead of reset MAC itself.
 >@@ -953,7 +944,7 @@ fec_restart(struct net_device *ndev)
 > 		else
 > 			val &=3D ~FEC_RACC_OPTIONS;
 > 		writel(val, fep->hwp + FEC_RACC);
 >-		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
 >+		writel(FEC_ENET_RX_FRSIZE - fep->rx_align, fep->hwp +
 >FEC_FTRL);

By the patch itself, it seems fine except MRBRn must be evenly divisible by=
 64.
But I think it is not necessary since the driver don't support jumbo frame.

 > 	}
 > #endif
 >
 >--
 >2.1.4
