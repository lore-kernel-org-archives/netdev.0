From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] mac80211: rewrite fragmentation code
Date: Wed, 07 May 2008 13:22:19 +0200
Message-ID: <1210159339.5642.13.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <20080430130050.105344000@sipsolutions.net>
	 <20080507071026.GA24407@gondor.apana.org.au>
	 <1210150217.9305.39.camel@johannes.berg>
	 <20080507090040.GA25186@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080507090040.GA25186-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch rewrites mac80211's fragmentation handling to
 (a) use skb_segment
 (b) get rid of the tasklet etc. and just push responsibility
     to the qdisc/core code

This can result in excessive requeues when the device only
accepts a fragment at a time or so then we'll always ask the
generic code to try again but then won't accept the skb.
However, devices that only accept a single skb at a time won't
get good performance anyhow so it doesn't matter.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
John, this has no more dependencies on other patches except ones I
submitted earlier, please merge unless somebody objects.

 include/net/mac80211.h     |   10 
 net/mac80211/ieee80211_i.h |   32 --
 net/mac80211/main.c        |   46 ++-
 net/mac80211/tx.c          |  629 ++++++++++++++++++++++-----------------------
 net/mac80211/util.c        |   30 --
 net/mac80211/wep.c         |   26 -
 net/mac80211/wme.c         |    9 
 net/mac80211/wpa.c         |   44 +--
 8 files changed, 395 insertions(+), 431 deletions(-)

--- everything.orig/net/mac80211/ieee80211_i.h	2008-05-07 11:13:00.000000000 +0200
+++ everything/net/mac80211/ieee80211_i.h	2008-05-07 11:49:11.000000000 +0200
@@ -147,7 +147,6 @@ typedef unsigned __bitwise__ ieee80211_t
 #define IEEE80211_TX_UNICAST		BIT(1)
 #define IEEE80211_TX_PS_BUFFERED	BIT(2)
 #define IEEE80211_TX_PROBE_LAST_FRAG	BIT(3)
-#define IEEE80211_TX_INJECTED		BIT(4)
 
 struct ieee80211_tx_data {
 	struct sk_buff *skb;
@@ -165,11 +164,6 @@ struct ieee80211_tx_data {
 	 * when using CTS protection with IEEE 802.11g. */
 	s8 last_frag_rate_idx;
 
-	/* Extra fragments (in addition to the first fragment
-	 * in skb) */
-	struct sk_buff **extra_frag;
-	int num_extra_frag;
-
 	u16 fc, ethertype;
 	unsigned int flags;
 };
@@ -215,19 +209,10 @@ struct ieee80211_rx_data {
 #define IEEE80211_TXPD_AMPDU		BIT(4)
 /* Stored in sk_buff->cb */
 struct ieee80211_tx_packet_data {
+	u32 flags;
 	int ifindex;
+	u16 queue;
 	unsigned long jiffies;
-	unsigned int flags;
-	u8 queue;
-};
-
-struct ieee80211_tx_stored_packet {
-	struct ieee80211_tx_control control;
-	struct sk_buff *skb;
-	struct sk_buff **extra_frag;
-	s8 last_frag_rate_idx;
-	int num_extra_frag;
-	bool last_frag_rate_ctrl_probe;
 };
 
 struct beacon_data {
@@ -612,8 +597,7 @@ struct ieee80211_local {
 	struct timer_list sta_cleanup;
 
 	unsigned long state[IEEE80211_MAX_QUEUES + IEEE80211_MAX_AMPDU_QUEUES];
-	struct ieee80211_tx_stored_packet pending_packet[IEEE80211_MAX_QUEUES + IEEE80211_MAX_AMPDU_QUEUES];
-	struct tasklet_struct tx_pending_tasklet;
+	struct sk_buff *pending_packet[IEEE80211_MAX_QUEUES];
 
 	/* number of interfaces with corresponding IFF_ flags */
 	atomic_t iff_allmultis, iff_promiscs;
@@ -846,7 +830,6 @@ static inline struct ieee80211_hw *local
 
 enum ieee80211_link_state_t {
 	IEEE80211_LINK_STATE_XOFF = 0,
-	IEEE80211_LINK_STATE_PENDING,
 };
 
 struct sta_attribute {
@@ -866,7 +849,6 @@ static inline int ieee80211_bssid_match(
 int ieee80211_hw_config(struct ieee80211_local *local);
 int ieee80211_if_config(struct net_device *dev);
 int ieee80211_if_config_beacon(struct net_device *dev);
-void ieee80211_tx_set_protected(struct ieee80211_tx_data *tx);
 void ieee80211_if_setup(struct net_device *dev);
 u32 ieee80211_handle_ht(struct ieee80211_local *local, int enable_ht,
 			struct ieee80211_ht_info *req_ht_cap,
@@ -967,8 +949,6 @@ void ieee80211_if_free(struct net_device
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
 
 /* tx handling */
-void ieee80211_clear_tx_pending(struct ieee80211_local *local);
-void ieee80211_tx_pending(unsigned long data);
 int ieee80211_master_start_xmit(struct sk_buff *skb, struct net_device *dev);
 int ieee80211_monitor_start_xmit(struct sk_buff *skb, struct net_device *dev);
 int ieee80211_subif_start_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -984,4 +964,10 @@ int ieee80211_frame_duration(struct ieee
 void mac80211_ev_michael_mic_failure(struct net_device *dev, int keyidx,
 				     struct ieee80211_hdr *hdr);
 
+static inline void ieee80211_skb_set_protected(struct sk_buff *skb)
+{
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
+}
+
 #endif /* IEEE80211_I_H */
--- everything.orig/net/mac80211/tx.c	2008-05-07 11:13:00.000000000 +0200
+++ everything/net/mac80211/tx.c	2008-05-07 13:02:02.000000000 +0200
@@ -2,7 +2,7 @@
  * Copyright 2002-2005, Instant802 Networks, Inc.
  * Copyright 2005-2006, Devicescape Software, Inc.
  * Copyright 2006-2007	Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
- * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ * Copyright 2007-2008	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -32,9 +32,6 @@
 #include "wme.h"
 #include "rate.h"
 
-#define IEEE80211_TX_OK		0
-#define IEEE80211_TX_AGAIN	1
-#define IEEE80211_TX_FRAG_AGAIN	2
 
 /* misc utils */
 
@@ -219,12 +216,6 @@ static inline int __ieee80211_queue_stop
 	return test_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
 }
 
-static inline int __ieee80211_queue_pending(const struct ieee80211_local *local,
-					    int queue)
-{
-	return test_bit(IEEE80211_LINK_STATE_PENDING, &local->state[queue]);
-}
-
 static int inline is_ieee80211_device(struct net_device *dev,
 				      struct net_device *master)
 {
@@ -243,7 +234,7 @@ ieee80211_tx_h_check_assoc(struct ieee80
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 	u32 sta_flags;
 
-	if (unlikely(tx->flags & IEEE80211_TX_INJECTED))
+	if (unlikely(tx->control->flags & IEEE80211_TXCTL_INJECTED))
 		return TX_CONTINUE;
 
 	if (unlikely(tx->local->sta_sw_scanning) &&
@@ -457,46 +448,66 @@ ieee80211_tx_h_ps_buf(struct ieee80211_t
 		return ieee80211_tx_h_multicast_ps_buf(tx);
 }
 
+static struct ieee80211_key *
+ieee80211_select_key(struct ieee80211_sub_if_data *sdata,
+		     struct sta_info *sta,
+		     struct ieee80211_tx_control *control,
+		     u16 fc)
+{
+	struct ieee80211_key *key, *result;
+	u16 ftype, stype;
+
+	if (unlikely(control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
+		result = NULL;
+	else if (sta && (key = rcu_dereference(sta->key)))
+		result = key;
+	else if ((key = rcu_dereference(sdata->default_key)))
+		result = key;
+	else
+		result = NULL;
+
+	if (!result)
+		return NULL;
+
+	switch (result->conf.alg) {
+	case ALG_WEP:
+		ftype = fc & IEEE80211_FCTL_FTYPE;
+		stype = fc & IEEE80211_FCTL_STYPE;
+
+		if (ftype == IEEE80211_FTYPE_MGMT &&
+		    stype == IEEE80211_STYPE_AUTH)
+			break;
+	case ALG_TKIP:
+	case ALG_CCMP:
+		if (!WLAN_FC_DATA_PRESENT(fc))
+			result = NULL;
+		break;
+	}
+
+	return result;
+}
+
 static ieee80211_tx_result
 ieee80211_tx_h_select_key(struct ieee80211_tx_data *tx)
 {
-	struct ieee80211_key *key;
 	u16 fc = tx->fc;
 
 	if (unlikely(tx->control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
-		tx->key = NULL;
-	else if (tx->sta && (key = rcu_dereference(tx->sta->key)))
-		tx->key = key;
-	else if ((key = rcu_dereference(tx->sdata->default_key)))
-		tx->key = key;
-	else if (tx->sdata->drop_unencrypted &&
-		 !(tx->control->flags & IEEE80211_TXCTL_EAPOL_FRAME) &&
-		 !(tx->flags & IEEE80211_TX_INJECTED)) {
+		return TX_CONTINUE;
+
+	tx->key = ieee80211_select_key(tx->sdata, tx->sta, tx->control, fc);
+
+	if (!tx->key &&
+	    tx->sdata->drop_unencrypted &&
+	    !(tx->control->flags & IEEE80211_TXCTL_EAPOL_FRAME) &&
+	    !(tx->control->flags & IEEE80211_TXCTL_INJECTED)) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TX_DROP;
-	} else
-		tx->key = NULL;
+	}
 
 	if (tx->key) {
-		u16 ftype, stype;
-
 		tx->key->tx_rx_count++;
 		/* TODO: add threshold stuff again */
-
-		switch (tx->key->conf.alg) {
-		case ALG_WEP:
-			ftype = fc & IEEE80211_FCTL_FTYPE;
-			stype = fc & IEEE80211_FCTL_STYPE;
-
-			if (ftype == IEEE80211_FTYPE_MGMT &&
-			    stype == IEEE80211_STYPE_AUTH)
-				break;
-		case ALG_TKIP:
-		case ALG_CCMP:
-			if (!WLAN_FC_DATA_PRESENT(fc))
-				tx->key = NULL;
-			break;
-		}
 	}
 
 	if (!tx->key || !(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
@@ -508,81 +519,69 @@ ieee80211_tx_h_select_key(struct ieee802
 static ieee80211_tx_result
 ieee80211_tx_h_fragment(struct ieee80211_tx_data *tx)
 {
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
-	size_t hdrlen, per_fragm, num_fragm, payload_len, left;
-	struct sk_buff **frags, *first, *frag;
-	int i;
-	u16 seq;
-	u8 *pos;
 	int frag_threshold = tx->local->fragmentation_threshold;
+	int hdrlen, payload_len, per_fragm, num_fragm;
+	struct sk_buff *skb = tx->skb, *frags;
+	int fragnum = 0;
 
 	if (!(tx->flags & IEEE80211_TX_FRAGMENTED))
 		return TX_CONTINUE;
 
-	first = tx->skb;
+	if (WARN_ON(tx->control->flags & IEEE80211_TXCTL_AMPDU ||
+		    tx->control->queue >= tx->local->hw.queues))
+		return TX_DROP;
 
 	hdrlen = ieee80211_get_hdrlen(tx->fc);
-	payload_len = first->len - hdrlen;
+	payload_len = skb->len - hdrlen;
 	per_fragm = frag_threshold - hdrlen - FCS_LEN;
 	num_fragm = DIV_ROUND_UP(payload_len, per_fragm);
 
-	frags = kzalloc(num_fragm * sizeof(struct sk_buff *), GFP_ATOMIC);
-	if (!frags)
-		goto fail;
+	if (WARN_ON(num_fragm <= 1))
+		return TX_DROP;
 
-	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREFRAGS);
-	seq = le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ;
-	pos = first->data + hdrlen + per_fragm;
-	left = payload_len - per_fragm;
-	for (i = 0; i < num_fragm - 1; i++) {
-		struct ieee80211_hdr *fhdr;
-		size_t copylen;
+	/* skb_segment will push the mac header back in */
+	skb_reset_mac_header(skb);
+	__skb_pull(skb, hdrlen);
 
-		if (left <= 0)
-			goto fail;
+	skb_shinfo(skb)->gso_size = per_fragm;
+	skb_shinfo(skb)->nr_frags = 0;
 
-		/* reserve enough extra head and tail room for possible
-		 * encryption */
-		frag = frags[i] =
-			dev_alloc_skb(tx->local->tx_headroom +
-				      frag_threshold +
-				      IEEE80211_ENCRYPT_HEADROOM +
-				      IEEE80211_ENCRYPT_TAILROOM);
-		if (!frag)
-			goto fail;
-		/* Make sure that all fragments use the same priority so
-		 * that they end up using the same TX queue */
-		frag->priority = first->priority;
-		skb_reserve(frag, tx->local->tx_headroom +
-				  IEEE80211_ENCRYPT_HEADROOM);
-		fhdr = (struct ieee80211_hdr *) skb_put(frag, hdrlen);
-		memcpy(fhdr, first->data, hdrlen);
-		if (i == num_fragm - 2)
-			fhdr->frame_control &= cpu_to_le16(~IEEE80211_FCTL_MOREFRAGS);
-		fhdr->seq_ctrl = cpu_to_le16(seq | ((i + 1) & IEEE80211_SCTL_FRAG));
-		copylen = left > per_fragm ? per_fragm : left;
-		memcpy(skb_put(frag, copylen), pos, copylen);
+	/*
+	 * Now segment (fragment) the frame. This will allocate all the
+	 * segments, we then assign them to the tx->skb->next pointer.
+	 * During transmission, we will remove the successfully transmitted
+	 * fragments from this list. Iff the low-level driver rejects one
+	 * of the fragments then we will simply pretend to accept the skb
+	 * but store it away in our fragment list and use it preferentially
+	 * when the next skb comes in.
+	 */
+	frags = skb_segment(skb, 0);
+	if (IS_ERR(frags))
+		return TX_DROP;
 
-		pos += copylen;
-		left -= copylen;
-	}
-	skb_trim(first, hdrlen + per_fragm);
+	skb->next = frags;
 
-	tx->num_extra_frag = num_fragm - 1;
-	tx->extra_frag = frags;
+	/* update duration/seq/flags of fragments, not on original */
+	while ((skb = skb->next)) {
+		struct ieee80211_hdr *hdr = (void *)skb->data;
+		int next_len, dur;
+		__le16 morefrags = cpu_to_le16(IEEE80211_FCTL_MOREFRAGS);
+
+		if (skb->next) {
+			hdr->frame_control |= morefrags;
+			next_len = skb->next->len;
+		} else {
+			hdr->frame_control &= ~morefrags;
+			next_len = 0;
+			tx->rate_idx = tx->last_frag_rate_idx;
+		}
+		dur = ieee80211_duration(tx, 0, next_len);
+		hdr->duration_id = cpu_to_le16(dur);
+		hdr->seq_ctrl |= cpu_to_le16(fragnum & IEEE80211_SCTL_FRAG);
+		fragnum++;
+	}
 
 	return TX_CONTINUE;
-
- fail:
-	printk(KERN_DEBUG "%s: failed to fragment frame\n", tx->dev->name);
-	if (frags) {
-		for (i = 0; i < num_fragm - 1; i++)
-			if (frags[i])
-				dev_kfree_skb(frags[i]);
-		kfree(frags);
-	}
-	I802_DEBUG_INC(tx->local->tx_handlers_drop_fragment);
-	return TX_DROP;
 }
 
 static ieee80211_tx_result
@@ -712,8 +711,7 @@ ieee80211_tx_h_misc(struct ieee80211_tx_
 	 * for remaining fragments will be updated when they are being sent
 	 * to low-level driver in ieee80211_tx(). */
 	dur = ieee80211_duration(tx, is_multicast_ether_addr(hdr->addr1),
-				 (tx->flags & IEEE80211_TX_FRAGMENTED) ?
-				 tx->extra_frag[0]->len : 0);
+				 tx->skb->next ? tx->skb->next->len : 0);
 	hdr->duration_id = cpu_to_le16(dur);
 
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
@@ -748,18 +746,16 @@ ieee80211_tx_h_misc(struct ieee80211_tx_
 	}
 
 	if (tx->sta) {
+		struct sk_buff *skb = tx->skb;
+
 		control->aid = tx->sta->aid;
 		tx->sta->tx_packets++;
-		tx->sta->tx_fragments++;
-		tx->sta->tx_bytes += tx->skb->len;
-		if (tx->extra_frag) {
-			int i;
-			tx->sta->tx_fragments += tx->num_extra_frag;
-			for (i = 0; i < tx->num_extra_frag; i++) {
-				tx->sta->tx_bytes +=
-					tx->extra_frag[i]->len;
-			}
-		}
+		if (skb->next)
+			skb = skb->next;
+		do {
+			tx->sta->tx_fragments++;
+			tx->sta->tx_bytes += skb->len;
+		} while ((skb = skb->next));
 	}
 
 	return TX_CONTINUE;
@@ -804,15 +800,12 @@ ieee80211_tx_h_load_stats(struct ieee802
 		load += hdrtime;
 
 	/* TODO: optimise again */
-	load += skb->len * CHAN_UTIL_RATE_LCM / rate->bitrate;
+	if (!skb->next)
+		load += skb->len * CHAN_UTIL_RATE_LCM / rate->bitrate;
 
-	if (tx->extra_frag) {
-		int i;
-		for (i = 0; i < tx->num_extra_frag; i++) {
-			load += 2 * hdrtime;
-			load += tx->extra_frag[i]->len *
-				rate->bitrate;
-		}
+	while ((skb = skb->next)) {
+		load += 2 * hdrtime;
+		load += skb->len * CHAN_UTIL_RATE_LCM / rate->bitrate;
 	}
 
 	/* Divide channel_use by 8 to avoid wrapping around the counter */
@@ -870,7 +863,7 @@ __ieee80211_parse_tx_radiotap(struct iee
 	sband = tx->local->hw.wiphy->bands[tx->channel->band];
 
 	control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
-	tx->flags |= IEEE80211_TX_INJECTED;
+	control->flags |= IEEE80211_TXCTL_INJECTED;
 	tx->flags &= ~IEEE80211_TX_FRAGMENTED;
 
 	/*
@@ -1074,63 +1067,106 @@ static int ieee80211_tx_prepare(struct i
 	return 0;
 }
 
+static int ___ieee80211_tx(struct ieee80211_local *local,
+			   struct sk_buff *skb,
+			   struct ieee80211_tx_control *control)
+{
+	int ret;
+
+	if (unlikely(!skb))
+		return NETDEV_TX_OK;
+
+	if (unlikely(netif_queue_stopped(local->mdev) ||
+		     __ieee80211_queue_stopped(local, control->queue)))
+		return NETDEV_TX_BUSY;
+
+	ieee80211_dump_frame(wiphy_name(local->hw.wiphy),
+			     "TX to low-level driver", skb);
+	ret = local->ops->tx(local_to_hw(local), skb, control);
+	if (ret)
+		return NETDEV_TX_BUSY;
+
+	local->mdev->trans_start = jiffies;
+	ieee80211_led_tx(local, 1);
+
+	return NETDEV_TX_OK;
+}
+
 static int __ieee80211_tx(struct ieee80211_local *local, struct sk_buff *skb,
-			  struct ieee80211_tx_data *tx)
+			  struct ieee80211_tx_control *control)
 {
-	struct ieee80211_tx_control *control = tx->control;
-	int ret, i;
+	struct sk_buff *origskb = NULL, *next;
+	int unsetflags = 0, ret;
 
-	if (!ieee80211_qdisc_installed(local->mdev) &&
-	    __ieee80211_queue_stopped(local, 0)) {
-		netif_stop_queue(local->mdev);
-		return IEEE80211_TX_AGAIN;
-	}
-	if (skb) {
-		ieee80211_dump_frame(wiphy_name(local->hw.wiphy),
-				     "TX to low-level driver", skb);
-		ret = local->ops->tx(local_to_hw(local), skb, control);
-		if (ret)
-			return IEEE80211_TX_AGAIN;
-		local->mdev->trans_start = jiffies;
-		ieee80211_led_tx(local, 1);
-	}
-	if (tx->extra_frag) {
-		control->flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
-				    IEEE80211_TXCTL_USE_CTS_PROTECT |
-				    IEEE80211_TXCTL_CLEAR_PS_FILT |
-				    IEEE80211_TXCTL_FIRST_FRAGMENT);
-		for (i = 0; i < tx->num_extra_frag; i++) {
-			if (!tx->extra_frag[i])
-				continue;
-			if (__ieee80211_queue_stopped(local, control->queue))
-				return IEEE80211_TX_FRAG_AGAIN;
-			if (i == tx->num_extra_frag) {
-				control->tx_rate_idx = tx->last_frag_rate_idx;
-
-				if (tx->flags & IEEE80211_TX_PROBE_LAST_FRAG)
-					control->flags |=
-						IEEE80211_TXCTL_RATE_CTRL_PROBE;
-				else
-					control->flags &=
-						~IEEE80211_TXCTL_RATE_CTRL_PROBE;
+	/*
+	 * Send skb (or fragments if any.)
+	 */
+
+	if (skb->next) {
+		origskb = skb;
+		skb = skb->next;
+	}
+
+	do {
+		control->flags &= ~unsetflags;
+
+		/* Try to transmit this fragment */
+
+		next = skb->next;
+		/*
+		 * skb->next must be NULL so the driver (or more likely
+		 * mac80211 in status handling) is able to put it onto a
+		 * queue.
+		 */
+		skb->next = NULL;
+		ret = ___ieee80211_tx(local, skb, control);
+
+		if (unlikely(ret != NETDEV_TX_OK)) {
+			/* important: restore skb->next on errors */
+			skb->next = next;
+			/* put control data into skb->cb for all fragments */
+			while (skb) {
+				control->flags &= ~unsetflags;
+				memcpy(skb->cb, control, sizeof(*control));
+				skb = skb->next;
+				unsetflags = IEEE80211_TXCTL_USE_RTS_CTS |
+					     IEEE80211_TXCTL_USE_CTS_PROTECT |
+					     IEEE80211_TXCTL_CLEAR_PS_FILT |
+					     IEEE80211_TXCTL_FIRST_FRAGMENT;
 			}
 
-			ieee80211_dump_frame(wiphy_name(local->hw.wiphy),
-					     "TX to low-level driver",
-					     tx->extra_frag[i]);
-			ret = local->ops->tx(local_to_hw(local),
-					    tx->extra_frag[i],
-					    control);
-			if (ret)
-				return IEEE80211_TX_FRAG_AGAIN;
-			local->mdev->trans_start = jiffies;
-			ieee80211_led_tx(local, 1);
-			tx->extra_frag[i] = NULL;
+			/*
+			 * If this is not fragmented, simply reject it and have
+			 * it requeued at the upper layer.
+			 */
+			if (!origskb)
+				return ret;
+
+			BUG_ON(local->pending_packet[control->queue]);
+			local->pending_packet[control->queue] = origskb;
+			/*
+			 * We stored it locally, pretend all is well,
+			 * let's hope the driver turned off the queue.
+			 */
+			return NETDEV_TX_OK;
 		}
-		kfree(tx->extra_frag);
-		tx->extra_frag = NULL;
-	}
-	return IEEE80211_TX_OK;
+
+		/* successfully transmitted this (only) fragment */
+
+		unsetflags = IEEE80211_TXCTL_USE_RTS_CTS |
+			     IEEE80211_TXCTL_USE_CTS_PROTECT |
+			     IEEE80211_TXCTL_CLEAR_PS_FILT |
+			     IEEE80211_TXCTL_FIRST_FRAGMENT;
+
+		/* remove this one from the segment list */
+		skb = next;
+		if (origskb)
+			origskb->next = skb;
+	} while (skb);
+
+	kfree_skb(origskb);
+
+	return NETDEV_TX_OK;
 }
 
 static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
@@ -1141,13 +1177,11 @@ static int ieee80211_tx(struct net_devic
 	ieee80211_tx_handler *handler;
 	struct ieee80211_tx_data tx;
 	ieee80211_tx_result res = TX_DROP, res_prepare;
-	int ret, i;
-
-	WARN_ON(__ieee80211_queue_pending(local, control->queue));
+	int ret;
 
 	if (unlikely(skb->len < 10)) {
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	rcu_read_lock();
@@ -1155,11 +1189,8 @@ static int ieee80211_tx(struct net_devic
 	/* initialises tx */
 	res_prepare = __ieee80211_tx_prepare(&tx, skb, dev, control);
 
-	if (res_prepare == TX_DROP) {
-		dev_kfree_skb(skb);
-		rcu_read_unlock();
-		return 0;
-	}
+	if (res_prepare == TX_DROP)
+		goto drop;
 
 	sta = tx.sta;
 	tx.channel = local->hw.conf.channel;
@@ -1181,78 +1212,107 @@ static int ieee80211_tx(struct net_devic
 
 	if (unlikely(res == TX_QUEUED)) {
 		I802_DEBUG_INC(local->tx_handlers_queued);
-		rcu_read_unlock();
-		return 0;
+		goto unlock;
 	}
 
-	if (tx.extra_frag) {
-		for (i = 0; i < tx.num_extra_frag; i++) {
-			int next_len, dur;
-			struct ieee80211_hdr *hdr =
-				(struct ieee80211_hdr *)
-				tx.extra_frag[i]->data;
-
-			if (i + 1 < tx.num_extra_frag) {
-				next_len = tx.extra_frag[i + 1]->len;
-			} else {
-				next_len = 0;
-				tx.rate_idx = tx.last_frag_rate_idx;
-			}
-			dur = ieee80211_duration(&tx, 0, next_len);
-			hdr->duration_id = cpu_to_le16(dur);
-		}
-	}
-
-retry:
-	ret = __ieee80211_tx(local, skb, &tx);
-	if (ret) {
-		struct ieee80211_tx_stored_packet *store =
-			&local->pending_packet[control->queue];
-
-		if (ret == IEEE80211_TX_FRAG_AGAIN)
-			skb = NULL;
-		set_bit(IEEE80211_LINK_STATE_PENDING,
-			&local->state[control->queue]);
-		smp_mb();
-		/* When the driver gets out of buffers during sending of
-		 * fragments and calls ieee80211_stop_queue, there is
-		 * a small window between IEEE80211_LINK_STATE_XOFF and
-		 * IEEE80211_LINK_STATE_PENDING flags are set. If a buffer
-		 * gets available in that window (i.e. driver calls
-		 * ieee80211_wake_queue), we would end up with ieee80211_tx
-		 * called with IEEE80211_LINK_STATE_PENDING. Prevent this by
-		 * continuing transmitting here when that situation is
-		 * possible to have happened. */
-		if (!__ieee80211_queue_stopped(local, control->queue)) {
-			clear_bit(IEEE80211_LINK_STATE_PENDING,
-				  &local->state[control->queue]);
-			goto retry;
-		}
-		memcpy(&store->control, control,
-		       sizeof(struct ieee80211_tx_control));
-		store->skb = skb;
-		store->extra_frag = tx.extra_frag;
-		store->num_extra_frag = tx.num_extra_frag;
-		store->last_frag_rate_idx = tx.last_frag_rate_idx;
-		store->last_frag_rate_ctrl_probe =
-			!!(tx.flags & IEEE80211_TX_PROBE_LAST_FRAG);
-	}
+	ret = __ieee80211_tx(local, skb, tx.control);
 	rcu_read_unlock();
-	return 0;
+	return ret;
 
  drop:
 	if (skb)
 		dev_kfree_skb(skb);
-	for (i = 0; i < tx.num_extra_frag; i++)
-		if (tx.extra_frag[i])
-			dev_kfree_skb(tx.extra_frag[i]);
-	kfree(tx.extra_frag);
+ unlock:
 	rcu_read_unlock();
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /* device xmit handlers */
 
+/*
+ * validate_control verifies that the control pointers are
+ * still valid after the requeue. If they are not then we'll
+ * simply drop the packet.
+ */
+static bool validate_control(struct ieee80211_local *local,
+			     struct ieee80211_tx_control *ctl,
+			     struct sk_buff *skb)
+{
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_key *key;
+	struct ieee80211_hdr *hdr = (void *)skb->data;
+	struct sta_info *sta;
+	u8 *da;
+
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
+		if (ctl->vif != &sdata->vif)
+			continue;
+
+		da = ieee80211_get_DA(hdr);
+		if (!is_multicast_ether_addr(da))
+			sta = sta_info_get(local, da);
+
+		key = ieee80211_select_key(sdata, sta, ctl,
+					   le16_to_cpu(hdr->frame_control));
+
+		if (!ctl->hw_key && !key)
+			return true;
+		return &key->conf == ctl->hw_key;
+	}
+
+	return false;
+}
+
+static int ieee80211_send_pending_fragments(struct ieee80211_local *local,
+					    struct ieee80211_tx_control *ctl,
+					    int queue)
+{
+	struct sk_buff *orig, *frag, *next;
+	int ret;
+
+	orig = local->pending_packet[queue];
+
+	if (!orig)
+		return NETDEV_TX_OK;
+
+	frag = orig->next;
+
+	/* need RCU protection for key/vif pointers */
+	rcu_read_lock();
+
+	do {
+		next = frag->next;
+		frag->next = NULL;
+
+		/* The interface could have been removed, or the key, or ... */
+		if (!validate_control(local, (void *)frag->cb, frag)) {
+			dev_kfree_skb(frag);
+			/* most likely we'll drop all others, but let's see */
+			orig->next = frag = next;
+			continue;
+		}
+		memcpy(ctl, frag->cb, sizeof(*ctl));
+		memset(frag->cb, 0, sizeof(frag->cb));
+		ret = ___ieee80211_tx(local, frag, ctl);
+		if (ret != NETDEV_TX_OK) {
+			frag->next = next;
+			memcpy(frag->cb, ctl, sizeof(*ctl));
+			rcu_read_unlock();
+			return ret;
+		}
+		/* fragment sent fine, remove from list */
+		orig->next = frag = next;
+	} while (next);
+
+	rcu_read_unlock();
+
+	/* yay, all fragments queued to hw successfully */
+	dev_kfree_skb(local->pending_packet[queue]);
+	local->pending_packet[queue] = NULL;
+
+	return NETDEV_TX_OK;
+}
+
 int ieee80211_master_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
@@ -1263,11 +1323,16 @@ int ieee80211_master_start_xmit(struct s
 	int headroom;
 	int ret;
 
-	/*
-	 * copy control out of the skb so other people can use skb->cb
-	 */
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
-	memset(&control, 0, sizeof(struct ieee80211_tx_control));
+
+	ret = ieee80211_send_pending_fragments(wdev_priv(dev->ieee80211_ptr),
+					       &control, pkt_data->queue);
+
+	/* Not all pending fragments queued to hw so reject this skb */
+	if (ret != NETDEV_TX_OK)
+		return ret;
+
+	memset(&control, 0, sizeof(control));
 
 	if (pkt_data->ifindex)
 		odev = dev_get_by_index(&init_net, pkt_data->ifindex);
@@ -1290,12 +1355,11 @@ int ieee80211_master_start_xmit(struct s
 		if (pskb_expand_head(skb, headroom, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
 			dev_put(odev);
-			return 0;
+			return NETDEV_TX_OK;
 		}
 	}
 
 	control.vif = &osdata->vif;
-	control.type = osdata->vif.type;
 	if (pkt_data->flags & IEEE80211_TXPD_REQ_TX_STATUS)
 		control.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
 	if (pkt_data->flags & IEEE80211_TXPD_DO_NOT_ENCRYPT)
@@ -1308,6 +1372,7 @@ int ieee80211_master_start_xmit(struct s
 		control.flags |= IEEE80211_TXCTL_AMPDU;
 	control.queue = pkt_data->queue;
 
+	memset(skb->cb, 0, sizeof(skb->cb));
 	ret = ieee80211_tx(odev, skb, &control);
 	dev_put(odev);
 
@@ -1552,19 +1617,6 @@ int ieee80211_subif_start_xmit(struct sk
 	nh_pos -= skip_header_bytes;
 	h_pos -= skip_header_bytes;
 
-	/* TODO: implement support for fragments so that there is no need to
-	 * reallocate and copy payload; it might be enough to support one
-	 * extra fragment that would be copied in the beginning of the frame
-	 * data.. anyway, it would be nice to include this into skb structure
-	 * somehow
-	 *
-	 * There are few options for this:
-	 * use skb->cb as an extra space for 802.11 header
-	 * allocate new buffer if not enough headroom
-	 * make sure that there is enough headroom in every skb by increasing
-	 * build in headroom in __dev_alloc_skb() (linux/skbuff.h) and
-	 * alloc_skb() (net/core/skbuff.c)
-	 */
 	head_need = hdrlen + encaps_len + meshhdrlen + local->tx_headroom;
 	head_need -= skb_headroom(skb);
 
@@ -1650,69 +1702,6 @@ int ieee80211_subif_start_xmit(struct sk
 	return ret;
 }
 
-/* helper functions for pending packets for when queues are stopped */
-
-void ieee80211_clear_tx_pending(struct ieee80211_local *local)
-{
-	int i, j;
-	struct ieee80211_tx_stored_packet *store;
-
-	for (i = 0; i < local->hw.queues; i++) {
-		if (!__ieee80211_queue_pending(local, i))
-			continue;
-		store = &local->pending_packet[i];
-		kfree_skb(store->skb);
-		for (j = 0; j < store->num_extra_frag; j++)
-			kfree_skb(store->extra_frag[j]);
-		kfree(store->extra_frag);
-		clear_bit(IEEE80211_LINK_STATE_PENDING, &local->state[i]);
-	}
-}
-
-void ieee80211_tx_pending(unsigned long data)
-{
-	struct ieee80211_local *local = (struct ieee80211_local *)data;
-	struct net_device *dev = local->mdev;
-	struct ieee80211_tx_stored_packet *store;
-	struct ieee80211_tx_data tx;
-	int i, ret, reschedule = 0;
-
-	netif_tx_lock_bh(dev);
-	for (i = 0; i < local->hw.queues; i++) {
-		if (__ieee80211_queue_stopped(local, i))
-			continue;
-		if (!__ieee80211_queue_pending(local, i)) {
-			reschedule = 1;
-			continue;
-		}
-		store = &local->pending_packet[i];
-		tx.control = &store->control;
-		tx.extra_frag = store->extra_frag;
-		tx.num_extra_frag = store->num_extra_frag;
-		tx.last_frag_rate_idx = store->last_frag_rate_idx;
-		tx.flags = 0;
-		if (store->last_frag_rate_ctrl_probe)
-			tx.flags |= IEEE80211_TX_PROBE_LAST_FRAG;
-		ret = __ieee80211_tx(local, store->skb, &tx);
-		if (ret) {
-			if (ret == IEEE80211_TX_FRAG_AGAIN)
-				store->skb = NULL;
-		} else {
-			clear_bit(IEEE80211_LINK_STATE_PENDING,
-				  &local->state[i]);
-			reschedule = 1;
-		}
-	}
-	netif_tx_unlock_bh(dev);
-	if (reschedule) {
-		if (!ieee80211_qdisc_installed(dev)) {
-			if (!__ieee80211_queue_stopped(local, 0))
-				netif_wake_queue(dev);
-		} else
-			netif_schedule(dev);
-	}
-}
-
 /* functions for drivers to get certain frames */
 
 static void ieee80211_beacon_add_tim(struct ieee80211_local *local,
--- everything.orig/net/mac80211/wep.c	2008-05-07 11:09:12.000000000 +0200
+++ everything/net/mac80211/wep.c	2008-05-07 11:13:19.000000000 +0200
@@ -333,6 +333,8 @@ ieee80211_crypto_wep_decrypt(struct ieee
 
 static int wep_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 {
+	ieee80211_skb_set_protected(skb);
+
 	if (!(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)) {
 		if (ieee80211_wep_encrypt(tx->local, skb, tx->key))
 			return -1;
@@ -349,25 +351,21 @@ static int wep_encrypt_skb(struct ieee80
 ieee80211_tx_result
 ieee80211_crypto_wep_encrypt(struct ieee80211_tx_data *tx)
 {
+	struct sk_buff *skb = tx->skb;
+
 	tx->control->iv_len = WEP_IV_LEN;
 	tx->control->icv_len = WEP_ICV_LEN;
-	ieee80211_tx_set_protected(tx);
 
-	if (wep_encrypt_skb(tx, tx->skb) < 0) {
+	/* skip original if fragmented */
+	if (skb->next)
+		skb = skb->next;
+
+	do {
+		if (wep_encrypt_skb(tx, tx->skb) == 0)
+			continue;
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_wep);
 		return TX_DROP;
-	}
-
-	if (tx->extra_frag) {
-		int i;
-		for (i = 0; i < tx->num_extra_frag; i++) {
-			if (wep_encrypt_skb(tx, tx->extra_frag[i]) < 0) {
-				I802_DEBUG_INC(tx->local->
-					       tx_handlers_drop_wep);
-				return TX_DROP;
-			}
-		}
-	}
+	} while ((skb = skb->next));
 
 	return TX_CONTINUE;
 }
--- everything.orig/net/mac80211/wpa.c	2008-05-07 11:09:13.000000000 +0200
+++ everything/net/mac80211/wpa.c	2008-05-07 11:13:19.000000000 +0200
@@ -192,6 +192,8 @@ static int tkip_encrypt_skb(struct ieee8
 	u16 fc;
 	u8 *pos;
 
+	ieee80211_skb_set_protected(skb);
+
 	fc = le16_to_cpu(hdr->frame_control);
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
@@ -250,7 +252,6 @@ ieee80211_crypto_tkip_encrypt(struct iee
 
 	tx->control->icv_len = TKIP_ICV_LEN;
 	tx->control->iv_len = TKIP_IV_LEN;
-	ieee80211_tx_set_protected(tx);
 
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
 	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -260,17 +261,14 @@ ieee80211_crypto_tkip_encrypt(struct iee
 		return TX_CONTINUE;
 	}
 
-	if (tkip_encrypt_skb(tx, skb, test) < 0)
-		return TX_DROP;
-
-	if (tx->extra_frag) {
-		int i;
-		for (i = 0; i < tx->num_extra_frag; i++) {
-			if (tkip_encrypt_skb(tx, tx->extra_frag[i], test)
-			    < 0)
-				return TX_DROP;
-		}
-	}
+	/* skip original if segmented */
+	if (skb->next)
+		skb = skb->next;
+
+	do {
+		if (tkip_encrypt_skb(tx, skb, test) < 0)
+			return TX_DROP;
+	} while ((skb = skb->next));
 
 	return TX_CONTINUE;
 }
@@ -439,6 +437,8 @@ static int ccmp_encrypt_skb(struct ieee8
 	u8 *pos, *pn, *b_0, *aad, *scratch;
 	int i;
 
+	ieee80211_skb_set_protected(skb);
+
 	scratch = key->u.ccmp.tx_crypto_buf;
 	b_0 = scratch + 3 * AES_BLOCK_LEN;
 	aad = scratch + 4 * AES_BLOCK_LEN;
@@ -499,7 +499,6 @@ ieee80211_crypto_ccmp_encrypt(struct iee
 
 	tx->control->icv_len = CCMP_MIC_LEN;
 	tx->control->iv_len = CCMP_HDR_LEN;
-	ieee80211_tx_set_protected(tx);
 
 	if ((tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE) &&
 	    !(tx->key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV)) {
@@ -509,17 +508,14 @@ ieee80211_crypto_ccmp_encrypt(struct iee
 		return TX_CONTINUE;
 	}
 
-	if (ccmp_encrypt_skb(tx, skb, test) < 0)
-		return TX_DROP;
-
-	if (tx->extra_frag) {
-		int i;
-		for (i = 0; i < tx->num_extra_frag; i++) {
-			if (ccmp_encrypt_skb(tx, tx->extra_frag[i], test)
-			    < 0)
-				return TX_DROP;
-		}
-	}
+	/* skip original if fragmented */
+	if (skb->next)
+		skb = skb->next;
+
+	do {
+		if (ccmp_encrypt_skb(tx, skb, test) < 0)
+			return TX_DROP;
+	} while ((skb = skb->next));
 
 	return TX_CONTINUE;
 }
--- everything.orig/net/mac80211/util.c	2008-05-07 11:13:00.000000000 +0200
+++ everything/net/mac80211/util.c	2008-05-07 11:13:19.000000000 +0200
@@ -165,22 +165,6 @@ int ieee80211_get_mesh_hdrlen(struct iee
 	}
 }
 
-void ieee80211_tx_set_protected(struct ieee80211_tx_data *tx)
-{
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
-
-	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
-	if (tx->extra_frag) {
-		struct ieee80211_hdr *fhdr;
-		int i;
-		for (i = 0; i < tx->num_extra_frag; i++) {
-			fhdr = (struct ieee80211_hdr *)
-				tx->extra_frag[i]->data;
-			fhdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
-		}
-	}
-}
-
 int ieee80211_frame_duration(struct ieee80211_local *local, size_t len,
 			     int rate, int erp, int short_preamble)
 {
@@ -333,15 +317,11 @@ void ieee80211_wake_queue(struct ieee802
 
 	if (test_and_clear_bit(IEEE80211_LINK_STATE_XOFF,
 			       &local->state[queue])) {
-		if (test_bit(IEEE80211_LINK_STATE_PENDING,
-			     &local->state[queue]))
-			tasklet_schedule(&local->tx_pending_tasklet);
-		else
-			if (!ieee80211_qdisc_installed(local->mdev)) {
-				if (queue == 0)
-					netif_wake_queue(local->mdev);
-			} else
-				__netif_schedule(local->mdev);
+		if (!ieee80211_qdisc_installed(local->mdev)) {
+			if (queue == 0)
+				netif_wake_queue(local->mdev);
+		} else
+			__netif_schedule(local->mdev);
 	}
 }
 EXPORT_SYMBOL(ieee80211_wake_queue);
--- everything.orig/net/mac80211/wme.c	2008-05-07 11:12:48.000000000 +0200
+++ everything/net/mac80211/wme.c	2008-05-07 11:13:19.000000000 +0200
@@ -235,9 +235,6 @@ static int wme_qdiscop_enqueue(struct sk
 }
 
 
-/* TODO: clean up the cases where master_hard_start_xmit
- * returns non 0 - it shouldn't ever do that. Once done we
- * can remove this function */
 static int wme_qdiscop_requeue(struct sk_buff *skb, struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
@@ -246,7 +243,7 @@ static int wme_qdiscop_requeue(struct sk
 	struct Qdisc *qdisc;
 	int err;
 
-	/* we recorded which queue to use earlier! */
+	/* We recorded which queue to use earlier. */
 	qdisc = q->queues[pkt_data->queue];
 
 	if ((err = qdisc->ops->requeue(skb, qdisc)) == 0) {
@@ -273,9 +270,7 @@ static struct sk_buff *wme_qdiscop_deque
 		/* see if there is room in this hardware queue */
 		if ((test_bit(IEEE80211_LINK_STATE_XOFF,
 				&local->state[queue])) ||
-		    (test_bit(IEEE80211_LINK_STATE_PENDING,
-				&local->state[queue])) ||
-			 (!test_bit(queue, q->qdisc_pool)))
+		    (!test_bit(queue, q->qdisc_pool)))
 			continue;
 
 		/* there is space - try and get a frame */
--- everything.orig/net/mac80211/main.c	2008-05-07 11:12:57.000000000 +0200
+++ everything/net/mac80211/main.c	2008-05-07 12:43:17.000000000 +0200
@@ -408,7 +408,6 @@ static int ieee80211_open(struct net_dev
 		WARN_ON(res);
 		if (res)
 			goto err_del_interface;
-		tasklet_enable(&local->tx_pending_tasklet);
 		tasklet_enable(&local->tasklet);
 	}
 
@@ -602,7 +601,6 @@ static int ieee80211_stop(struct net_dev
 
 		ieee80211_led_radio(local, 0);
 
-		tasklet_disable(&local->tx_pending_tasklet);
 		tasklet_disable(&local->tasklet);
 	}
 
@@ -1204,8 +1202,16 @@ void ieee80211_tx_status_irqsafe(struct 
 	struct ieee80211_tx_status *saved;
 	int tmp;
 
+	if (WARN_ON(!skb))
+		return;
+
+	if (WARN_ON(!status)) {
+		dev_kfree_skb(skb);
+		return;
+	}
+
 	skb->dev = local->mdev;
-	saved = kmalloc(sizeof(struct ieee80211_tx_status), GFP_ATOMIC);
+	saved = kmemdup(status, sizeof(struct ieee80211_tx_status), GFP_ATOMIC);
 	if (unlikely(!saved)) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "%s: Not enough memory, "
@@ -1216,7 +1222,6 @@ void ieee80211_tx_status_irqsafe(struct 
 		dev_kfree_skb_any(skb);
 		return;
 	}
-	memcpy(saved, status, sizeof(struct ieee80211_tx_status));
 	/* copy pointer to saved status into skb->cb for use by tasklet */
 	memcpy(skb->cb, &saved, sizeof(saved));
 
@@ -1435,10 +1440,10 @@ void ieee80211_tx_status(struct ieee8021
 	struct ieee80211_sub_if_data *sdata;
 	struct net_device *prev_dev = NULL;
 
-	if (!status) {
-		printk(KERN_ERR
-		       "%s: ieee80211_tx_status called with NULL status\n",
-		       wiphy_name(local->hw.wiphy));
+	if (WARN_ON(!skb))
+		return;
+
+	if (WARN_ON(!status)) {
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -1665,10 +1670,6 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 
 	sta_info_init(local);
 
-	tasklet_init(&local->tx_pending_tasklet, ieee80211_tx_pending,
-		     (unsigned long)local);
-	tasklet_disable(&local->tx_pending_tasklet);
-
 	tasklet_init(&local->tasklet,
 		     ieee80211_tasklet_handler,
 		     (unsigned long) local);
@@ -1851,8 +1852,8 @@ void ieee80211_unregister_hw(struct ieee
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata, *tmp;
+	int queue;
 
-	tasklet_kill(&local->tx_pending_tasklet);
 	tasklet_kill(&local->tasklet);
 
 	rtnl_lock();
@@ -1886,7 +1887,6 @@ void ieee80211_unregister_hw(struct ieee
 	rtnl_unlock();
 
 	ieee80211_rx_bss_list_deinit(local->mdev);
-	ieee80211_clear_tx_pending(local);
 	sta_info_stop(local);
 	rate_control_deinitialize(local);
 	debugfs_hw_del(local);
@@ -1898,6 +1898,21 @@ void ieee80211_unregister_hw(struct ieee
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);
 
+	/* free possibly queued fragmented skbs */
+	for (queue = 0; queue < hw->queues; queue++) {
+		struct sk_buff *skb = local->pending_packet[queue];
+		struct sk_buff *frag;
+		if (!skb)
+			continue;
+		frag = skb->next;
+		while (frag) {
+			skb->next = frag->next;
+			dev_kfree_skb(frag);
+			frag = skb->next;
+		}
+		dev_kfree_skb(skb);
+	}
+
 	destroy_workqueue(local->hw.workqueue);
 	wiphy_unregister(local->hw.wiphy);
 	ieee80211_wep_free(local);
@@ -1921,6 +1936,9 @@ static int __init ieee80211_init(void)
 	int ret;
 
 	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
+	BUILD_BUG_ON(sizeof(struct ieee80211_tx_control) > sizeof(skb->cb));
+	BUILD_BUG_ON(offsetof(struct ieee80211_tx_control, flags) != 0);
+	BUILD_BUG_ON(offsetof(struct ieee80211_tx_packet_data, flags) != 0);
 
 	ret = rc80211_pid_init();
 	if (ret)
--- everything.orig/include/net/mac80211.h	2008-05-07 11:13:00.000000000 +0200
+++ everything/include/net/mac80211.h	2008-05-07 12:01:25.000000000 +0200
@@ -3,7 +3,7 @@
  *
  * Copyright 2002-2005, Devicescape Software, Inc.
  * Copyright 2006-2007	Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
- * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ * Copyright 2007-2008	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -233,6 +233,7 @@ struct ieee80211_bss_conf {
  * @IEEE80211_TXCTL_40_MHZ_WIDTH: send this frame using 40 Mhz channel width
  * @IEEE80211_TXCTL_DUP_DATA: duplicate data frame on both 20 Mhz channels
  * @IEEE80211_TXCTL_SHORT_GI: send this frame using short guard interval
+ * @IEEE80211_TXCTL_INJECTED: Frame was injected (NOT for driver use!)
  */
 enum mac80211_tx_control_flags {
 	IEEE80211_TXCTL_REQ_TX_STATUS		= (1<<0),
@@ -254,6 +255,7 @@ enum mac80211_tx_control_flags {
 	IEEE80211_TXCTL_40_MHZ_WIDTH		= (1<<16),
 	IEEE80211_TXCTL_DUP_DATA		= (1<<17),
 	IEEE80211_TXCTL_SHORT_GI		= (1<<18),
+	IEEE80211_TXCTL_INJECTED		= (1<<19),
 };
 
 /* Transmit control fields. This data structure is passed to low-level driver
@@ -278,6 +280,9 @@ struct ieee80211_tx_control {
 				 * This could be used when set_retry_limit
 				 * is not implemented by the driver */
 
+	u16 queue;		/* hardware queue to use for this frame;
+				 * 0 = highest, hw->queues-1 = lowest */
+
 	struct ieee80211_vif *vif;
 
 	/* Key used for hardware encryption
@@ -290,10 +295,7 @@ struct ieee80211_tx_control {
 				 * position represents antenna number used */
 	u8 icv_len;		/* length of the ICV/MIC field in octets */
 	u8 iv_len;		/* length of the IV field in octets */
-	u16 queue;		/* hardware queue to use for this frame;
-				 * 0 = highest, hw->queues-1 = lowest */
 	u16 aid;		/* Station AID */
-	int type;	/* internal */
 };
 
 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
