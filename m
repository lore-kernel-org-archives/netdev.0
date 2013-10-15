From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 07/18] net: ethernet: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:03 +0800
Message-ID: <1381837514-50660-8-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrapper functions net_ratelimited_function() and net_XXX_ratelimited()
are called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/ethernet/aeroflex/greth.c            | 16 ++++----
 drivers/net/ethernet/alteon/acenic.c             |  3 +-
 drivers/net/ethernet/arc/emac_main.c             |  7 ++--
 drivers/net/ethernet/broadcom/b44.c              |  4 +-
 drivers/net/ethernet/ethoc.c                     |  4 +-
 drivers/net/ethernet/faraday/ftgmac100.c         | 49 +++++++-----------------
 drivers/net/ethernet/faraday/ftmac100.c          | 45 +++++++---------------
 drivers/net/ethernet/freescale/fec_mpc52xx.c     |  3 +-
 drivers/net/ethernet/ibm/emac/mal.c              | 15 ++------
 drivers/net/ethernet/marvell/mv643xx_eth.c       |  6 +--
 drivers/net/ethernet/marvell/pxa168_eth.c        |  8 +---
 drivers/net/ethernet/marvell/sky2.c              | 42 ++++++++------------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  5 +--
 drivers/net/ethernet/realtek/r8169.c             | 13 +++----
 drivers/net/ethernet/sfc/rx.c                    |  8 ++--
 drivers/net/ethernet/sfc/siena_sriov.c           | 27 +++++--------
 drivers/net/ethernet/ti/davinci_emac.c           |  4 +-
 drivers/net/ethernet/tundra/tsi108_eth.c         | 12 ++----
 18 files changed, 90 insertions(+), 181 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index e066945..6a1a97f 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -569,8 +569,8 @@ frag_map_error:
 		greth_write_bd(&bdp->stat, 0);
 	}
 map_error:
-	if (net_ratelimit())
-		dev_warn(greth->dev, "Could not create TX DMA mapping\n");
+	net_ratelimited_function(dev_warn,
+		greth->dev, "Could not create TX DMA mapping\n");
 	dev_kfree_skb(skb);
 out:
 	return err;
@@ -778,8 +778,8 @@ static int greth_rx(struct net_device *dev, int limit)
 
 			if (unlikely(skb == NULL)) {
 
-				if (net_ratelimit())
-					dev_warn(&dev->dev, "low on memory - " "packet dropped\n");
+				net_ratelimited_function(dev_warn, &dev->dev,
+						"low on memory - packet dropped\n");
 
 				dev->stats.rx_dropped++;
 
@@ -918,8 +918,8 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 				greth->rx_skbuff[greth->rx_cur] = newskb;
 				greth_write_bd(&bdp->addr, dma_addr);
 			} else {
-				if (net_ratelimit())
-					dev_warn(greth->dev, "Could not create DMA mapping, dropping packet\n");
+				net_ratelimited_function(dev_warn, greth->dev,
+					"Could not create DMA mapping, dropping packet\n");
 				dev_kfree_skb(newskb);
 				/* reusing current skb, so it is a drop */
 				dev->stats.rx_dropped++;
@@ -934,8 +934,8 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 			 * table handling should be divided into cleaning and
 			 * filling as the TX part of the driver
 			 */
-			if (net_ratelimit())
-				dev_warn(greth->dev, "Could not allocate SKB, dropping packet\n");
+			net_ratelimited_function(dev_warn, greth->dev,
+				"Could not allocate SKB, dropping packet\n");
 			/* reusing current skb, so it is a drop */
 			dev->stats.rx_dropped++;
 		}
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 219be1b..432640b 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -1799,8 +1799,7 @@ static void ace_load_jumbo_rx_ring(struct net_device *dev, int nr_bufs)
 	clear_bit(0, &ap->jumbo_refill_busy);
 	return;
  error_out:
-	if (net_ratelimit())
-		printk(KERN_INFO "Out of memory when allocating "
+	net_info_ratelimited("Out of memory when allocating "
 		       "jumbo receive buffers\n");
 	goto out;
 }
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 9e16014..fe659b8 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -221,8 +221,8 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 			/* We pre-allocate buffers of MTU size so incoming
 			 * packets won't be split/chained.
 			 */
-			if (net_ratelimit())
-				netdev_err(ndev, "incomplete packet received\n");
+			net_ratelimited_funciton(netdev_err, ndev,
+				"incomplete packet received\n");
 
 			/* Return ownership to EMAC */
 			rxbd->info = cpu_to_le32(FOR_EMAC | EMAC_BUFFER_SIZE);
@@ -258,8 +258,7 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 		addr = dma_map_single(&ndev->dev, (void *)rx_buff->skb->data,
 				      EMAC_BUFFER_SIZE, DMA_FROM_DEVICE);
 		if (dma_mapping_error(&ndev->dev, addr)) {
-			if (net_ratelimit())
-				netdev_err(ndev, "cannot dma map\n");
+			net_ratelimited_function(netdev_err, ndev, "cannot dma map\n");
 			dev_kfree_skb(rx_buff->skb);
 			stats->rx_errors++;
 			continue;
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 9b017d9..7e422dc 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -187,8 +187,8 @@ static int b44_wait_bit(struct b44 *bp, unsigned long reg,
 		udelay(10);
 	}
 	if (i == timeout) {
-		if (net_ratelimit())
-			netdev_err(bp->dev, "BUG!  Timeout waiting for bit %08x of register %lx to %s\n",
+		net_ratelimited_function(netdev_err, bp->dev,
+				"BUG!  Timeout waiting for bit %08x of register %lx to %s\n",
 				   bit, reg, clear ? "clear" : "set");
 
 		return -ENODEV;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4de8cfd..b61b56d 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -446,10 +446,8 @@ static int ethoc_rx(struct net_device *dev, int limit)
 				dev->stats.rx_bytes += size;
 				netif_receive_skb(skb);
 			} else {
-				if (net_ratelimit())
-					dev_warn(&dev->dev,
+				net_ratelimited_function(dev_warn, &dev->dev,
 					    "low on memory - packet dropped\n");
-
 				dev->stats.rx_dropped++;
 				break;
 			}
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 212f44b..a289337 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -354,42 +354,30 @@ static bool ftgmac100_rx_packet_error(struct ftgmac100 *priv,
 	bool error = false;
 
 	if (unlikely(ftgmac100_rxdes_rx_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx err\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx err\n");
 		netdev->stats.rx_errors++;
 		error = true;
 	}
 
 	if (unlikely(ftgmac100_rxdes_crc_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx crc err\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx crc err\n");
 		netdev->stats.rx_crc_errors++;
 		error = true;
 	} else if (unlikely(ftgmac100_rxdes_ipcs_err(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx IP checksum err\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx IP checksum err\n");
 		error = true;
 	}
 
 	if (unlikely(ftgmac100_rxdes_frame_too_long(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx frame too long\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx frame too long\n");
 		netdev->stats.rx_length_errors++;
 		error = true;
 	} else if (unlikely(ftgmac100_rxdes_runt(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx runt\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx runt\n");
 		netdev->stats.rx_length_errors++;
 		error = true;
 	} else if (unlikely(ftgmac100_rxdes_odd_nibble(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx odd nibble\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx odd bibble\n");
 		netdev->stats.rx_length_errors++;
 		error = true;
 	}
@@ -403,8 +391,7 @@ static void ftgmac100_rx_drop_packet(struct ftgmac100 *priv)
 	struct ftgmac100_rxdes *rxdes = ftgmac100_current_rxdes(priv);
 	bool done = false;
 
-	if (net_ratelimit())
-		netdev_dbg(netdev, "drop packet %p\n", rxdes);
+	net_ratelimited_function(netdev_dbg, netdev, "drop packet %p\n", rxdes);
 
 	do {
 		if (ftgmac100_rxdes_last_segment(rxdes))
@@ -437,9 +424,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	/* start processing */
 	skb = netdev_alloc_skb_ip_align(netdev, 128);
 	if (unlikely(!skb)) {
-		if (net_ratelimit())
-			netdev_err(netdev, "rx skb alloc failed\n");
-
+		net_ratelimited_function(netdev_err, netdev, "rx skb alloc failed\n");
 		ftgmac100_rx_drop_packet(priv);
 		return true;
 	}
@@ -723,15 +708,13 @@ static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
 
 	page = alloc_page(gfp);
 	if (!page) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to allocate rx page\n");
+		net_ratelimited_function(netdev_err, netdev, "failed to allocate rx page\n");
 		return -ENOMEM;
 	}
 
 	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to map rx page\n");
+		net_ratelimited_function(netdev_err, netdev, "failed to map rx page\n");
 		__free_page(page);
 		return -ENOMEM;
 	}
@@ -1043,8 +1026,8 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 
 	if (status & (FTGMAC100_INT_NO_RXBUF | FTGMAC100_INT_RPKT_LOST |
 		      FTGMAC100_INT_AHB_ERR | FTGMAC100_INT_PHYSTS_CHG)) {
-		if (net_ratelimit())
-			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s%s\n", status,
+		net_ratelimited_function(netdev_info, netdev, "[ISR] = 0x%x: %s%s%s%s\n",
+					status,
 				    status & FTGMAC100_INT_NO_RXBUF ? "NO_RXBUF " : "",
 				    status & FTGMAC100_INT_RPKT_LOST ? "RPKT_LOST " : "",
 				    status & FTGMAC100_INT_AHB_ERR ? "AHB_ERR " : "",
@@ -1145,9 +1128,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	dma_addr_t map;
 
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
-		if (net_ratelimit())
-			netdev_dbg(netdev, "tx packet too big\n");
-
+		net_ratelimited_function(netdev_dbg, netdev, "tx packet too big\n");
 		netdev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
@@ -1156,9 +1137,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(priv->dev, map))) {
 		/* drop packet */
-		if (net_ratelimit())
-			netdev_err(netdev, "map socket buffer failed\n");
-
+		net_ratelimited_function(netdev_err, netdev, "map socket buffer failed\n");
 		netdev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index 8be5b40..ec8afe2 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -335,37 +335,27 @@ static bool ftmac100_rx_packet_error(struct ftmac100 *priv,
 	bool error = false;
 
 	if (unlikely(ftmac100_rxdes_rx_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx err\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx err\n");
 		netdev->stats.rx_errors++;
 		error = true;
 	}
 
 	if (unlikely(ftmac100_rxdes_crc_error(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx crc err\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx crc err\n");
 		netdev->stats.rx_crc_errors++;
 		error = true;
 	}
 
 	if (unlikely(ftmac100_rxdes_frame_too_long(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx frame too long\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx frame too long\n");
 		netdev->stats.rx_length_errors++;
 		error = true;
 	} else if (unlikely(ftmac100_rxdes_runt(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx runt\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx runt\n");
 		netdev->stats.rx_length_errors++;
 		error = true;
 	} else if (unlikely(ftmac100_rxdes_odd_nibble(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx odd nibble\n");
-
+		net_ratelimited_function(netdev_info, netdev, "rx odd nibble\n");
 		netdev->stats.rx_length_errors++;
 		error = true;
 	}
@@ -379,8 +369,7 @@ static void ftmac100_rx_drop_packet(struct ftmac100 *priv)
 	struct ftmac100_rxdes *rxdes = ftmac100_current_rxdes(priv);
 	bool done = false;
 
-	if (net_ratelimit())
-		netdev_dbg(netdev, "drop packet %p\n", rxdes);
+	net_ratelimited_function(netdev_dbg, netdev, "drop packet %p\n", rxdes);
 
 	do {
 		if (ftmac100_rxdes_last_segment(rxdes))
@@ -422,9 +411,7 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 	/* start processing */
 	skb = netdev_alloc_skb_ip_align(netdev, 128);
 	if (unlikely(!skb)) {
-		if (net_ratelimit())
-			netdev_err(netdev, "rx skb alloc failed\n");
-
+		net_ratelimited_function(netdev_err, netdev, "rx skb alloc failed\n");
 		ftmac100_rx_drop_packet(priv);
 		return true;
 	}
@@ -676,15 +663,13 @@ static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
 
 	page = alloc_page(gfp);
 	if (!page) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to allocate rx page\n");
+		net_ratelimited_function(netdev_err, netdev, "failed to allocate rx page\n");
 		return -ENOMEM;
 	}
 
 	map = dma_map_page(priv->dev, page, 0, RX_BUF_SIZE, DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		if (net_ratelimit())
-			netdev_err(netdev, "failed to map rx page\n");
+		net_ratelimited_function(netdev_err, netdev, "failed to map rx page\n");
 		__free_page(page);
 		return -ENOMEM;
 	}
@@ -919,8 +904,8 @@ static int ftmac100_poll(struct napi_struct *napi, int budget)
 
 	if (status & (FTMAC100_INT_NORXBUF | FTMAC100_INT_RPKT_LOST |
 		      FTMAC100_INT_AHB_ERR | FTMAC100_INT_PHYSTS_CHG)) {
-		if (net_ratelimit())
-			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s%s\n", status,
+		net_ratelimited_function(netdev_info, netdev, "[ISR] = 0x%x: %s%s%s%s\n",
+					status,
 				    status & FTMAC100_INT_NORXBUF ? "NORXBUF " : "",
 				    status & FTMAC100_INT_RPKT_LOST ? "RPKT_LOST " : "",
 				    status & FTMAC100_INT_AHB_ERR ? "AHB_ERR " : "",
@@ -1015,9 +1000,7 @@ static int ftmac100_hard_start_xmit(struct sk_buff *skb, struct net_device *netd
 	dma_addr_t map;
 
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
-		if (net_ratelimit())
-			netdev_dbg(netdev, "tx packet too big\n");
-
+		net_ratelimited_function(netdev_dbg, netdev, "tx packet too big\n");
 		netdev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
@@ -1026,9 +1009,7 @@ static int ftmac100_hard_start_xmit(struct sk_buff *skb, struct net_device *netd
 	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(priv->dev, map))) {
 		/* drop packet */
-		if (net_ratelimit())
-			netdev_err(netdev, "map socket buffer failed\n");
-
+		net_ratelimited_function(netdev_err, netdev, "map socket buffer failed\n");
 		netdev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 9947765..6b1feeb 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -313,8 +313,7 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	if (bcom_queue_full(priv->tx_dmatsk)) {
-		if (net_ratelimit())
-			dev_err(&dev->dev, "transmit queue overrun\n");
+		net_ratelimited_function(dev_err, &dev->dev, "transmit queue overrun\n");
 		return NETDEV_TX_BUSY;
 	}
 
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index dac564c..9177345 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -240,20 +240,15 @@ static irqreturn_t mal_serr(int irq, void *dev_instance)
 			/* PLB error, it's probably buggy hardware or
 			 * incorrect physical address in BD (i.e. bug)
 			 */
-			if (net_ratelimit())
-				printk(KERN_ERR
-				       "mal%d: system error, "
-				       "PLB (ESR = 0x%08x)\n",
-				       mal->index, esr);
+			net_err_ratelimited("mal%d: system error, "
+				"PLB (ESR = 0x%08x)\n", mal->index, esr);
 			return IRQ_HANDLED;
 		}
 
 		/* OPB error, it's probably buggy hardware or incorrect
 		 * EBC setup
 		 */
-		if (net_ratelimit())
-			printk(KERN_ERR
-			       "mal%d: system error, OPB (ESR = 0x%08x)\n",
+		net_err_ratelimited("mal%d: system error, OPB (ESR = 0x%08x)\n",
 			       mal->index, esr);
 	}
 	return IRQ_HANDLED;
@@ -318,9 +313,7 @@ static irqreturn_t mal_txde(int irq, void *dev_instance)
 
 	MAL_DBG(mal, "txde %08x" NL, deir);
 
-	if (net_ratelimit())
-		printk(KERN_ERR
-		       "mal%d: TX descriptor error (TXDEIR = 0x%08x)\n",
+	net_err_ratelimited("mal%d: TX descriptor error (TXDEIR = 0x%08x)\n",
 		       mal->index, deir);
 
 	return IRQ_HANDLED;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 7fb5677..d1e23d7 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -573,8 +573,7 @@ err:
 
 		if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 			(RX_FIRST_DESC | RX_LAST_DESC)) {
-			if (net_ratelimit())
-				netdev_err(mp->dev,
+			net_ratelimited_function(netdev_err, mp->dev,
 					   "received packet spanning multiple descriptors\n");
 		}
 
@@ -818,8 +817,7 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
-		if (net_ratelimit())
-			netdev_err(dev, "tx queue full?!\n");
+		net_ratelimited_function(netdev_err, dev, "tx queue full?!\n");
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index fff6246..ce36745 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -744,8 +744,7 @@ static int txq_reclaim(struct net_device *dev, int force)
 			pep->tx_skb[tx_index] = NULL;
 
 		if (cmd_sts & TX_ERROR) {
-			if (net_ratelimit())
-				printk(KERN_ERR "%s: Error in TX\n", dev->name);
+			net_err_ratelimited("%s: Error in TX\n", dev->name);
 			dev->stats.tx_errors++;
 		}
 		dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
@@ -832,10 +831,7 @@ static int rxq_process(struct net_device *dev, int budget)
 			stats->rx_dropped++;
 			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 			    (RX_FIRST_DESC | RX_LAST_DESC)) {
-				if (net_ratelimit())
-					printk(KERN_ERR
-					       "%s: Rx pkt on multiple desc\n",
-					       dev->name);
+				net_err_ratelimited("%s: Rx pkt on multiple desc\n", dev->name);
 			}
 			if (cmd_sts & RX_ERROR)
 				stats->rx_errors++;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index e09a8c6..42cad5d 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1250,8 +1250,7 @@ map_page_error:
 			 PCI_DMA_FROMDEVICE);
 
 mapping_error:
-	if (net_ratelimit())
-		dev_warn(&pdev->dev, "%s: rx mapping error\n",
+	net_ratelimited_function(dev_warn, &pdev->dev, "%s: rx mapping error\n",
 			 skb->dev->name);
 	return -EIO;
 }
@@ -1998,8 +1997,8 @@ mapping_unwind:
 	}
 
 mapping_error:
-	if (net_ratelimit())
-		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
+	net_ratelimited_function(dev_warn, &hw->pdev->dev,
+		"%s: tx mapping error\n", dev->name);
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -2633,8 +2632,7 @@ resubmit:
 error:
 	++dev->stats.rx_errors;
 
-	if (net_ratelimit())
-		netif_info(sky2, rx_err, dev,
+	net_ratelimited_function(netif_info, sky2, rx_err, dev,
 			   "rx error, status 0x%x length %d\n", status, length);
 
 	goto resubmit;
@@ -2809,8 +2807,7 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 			break;
 
 		default:
-			if (net_ratelimit())
-				pr_warning("unknown status opcode 0x%x\n", opcode);
+			net_warn_ratelimited("unknown status opcode 0x%x\n", opcode);
 		}
 	} while (hw->st_idx != idx);
 
@@ -2828,38 +2825,33 @@ static void sky2_hw_error(struct sky2_hw *hw, unsigned port, u32 status)
 {
 	struct net_device *dev = hw->dev[port];
 
-	if (net_ratelimit())
-		netdev_info(dev, "hw error interrupt status 0x%x\n", status);
+	net_ratelimited_function(netdev_info, dev, "hw error interrupt status 0x%x\n",
+		status);
 
 	if (status & Y2_IS_PAR_RD1) {
-		if (net_ratelimit())
-			netdev_err(dev, "ram data read parity error\n");
+		net_ratelimited_function(netdev_err, dev, "ram data read parity error\n");
 		/* Clear IRQ */
 		sky2_write16(hw, RAM_BUFFER(port, B3_RI_CTRL), RI_CLR_RD_PERR);
 	}
 
 	if (status & Y2_IS_PAR_WR1) {
-		if (net_ratelimit())
-			netdev_err(dev, "ram data write parity error\n");
+		net_ratelimited_function(netdev_err, dev, "ram data write parity error\n");
 
 		sky2_write16(hw, RAM_BUFFER(port, B3_RI_CTRL), RI_CLR_WR_PERR);
 	}
 
 	if (status & Y2_IS_PAR_MAC1) {
-		if (net_ratelimit())
-			netdev_err(dev, "MAC parity error\n");
+		net_ratelimited_function(netdev_err, dev, "MAC parity error\n");
 		sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_CLI_TX_PE);
 	}
 
 	if (status & Y2_IS_PAR_RX1) {
-		if (net_ratelimit())
-			netdev_err(dev, "RX parity error\n");
+		net_ratelimited_function(netdev_err, dev, "RX parity error\n");
 		sky2_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), BMU_CLR_IRQ_PAR);
 	}
 
 	if (status & Y2_IS_TCP_TXA1) {
-		if (net_ratelimit())
-			netdev_err(dev, "TCP segmentation error\n");
+		net_ratelimited_function(netdev_err, dev, "TCP segmentation error\n");
 		sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR), BMU_CLR_IRQ_TCP);
 	}
 }
@@ -2880,8 +2872,7 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
-		if (net_ratelimit())
-			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
+		net_ratelimited_function(dev_err, &pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
 		sky2_pci_write16(hw, PCI_STATUS,
@@ -2897,8 +2888,7 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
 			     0xfffffffful);
-		if (net_ratelimit())
-			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
+		net_ratelimited_function(dev_err, &pdev->dev, "PCI Express error (0x%x)\n", err);
 
 		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
@@ -3017,8 +3007,8 @@ static void sky2_watchdog(unsigned long arg)
 /* Hardware/software error handling */
 static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 {
-	if (net_ratelimit())
-		dev_warn(&hw->pdev->dev, "error interrupt status=%#x\n", status);
+	net_ratelimited_function(dev_warn, &hw->pdev->dev,
+		"error interrupt status=%#x\n", status);
 
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 149355b..920ef96 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3559,9 +3559,8 @@ myri10ge_check_slice(struct myri10ge_slice_state *ss, int *reset_needed,
 	    ss->watchdog_tx_req != ss->watchdog_tx_done) {
 		/* nic seems like it might be stuck.. */
 		if (rx_pause_cnt != mgp->watchdog_pause) {
-			if (net_ratelimit())
-				netdev_warn(mgp->dev, "slice %d: TX paused, "
-					    "check link partner\n", slice);
+			net_ratelimited_function(netdev_warn, mgp->dev,
+				"slice %d: TX paused, check link partner\n", slice);
 		} else {
 			netdev_warn(mgp->dev,
 				    "slice %d: TX stuck %d %d %d %d %d %d\n",
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3397cee..5e0ee96 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1496,8 +1496,7 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 		if (pm)
 			pm_request_resume(&tp->pci_dev->dev);
 		netif_carrier_on(dev);
-		if (net_ratelimit())
-			netif_info(tp, ifup, dev, "link up\n");
+		net_ratelimited_function(netif_info, tp, ifup, dev, "link up\n");
 	} else {
 		netif_carrier_off(dev);
 		netif_info(tp, ifdown, dev, "link down\n");
@@ -5732,8 +5731,8 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 	mapping = dma_map_single(d, rtl8169_align(data), rx_buf_sz,
 				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(d, mapping))) {
-		if (net_ratelimit())
-			netif_err(tp, drv, tp->dev, "Failed to map RX DMA!\n");
+		net_ratelimited_function(netif_err,
+			tp, drv, tp->dev, "Failed to map RX DMA!\n");
 		goto err_out;
 	}
 
@@ -5895,8 +5894,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		addr = skb_frag_address(frag);
 		mapping = dma_map_single(d, addr, len, DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(d, mapping))) {
-			if (net_ratelimit())
-				netif_err(tp, drv, tp->dev,
+			net_ratelimited_function(netif_err, tp, drv, tp->dev,
 					  "Failed to map TX fragments DMA!\n");
 			goto err_out;
 		}
@@ -5996,8 +5994,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	len = skb_headlen(skb);
 	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(d, mapping))) {
-		if (net_ratelimit())
-			netif_err(tp, drv, dev, "Failed to map TX DMA!\n");
+		net_ratelimited_function(netif_err, tp, drv, dev, "Failed to map TX DMA!\n");
 		goto err_dma_0;
 	}
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 4a59672..b53f16d 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -397,19 +397,17 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 	rx_buf->flags |= EFX_RX_PKT_DISCARD;
 
 	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
-		if (net_ratelimit())
-			netif_err(efx, rx_err, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, rx_err, efx->net_dev,
 				  " RX queue %d seriously overlength "
 				  "RX event (0x%x > 0x%x+0x%x). Leaking\n",
 				  efx_rx_queue_index(rx_queue), len, max_len,
 				  efx->type->rx_buffer_padding);
 		efx_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
 	} else {
-		if (net_ratelimit())
-			netif_err(efx, rx_err, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, rx_err, efx->net_dev,
 				  " RX queue %d overlength RX event "
 				  "(0x%x > 0x%x)\n",
-				  efx_rx_queue_index(rx_queue), len, max_len);
+		efx_rx_queue_index(rx_queue), len, max_len);
 	}
 
 	efx_rx_queue_channel(rx_queue)->n_rx_overlength++;
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 0c38f92..71ec42d 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -532,8 +532,7 @@ static int efx_vfdi_init_evq(struct efx_vf *vf)
 
 	if (bad_vf_index(efx, vf_evq) ||
 	    bad_buf_count(buf_count, EFX_MAX_VF_EVQ_SIZE)) {
-		if (net_ratelimit())
-			netif_err(efx, hw, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 				  "ERROR: Invalid INIT_EVQ from %s: evq %d bufs %d\n",
 				  vf->pci_name, vf_evq, buf_count);
 		return VFDI_RC_EINVAL;
@@ -575,8 +574,7 @@ static int efx_vfdi_init_rxq(struct efx_vf *vf)
 	if (bad_vf_index(efx, vf_evq) || bad_vf_index(efx, vf_rxq) ||
 	    vf_rxq >= VF_MAX_RX_QUEUES ||
 	    bad_buf_count(buf_count, EFX_MAX_DMAQ_SIZE)) {
-		if (net_ratelimit())
-			netif_err(efx, hw, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 				  "ERROR: Invalid INIT_RXQ from %s: rxq %d evq %d "
 				  "buf_count %d\n", vf->pci_name, vf_rxq,
 				  vf_evq, buf_count);
@@ -616,8 +614,7 @@ static int efx_vfdi_init_txq(struct efx_vf *vf)
 	if (bad_vf_index(efx, vf_evq) || bad_vf_index(efx, vf_txq) ||
 	    vf_txq >= vf_max_tx_channels ||
 	    bad_buf_count(buf_count, EFX_MAX_DMAQ_SIZE)) {
-		if (net_ratelimit())
-			netif_err(efx, hw, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 				  "ERROR: Invalid INIT_TXQ from %s: txq %d evq %d "
 				  "buf_count %d\n", vf->pci_name, vf_txq,
 				  vf_evq, buf_count);
@@ -759,8 +756,7 @@ static int efx_vfdi_insert_filter(struct efx_vf *vf)
 	unsigned flags;
 
 	if (bad_vf_index(efx, vf_rxq) || vf->rx_filtering) {
-		if (net_ratelimit())
-			netif_err(efx, hw, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 				  "ERROR: Invalid INSERT_FILTER from %s: rxq %d "
 				  "flags 0x%x\n", vf->pci_name, vf_rxq,
 				  req->u.mac_filter.flags);
@@ -802,8 +798,7 @@ static int efx_vfdi_set_status_page(struct efx_vf *vf)
 		/ sizeof(req->u.set_status_page.peer_page_addr[0]);
 
 	if (!req->u.set_status_page.dma_addr || page_count > max_page_count) {
-		if (net_ratelimit())
-			netif_err(efx, hw, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 				  "ERROR: Invalid SET_STATUS_PAGE from %s\n",
 				  vf->pci_name);
 		return VFDI_RC_EINVAL;
@@ -875,8 +870,7 @@ static void efx_sriov_vfdi(struct work_struct *work)
 	rc = efx_sriov_memcpy(efx, copy, 1);
 	if (rc) {
 		/* If we can't get the request, we can't reply to the caller */
-		if (net_ratelimit())
-			netif_err(efx, hw, efx->net_dev,
+		net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 				  "ERROR: Unable to fetch VFDI request from %s rc %d\n",
 				  vf->pci_name, -rc);
 		vf->busy = false;
@@ -963,8 +957,7 @@ static void efx_sriov_reset_vf(struct efx_vf *vf, struct efx_buffer *buffer)
 		}
 		rc = efx_sriov_memcpy(efx, copy_req, count);
 		if (rc) {
-			if (net_ratelimit())
-				netif_err(efx, hw, efx->net_dev,
+			net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 					  "ERROR: Unable to notify %s of reset"
 					  ": %d\n", vf->pci_name, -rc);
 			break;
@@ -1420,8 +1413,7 @@ void efx_sriov_event(struct efx_channel *channel, efx_qword_t *event)
 	}
 
 error:
-	if (net_ratelimit())
-		netif_err(efx, hw, efx->net_dev,
+	net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 			  "ERROR: Screaming VFDI request from %s\n",
 			  vf->pci_name);
 	/* Reset the request and sequence number */
@@ -1509,8 +1501,7 @@ void efx_sriov_desc_fetch_err(struct efx_nic *efx, unsigned dmaq)
 	if (map_vi_index(efx, dmaq, &vf, &rel))
 		return;
 
-	if (net_ratelimit())
-		netif_err(efx, hw, efx->net_dev,
+	net_ratelimited_function(netif_err, efx, hw, efx->net_dev,
 			  "VF %d DMA Q %d reports descriptor fetch error.\n",
 			  vf->index, rel);
 	queue_work(vfdi_workqueue, &vf->reset_work);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 67df09e..caab0a9 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1408,10 +1408,8 @@ static int emac_poll(struct napi_struct *napi, int budget)
 		if (cause) {
 			ch = ((status & EMAC_MACSTATUS_TXERRCH_MASK) >>
 			      EMAC_MACSTATUS_TXERRCH_SHIFT);
-			if (net_ratelimit()) {
-				dev_err(emac_dev, "TX Host error %s on ch=%d\n",
+			net_ratelimited_function(dev_err, emac_dev, "TX Host error %s on ch=%d\n",
 					&emac_txhost_errcodes[cause][0], ch);
-			}
 		}
 		cause = ((status & EMAC_MACSTATUS_RXERRCODE_MASK) >>
 			 EMAC_MACSTATUS_RXERRCODE_SHIFT);
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index c4dbf98..467d76d 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -669,10 +669,7 @@ static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 
 	if (data->txfree < MAX_SKB_FRAGS + 1) {
 		netif_stop_queue(dev);
-
-		if (net_ratelimit())
-			printk(KERN_ERR "%s: Transmit with full tx ring!\n",
-			       dev->name);
+		net_err_ratelimited("%s: Transmit with full tx ring!\n", dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -869,9 +866,7 @@ static int tsi108_poll(struct napi_struct *napi, int budget)
 		TSI_WRITE(TSI108_EC_RXERR, err);
 
 		if (err) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "%s: RX error %x\n",
-				       dev->name, err);
+			net_dbg_ratelimited("%s: RX error %x\n", dev->name, err);
 
 			if (!(TSI_READ(TSI108_EC_RXSTAT) &
 			      TSI108_EC_RXSTAT_QUEUE0))
@@ -1024,8 +1019,7 @@ static irqreturn_t tsi108_irq(int irq, void *dev_id)
 		tsi108_rx_int(dev);
 
 	if (stat & TSI108_INT_SFN) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: SFN error\n", dev->name);
+		net_dbg_ratelimited("%s: SFN error\n", dev->name);
 		TSI_WRITE(TSI108_EC_INTSTAT, TSI108_INT_SFN);
 	}
 
-- 
1.8.2.1
