From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 75/77] hostap: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:42 -0700
Message-ID: <20090321053718.302886142@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, j@w1.fi
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=hostap-stats.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use pre-existing net_device_stats in network_device struct.

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

---
 drivers/net/wireless/hostap/hostap_80211_rx.c |   19 ++++++-------------
 drivers/net/wireless/hostap/hostap_ap.c       |    2 +-
 drivers/net/wireless/hostap/hostap_hw.c       |   12 ++++--------
 drivers/net/wireless/hostap/hostap_main.c     |   10 ----------
 drivers/net/wireless/hostap/hostap_wlan.h     |    1 -
 5 files changed, 11 insertions(+), 33 deletions(-)

--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2009-03-20 21:24:29.727901352 -0700
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2009-03-20 21:25:28.499088945 -0700
@@ -207,13 +207,11 @@ hdr->f.status = s; hdr->f.len = l; hdr->
 static void monitor_rx(struct net_device *dev, struct sk_buff *skb,
 		       struct hostap_80211_rx_status *rx_stats)
 {
-	struct net_device_stats *stats;
 	int len;
 
 	len = prism2_rx_80211(dev, skb, rx_stats, PRISM2_RX_MONITOR);
-	stats = hostap_get_stats(dev);
-	stats->rx_packets++;
-	stats->rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 }
 
 
@@ -724,7 +722,6 @@ void hostap_80211_rx(struct net_device *
 	size_t hdrlen;
 	u16 fc, type, stype, sc;
 	struct net_device *wds = NULL;
-	struct net_device_stats *stats;
 	unsigned int frag;
 	u8 *payload;
 	struct sk_buff *skb2 = NULL;
@@ -748,7 +745,6 @@ void hostap_80211_rx(struct net_device *
 	iface = netdev_priv(dev);
 
 	hdr = (struct ieee80211_hdr *) skb->data;
-	stats = hostap_get_stats(dev);
 
 	if (skb->len < 10)
 		goto rx_dropped;
@@ -866,10 +862,8 @@ void hostap_80211_rx(struct net_device *
 
 	if (hostap_rx_frame_wds(local, hdr, fc, &wds))
 		goto rx_dropped;
-	if (wds) {
+	if (wds)
 		skb->dev = dev = wds;
-		stats = hostap_get_stats(dev);
-	}
 
 	if (local->iw_mode == IW_MODE_MASTER && !wds &&
 	    (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
@@ -878,7 +872,6 @@ void hostap_80211_rx(struct net_device *
 	    memcmp(hdr->addr2, local->assoc_ap_addr, ETH_ALEN) == 0) {
 		/* Frame from BSSID of the AP for which we are a client */
 		skb->dev = dev = local->stadev;
-		stats = hostap_get_stats(dev);
 		from_assoc_ap = 1;
 	}
 
@@ -1069,8 +1062,8 @@ void hostap_80211_rx(struct net_device *
 		skb_trim(skb, skb->len - ETH_ALEN);
 	}
 
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	if (local->iw_mode == IW_MODE_MASTER && !wds &&
 	    local->ap->bridge_packets) {
@@ -1115,7 +1108,7 @@ void hostap_80211_rx(struct net_device *
  rx_dropped:
 	dev_kfree_skb(skb);
 
-	stats->rx_dropped++;
+	dev->stats.rx_dropped++;
 	goto rx_exit;
 }
 
--- a/drivers/net/wireless/hostap/hostap_hw.c	2009-03-20 21:24:29.735901559 -0700
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2009-03-20 21:36:12.541714768 -0700
@@ -1682,7 +1682,7 @@ static int prism2_get_txfid_idx(local_in
 
 	PDEBUG(DEBUG_EXTRA2, "prism2_get_txfid_idx: no room in txfid buf: "
 	       "packet dropped\n");
-	local->stats.tx_dropped++;
+	local->dev->stats.tx_dropped++;
 
 	return -1;
 }
@@ -1787,11 +1787,9 @@ static int prism2_transmit(struct net_de
 		prism2_transmit_cb, (long) idx);
 
 	if (res) {
-		struct net_device_stats *stats;
 		printk(KERN_DEBUG "%s: prism2_transmit: CMDCODE_TRANSMIT "
 		       "failed (res=%d)\n", dev->name, res);
-		stats = hostap_get_stats(dev);
-		stats->tx_dropped++;
+		dev->stats.tx_dropped++;
 		netif_wake_queue(dev);
 		return -1;
 	}
@@ -1939,12 +1937,10 @@ static void prism2_rx(local_info_t *loca
 	struct net_device *dev = local->dev;
 	int res, rx_pending = 0;
 	u16 len, hdr_len, rxfid, status, macport;
-	struct net_device_stats *stats;
 	struct hfa384x_rx_frame rxdesc;
 	struct sk_buff *skb = NULL;
 
 	prism2_callback(local, PRISM2_CALLBACK_RX_START);
-	stats = hostap_get_stats(dev);
 
 	rxfid = prism2_read_fid_reg(dev, HFA384X_RXFID_OFF);
 #ifndef final_version
@@ -2031,7 +2027,7 @@ static void prism2_rx(local_info_t *loca
 	return;
 
  rx_dropped:
-	stats->rx_dropped++;
+	dev->stats.rx_dropped++;
 	if (skb)
 		dev_kfree_skb(skb);
 	goto rx_exit;
@@ -2335,7 +2331,7 @@ static void prism2_txexc(local_info_t *l
 	struct hfa384x_tx_frame txdesc;
 
 	show_dump = local->frame_dump & PRISM2_DUMP_TXEXC_HDR;
-	local->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	res = hostap_tx_compl_read(local, 1, &txdesc, &payload);
 	HFA384X_OUTW(HFA384X_EV_TXEXC, HFA384X_EVACK_OFF);
--- a/drivers/net/wireless/hostap/hostap_main.c	2009-03-20 21:24:29.713901614 -0700
+++ b/drivers/net/wireless/hostap/hostap_main.c	2009-03-20 21:36:12.533715392 -0700
@@ -607,14 +607,6 @@ int hostap_80211_get_hdrlen(__le16 fc)
 }
 
 
-struct net_device_stats *hostap_get_stats(struct net_device *dev)
-{
-	struct hostap_interface *iface;
-	iface = netdev_priv(dev);
-	return &iface->stats;
-}
-
-
 static int prism2_close(struct net_device *dev)
 {
 	struct hostap_interface *iface;
@@ -832,7 +824,6 @@ void hostap_setup_dev(struct net_device 
 	ether_setup(dev);
 
 	/* kernel callbacks */
-	dev->get_stats = hostap_get_stats;
 	if (iface) {
 		/* Currently, we point to the proper spy_data only on
 		 * the main_dev. This could be fixed. Jean II */
@@ -1112,7 +1103,6 @@ EXPORT_SYMBOL(hostap_set_auth_algs);
 EXPORT_SYMBOL(hostap_dump_rx_header);
 EXPORT_SYMBOL(hostap_dump_tx_header);
 EXPORT_SYMBOL(hostap_80211_get_hdrlen);
-EXPORT_SYMBOL(hostap_get_stats);
 EXPORT_SYMBOL(hostap_setup_dev);
 EXPORT_SYMBOL(hostap_set_multicast_list_queue);
 EXPORT_SYMBOL(hostap_set_hostapd);
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2009-03-20 21:24:29.722901695 -0700
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2009-03-20 21:25:28.500088879 -0700
@@ -684,7 +684,6 @@ struct local_info {
 	u16 channel_mask; /* mask of allowed channels */
 	u16 scan_channel_mask; /* mask of channels to be scanned */
 	struct comm_tallies_sums comm_tallies;
-	struct net_device_stats stats;
 	struct proc_dir_entry *proc;
 	int iw_mode; /* operating mode (IW_MODE_*) */
 	int pseudo_adhoc; /* 0: IW_MODE_ADHOC is real 802.11 compliant IBSS
--- a/drivers/net/wireless/hostap/hostap_ap.c	2009-03-20 21:24:29.718901717 -0700
+++ b/drivers/net/wireless/hostap/hostap_ap.c	2009-03-20 21:25:28.501088825 -0700
@@ -2262,7 +2262,7 @@ void hostap_rx(struct net_device *dev, s
 	if (skb->len < 16)
 		goto drop;
 
-	local->stats.rx_packets++;
+	dev->stats.rx_packets++;
 
 	hdr = (struct ieee80211_hdr *) skb->data;
 

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
