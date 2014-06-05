From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v3 5/6] net: fec: Add Scatter/gather support
Date: Thu, 5 Jun 2014 14:59:31 +0800
Message-ID: <1401951572-6538-6-git-send-email-b38611@freescale.com>
References: <1401951572-6538-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>, <R49496@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0190.outbound.protection.outlook.com ([207.46.163.190]:34501
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751799AbaFEIXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 04:23:21 -0400
In-Reply-To: <1401951572-6538-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Scatter/gather support for FEC.
This feature allows to improve outbound throughput performance.

Tested on imx6dl sabresd board:
Running iperf tests shows a 55.4% improvement.

$ ethtool -K eth0 sg off
$ iperf -c 10.192.242.167 -t 3 &
[  3] local 10.192.242.108 port 52618 connected with 10.192.242.167 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec  99.5 MBytes   278 Mbits/sec

$ ethtool -K eth0 sg on
$ iperf -c 10.192.242.167 -t 3 &
[  3] local 10.192.242.108 port 52617 connected with 10.192.242.167 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec   154 MBytes   432 Mbits/sec

CC: Li Frank <B20596@freescale.com>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    2 +-
 drivers/net/ethernet/freescale/fec_main.c |  245 ++++++++++++++++++++++-------
 2 files changed, 185 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 241621d..b3de6cfa 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -221,7 +221,7 @@ struct bufdesc_ex {
 #define BD_ENET_TX_RCMASK       ((ushort)0x003c)
 #define BD_ENET_TX_UN           ((ushort)0x0002)
 #define BD_ENET_TX_CSL          ((ushort)0x0001)
-#define BD_ENET_TX_STATS        ((ushort)0x03ff)        /* All status bits */
+#define BD_ENET_TX_STATS        ((ushort)0x0fff)        /* All status bits */
 
 /*enhanced buffer descriptor control/status used by Ethernet transmit*/
 #define BD_ENET_TX_INT          0x40000000
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9de1660..0ce8de6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -302,6 +302,23 @@ int fec_enet_get_bd_index(struct bufdesc *bdp, struct fec_enet_private *fep)
 	return index;
 }
 
+static inline
+int fec_enet_get_free_txdesc_num(struct fec_enet_private *fep)
+{
+	int entries;
+
+	if (fep->bufdesc_ex)
+		entries = (struct bufdesc_ex *)fep->dirty_tx -
+				(struct bufdesc_ex *)fep->cur_tx;
+	else
+		entries = fep->dirty_tx - fep->cur_tx;
+
+	if (fep->cur_tx >= fep->dirty_tx)
+		entries += fep->tx_ring_size;
+
+	return entries;
+}
+
 static void *swap_buffer(void *bufaddr, int len)
 {
 	int i;
@@ -329,20 +346,119 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
-static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
+static void
+fec_enet_submit_work(struct bufdesc *bdp, struct fec_enet_private *fep)
+{
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+	struct bufdesc *bdp_pre;
+
+	bdp_pre = fec_enet_get_prevdesc(bdp, fep);
+	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
+	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
+		fep->delay_work.trig_tx = true;
+		schedule_delayed_work(&(fep->delay_work.delay_work),
+					msecs_to_jiffies(1));
+	}
+}
+
+static int
+fec_enet_txq_submit_frag_skb(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
-	struct bufdesc *bdp, *bdp_pre;
-	void *bufaddr;
-	unsigned short	status;
+	struct bufdesc *bdp = fep->cur_tx;
+	struct bufdesc_ex *ebdp;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int frag, frag_len;
+	unsigned short status;
+	unsigned int estatus = 0;
+	skb_frag_t *this_frag;
 	unsigned int index;
+	void *bufaddr;
+	int i;
 
-	/* Fill in a Tx ring entry */
+	for (frag = 0; frag < nr_frags; frag++) {
+		this_frag = &skb_shinfo(skb)->frags[frag];
+		bdp = fec_enet_get_nextdesc(bdp, fep);
+		ebdp = (struct bufdesc_ex *)bdp;
+
+		status = bdp->cbd_sc;
+		status &= ~BD_ENET_TX_STATS;
+		status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
+		frag_len = skb_shinfo(skb)->frags[frag].size;
+
+		/* Handle the last BD specially */
+		if (frag == nr_frags - 1) {
+			status |= (BD_ENET_TX_INTR | BD_ENET_TX_LAST);
+			if (fep->bufdesc_ex) {
+				estatus |= BD_ENET_TX_INT;
+				if (unlikely(skb_shinfo(skb)->tx_flags &
+					SKBTX_HW_TSTAMP && fep->hwts_tx_en))
+					estatus |= BD_ENET_TX_TS;
+			}
+		}
+
+		if (fep->bufdesc_ex) {
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
+				estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+			ebdp->cbd_bdu = 0;
+			ebdp->cbd_esc = estatus;
+		}
+
+		bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
+
+		index = fec_enet_get_bd_index(bdp, fep);
+		if (((unsigned long) bufaddr) & FEC_ALIGNMENT ||
+			id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+			memcpy(fep->tx_bounce[index], bufaddr, frag_len);
+			bufaddr = fep->tx_bounce[index];
+
+			if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+				swap_buffer(bufaddr, frag_len);
+		}
+
+		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
+						frag_len, DMA_TO_DEVICE);
+		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+			dev_kfree_skb_any(skb);
+			if (net_ratelimit())
+				netdev_err(ndev, "Tx DMA memory map failed\n");
+			goto dma_mapping_error;
+		}
+
+		bdp->cbd_datlen = frag_len;
+		bdp->cbd_sc = status;
+	}
+
+	fep->cur_tx = bdp;
+
+	return 0;
+
+dma_mapping_error:
 	bdp = fep->cur_tx;
+	for (i = 0; i < frag; i++) {
+		bdp = fec_enet_get_nextdesc(bdp, fep);
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+				bdp->cbd_datlen, DMA_TO_DEVICE);
+	}
+	return NETDEV_TX_OK;
+}
 
-	status = bdp->cbd_sc;
+static int fec_enet_txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	struct bufdesc *bdp, *last_bdp;
+	void *bufaddr;
+	unsigned short status;
+	unsigned short buflen;
+	unsigned int estatus = 0;
+	unsigned int index;
+	int ret;
 
 	/* Protocol checksum off-load for TCP and UDP. */
 	if (fec_enet_clear_csum(skb, ndev)) {
@@ -350,82 +466,83 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_OK;
 	}
 
-	/* Clear all of the status flags */
+	/* Fill in a Tx ring entry */
+	bdp = fep->cur_tx;
+	status = bdp->cbd_sc;
 	status &= ~BD_ENET_TX_STATS;
 
 	/* Set buffer length and buffer pointer */
 	bufaddr = skb->data;
-	bdp->cbd_datlen = skb->len;
+	buflen = skb_headlen(skb);
 
 	index = fec_enet_get_bd_index(bdp, fep);
-
-	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
-		memcpy(fep->tx_bounce[index], skb->data, skb->len);
+	if (((unsigned long) bufaddr) & FEC_ALIGNMENT ||
+		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+		memcpy(fep->tx_bounce[index], skb->data, buflen);
 		bufaddr = fep->tx_bounce[index];
-	}
-
-	/*
-	 * Some design made an incorrect assumption on endian mode of
-	 * the system that it's running on. As the result, driver has to
-	 * swap every frame going to and coming from the controller.
-	 */
-	if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
-		swap_buffer(bufaddr, skb->len);
 
-	/* Save skb pointer */
-	fep->tx_skbuff[index] = skb;
+		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+			swap_buffer(bufaddr, buflen);
+	}
 
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
 	 */
 	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
-			skb->len, DMA_TO_DEVICE);
+					buflen, DMA_TO_DEVICE);
 	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
-		bdp->cbd_bufaddr = 0;
-		fep->tx_skbuff[index] = NULL;
 		dev_kfree_skb_any(skb);
 		if (net_ratelimit())
 			netdev_err(ndev, "Tx DMA memory map failed\n");
 		return NETDEV_TX_OK;
 	}
 
+	if (nr_frags) {
+		ret = fec_enet_txq_submit_frag_skb(skb, ndev);
+		if (ret)
+			return ret;
+	} else {
+		status |= (BD_ENET_TX_INTR | BD_ENET_TX_LAST);
+		if (fep->bufdesc_ex) {
+			estatus = BD_ENET_TX_INT;
+			if (unlikely(skb_shinfo(skb)->tx_flags &
+				SKBTX_HW_TSTAMP && fep->hwts_tx_en))
+				estatus |= BD_ENET_TX_TS;
+		}
+	}
+
 	if (fep->bufdesc_ex) {
 
 		struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
-		ebdp->cbd_bdu = 0;
+
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-			fep->hwts_tx_en)) {
-			ebdp->cbd_esc = (BD_ENET_TX_TS | BD_ENET_TX_INT);
+			fep->hwts_tx_en))
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		} else {
-			ebdp->cbd_esc = BD_ENET_TX_INT;
 
-			/* Enable protocol checksum flags
-			 * We do not bother with the IP Checksum bits as they
-			 * are done by the kernel
-			 */
-			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				ebdp->cbd_esc |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
-		}
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
+
+		ebdp->cbd_bdu = 0;
+		ebdp->cbd_esc = estatus;
 	}
 
+	last_bdp = fep->cur_tx;
+	index = fec_enet_get_bd_index(last_bdp, fep);
+	/* Save skb pointer */
+	fep->tx_skbuff[index] = skb;
+
+	bdp->cbd_datlen = buflen;
+
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
-	status |= (BD_ENET_TX_READY | BD_ENET_TX_INTR
-			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
+	status |= (BD_ENET_TX_READY | BD_ENET_TX_TC);
 	bdp->cbd_sc = status;
 
-	bdp_pre = fec_enet_get_prevdesc(bdp, fep);
-	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
-	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
-		fep->delay_work.trig_tx = true;
-		schedule_delayed_work(&(fep->delay_work.delay_work),
-					msecs_to_jiffies(1));
-	}
+	fec_enet_submit_work(bdp, fep);
 
 	/* If this was the last BD in the ring, start at the beginning again. */
-	bdp = fec_enet_get_nextdesc(bdp, fep);
+	bdp = fec_enet_get_nextdesc(last_bdp, fep);
 
 	skb_tx_timestamp(skb);
 
@@ -434,7 +551,7 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
-	return NETDEV_TX_OK;
+	return 0;
 }
 
 static netdev_tx_t
@@ -443,6 +560,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct bufdesc *bdp;
 	unsigned short	status;
+	int entries_free;
 	int ret;
 
 	/* Fill in a Tx ring entry */
@@ -454,15 +572,17 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		/* Ooops.  All transmit buffers are full.  Bail out.
 		 * This should not happen, since ndev->tbusy should be set.
 		 */
-		netdev_err(ndev, "tx queue full!\n");
+		if (net_ratelimit())
+			netdev_err(ndev, "tx queue full!\n");
 		return NETDEV_TX_BUSY;
 	}
 
-	ret = txq_submit_skb(skb, ndev);
-	if (ret == -EBUSY)
-		return NETDEV_TX_BUSY;
+	ret = fec_enet_txq_submit_skb(skb, ndev);
+	if (ret)
+		return ret;
 
-	if (fep->cur_tx == fep->dirty_tx)
+	entries_free = fec_enet_get_free_txdesc_num(fep);
+	if (entries_free < MAX_SKB_FRAGS + 1)
 		netif_stop_queue(ndev);
 
 	return NETDEV_TX_OK;
@@ -783,6 +903,7 @@ fec_enet_tx(struct net_device *ndev)
 	unsigned short status;
 	struct	sk_buff	*skb;
 	int	index = 0;
+	int	entries;
 
 	fep = netdev_priv(ndev);
 	bdp = fep->dirty_tx;
@@ -799,9 +920,13 @@ fec_enet_tx(struct net_device *ndev)
 		index = fec_enet_get_bd_index(bdp, fep);
 
 		skb = fep->tx_skbuff[index];
-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, skb->len,
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, bdp->cbd_datlen,
 				DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
+		if (!skb) {
+			bdp = fec_enet_get_nextdesc(bdp, fep);
+			continue;
+		}
 
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
@@ -820,7 +945,7 @@ fec_enet_tx(struct net_device *ndev)
 				ndev->stats.tx_carrier_errors++;
 		} else {
 			ndev->stats.tx_packets++;
-			ndev->stats.tx_bytes += bdp->cbd_datlen;
+			ndev->stats.tx_bytes += skb->len;
 		}
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
@@ -857,15 +982,13 @@ fec_enet_tx(struct net_device *ndev)
 
 		/* Since we have freed up a buffer, the ring is no longer full
 		 */
-		if (fep->dirty_tx != fep->cur_tx) {
-			if (netif_queue_stopped(ndev))
-				netif_wake_queue(ndev);
-		}
+		entries = fec_enet_get_free_txdesc_num(fep);
+		if (entries >= MAX_SKB_FRAGS + 1 && netif_queue_stopped(ndev))
+			netif_wake_queue(ndev);
 	}
 	return;
 }
 
-
 /* During a receive, the cur_rx points to the current incoming buffer.
  * When we update through the ring, if the next incoming buffer has
  * not been given to the system, we just set the empty indicator,
@@ -2107,7 +2230,7 @@ static int fec_enet_init(struct net_device *ndev)
 	if (id_entry->driver_data & FEC_QUIRK_HAS_CSUM) {
 		/* enable hw accelerator */
 		ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-				| NETIF_F_RXCSUM);
+				| NETIF_F_RXCSUM | NETIF_F_SG);
 		fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
 	}
 
-- 
1.7.8
