From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] d80211: respect extra_tx_headroom
Date: Mon, 5 Feb 2007 16:32:24 +0100
Message-ID: <200702051632.24949.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>, "John Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:22301 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932794AbXBEPcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:32:47 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1325859uga
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 07:32:46 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a driver requested additional header room
through the extra_tx_headroom field, the stack
should respect that and make sure that all frames
that are being send to the stack actually have
that extra header room.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 dscape/net/d80211/ieee80211.c dscape.hdr/net/d80211/ieee80211.c
--- dscape/net/d80211/ieee80211.c	2007-02-05 16:20:04.000000000 +0100
+++ dscape.hdr/net/d80211/ieee80211.c	2007-02-05 16:24:01.000000000 +0100
@@ -472,10 +472,9 @@
 
 		/* reserve enough extra head and tail room for possible
 		 * encryption */
-#define IEEE80211_ENCRYPT_HEADROOM 8
-#define IEEE80211_ENCRYPT_TAILROOM 12
 		frag = frags[i] =
-			dev_alloc_skb(frag_threshold +
+			dev_alloc_skb(tx->local->hw.extra_tx_headroom +
+				      frag_threshold +
 				      IEEE80211_ENCRYPT_HEADROOM +
 				      IEEE80211_ENCRYPT_TAILROOM);
 		if (!frag)
@@ -483,7 +482,8 @@
 		/* Make sure that all fragments use the same priority so
 		 * that they end up using the same TX queue */
 		frag->priority = first->priority;
-		skb_reserve(frag, IEEE80211_ENCRYPT_HEADROOM);
+		skb_reserve(frag, tx->local->hw.extra_tx_headroom +
+			IEEE80211_ENCRYPT_HEADROOM);
 		fhdr = (struct ieee80211_hdr *) skb_put(frag, hdrlen);
 		memcpy(fhdr, first->data, hdrlen);
 		if (i == num_fragm - 2)
@@ -858,10 +858,13 @@
 
 	hdr_len = ieee80211_get_hdrlen(old_hdr->frame_control);
 
-	tx->u.tx.rts_frame = dev_alloc_skb(hdr_len);
+	tx->u.tx.rts_frame = dev_alloc_skb(hdr_len +
+		tx->local->hw.extra_tx_headroom);
 	if (!tx->u.tx.rts_frame)
 		return TXRX_DROP;
 
+	skb_reserve(tx->u.tx.rts_frame, tx->local->hw.extra_tx_headroom);
+
 	new_hdr = (struct ieee80211_hdr*)skb_put(tx->u.tx.rts_frame, hdr_len);
 
 	memcpy(new_hdr, old_hdr, hdr_len);
@@ -1427,6 +1430,7 @@
 	struct ieee80211_tx_packet_data *pkt_data;
 	struct net_device *odev = NULL;
 	struct ieee80211_sub_if_data *osdata;
+	int headroom;
 	int ret;
 
 	/*
@@ -1451,6 +1455,15 @@
 	}
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
+	headroom = osdata->local->hw.extra_tx_headroom +
+		IEEE80211_ENCRYPT_HEADROOM;
+	if (skb_headroom(skb) < headroom) {
+		if (pskb_expand_head(skb, headroom, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
 	control.ifindex = odev->ifindex;
 	control.type = osdata->type;
 	if (pkt_data->req_tx_status)
@@ -1680,6 +1693,14 @@
 		return 0;
 	}
 
+	if (skb_headroom(skb) < sdata->local->hw.extra_tx_headroom) {
+		if (pskb_expand_head(skb,
+		    sdata->local->hw.extra_tx_headroom, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
 	hdr = (struct ieee80211_hdr *) skb->data;
 	fc = le16_to_cpu(hdr->frame_control);
 
@@ -1813,10 +1834,12 @@
 	bh_len = ap->beacon_head_len;
 	bt_len = ap->beacon_tail_len;
 
-	skb = dev_alloc_skb(bh_len + bt_len + 256 /* maximum TIM len */);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+		bh_len + bt_len + 256 /* maximum TIM len */);
 	if (!skb)
 		return NULL;
 
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 	memcpy(skb_put(skb, bh_len), b_head, bh_len);
 
 	if (hw->flags & IEEE80211_HW_SOFTWARE_SEQUENCE)
diff -rU3 dscape/net/d80211/ieee80211_i.h dscape.hdr/net/d80211/ieee80211_i.h
--- dscape/net/d80211/ieee80211_i.h	2007-02-05 16:20:01.000000000 +0100
+++ dscape.hdr/net/d80211/ieee80211_i.h	2007-02-05 16:24:19.000000000 +0100
@@ -49,6 +49,9 @@
  * frame can be up to about 2 kB long. */
 #define TOTAL_MAX_TX_BUFFER 512
 
+/* Required encryption head and tailroom */
+#define IEEE80211_ENCRYPT_HEADROOM 8
+#define IEEE80211_ENCRYPT_TAILROOM 12
 
 /* IEEE 802.11 (Ch. 9.5 Defragmentation) requires support for concurrent
  * reception of at least three fragmented frames. This limit can be increased
diff -rU3 dscape/net/d80211/ieee80211_scan.c dscape.hdr/net/d80211/ieee80211_scan.c
--- dscape/net/d80211/ieee80211_scan.c	2007-02-05 16:18:41.000000000 +0100
+++ dscape.hdr/net/d80211/ieee80211_scan.c	2007-02-05 16:24:49.000000000 +0100
@@ -280,7 +280,7 @@
 {
 	struct ieee80211_hdr hdr;
 	u16 fc;
-	int len = 10;
+	int len = 10 + local->hw.extra_tx_headroom;
 	struct rate_control_extra extra;
 
 	/* Only initialize passive scanning if the hardware supports it */
@@ -309,6 +309,7 @@
 		       "passive scan\n", local->mdev->name);
 		return;
 	}
+	skb_reserve(local->scan.skb, local->hw.extra_tx_headroom);
 
 	fc = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CTS;
 	hdr.frame_control = cpu_to_le16(fc);
diff -rU3 dscape/net/d80211/ieee80211_sta.c dscape.hdr/net/d80211/ieee80211_sta.c
--- dscape/net/d80211/ieee80211_sta.c	2007-02-05 16:18:41.000000000 +0100
+++ dscape.hdr/net/d80211/ieee80211_sta.c	2007-02-05 16:27:29.000000000 +0100
@@ -415,15 +415,18 @@
 				int transaction, u8 *extra, size_t extra_len,
 				int encrypt)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + 6 + extra_len);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+			    sizeof(*mgmt) + 6 + extra_len);
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for auth "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
 	memset(mgmt, 0, 24 + 6);
@@ -478,13 +481,15 @@
 	struct ieee80211_sta_bss *bss;
 	int wmm = 0;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + 200 + ifsta->extra_ie_len +
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+			    sizeof(*mgmt) + 200 + ifsta->extra_ie_len +
 			    ifsta->ssid_len);
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for assoc "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	capab = ifsta->capab;
 	if (local->hw.conf.phymode == MODE_IEEE80211G) {
@@ -585,15 +590,17 @@
 static void ieee80211_send_deauth(struct net_device *dev,
 				  struct ieee80211_if_sta *ifsta, u16 reason)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 
-	skb = dev_alloc_skb(sizeof(*mgmt));
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt));
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for deauth "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -612,15 +619,17 @@
 static void ieee80211_send_disassoc(struct net_device *dev,
 				    struct ieee80211_if_sta *ifsta, u16 reason)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 
-	skb = dev_alloc_skb(sizeof(*mgmt));
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt));
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for disassoc "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -758,12 +767,13 @@
 	u8 *pos, *supp_rates, *esupp_rates = NULL;
 	int i;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + 200);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt) + 200);
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for probe "
 		       "request\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -2007,6 +2017,8 @@
 		if (!skb)
 			break;
 
+		skb_reserve(skb, local->hw.extra_tx_headroom);
+
 		mgmt = (struct ieee80211_mgmt *)
 			skb_put(skb, 24 + sizeof(mgmt->u.beacon));
 		memset(mgmt, 0, 24 + sizeof(mgmt->u.beacon));
