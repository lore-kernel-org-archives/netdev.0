From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Wed,  7 Dec 2016 21:05:38 +0100
Message-ID: <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: pavel@ucw.cz, davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver uses a private lock for synchronization between the xmit
function and the xmit completion handler, but since the NETIF_F_LLTX flag
is not set, the xmit function is also called with the xmit_lock held.

On the other hand the xmit completion handler first takes the private lock
and (in case that the tx queue has been stopped) the xmit_lock, leading to
a reverse locking order and the potential danger of a deadlock.

Fix this by removing the private lock completely and synchronizing the xmit
function and completion handler solely by means of the xmit_lock. By doing
this remove also the now unnecessary double check for a stopped tx queue.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 28 +++++------------------
 2 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 4d2a759..7e69b11 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -64,7 +64,6 @@ struct stmmac_priv {
 	dma_addr_t dma_tx_phy;
 	int tx_coalesce;
 	int hwts_tx_en;
-	spinlock_t tx_lock;
 	bool tx_path_in_lpi_mode;
 	struct timer_list txtimer;
 	bool tso;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index caf069a..db46ec4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1307,7 +1307,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	unsigned int bytes_compl = 0, pkts_compl = 0;
 	unsigned int entry = priv->dirty_tx;
 
-	spin_lock(&priv->tx_lock);
+	netif_tx_lock(priv->dev);
 
 	priv->xstats.tx_clean++;
 
@@ -1378,22 +1378,17 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
 
 	if (unlikely(netif_queue_stopped(priv->dev) &&
-		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
-		netif_tx_lock(priv->dev);
-		if (netif_queue_stopped(priv->dev) &&
-		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
-			if (netif_msg_tx_done(priv))
-				pr_debug("%s: restart transmit\n", __func__);
-			netif_wake_queue(priv->dev);
-		}
-		netif_tx_unlock(priv->dev);
+	    stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: restart transmit\n", __func__);
+		netif_wake_queue(priv->dev);
 	}
 
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
 		stmmac_enable_eee_mode(priv);
 		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_T(eee_timer));
 	}
-	spin_unlock(&priv->tx_lock);
+	netif_tx_unlock(priv->dev);
 }
 
 static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
@@ -1998,8 +1993,6 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 proto_hdr_len;
 	int i;
 
-	spin_lock(&priv->tx_lock);
-
 	/* Compute header lengths */
 	proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 
@@ -2011,7 +2004,6 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* This is a hard error, log it. */
 			pr_err("%s: Tx Ring full when queue awake\n", __func__);
 		}
-		spin_unlock(&priv->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2146,11 +2138,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
 				       STMMAC_CHAN0);
 
-	spin_unlock(&priv->tx_lock);
 	return NETDEV_TX_OK;
 
 dma_map_err:
-	spin_unlock(&priv->tx_lock);
 	dev_err(priv->device, "Tx dma map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
@@ -2182,10 +2172,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			return stmmac_tso_xmit(skb, dev);
 	}
 
-	spin_lock(&priv->tx_lock);
-
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
-		spin_unlock(&priv->tx_lock);
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
@@ -2357,11 +2344,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
 					       STMMAC_CHAN0);
 
-	spin_unlock(&priv->tx_lock);
 	return NETDEV_TX_OK;
 
 dma_map_err:
-	spin_unlock(&priv->tx_lock);
 	dev_err(priv->device, "Tx dma map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
@@ -3347,7 +3332,6 @@ int stmmac_dvr_probe(struct device *device,
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
 
 	spin_lock_init(&priv->lock);
-	spin_lock_init(&priv->tx_lock);
 
 	ret = register_netdev(ndev);
 	if (ret) {
-- 
1.9.1
