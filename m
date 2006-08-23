From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 13/21] d80211: surface powersave debug switch
Date: Wed, 23 Aug 2006 21:24:22 +0200 (CEST)
Message-ID: <20060823192422.48F7E483B1@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:29904 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965126AbWHWTYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:22 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch makes the verbose powersave debugging
visible in Kconfig.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Kconfig     |    7 +++++++
 net/d80211/ieee80211.c |   28 ++++++++++++++--------------
 2 files changed, 21 insertions(+), 14 deletions(-)

505c84c433dd4185c987844a10baf24fada3620d
diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index ae39e6e..2f3c0a3 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -51,3 +51,10 @@ config D80211_IBSS_DEBUG
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
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 96ef85a..ad37015 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1026,12 +1026,12 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 
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
@@ -1057,13 +1057,13 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
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
@@ -2689,10 +2689,10 @@ static void ap_sta_ps_start(struct net_d
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
 
 
@@ -2715,10 +2715,10 @@ static int ap_sta_ps_end(struct net_devi
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
@@ -2730,11 +2730,11 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
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
@@ -2772,12 +2772,12 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
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
@@ -2795,12 +2795,12 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 			if (rx->sdata->bss)
 				bss_tim_clear(rx->local, rx->sdata->bss, rx->sta->aid);
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
1.3.0

