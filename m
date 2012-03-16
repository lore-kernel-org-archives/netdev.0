From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 5/5] net: sh_eth: use NAPI
Date: Fri, 16 Mar 2012 17:46:18 +0900
Message-ID: <4F62FDDA.9070708@renesas.com>
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
 drivers/net/ethernet/renesas/sh_eth.c |   88 +++++++++++++++++++++++----------
 drivers/net/ethernet/renesas/sh_eth.h |    3 +
 2 files changed, 64 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 62458d9..02878af 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -871,7 +871,7 @@ static int sh_eth_txfree(struct net_device *ndev)
 		if (mdp->tx_skbuff[entry]) {
 			dma_unmap_single(&ndev->dev, txdesc->addr,
 					 txdesc->buffer_length, DMA_TO_DEVICE);
-			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
+			dev_kfree_skb(mdp->tx_skbuff[entry]);
 			mdp->tx_skbuff[entry] = NULL;
 			freeNum++;
 		}
@@ -886,7 +886,7 @@ static int sh_eth_txfree(struct net_device *ndev)
 }

 /* Packet receive function */
-static int sh_eth_rx(struct net_device *ndev)
+static int sh_eth_rx(struct net_device *ndev, int *work, int budget)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_rxdesc *rxdesc;
@@ -898,7 +898,8 @@ static int sh_eth_rx(struct net_device *ndev)
 	u32 desc_status;

 	rxdesc = &mdp->rx_ring[entry];
-	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
+	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT)) &&
+	       *work < budget) {
 		desc_status = edmac_to_cpu(mdp, rxdesc->status);
 		pkt_len = rxdesc->frame_length;

@@ -934,13 +935,16 @@ static int sh_eth_rx(struct net_device *ndev)
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
-		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
 		entry = (++mdp->cur_rx) % RX_RING_SIZE;
 		rxdesc = &mdp->rx_ring[entry];
+		(*work)++;
 	}

 	/* Refill the Rx ring buffers. */
@@ -972,7 +976,7 @@ static int sh_eth_rx(struct net_device *ndev)

 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
+	if (*work < budget && !(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
 		/* fix the values for the next receiving */
 		mdp->cur_rx = mdp->dirty_rx = (sh_eth_read(ndev, RDFAR) -
 					       sh_eth_read(ndev, RDLAR)) >> 4;
@@ -1128,38 +1132,61 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)

 	/* Get interrpt stat */
 	intr_status = sh_eth_read(ndev, EESR);
-	/* Clear interrupt */
 	if (intr_status & (EESR_FRC | EESR_RMAF | EESR_RRF |
 			EESR_RTLF | EESR_RTSF | EESR_PRE | EESR_CERF |
 			cd->tx_check | cd->eesr_err_check)) {
-		sh_eth_write(ndev, intr_status, EESR);
+		if (napi_schedule_prep(&mdp->napi)) {
+			/* Disable all interrupts */
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
+	spin_lock(&mdp->lock);
+
+	/* Clear interrupt flags */
+	sh_eth_write(ndev, intr_status, EESR);
+
+	/* check txdesc */
+	txfree_num = sh_eth_txfree(ndev);
+	if (txfree_num)
 		netif_wake_queue(ndev);
-	}

+	/* check rxdesc */
+	sh_eth_rx(ndev, &work_done, budget);
+
+	/* check error flags */
 	if (intr_status & cd->eesr_err_check)
 		sh_eth_error(ndev, intr_status);

-other_irq:
+	/* get current interrupt flags */
+	intr_status = sh_eth_read(ndev, EESR);
 	spin_unlock(&mdp->lock);

-	return ret;
+	/* check whether the controller doesn't have any events */
+	if (!txfree_num && !(intr_status & cd->eesr_err_check) &&
+	    work_done < budget) {
+		napi_complete(napi);
+		/* Enable all interrupts */
+		sh_eth_write(ndev, cd->eesipr_value, EESIPR);
+	}
+
+	return work_done;
 }

 /* PHY state control function */
@@ -1380,6 +1407,8 @@ static int sh_eth_open(struct net_device *ndev)

 	pm_runtime_get_sync(&mdp->pdev->dev);

+	napi_enable(&mdp->napi);
+
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
 	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
@@ -1520,6 +1549,8 @@ static int sh_eth_close(struct net_device *ndev)
 		phy_disconnect(mdp->phydev);
 	}

+	napi_disable(&mdp->napi);
+
 	free_irq(ndev->irq, ndev);

 	/* Free all the skbuffs in the Rx queue. */
@@ -2152,6 +2183,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 #endif
 	sh_eth_set_default_cpu_data(mdp->cd);

+	mdp->ndev = ndev;
+	netif_napi_add(ndev, &mdp->napi, sh_eth_poll, SH_ETH_NAPI_WEIGHT);
+
 	/* set function */
 	ndev->netdev_ops = &sh_eth_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 667bdd2..9f4c91e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -31,6 +31,7 @@
 #define PKT_BUF_SZ		1538
 #define SH_ETH_TSU_TIMEOUT_MS	500
 #define SH_ETH_TSU_CAM_ENTRIES	32
+#define SH_ETH_NAPI_WEIGHT	32

 enum {
 	/* E-DMAC registers */
@@ -716,6 +717,8 @@ struct sh_eth_private {
 	int duplex;
 	int port;		/* for TSU */
 	int vlan_num_ids;	/* for VLAN tag filter */
+	struct napi_struct napi;
+	struct net_device *ndev;

 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
-- 
1.7.1
