From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: fec: Allow reception of frames bigger than 1522 bytes
Date: Sun, 30 Jul 2017 19:36:05 +0200
Message-ID: <1501436165-20259-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Fugang Duan <fugang.duan@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45136 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754193AbdG3Rge (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 13:36:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC Receive Control Register has a 14 bit field indicating the
longest frame that my be received. It is being set to 1522. Frames
longer than this are discarded, but counted as being in error.

When using DSA, frames from the switch has an additional header,
either 4 or 8 bytes if a Marvell switch is used. Thus a full MTU frame
of 1522 bytes received by the switch on a port becomes 1530 bytes when
passed to the host via the FEC interface.

Change the maximum receive size to 2048 - 64, where 64 is the maximum
rx_alignment applied on the receive buffer for AVB capable FEC
cores. Use this value also for the maximum receive buffer size. The
driver is already allocating a receive SKB of 2048 bytes, so this
change should not have any significant effects.

Tested on imx51, imx6, vf610.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a6e323f15637..47ee74a17a9f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -173,10 +173,12 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #endif /* CONFIG_M5272 */
 
 /* The FEC stores dest/src/type/vlan, data, and checksum for receive packets.
+ *
+ * 2048 byte skbufs are allocated. However, alignment requirements
+ * varies between FEC variants. Worst case is 64, so round down by 64.
  */
-#define PKT_MAXBUF_SIZE		1522
+#define PKT_MAXBUF_SIZE		(round_down(2048 - 64, 64))
 #define PKT_MINBUF_SIZE		64
-#define PKT_MAXBLR_SIZE		1536
 
 /* FEC receive acceleration */
 #define FEC_RACC_IPDIS		(1 << 1)
@@ -851,7 +853,7 @@ static void fec_enet_enable_ring(struct net_device *ndev)
 	for (i = 0; i < fep->num_rx_queues; i++) {
 		rxq = fep->rx_queue[i];
 		writel(rxq->bd.dma, fep->hwp + FEC_R_DES_START(i));
-		writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
+		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
 
 		/* enable DMA1/2 */
 		if (i)
-- 
2.13.2
