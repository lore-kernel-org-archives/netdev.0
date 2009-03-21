From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 69/77] libertas: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:36 -0700
Message-ID: <20090321053717.836980109@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=libertas-stats.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

---
 drivers/net/wireless/libertas/dev.h   |    1 -
 drivers/net/wireless/libertas/if_cs.c |    2 +-
 drivers/net/wireless/libertas/main.c  |   26 +-------------------------
 drivers/net/wireless/libertas/rx.c    |   18 +++++++++---------
 drivers/net/wireless/libertas/tx.c    |    8 ++++----
 drivers/net/wireless/libertas/wext.c  |    2 +-
 6 files changed, 16 insertions(+), 41 deletions(-)

--- a/drivers/net/wireless/libertas/dev.h	2009-03-20 21:45:40.710964143 -0700
+++ b/drivers/net/wireless/libertas/dev.h	2009-03-20 22:26:09.127902523 -0700
@@ -109,7 +109,6 @@ struct lbs_private {
 	void *card;
 	struct net_device *dev;
 
-	struct net_device_stats stats;
 	struct net_device *mesh_dev; /* Virtual device */
 	struct net_device *rtap_net_dev;
 
--- a/drivers/net/wireless/libertas/main.c	2009-03-20 21:45:40.701964238 -0700
+++ b/drivers/net/wireless/libertas/main.c	2009-03-20 22:26:09.128902494 -0700
@@ -582,20 +582,6 @@ void lbs_host_to_card_done(struct lbs_pr
 }
 EXPORT_SYMBOL_GPL(lbs_host_to_card_done);
 
-/**
- *  @brief This function returns the network statistics
- *
- *  @param dev     A pointer to struct lbs_private structure
- *  @return 	   A pointer to net_device_stats structure
- */
-static struct net_device_stats *lbs_get_stats(struct net_device *dev)
-{
-	struct lbs_private *priv = dev->ml_priv;
-
-	lbs_deb_enter(LBS_DEB_NET);
-	return &priv->stats;
-}
-
 static int lbs_set_mac_address(struct net_device *dev, void *addr)
 {
 	int ret = 0;
@@ -1201,7 +1187,7 @@ struct lbs_private *lbs_add_card(void *c
 	dev->stop = lbs_eth_stop;
 	dev->set_mac_address = lbs_set_mac_address;
 	dev->tx_timeout = lbs_tx_timeout;
-	dev->get_stats = lbs_get_stats;
+
 	dev->watchdog_timeo = 5 * HZ;
 	dev->ethtool_ops = &lbs_ethtool_ops;
 #ifdef	WIRELESS_EXT
@@ -1443,7 +1429,6 @@ static int lbs_add_mesh(struct lbs_priva
 	mesh_dev->open = lbs_dev_open;
 	mesh_dev->hard_start_xmit = lbs_hard_start_xmit;
 	mesh_dev->stop = lbs_mesh_stop;
-	mesh_dev->get_stats = lbs_get_stats;
 	mesh_dev->set_mac_address = lbs_set_mac_address;
 	mesh_dev->ethtool_ops = &lbs_ethtool_ops;
 	memcpy(mesh_dev->dev_addr, priv->dev->dev_addr,
@@ -1648,14 +1633,6 @@ static int lbs_rtap_hard_start_xmit(stru
 	return NETDEV_TX_BUSY;
 }
 
-static struct net_device_stats *lbs_rtap_get_stats(struct net_device *dev)
-{
-	struct lbs_private *priv = dev->ml_priv;
-	lbs_deb_enter(LBS_DEB_NET);
-	return &priv->stats;
-}
-
-
 static void lbs_remove_rtap(struct lbs_private *priv)
 {
 	lbs_deb_enter(LBS_DEB_MAIN);
@@ -1689,7 +1666,6 @@ static int lbs_add_rtap(struct lbs_priva
 	rtap_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 	rtap_dev->open = lbs_rtap_open;
 	rtap_dev->stop = lbs_rtap_stop;
-	rtap_dev->get_stats = lbs_rtap_get_stats;
 	rtap_dev->hard_start_xmit = lbs_rtap_hard_start_xmit;
 	rtap_dev->ml_priv = priv;
 	SET_NETDEV_DEV(rtap_dev, priv->dev->dev.parent);
--- a/drivers/net/wireless/libertas/if_cs.c	2009-03-20 21:45:40.718964266 -0700
+++ b/drivers/net/wireless/libertas/if_cs.c	2009-03-20 22:26:09.129902588 -0700
@@ -421,7 +421,7 @@ static struct sk_buff *if_cs_receive_dat
 	len = if_cs_read16(priv->card, IF_CS_READ_LEN);
 	if (len == 0 || len > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
 		lbs_pr_err("card data buffer has invalid # of bytes (%d)\n", len);
-		priv->stats.rx_dropped++;
+		priv->dev->stats.rx_dropped++;
 		goto dat_err;
 	}
 
--- a/drivers/net/wireless/libertas/rx.c	2009-03-20 21:45:40.706964162 -0700
+++ b/drivers/net/wireless/libertas/rx.c	2009-03-20 22:26:09.129902588 -0700
@@ -168,7 +168,7 @@ int lbs_process_rxed_packet(struct lbs_p
 
 	if (skb->len < (ETH_HLEN + 8 + sizeof(struct rxpd))) {
 		lbs_deb_rx("rx err: frame received with bad length\n");
-		priv->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 		ret = 0;
 		goto done;
 	}
@@ -179,7 +179,7 @@ int lbs_process_rxed_packet(struct lbs_p
 	if (!(p_rx_pd->status & cpu_to_le16(MRVDRV_RXPD_STATUS_OK))) {
 		lbs_deb_rx("rx err: frame received with bad status\n");
 		lbs_pr_alert("rxpd not ok\n");
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		ret = 0;
 		goto done;
 	}
@@ -243,8 +243,8 @@ int lbs_process_rxed_packet(struct lbs_p
 	lbs_compute_rssi(priv, p_rx_pd);
 
 	lbs_deb_rx("rx data: size of actual packet %d\n", skb->len);
-	priv->stats.rx_bytes += skb->len;
-	priv->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
 
 	skb->protocol = eth_type_trans(skb, dev);
 	if (in_interrupt())
@@ -311,7 +311,7 @@ static int process_rxed_802_11_packet(st
 	struct sk_buff *skb)
 {
 	int ret = 0;
-
+	struct net_device *dev = priv->dev;
 	struct rx80211packethdr *p_rx_pkt;
 	struct rxpd *prxpd;
 	struct rx_radiotap_hdr radiotap_hdr;
@@ -326,7 +326,7 @@ static int process_rxed_802_11_packet(st
 
 	if (skb->len < (ETH_HLEN + 8 + sizeof(struct rxpd))) {
 		lbs_deb_rx("rx err: frame received with bad length\n");
-		priv->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 		ret = -EINVAL;
 		kfree_skb(skb);
 		goto done;
@@ -337,7 +337,7 @@ static int process_rxed_802_11_packet(st
 	 */
 	if (!(prxpd->status & cpu_to_le16(MRVDRV_RXPD_STATUS_OK))) {
 		//lbs_deb_rx("rx err: frame received with bad status\n");
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 	}
 
 	lbs_deb_rx("rx data: skb->len-sizeof(RxPd) = %d-%zd = %zd\n",
@@ -389,8 +389,8 @@ static int process_rxed_802_11_packet(st
 	lbs_compute_rssi(priv, prxpd);
 
 	lbs_deb_rx("rx data: size of actual packet %d\n", skb->len);
-	priv->stats.rx_bytes += skb->len;
-	priv->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
 
 	skb->protocol = eth_type_trans(skb, priv->rtap_net_dev);
 	netif_rx(skb);
--- a/drivers/net/wireless/libertas/tx.c	2009-03-20 21:45:40.691964095 -0700
+++ b/drivers/net/wireless/libertas/tx.c	2009-03-20 22:26:09.129902588 -0700
@@ -82,8 +82,8 @@ int lbs_hard_start_xmit(struct sk_buff *
 		       skb->len, MRVDRV_ETH_TX_PACKET_BUFFER_SIZE);
 		/* We'll never manage to send this one; drop it and return 'OK' */
 
-		priv->stats.tx_dropped++;
-		priv->stats.tx_errors++;
+		dev->stats.tx_dropped++;
+		dev->stats.tx_errors++;
 		goto free;
 	}
 
@@ -146,8 +146,8 @@ int lbs_hard_start_xmit(struct sk_buff *
 
 	lbs_deb_tx("%s lined up packet\n", __func__);
 
-	priv->stats.tx_packets++;
-	priv->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	dev->trans_start = jiffies;
 
--- a/drivers/net/wireless/libertas/wext.c	2009-03-20 21:45:40.696716266 -0700
+++ b/drivers/net/wireless/libertas/wext.c	2009-03-20 22:26:09.130903884 -0700
@@ -830,7 +830,7 @@ static struct iw_statistics *lbs_get_wir
 	quality = rssi_qual;
 
 	/* Quality by TX errors */
-	priv->wstats.discard.retries = priv->stats.tx_errors;
+	priv->wstats.discard.retries = dev->stats.tx_errors;
 
 	memset(&log, 0, sizeof(log));
 	log.hdr.size = cpu_to_le16(sizeof(log));

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
