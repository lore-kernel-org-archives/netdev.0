From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC/RFT 1/4] mac80211: use rate index in TX control
Date: Wed, 30 Apr 2008 14:40:56 +0200
Message-ID: <20080430130048.146297000@sipsolutions.net>
References: <20080430124055.091382000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=036-mac80211-tx-rate-idx.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch modifies struct ieee80211_tx_control to give band
info and the rate index (instead of rate pointers) to drivers.
This mostly serves to reduce the TX control structure size to
make it fit into skb->cb so that the fragmentation code can
put it there and we can think about passing it to drivers that
way in the future.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 drivers/net/wireless/adm8211.c              |    6 -
 drivers/net/wireless/at76_usb.c             |    2 
 drivers/net/wireless/ath5k/base.c           |    8 +-
 drivers/net/wireless/b43/main.c             |    2 
 drivers/net/wireless/b43/xmit.c             |   13 ++-
 drivers/net/wireless/b43legacy/xmit.c       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |    6 -
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    7 +
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |   12 +--
 drivers/net/wireless/iwlwifi/iwl-4965.c     |   13 +--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 -
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    4 -
 drivers/net/wireless/p54/p54common.c        |    2 
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    6 -
 drivers/net/wireless/rtl8180_dev.c          |   19 ++---
 drivers/net/wireless/rtl8187_dev.c          |   10 --
 drivers/net/wireless/zd1211rw/zd_mac.c      |    7 +
 include/net/mac80211.h                      |   51 ++++++++++---
 net/mac80211/ieee80211_i.h                  |    8 +-
 net/mac80211/mlme.c                         |    6 -
 net/mac80211/rate.c                         |   12 ++-
 net/mac80211/rate.h                         |   25 ++----
 net/mac80211/rc80211_pid_algo.c             |    6 -
 net/mac80211/tx.c                           |  104 +++++++++++++++-------------
 net/mac80211/util.c                         |   10 ++
 25 files changed, 200 insertions(+), 152 deletions(-)

--- everything.orig/include/net/mac80211.h	2008-04-29 22:49:27.000000000 +0200
+++ everything/include/net/mac80211.h	2008-04-29 23:56:43.000000000 +0200
@@ -266,27 +266,26 @@ enum mac80211_tx_control_flags {
  * ieee80211_ops->remove_interface() callback funtion.
  * The hw_key pointer is valid until it has been removed with the
  * ieee80211_ops->set_key() callback function.
- * The tx_rate and alt_retry_rate pointers are valid until the phy is
- * deregistered.
  */
 struct ieee80211_tx_control {
-	struct ieee80211_vif *vif;
-	struct ieee80211_rate *tx_rate;
+	u32 flags;		/* tx control flags defined above */
+
+	s8 tx_rate_idx,		/* Transmit rate (indexes registered rates) */
+	   rts_cts_rate_idx,	/* Transmit rate for RTS/CTS frame */
+	   alt_retry_rate_idx;	/* retry rate for the last retries */
 
-	/* Transmit rate for RTS/CTS frame */
-	struct ieee80211_rate *rts_cts_rate;
+	s8 retry_limit;		/* 1 = only first attempt, 2 = one retry, ..
+				 * This could be used when set_retry_limit
+				 * is not implemented by the driver */
 
-	/* retry rate for the last retries */
-	struct ieee80211_rate *alt_retry_rate;
+	struct ieee80211_vif *vif;
 
 	/* Key used for hardware encryption
 	 * NULL if IEEE80211_TXCTL_DO_NOT_ENCRYPT is set */
 	struct ieee80211_key_conf *hw_key;
 
-	u32 flags;		/* tx control flags defined above */
-	u8 retry_limit;		/* 1 = only first attempt, 2 = one retry, ..
-				 * This could be used when set_retry_limit
-				 * is not implemented by the driver */
+	enum ieee80211_band band;
+
 	u8 antenna_sel_tx; 	/* 0 = default/diversity, otherwise bit
 				 * position represents antenna number used */
 	u8 icv_len;		/* length of the ICV/MIC field in octets */
@@ -298,6 +297,7 @@ struct ieee80211_tx_control {
 };
 
 
+
 /**
  * enum mac80211_rx_flags - receive flags
  *
@@ -799,6 +799,33 @@ static inline void SET_IEEE80211_PERM_AD
 	memcpy(hw->wiphy->perm_addr, addr, ETH_ALEN);
 }
 
+static inline struct ieee80211_rate *
+ieee80211_get_tx_rate(const struct ieee80211_hw *hw,
+		      const struct ieee80211_tx_control *c)
+{
+	if (WARN_ON(c->tx_rate_idx < 0))
+		return NULL;
+	return &hw->wiphy->bands[c->band]->bitrates[c->tx_rate_idx];
+}
+
+static inline struct ieee80211_rate *
+ieee80211_get_rts_cts_rate(const struct ieee80211_hw *hw,
+			   const struct ieee80211_tx_control *c)
+{
+	if (c->rts_cts_rate_idx < 0)
+		return NULL;
+	return &hw->wiphy->bands[c->band]->bitrates[c->rts_cts_rate_idx];
+}
+
+static inline struct ieee80211_rate *
+ieee80211_get_alt_retry_rate(const struct ieee80211_hw *hw,
+			     const struct ieee80211_tx_control *c)
+{
+	if (c->alt_retry_rate_idx < 0)
+		return NULL;
+	return &hw->wiphy->bands[c->band]->bitrates[c->alt_retry_rate_idx];
+}
+
 /**
  * DOC: Hardware crypto acceleration
  *
--- everything.orig/net/mac80211/rate.h	2008-04-29 22:56:34.000000000 +0200
+++ everything/net/mac80211/rate.h	2008-04-29 23:15:36.000000000 +0200
@@ -19,14 +19,15 @@
 #include "ieee80211_i.h"
 #include "sta_info.h"
 
-/* TODO: kdoc */
+/**
+ * struct rate_selection - rate selection for rate control algos
+ * @rate: selected transmission rate index
+ * @nonerp: Non-ERP rate to use instead if ERP cannot be used
+ * @probe: rate for probing (or -1)
+ *
+ */
 struct rate_selection {
-	/* Selected transmission rate */
-	struct ieee80211_rate *rate;
-	/* Non-ERP rate to use if mac80211 decides it cannot use an ERP rate */
-	struct ieee80211_rate *nonerp;
-	/* probe with this rate, or NULL for no probing */
-	struct ieee80211_rate *probe;
+	s8 rate_idx, nonerp_idx, probe_idx;
 };
 
 struct rate_control_ops {
@@ -138,7 +139,7 @@ static inline int rate_supported(struct 
 	return (sta == NULL || sta->supp_rates[band] & BIT(index));
 }
 
-static inline int
+static inline s8
 rate_lowest_index(struct ieee80211_local *local,
 		  struct ieee80211_supported_band *sband,
 		  struct sta_info *sta)
@@ -155,14 +156,6 @@ rate_lowest_index(struct ieee80211_local
 	return 0;
 }
 
-static inline struct ieee80211_rate *
-rate_lowest(struct ieee80211_local *local,
-	    struct ieee80211_supported_band *sband,
-	    struct sta_info *sta)
-{
-	return &sband->bitrates[rate_lowest_index(local, sband, sta)];
-}
-
 
 /* functions for rate control related to a device */
 int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
--- everything.orig/net/mac80211/mlme.c	2008-04-29 22:56:00.000000000 +0200
+++ everything/net/mac80211/mlme.c	2008-04-29 23:20:08.000000000 +0200
@@ -2371,15 +2371,15 @@ static int ieee80211_sta_join_ibss(struc
 
 		memset(&control, 0, sizeof(control));
 		rate_control_get_rate(dev, sband, skb, &ratesel);
-		if (!ratesel.rate) {
+		if (ratesel.rate_idx < 0) {
 			printk(KERN_DEBUG "%s: Failed to determine TX rate "
 			       "for IBSS beacon\n", dev->name);
 			break;
 		}
 		control.vif = &sdata->vif;
-		control.tx_rate = ratesel.rate;
+		control.tx_rate_idx = ratesel.rate_idx;
 		if (sdata->bss_conf.use_short_preamble &&
-		    ratesel.rate->flags & IEEE80211_RATE_SHORT_PREAMBLE)
+		    sband->bitrates[ratesel.rate_idx].flags & IEEE80211_RATE_SHORT_PREAMBLE)
 			control.flags |= IEEE80211_TXCTL_SHORT_PREAMBLE;
 		control.antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control.flags |= IEEE80211_TXCTL_NO_ACK;
--- everything.orig/net/mac80211/rate.c	2008-04-29 22:59:56.000000000 +0200
+++ everything/net/mac80211/rate.c	2008-04-29 23:16:53.000000000 +0200
@@ -176,20 +176,24 @@ void rate_control_get_rate(struct net_de
 	rcu_read_lock();
 	sta = sta_info_get(local, hdr->addr1);
 
-	memset(sel, 0, sizeof(struct rate_selection));
+	sel->rate_idx = -1;
+	sel->nonerp_idx = -1;
+	sel->probe_idx = -1;
 
 	ref->ops->get_rate(ref->priv, dev, sband, skb, sel);
 
+	BUG_ON(sel->rate_idx < 0);
+
 	/* Select a non-ERP backup rate. */
-	if (!sel->nonerp) {
+	if (sel->nonerp_idx < 0) {
 		for (i = 0; i < sband->n_bitrates; i++) {
 			struct ieee80211_rate *rate = &sband->bitrates[i];
-			if (sel->rate->bitrate < rate->bitrate)
+			if (sband->bitrates[sel->rate_idx].bitrate < rate->bitrate)
 				break;
 
 			if (rate_supported(sta, sband->band, i) &&
 			    !(rate->flags & IEEE80211_RATE_ERP_G))
-				sel->nonerp = rate;
+				sel->nonerp_idx = i;
 		}
 	}
 
--- everything.orig/net/mac80211/ieee80211_i.h	2008-04-29 22:55:37.000000000 +0200
+++ everything/net/mac80211/ieee80211_i.h	2008-04-29 23:33:09.000000000 +0200
@@ -159,11 +159,11 @@ struct ieee80211_tx_data {
 
 	struct ieee80211_tx_control *control;
 	struct ieee80211_channel *channel;
-	struct ieee80211_rate *rate;
+	s8 rate_idx;
 	/* use this rate (if set) for last fragment; rate can
 	 * be set to lower rate for the first fragments, e.g.,
 	 * when using CTS protection with IEEE 802.11g. */
-	struct ieee80211_rate *last_frag_rate;
+	s8 last_frag_rate_idx;
 
 	/* Extra fragments (in addition to the first fragment
 	 * in skb) */
@@ -225,9 +225,9 @@ struct ieee80211_tx_stored_packet {
 	struct ieee80211_tx_control control;
 	struct sk_buff *skb;
 	struct sk_buff **extra_frag;
-	struct ieee80211_rate *last_frag_rate;
+	s8 last_frag_rate_idx;
 	int num_extra_frag;
-	unsigned int last_frag_rate_ctrl_probe;
+	bool last_frag_rate_ctrl_probe;
 };
 
 struct beacon_data {
--- everything.orig/net/mac80211/rc80211_pid_algo.c	2008-04-29 23:11:25.000000000 +0200
+++ everything/net/mac80211/rc80211_pid_algo.c	2008-04-29 23:26:07.000000000 +0200
@@ -266,7 +266,7 @@ static void rate_control_pid_tx_status(v
 
 	/* Ignore all frames that were sent with a different rate than the rate
 	 * we currently advise mac80211 to use. */
-	if (status->control.tx_rate != &sband->bitrates[sta->txrate_idx])
+	if (status->control.tx_rate_idx != sta->txrate_idx)
 		goto unlock;
 
 	spinfo = sta->rate_ctrl_priv;
@@ -330,7 +330,7 @@ static void rate_control_pid_get_rate(vo
 	fc = le16_to_cpu(hdr->frame_control);
 	if ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
 	    is_multicast_ether_addr(hdr->addr1) || !sta) {
-		sel->rate = rate_lowest(local, sband, sta);
+		sel->rate_idx = rate_lowest_index(local, sband, sta);
 		rcu_read_unlock();
 		return;
 	}
@@ -349,7 +349,7 @@ static void rate_control_pid_get_rate(vo
 
 	rcu_read_unlock();
 
-	sel->rate = &sband->bitrates[rateidx];
+	sel->rate_idx = rateidx;
 
 #ifdef CONFIG_MAC80211_DEBUGFS
 	rate_control_pid_event_tx_rate(
--- everything.orig/net/mac80211/tx.c	2008-04-29 23:00:43.000000000 +0200
+++ everything/net/mac80211/tx.c	2008-04-29 23:38:40.000000000 +0200
@@ -91,11 +91,12 @@ static u16 ieee80211_duration(struct iee
 			      int next_frag_len)
 {
 	int rate, mrate, erp, dur, i;
-	struct ieee80211_rate *txrate = tx->rate;
+	struct ieee80211_rate *txrate;
 	struct ieee80211_local *local = tx->local;
 	struct ieee80211_supported_band *sband;
 
-	sband = local->hw.wiphy->bands[local->hw.conf.channel->band];
+	sband = local->hw.wiphy->bands[tx->channel->band];
+	txrate = &sband->bitrates[tx->rate_idx];
 
 	erp = 0;
 	if (tx->sdata->flags & IEEE80211_SDATA_OPERATING_GMODE)
@@ -610,40 +611,40 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 	struct rate_selection rsel;
 	struct ieee80211_supported_band *sband;
 
-	sband = tx->local->hw.wiphy->bands[tx->local->hw.conf.channel->band];
+	sband = tx->local->hw.wiphy->bands[tx->channel->band];
 
-	if (likely(!tx->rate)) {
+	if (likely(tx->rate_idx < 0)) {
 		rate_control_get_rate(tx->dev, sband, tx->skb, &rsel);
-		tx->rate = rsel.rate;
-		if (unlikely(rsel.probe)) {
+		tx->rate_idx = rsel.rate_idx;
+		if (unlikely(rsel.probe_idx >= 0)) {
 			tx->control->flags |=
 				IEEE80211_TXCTL_RATE_CTRL_PROBE;
 			tx->flags |= IEEE80211_TX_PROBE_LAST_FRAG;
-			tx->control->alt_retry_rate = tx->rate;
-			tx->rate = rsel.probe;
+			tx->control->alt_retry_rate_idx = tx->rate_idx;
+			tx->rate_idx = rsel.probe_idx;
 		} else
-			tx->control->alt_retry_rate = NULL;
+			tx->control->alt_retry_rate_idx = -1;
 
-		if (!tx->rate)
+		if (unlikely(tx->rate_idx < 0))
 			return TX_DROP;
 	} else
-		tx->control->alt_retry_rate = NULL;
+		tx->control->alt_retry_rate_idx = -1;
 
 	if (tx->sdata->bss_conf.use_cts_prot &&
-	    (tx->flags & IEEE80211_TX_FRAGMENTED) && rsel.nonerp) {
-		tx->last_frag_rate = tx->rate;
-		if (rsel.probe)
+	    (tx->flags & IEEE80211_TX_FRAGMENTED) && (rsel.nonerp_idx >= 0)) {
+		tx->last_frag_rate_idx = tx->rate_idx;
+		if (rsel.probe_idx >= 0)
 			tx->flags &= ~IEEE80211_TX_PROBE_LAST_FRAG;
 		else
 			tx->flags |= IEEE80211_TX_PROBE_LAST_FRAG;
-		tx->rate = rsel.nonerp;
-		tx->control->tx_rate = rsel.nonerp;
+		tx->rate_idx = rsel.nonerp_idx;
+		tx->control->tx_rate_idx = rsel.nonerp_idx;
 		tx->control->flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 	} else {
-		tx->last_frag_rate = tx->rate;
-		tx->control->tx_rate = tx->rate;
+		tx->last_frag_rate_idx = tx->rate_idx;
+		tx->control->tx_rate_idx = tx->rate_idx;
 	}
-	tx->control->tx_rate = tx->rate;
+	tx->control->tx_rate_idx = tx->rate_idx;
 
 	return TX_CONTINUE;
 }
@@ -655,6 +656,9 @@ ieee80211_tx_h_misc(struct ieee80211_tx_
 	u16 fc = le16_to_cpu(hdr->frame_control);
 	u16 dur;
 	struct ieee80211_tx_control *control = tx->control;
+	struct ieee80211_supported_band *sband;
+
+	sband = tx->local->hw.wiphy->bands[tx->channel->band];
 
 	if (!control->retry_limit) {
 		if (!is_multicast_ether_addr(hdr->addr1)) {
@@ -681,14 +685,14 @@ ieee80211_tx_h_misc(struct ieee80211_tx_
 		 * frames.
 		 * TODO: The last fragment could still use multiple retry
 		 * rates. */
-		control->alt_retry_rate = NULL;
+		control->alt_retry_rate_idx = -1;
 	}
 
 	/* Use CTS protection for unicast frames sent using extended rates if
 	 * there are associated non-ERP stations and RTS/CTS is not configured
 	 * for the frame. */
 	if ((tx->sdata->flags & IEEE80211_SDATA_OPERATING_GMODE) &&
-	    (tx->rate->flags & IEEE80211_RATE_ERP_G) &&
+	    (sband->bitrates[tx->rate_idx].flags & IEEE80211_RATE_ERP_G) &&
 	    (tx->flags & IEEE80211_TX_UNICAST) &&
 	    tx->sdata->bss_conf.use_cts_prot &&
 	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
@@ -698,7 +702,7 @@ ieee80211_tx_h_misc(struct ieee80211_tx_
 	 * short preambles at the selected rate and short preambles are
 	 * available on the network at the current point in time. */
 	if (((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) &&
-	    (tx->rate->flags & IEEE80211_RATE_SHORT_PREAMBLE) &&
+	    (sband->bitrates[tx->rate_idx].flags & IEEE80211_RATE_SHORT_PREAMBLE) &&
 	    tx->sdata->bss_conf.use_short_preamble &&
 	    (!tx->sta || test_sta_flags(tx->sta, WLAN_STA_SHORT_PREAMBLE))) {
 		tx->control->flags |= IEEE80211_TXCTL_SHORT_PREAMBLE;
@@ -715,32 +719,32 @@ ieee80211_tx_h_misc(struct ieee80211_tx_
 	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
 	    (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)) {
 		struct ieee80211_supported_band *sband;
-		struct ieee80211_rate *rate, *baserate;
+		struct ieee80211_rate *rate;
+		s8 baserate = -1;
 		int idx;
 
-		sband = tx->local->hw.wiphy->bands[
-				tx->local->hw.conf.channel->band];
+		sband = tx->local->hw.wiphy->bands[tx->channel->band];
 
 		/* Do not use multiple retry rates when using RTS/CTS */
-		control->alt_retry_rate = NULL;
+		control->alt_retry_rate_idx = -1;
 
 		/* Use min(data rate, max base rate) as CTS/RTS rate */
-		rate = tx->rate;
-		baserate = NULL;
+		rate = &sband->bitrates[tx->rate_idx];
 
 		for (idx = 0; idx < sband->n_bitrates; idx++) {
 			if (sband->bitrates[idx].bitrate > rate->bitrate)
 				continue;
 			if (tx->sdata->basic_rates & BIT(idx) &&
-			    (!baserate ||
-			     (baserate->bitrate < sband->bitrates[idx].bitrate)))
-				baserate = &sband->bitrates[idx];
+			    (baserate < 0 ||
+			     (sband->bitrates[baserate].bitrate
+			      < sband->bitrates[idx].bitrate)))
+				baserate = idx;
 		}
 
-		if (baserate)
-			control->rts_cts_rate = baserate;
+		if (baserate >= 0)
+			control->rts_cts_rate_idx = baserate;
 		else
-			control->rts_cts_rate = &sband->bitrates[0];
+			control->rts_cts_rate_idx = 0;
 	}
 
 	if (tx->sta) {
@@ -768,7 +772,11 @@ ieee80211_tx_h_load_stats(struct ieee802
 	struct sk_buff *skb = tx->skb;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	u32 load = 0, hdrtime;
-	struct ieee80211_rate *rate = tx->rate;
+	struct ieee80211_rate *rate;
+	struct ieee80211_supported_band *sband;
+
+	sband = tx->local->hw.wiphy->bands[tx->channel->band];
+	rate = &sband->bitrates[tx->rate_idx];
 
 	/* TODO: this could be part of tx_status handling, so that the number
 	 * of retries would be known; TX rate should in that case be stored
@@ -803,7 +811,7 @@ ieee80211_tx_h_load_stats(struct ieee802
 		for (i = 0; i < tx->num_extra_frag; i++) {
 			load += 2 * hdrtime;
 			load += tx->extra_frag[i]->len *
-				tx->rate->bitrate;
+				rate->bitrate;
 		}
 	}
 
@@ -859,7 +867,7 @@ __ieee80211_parse_tx_radiotap(struct iee
 	int ret = ieee80211_radiotap_iterator_init(&iterator, rthdr, skb->len);
 	struct ieee80211_tx_control *control = tx->control;
 
-	sband = tx->local->hw.wiphy->bands[tx->local->hw.conf.channel->band];
+	sband = tx->local->hw.wiphy->bands[tx->channel->band];
 
 	control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	tx->flags |= IEEE80211_TX_INJECTED;
@@ -899,7 +907,7 @@ __ieee80211_parse_tx_radiotap(struct iee
 				r = &sband->bitrates[i];
 
 				if (r->bitrate == target_rate) {
-					tx->rate = r;
+					tx->rate_idx = i;
 					break;
 				}
 			}
@@ -1098,7 +1106,7 @@ static int __ieee80211_tx(struct ieee802
 			if (__ieee80211_queue_stopped(local, control->queue))
 				return IEEE80211_TX_FRAG_AGAIN;
 			if (i == tx->num_extra_frag) {
-				control->tx_rate = tx->last_frag_rate;
+				control->tx_rate_idx = tx->last_frag_rate_idx;
 
 				if (tx->flags & IEEE80211_TX_PROBE_LAST_FRAG)
 					control->flags |=
@@ -1156,6 +1164,7 @@ static int ieee80211_tx(struct net_devic
 
 	sta = tx.sta;
 	tx.channel = local->hw.conf.channel;
+	control->band = tx.channel->band;
 
 	for (handler = ieee80211_tx_handlers; *handler != NULL;
 	     handler++) {
@@ -1188,7 +1197,7 @@ static int ieee80211_tx(struct net_devic
 				next_len = tx.extra_frag[i + 1]->len;
 			} else {
 				next_len = 0;
-				tx.rate = tx.last_frag_rate;
+				tx.rate_idx = tx.last_frag_rate_idx;
 			}
 			dur = ieee80211_duration(&tx, 0, next_len);
 			hdr->duration_id = cpu_to_le16(dur);
@@ -1225,7 +1234,7 @@ retry:
 		store->skb = skb;
 		store->extra_frag = tx.extra_frag;
 		store->num_extra_frag = tx.num_extra_frag;
-		store->last_frag_rate = tx.last_frag_rate;
+		store->last_frag_rate_idx = tx.last_frag_rate_idx;
 		store->last_frag_rate_ctrl_probe =
 			!!(tx.flags & IEEE80211_TX_PROBE_LAST_FRAG);
 	}
@@ -1681,7 +1690,7 @@ void ieee80211_tx_pending(unsigned long 
 		tx.control = &store->control;
 		tx.extra_frag = store->extra_frag;
 		tx.num_extra_frag = store->num_extra_frag;
-		tx.last_frag_rate = store->last_frag_rate;
+		tx.last_frag_rate_idx = store->last_frag_rate_idx;
 		tx.flags = 0;
 		if (store->last_frag_rate_ctrl_probe)
 			tx.flags |= IEEE80211_TX_PROBE_LAST_FRAG;
@@ -1785,9 +1794,10 @@ struct sk_buff *ieee80211_beacon_get(str
 	struct ieee80211_mgmt *mgmt;
 	int *num_beacons;
 	bool err = true;
+	enum ieee80211_band band = local->hw.conf.channel->band;
 	u8 *pos;
 
-	sband = local->hw.wiphy->bands[local->hw.conf.channel->band];
+	sband = local->hw.wiphy->bands[band];
 
 	rcu_read_lock();
 
@@ -1881,8 +1891,9 @@ struct sk_buff *ieee80211_beacon_get(str
 	}
 
 	if (control) {
+		control->band = band;
 		rate_control_get_rate(local->mdev, sband, skb, &rsel);
-		if (!rsel.rate) {
+		if (unlikely(rsel.rate_idx < 0)) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: ieee80211_beacon_get: "
 				       "no rate found\n",
@@ -1894,9 +1905,9 @@ struct sk_buff *ieee80211_beacon_get(str
 		}
 
 		control->vif = vif;
-		control->tx_rate = rsel.rate;
+		control->tx_rate_idx = rsel.rate_idx;
 		if (sdata->bss_conf.use_short_preamble &&
-		    rsel.rate->flags & IEEE80211_RATE_SHORT_PREAMBLE)
+		    sband->bitrates[rsel.rate_idx].flags & IEEE80211_RATE_SHORT_PREAMBLE)
 			control->flags |= IEEE80211_TXCTL_SHORT_PREAMBLE;
 		control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control->flags |= IEEE80211_TXCTL_NO_ACK;
@@ -2001,6 +2012,7 @@ ieee80211_get_buffered_bc(struct ieee802
 	sta = tx.sta;
 	tx.flags |= IEEE80211_TX_PS_BUFFERED;
 	tx.channel = local->hw.conf.channel;
+	control->band = tx.channel->band;
 
 	for (handler = ieee80211_tx_handlers; *handler != NULL; handler++) {
 		res = (*handler)(&tx);
--- everything.orig/net/mac80211/util.c	2008-04-29 23:13:24.000000000 +0200
+++ everything/net/mac80211/util.c	2008-04-29 23:25:15.000000000 +0200
@@ -266,10 +266,13 @@ __le16 ieee80211_rts_duration(struct iee
 	bool short_preamble;
 	int erp;
 	u16 dur;
+	struct ieee80211_supported_band *sband;
+
+	sband = local->hw.wiphy->bands[local->hw.conf.channel->band];
 
 	short_preamble = sdata->bss_conf.use_short_preamble;
 
-	rate = frame_txctl->rts_cts_rate;
+	rate = &sband->bitrates[frame_txctl->rts_cts_rate_idx];
 
 	erp = 0;
 	if (sdata->flags & IEEE80211_SDATA_OPERATING_GMODE)
@@ -300,10 +303,13 @@ __le16 ieee80211_ctstoself_duration(stru
 	bool short_preamble;
 	int erp;
 	u16 dur;
+	struct ieee80211_supported_band *sband;
+
+	sband = local->hw.wiphy->bands[local->hw.conf.channel->band];
 
 	short_preamble = sdata->bss_conf.use_short_preamble;
 
-	rate = frame_txctl->rts_cts_rate;
+	rate = &sband->bitrates[frame_txctl->rts_cts_rate_idx];
 	erp = 0;
 	if (sdata->flags & IEEE80211_SDATA_OPERATING_GMODE)
 		erp = rate->flags & IEEE80211_RATE_ERP_G;
--- everything.orig/drivers/net/wireless/adm8211.c	2008-04-29 23:49:15.000000000 +0200
+++ everything/drivers/net/wireless/adm8211.c	2008-04-29 23:50:11.000000000 +0200
@@ -1693,10 +1693,10 @@ static int adm8211_tx(struct ieee80211_h
 	size_t payload_len, hdrlen;
 	int plcp, dur, len, plcp_signal, short_preamble;
 	struct ieee80211_hdr *hdr;
+	struct ieee80211_rate *txrate = ieee80211_get_tx_rate(dev, control);
 
-	short_preamble = !!(control->tx_rate->flags &
-					IEEE80211_TXCTL_SHORT_PREAMBLE);
-	plcp_signal = control->tx_rate->bitrate;
+	short_preamble = !!(txrate->flags & IEEE80211_TXCTL_SHORT_PREAMBLE);
+	plcp_signal = txrate->bitrate;
 
 	hdr = (struct ieee80211_hdr *)skb->data;
 	fc = le16_to_cpu(hdr->frame_control) & ~IEEE80211_FCTL_PROTECTED;
--- everything.orig/drivers/net/wireless/at76_usb.c	2008-04-29 23:44:22.000000000 +0200
+++ everything/drivers/net/wireless/at76_usb.c	2008-04-29 23:44:48.000000000 +0200
@@ -1753,7 +1753,7 @@ static int at76_mac80211_tx(struct ieee8
 	memset(tx_buffer, 0, sizeof(*tx_buffer));
 	tx_buffer->padding = padding;
 	tx_buffer->wlength = cpu_to_le16(skb->len);
-	tx_buffer->tx_rate = control->tx_rate->hw_value;
+	tx_buffer->tx_rate = ieee80211_get_tx_rate(hw, control)->hw_value;
 	memset(tx_buffer->reserved, 0, sizeof(tx_buffer->reserved));
 	memcpy(tx_buffer->packet, skb->data, skb->len);
 
--- everything.orig/drivers/net/wireless/ath5k/base.c	2008-04-29 23:50:17.000000000 +0200
+++ everything/drivers/net/wireless/ath5k/base.c	2008-04-29 23:52:29.000000000 +0200
@@ -1329,7 +1329,8 @@ ath5k_txbuf_setup(struct ath5k_softc *sc
 
 	ret = ah->ah_setup_tx_desc(ah, ds, pktlen,
 		ieee80211_get_hdrlen_from_skb(skb), AR5K_PKT_TYPE_NORMAL,
-		(sc->power_level * 2), ctl->tx_rate->hw_value,
+		(sc->power_level * 2),
+		ieee80211_get_tx_rate(sc->hw, ctl)->hw_value,
 		ctl->retry_limit, keyidx, 0, flags, 0, 0);
 	if (ret)
 		goto err_unmap;
@@ -2061,7 +2062,8 @@ ath5k_beacon_setup(struct ath5k_softc *s
 	ret = ah->ah_setup_tx_desc(ah, ds, skb->len,
 			ieee80211_get_hdrlen_from_skb(skb),
 			AR5K_PKT_TYPE_BEACON, (sc->power_level * 2),
-			ctl->tx_rate->hw_value, 1, AR5K_TXKEYIX_INVALID,
+			ieee80211_get_tx_rate(sc->hw, ctl)->hw_value,
+			1, AR5K_TXKEYIX_INVALID,
 			antenna, flags, 0, 0);
 	if (ret)
 		goto err_unmap;
@@ -2669,7 +2671,7 @@ ath5k_tx(struct ieee80211_hw *hw, struct
 		memmove(skb->data, skb->data+pad, hdrlen);
 	}
 
-	sc->led_txrate = ctl->tx_rate->hw_value;
+	sc->led_txrate = ieee80211_get_tx_rate(hw, ctl)->hw_value;
 
 	spin_lock_irqsave(&sc->txbuflock, flags);
 	if (list_empty(&sc->txbuf)) {
--- everything.orig/drivers/net/wireless/b43/main.c	2008-04-29 23:52:44.000000000 +0200
+++ everything/drivers/net/wireless/b43/main.c	2008-04-29 23:53:58.000000000 +0200
@@ -1365,7 +1365,7 @@ static void b43_write_beacon_template(st
 	bcn = (const struct ieee80211_mgmt *)(dev->wl->current_beacon->data);
 	len = min((size_t) dev->wl->current_beacon->len,
 		  0x200 - sizeof(struct b43_plcp_hdr6));
-	rate = dev->wl->beacon_txctl.tx_rate->hw_value;
+	rate = ieee80211_get_tx_rate(dev->wl->hw, &dev->wl->beacon_txctl)->hw_value;
 
 	b43_write_template_common(dev, (const u8 *)bcn,
 				  len, ram_offset, shm_size_offset, rate);
--- everything.orig/drivers/net/wireless/b43/xmit.c	2008-04-29 23:54:15.000000000 +0200
+++ everything/drivers/net/wireless/b43/xmit.c	2008-04-29 23:58:24.000000000 +0200
@@ -201,13 +201,14 @@ int b43_generate_txhdr(struct b43_wldev 
 	u32 mac_ctl = 0;
 	u16 phy_ctl = 0;
 	u8 extra_ft = 0;
+	struct ieee80211_rate *txrate;
 
 	memset(txhdr, 0, sizeof(*txhdr));
 
-	WARN_ON(!txctl->tx_rate);
-	rate = txctl->tx_rate ? txctl->tx_rate->hw_value : B43_CCK_RATE_1MB;
+	txrate = ieee80211_get_tx_rate(dev->wl->hw, txctl);
+	rate = txrate ? txrate->hw_value : B43_CCK_RATE_1MB;
 	rate_ofdm = b43_is_ofdm_rate(rate);
-	fbrate = txctl->alt_retry_rate ? : txctl->tx_rate;
+	fbrate = ieee80211_get_alt_retry_rate(dev->wl->hw, txctl) ? : txrate;
 	rate_fb = fbrate->hw_value;
 	rate_fb_ofdm = b43_is_ofdm_rate(rate_fb);
 
@@ -336,9 +337,11 @@ int b43_generate_txhdr(struct b43_wldev 
 		int rts_rate, rts_rate_fb;
 		int rts_rate_ofdm, rts_rate_fb_ofdm;
 		struct b43_plcp_hdr6 *plcp;
+		struct ieee80211_rate *rts_cts_rate;
 
-		WARN_ON(!txctl->rts_cts_rate);
-		rts_rate = txctl->rts_cts_rate ? txctl->rts_cts_rate->hw_value : B43_CCK_RATE_1MB;
+		rts_cts_rate = ieee80211_get_rts_cts_rate(dev->wl->hw, txctl);
+
+		rts_rate = rts_cts_rate ? rts_cts_rate->hw_value : B43_CCK_RATE_1MB;
 		rts_rate_ofdm = b43_is_ofdm_rate(rts_rate);
 		rts_rate_fb = b43_calc_fallback_rate(rts_rate);
 		rts_rate_fb_ofdm = b43_is_ofdm_rate(rts_rate_fb);
--- everything.orig/drivers/net/wireless/b43legacy/xmit.c	2008-04-29 23:58:40.000000000 +0200
+++ everything/drivers/net/wireless/b43legacy/xmit.c	2008-04-30 00:00:33.000000000 +0200
@@ -201,15 +201,18 @@ static int generate_txhdr_fw3(struct b43
 	unsigned int plcp_fragment_len;
 	u32 mac_ctl = 0;
 	u16 phy_ctl = 0;
+	struct ieee80211_rate *tx_rate;
 
 	wlhdr = (const struct ieee80211_hdr *)fragment_data;
 	fctl = le16_to_cpu(wlhdr->frame_control);
 
 	memset(txhdr, 0, sizeof(*txhdr));
 
-	rate = txctl->tx_rate->hw_value;
+	tx_rate = ieee80211_get_tx_rate(dev->wl->hw, txctl);
+
+	rate = tx_rate->hw_value;
 	rate_ofdm = b43legacy_is_ofdm_rate(rate);
-	rate_fb = txctl->alt_retry_rate ? : txctl->tx_rate;
+	rate_fb = ieee80211_get_alt_retry_rate(dev->wl->hw, txctl) ? : tx_rate;
 	rate_fb_ofdm = b43legacy_is_ofdm_rate(rate_fb->hw_value);
 
 	txhdr->mac_frame_ctl = wlhdr->frame_control;
@@ -312,7 +315,7 @@ static int generate_txhdr_fw3(struct b43
 		int rts_rate_ofdm;
 		int rts_rate_fb_ofdm;
 
-		rts_rate = txctl->rts_cts_rate->hw_value;
+		rts_rate = ieee80211_get_rts_cts_rate(dev->wl->hw, txctl)->hw_value;
 		rts_rate_ofdm = b43legacy_is_ofdm_rate(rts_rate);
 		rts_rate_fb = b43legacy_calc_fallback_rate(rts_rate);
 		rts_rate_fb_ofdm = b43legacy_is_ofdm_rate(rts_rate_fb);
--- everything.orig/drivers/net/wireless/iwlwifi/iwl-3945-rs.c	2008-04-30 00:05:11.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl-3945-rs.c	2008-04-30 00:08:12.000000000 +0200
@@ -465,7 +465,7 @@ static void rs_tx_status(void *priv_rate
 
 
 	retries = tx_resp->retry_count;
-	first_index = tx_resp->control.tx_rate->hw_value;
+	first_index = sband->bitrates[tx_resp->control.tx_rate_idx].hw_value;
 	if ((first_index < 0) || (first_index >= IWL_RATE_COUNT)) {
 		IWL_DEBUG_RATE("leave: Rate out of bounds: %d\n", first_index);
 		return;
@@ -670,7 +670,7 @@ static void rs_get_rate(void *priv_rate,
 	    is_multicast_ether_addr(hdr->addr1) ||
 	    !sta || !sta->rate_ctrl_priv) {
 		IWL_DEBUG_RATE("leave: No STA priv data to update!\n");
-		sel->rate = rate_lowest(local, sband, sta);
+		sel->rate_idx = rate_lowest_index(local, sband, sta);
 		rcu_read_unlock();
 		return;
 	}
@@ -814,7 +814,7 @@ static void rs_get_rate(void *priv_rate,
 
 	IWL_DEBUG_RATE("leave: %d\n", index);
 
-	sel->rate = &sband->bitrates[sta->txrate_idx];
+	sel->rate_idx = sta->txrate_idx;
 }
 
 static struct rate_control_ops rs_ops = {
--- everything.orig/drivers/net/wireless/iwlwifi/iwl-3945.c	2008-04-30 00:02:07.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl-3945.c	2008-04-30 00:13:39.000000000 +0200
@@ -331,7 +331,9 @@ static void iwl3945_rx_reply_tx(struct i
 			tx_resp->rate, tx_resp->failure_frame);
 
 	rate_idx = iwl3945_hwrate_to_plcp_idx(tx_resp->rate);
-	tx_status->control.tx_rate = &priv->ieee_rates[rate_idx];
+	if (tx_status->control.band == IEEE80211_BAND_5GHZ)
+		rate_idx -= IWL_FIRST_OFDM_RATE;
+	tx_status->control.tx_rate_idx = rate_idx;
 	IWL_DEBUG_TX_REPLY("Tx queue reclaim %d\n", index);
 	iwl3945_tx_queue_reclaim(priv, txq_id, index);
 
@@ -966,7 +968,8 @@ void iwl3945_hw_build_tx_cmd_rate(struct
 			      struct ieee80211_hdr *hdr, int sta_id, int tx_id)
 {
 	unsigned long flags;
-	u16 rate_index = min(ctrl->tx_rate->hw_value & 0xffff, IWL_RATE_COUNT - 1);
+	u16 hw_value = ieee80211_get_tx_rate(priv->hw, ctrl)->hw_value;
+	u16 rate_index = min(hw_value & 0xffff, IWL_RATE_COUNT - 1);
 	u16 rate_mask;
 	int rate;
 	u8 rts_retry_limit;
--- everything.orig/drivers/net/wireless/iwlwifi/iwl-4965-rs.c	2008-04-30 00:13:48.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl-4965-rs.c	2008-04-30 00:17:28.000000000 +0200
@@ -851,7 +851,7 @@ static void rs_tx_status(void *priv_rate
 	if (priv->band == IEEE80211_BAND_5GHZ)
 		rs_index -= IWL_FIRST_OFDM_RATE;
 
-	if ((tx_resp->control.tx_rate == NULL) ||
+	if ((tx_resp->control.tx_rate_idx < 0) ||
 	    (tbl_type.is_SGI ^
 		!!(tx_resp->control.flags & IEEE80211_TXCTL_SHORT_GI)) ||
 	    (tbl_type.is_fat ^
@@ -865,7 +865,7 @@ static void rs_tx_status(void *priv_rate
 	    (!!(tx_mcs.rate_n_flags & RATE_MCS_GF_MSK) ^
 		!!(tx_resp->control.flags & IEEE80211_TXCTL_GREEN_FIELD)) ||
 	    (hw->wiphy->bands[priv->band]->bitrates[rs_index].bitrate !=
-		tx_resp->control.tx_rate->bitrate)) {
+	     hw->wiphy->bands[tx_resp->control.band]->bitrates[tx_resp->control.tx_rate_idx].bitrate)) {
 		IWL_DEBUG_RATE("initial rate does not match 0x%x\n",
 				tx_mcs.rate_n_flags);
 		goto out;
@@ -2181,7 +2181,7 @@ static void rs_get_rate(void *priv_rate,
 	fc = le16_to_cpu(hdr->frame_control);
 	if (!ieee80211_is_data(fc) || is_multicast_ether_addr(hdr->addr1) ||
 	    !sta || !sta->rate_ctrl_priv) {
-		sel->rate = rate_lowest(local, sband, sta);
+		sel->rate_idx = rate_lowest_index(local, sband, sta);
 		goto out;
 	}
 
@@ -2211,11 +2211,13 @@ static void rs_get_rate(void *priv_rate,
 
 done:
 	if ((i < 0) || (i > IWL_RATE_COUNT)) {
-		sel->rate = rate_lowest(local, sband, sta);
+		sel->rate_idx = rate_lowest_index(local, sband, sta);
 		goto out;
 	}
 
-	sel->rate = &priv->ieee_rates[i];
+	if (sband->band == IEEE80211_BAND_5GHZ)
+		i -= IWL_FIRST_OFDM_RATE;
+	sel->rate_idx = i;
 out:
 	rcu_read_unlock();
 }
--- everything.orig/drivers/net/wireless/iwlwifi/iwl-4965.c	2008-04-30 00:09:05.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl-4965.c	2008-04-30 00:12:01.000000000 +0200
@@ -421,14 +421,10 @@ void iwl4965_hwrate_to_tx_control(struct
 		control->flags |= IEEE80211_TXCTL_DUP_DATA;
 	if (rate_n_flags & RATE_MCS_SGI_MSK)
 		control->flags |= IEEE80211_TXCTL_SHORT_GI;
-	/* since iwl4965_hwrate_to_plcp_idx is band indifferent, we always use
-	 * IEEE80211_BAND_2GHZ band as it contains all the rates */
 	rate_index = iwl4965_hwrate_to_plcp_idx(rate_n_flags);
-	if (rate_index == -1)
-		control->tx_rate = NULL;
-	else
-		control->tx_rate =
-			&priv->bands[IEEE80211_BAND_2GHZ].bitrates[rate_index];
+	if (control->band == IEEE80211_BAND_5GHZ)
+		rate_index -= IWL_FIRST_OFDM_RATE;
+	control->tx_rate_idx = rate_index;
 }
 
 /*
@@ -2980,7 +2976,8 @@ void iwl4965_hw_build_tx_cmd_rate(struct
 	u16 fc = le16_to_cpu(hdr->frame_control);
 	u8 rate_plcp;
 	u16 rate_flags = 0;
-	int rate_idx = min(ctrl->tx_rate->hw_value & 0xffff, IWL_RATE_COUNT - 1);
+	u16 hw_value = ieee80211_get_tx_rate(priv->hw, ctrl)->hw_value;
+	int rate_idx = min(hw_value & 0xffff, IWL_RATE_COUNT - 1);
 
 	rate_plcp = iwl4965_rates[rate_idx].plcp;
 
--- everything.orig/drivers/net/wireless/iwlwifi/iwl3945-base.c	2008-04-30 00:00:59.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl3945-base.c	2008-04-30 00:01:52.000000000 +0200
@@ -2589,7 +2589,7 @@ static int iwl3945_tx_skb(struct iwl3945
 		goto drop_unlock;
 	}
 
-	if ((ctl->tx_rate->hw_value & 0xFF) == IWL_INVALID_RATE) {
+	if ((ieee80211_get_tx_rate(priv->hw, ctl)->hw_value & 0xFF) == IWL_INVALID_RATE) {
 		IWL_ERROR("ERROR: No TX rate available.\n");
 		goto drop_unlock;
 	}
@@ -6700,7 +6700,7 @@ static int iwl3945_mac_tx(struct ieee802
 	}
 
 	IWL_DEBUG_TX("dev->xmit(%d bytes) at rate 0x%02x\n", skb->len,
-		     ctl->tx_rate->bitrate);
+		     ieee80211_get_tx_rate(hw, ctl)->bitrate);
 
 	if (iwl3945_tx_skb(priv, skb, ctl))
 		dev_kfree_skb_any(skb);
--- everything.orig/drivers/net/wireless/iwlwifi/iwl4965-base.c	2008-04-30 00:08:23.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl4965-base.c	2008-04-30 00:08:51.000000000 +0200
@@ -2154,7 +2154,7 @@ static int iwl4965_tx_skb(struct iwl_pri
 		goto drop_unlock;
 	}
 
-	if ((ctl->tx_rate->hw_value & 0xFF) == IWL_INVALID_RATE) {
+	if ((ieee80211_get_tx_rate(priv->hw, ctl)->hw_value & 0xFF) == IWL_INVALID_RATE) {
 		IWL_ERROR("ERROR: No TX rate available.\n");
 		goto drop_unlock;
 	}
@@ -6243,7 +6243,7 @@ static int iwl4965_mac_tx(struct ieee802
 	}
 
 	IWL_DEBUG_TX("dev->xmit(%d bytes) at rate 0x%02x\n", skb->len,
-		     ctl->tx_rate->bitrate);
+		     ieee80211_get_tx_rate(hw, ctl)->bitrate);
 
 	if (iwl4965_tx_skb(priv, skb, ctl))
 		dev_kfree_skb_any(skb);
--- everything.orig/drivers/net/wireless/p54/p54common.c	2008-04-30 00:17:46.000000000 +0200
+++ everything/drivers/net/wireless/p54/p54common.c	2008-04-30 00:18:05.000000000 +0200
@@ -595,7 +595,7 @@ static int p54_tx(struct ieee80211_hw *d
 	txhdr->padding2 = 0;
 
 	/* TODO: add support for alternate retry TX rates */
-	rate = control->tx_rate->hw_value;
+	rate = ieee80211_get_tx_rate(dev, control)->hw_value;
 	if (control->flags & IEEE80211_TXCTL_SHORT_PREAMBLE)
 		rate |= 0x10;
 	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
--- everything.orig/drivers/net/wireless/rt2x00/rt2x00dev.c	2008-04-30 00:18:16.000000000 +0200
+++ everything/drivers/net/wireless/rt2x00/rt2x00dev.c	2008-04-30 00:19:14.000000000 +0200
@@ -648,7 +648,7 @@ void rt2x00lib_write_tx_desc(struct rt2x
 	frame_control = le16_to_cpu(hdr->frame_control);
 	seq_ctrl = le16_to_cpu(hdr->seq_ctrl);
 
-	tx_rate = control->tx_rate->hw_value;
+	tx_rate = ieee80211_get_tx_rate(rt2x00dev->hw, control)->hw_value;
 
 	/*
 	 * Check whether this frame is to be acked
@@ -666,8 +666,8 @@ void rt2x00lib_write_tx_desc(struct rt2x
 			__set_bit(ENTRY_TXD_ACK, &txdesc.flags);
 		} else
 			__clear_bit(ENTRY_TXD_ACK, &txdesc.flags);
-		if (control->rts_cts_rate)
-			tx_rate = control->rts_cts_rate->hw_value;
+		if (control->rts_cts_rate_idx >= 0)
+			tx_rate = ieee80211_get_rts_cts_rate(rt2x00dev->hw, control)->hw_value;
 	}
 
 	rate = rt2x00_get_rate(tx_rate);
--- everything.orig/drivers/net/wireless/rtl8180_dev.c	2008-04-29 23:45:07.000000000 +0200
+++ everything/drivers/net/wireless/rtl8180_dev.c	2008-04-29 23:48:00.000000000 +0200
@@ -257,24 +257,21 @@ static int rtl8180_tx(struct ieee80211_h
 	mapping = pci_map_single(priv->pdev, skb->data,
 				 skb->len, PCI_DMA_TODEVICE);
 
-	BUG_ON(!control->tx_rate);
-
 	tx_flags = RTL8180_TX_DESC_FLAG_OWN | RTL8180_TX_DESC_FLAG_FS |
 		   RTL8180_TX_DESC_FLAG_LS |
-		   (control->tx_rate->hw_value << 24) | skb->len;
+		   (ieee80211_get_tx_rate(dev, control)->hw_value << 24) |
+		   skb->len;
 
 	if (priv->r8185)
 		tx_flags |= RTL8180_TX_DESC_FLAG_DMA |
 			    RTL8180_TX_DESC_FLAG_NO_ENC;
 
 	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
-		BUG_ON(!control->rts_cts_rate);
 		tx_flags |= RTL8180_TX_DESC_FLAG_RTS;
-		tx_flags |= control->rts_cts_rate->hw_value << 19;
+		tx_flags |= ieee80211_get_rts_cts_rate(dev, control)->hw_value << 19;
 	} else if (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT) {
-		BUG_ON(!control->rts_cts_rate);
 		tx_flags |= RTL8180_TX_DESC_FLAG_CTS;
-		tx_flags |= control->rts_cts_rate->hw_value << 19;
+		tx_flags |= ieee80211_get_rts_cts_rate(dev, control)->hw_value << 19;
 	}
 
 	*((struct ieee80211_tx_control **) skb->cb) =
@@ -288,9 +285,9 @@ static int rtl8180_tx(struct ieee80211_h
 		unsigned int remainder;
 
 		plcp_len = DIV_ROUND_UP(16 * (skb->len + 4),
-					(control->tx_rate->bitrate * 2) / 10);
+				(ieee80211_get_tx_rate(dev, control)->bitrate * 2) / 10);
 		remainder = (16 * (skb->len + 4)) %
-			    ((control->tx_rate->bitrate * 2) / 10);
+			    ((ieee80211_get_tx_rate(dev, control)->bitrate * 2) / 10);
 		if (remainder > 0 && remainder <= 6)
 			plcp_len |= 1 << 15;
 	}
@@ -303,8 +300,8 @@ static int rtl8180_tx(struct ieee80211_h
 	entry->plcp_len = cpu_to_le16(plcp_len);
 	entry->tx_buf = cpu_to_le32(mapping);
 	entry->frame_len = cpu_to_le32(skb->len);
-	entry->flags2 = control->alt_retry_rate != NULL ?
-			control->alt_retry_rate->bitrate << 4 : 0;
+	entry->flags2 = control->alt_retry_rate_idx >= 0 ?
+		ieee80211_get_alt_retry_rate(dev, control)->bitrate << 4 : 0;
 	entry->retry_limit = control->retry_limit;
 	entry->flags = cpu_to_le32(tx_flags);
 	__skb_queue_tail(&ring->queue, skb);
--- everything.orig/drivers/net/wireless/rtl8187_dev.c	2008-04-29 23:48:15.000000000 +0200
+++ everything/drivers/net/wireless/rtl8187_dev.c	2008-04-29 23:49:04.000000000 +0200
@@ -179,21 +179,17 @@ static int rtl8187_tx(struct ieee80211_h
 	flags = skb->len;
 	flags |= RTL8187_TX_FLAG_NO_ENCRYPT;
 
-	BUG_ON(!control->tx_rate);
-
-	flags |= control->tx_rate->hw_value << 24;
+	flags |= ieee80211_get_tx_rate(dev, control)->hw_value << 24;
 	if (ieee80211_get_morefrag((struct ieee80211_hdr *)skb->data))
 		flags |= RTL8187_TX_FLAG_MORE_FRAG;
 	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
-		BUG_ON(!control->rts_cts_rate);
 		flags |= RTL8187_TX_FLAG_RTS;
-		flags |= control->rts_cts_rate->hw_value << 19;
+		flags |= ieee80211_get_rts_cts_rate(dev, control)->hw_value << 19;
 		rts_dur = ieee80211_rts_duration(dev, priv->vif,
 						 skb->len, control);
 	} else if (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT) {
-		BUG_ON(!control->rts_cts_rate);
 		flags |= RTL8187_TX_FLAG_CTS;
-		flags |= control->rts_cts_rate->hw_value << 19;
+		flags |= ieee80211_get_rts_cts_rate(dev, control)->hw_value << 19;
 	}
 
 	hdr = (struct rtl8187_tx_hdr *)skb_push(skb, sizeof(*hdr));
--- everything.orig/drivers/net/wireless/zd1211rw/zd_mac.c	2008-04-30 00:19:42.000000000 +0200
+++ everything/drivers/net/wireless/zd1211rw/zd_mac.c	2008-04-30 00:21:03.000000000 +0200
@@ -523,14 +523,17 @@ static int fill_ctrlset(struct zd_mac *m
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	unsigned int frag_len = skb->len + FCS_LEN;
 	unsigned int packet_length;
+	struct ieee80211_rate *txrate;
 	struct zd_ctrlset *cs = (struct zd_ctrlset *)
 		skb_push(skb, sizeof(struct zd_ctrlset));
 
 	ZD_ASSERT(frag_len <= 0xffff);
 
-	cs->modulation = control->tx_rate->hw_value;
+	txrate = ieee80211_get_tx_rate(mac->hw, control);
+
+	cs->modulation = txrate->hw_value;
 	if (control->flags & IEEE80211_TXCTL_SHORT_PREAMBLE)
-		cs->modulation = control->tx_rate->hw_value_short;
+		cs->modulation = txrate->hw_value_short;
 
 	cs->tx_length = cpu_to_le16(frag_len);
 

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
