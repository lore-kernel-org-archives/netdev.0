From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC] mac80211: clean up frame receive handling
Date: Wed, 12 Dec 2007 19:24:04 +0100
Message-ID: <1197483844.6558.158.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jouni Malinen <j@w1.fi>
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[comments welcome. I really need a refresher on what the frame formats
mean but I think I did the right thing with skb->protocol here, I also
think we had a bug with rfc2042 header frames bigger than 15xx bytes and
eth_type_trans()]

This cleans up the frame receive handling. After this patch
 * EAPOL frames addressed to us or the EAPOL group address are
   always accepted regardless of whether they are encrypted or not
 * other frames from a station are dropped if PAE is enabled and
   the station is not authorized
 * unencrypted frames (except the EAPOL frames above) are dropped if
   drop_unencrypted is enabled
 * we no longer invoke eth_type_trans() as we've done most of the work
   already, this patch implements the rest of the work needed
 * port control is not done for injected packets

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
I've made a corresponding hostapd patch which is on my website
http://johannes.sipsolutions.net/patches/hostap/all/2007-12-12-17%3a18/005-eapol-on-regular-iface.patch

It works fine and is IMHO nicer than doing the eapol stuff over the
management interface.

 net/mac80211/debugfs_netdev.c  |   27 +++--------
 net/mac80211/ieee80211_i.h     |   22 +++------
 net/mac80211/ieee80211_iface.c |    1 
 net/mac80211/rx.c              |  100 ++++++++++++++++++++++-------------------
 net/mac80211/tx.c              |   10 ++--
 5 files changed, 79 insertions(+), 81 deletions(-)

--- everything.orig/net/mac80211/ieee80211_i.h	2007-12-12 16:25:05.819131294 +0100
+++ everything/net/mac80211/ieee80211_i.h	2007-12-12 16:31:58.749134385 +0100
@@ -306,11 +306,11 @@ struct ieee80211_sub_if_data {
 	unsigned int flags;
 
 	int drop_unencrypted;
-	int eapol; /* 0 = process EAPOL frames as normal data frames,
-		    * 1 = send EAPOL frames through wlan#ap to hostapd
-		    *     (default) */
-	int ieee802_1x; /* IEEE 802.1X PAE - drop packet to/from unauthorized
-			 * port */
+	/*
+	 * IEEE 802.1X Port access control in effect,
+	 * drop packets to/from unauthorized port
+	 */
+	int ieee802_1x_pac;
 
 	u16 sequence;
 
@@ -339,8 +339,7 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 			struct dentry *state;
 			struct dentry *bssid;
 			struct dentry *prev_bssid;
@@ -359,8 +358,7 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 			struct dentry *num_sta_ps;
 			struct dentry *dtim_period;
 			struct dentry *dtim_count;
@@ -374,15 +372,13 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 			struct dentry *peer;
 		} wds;
 		struct {
 			struct dentry *channel_use;
 			struct dentry *drop_unencrypted;
-			struct dentry *eapol;
-			struct dentry *ieee8021_x;
+			struct dentry *ieee802_1x_pac;
 		} vlan;
 		struct {
 			struct dentry *mode;
--- everything.orig/net/mac80211/rx.c	2007-12-12 16:25:05.849130805 +0100
+++ everything/net/mac80211/rx.c	2007-12-12 16:31:58.749134385 +0100
@@ -190,7 +190,7 @@ ieee80211_rx_monitor(struct ieee80211_lo
 		rthdr->antsignal = status->ssi;
 	}
 
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
@@ -387,18 +387,6 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		return TXRX_DROP;
 	}
 
-	if (!(rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
-		rx->skb->pkt_type = PACKET_OTHERHOST;
-	else if (compare_ether_addr(rx->dev->dev_addr, hdr->addr1) == 0)
-		rx->skb->pkt_type = PACKET_HOST;
-	else if (is_multicast_ether_addr(hdr->addr1)) {
-		if (is_broadcast_ether_addr(hdr->addr1))
-			rx->skb->pkt_type = PACKET_BROADCAST;
-		else
-			rx->skb->pkt_type = PACKET_MULTICAST;
-	} else
-		rx->skb->pkt_type = PACKET_OTHERHOST;
-
 	/* Drop disallowed frame classes based on STA auth/assoc state;
 	 * IEEE 802.11, Chap 5.5.
 	 *
@@ -967,18 +955,10 @@ ieee80211_rx_h_remove_qos_control(struct
 }
 
 static int
-ieee80211_drop_802_1x_pae(struct ieee80211_txrx_data *rx, int hdrlen)
+ieee80211_802_1x_port_control(struct ieee80211_txrx_data *rx)
 {
-	if (rx->sdata->eapol && ieee80211_is_eapol(rx->skb, hdrlen) &&
-	    rx->sdata->type != IEEE80211_IF_TYPE_STA &&
-	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH))
-		return 0;
-
-	if (unlikely(rx->sdata->ieee802_1x &&
-		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
-		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
-		     (!rx->sta || !(rx->sta->flags & WLAN_STA_AUTHORIZED)) &&
-		     !ieee80211_is_eapol(rx->skb, hdrlen))) {
+	if (unlikely(rx->sdata->ieee802_1x_pac &&
+		     (!rx->sta || !(rx->sta->flags & WLAN_STA_AUTHORIZED)))) {
 #ifdef CONFIG_MAC80211_DEBUG
 		printk(KERN_DEBUG "%s: dropped frame "
 		       "(unauthorized port)\n", rx->dev->name);
@@ -990,7 +970,7 @@ ieee80211_drop_802_1x_pae(struct ieee802
 }
 
 static int
-ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx, int hdrlen)
+ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx)
 {
 	/*
 	 * Pass through unencrypted frames if the hardware has
@@ -1003,9 +983,7 @@ ieee80211_drop_unencrypted(struct ieee80
 	if (unlikely(!(rx->fc & IEEE80211_FCTL_PROTECTED) &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
-		     (rx->key || rx->sdata->drop_unencrypted) &&
-		     (rx->sdata->eapol == 0 ||
-		      !ieee80211_is_eapol(rx->skb, hdrlen)))) {
+		     (rx->key || rx->sdata->drop_unencrypted))) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: RX non-WEP frame, but expected "
 			       "encryption\n", rx->dev->name);
@@ -1014,6 +992,24 @@ ieee80211_drop_unencrypted(struct ieee80
 	return 0;
 }
 
+static bool ieee80211_frame_allowed(struct ieee80211_txrx_data *rx)
+{
+	static const u8 pae_group_addr[ETH_ALEN]
+		= { 0x01, 0x80, 0xC2, 0x00, 0x00, 0x03 };
+	struct ethhdr *ehdr = (struct ethhdr *)rx->skb->data;
+
+	if (rx->skb->protocol == htons(ETH_P_PAE) &&
+	    (compare_ether_addr(ehdr->h_dest, pae_group_addr) == 0 ||
+	     compare_ether_addr(ehdr->h_dest, rx->dev->dev_addr) == 0))
+		return true;
+
+	if (ieee80211_802_1x_port_control(rx) ||
+	    ieee80211_drop_unencrypted(rx))
+		return false;
+
+	return true;
+}
+
 static int
 ieee80211_data_to_8023(struct ieee80211_txrx_data *rx)
 {
@@ -1130,6 +1126,7 @@ ieee80211_data_to_8023(struct ieee80211_
 		skb_pull(skb, hdrlen + 6);
 		memcpy(skb_push(skb, ETH_ALEN), src, ETH_ALEN);
 		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
+		skb->protocol = htons(ethertype);
 	} else {
 		struct ethhdr *ehdr;
 		__be16 len;
@@ -1139,6 +1136,7 @@ ieee80211_data_to_8023(struct ieee80211_
 		memcpy(ehdr->h_dest, dst, ETH_ALEN);
 		memcpy(ehdr->h_source, src, ETH_ALEN);
 		ehdr->h_proto = len;
+		skb->protocol = htons(ETH_P_802_2);
 	}
 	return 0;
 }
@@ -1150,14 +1148,27 @@ ieee80211_deliver_skb(struct ieee80211_t
 	struct ieee80211_local *local = rx->local;
 	struct sk_buff *skb, *xmit_skb;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	u8 *dst;
 
 	skb = rx->skb;
 	xmit_skb = NULL;
 
-	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
-	    || sdata->type == IEEE80211_IF_TYPE_VLAN) &&
+	dst = skb->data;
+
+	if (compare_ether_addr(dev->dev_addr, dst) == 0)
+		skb->pkt_type = PACKET_HOST;
+	else if (is_multicast_ether_addr(dst)) {
+		if (is_broadcast_ether_addr(dst))
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_MULTICAST;
+	} else
+		skb->pkt_type = PACKET_OTHERHOST;
+
+	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP ||
+				      sdata->type == IEEE80211_IF_TYPE_VLAN) &&
 	    (rx->flags & IEEE80211_TXRXD_RXRA_MATCH)) {
-		if (is_multicast_ether_addr(skb->data)) {
+		if (is_multicast_ether_addr(dst)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
 			xmit_skb = skb_copy(skb, GFP_ATOMIC);
@@ -1186,16 +1197,18 @@ ieee80211_deliver_skb(struct ieee80211_t
 
 	if (skb) {
 		/* deliver to local stack */
-		skb->protocol = eth_type_trans(skb, dev);
 		memset(skb->cb, 0, sizeof(skb->cb));
+		skb->dev = dev;
+		skb_reset_mac_header(skb);
+		skb_pull(skb, ETH_HLEN);
 		netif_rx(skb);
 	}
 
 	if (xmit_skb) {
 		/* send to wireless media */
 		xmit_skb->protocol = __constant_htons(ETH_P_802_3);
-		skb_set_network_header(xmit_skb, 0);
-		skb_set_mac_header(xmit_skb, 0);
+		skb_reset_network_header(xmit_skb);
+		skb_reset_mac_header(xmit_skb);
 		dev_queue_xmit(xmit_skb);
 	}
 }
@@ -1280,13 +1293,12 @@ ieee80211_rx_h_amsdu(struct ieee80211_tx
 			}
 		}
 
-		skb_set_network_header(frame, 0);
+		skb_reset_network_header(frame);
 		frame->dev = dev;
 		frame->priority = skb->priority;
 		rx->skb = frame;
 
-		if ((ieee80211_drop_802_1x_pae(rx, 0)) ||
-		    (ieee80211_drop_unencrypted(rx, 0))) {
+		if (!ieee80211_frame_allowed(rx)) {
 			if (skb == frame) /* last frame */
 				return TXRX_DROP;
 			dev_kfree_skb(frame);
@@ -1305,14 +1317,15 @@ ieee80211_rx_h_amsdu(struct ieee80211_tx
 			skb_pull(frame, 6);
 			memcpy(skb_push(frame, ETH_ALEN), src, ETH_ALEN);
 			memcpy(skb_push(frame, ETH_ALEN), dst, ETH_ALEN);
+			frame->protocol = htons(ethertype);
 		} else {
 			memcpy(skb_push(frame, sizeof(__be16)), &len,
 				sizeof(__be16));
 			memcpy(skb_push(frame, ETH_ALEN), src, ETH_ALEN);
 			memcpy(skb_push(frame, ETH_ALEN), dst, ETH_ALEN);
+			frame->protocol = htons(ETH_P_802_2);
 		}
 
-
 		ieee80211_deliver_skb(rx);
 	}
 
@@ -1324,7 +1337,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 {
 	struct net_device *dev = rx->dev;
 	u16 fc;
-	int err, hdrlen;
+	int err;
 
 	fc = rx->fc;
 	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
@@ -1333,16 +1346,13 @@ ieee80211_rx_h_data(struct ieee80211_txr
 	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
 		return TXRX_DROP;
 
-	hdrlen = ieee80211_get_hdrlen(fc);
-
-	if ((ieee80211_drop_802_1x_pae(rx, hdrlen)) ||
-	    (ieee80211_drop_unencrypted(rx, hdrlen)))
-		return TXRX_DROP;
-
 	err = ieee80211_data_to_8023(rx);
 	if (unlikely(err))
 		return TXRX_DROP;
 
+	if (!ieee80211_frame_allowed(rx))
+		return TXRX_DROP;
+
 	rx->skb->dev = dev;
 
 	dev->stats.rx_packets++;
--- everything.orig/net/mac80211/debugfs_netdev.c	2007-12-12 16:25:05.899132325 +0100
+++ everything/net/mac80211/debugfs_netdev.c	2007-12-12 16:31:58.759132161 +0100
@@ -91,8 +91,7 @@ static const struct file_operations name
 /* common attributes */
 IEEE80211_IF_FILE(channel_use, channel_use, DEC);
 IEEE80211_IF_FILE(drop_unencrypted, drop_unencrypted, DEC);
-IEEE80211_IF_FILE(eapol, eapol, DEC);
-IEEE80211_IF_FILE(ieee8021_x, ieee802_1x, DEC);
+IEEE80211_IF_FILE(ieee802_1x_pac, ieee802_1x_pac, DEC);
 
 /* STA/IBSS attributes */
 IEEE80211_IF_FILE(state, u.sta.state, DEC);
@@ -170,8 +169,7 @@ static void add_sta_files(struct ieee802
 {
 	DEBUGFS_ADD(channel_use, sta);
 	DEBUGFS_ADD(drop_unencrypted, sta);
-	DEBUGFS_ADD(eapol, sta);
-	DEBUGFS_ADD(ieee8021_x, sta);
+	DEBUGFS_ADD(ieee802_1x_pac, sta);
 	DEBUGFS_ADD(state, sta);
 	DEBUGFS_ADD(bssid, sta);
 	DEBUGFS_ADD(prev_bssid, sta);
@@ -192,8 +190,7 @@ static void add_ap_files(struct ieee8021
 {
 	DEBUGFS_ADD(channel_use, ap);
 	DEBUGFS_ADD(drop_unencrypted, ap);
-	DEBUGFS_ADD(eapol, ap);
-	DEBUGFS_ADD(ieee8021_x, ap);
+	DEBUGFS_ADD(ieee802_1x_pac, ap);
 	DEBUGFS_ADD(num_sta_ps, ap);
 	DEBUGFS_ADD(dtim_period, ap);
 	DEBUGFS_ADD(dtim_count, ap);
@@ -209,8 +206,7 @@ static void add_wds_files(struct ieee802
 {
 	DEBUGFS_ADD(channel_use, wds);
 	DEBUGFS_ADD(drop_unencrypted, wds);
-	DEBUGFS_ADD(eapol, wds);
-	DEBUGFS_ADD(ieee8021_x, wds);
+	DEBUGFS_ADD(ieee802_1x_pac, wds);
 	DEBUGFS_ADD(peer, wds);
 }
 
@@ -218,8 +214,7 @@ static void add_vlan_files(struct ieee80
 {
 	DEBUGFS_ADD(channel_use, vlan);
 	DEBUGFS_ADD(drop_unencrypted, vlan);
-	DEBUGFS_ADD(eapol, vlan);
-	DEBUGFS_ADD(ieee8021_x, vlan);
+	DEBUGFS_ADD(ieee802_1x_pac, vlan);
 }
 
 static void add_monitor_files(struct ieee80211_sub_if_data *sdata)
@@ -263,8 +258,7 @@ static void del_sta_files(struct ieee802
 {
 	DEBUGFS_DEL(channel_use, sta);
 	DEBUGFS_DEL(drop_unencrypted, sta);
-	DEBUGFS_DEL(eapol, sta);
-	DEBUGFS_DEL(ieee8021_x, sta);
+	DEBUGFS_DEL(ieee802_1x_pac, sta);
 	DEBUGFS_DEL(state, sta);
 	DEBUGFS_DEL(bssid, sta);
 	DEBUGFS_DEL(prev_bssid, sta);
@@ -285,8 +279,7 @@ static void del_ap_files(struct ieee8021
 {
 	DEBUGFS_DEL(channel_use, ap);
 	DEBUGFS_DEL(drop_unencrypted, ap);
-	DEBUGFS_DEL(eapol, ap);
-	DEBUGFS_DEL(ieee8021_x, ap);
+	DEBUGFS_DEL(ieee802_1x_pac, ap);
 	DEBUGFS_DEL(num_sta_ps, ap);
 	DEBUGFS_DEL(dtim_period, ap);
 	DEBUGFS_DEL(dtim_count, ap);
@@ -302,8 +295,7 @@ static void del_wds_files(struct ieee802
 {
 	DEBUGFS_DEL(channel_use, wds);
 	DEBUGFS_DEL(drop_unencrypted, wds);
-	DEBUGFS_DEL(eapol, wds);
-	DEBUGFS_DEL(ieee8021_x, wds);
+	DEBUGFS_DEL(ieee802_1x_pac, wds);
 	DEBUGFS_DEL(peer, wds);
 }
 
@@ -311,8 +303,7 @@ static void del_vlan_files(struct ieee80
 {
 	DEBUGFS_DEL(channel_use, vlan);
 	DEBUGFS_DEL(drop_unencrypted, vlan);
-	DEBUGFS_DEL(eapol, vlan);
-	DEBUGFS_DEL(ieee8021_x, vlan);
+	DEBUGFS_DEL(ieee802_1x_pac, vlan);
 }
 
 static void del_monitor_files(struct ieee80211_sub_if_data *sdata)
--- everything.orig/net/mac80211/ieee80211_iface.c	2007-12-12 16:25:05.939130533 +0100
+++ everything/net/mac80211/ieee80211_iface.c	2007-12-12 16:31:58.759132161 +0100
@@ -22,7 +22,6 @@ void ieee80211_if_sdata_init(struct ieee
 
 	/* Default values for sub-interface parameters */
 	sdata->drop_unencrypted = 0;
-	sdata->eapol = 1;
 	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
 		skb_queue_head_init(&sdata->fragments[i].skb_list);
 
--- everything.orig/net/mac80211/tx.c	2007-12-12 16:25:06.039131944 +0100
+++ everything/net/mac80211/tx.c	2007-12-12 16:31:58.759132161 +0100
@@ -221,6 +221,7 @@ ieee80211_tx_h_check_assoc(struct ieee80
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 	u32 sta_flags;
+	u16 fc = tx->fc;
 
 	if (unlikely(tx->flags & IEEE80211_TXRXD_TX_INJECTED))
 		return TXRX_CONTINUE;
@@ -261,8 +262,10 @@ ieee80211_tx_h_check_assoc(struct ieee80
 		return TXRX_CONTINUE;
 	}
 
-	if (unlikely(/* !injected && */ tx->sdata->ieee802_1x &&
-		     !(sta_flags & WLAN_STA_AUTHORIZED))) {
+	if (unlikely(!(tx->flags & IEEE80211_TXRXD_TX_INJECTED) &&
+		     tx->sdata->ieee802_1x_pac &&
+		     !(sta_flags & WLAN_STA_AUTHORIZED) &&
+		     !ieee80211_is_eapol(tx->skb, ieee80211_get_hdrlen(fc)))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		DECLARE_MAC_BUF(mac);
 		printk(KERN_DEBUG "%s: dropped frame to %s"
@@ -449,8 +452,7 @@ ieee80211_tx_h_select_key(struct ieee802
 	else if ((key = rcu_dereference(tx->sdata->default_key)))
 		tx->key = key;
 	else if (tx->sdata->drop_unencrypted &&
-		 !(tx->sdata->eapol &&
-		   ieee80211_is_eapol(tx->skb, ieee80211_get_hdrlen(fc)))) {
+		 !ieee80211_is_eapol(tx->skb, ieee80211_get_hdrlen(fc))) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TXRX_DROP;
 	} else {
