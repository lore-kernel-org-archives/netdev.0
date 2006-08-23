From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH ] d80211:  get rid of sta_aid in favour of keeping track of
	TIM
Date: Wed, 23 Aug 2006 12:16:12 +0200
Message-ID: <1156328173.3914.9.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075200.055344487@sipsolutions.net>
	 <20060822203647.5a160a34@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:19911 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964813AbWHWKPl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 06:15:41 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060822203647.5a160a34@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch gets rid of the HUGE sta_aid array that was there in the
access point structure and instead keeps track of the TIM. Also
reduces stack usage of the ieee80211_beacon_add_tim() function
considerably, and fixes a bug where removing a station that had
frames buffered wouldn't update the hardware TIM (if necessary).

It also removes the MAX_AID_TABLE_SIZE pseudo-configuration option
(it was a define with a comment indicating it could be changed)
since now having all AIDs available is no longer expensive.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-23 10:58:26.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-23 12:09:53.000000000 +0200
@@ -22,6 +22,7 @@
 #include <linux/mutex.h>
 #include <net/iw_handler.h>
 #include <linux/compiler.h>
+#include <linux/bitmap.h>
 
 #include <net/d80211.h>
 #include <net/d80211_common.h>
@@ -1044,8 +1045,12 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 		} else
 			tx->local->total_ps_buffered++;
 		/* Queue frame to be sent after STA sends an PS Poll frame */
-		if (skb_queue_empty(&sta->ps_tx_buf) && tx->local->hw->set_tim)
-			tx->local->hw->set_tim(tx->dev, sta->aid, 1);
+		if (skb_queue_empty(&sta->ps_tx_buf)) {
+			if (tx->local->hw->set_tim)
+				tx->local->hw->set_tim(tx->dev, sta->aid, 1);
+			if (tx->sdata->bss)
+				bss_tim_set(tx->local, tx->sdata->bss, sta->aid);
+		}
 		pkt_data = (struct ieee80211_tx_packet_data *)tx->skb->cb;
 		pkt_data->jiffies = jiffies;
                 skb_queue_tail(&sta->ps_tx_buf, tx->skb);
@@ -1676,25 +1681,16 @@ static void ieee80211_beacon_add_tim(str
 {
 	u8 *pos, *tim;
 	int aid0 = 0;
-	int i, num_bits = 0, n1, n2;
-	u8 bitmap[251];
+	int i, have_bits = 0, n1, n2;
 
 	/* Generate bitmap for TIM only if there are any STAs in power save
 	 * mode. */
-	if (atomic_read(&bss->num_sta_ps) > 0 && bss->max_aid > 0) {
-		memset(bitmap, 0, sizeof(bitmap));
-		spin_lock_bh(&local->sta_lock);
-		for (i = 0; i < bss->max_aid; i++) {
-			if (bss->sta_aid[i] &&
-			    (!skb_queue_empty(&bss->sta_aid[i]->ps_tx_buf) ||
-			     !skb_queue_empty(&bss->sta_aid[i]->tx_filtered)))
-			{
-				bitmap[(i + 1) / 8] |= 1 << (i + 1) % 8;
-				num_bits++;
-			}
-		}
-		spin_unlock_bh(&local->sta_lock);
-	}
+	spin_lock_bh(&local->sta_lock);
+	if (atomic_read(&bss->num_sta_ps) > 0)
+		/* in the hope that this is faster than
+		 * checking byte-for-byte */
+		have_bits = !bitmap_empty((unsigned long*)bss->tim,
+					  IEEE80211_MAX_AID+1);
 
 	if (bss->dtim_count == 0)
 		bss->dtim_count = bss->dtim_period - 1;
@@ -1707,40 +1703,40 @@ static void ieee80211_beacon_add_tim(str
 	*pos++ = bss->dtim_count;
 	*pos++ = bss->dtim_period;
 
-	if (bss->dtim_count == 0 && !skb_queue_empty(&bss->ps_bc_buf)) {
+	if (bss->dtim_count == 0 && !skb_queue_empty(&bss->ps_bc_buf))
 		aid0 = 1;
-	}
 
-	if (num_bits) {
+	if (have_bits) {
 		/* Find largest even number N1 so that bits numbered 1 through
 		 * (N1 x 8) - 1 in the bitmap are 0 and number N2 so that bits
 		 * (N2 + 1) x 8 through 2007 are 0. */
 		n1 = 0;
-		for (i = 0; i < sizeof(bitmap); i++) {
-			if (bitmap[i]) {
+		for (i = 0; i < IEEE80211_MAX_TIM_LEN; i++) {
+			if (bss->tim[i]) {
 				n1 = i & 0xfe;
 				break;
 			}
 		}
 		n2 = n1;
-		for (i = sizeof(bitmap) - 1; i >= n1; i--) {
-			if (bitmap[i]) {
+		for (i = IEEE80211_MAX_TIM_LEN - 1; i >= n1; i--) {
+			if (bss->tim[i]) {
 				n2 = i;
 				break;
 			}
 		}
 
 		/* Bitmap control */
-		*pos++ = n1 | (aid0 ? 1 : 0);
+		*pos++ = n1 | aid0;
 		/* Part Virt Bitmap */
-		memcpy(pos, bitmap + n1, n2 - n1 + 1);
+		memcpy(pos, bss->tim + n1, n2 - n1 + 1);
 
 		tim[1] = n2 - n1 + 4;
 		skb_put(skb, n2 - n1);
 	} else {
-		*pos++ = aid0 ? 1 : 0; /* Bitmap control */
+		*pos++ = aid0; /* Bitmap control */
 		*pos++ = 0; /* Part Virt Bitmap */
 	}
+	spin_unlock_bh(&local->sta_lock);
 }
 
 
@@ -2702,8 +2698,12 @@ static int ap_sta_ps_end(struct net_devi
 		atomic_dec(&sdata->bss->num_sta_ps);
 	sta->flags &= ~(WLAN_STA_PS | WLAN_STA_TIM);
 	sta->pspoll = 0;
-	if (!skb_queue_empty(&sta->ps_tx_buf) && local->hw->set_tim)
-		local->hw->set_tim(dev, sta->aid, 0);
+	if (!skb_queue_empty(&sta->ps_tx_buf)) {
+		if (local->hw->set_tim)
+			local->hw->set_tim(dev, sta->aid, 0);
+		if (sdata->bss)
+			bss_tim_clear(local, sdata->bss, sta->aid);
+	}
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
 	printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d exits power "
 	       "save mode\n", dev->name, MAC_ARG(sta->addr), sta->aid);
@@ -2778,8 +2778,12 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 
 		dev_queue_xmit(skb);
 
-		if (no_pending_pkts && rx->local->hw->set_tim)
-			rx->local->hw->set_tim(rx->dev, rx->sta->aid, 0);
+		if (no_pending_pkts) {
+			if (rx->local->hw->set_tim)
+				rx->local->hw->set_tim(rx->dev, rx->sta->aid, 0);
+			if (rx->sdata->bss)
+				bss_tim_clear(rx->local, rx->sdata->bss, rx->sta->aid);
+		}
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
 	} else if (!rx->u.rx.sent_ps_buffered) {
 		printk(KERN_DEBUG "%s: STA " MAC_FMT " sent PS Poll even "
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-23 10:58:26.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-23 12:09:53.000000000 +0200
@@ -18,6 +18,8 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
 #include "ieee80211_key.h"
 #include "sta_info.h"
 
@@ -211,13 +213,10 @@ struct ieee80211_if_ap {
 	u8 *generic_elem;
 	size_t generic_elem_len;
 
-	/* TODO: sta_aid could be replaced by 2008-bit large bitfield of
-	 * that could be used in TIM element generation. This would also
-	 * make TIM element generation a bit faster. */
-	/* AID mapping to station data. NULL, if AID is free. AID is in the
-	 * range 1..2007 and sta_aid[i] corresponds to AID i+1. */
-	struct sta_info *sta_aid[MAX_AID_TABLE_SIZE];
-	int max_aid; /* largest aid currently in use */
+	/* yes, this looks ugly, but guarantees that we can later use
+	 * bitmap_empty :)
+	 * NB: don't ever use set_bit, use bss_tim_set/bss_tim_clear! */
+	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)];
 	atomic_t num_sta_ps; /* number of stations in PS mode */
 	struct sk_buff_head ps_bc_buf;
 	int dtim_period, dtim_count;
@@ -549,6 +548,21 @@ struct sta_attribute {
 	ssize_t (*store)(struct sta_info *, const char *buf, size_t count);
 };
 
+static inline void bss_tim_set(struct ieee80211_local *local,
+			       struct ieee80211_if_ap *bss, int aid)
+{
+	spin_lock(&local->sta_lock);
+	bss->tim[(aid)/8] |= 1<<((aid) % 8);
+	spin_unlock(&local->sta_lock);
+}
+
+static inline void bss_tim_clear(struct ieee80211_local *local,
+				 struct ieee80211_if_ap *bss, int aid)
+{
+	spin_lock(&local->sta_lock);
+	bss->tim[(aid)/8] &= !(1<<((aid) % 8));
+	spin_unlock(&local->sta_lock);
+}
 
 /* ieee80211.c */
 void ieee80211_release_hw(struct ieee80211_local *local);
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-08-23 10:58:26.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-08-23 12:09:53.000000000 +0200
@@ -296,12 +296,8 @@ static int ieee80211_ioctl_add_sta(struc
 
 	sta->flags |= WLAN_STA_AUTH | WLAN_STA_ASSOC;
 	sta->aid = param->u.add_sta.aid;
-	if (sta->aid > MAX_AID_TABLE_SIZE)
+	if (sta->aid > IEEE80211_MAX_AID)
 		sta->aid = 0;
-	if (sta->aid > 0 && sdata->bss)
-		sdata->bss->sta_aid[sta->aid - 1] = sta;
-	if (sdata->bss && sta->aid > sdata->bss->max_aid)
-		sdata->bss->max_aid = sta->aid;
 
 	rates = 0;
 	for (i = 0; i < sizeof(param->u.add_sta.supp_rates); i++) {
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-08-23 10:58:26.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-08-23 12:06:16.000000000 +0200
@@ -514,7 +514,6 @@ static ssize_t ieee80211_if_fmt_flags(co
 __IEEE80211_IF_SHOW(flags);
 
 /* AP attributes */
-IEEE80211_IF_SHOW(max_aid, u.ap.max_aid, DEC);
 IEEE80211_IF_SHOW(num_sta_ps, u.ap.num_sta_ps, ATOMIC);
 IEEE80211_IF_SHOW(dtim_period, u.ap.dtim_period, DEC);
 IEEE80211_IF_SHOW(dtim_count, u.ap.dtim_count, DEC);
@@ -592,7 +591,6 @@ static struct attribute *ieee80211_ap_at
 	&class_device_attr_drop_unencrypted.attr,
 	&class_device_attr_eapol.attr,
 	&class_device_attr_ieee8021_x.attr,
-	&class_device_attr_max_aid.attr,
 	&class_device_attr_num_sta_ps.attr,
 	&class_device_attr_dtim_period.attr,
 	&class_device_attr_dtim_count.attr,
--- wireless-dev.orig/net/d80211/sta_info.c	2006-08-23 10:58:26.000000000 +0200
+++ wireless-dev/net/d80211/sta_info.c	2006-08-23 12:06:18.000000000 +0200
@@ -421,16 +421,15 @@ void sta_info_remove_aid_ptr(struct sta_
 {
 	struct ieee80211_sub_if_data *sdata;
 
-	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
-	if (sta->aid <= 0 || !sdata->bss)
+	if (sta->aid <= 0)
 		return;
 
-	sdata->bss->sta_aid[sta->aid - 1] = NULL;
-	if (sta->aid == sdata->bss->max_aid) {
-		while (sdata->bss->max_aid > 0 &&
-		       !sdata->bss->sta_aid[sdata->bss->max_aid - 1])
-			sdata->bss->max_aid--;
-	}
+	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
+
+	if (sdata->local->hw->set_tim)
+		sdata->local->hw->set_tim(sta->dev, sta->aid, 0);
+	if (sdata->bss)
+		bss_tim_clear(sdata->local, sdata->bss, sta->aid);
 }
 
 
--- wireless-dev.orig/include/net/d80211.h	2006-08-23 10:58:26.000000000 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-23 12:09:38.000000000 +0200
@@ -987,8 +987,11 @@ enum {
 #define IEEE80211_STYPE_QOS_CFACKPOLL		0x00F0
 
 
+/* miscellaneous IEEE 802.11 constants */
 #define IEEE80211_MAX_FRAG_THRESHOLD 2346
 #define IEEE80211_MAX_RTS_THRESHOLD 2347
+#define IEEE80211_MAX_AID 2007
+#define IEEE80211_MAX_TIM_LEN 251
 
 struct ieee80211_hdr {
 	__le16 frame_control;
--- wireless-dev.orig/net/d80211/sta_info.h	2006-08-23 12:09:04.000000000 +0200
+++ wireless-dev/net/d80211/sta_info.h	2006-08-23 12:09:09.000000000 +0200
@@ -114,10 +114,6 @@ struct sta_info {
 /* Maximum number of concurrently registered stations */
 #define MAX_STA_COUNT 2007
 
-/* Maximum number of AIDs to use for STAs; must be 2007 or lower
- * (IEEE 802.11 beacon format limitation) */
-#define MAX_AID_TABLE_SIZE 2007
-
 #define STA_HASH_SIZE 256
 #define STA_HASH(sta) (sta[5])
 

