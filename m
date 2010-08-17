From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] tehuti: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 18:12:57 +0200
Message-ID: <1282061577-19484-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:34249 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757274Ab0HQQNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 12:13:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the bdx_priv struct.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/tehuti.c |   17 ++++++++---------
 drivers/net/tehuti.h |    1 -
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 737df60..663a4e7 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -929,9 +929,7 @@ static void bdx_update_stats(struct bdx_priv *priv)
 
 static struct net_device_stats *bdx_get_stats(struct net_device *ndev)
 {
-	struct bdx_priv *priv = netdev_priv(ndev);
-	struct net_device_stats *net_stat = &priv->net_stats;
-	return net_stat;
+	return &ndev->stats;
 }
 
 static void print_rxdd(struct rxd_desc *rxdd, u32 rxd_val1, u16 len,
@@ -1220,6 +1218,7 @@ static void bdx_recycle_skb(struct bdx_priv *priv, struct rxd_desc *rxdd)
 
 static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 {
+	struct net_device *ndev = priv->ndev;
 	struct sk_buff *skb, *skb2;
 	struct rxd_desc *rxdd;
 	struct rx_map *dm;
@@ -1273,7 +1272,7 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 
 		if (unlikely(GET_RXD_ERR(rxd_val1))) {
 			DBG("rxd_err = 0x%x\n", GET_RXD_ERR(rxd_val1));
-			priv->net_stats.rx_errors++;
+			ndev->stats.rx_errors++;
 			bdx_recycle_skb(priv, rxdd);
 			continue;
 		}
@@ -1300,11 +1299,11 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 			bdx_rxdb_free_elem(db, rxdd->va_lo);
 		}
 
-		priv->net_stats.rx_bytes += len;
+		ndev->stats.rx_bytes += len;
 
 		skb_put(skb, len);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		skb->protocol = eth_type_trans(skb, priv->ndev);
+		skb->protocol = eth_type_trans(skb, ndev);
 
 		/* Non-IP packets aren't checksum-offloaded */
 		if (GET_RXD_PKT_ID(rxd_val1) == 0)
@@ -1316,7 +1315,7 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 			break;
 	}
 
-	priv->net_stats.rx_packets += done;
+	ndev->stats.rx_packets += done;
 
 	/* FIXME: do smth to minimize pci accesses    */
 	WRITE_REG(priv, f->m.reg_RPTR, f->m.rptr & TXF_WPTR_WR_PTR);
@@ -1712,8 +1711,8 @@ static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
 #ifdef BDX_LLTX
 	ndev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 #endif
-	priv->net_stats.tx_packets++;
-	priv->net_stats.tx_bytes += skb->len;
+	ndev->stats.tx_packets++;
+	ndev->stats.tx_bytes += skb->len;
 
 	if (priv->tx_level < BDX_MIN_TX_LEVEL) {
 		DBG("%s: %s: TX Q STOP level %d\n",
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index 67e3b71..b6ba860 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -269,7 +269,6 @@ struct bdx_priv {
 	u32 msg_enable;
 	int stats_flag;
 	struct bdx_stats hw_stats;
-	struct net_device_stats net_stats;
 	struct pci_dev *pdev;
 
 	struct pci_nic *nic;
-- 
1.7.0.4

