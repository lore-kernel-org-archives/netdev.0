From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 1/3] net: fs_enet: merge NAPI RX and NAPI TX
Date: Wed, 24 Aug 2016 12:36:40 +0200 (CEST)
Message-ID: <c607324b1322bb5729081808b2f54f5f9da52444.1472033140.git.christophe.leroy@c-s.fr>
References: <cover.1472033140.git.christophe.leroy@c-s.fr>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
 Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <cover.1472033140.git.christophe.leroy@c-s.fr>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Initially, a NAPI TX routine has been implemented separately from
NAPI RX, as done on the freescale/gianfar driver.

By merging NAPI RX and NAPI TX, we reduce the amount of TX completion
interrupts.

Handling of the budget in association with TX interrupts is based on
indications provided at https://wiki.linuxfoundation.org/networking/napi

At the same time, we fix an issue in the handling of fep->tx_free:

It is only when fep->tx_free goes up to MAX_SKB_FRAGS that
we need to wake up the queue. There is no need to call
netif_wake_queue() at every packet successfully transmitted.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 259 +++++++++------------
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |  16 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c   |  57 ++---
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |  57 ++---
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c   |  57 ++---
 5 files changed, 153 insertions(+), 293 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 61fd486..7cd3ef9 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -79,8 +79,8 @@ static void skb_align(struct sk_buff *skb, int align)
 		skb_reserve(skb, align - off);
 }
 
-/* NAPI receive function */
-static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
+/* NAPI function */
+static int fs_enet_napi(struct napi_struct *napi, int budget)
 {
 	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private, napi);
 	struct net_device *dev = fep->ndev;
@@ -90,9 +90,100 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 	int received = 0;
 	u16 pkt_len, sc;
 	int curidx;
+	int dirtyidx, do_wake, do_restart;
 
-	if (budget <= 0)
-		return received;
+	spin_lock(&fep->tx_lock);
+	bdp = fep->dirty_tx;
+
+	/* clear status bits for napi*/
+	(*fep->ops->napi_clear_event)(dev);
+
+	do_wake = do_restart = 0;
+	while (((sc = CBDR_SC(bdp)) & BD_ENET_TX_READY) == 0) {
+		dirtyidx = bdp - fep->tx_bd_base;
+
+		if (fep->tx_free == fep->tx_ring)
+			break;
+
+		skb = fep->tx_skbuff[dirtyidx];
+
+		/*
+		 * Check for errors.
+		 */
+		if (sc & (BD_ENET_TX_HB | BD_ENET_TX_LC |
+			  BD_ENET_TX_RL | BD_ENET_TX_UN | BD_ENET_TX_CSL)) {
+
+			if (sc & BD_ENET_TX_HB)	/* No heartbeat */
+				fep->stats.tx_heartbeat_errors++;
+			if (sc & BD_ENET_TX_LC)	/* Late collision */
+				fep->stats.tx_window_errors++;
+			if (sc & BD_ENET_TX_RL)	/* Retrans limit */
+				fep->stats.tx_aborted_errors++;
+			if (sc & BD_ENET_TX_UN)	/* Underrun */
+				fep->stats.tx_fifo_errors++;
+			if (sc & BD_ENET_TX_CSL)	/* Carrier lost */
+				fep->stats.tx_carrier_errors++;
+
+			if (sc & (BD_ENET_TX_LC | BD_ENET_TX_RL | BD_ENET_TX_UN)) {
+				fep->stats.tx_errors++;
+				do_restart = 1;
+			}
+		} else
+			fep->stats.tx_packets++;
+
+		if (sc & BD_ENET_TX_READY) {
+			dev_warn(fep->dev,
+				 "HEY! Enet xmit interrupt and TX_READY.\n");
+		}
+
+		/*
+		 * Deferred means some collisions occurred during transmit,
+		 * but we eventually sent the packet OK.
+		 */
+		if (sc & BD_ENET_TX_DEF)
+			fep->stats.collisions++;
+
+		/* unmap */
+		if (fep->mapped_as_page[dirtyidx])
+			dma_unmap_page(fep->dev, CBDR_BUFADDR(bdp),
+				       CBDR_DATLEN(bdp), DMA_TO_DEVICE);
+		else
+			dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
+					 CBDR_DATLEN(bdp), DMA_TO_DEVICE);
+
+		/*
+		 * Free the sk buffer associated with this last transmit.
+		 */
+		if (skb) {
+			dev_kfree_skb(skb);
+			fep->tx_skbuff[dirtyidx] = NULL;
+		}
+
+		/*
+		 * Update pointer to next buffer descriptor to be transmitted.
+		 */
+		if ((sc & BD_ENET_TX_WRAP) == 0)
+			bdp++;
+		else
+			bdp = fep->tx_bd_base;
+
+		/*
+		 * Since we have freed up a buffer, the ring is no longer
+		 * full.
+		 */
+		if (++fep->tx_free == MAX_SKB_FRAGS)
+			do_wake = 1;
+	}
+
+	fep->dirty_tx = bdp;
+
+	if (do_restart)
+		(*fep->ops->tx_restart)(dev);
+
+	spin_unlock(&fep->tx_lock);
+
+	if (do_wake)
+		netif_wake_queue(dev);
 
 	/*
 	 * First, grab all of the stats for the incoming packet.
@@ -100,10 +191,8 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 	 */
 	bdp = fep->cur_rx;
 
-	/* clear RX status bits for napi*/
-	(*fep->ops->napi_clear_rx_event)(dev);
-
-	while (((sc = CBDR_SC(bdp)) & BD_ENET_RX_EMPTY) == 0) {
+	while (((sc = CBDR_SC(bdp)) & BD_ENET_RX_EMPTY) == 0 &&
+	       received < budget) {
 		curidx = bdp - fep->rx_bd_base;
 
 		/*
@@ -197,134 +286,19 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 			bdp = fep->rx_bd_base;
 
 		(*fep->ops->rx_bd_done)(dev);
-
-		if (received >= budget)
-			break;
 	}
 
 	fep->cur_rx = bdp;
 
-	if (received < budget) {
+	if (received < budget && !do_wake) {
 		/* done */
 		napi_complete(napi);
-		(*fep->ops->napi_enable_rx)(dev);
-	}
-	return received;
-}
-
-static int fs_enet_tx_napi(struct napi_struct *napi, int budget)
-{
-	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private,
-						   napi_tx);
-	struct net_device *dev = fep->ndev;
-	cbd_t __iomem *bdp;
-	struct sk_buff *skb;
-	int dirtyidx, do_wake, do_restart;
-	u16 sc;
-	int has_tx_work = 0;
-
-	spin_lock(&fep->tx_lock);
-	bdp = fep->dirty_tx;
-
-	/* clear TX status bits for napi*/
-	(*fep->ops->napi_clear_tx_event)(dev);
-
-	do_wake = do_restart = 0;
-	while (((sc = CBDR_SC(bdp)) & BD_ENET_TX_READY) == 0) {
-		dirtyidx = bdp - fep->tx_bd_base;
-
-		if (fep->tx_free == fep->tx_ring)
-			break;
-
-		skb = fep->tx_skbuff[dirtyidx];
-
-		/*
-		 * Check for errors.
-		 */
-		if (sc & (BD_ENET_TX_HB | BD_ENET_TX_LC |
-			  BD_ENET_TX_RL | BD_ENET_TX_UN | BD_ENET_TX_CSL)) {
-
-			if (sc & BD_ENET_TX_HB)	/* No heartbeat */
-				fep->stats.tx_heartbeat_errors++;
-			if (sc & BD_ENET_TX_LC)	/* Late collision */
-				fep->stats.tx_window_errors++;
-			if (sc & BD_ENET_TX_RL)	/* Retrans limit */
-				fep->stats.tx_aborted_errors++;
-			if (sc & BD_ENET_TX_UN)	/* Underrun */
-				fep->stats.tx_fifo_errors++;
-			if (sc & BD_ENET_TX_CSL)	/* Carrier lost */
-				fep->stats.tx_carrier_errors++;
-
-			if (sc & (BD_ENET_TX_LC | BD_ENET_TX_RL | BD_ENET_TX_UN)) {
-				fep->stats.tx_errors++;
-				do_restart = 1;
-			}
-		} else
-			fep->stats.tx_packets++;
-
-		if (sc & BD_ENET_TX_READY) {
-			dev_warn(fep->dev,
-				 "HEY! Enet xmit interrupt and TX_READY.\n");
-		}
-
-		/*
-		 * Deferred means some collisions occurred during transmit,
-		 * but we eventually sent the packet OK.
-		 */
-		if (sc & BD_ENET_TX_DEF)
-			fep->stats.collisions++;
+		(*fep->ops->napi_enable)(dev);
 
-		/* unmap */
-		if (fep->mapped_as_page[dirtyidx])
-			dma_unmap_page(fep->dev, CBDR_BUFADDR(bdp),
-				       CBDR_DATLEN(bdp), DMA_TO_DEVICE);
-		else
-			dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
-					 CBDR_DATLEN(bdp), DMA_TO_DEVICE);
-
-		/*
-		 * Free the sk buffer associated with this last transmit.
-		 */
-		if (skb) {
-			dev_kfree_skb(skb);
-			fep->tx_skbuff[dirtyidx] = NULL;
-		}
-
-		/*
-		 * Update pointer to next buffer descriptor to be transmitted.
-		 */
-		if ((sc & BD_ENET_TX_WRAP) == 0)
-			bdp++;
-		else
-			bdp = fep->tx_bd_base;
-
-		/*
-		 * Since we have freed up a buffer, the ring is no longer
-		 * full.
-		 */
-		if (++fep->tx_free >= MAX_SKB_FRAGS)
-			do_wake = 1;
-		has_tx_work = 1;
-	}
-
-	fep->dirty_tx = bdp;
-
-	if (do_restart)
-		(*fep->ops->tx_restart)(dev);
-
-	if (!has_tx_work) {
-		napi_complete(napi);
-		(*fep->ops->napi_enable_tx)(dev);
+		return received;
 	}
 
-	spin_unlock(&fep->tx_lock);
-
-	if (do_wake)
-		netif_wake_queue(dev);
-
-	if (has_tx_work)
-		return budget;
-	return 0;
+	return budget;
 }
 
 /*
@@ -350,18 +324,18 @@ fs_enet_interrupt(int irq, void *dev_id)
 		nr++;
 
 		int_clr_events = int_events;
-		int_clr_events &= ~fep->ev_napi_rx;
+		int_clr_events &= ~fep->ev_napi;
 
 		(*fep->ops->clear_int_events)(dev, int_clr_events);
 
 		if (int_events & fep->ev_err)
 			(*fep->ops->ev_error)(dev, int_events);
 
-		if (int_events & fep->ev_rx) {
+		if (int_events & fep->ev) {
 			napi_ok = napi_schedule_prep(&fep->napi);
 
-			(*fep->ops->napi_disable_rx)(dev);
-			(*fep->ops->clear_int_events)(dev, fep->ev_napi_rx);
+			(*fep->ops->napi_disable)(dev);
+			(*fep->ops->clear_int_events)(dev, fep->ev_napi);
 
 			/* NOTE: it is possible for FCCs in NAPI mode    */
 			/* to submit a spurious interrupt while in poll  */
@@ -369,17 +343,6 @@ fs_enet_interrupt(int irq, void *dev_id)
 				__napi_schedule(&fep->napi);
 		}
 
-		if (int_events & fep->ev_tx) {
-			napi_ok = napi_schedule_prep(&fep->napi_tx);
-
-			(*fep->ops->napi_disable_tx)(dev);
-			(*fep->ops->clear_int_events)(dev, fep->ev_napi_tx);
-
-			/* NOTE: it is possible for FCCs in NAPI mode    */
-			/* to submit a spurious interrupt while in poll  */
-			if (napi_ok)
-				__napi_schedule(&fep->napi_tx);
-		}
 	}
 
 	handled = nr > 0;
@@ -659,7 +622,8 @@ static void fs_timeout(struct net_device *dev)
 	}
 
 	phy_start(dev->phydev);
-	wake = fep->tx_free && !(CBDR_SC(fep->cur_tx) & BD_ENET_TX_READY);
+	wake = fep->tx_free >= MAX_SKB_FRAGS &&
+	       !(CBDR_SC(fep->cur_tx) & BD_ENET_TX_READY);
 	spin_unlock_irqrestore(&fep->lock, flags);
 
 	if (wake)
@@ -751,11 +715,10 @@ static int fs_enet_open(struct net_device *dev)
 	int err;
 
 	/* to initialize the fep->cur_rx,... */
-	/* not doing this, will cause a crash in fs_enet_rx_napi */
+	/* not doing this, will cause a crash in fs_enet_napi */
 	fs_init_bds(fep->ndev);
 
 	napi_enable(&fep->napi);
-	napi_enable(&fep->napi_tx);
 
 	/* Install our interrupt handler. */
 	r = request_irq(fep->interrupt, fs_enet_interrupt, IRQF_SHARED,
@@ -763,7 +726,6 @@ static int fs_enet_open(struct net_device *dev)
 	if (r != 0) {
 		dev_err(fep->dev, "Could not allocate FS_ENET IRQ!");
 		napi_disable(&fep->napi);
-		napi_disable(&fep->napi_tx);
 		return -EINVAL;
 	}
 
@@ -771,7 +733,6 @@ static int fs_enet_open(struct net_device *dev)
 	if (err) {
 		free_irq(fep->interrupt, dev);
 		napi_disable(&fep->napi);
-		napi_disable(&fep->napi_tx);
 		return err;
 	}
 	phy_start(dev->phydev);
@@ -789,7 +750,6 @@ static int fs_enet_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
 	napi_disable(&fep->napi);
-	napi_disable(&fep->napi_tx);
 	phy_stop(dev->phydev);
 
 	spin_lock_irqsave(&fep->lock, flags);
@@ -1024,8 +984,7 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	ndev->netdev_ops = &fs_enet_netdev_ops;
 	ndev->watchdog_timeo = 2 * HZ;
-	netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi, fpi->napi_weight);
-	netif_tx_napi_add(ndev, &fep->napi_tx, fs_enet_tx_napi, 2);
+	netif_napi_add(ndev, &fep->napi, fs_enet_napi, fpi->napi_weight);
 
 	ndev->ethtool_ops = &fs_ethtool_ops;
 
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
index e29f54a..fee24c8 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
@@ -81,12 +81,9 @@ struct fs_ops {
 	void (*adjust_link)(struct net_device *dev);
 	void (*restart)(struct net_device *dev);
 	void (*stop)(struct net_device *dev);
-	void (*napi_clear_rx_event)(struct net_device *dev);
-	void (*napi_enable_rx)(struct net_device *dev);
-	void (*napi_disable_rx)(struct net_device *dev);
-	void (*napi_clear_tx_event)(struct net_device *dev);
-	void (*napi_enable_tx)(struct net_device *dev);
-	void (*napi_disable_tx)(struct net_device *dev);
+	void (*napi_clear_event)(struct net_device *dev);
+	void (*napi_enable)(struct net_device *dev);
+	void (*napi_disable)(struct net_device *dev);
 	void (*rx_bd_done)(struct net_device *dev);
 	void (*tx_kickstart)(struct net_device *dev);
 	u32 (*get_int_events)(struct net_device *dev);
@@ -122,7 +119,6 @@ struct phy_info {
 
 struct fs_enet_private {
 	struct napi_struct napi;
-	struct napi_struct napi_tx;
 	struct device *dev;	/* pointer back to the device (must be initialized first) */
 	struct net_device *ndev;
 	spinlock_t lock;	/* during all ops except TX pckt processing */
@@ -152,10 +148,8 @@ struct fs_enet_private {
 	int oldduplex, oldspeed, oldlink;	/* current settings */
 
 	/* event masks */
-	u32 ev_napi_rx;		/* mask of NAPI rx events */
-	u32 ev_napi_tx;		/* mask of NAPI rx events */
-	u32 ev_rx;		/* rx event mask          */
-	u32 ev_tx;		/* tx event mask          */
+	u32 ev_napi;		/* mask of NAPI events */
+	u32 ev;			/* event mask          */
 	u32 ev_err;		/* error event mask       */
 
 	u16 bd_rx_empty;	/* mask of BD rx empty	  */
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
index d71761a..7919896 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
@@ -124,10 +124,8 @@ out:
 	return ret;
 }
 
-#define FCC_NAPI_RX_EVENT_MSK	(FCC_ENET_RXF | FCC_ENET_RXB)
-#define FCC_NAPI_TX_EVENT_MSK	(FCC_ENET_TXB)
-#define FCC_RX_EVENT		(FCC_ENET_RXF)
-#define FCC_TX_EVENT		(FCC_ENET_TXB)
+#define FCC_NAPI_EVENT_MSK	(FCC_ENET_RXF | FCC_ENET_RXB | FCC_ENET_TXB)
+#define FCC_EVENT		(FCC_ENET_RXF | FCC_ENET_TXB)
 #define FCC_ERR_EVENT_MSK	(FCC_ENET_TXE)
 
 static int setup_data(struct net_device *dev)
@@ -137,10 +135,8 @@ static int setup_data(struct net_device *dev)
 	if (do_pd_setup(fep) != 0)
 		return -EINVAL;
 
-	fep->ev_napi_rx = FCC_NAPI_RX_EVENT_MSK;
-	fep->ev_napi_tx = FCC_NAPI_TX_EVENT_MSK;
-	fep->ev_rx = FCC_RX_EVENT;
-	fep->ev_tx = FCC_TX_EVENT;
+	fep->ev_napi = FCC_NAPI_EVENT_MSK;
+	fep->ev = FCC_EVENT;
 	fep->ev_err = FCC_ERR_EVENT_MSK;
 
 	return 0;
@@ -424,52 +420,28 @@ static void stop(struct net_device *dev)
 	fs_cleanup_bds(dev);
 }
 
-static void napi_clear_rx_event(struct net_device *dev)
+static void napi_clear_event_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	fcc_t __iomem *fccp = fep->fcc.fccp;
 
-	W16(fccp, fcc_fcce, FCC_NAPI_RX_EVENT_MSK);
+	W16(fccp, fcc_fcce, FCC_NAPI_EVENT_MSK);
 }
 
-static void napi_enable_rx(struct net_device *dev)
+static void napi_enable_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	fcc_t __iomem *fccp = fep->fcc.fccp;
 
-	S16(fccp, fcc_fccm, FCC_NAPI_RX_EVENT_MSK);
+	S16(fccp, fcc_fccm, FCC_NAPI_EVENT_MSK);
 }
 
-static void napi_disable_rx(struct net_device *dev)
+static void napi_disable_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	fcc_t __iomem *fccp = fep->fcc.fccp;
 
-	C16(fccp, fcc_fccm, FCC_NAPI_RX_EVENT_MSK);
-}
-
-static void napi_clear_tx_event(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t __iomem *fccp = fep->fcc.fccp;
-
-	W16(fccp, fcc_fcce, FCC_NAPI_TX_EVENT_MSK);
-}
-
-static void napi_enable_tx(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t __iomem *fccp = fep->fcc.fccp;
-
-	S16(fccp, fcc_fccm, FCC_NAPI_TX_EVENT_MSK);
-}
-
-static void napi_disable_tx(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	fcc_t __iomem *fccp = fep->fcc.fccp;
-
-	C16(fccp, fcc_fccm, FCC_NAPI_TX_EVENT_MSK);
+	C16(fccp, fcc_fccm, FCC_NAPI_EVENT_MSK);
 }
 
 static void rx_bd_done(struct net_device *dev)
@@ -595,12 +567,9 @@ const struct fs_ops fs_fcc_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.napi_clear_rx_event	= napi_clear_rx_event,
-	.napi_enable_rx		= napi_enable_rx,
-	.napi_disable_rx	= napi_disable_rx,
-	.napi_clear_tx_event	= napi_clear_tx_event,
-	.napi_enable_tx		= napi_enable_tx,
-	.napi_disable_tx	= napi_disable_tx,
+	.napi_clear_event	= napi_clear_event_fs,
+	.napi_enable		= napi_enable_fs,
+	.napi_disable		= napi_disable_fs,
 	.rx_bd_done		= rx_bd_done,
 	.tx_kickstart		= tx_kickstart,
 	.get_int_events		= get_int_events,
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index 35a318e..21fbaaf 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -109,10 +109,8 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	return 0;
 }
 
-#define FEC_NAPI_RX_EVENT_MSK	(FEC_ENET_RXF | FEC_ENET_RXB)
-#define FEC_NAPI_TX_EVENT_MSK	(FEC_ENET_TXF)
-#define FEC_RX_EVENT		(FEC_ENET_RXF)
-#define FEC_TX_EVENT		(FEC_ENET_TXF)
+#define FEC_NAPI_EVENT_MSK	(FEC_ENET_RXF | FEC_ENET_RXB | FEC_ENET_TXF)
+#define FEC_EVENT		(FEC_ENET_RXF | FEC_ENET_TXF)
 #define FEC_ERR_EVENT_MSK	(FEC_ENET_HBERR | FEC_ENET_BABR | \
 				 FEC_ENET_BABT | FEC_ENET_EBERR)
 
@@ -126,10 +124,8 @@ static int setup_data(struct net_device *dev)
 	fep->fec.hthi = 0;
 	fep->fec.htlo = 0;
 
-	fep->ev_napi_rx = FEC_NAPI_RX_EVENT_MSK;
-	fep->ev_napi_tx = FEC_NAPI_TX_EVENT_MSK;
-	fep->ev_rx = FEC_RX_EVENT;
-	fep->ev_tx = FEC_TX_EVENT;
+	fep->ev_napi = FEC_NAPI_EVENT_MSK;
+	fep->ev = FEC_EVENT;
 	fep->ev_err = FEC_ERR_EVENT_MSK;
 
 	return 0;
@@ -396,52 +392,28 @@ static void stop(struct net_device *dev)
 	}
 }
 
-static void napi_clear_rx_event(struct net_device *dev)
+static void napi_clear_event_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct fec __iomem *fecp = fep->fec.fecp;
 
-	FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
+	FW(fecp, ievent, FEC_NAPI_EVENT_MSK);
 }
 
-static void napi_enable_rx(struct net_device *dev)
+static void napi_enable_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct fec __iomem *fecp = fep->fec.fecp;
 
-	FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
+	FS(fecp, imask, FEC_NAPI_EVENT_MSK);
 }
 
-static void napi_disable_rx(struct net_device *dev)
+static void napi_disable_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct fec __iomem *fecp = fep->fec.fecp;
 
-	FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
-}
-
-static void napi_clear_tx_event(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	struct fec __iomem *fecp = fep->fec.fecp;
-
-	FW(fecp, ievent, FEC_NAPI_TX_EVENT_MSK);
-}
-
-static void napi_enable_tx(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	struct fec __iomem *fecp = fep->fec.fecp;
-
-	FS(fecp, imask, FEC_NAPI_TX_EVENT_MSK);
-}
-
-static void napi_disable_tx(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	struct fec __iomem *fecp = fep->fec.fecp;
-
-	FC(fecp, imask, FEC_NAPI_TX_EVENT_MSK);
+	FC(fecp, imask, FEC_NAPI_EVENT_MSK);
 }
 
 static void rx_bd_done(struct net_device *dev)
@@ -513,12 +485,9 @@ const struct fs_ops fs_fec_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.napi_clear_rx_event	= napi_clear_rx_event,
-	.napi_enable_rx		= napi_enable_rx,
-	.napi_disable_rx	= napi_disable_rx,
-	.napi_clear_tx_event	= napi_clear_tx_event,
-	.napi_enable_tx		= napi_enable_tx,
-	.napi_disable_tx	= napi_disable_tx,
+	.napi_clear_event	= napi_clear_event_fs,
+	.napi_enable		= napi_enable_fs,
+	.napi_disable		= napi_disable_fs,
 	.rx_bd_done		= rx_bd_done,
 	.tx_kickstart		= tx_kickstart,
 	.get_int_events		= get_int_events,
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
index e8b9c33..9d52e1e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
@@ -115,10 +115,8 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	return 0;
 }
 
-#define SCC_NAPI_RX_EVENT_MSK	(SCCE_ENET_RXF | SCCE_ENET_RXB)
-#define SCC_NAPI_TX_EVENT_MSK	(SCCE_ENET_TXB)
-#define SCC_RX_EVENT		(SCCE_ENET_RXF)
-#define SCC_TX_EVENT		(SCCE_ENET_TXB)
+#define SCC_NAPI_EVENT_MSK	(SCCE_ENET_RXF | SCCE_ENET_RXB | SCCE_ENET_TXB)
+#define SCC_EVENT		(SCCE_ENET_RXF | SCCE_ENET_TXB)
 #define SCC_ERR_EVENT_MSK	(SCCE_ENET_TXE | SCCE_ENET_BSY)
 
 static int setup_data(struct net_device *dev)
@@ -130,10 +128,8 @@ static int setup_data(struct net_device *dev)
 	fep->scc.hthi = 0;
 	fep->scc.htlo = 0;
 
-	fep->ev_napi_rx = SCC_NAPI_RX_EVENT_MSK;
-	fep->ev_napi_tx = SCC_NAPI_TX_EVENT_MSK;
-	fep->ev_rx = SCC_RX_EVENT;
-	fep->ev_tx = SCC_TX_EVENT | SCCE_ENET_TXE;
+	fep->ev_napi = SCC_NAPI_EVENT_MSK;
+	fep->ev = SCC_EVENT | SCCE_ENET_TXE;
 	fep->ev_err = SCC_ERR_EVENT_MSK;
 
 	return 0;
@@ -379,52 +375,28 @@ static void stop(struct net_device *dev)
 	fs_cleanup_bds(dev);
 }
 
-static void napi_clear_rx_event(struct net_device *dev)
+static void napi_clear_event_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	scc_t __iomem *sccp = fep->scc.sccp;
 
-	W16(sccp, scc_scce, SCC_NAPI_RX_EVENT_MSK);
+	W16(sccp, scc_scce, SCC_NAPI_EVENT_MSK);
 }
 
-static void napi_enable_rx(struct net_device *dev)
+static void napi_enable_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	scc_t __iomem *sccp = fep->scc.sccp;
 
-	S16(sccp, scc_sccm, SCC_NAPI_RX_EVENT_MSK);
+	S16(sccp, scc_sccm, SCC_NAPI_EVENT_MSK);
 }
 
-static void napi_disable_rx(struct net_device *dev)
+static void napi_disable_fs(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	scc_t __iomem *sccp = fep->scc.sccp;
 
-	C16(sccp, scc_sccm, SCC_NAPI_RX_EVENT_MSK);
-}
-
-static void napi_clear_tx_event(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t __iomem *sccp = fep->scc.sccp;
-
-	W16(sccp, scc_scce, SCC_NAPI_TX_EVENT_MSK);
-}
-
-static void napi_enable_tx(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t __iomem *sccp = fep->scc.sccp;
-
-	S16(sccp, scc_sccm, SCC_NAPI_TX_EVENT_MSK);
-}
-
-static void napi_disable_tx(struct net_device *dev)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-	scc_t __iomem *sccp = fep->scc.sccp;
-
-	C16(sccp, scc_sccm, SCC_NAPI_TX_EVENT_MSK);
+	C16(sccp, scc_sccm, SCC_NAPI_EVENT_MSK);
 }
 
 static void rx_bd_done(struct net_device *dev)
@@ -497,12 +469,9 @@ const struct fs_ops fs_scc_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.napi_clear_rx_event	= napi_clear_rx_event,
-	.napi_enable_rx		= napi_enable_rx,
-	.napi_disable_rx	= napi_disable_rx,
-	.napi_clear_tx_event	= napi_clear_tx_event,
-	.napi_enable_tx		= napi_enable_tx,
-	.napi_disable_tx	= napi_disable_tx,
+	.napi_clear_event	= napi_clear_event_fs,
+	.napi_enable		= napi_enable_fs,
+	.napi_disable		= napi_disable_fs,
 	.rx_bd_done		= rx_bd_done,
 	.tx_kickstart		= tx_kickstart,
 	.get_int_events		= get_int_events,
-- 
2.1.0
