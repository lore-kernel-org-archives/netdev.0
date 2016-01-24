From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2] net: fec: make driver endian-safe
Date: Sun, 24 Jan 2016 16:52:37 +0100
Message-ID: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Cc: Greg Ungerer <gerg@uclinux.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Arnd Bergmann <arnd@arndb.de>, Shawn Guo <shawnguo@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55096 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbcAXPwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jan 2016 10:52:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver treats the device descriptors as CPU-endian, which appears
to be correct with the default endianness on both ARM (typically LE)
and PowerPC (typically BE) SoCs, indicating that the hardware block
is generated differently. Add endianness annotations and byteswaps as
necessary.

It's not clear that the ifdef there really is correct and shouldn't
just be #ifdef CONFIG_ARM, but I also can't test on anything but the
i.MX6 HummingBoard where this gets it working with a BE kernel.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/freescale/Makefile   |   3 +
 drivers/net/ethernet/freescale/fec.h      |  40 ++++++---
 drivers/net/ethernet/freescale/fec_main.c | 130 ++++++++++++++++--------------
 3 files changed, 101 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
index 71debd1c18c9..632adc2d7562 100644
--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -4,6 +4,9 @@
 
 obj-$(CONFIG_FEC) += fec.o
 fec-objs :=fec_main.o fec_ptp.o
+CFLAGS_fec_main.o := -D__CHECK_ENDIAN__
+CFLAGS_fec_ptp.o := -D__CHECK_ENDIAN__
+
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 99d33e2d35e6..7dd47a0b8cfb 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -190,28 +190,46 @@
 
 /*
  *	Define the buffer descriptor structure.
+ *
+ *	Evidently, ARM SoCs have the FEC block generated in a
+ *	little endian mode; or at least ARCH_MXC/SOC_IMX28 do,
+ *	so adjust endianness accordingly.
  */
 #if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+#define fec32_to_cpu le32_to_cpu
+#define fec16_to_cpu le16_to_cpu
+#define cpu_to_fec32 cpu_to_le32
+#define cpu_to_fec16 cpu_to_le16
+#define __fec32 __le32
+#define __fec16 __le16
+
 struct bufdesc {
-	unsigned short cbd_datlen;	/* Data length */
-	unsigned short cbd_sc;	/* Control and status info */
-	unsigned long cbd_bufaddr;	/* Buffer address */
+	__fec16 cbd_datlen;	/* Data length */
+	__fec16 cbd_sc;		/* Control and status info */
+	__fec32 cbd_bufaddr;	/* Buffer address */
 };
 #else
+#define fec32_to_cpu be32_to_cpu
+#define fec16_to_cpu be16_to_cpu
+#define cpu_to_fec32 cpu_to_be32
+#define cpu_to_fec16 cpu_to_be16
+#define __fec32 __be32
+#define __fec16 __be16
+
 struct bufdesc {
-	unsigned short	cbd_sc;			/* Control and status info */
-	unsigned short	cbd_datlen;		/* Data length */
-	unsigned long	cbd_bufaddr;		/* Buffer address */
+	__fec16	cbd_sc;		/* Control and status info */
+	__fec16	cbd_datlen;	/* Data length */
+	__fec32	cbd_bufaddr;	/* Buffer address */
 };
 #endif
 
 struct bufdesc_ex {
 	struct bufdesc desc;
-	unsigned long cbd_esc;
-	unsigned long cbd_prot;
-	unsigned long cbd_bdu;
-	unsigned long ts;
-	unsigned short res0[4];
+	__fec32 cbd_esc;
+	__fec32 cbd_prot;
+	__fec32 cbd_bdu;
+	__fec32 ts;
+	__fec16 res0[4];
 };
 
 /*
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2a32209ffbf..a055fbad1253 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -331,11 +331,13 @@ static void fec_dump(struct net_device *ndev)
 	bdp = txq->tx_bd_base;
 
 	do {
-		pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
+		pr_info("%3u %c%c 0x%04x 0x%08x %4u %p\n",
 			index,
 			bdp == txq->cur_tx ? 'S' : ' ',
 			bdp == txq->dirty_tx ? 'H' : ' ',
-			bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
+			fec16_to_cpu(bdp->cbd_sc),
+			fec32_to_cpu(bdp->cbd_bufaddr),
+			fec16_to_cpu(bdp->cbd_datlen),
 			txq->tx_skbuff[index]);
 		bdp = fec_enet_get_nextdesc(bdp, fep, 0);
 		index++;
@@ -388,7 +390,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
 		ebdp = (struct bufdesc_ex *)bdp;
 
-		status = bdp->cbd_sc;
+		status = fec16_to_cpu(bdp->cbd_sc);
 		status &= ~BD_ENET_TX_STATS;
 		status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
 		frag_len = skb_shinfo(skb)->frags[frag].size;
@@ -410,7 +412,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 			ebdp->cbd_bdu = 0;
-			ebdp->cbd_esc = estatus;
+			ebdp->cbd_esc = cpu_to_fec32(estatus);
 		}
 
 		bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
@@ -434,9 +436,9 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 			goto dma_mapping_error;
 		}
 
-		bdp->cbd_bufaddr = addr;
-		bdp->cbd_datlen = frag_len;
-		bdp->cbd_sc = status;
+		bdp->cbd_bufaddr = cpu_to_fec32(addr);
+		bdp->cbd_datlen = cpu_to_fec16(frag_len);
+		bdp->cbd_sc = cpu_to_fec16(status);
 	}
 
 	return bdp;
@@ -444,8 +446,8 @@ dma_mapping_error:
 	bdp = txq->cur_tx;
 	for (i = 0; i < frag; i++) {
 		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-				bdp->cbd_datlen, DMA_TO_DEVICE);
+		dma_unmap_single(&fep->pdev->dev, fec32_to_cpu(bdp->cbd_bufaddr),
+				 fec16_to_cpu(bdp->cbd_datlen), DMA_TO_DEVICE);
 	}
 	return ERR_PTR(-ENOMEM);
 }
@@ -482,7 +484,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	/* Fill in a Tx ring entry */
 	bdp = txq->cur_tx;
 	last_bdp = bdp;
-	status = bdp->cbd_sc;
+	status = fec16_to_cpu(bdp->cbd_sc);
 	status &= ~BD_ENET_TX_STATS;
 
 	/* Set buffer length and buffer pointer */
@@ -538,21 +540,21 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 
 		ebdp->cbd_bdu = 0;
-		ebdp->cbd_esc = estatus;
+		ebdp->cbd_esc = cpu_to_fec32(estatus);
 	}
 
 	index = fec_enet_get_bd_index(txq->tx_bd_base, last_bdp, fep);
 	/* Save skb pointer */
 	txq->tx_skbuff[index] = skb;
 
-	bdp->cbd_datlen = buflen;
-	bdp->cbd_bufaddr = addr;
+	bdp->cbd_datlen = cpu_to_fec16(buflen);
+	bdp->cbd_bufaddr = cpu_to_fec32(addr);
 
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
 	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);
-	bdp->cbd_sc = status;
+	bdp->cbd_sc = cpu_to_fec16(status);
 
 	/* If this was the last BD in the ring, start at the beginning again. */
 	bdp = fec_enet_get_nextdesc(last_bdp, fep, queue);
@@ -584,7 +586,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	unsigned int estatus = 0;
 	dma_addr_t addr;
 
-	status = bdp->cbd_sc;
+	status = fec16_to_cpu(bdp->cbd_sc);
 	status &= ~BD_ENET_TX_STATS;
 
 	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
@@ -606,8 +608,8 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	bdp->cbd_datlen = size;
-	bdp->cbd_bufaddr = addr;
+	bdp->cbd_datlen = cpu_to_fec16(size);
+	bdp->cbd_bufaddr = cpu_to_fec32(addr);
 
 	if (fep->bufdesc_ex) {
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
@@ -615,7 +617,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
-		ebdp->cbd_esc = estatus;
+		ebdp->cbd_esc = cpu_to_fec32(estatus);
 	}
 
 	/* Handle the last BD specially */
@@ -624,10 +626,10 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	if (is_last) {
 		status |= BD_ENET_TX_INTR;
 		if (fep->bufdesc_ex)
-			ebdp->cbd_esc |= BD_ENET_TX_INT;
+			ebdp->cbd_esc |= cpu_to_fec32(BD_ENET_TX_INT);
 	}
 
-	bdp->cbd_sc = status;
+	bdp->cbd_sc = cpu_to_fec16(status);
 
 	return 0;
 }
@@ -646,7 +648,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	unsigned short status;
 	unsigned int estatus = 0;
 
-	status = bdp->cbd_sc;
+	status = fec16_to_cpu(bdp->cbd_sc);
 	status &= ~BD_ENET_TX_STATS;
 	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
 
@@ -670,8 +672,8 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 		}
 	}
 
-	bdp->cbd_bufaddr = dmabuf;
-	bdp->cbd_datlen = hdr_len;
+	bdp->cbd_bufaddr = cpu_to_fec32(dmabuf);
+	bdp->cbd_datlen = cpu_to_fec16(hdr_len);
 
 	if (fep->bufdesc_ex) {
 		if (fep->quirks & FEC_QUIRK_HAS_AVB)
@@ -679,10 +681,10 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
-		ebdp->cbd_esc = estatus;
+		ebdp->cbd_esc = cpu_to_fec32(estatus);
 	}
 
-	bdp->cbd_sc = status;
+	bdp->cbd_sc = cpu_to_fec16(status);
 
 	return 0;
 }
@@ -822,15 +824,15 @@ static void fec_enet_bd_init(struct net_device *dev)
 
 			/* Initialize the BD for every fragment in the page. */
 			if (bdp->cbd_bufaddr)
-				bdp->cbd_sc = BD_ENET_RX_EMPTY;
+				bdp->cbd_sc = cpu_to_fec16(BD_ENET_RX_EMPTY);
 			else
-				bdp->cbd_sc = 0;
+				bdp->cbd_sc = cpu_to_fec16(0);
 			bdp = fec_enet_get_nextdesc(bdp, fep, q);
 		}
 
 		/* Set the last buffer to wrap */
 		bdp = fec_enet_get_prevdesc(bdp, fep, q);
-		bdp->cbd_sc |= BD_SC_WRAP;
+		bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
 
 		rxq->cur_rx = rxq->rx_bd_base;
 	}
@@ -843,18 +845,18 @@ static void fec_enet_bd_init(struct net_device *dev)
 
 		for (i = 0; i < txq->tx_ring_size; i++) {
 			/* Initialize the BD for every fragment in the page. */
-			bdp->cbd_sc = 0;
+			bdp->cbd_sc = cpu_to_fec16(0);
 			if (txq->tx_skbuff[i]) {
 				dev_kfree_skb_any(txq->tx_skbuff[i]);
 				txq->tx_skbuff[i] = NULL;
 			}
-			bdp->cbd_bufaddr = 0;
+			bdp->cbd_bufaddr = cpu_to_fec32(0);
 			bdp = fec_enet_get_nextdesc(bdp, fep, q);
 		}
 
 		/* Set the last buffer to wrap */
 		bdp = fec_enet_get_prevdesc(bdp, fep, q);
-		bdp->cbd_sc |= BD_SC_WRAP;
+		bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
 		txq->dirty_tx = bdp;
 	}
 }
@@ -946,8 +948,10 @@ fec_restart(struct net_device *ndev)
 	 */
 	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
 		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
-		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
-		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
+		writel((__force u32)cpu_to_be32(temp_mac[0]),
+		       fep->hwp + FEC_ADDR_LOW);
+		writel((__force u32)cpu_to_be32(temp_mac[1]),
+		       fep->hwp + FEC_ADDR_HIGH);
 	}
 
 	/* Clear any outstanding interrupt. */
@@ -1221,7 +1225,7 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 	while (bdp != READ_ONCE(txq->cur_tx)) {
 		/* Order the load of cur_tx and cbd_sc */
 		rmb();
-		status = READ_ONCE(bdp->cbd_sc);
+		status = fec16_to_cpu(READ_ONCE(bdp->cbd_sc));
 		if (status & BD_ENET_TX_READY)
 			break;
 
@@ -1229,10 +1233,12 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 
 		skb = txq->tx_skbuff[index];
 		txq->tx_skbuff[index] = NULL;
-		if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
-			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-					bdp->cbd_datlen, DMA_TO_DEVICE);
-		bdp->cbd_bufaddr = 0;
+		if (!IS_TSO_HEADER(txq, fec32_to_cpu(bdp->cbd_bufaddr)))
+			dma_unmap_single(&fep->pdev->dev,
+					 fec32_to_cpu(bdp->cbd_bufaddr),
+					 fec16_to_cpu(bdp->cbd_datlen),
+					 DMA_TO_DEVICE);
+		bdp->cbd_bufaddr = cpu_to_fec32(0);
 		if (!skb) {
 			bdp = fec_enet_get_nextdesc(bdp, fep, queue_id);
 			continue;
@@ -1263,7 +1269,7 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 			struct skb_shared_hwtstamps shhwtstamps;
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
 
-			fec_enet_hwtstamp(fep, ebdp->ts, &shhwtstamps);
+			fec_enet_hwtstamp(fep, fec32_to_cpu(ebdp->ts), &shhwtstamps);
 			skb_tstamp_tx(skb, &shhwtstamps);
 		}
 
@@ -1323,10 +1329,8 @@ fec_enet_new_rxbdp(struct net_device *ndev, struct bufdesc *bdp, struct sk_buff
 	if (off)
 		skb_reserve(skb, fep->rx_align + 1 - off);
 
-	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
-					  FEC_ENET_RX_FRSIZE - fep->rx_align,
-					  DMA_FROM_DEVICE);
-	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+	bdp->cbd_bufaddr = cpu_to_fec32(dma_map_single(&fep->pdev->dev, skb->data, FEC_ENET_RX_FRSIZE - fep->rx_align, DMA_FROM_DEVICE));
+	if (dma_mapping_error(&fep->pdev->dev, fec32_to_cpu(bdp->cbd_bufaddr))) {
 		if (net_ratelimit())
 			netdev_err(ndev, "Rx DMA memory map failed\n");
 		return -ENOMEM;
@@ -1348,7 +1352,8 @@ static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff **skb,
 	if (!new_skb)
 		return false;
 
-	dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
+	dma_sync_single_for_cpu(&fep->pdev->dev,
+				fec32_to_cpu(bdp->cbd_bufaddr),
 				FEC_ENET_RX_FRSIZE - fep->rx_align,
 				DMA_FROM_DEVICE);
 	if (!swap)
@@ -1395,7 +1400,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 	 */
 	bdp = rxq->cur_rx;
 
-	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
+	while (!((status = fec16_to_cpu(bdp->cbd_sc)) & BD_ENET_RX_EMPTY)) {
 
 		if (pkt_received >= budget)
 			break;
@@ -1437,7 +1442,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 
 		/* Process the incoming frame. */
 		ndev->stats.rx_packets++;
-		pkt_len = bdp->cbd_datlen;
+		pkt_len = fec16_to_cpu(bdp->cbd_datlen);
 		ndev->stats.rx_bytes += pkt_len;
 
 		index = fec_enet_get_bd_index(rxq->rx_bd_base, bdp, fep);
@@ -1455,7 +1460,8 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 				ndev->stats.rx_dropped++;
 				goto rx_processing_done;
 			}
-			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+			dma_unmap_single(&fep->pdev->dev,
+					 fec32_to_cpu(bdp->cbd_bufaddr),
 					 FEC_ENET_RX_FRSIZE - fep->rx_align,
 					 DMA_FROM_DEVICE);
 		}
@@ -1474,7 +1480,8 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		/* If this is a VLAN packet remove the VLAN Tag */
 		vlan_packet_rcvd = false;
 		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
-			fep->bufdesc_ex && (ebdp->cbd_esc & BD_ENET_RX_VLAN)) {
+		    fep->bufdesc_ex &&
+		    (ebdp->cbd_esc & cpu_to_fec32(BD_ENET_RX_VLAN))) {
 			/* Push and remove the vlan tag */
 			struct vlan_hdr *vlan_header =
 					(struct vlan_hdr *) (data + ETH_HLEN);
@@ -1490,12 +1497,12 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 
 		/* Get receive timestamp from the skb */
 		if (fep->hwts_rx_en && fep->bufdesc_ex)
-			fec_enet_hwtstamp(fep, ebdp->ts,
+			fec_enet_hwtstamp(fep, fec32_to_cpu(ebdp->ts),
 					  skb_hwtstamps(skb));
 
 		if (fep->bufdesc_ex &&
 		    (fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
-			if (!(ebdp->cbd_esc & FLAG_RX_CSUM_ERROR)) {
+			if (!(ebdp->cbd_esc & cpu_to_fec32(FLAG_RX_CSUM_ERROR))) {
 				/* don't check it */
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
@@ -1512,7 +1519,8 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		napi_gro_receive(&fep->napi, skb);
 
 		if (is_copybreak) {
-			dma_sync_single_for_device(&fep->pdev->dev, bdp->cbd_bufaddr,
+			dma_sync_single_for_device(&fep->pdev->dev,
+						   fec32_to_cpu(bdp->cbd_bufaddr),
 						   FEC_ENET_RX_FRSIZE - fep->rx_align,
 						   DMA_FROM_DEVICE);
 		} else {
@@ -1526,12 +1534,12 @@ rx_processing_done:
 
 		/* Mark the buffer empty */
 		status |= BD_ENET_RX_EMPTY;
-		bdp->cbd_sc = status;
+		bdp->cbd_sc = cpu_to_fec16(status);
 
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
 
-			ebdp->cbd_esc = BD_ENET_RX_INT;
+			ebdp->cbd_esc = cpu_to_fec32(BD_ENET_RX_INT);
 			ebdp->cbd_prot = 0;
 			ebdp->cbd_bdu = 0;
 		}
@@ -2679,7 +2687,7 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 			rxq->rx_skbuff[i] = NULL;
 			if (skb) {
 				dma_unmap_single(&fep->pdev->dev,
-						 bdp->cbd_bufaddr,
+						 fec32_to_cpu(bdp->cbd_bufaddr),
 						 FEC_ENET_RX_FRSIZE - fep->rx_align,
 						 DMA_FROM_DEVICE);
 				dev_kfree_skb(skb);
@@ -2794,11 +2802,11 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 		}
 
 		rxq->rx_skbuff[i] = skb;
-		bdp->cbd_sc = BD_ENET_RX_EMPTY;
+		bdp->cbd_sc = cpu_to_fec16(BD_ENET_RX_EMPTY);
 
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
-			ebdp->cbd_esc = BD_ENET_RX_INT;
+			ebdp->cbd_esc = cpu_to_fec32(BD_ENET_RX_INT);
 		}
 
 		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
@@ -2806,7 +2814,7 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 
 	/* Set the last buffer to wrap. */
 	bdp = fec_enet_get_prevdesc(bdp, fep, queue);
-	bdp->cbd_sc |= BD_SC_WRAP;
+	bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
 	return 0;
 
  err_alloc:
@@ -2829,12 +2837,12 @@ fec_enet_alloc_txq_buffers(struct net_device *ndev, unsigned int queue)
 		if (!txq->tx_bounce[i])
 			goto err_alloc;
 
-		bdp->cbd_sc = 0;
-		bdp->cbd_bufaddr = 0;
+		bdp->cbd_sc = cpu_to_fec16(0);
+		bdp->cbd_bufaddr = cpu_to_fec32(0);
 
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
-			ebdp->cbd_esc = BD_ENET_TX_INT;
+			ebdp->cbd_esc = cpu_to_fec32(BD_ENET_TX_INT);
 		}
 
 		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
@@ -2842,7 +2850,7 @@ fec_enet_alloc_txq_buffers(struct net_device *ndev, unsigned int queue)
 
 	/* Set the last buffer to wrap. */
 	bdp = fec_enet_get_prevdesc(bdp, fep, queue);
-	bdp->cbd_sc |= BD_SC_WRAP;
+	bdp->cbd_sc |= cpu_to_fec16(BD_SC_WRAP);
 
 	return 0;
 
-- 
2.6.2
