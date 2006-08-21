From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 17/18] d80211:  surface powersave debug switch
Date: Mon, 21 Aug 2006 09:41:24 +0200
Message-ID: <20060821075202.804894178@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:1217 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030353AbWHUIC0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:26 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-ps-debug.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the verbose powersave debugging
visible in Kconfig.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/Kconfig	2006-08-20 17:41:50.828192788 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-20 17:42:43.448192788 +0200
@@ -59,3 +59,10 @@ config D80211_IBSS_DEBUG
 	depends on D80211_DEBUG
 	---help---
 	  Say Y here if you intend to debug the IBSS code.
+
+config D80211_VERBOSE_PS_DEBUG
+	bool "Verbose powersave mode debugging"
+	depends on D80211_DEBUG
+	---help---
+	  Say Y here to print out verbose powersave
+	  mode debug messages.
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 17:41:19.968192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 17:41:39.448192788 +0200
@@ -1014,12 +1014,12 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 
 	if (unlikely((sta->flags & WLAN_STA_PS) && !sta->pspoll)) {
 		struct ieee80211_tx_packet_data *pkt_data;
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 		printk(KERN_DEBUG "STA " MAC_FMT " aid %d: PS buffer (entries "
 		       "before %d)\n",
 		       MAC_ARG(sta->addr), sta->aid,
 		       skb_queue_len(&sta->ps_tx_buf));
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 		sta->flags |= WLAN_STA_TIM;
 		if (tx->local->total_ps_buffered >= TOTAL_MAX_TX_BUFFER)
 			purge_old_ps_buffers(tx->local);
@@ -1045,13 +1045,13 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
                 skb_queue_tail(&sta->ps_tx_buf, tx->skb);
 		return TXRX_QUEUED;
 	}
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 	else if (unlikely(sta->flags & WLAN_STA_PS)) {
 		printk(KERN_DEBUG "%s: STA " MAC_FMT " in PS mode, but pspoll "
 		       "set -> send frame\n", tx->dev->name,
 		       MAC_ARG(sta->addr));
 	}
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 	sta->pspoll = 0;
 
 	return TXRX_CONTINUE;
@@ -2669,10 +2669,10 @@ static void ap_sta_ps_start(struct net_d
 		atomic_inc(&sdata->bss->num_sta_ps);
 	sta->flags |= WLAN_STA_PS;
 	sta->pspoll = 0;
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 	printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d enters power "
 	       "save mode\n", dev->name, MAC_ARG(sta->addr), sta->aid);
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 }
 
 
@@ -2695,10 +2695,10 @@ static int ap_sta_ps_end(struct net_devi
 		if (sdata->bss)
 			bss_tim_clear(local, sdata->bss, sta->aid);
 	}
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 	printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d exits power "
 	       "save mode\n", dev->name, MAC_ARG(sta->addr), sta->aid);
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 	/* Send all buffered frames to the station */
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
@@ -2710,11 +2710,11 @@ static int ap_sta_ps_end(struct net_devi
 		pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 		local->total_ps_buffered--;
 		sent++;
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 		printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d send PS frame "
 		       "since STA not sleeping anymore\n", dev->name,
 		       MAC_ARG(sta->addr), sta->aid);
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 		pkt_data->requeue = 1;
 		dev_queue_xmit(skb);
 	}
@@ -2752,12 +2752,12 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 		 * still remain is PS mode after this frame exchange */
 		rx->sta->pspoll = 1;
 
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 		printk(KERN_DEBUG "STA " MAC_FMT " aid %d: PS Poll (entries "
 		       "after %d)\n",
 		       MAC_ARG(rx->sta->addr), rx->sta->aid,
 		       skb_queue_len(&rx->sta->ps_tx_buf));
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 
 		/* Use MoreData flag to indicate whether there are more
 		 * buffered frames for this STA */
@@ -2781,12 +2781,12 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 					      rx->sdata->bss,
 					      rx->sta->aid);
 		}
-#ifdef IEEE80211_VERBOSE_DEBUG_PS
+#ifdef CONFIG_D80211_VERBOSE_PS_DEBUG
 	} else if (!rx->u.rx.sent_ps_buffered) {
 		printk(KERN_DEBUG "%s: STA " MAC_FMT " sent PS Poll even "
 		       "though there is no buffered frames for it\n",
 		       rx->dev->name, MAC_ARG(rx->sta->addr));
-#endif /* IEEE80211_VERBOSE_DEBUG_PS */
+#endif /* CONFIG_D80211_VERBOSE_PS_DEBUG */
 
 	}
 

--
