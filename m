From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-07-29
Date: Wed, 29 Jul 2009 16:30:07 -0400
Message-ID: <20090729203007.GB10056@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37776 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045AbZG2UqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 16:46:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a small collection of fixes intended for 2.6.31.  Several of
them are small fixes dug-out by the usual static analysis suspects.
There are also a couple of iwlwifi fixes that the Intel team thinks are
important -- they look reasonably safe to me and they should only effec=
t
their drivers.  Their are also some small fixes from Luis and Johannes.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 8bae1b2b13beb4cf4c0f119f97640503c2b7=
4b0f:
  Don Skidmore (1):
        ixgbe: fix for 82599 errata marking UDP checksum errors

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Dan Carpenter (1):
      wireless: ERR_PTR vs null

Johannes Berg (2):
      iwlwifi: fix TX queue race
      mac80211: fix suspend

Luis R. Rodriguez (1):
      mac80211: do not queue work after suspend in the dynamic ps timer

Roel Kluin (5):
      airo: Buffer overflow
      ath9k: Read outside array bounds
      iwlwifi: Read outside array bounds
      libertas: Read outside array bounds
      libertas: Read buffer overflow

reinette chatre (1):
      iwlagn: fix minimum number of queues setting

 drivers/net/wireless/airo.c                 |   13 ++++++-------
 drivers/net/wireless/ath/ath9k/eeprom.c     |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    6 ++++--
 drivers/net/wireless/iwlwifi/iwl-tx.c       |   14 ++++++++------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 ++--
 drivers/net/wireless/iwmc3200wifi/netdev.c  |    6 ++----
 drivers/net/wireless/libertas/assoc.c       |   18 ++++++++----------
 drivers/net/wireless/libertas/scan.c        |    3 ++-
 net/mac80211/mlme.c                         |    2 +-
 net/mac80211/pm.c                           |   24 +++++++++++++++----=
-----
 net/mac80211/rx.c                           |   12 ++++++++++++
 12 files changed, 63 insertions(+), 45 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index c70604f..8ce5e4c 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5918,20 +5918,19 @@ static int airo_set_essid(struct net_device *de=
v,
 	readSsidRid(local, &SSID_rid);
=20
 	/* Check if we asked for `any' */
-	if(dwrq->flags =3D=3D 0) {
+	if (dwrq->flags =3D=3D 0) {
 		/* Just send an empty SSID list */
 		memset(&SSID_rid, 0, sizeof(SSID_rid));
 	} else {
-		int	index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
+		unsigned index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
=20
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE) {
+		if (dwrq->length > IW_ESSID_MAX_SIZE)
 			return -E2BIG ;
-		}
+
 		/* Check if index is valid */
-		if((index < 0) || (index >=3D 4)) {
+		if (index >=3D ARRAY_SIZE(SSID_rid.ssids))
 			return -EINVAL;
-		}
=20
 		/* Set the SSID */
 		memset(SSID_rid.ssids[index].ssid, 0,
@@ -6819,7 +6818,7 @@ static int airo_set_txpow(struct net_device *dev,
 		return -EINVAL;
 	}
 	clear_bit (FLAG_RADIO_OFF, &local->flags);
-	for (i =3D 0; cap_rid.txPowerLevels[i] && (i < 8); i++)
+	for (i =3D 0; i < 8 && cap_rid.txPowerLevels[i]; i++)
 		if (v =3D=3D cap_rid.txPowerLevels[i]) {
 			readConfigRid(local, 1);
 			local->config.txPower =3D v;
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wire=
less/ath/ath9k/eeprom.c
index a2fda70..ce0e86c 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -460,7 +460,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *=
ah)
 		integer =3D swab32(eep->modalHeader.antCtrlCommon);
 		eep->modalHeader.antCtrlCommon =3D integer;
=20
-		for (i =3D 0; i < AR5416_MAX_CHAINS; i++) {
+		for (i =3D 0; i < AR5416_EEP4K_MAX_CHAINS; i++) {
 			integer =3D swab32(eep->modalHeader.antCtrlChain[i]);
 			eep->modalHeader.antCtrlChain[i] =3D integer;
 		}
@@ -914,7 +914,7 @@ static void ath9k_hw_set_4k_power_per_rate_table(st=
ruct ath_hw *ah,
 			ctlMode, numCtlModes, isHt40CtlMode,
 			(pCtlMode[ctlMode] & EXT_ADDITIVE));
=20
-		for (i =3D 0; (i < AR5416_NUM_CTLS) &&
+		for (i =3D 0; (i < AR5416_EEP4K_NUM_CTLS) &&
 				pEepData->ctlIndex[i]; i++) {
 			DPRINTF(ah->ah_sc, ATH_DBG_EEPROM,
 				"  LOOP-Ctlidx %d: cfgCtl 0x%2.2x "
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wire=
less/iwlwifi/iwl-3945.h
index fbb3a57..2de6471 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -112,7 +112,7 @@ enum iwl3945_antenna {
 #define IWL_TX_FIFO_NONE	7
=20
 /* Minimum number of queues. MAX_NUM is defined in hw specific files *=
/
-#define IWL_MIN_NUM_QUEUES	4
+#define IWL39_MIN_NUM_QUEUES	4
=20
 #define IEEE80211_DATA_LEN              2304
 #define IEEE80211_4ADDR_LEN             30
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wirel=
ess/iwlwifi/iwl-dev.h
index e2d620f..650e20a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -258,8 +258,10 @@ struct iwl_channel_info {
 #define IWL_TX_FIFO_HCCA_2	6
 #define IWL_TX_FIFO_NONE	7
=20
-/* Minimum number of queues. MAX_NUM is defined in hw specific files *=
/
-#define IWL_MIN_NUM_QUEUES	4
+/* Minimum number of queues. MAX_NUM is defined in hw specific files.
+ * Set the minimum to accommodate the 4 standard TX queues, 1 command
+ * queue, 2 (unused) HCCA queues, and 4 HT queues (one for each AC) */
+#define IWL_MIN_NUM_QUEUES	10
=20
 /* Power management (not Tx power) structures */
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wirele=
ss/iwlwifi/iwl-tx.c
index 9bbeec9..2e89040 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -720,8 +720,6 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buf=
f *skb)
 		goto drop_unlock;
 	}
=20
-	spin_unlock_irqrestore(&priv->lock, flags);
-
 	hdr_len =3D ieee80211_hdrlen(fc);
=20
 	/* Find (or create) index into station table for destination station =
*/
@@ -729,7 +727,7 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buf=
f *skb)
 	if (sta_id =3D=3D IWL_INVALID_STATION) {
 		IWL_DEBUG_DROP(priv, "Dropping - INVALID STATION: %pM\n",
 			       hdr->addr1);
-		goto drop;
+		goto drop_unlock;
 	}
=20
 	IWL_DEBUG_TX(priv, "station Id %d\n", sta_id);
@@ -750,14 +748,17 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_b=
uff *skb)
 			txq_id =3D priv->stations[sta_id].tid[tid].agg.txq_id;
 			swq_id =3D iwl_virtual_agg_queue_num(swq_id, txq_id);
 		}
-		priv->stations[sta_id].tid[tid].tfds_in_queue++;
 	}
=20
 	txq =3D &priv->txq[txq_id];
 	q =3D &txq->q;
 	txq->swq_id =3D swq_id;
=20
-	spin_lock_irqsave(&priv->lock, flags);
+	if (unlikely(iwl_queue_space(q) < q->high_mark))
+		goto drop_unlock;
+
+	if (ieee80211_is_data_qos(fc))
+		priv->stations[sta_id].tid[tid].tfds_in_queue++;
=20
 	/* Set up driver data for this TFD */
 	memset(&(txq->txb[q->write_ptr]), 0, sizeof(struct iwl_tx_info));
@@ -902,7 +903,6 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buf=
f *skb)
=20
 drop_unlock:
 	spin_unlock_irqrestore(&priv->lock, flags);
-drop:
 	return -1;
 }
 EXPORT_SYMBOL(iwl_tx_skb);
@@ -1171,6 +1171,8 @@ int iwl_tx_agg_start(struct iwl_priv *priv, const=
 u8 *ra, u16 tid, u16 *ssn)
 		IWL_ERR(priv, "Start AGG on invalid station\n");
 		return -ENXIO;
 	}
+	if (unlikely(tid >=3D MAX_TID_COUNT))
+		return -EINVAL;
=20
 	if (priv->stations[sta_id].tid[tid].agg.state !=3D IWL_AGG_OFF) {
 		IWL_ERR(priv, "Start AGG when state is not IWL_AGG_OFF !\n");
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/=
wireless/iwlwifi/iwl3945-base.c
index 956798f..2f50ab6 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4018,10 +4018,10 @@ static int iwl3945_pci_probe(struct pci_dev *pd=
ev, const struct pci_device_id *e
 	SET_IEEE80211_DEV(hw, &pdev->dev);
=20
 	if ((iwl3945_mod_params.num_of_queues > IWL39_MAX_NUM_QUEUES) ||
-	     (iwl3945_mod_params.num_of_queues < IWL_MIN_NUM_QUEUES)) {
+	     (iwl3945_mod_params.num_of_queues < IWL39_MIN_NUM_QUEUES)) {
 		IWL_ERR(priv,
 			"invalid queues_num, should be between %d and %d\n",
-			IWL_MIN_NUM_QUEUES, IWL39_MAX_NUM_QUEUES);
+			IWL39_MIN_NUM_QUEUES, IWL39_MAX_NUM_QUEUES);
 		err =3D -EINVAL;
 		goto out_ieee80211_free_hw;
 	}
diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/w=
ireless/iwmc3200wifi/netdev.c
index aea5ccf..bf294e4 100644
--- a/drivers/net/wireless/iwmc3200wifi/netdev.c
+++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
@@ -106,10 +106,8 @@ void *iwm_if_alloc(int sizeof_bus, struct device *=
dev,
 	int ret =3D 0;
=20
 	wdev =3D iwm_wdev_alloc(sizeof_bus, dev);
-	if (!wdev) {
-		dev_err(dev, "no memory for wireless device instance\n");
-		return ERR_PTR(-ENOMEM);
-	}
+	if (IS_ERR(wdev))
+		return wdev;
=20
 	iwm =3D wdev_to_iwm(wdev);
 	iwm->bus_ops =3D if_ops;
diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wirele=
ss/libertas/assoc.c
index b9b3741..d699737 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -1,6 +1,7 @@
 /* Copyright (C) 2006, Red Hat, Inc. */
=20
 #include <linux/types.h>
+#include <linux/kernel.h>
 #include <linux/etherdevice.h>
 #include <linux/ieee80211.h>
 #include <linux/if_arp.h>
@@ -43,21 +44,21 @@ static int get_common_rates(struct lbs_private *pri=
v,
 	u16 *rates_size)
 {
 	u8 *card_rates =3D lbs_bg_rates;
-	size_t num_card_rates =3D sizeof(lbs_bg_rates);
 	int ret =3D 0, i, j;
-	u8 tmp[30];
+	u8 tmp[(ARRAY_SIZE(lbs_bg_rates) - 1) * (*rates_size - 1)];
 	size_t tmp_size =3D 0;
=20
 	/* For each rate in card_rates that exists in rate1, copy to tmp */
-	for (i =3D 0; card_rates[i] && (i < num_card_rates); i++) {
-		for (j =3D 0; rates[j] && (j < *rates_size); j++) {
+	for (i =3D 0; i < ARRAY_SIZE(lbs_bg_rates) && card_rates[i]; i++) {
+		for (j =3D 0; j < *rates_size && rates[j]; j++) {
 			if (rates[j] =3D=3D card_rates[i])
 				tmp[tmp_size++] =3D card_rates[i];
 		}
 	}
=20
 	lbs_deb_hex(LBS_DEB_JOIN, "AP rates    ", rates, *rates_size);
-	lbs_deb_hex(LBS_DEB_JOIN, "card rates  ", card_rates, num_card_rates)=
;
+	lbs_deb_hex(LBS_DEB_JOIN, "card rates  ", card_rates,
+			ARRAY_SIZE(lbs_bg_rates));
 	lbs_deb_hex(LBS_DEB_JOIN, "common rates", tmp, tmp_size);
 	lbs_deb_join("TX data rate 0x%02x\n", priv->cur_rate);
=20
@@ -69,10 +70,7 @@ static int get_common_rates(struct lbs_private *priv=
,
 		lbs_pr_alert("Previously set fixed data rate %#x isn't "
 		       "compatible with the network.\n", priv->cur_rate);
 		ret =3D -1;
-		goto done;
 	}
-	ret =3D 0;
-
 done:
 	memset(rates, 0, *rates_size);
 	*rates_size =3D min_t(int, tmp_size, *rates_size);
@@ -322,7 +320,7 @@ static int lbs_associate(struct lbs_private *priv,
 	rates =3D (struct mrvl_ie_rates_param_set *) pos;
 	rates->header.type =3D cpu_to_le16(TLV_TYPE_RATES);
 	memcpy(&rates->rates, &bss->rates, MAX_RATES);
-	tmplen =3D MAX_RATES;
+	tmplen =3D min_t(u16, ARRAY_SIZE(rates->rates), MAX_RATES);
 	if (get_common_rates(priv, rates->rates, &tmplen)) {
 		ret =3D -1;
 		goto done;
@@ -598,7 +596,7 @@ static int lbs_adhoc_join(struct lbs_private *priv,
=20
 	/* Copy Data rates from the rates recorded in scan response */
 	memset(cmd.bss.rates, 0, sizeof(cmd.bss.rates));
-	ratesize =3D min_t(u16, sizeof(cmd.bss.rates), MAX_RATES);
+	ratesize =3D min_t(u16, ARRAY_SIZE(cmd.bss.rates), MAX_RATES);
 	memcpy(cmd.bss.rates, bss->rates, ratesize);
 	if (get_common_rates(priv, cmd.bss.rates, &ratesize)) {
 		lbs_deb_join("ADHOC_JOIN: get_common_rates returned error.\n");
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireles=
s/libertas/scan.c
index 601b542..6c95af3 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -5,6 +5,7 @@
   *  for sending scan commands to the firmware.
   */
 #include <linux/types.h>
+#include <linux/kernel.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <asm/unaligned.h>
@@ -876,7 +877,7 @@ static inline char *lbs_translate_scan(struct lbs_p=
rivate *priv,
 	iwe.u.bitrate.disabled =3D 0;
 	iwe.u.bitrate.value =3D 0;
=20
-	for (j =3D 0; bss->rates[j] && (j < sizeof(bss->rates)); j++) {
+	for (j =3D 0; j < ARRAY_SIZE(bss->rates) && bss->rates[j]; j++) {
 		/* Bit rate given in 500 kb/s units */
 		iwe.u.bitrate.value =3D bss->rates[j] * 500000;
 		current_val =3D iwe_stream_add_value(info, start, current_val,
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index aca22b0..07e7e41 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -721,7 +721,7 @@ void ieee80211_dynamic_ps_timer(unsigned long data)
 {
 	struct ieee80211_local *local =3D (void *) data;
=20
-	if (local->quiescing)
+	if (local->quiescing || local->suspended)
 		return;
=20
 	queue_work(local->hw.workqueue, &local->dynamic_ps_enable_work);
diff --git a/net/mac80211/pm.c b/net/mac80211/pm.c
index 7a549f9..5e3d476 100644
--- a/net/mac80211/pm.c
+++ b/net/mac80211/pm.c
@@ -55,15 +55,6 @@ int __ieee80211_suspend(struct ieee80211_hw *hw)
=20
 	rcu_read_unlock();
=20
-	/* flush again, in case driver queued work */
-	flush_workqueue(local->hw.workqueue);
-
-	/* stop hardware - this must stop RX */
-	if (local->open_count) {
-		ieee80211_led_radio(local, false);
-		drv_stop(local);
-	}
-
 	/* remove STAs */
 	spin_lock_irqsave(&local->sta_lock, flags);
 	list_for_each_entry(sta, &local->sta_list, list) {
@@ -111,7 +102,22 @@ int __ieee80211_suspend(struct ieee80211_hw *hw)
 		drv_remove_interface(local, &conf);
 	}
=20
+	/* stop hardware - this must stop RX */
+	if (local->open_count) {
+		ieee80211_led_radio(local, false);
+		drv_stop(local);
+	}
+
+	/*
+	 * flush again, in case driver queued work -- it
+	 * shouldn't be doing (or cancel everything in the
+	 * stop callback) that but better safe than sorry.
+	 */
+	flush_workqueue(local->hw.workqueue);
+
 	local->suspended =3D true;
+	/* need suspended to be visible before quiescing is false */
+	barrier();
 	local->quiescing =3D false;
=20
 	return 0;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index de5bba7..0936fc2 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2453,6 +2453,18 @@ void __ieee80211_rx(struct ieee80211_hw *hw, str=
uct sk_buff *skb,
 		return;
 	}
=20
+	/*
+	 * If we're suspending, it is possible although not too likely
+	 * that we'd be receiving frames after having already partially
+	 * quiesced the stack. We can't process such frames then since
+	 * that might, for example, cause stations to be added or other
+	 * driver callbacks be invoked.
+	 */
+	if (unlikely(local->quiescing || local->suspended)) {
+		kfree_skb(skb);
+		return;
+	}
+
 	if (status->flag & RX_FLAG_HT) {
 		/* rate_idx is MCS index */
 		if (WARN_ON(status->rate_idx < 0 ||
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
