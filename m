From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/13] d80211: reduce mdev usage, change ieee80211_rx_mgmt
Date: Sun, 19 Nov 2006 20:26:41 +0100
Message-ID: <1163964402.15473.47.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39864 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933061AbWKST2d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:28:33 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch reduces mdev usage by replacing struct net_device *
arguments that are never used except for dereferencing to get
struct ieee80211_local from ieee80211_ptr by struct
ieee80211_local directly.

Also, this patch changes ieee80211_rx_mgmt to no longer be callable
when local->apdev is NULL. All callers are updated accordingly,
in most cases actually increasing performance by not allocating
skbs when they won't be given to anyone anyway.

Instead of abusing ieee80211_rx_mgmt also introduce
ieee80211_rx_monitor.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:13:56.079275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:13:56.719275208 +0100
@@ -210,9 +210,16 @@ static void ieee80211_key_threshold_noti
 					   struct ieee80211_key *key,
 					   struct sta_info *sta)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_msg_key_notification *msg;
 
+	/* if no one will get it anyway, don't even allocate it.
+	 * unlikely because this is only relevant for APs
+	 * where the device must be open... */
+	if (unlikely(!local->apdev))
+		return;
+
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_msg_key_notification));
 	if (!skb)
@@ -230,7 +237,7 @@ static void ieee80211_key_threshold_noti
 
 	key->tx_rx_count = 0;
 
-	ieee80211_rx_mgmt(dev, skb, NULL,
+	ieee80211_rx_mgmt(local, skb, NULL,
 			  ieee80211_msg_key_threshold_notification);
 }
 
@@ -2526,45 +2533,11 @@ ieee80211_get_rate(struct ieee80211_loca
 	return NULL;
 }
 
-
 void
-ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
-		  struct ieee80211_rx_status *status, u32 msg_type)
+ieee80211_fill_frame_info(struct ieee80211_local *local,
+			  struct ieee80211_frame_info *fi,
+			  struct ieee80211_rx_status *status)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-        struct ieee80211_frame_info *fi;
-        size_t hlen;
-        struct ieee80211_sub_if_data *sdata;
-
-	if (msg_type != ieee80211_msg_monitor)
-		dev = local->apdev;
-	if (!dev) {
-		dev_kfree_skb(skb);
-		return;
-	}
-        skb->dev = dev;
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-
-	if (skb_headroom(skb) < sizeof(struct ieee80211_frame_info)) {
-		I802_DEBUG_INC(local->rx_expand_skb_head);
-		if (pskb_expand_head(skb, sizeof(struct ieee80211_frame_info),
-				     0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-                        return;
-		}
-	}
-
-	hlen = sizeof(struct ieee80211_frame_info);
-	if (msg_type == ieee80211_msg_monitor)
-		hlen -= sizeof(fi->msg_type);
-
-	fi = (struct ieee80211_frame_info *) skb_push(skb, hlen);
-        memset(fi, 0, hlen);
-	if (msg_type != ieee80211_msg_monitor)
-		fi->msg_type = htonl(msg_type);
-	fi->version = htonl(IEEE80211_FI_VERSION);
-        fi->length = htonl(hlen);
         if (status) {
                 struct timespec ts;
 		struct ieee80211_rate *rate;
@@ -2615,27 +2588,104 @@ ieee80211_rx_mgmt(struct net_device *dev
                 fi->ssi_noise = 0x00000000;
                 fi->encoding = 0;
 	} else {
+		/* clear everything because we really don't know.
+		 * the msg_type field isn't present on monitor frames
+		 * so we don't know whether it will be present or not,
+		 * but it's ok to not clear it since it'll be assigned
+		 * anyway */
+		memset(fi, 0, sizeof(*fi) - sizeof(fi->msg_type));
+
                 fi->ssi_type = htonl(ieee80211_ssi_none);
         }
+	fi->version = htonl(IEEE80211_FI_VERSION);
+	fi->length = cpu_to_be32(sizeof(*fi) - sizeof(fi->msg_type));
+}
+
+/* this routine is actually not just for this, but also
+ * for pushing fake 'management' frames into userspace.
+ * it shall be replaced by a netlink-based system. */
+void
+ieee80211_rx_mgmt(struct ieee80211_local *local, struct sk_buff *skb,
+		  struct ieee80211_rx_status *status, u32 msg_type)
+{
+	struct ieee80211_frame_info *fi;
+	const size_t hlen = sizeof(struct ieee80211_frame_info);
+	struct ieee80211_sub_if_data *sdata;
+
+	skb->dev = local->apdev;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(local->apdev);
+
+	if (skb_headroom(skb) < hlen) {
+		I802_DEBUG_INC(local->rx_expand_skb_head);
+		if (pskb_expand_head(skb, hlen, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+                        return;
+		}
+	}
+
+	fi = (struct ieee80211_frame_info *) skb_push(skb, hlen);
 
-        sdata->stats.rx_packets++;
-        sdata->stats.rx_bytes += skb->len;
+	ieee80211_fill_frame_info(local, fi, status);
+	fi->msg_type = htonl(msg_type);
 
-        skb->mac.raw = skb->data;
+	sdata->stats.rx_packets++;
+	sdata->stats.rx_bytes += skb->len;
+
+	skb->mac.raw = skb->data;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_802_2);
+	skb->protocol = htons(ETH_P_802_2);
 	memset(skb->cb, 0, sizeof(skb->cb));
-        netif_rx(skb);
+	netif_rx(skb);
 }
 
+void
+ieee80211_rx_monitor(struct net_device *dev, struct sk_buff *skb,
+		     struct ieee80211_rx_status *status)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_frame_info *fi;
+	struct ieee80211_sub_if_data *sdata;
+	const size_t hlen = sizeof(struct ieee80211_frame_info)
+				- sizeof(fi->msg_type);
+
+	skb->dev = dev;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	if (skb_headroom(skb) < hlen) {
+		I802_DEBUG_INC(local->rx_expand_skb_head);
+		if (pskb_expand_head(skb, hlen, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+                        return;
+		}
+	}
+
+	fi = (struct ieee80211_frame_info *) skb_push(skb, hlen);
+
+	ieee80211_fill_frame_info(local, fi, status);
+	sdata->stats.rx_packets++;
+	sdata->stats.rx_bytes += skb->len;
+
+	skb->mac.raw = skb->data;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->pkt_type = PACKET_OTHERHOST;
+	skb->protocol = htons(ETH_P_802_2);
+	memset(skb->cb, 0, sizeof(skb->cb));
+	netif_rx(skb);
+}
 
 int ieee80211_radar_status(struct net_device *dev, int channel, int radar,
 			   int radar_type)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_radar_info *msg;
 
+	if (!local->apdev)
+		return 0;
+
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_radar_info));
 
@@ -2649,7 +2699,7 @@ int ieee80211_radar_status(struct net_de
 	msg->radar = radar;
 	msg->radar_type = radar_type;
 
-	ieee80211_rx_mgmt(dev, skb, NULL, ieee80211_msg_radar);
+	ieee80211_rx_mgmt(local, skb, NULL, ieee80211_msg_radar);
 	return 0;
 }
 EXPORT_SYMBOL(ieee80211_radar_status);
@@ -2657,9 +2707,15 @@ EXPORT_SYMBOL(ieee80211_radar_status);
 int ieee80211_set_aid_for_sta(struct net_device *dev, u8 *peer_address,
 			      u16 aid)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_msg_set_aid_for_sta *msg;
 
+	/* unlikely because if this event only happens for APs,
+	 * which require an open ap device. */
+	if (unlikely(!local->apdev))
+		return 0;
+
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_msg_set_aid_for_sta));
 
@@ -2672,7 +2728,7 @@ int ieee80211_set_aid_for_sta(struct net
 	memcpy(msg->sta_address, peer_address, ETH_ALEN);
 	msg->aid = aid;
 
-	ieee80211_rx_mgmt(dev, skb, NULL, ieee80211_msg_set_aid_for_sta);
+	ieee80211_rx_mgmt(local, skb, NULL, ieee80211_msg_set_aid_for_sta);
 	return 0;
 }
 EXPORT_SYMBOL(ieee80211_set_aid_for_sta);
@@ -3007,8 +3063,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_monitor(struct ieee80211_txrx_data *rx)
 {
 	if (rx->sdata->type == IEEE80211_IF_TYPE_MNTR) {
-		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
-                                  ieee80211_msg_monitor);
+		ieee80211_rx_monitor(rx->dev, rx->skb, rx->u.rx.status);
 		return TXRX_QUEUED;
 	}
 
@@ -3080,7 +3135,10 @@ ieee80211_rx_h_check(struct ieee80211_tx
 			return TXRX_DROP;
 		}
 
-		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
+		if (!rx->local->apdev)
+			return TXRX_DROP;
+
+		ieee80211_rx_mgmt(rx->local, rx->skb, rx->u.rx.status,
 				  ieee80211_msg_sta_not_assoc);
 		return TXRX_QUEUED;
 	}
@@ -3116,8 +3174,10 @@ ieee80211_rx_h_check(struct ieee80211_tx
 				       MAC_ARG(hdr->addr1),
 				       MAC_ARG(hdr->addr2),
 				       MAC_ARG(hdr->addr3));
+				if (!rx->local->apdev)
+					return TXRX_DROP;
 				ieee80211_rx_mgmt(
-					rx->dev, rx->skb, rx->u.rx.status,
+					rx->local, rx->skb, rx->u.rx.status,
 					ieee80211_msg_wep_frame_unknown_key);
 				return TXRX_QUEUED;
 			}
@@ -3267,7 +3327,9 @@ ieee80211_rx_h_802_1x_pae(struct ieee802
 	    rx->sdata->type != IEEE80211_IF_TYPE_STA && rx->u.rx.ra_match) {
 		/* Pass both encrypted and unencrypted EAPOL frames to user
 		 * space for processing. */
-		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
+		if (!rx->local->apdev)
+			return TXRX_DROP;
+		ieee80211_rx_mgmt(rx->local, rx->skb, rx->u.rx.status,
                                   ieee80211_msg_normal);
 		return TXRX_QUEUED;
 	}
@@ -3328,7 +3390,9 @@ ieee80211_rx_h_mgmt(struct ieee80211_txr
 		ieee80211_sta_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status);
 	} else {
 		/* Management frames are sent to hostapd for processing */
-		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
+		if (!rx->local->apdev)
+			return TXRX_DROP;
+		ieee80211_rx_mgmt(rx->local, rx->skb, rx->u.rx.status,
 				  ieee80211_msg_normal);
 	}
 	return TXRX_QUEUED;
@@ -3368,7 +3432,10 @@ ieee80211_rx_h_passive_scan(struct ieee8
 			    rx->skb->len > FCS_LEN)
 				skb_trim(rx->skb, rx->skb->len - FCS_LEN);
 
-                        ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
+			if (!rx->local->apdev)
+				return TXRX_DROP;
+			ieee80211_rx_mgmt(rx->local, rx->skb,
+					  rx->u.rx.status,
                                           ieee80211_msg_passive_scan);
                         return TXRX_QUEUED;
                 } else {
@@ -3502,7 +3569,9 @@ static void ieee80211_rx_michael_mic_rep
 	/* TODO: consider verifying the MIC error report with software
 	 * implementation if we get too many spurious reports from the
 	 * hardware. */
-	ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
+	if (!rx->local->apdev)
+		goto ignore;
+	ieee80211_rx_mgmt(rx->local, rx->skb, rx->u.rx.status,
 			  ieee80211_msg_michael_mic_failure);
 	return;
 
@@ -4148,7 +4217,8 @@ void ieee80211_tx_status(struct net_devi
 			local->dot11FailedCount++;
         }
 
-        if (!(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS)) {
+        if (!(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS)
+            || unlikely(!local->apdev)) {
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -4167,7 +4237,7 @@ void ieee80211_tx_status(struct net_devi
 	skb = skb2;
 
         /* Send frame to hostapd */
-        ieee80211_rx_mgmt(dev, skb, NULL, msg_type);
+        ieee80211_rx_mgmt(local, skb, NULL, msg_type);
 }
 EXPORT_SYMBOL(ieee80211_tx_status);
 
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-11-19 20:13:56.069275208 +0100
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-11-19 20:13:56.719275208 +0100
@@ -571,7 +571,7 @@ struct ieee80211_key *ieee80211_key_allo
 					  int idx, size_t key_len, gfp_t flags);
 void ieee80211_key_free(struct ieee80211_key *key);
 void ieee80211_key_release(struct kobject *kobj);
-void ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
+void ieee80211_rx_mgmt(struct ieee80211_local *local, struct sk_buff *skb,
 		       struct ieee80211_rx_status *status, u32 msg_type);
 void ieee80211_prepare_rates(struct ieee80211_local *local);
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
--- wireless-dev.orig/net/d80211/wpa.c	2006-11-19 20:13:51.199275208 +0100
+++ wireless-dev/net/d80211/wpa.c	2006-11-19 20:13:56.719275208 +0100
@@ -267,7 +267,10 @@ ieee80211_rx_h_michael_mic_verify(struct
 			kfree(buf);
 		} while (0);
 
-		ieee80211_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status,
+		if (!rx->local->apdev)
+			return TXRX_DROP;
+
+		ieee80211_rx_mgmt(rx->local, rx->skb, rx->u.rx.status,
 				  ieee80211_msg_michael_mic_failure);
 
 		return TXRX_QUEUED;
--- wireless-dev.orig/include/net/d80211_common.h	2006-11-19 20:13:51.249275208 +0100
+++ wireless-dev/include/net/d80211_common.h	2006-11-19 20:13:56.719275208 +0100
@@ -50,7 +50,7 @@ enum ieee80211_msg_type {
 	ieee80211_msg_passive_scan = 3,
 	ieee80211_msg_wep_frame_unknown_key = 4,
 	ieee80211_msg_michael_mic_failure = 5,
-	ieee80211_msg_monitor = 6,
+	/* hole at 6, was monitor but never sent to userspace */
 	ieee80211_msg_sta_not_assoc = 7,
 	ieee80211_msg_set_aid_for_sta = 8 /* used by Intersil MVC driver */,
 	ieee80211_msg_key_threshold_notification = 9,


