From: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Subject: [PATCH] orinoco:  Use net_device_stats from struct net_device
Date: Fri, 10 Feb 2017 14:03:13 +0100
Message-ID: <20170210130313.27821-1-tklauser@distanz.ch>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of using a private copy of struct net_device_stats in
struct orinoco_private, use stats from struct net_device. Also remove
the now unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
---
 drivers/net/wireless/intersil/orinoco/main.c       | 27 ++++++----------------
 drivers/net/wireless/intersil/orinoco/orinoco.h    |  2 --
 .../net/wireless/intersil/orinoco/orinoco_usb.c    |  6 ++---
 3 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/intersil/orinoco/main.c b/drivers/net/wireless/intersil/orinoco/main.c
index 9d96b7c928f7..28cf97489001 100644
--- a/drivers/net/wireless/intersil/orinoco/main.c
+++ b/drivers/net/wireless/intersil/orinoco/main.c
@@ -294,14 +294,6 @@ int orinoco_stop(struct net_device *dev)
 }
 EXPORT_SYMBOL(orinoco_stop);
 
-struct net_device_stats *orinoco_get_stats(struct net_device *dev)
-{
-	struct orinoco_private *priv = ndev_priv(dev);
-
-	return &priv->stats;
-}
-EXPORT_SYMBOL(orinoco_get_stats);
-
 void orinoco_set_multicast_list(struct net_device *dev)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
@@ -433,7 +425,7 @@ EXPORT_SYMBOL(orinoco_process_xmit_skb);
 static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct hermes *hw = &priv->hw;
 	int err = 0;
 	u16 txfid = priv->txfid;
@@ -593,10 +585,7 @@ static void __orinoco_ev_alloc(struct net_device *dev, struct hermes *hw)
 
 static void __orinoco_ev_tx(struct net_device *dev, struct hermes *hw)
 {
-	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
-
-	stats->tx_packets++;
+	dev->stats.tx_packets++;
 
 	netif_wake_queue(dev);
 
@@ -605,8 +594,7 @@ static void __orinoco_ev_tx(struct net_device *dev, struct hermes *hw)
 
 static void __orinoco_ev_txexc(struct net_device *dev, struct hermes *hw)
 {
-	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	u16 fid = hermes_read_regn(hw, TXCOMPLFID);
 	u16 status;
 	struct hermes_txexc_data hdr;
@@ -662,7 +650,7 @@ static void __orinoco_ev_txexc(struct net_device *dev, struct hermes *hw)
 void orinoco_tx_timeout(struct net_device *dev)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct hermes *hw = &priv->hw;
 
 	printk(KERN_WARNING "%s: Tx timeout! "
@@ -749,7 +737,7 @@ static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
 	int len;
 	struct sk_buff *skb;
 	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct hermes *hw = &priv->hw;
 
 	len = le16_to_cpu(desc->data_len);
@@ -840,7 +828,7 @@ static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
 void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct iw_statistics *wstats = &priv->wstats;
 	struct sk_buff *skb = NULL;
 	u16 rxfid, status;
@@ -959,7 +947,7 @@ static void orinoco_rx(struct net_device *dev,
 		       struct sk_buff *skb)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	u16 status, fc;
 	int length;
 	struct ethhdr *hdr;
@@ -2137,7 +2125,6 @@ static const struct net_device_ops orinoco_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= orinoco_tx_timeout,
-	.ndo_get_stats		= orinoco_get_stats,
 };
 
 /* Allocate private data.
diff --git a/drivers/net/wireless/intersil/orinoco/orinoco.h b/drivers/net/wireless/intersil/orinoco/orinoco.h
index 5fa1c3e3713f..430862a6a24b 100644
--- a/drivers/net/wireless/intersil/orinoco/orinoco.h
+++ b/drivers/net/wireless/intersil/orinoco/orinoco.h
@@ -84,7 +84,6 @@ struct orinoco_private {
 
 	/* Net device stuff */
 	struct net_device *ndev;
-	struct net_device_stats stats;
 	struct iw_statistics wstats;
 
 	/* Hardware control variables */
@@ -206,7 +205,6 @@ int orinoco_process_xmit_skb(struct sk_buff *skb,
 /* Common ndo functions exported for reuse by orinoco_usb */
 int orinoco_open(struct net_device *dev);
 int orinoco_stop(struct net_device *dev);
-struct net_device_stats *orinoco_get_stats(struct net_device *dev);
 void orinoco_set_multicast_list(struct net_device *dev);
 int orinoco_change_mtu(struct net_device *dev, int new_mtu);
 void orinoco_tx_timeout(struct net_device *dev);
diff --git a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
index bca6935a94db..98e1380b9917 100644
--- a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
@@ -403,8 +403,7 @@ static void ezusb_ctx_complete(struct request_context *ctx)
 
 		if ((ctx->out_rid == EZUSB_RID_TX) && upriv->dev) {
 			struct net_device *dev = upriv->dev;
-			struct orinoco_private *priv = ndev_priv(dev);
-			struct net_device_stats *stats = &priv->stats;
+			struct net_device_stats *stats = &dev->stats;
 
 			if (ctx->state != EZUSB_CTX_COMPLETE)
 				stats->tx_errors++;
@@ -1183,7 +1182,7 @@ static int ezusb_program(struct hermes *hw, const char *buf,
 static netdev_tx_t ezusb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct orinoco_private *priv = ndev_priv(dev);
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct ezusb_priv *upriv = priv->card;
 	u8 mic[MICHAEL_MIC_LEN + 1];
 	int err = 0;
@@ -1556,7 +1555,6 @@ static const struct net_device_ops ezusb_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= orinoco_tx_timeout,
-	.ndo_get_stats		= orinoco_get_stats,
 };
 
 static int ezusb_probe(struct usb_interface *interface,
-- 
2.11.0
