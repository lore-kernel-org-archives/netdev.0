From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [BUG] kernel BUG at net/core/dev.c:1328!
Date: Tue, 22 Jul 2008 15:56:11 -0700 (PDT)
Message-ID: <20080722.155611.176476925.davem@davemloft.net>
References: <d4b984a30807210914nd4d0db5yb7b93ca5143ff0d5@mail.gmail.com>
	<20080721.092027.14394005.davem@davemloft.net>
	<d4b984a30807220254t1aaf6ac4q874329966511b0c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ag-CnKWz401HL/3u/SXJKErtNrkRsMOXBsj@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d4b984a30807220254t1aaf6ac4q874329966511b0c5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Alessandro Guido" <ag-CnKWz401HL/3u/SXJKErtNrkRsMOXBsj@public.gmane.org>
Date: Tue, 22 Jul 2008 11:54:26 +0200

> Got a WARNING this morning (2.6.26-05752-g93ded9b) and I think it's related.

Please try this patch:

ipw2200: Call netif_*_queue() interfaces properly.

netif_carrier_{on,off}() handles starting and stopping packet
flow into the driver.  So there is no reason to invoke netif_stop_queue()
and netif_wake_queue() in response to link status events.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 6e70460..1acfbcd 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -4972,8 +4972,7 @@ static int ipw_queue_tx_reclaim(struct ipw_priv *priv,
 	}
       done:
 	if ((ipw_tx_queue_space(q) > q->low_mark) &&
-	    (qindex >= 0) &&
-	    (priv->status & STATUS_ASSOCIATED) && netif_running(priv->net_dev))
+	    (qindex >= 0))
 		netif_wake_queue(priv->net_dev);
 	used = q->first_empty - q->last_used;
 	if (used < 0)
@@ -10154,14 +10153,8 @@ static  void init_sys_config(struct ipw_sys_config *sys_config)
 
 static int ipw_net_open(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
 	IPW_DEBUG_INFO("dev->open\n");
-	/* we should be verifying the device is ready to be opened */
-	mutex_lock(&priv->mutex);
-	if (!(priv->status & STATUS_RF_KILL_MASK) &&
-	    (priv->status & STATUS_ASSOCIATED))
-		netif_start_queue(dev);
-	mutex_unlock(&priv->mutex);
+	netif_start_queue(dev);
 	return 0;
 }
 
@@ -10481,13 +10474,6 @@ static int ipw_net_hard_start_xmit(struct ieee80211_txb *txb,
 	IPW_DEBUG_TX("dev->xmit(%d bytes)\n", txb->payload_size);
 	spin_lock_irqsave(&priv->lock, flags);
 
-	if (!(priv->status & STATUS_ASSOCIATED)) {
-		IPW_DEBUG_INFO("Tx attempt while not associated.\n");
-		priv->ieee->stats.tx_carrier_errors++;
-		netif_stop_queue(dev);
-		goto fail_unlock;
-	}
-
 #ifdef CONFIG_IPW2200_PROMISCUOUS
 	if (rtap_iface && netif_running(priv->prom_net_dev))
 		ipw_handle_promiscuous_tx(priv, txb);
@@ -10499,10 +10485,6 @@ static int ipw_net_hard_start_xmit(struct ieee80211_txb *txb,
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	return ret;
-
-      fail_unlock:
-	spin_unlock_irqrestore(&priv->lock, flags);
-	return 1;
 }
 
 static struct net_device_stats *ipw_net_get_stats(struct net_device *dev)
@@ -10703,13 +10685,6 @@ static void ipw_link_up(struct ipw_priv *priv)
 	priv->last_packet_time = 0;
 
 	netif_carrier_on(priv->net_dev);
-	if (netif_queue_stopped(priv->net_dev)) {
-		IPW_DEBUG_NOTIF("waking queue\n");
-		netif_wake_queue(priv->net_dev);
-	} else {
-		IPW_DEBUG_NOTIF("starting queue\n");
-		netif_start_queue(priv->net_dev);
-	}
 
 	cancel_delayed_work(&priv->request_scan);
 	cancel_delayed_work(&priv->request_direct_scan);
@@ -10739,7 +10714,6 @@ static void ipw_link_down(struct ipw_priv *priv)
 {
 	ipw_led_link_down(priv);
 	netif_carrier_off(priv->net_dev);
-	netif_stop_queue(priv->net_dev);
 	notify_wx_assoc_event(priv);
 
 	/* Cancel any queued work ... */
@@ -11419,7 +11393,6 @@ static void ipw_down(struct ipw_priv *priv)
 	/* Clear all bits but the RF Kill */
 	priv->status &= STATUS_RF_KILL_MASK | STATUS_EXIT_PENDING;
 	netif_carrier_off(priv->net_dev);
-	netif_stop_queue(priv->net_dev);
 
 	ipw_stop_nic(priv);
 
@@ -11522,7 +11495,6 @@ static int ipw_prom_open(struct net_device *dev)
 
 	IPW_DEBUG_INFO("prom dev->open\n");
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	if (priv->ieee->iw_mode != IW_MODE_MONITOR) {
 		priv->sys_config.accept_all_data_frames = 1;
@@ -11558,7 +11530,6 @@ static int ipw_prom_stop(struct net_device *dev)
 static int ipw_prom_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	IPW_DEBUG_INFO("prom dev->xmit\n");
-	netif_stop_queue(dev);
 	return -EOPNOTSUPP;
 }
 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
