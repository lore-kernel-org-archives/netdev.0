From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v5 6/6] net: sh_eth: use NAPI
Date: Fri, 18 May 2012 10:58:36 +0900
Message-ID: <4FB5ACCC.9050709@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies the driver to use NAPI.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 about v5:
  - fix two racing sh_eth_txfree() in sh_eth_start_xmit() and sh_eth_poll()

 drivers/net/ethernet/renesas/sh_eth.c |  109 +++++++++++++++++++++------------
 drivers/net/ethernet/renesas/sh_eth.h |    3 +
 2 files changed, 73 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c64a31c..1dc9b6e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1035,7 +1035,7 @@ static int sh_eth_txfree(struct net_device *ndev)
 }

 /* Packet receive function */
-static int sh_eth_rx(struct net_device *ndev)
+static int sh_eth_rx(struct net_device *ndev, int *work, int budget)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_rxdesc *rxdesc;
@@ -1047,7 +1047,8 @@ static int sh_eth_rx(struct net_device *ndev)
 	u32 desc_status;

 	rxdesc = &mdp->rx_ring[entry];
-	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
+	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT)) &&
+	       *work < budget) {
 		desc_status = edmac_to_cpu(mdp, rxdesc->status);
 		pkt_len = rxdesc->frame_length;

@@ -1087,13 +1088,17 @@ static int sh_eth_rx(struct net_device *ndev)
 				skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
-			netif_rx(skb);
-			ndev->stats.rx_packets++;
-			ndev->stats.rx_bytes += pkt_len;
+			if (netif_receive_skb(skb) == NET_RX_DROP) {
+				ndev->stats.rx_dropped++;
+			} else {
+				ndev->stats.rx_packets++;
+				ndev->stats.rx_bytes += pkt_len;
+			}
 		}
 		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
 		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
+		(*work)++;
 	}

 	/* Refill the Rx ring buffers. */
@@ -1125,7 +1130,7 @@ static int sh_eth_rx(struct net_device *ndev)

 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
+	if (*work < budget && !(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
 		/* fix the values for the next receiving */
 		mdp->cur_rx = mdp->dirty_rx = (sh_eth_read(ndev, RDFAR) -
 					       sh_eth_read(ndev, RDLAR)) >> 4;
@@ -1281,38 +1286,61 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)

 	/* Get interrpt stat */
 	intr_status = sh_eth_read(ndev, EESR);
-	/* Clear interrupt */
 	if (intr_status & (EESR_FRC | EESR_RMAF | EESR_RRF |
 			EESR_RTLF | EESR_RTSF | EESR_PRE | EESR_CERF |
 			cd->tx_check | cd->eesr_err_check)) {
-		sh_eth_write(ndev, intr_status, EESR);
+		if (napi_schedule_prep(&mdp->napi)) {
+			/* Disable interrupts of the channel */
+			sh_eth_write(ndev, 0, EESIPR);
+			__napi_schedule(&mdp->napi);
+		}
 		ret = IRQ_HANDLED;
-	} else
-		goto other_irq;
-
-	if (intr_status & (EESR_FRC | /* Frame recv*/
-			EESR_RMAF | /* Multi cast address recv*/
-			EESR_RRF  | /* Bit frame recv */
-			EESR_RTLF | /* Long frame recv*/
-			EESR_RTSF | /* short frame recv */
-			EESR_PRE  | /* PHY-LSI recv error */
-			EESR_CERF)){ /* recv frame CRC error */
-		sh_eth_rx(ndev);
 	}

-	/* Tx Check */
-	if (intr_status & cd->tx_check) {
-		sh_eth_txfree(ndev);
-		netif_wake_queue(ndev);
+	spin_unlock(&mdp->lock);
+
+	return ret;
+}
+
+static int sh_eth_poll(struct napi_struct *napi, int budget)
+{
+	struct sh_eth_private *mdp = container_of(napi, struct sh_eth_private,
+						  napi);
+	struct net_device *ndev = mdp->ndev;
+	struct sh_eth_cpu_data *cd = mdp->cd;
+	int work_done = 0, txfree_num;
+	u32 intr_status = sh_eth_read(ndev, EESR);
+
+	/* Clear interrupt flags */
+	sh_eth_write(ndev, intr_status, EESR);
+
+	/* check txdesc */
+	txfree_num = sh_eth_txfree(ndev);
+	if (txfree_num) {
+		netif_tx_lock(ndev);
+		if (netif_queue_stopped(ndev))
+			netif_wake_queue(ndev);
+		netif_tx_unlock(ndev);
 	}

+	/* check rxdesc */
+	sh_eth_rx(ndev, &work_done, budget);
+
+	/* check error flags */
 	if (intr_status & cd->eesr_err_check)
 		sh_eth_error(ndev, intr_status);

-other_irq:
-	spin_unlock(&mdp->lock);
+	/* get current interrupt flags */
+	intr_status = sh_eth_read(ndev, EESR);

-	return ret;
+	/* check whether this driver should call napi_complete() */
+	if (work_done < budget) {
+		napi_complete(napi);
+		/* Enable all interrupts */
+		sh_eth_write(ndev, cd->eesipr_value, EESIPR);
+	}
+
+	return work_done;
 }

 /* PHY state control function */
@@ -1545,6 +1573,7 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 		/* Stop the chip's Tx and Rx processes. */
 		sh_eth_write(ndev, 0, EDTRR);
 		sh_eth_write(ndev, 0, EDRRR);
+		napi_disable(&mdp->napi);
 		synchronize_irq(ndev->irq);
 	}

@@ -1569,6 +1598,7 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 	}

 	if (netif_running(ndev)) {
+		napi_enable(&mdp->napi);
 		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
 		/* Setting the Rx mode will start the Rx process. */
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
@@ -1600,6 +1630,8 @@ static int sh_eth_open(struct net_device *ndev)

 	pm_runtime_get_sync(&mdp->pdev->dev);

+	napi_enable(&mdp->napi);
+
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
@@ -1678,19 +1710,6 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_txdesc *txdesc;
 	u32 entry;
-	unsigned long flags;
-
-	spin_lock_irqsave(&mdp->lock, flags);
-	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
-		if (!sh_eth_txfree(ndev)) {
-			if (netif_msg_tx_queued(mdp))
-				dev_warn(&ndev->dev, "TxFD exhausted.\n");
-			netif_stop_queue(ndev);
-			spin_unlock_irqrestore(&mdp->lock, flags);
-			return NETDEV_TX_BUSY;
-		}
-	}
-	spin_unlock_irqrestore(&mdp->lock, flags);

 	entry = mdp->cur_tx % mdp->num_tx_ring;
 	mdp->tx_skbuff[entry] = skb;
@@ -1716,6 +1735,13 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (!(sh_eth_read(ndev, EDTRR) & sh_eth_get_edtrr_trns(mdp)))
 		sh_eth_write(ndev, sh_eth_get_edtrr_trns(mdp), EDTRR);

+	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
+		if (netif_msg_tx_queued(mdp)) {
+			dev_warn(&ndev->dev, "TxFD exhausted.\n");
+			netif_stop_queue(ndev);
+		}
+	}
+
 	return NETDEV_TX_OK;
 }

@@ -1739,6 +1765,8 @@ static int sh_eth_close(struct net_device *ndev)
 		phy_disconnect(mdp->phydev);
 	}

+	napi_disable(&mdp->napi);
+
 	free_irq(ndev->irq, ndev);

 	/* Free all the skbuffs in the Rx queue. */
@@ -2368,6 +2396,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 #endif
 	sh_eth_set_default_cpu_data(mdp->cd);

+	mdp->ndev = ndev;
+	netif_napi_add(ndev, &mdp->napi, sh_eth_poll, SH_ETH_NAPI_WEIGHT);
+
 	/* set function */
 	ndev->netdev_ops = &sh_eth_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index f1dbc27..93dad7b 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -35,6 +35,7 @@
 #define PKT_BUF_SZ		1538
 #define SH_ETH_TSU_TIMEOUT_MS	500
 #define SH_ETH_TSU_CAM_ENTRIES	32
+#define SH_ETH_NAPI_WEIGHT	32

 enum {
 	/* E-DMAC registers */
@@ -728,6 +729,8 @@ struct sh_eth_private {
 	int duplex;
 	int port;		/* for TSU */
 	int vlan_num_ids;	/* for VLAN tag filter */
+	struct napi_struct napi;
+	struct net_device *ndev;

 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
-- 
1.7.1
