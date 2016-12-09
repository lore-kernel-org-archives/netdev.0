From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [PATCH/RFC net-next] net: fec: allow "mini jumbo" frames
Date: Fri,  9 Dec 2016 12:20:55 +0300
Message-ID: <1481275255-7650-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: Fugang Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds support for MTU slightly larger than default, on modern
FEC flavours.

Currently FEC driver uses single hardware Rx buffer per frame. On most
FEC flavours, size of single buffer is limited by 11-bit field, and
has to be multiple of 64 (in the worst case). Thus maximum usable Rx
buffer size is 1984 bytes.

Of those:
- 2 bytes are used for IP header alignment,
- 14 bytes are used by ethhdr,
- up to 8 bytes are needed for VLAN and/or DSA tags,
- 4 bytes are needed for CRC.

Thus maximum MTU possible within current RX architecture is 1956.

This patch allows exactly that. For further increase, Rx architecture
change is needed.

Use of MTU=1956 gives about 1.5% throughput improvement between two Vybrid
boards, compared to default MTU=1500.

Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
---
 drivers/net/ethernet/freescale/fec.h      |  2 +
 drivers/net/ethernet/freescale/fec_main.c | 69 ++++++++++++++++++++-----------
 2 files changed, 47 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 5ea740b4cf14..72c918bd10f3 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -557,6 +557,8 @@ struct fec_enet_private {
 	unsigned int tx_align;
 	unsigned int rx_align;
 
+	unsigned int max_fl;
+
 	/* hw interrupt coalesce */
 	unsigned int rx_pkts_itr;
 	unsigned int rx_time_itr;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 38160c2bebcb..6a299a4d75ed 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -171,29 +171,20 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
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
+/* Difference between buffer size and MTU.
+ * This accounts:
+ * - possible 2 byte alignment,
+ * - standard ethernet header,
+ * - up to 8 bytes of VLAN or DSA tags,
+ * - checksum
  */
-#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
-#define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
-#else
-#define	OPT_FRAME_SIZE	0
-#endif
+#define FEC_BUFFER_OVERHEAD	(2 + ETH_HLEN + 8 + ETH_FCS_LEN)
 
 /* FEC MII MMFR bits definition */
 #define FEC_MMFR_ST		(1 << 30)
@@ -847,7 +838,7 @@ static void fec_enet_enable_ring(struct net_device *ndev)
 	for (i = 0; i < fep->num_rx_queues; i++) {
 		rxq = fep->rx_queue[i];
 		writel(rxq->bd.dma, fep->hwp + FEC_R_DES_START(i));
-		writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
+		writel(fep->max_fl, fep->hwp + FEC_R_BUFF_SIZE(i));
 
 		/* enable DMA1/2 */
 		if (i)
@@ -895,8 +886,18 @@ fec_restart(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	u32 val;
 	u32 temp_mac[2];
-	u32 rcntl = OPT_FRAME_SIZE | 0x04;
+	u32 rcntl = 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
+/*
+ * The 5270/5271/5280/5282/532x RX control register also contains maximum frame
+ * size bits. Other FEC hardware does not, so we need to take that into
+ * account when setting it.
+ */
+#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
+	rcntl |= (fep->max_fl << 16);
+#endif
+
 
 	/* Whack a reset.  We should wait for this.
 	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
@@ -953,7 +954,7 @@ fec_restart(struct net_device *ndev)
 		else
 			val &= ~FEC_RACC_OPTIONS;
 		writel(val, fep->hwp + FEC_RACC);
-		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
+		writel(fep->max_fl, fep->hwp + FEC_FTRL);
 	}
 #endif
 
@@ -1295,7 +1296,10 @@ fec_enet_new_rxbdp(struct net_device *ndev, struct bufdesc *bdp, struct sk_buff
 	if (off)
 		skb_reserve(skb, fep->rx_align + 1 - off);
 
-	bdp->cbd_bufaddr = cpu_to_fec32(dma_map_single(&fep->pdev->dev, skb->data, FEC_ENET_RX_FRSIZE - fep->rx_align, DMA_FROM_DEVICE));
+	bdp->cbd_bufaddr = cpu_to_fec32(dma_map_single(&fep->pdev->dev,
+						       skb->data,
+						       fep->max_fl,
+						       DMA_FROM_DEVICE));
 	if (dma_mapping_error(&fep->pdev->dev, fec32_to_cpu(bdp->cbd_bufaddr))) {
 		if (net_ratelimit())
 			netdev_err(ndev, "Rx DMA memory map failed\n");
@@ -1320,7 +1324,7 @@ static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff **skb,
 
 	dma_sync_single_for_cpu(&fep->pdev->dev,
 				fec32_to_cpu(bdp->cbd_bufaddr),
-				FEC_ENET_RX_FRSIZE - fep->rx_align,
+				fep->max_fl,
 				DMA_FROM_DEVICE);
 	if (!swap)
 		memcpy(new_skb->data, (*skb)->data, length);
@@ -1422,7 +1426,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 			}
 			dma_unmap_single(&fep->pdev->dev,
 					 fec32_to_cpu(bdp->cbd_bufaddr),
-					 FEC_ENET_RX_FRSIZE - fep->rx_align,
+					 fep->max_fl,
 					 DMA_FROM_DEVICE);
 		}
 
@@ -1487,7 +1491,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		if (is_copybreak) {
 			dma_sync_single_for_device(&fep->pdev->dev,
 						   fec32_to_cpu(bdp->cbd_bufaddr),
-						   FEC_ENET_RX_FRSIZE - fep->rx_align,
+						   fep->max_fl,
 						   DMA_FROM_DEVICE);
 		} else {
 			rxq->rx_skbuff[index] = skb_new;
@@ -2621,7 +2625,7 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 			if (skb) {
 				dma_unmap_single(&fep->pdev->dev,
 						 fec32_to_cpu(bdp->cbd_bufaddr),
-						 FEC_ENET_RX_FRSIZE - fep->rx_align,
+						 fep->max_fl,
 						 DMA_FROM_DEVICE);
 				dev_kfree_skb(skb);
 			}
@@ -3182,6 +3186,23 @@ static int fec_enet_init(struct net_device *ndev)
 		fep->rx_align = 0x3f;
 	}
 
+	/* For ENET_MAC case, allow frames up to space available in Rx buffer
+	 * - buffer size is FEC_ENET_RX_FRSIZE,
+	 * - up to (fep->rx_aligned) might be eaten by alignment
+	 * - since single buffer per frame is used, R_BUF_SIZE must be not
+	 *   less than maximum frame size, and at the same time R_BUF_SIZE
+	 *   has to be evenly dividable by 64 [on IMX7 FEC, older FECs have
+	 *   looser constraints]
+	 *
+	 * For !ENET_MAC case, keep standard frame sizes because effect of
+	 * larger frames on small FIFO is unclear.
+	 */
+	if (fep->quirks & FEC_QUIRK_ENET_MAC)
+		fep->max_fl = (FEC_ENET_RX_FRSIZE - fep->rx_align) & ~63;
+	else
+		fep->max_fl = 1536;	/* >1522 and dividable by 16 */
+	ndev->max_mtu = fep->max_fl - FEC_BUFFER_OVERHEAD;
+
 	ndev->hw_features = ndev->features;
 
 	fec_restart(ndev);
-- 
2.1.4
