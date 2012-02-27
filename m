From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-02-27
Date: Mon, 27 Feb 2012 15:15:07 -0500
Message-ID: <20120227201507.GE26664@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34157 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756148Ab2B0X0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 18:26:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit eea79e0713d94b02952f6c591b615710fd40a562

Dave,

This is a batch of fixes intended for 3.3.

The biggest fix comes from Felix, where he moves around some code
in ath9k in order to avoid a crash reported to him by a user on IRC.
Also included is an rt2x00 fix from Gabor Juhos for a possible NULL
pointer dereference, an iwlwifi fix from Johannes Berg for a bug that
led to incorrectly removing unicast keys (and dropping connections),
a mac80211 fix from Mohammed Shafi Shajakhan to properly initialize
a structure used by the rate control algorithms, another mac80211
fix from Mohammed to avoid a WARNING when changing from monitor mode
to managed mode, a brcmsmac fix from Arend van Spriel to avoid an
endless retry of A-MPDU retransmits, and another fix from Arend to
avoid some log spam coming from brcmsmac.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 203738e548cefc3fc3c2f73a9063176c9f3583d5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-02-26=
 12:47:17 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Arend van Spriel (2):
      brcm80211: smac: fix endless retry of A-MPDU transmissions
      brcm80211: smac: only print block-ack timeout message at trace level

Felix Fietkau (1):
      ath9k_hw: prevent writes to const data on AR9160

Gabor Juhos (1):
      rt2x00: fix a possible NULL pointer dereference

Johannes Berg (1):
      iwlwifi: fix key removal

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Mohammed Shafi Shajakhan (2):
      mac80211: zero initialize count field in ieee80211_tx_rate
      mac80211: Fix a warning on changing to monitor mode from STA

 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |   25 +------------------=
----
 drivers/net/wireless/ath/ath9k/ar9002_hw.c      |   19 +++++++++++++++++
 drivers/net/wireless/ath/ath9k/hw.h             |    1 -
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c |   12 +++-------
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c      |   10 ++++++++-
 drivers/net/wireless/rt2x00/rt2x00dev.c         |    3 +-
 net/mac80211/iface.c                            |    3 ++
 net/mac80211/rate.c                             |    2 +-
 8 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wire=
less/ath/ath9k/ar5008_phy.c
index f901a17..86a891f 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -489,8 +489,6 @@ static int ar5008_hw_rf_alloc_ext_banks(struct ath_hw *=
ah)
 	ATH_ALLOC_BANK(ah->analogBank6Data, ah->iniBank6.ia_rows);
 	ATH_ALLOC_BANK(ah->analogBank6TPCData, ah->iniBank6TPC.ia_rows);
 	ATH_ALLOC_BANK(ah->analogBank7Data, ah->iniBank7.ia_rows);
-	ATH_ALLOC_BANK(ah->addac5416_21,
-		       ah->iniAddac.ia_rows * ah->iniAddac.ia_columns);
 	ATH_ALLOC_BANK(ah->bank6Temp, ah->iniBank6.ia_rows);
=20
 	return 0;
@@ -519,7 +517,6 @@ static void ar5008_hw_rf_free_ext_banks(struct ath_hw *=
ah)
 	ATH_FREE_BANK(ah->analogBank6Data);
 	ATH_FREE_BANK(ah->analogBank6TPCData);
 	ATH_FREE_BANK(ah->analogBank7Data);
-	ATH_FREE_BANK(ah->addac5416_21);
 	ATH_FREE_BANK(ah->bank6Temp);
=20
 #undef ATH_FREE_BANK
@@ -805,27 +802,7 @@ static int ar5008_hw_process_ini(struct ath_hw *ah,
 	if (ah->eep_ops->set_addac)
 		ah->eep_ops->set_addac(ah, chan);
=20
-	if (AR_SREV_5416_22_OR_LATER(ah)) {
-		REG_WRITE_ARRAY(&ah->iniAddac, 1, regWrites);
-	} else {
-		struct ar5416IniArray temp;
-		u32 addacSize =3D
-			sizeof(u32) * ah->iniAddac.ia_rows *
-			ah->iniAddac.ia_columns;
-
-		/* For AR5416 2.0/2.1 */
-		memcpy(ah->addac5416_21,
-		       ah->iniAddac.ia_array, addacSize);
-
-		/* override CLKDRV value at [row, column] =3D [31, 1] */
-		(ah->addac5416_21)[31 * ah->iniAddac.ia_columns + 1] =3D 0;
-
-		temp.ia_array =3D ah->addac5416_21;
-		temp.ia_columns =3D ah->iniAddac.ia_columns;
-		temp.ia_rows =3D ah->iniAddac.ia_rows;
-		REG_WRITE_ARRAY(&temp, 1, regWrites);
-	}
-
+	REG_WRITE_ARRAY(&ah->iniAddac, 1, regWrites);
 	REG_WRITE(ah, AR_PHY_ADC_SERIAL_CTL, AR_PHY_SEL_INTERNAL_ADDAC);
=20
 	ENABLE_REGWRITE_BUFFER(ah);
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wirel=
ess/ath/ath9k/ar9002_hw.c
index 11f192a..d190411 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -180,6 +180,25 @@ static void ar9002_hw_init_mode_regs(struct ath_hw *ah)
 		INIT_INI_ARRAY(&ah->iniAddac, ar5416Addac,
 			       ARRAY_SIZE(ar5416Addac), 2);
 	}
+
+	/* iniAddac needs to be modified for these chips */
+	if (AR_SREV_9160(ah) || !AR_SREV_5416_22_OR_LATER(ah)) {
+		struct ar5416IniArray *addac =3D &ah->iniAddac;
+		u32 size =3D sizeof(u32) * addac->ia_rows * addac->ia_columns;
+		u32 *data;
+
+		data =3D kmalloc(size, GFP_KERNEL);
+		if (!data)
+			return;
+
+		memcpy(data, addac->ia_array, size);
+		addac->ia_array =3D data;
+
+		if (!AR_SREV_5416_22_OR_LATER(ah)) {
+			/* override CLKDRV value */
+			INI_RA(addac, 31,1) =3D 0;
+		}
+	}
 }
=20
 /* Support for Japan ch.14 (2484) spread */
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index 6a29004..c8261d4 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -940,7 +940,6 @@ struct ath_hw {
 	u32 *analogBank6Data;
 	u32 *analogBank6TPCData;
 	u32 *analogBank7Data;
-	u32 *addac5416_21;
 	u32 *bank6Temp;
=20
 	u8 txpower_limit;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c b/drivers/net/=
wireless/brcm80211/brcmsmac/ampdu.c
index 90911ee..30b5887 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
@@ -1051,17 +1051,13 @@ brcms_c_ampdu_dotxstatus_complete(struct ampdu_info=
 *ampdu, struct scb *scb,
 		}
 		/* either retransmit or send bar if ack not recd */
 		if (!ack_recd) {
-			struct ieee80211_tx_rate *txrate =3D
-			    tx_info->status.rates;
-			if (retry && (txrate[0].count < (int)retry_limit)) {
+			if (retry && (ini->txretry[index] < (int)retry_limit)) {
 				ini->txretry[index]++;
 				ini->tx_in_transit--;
 				/*
 				 * Use high prededence for retransmit to
 				 * give some punch
 				 */
-				/* brcms_c_txq_enq(wlc, scb, p,
-				 * BRCMS_PRIO_TO_PREC(tid)); */
 				brcms_c_txq_enq(wlc, scb, p,
 						BRCMS_PRIO_TO_HI_PREC(tid));
 			} else {
@@ -1074,9 +1070,9 @@ brcms_c_ampdu_dotxstatus_complete(struct ampdu_info *=
ampdu, struct scb *scb,
 				    IEEE80211_TX_STAT_AMPDU_NO_BACK;
 				skb_pull(p, D11_PHY_HDR_LEN);
 				skb_pull(p, D11_TXH_LEN);
-				wiphy_err(wiphy, "%s: BA Timeout, seq %d, in_"
-					"transit %d\n", "AMPDU status", seq,
-					ini->tx_in_transit);
+				BCMMSG(wiphy,
+				       "BA Timeout, seq %d, in_transit %d\n",
+				       seq, ini->tx_in_transit);
 				ieee80211_tx_status_irqsafe(wlc->pub->ieee_hw,
 							    p);
 			}
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c b/drivers/net/wirel=
ess/iwlwifi/iwl-agn-sta.c
index 7353826..e483cfa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
@@ -1187,6 +1187,7 @@ int iwl_remove_dynamic_key(struct iwl_priv *priv,
 	unsigned long flags;
 	struct iwl_addsta_cmd sta_cmd;
 	u8 sta_id =3D iwlagn_key_sta_id(priv, ctx->vif, sta);
+	__le16 key_flags;
=20
 	/* if station isn't there, neither is the key */
 	if (sta_id =3D=3D IWL_INVALID_STATION)
@@ -1212,7 +1213,14 @@ int iwl_remove_dynamic_key(struct iwl_priv *priv,
 		IWL_ERR(priv, "offset %d not used in uCode key table.\n",
 			keyconf->hw_key_idx);
=20
-	sta_cmd.key.key_flags =3D STA_KEY_FLG_NO_ENC | STA_KEY_FLG_INVALID;
+	key_flags =3D cpu_to_le16(keyconf->keyidx << STA_KEY_FLG_KEYID_POS);
+	key_flags |=3D STA_KEY_FLG_MAP_KEY_MSK | STA_KEY_FLG_NO_ENC |
+		     STA_KEY_FLG_INVALID;
+
+	if (!(keyconf->flags & IEEE80211_KEY_FLAG_PAIRWISE))
+		key_flags |=3D STA_KEY_MULTICAST_MSK;
+
+	sta_cmd.key.key_flags =3D key_flags;
 	sta_cmd.key.key_offset =3D WEP_INVALID_OFFSET;
 	sta_cmd.sta.modify_mask =3D STA_MODIFY_KEY_MASK;
 	sta_cmd.mode =3D STA_CONTROL_MODIFY_MSK;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index c3e1aa7..d2a1ea9 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1220,7 +1220,8 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00de=
v)
 		cancel_work_sync(&rt2x00dev->rxdone_work);
 		cancel_work_sync(&rt2x00dev->txdone_work);
 	}
-	destroy_workqueue(rt2x00dev->workqueue);
+	if (rt2x00dev->workqueue)
+		destroy_workqueue(rt2x00dev->workqueue);
=20
 	/*
 	 * Free the tx status fifo.
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 01a21c2..8e2137b 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1332,6 +1332,9 @@ u32 __ieee80211_recalc_idle(struct ieee80211_local *l=
ocal)
 		hw_roc =3D true;
=20
 	list_for_each_entry(sdata, &local->interfaces, list) {
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR ||
+		    sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+			continue;
 		if (sdata->old_idle =3D=3D sdata->vif.bss_conf.idle)
 			continue;
 		if (!ieee80211_sdata_running(sdata))
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index ad64f4d..f9b8e81 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -344,7 +344,7 @@ void rate_control_get_rate(struct ieee80211_sub_if_data=
 *sdata,
 	for (i =3D 0; i < IEEE80211_TX_MAX_RATES; i++) {
 		info->control.rates[i].idx =3D -1;
 		info->control.rates[i].flags =3D 0;
-		info->control.rates[i].count =3D 1;
+		info->control.rates[i].count =3D 0;
 	}
=20
 	if (sdata->local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPS+RLAAoJEJctW/TcYTgGizsP/jcz7TSzdOV/seh4hSFbHsow
+ihPFnyHo6u7swGyDnyuh/KY5RQHHpSlYfW+g0SOyFxCEGfQTY8cJBEQzXZT4gTM
Ej6Oeox875xrDrZVJ/xRkBfSdVc8ah8ERWXrq/lgysyV/GUq/esqggivEsL1fusL
Otb1mAfdVNOlnWF+WPQeBP8N1W5u/WfXdARxMahywOpXGswErsujt5VsKmIqFRqz
GQ671O7eTvoHh1ikh4lMFDrsUxPlwtfu/SHnr902N08NpacbR6VxOHKbVD3fRBW/
CDydjwahX7/QHms9JfxKZL04vSFEiGQw7lMWjIpkkUAhAocKSzG0DnvbVudCJb8x
2w6+W7Vr/neszXDHhMbpwPLkkI7znPP3y8b3JXE32ocVTUPQDgo6s3YxAse7e/g+
iH4HbanHCcNHddf3spOvBC8b9sAlzY9uxTxzBxa02Bjk46BE+TUIQERaRa6fLy89
CK0RhXtvEyH/7TlbDqjVGrUJGcaJPGg1Ma3elguNh0Y9lia5EyT49E/qjWLSzi/R
MzX6YEkHDcJKLAe7k7Kgy/MiTeNvtiWxLeTWnYrFu7yEzy8PdfuhuZAhqj8TWs7M
hO/rgtJ2Fhvcr+f9JD90aXl9ZGefmmcGhwGGeRUBXzbItqEEPHsVkr16+4EnEAia
mY0KhuTj8K7ssXfaTF3y
=BfNl
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
