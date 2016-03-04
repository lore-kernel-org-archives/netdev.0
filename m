From: Tim Shepard <shep@alum.mit.edu>
Subject: Re: [PATCH RFC/RFT 1/2] ath9k: rename struct ath_txq to struct ath_hwq
Date: Fri, 04 Mar 2016 02:11:40 -0500
Message-ID: <E1abjtk-0002ud-00@www.xplot.org>
Cc: linux-wireless@vger.kernel.org, michal.kazior@tieto.com,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, dave.taht@gmail.com,
	emmanuel.grumbach@intel.com, nbd@openwrt.org,
	andrewmcgr@google.com, apenwarr@google.com
To: Tim Shepard <shep@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.xplot.org ([66.92.66.146]:35250 "EHLO www.xplot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbcCDHLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 02:11:31 -0500
In-reply-to: Your message of Thu, 03 Mar 2016 20:17:43 -0500.
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




I've already received an automated report that this patch fails to
build.  Oops.

Apparently only when either CONFIG_ATH9K_TX99=y or
CONFIG_ATH9K_CHANNEL_CONTEXT=y .

I missed a few things in the ath_txq to ath_hwq rename and failed to
catch it because I didn't have those turned on in my .config .

So if you want to test this before I resubmit, make sure those two
configs are turned off in your .config, or maybe try patching with the
diff below.

I plan to resend the patch soon (probably tomorrow) with this fix
squashed in, after I do some test compiling to make sure I've actually
fixed it.

			-Tim Shepard
			 shep@alum.mit.edu
 ___ _ ___ _   _ _ ___   ___     _ _ _ _   _   _ ___ _   _   _ ___ _ ___ _ ___


diff --git a/drivers/net/wireless/ath/ath9k/channel.c b/drivers/net/wireless/ath/ath9k/channel.c
index 50e614b..0297588 100644
--- a/drivers/net/wireless/ath/ath9k/channel.c
+++ b/drivers/net/wireless/ath/ath9k/channel.c
@@ -1006,7 +1006,7 @@ static void ath_scan_send_probe(struct ath_softc *sc,
 	if (!ieee80211_tx_prepare_skb(sc->hw, vif, skb, band, NULL))
 		goto error;
 
-	txctl.txq = sc->tx.txq_map[IEEE80211_AC_VO];
+	txctl.hwq = sc->tx.hwq_map[IEEE80211_AC_VO];
 	txctl.force_channel = true;
 	if (ath_tx_start(sc->hw, skb, &txctl))
 		goto error;
@@ -1128,7 +1128,7 @@ ath_chanctx_send_vif_ps_frame(struct ath_softc *sc, struct ath_vif *avp,
 	}
 
 	memset(&txctl, 0, sizeof(txctl));
-	txctl.txq = sc->tx.txq_map[IEEE80211_AC_VO];
+	txctl.hwq = sc->tx.hwq_map[IEEE80211_AC_VO];
 	txctl.sta = sta;
 	txctl.force_channel = true;
 	if (ath_tx_start(sc->hw, skb, &txctl)) {
diff --git a/drivers/net/wireless/ath/ath9k/tx99.c b/drivers/net/wireless/ath/ath9k/tx99.c
index ac4781f..0a9ed5c 100644
--- a/drivers/net/wireless/ath/ath9k/tx99.c
+++ b/drivers/net/wireless/ath/ath9k/tx99.c
@@ -21,7 +21,7 @@ static void ath9k_tx99_stop(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_drain_all_txq(sc);
+	ath_drain_all_hwq(sc);
 	ath_startrecv(sc);
 
 	ath9k_hw_set_interrupts(ah);
@@ -125,7 +125,7 @@ static int ath9k_tx99_init(struct ath_softc *sc)
 		return -ENOMEM;
 
 	memset(&txctl, 0, sizeof(txctl));
-	txctl.txq = sc->tx.txq_map[IEEE80211_AC_VO];
+	txctl.hwq = sc->tx.hwq_map[IEEE80211_AC_VO];
 
 	ath_reset(sc, NULL);
 
@@ -133,7 +133,7 @@ static int ath9k_tx99_init(struct ath_softc *sc)
 
 	ath9k_hw_disable_interrupts(ah);
 	atomic_set(&ah->intr_ref_cnt, -1);
-	ath_drain_all_txq(sc);
+	ath_drain_all_hwq(sc);
 	ath_stoprecv(sc);
 
 	sc->tx99_state = true;
