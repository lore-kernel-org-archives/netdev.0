From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-08-23
Date: Fri, 23 Aug 2013 12:20:44 -0400
Message-ID: <20130823162044.GD15114@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is one more set of fixes intended for the 3.11 stream...

For the mac80211 bits, Johannes says:

"I have three more patches for the 3.11 stream: Felix's fix for the
fairly visible brcmsmac crash, a fix from Simon for an IBSS join bug I
found and a fix for a channel context bug in IBSS I'd introduced."

Along with those...

Sujith Manoharan makes a minor change to not use a PLL hang workaroun
for AR9550.  This one-liner fixes a couple of bugs reported in the Red Hat
bugzilla.

Helmut Schaa addresses an ath9k_htc bug that mangles frame headers
during Tx.  This fix is small, tested by the bug reported and isolated
to ath9k_htc.

Stanislaw Gruszka reverts a recent iwl4965 change that broke rfkill
notification to user space.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4a5a8aa6c966eafc106543bd955ae388230420e5:

  ipv4: expose IPV4_DEVCONF (2013-08-22 20:30:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 81ca2ff9450c2e983ee416eca17ebe6fa9c3da4f:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-08-23 11:47:48 -0400)

----------------------------------------------------------------

Felix Fietkau (1):
      mac80211: add a flag to indicate CCK support for HT clients

Helmut Schaa (1):
      ath9k_htc: Restore skb headroom when returning skb to mac80211

Johannes Berg (1):
      mac80211: add missing channel context release

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Simon Wunderlich (1):
      mac80211: ibss: fix ignored channel parameter

Stanislaw Gruszka (1):
      iwl4965: fix rfkill set state regression

Sujith Manoharan (1):
      ath9k: Enable PLL fix only for AR9340/AR9330

 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c | 10 ++++++++
 drivers/net/wireless/ath/ath9k/init.c         |  3 ++-
 drivers/net/wireless/ath/ath9k/main.c         |  3 +--
 drivers/net/wireless/ath/carl9170/main.c      |  3 ++-
 drivers/net/wireless/iwlegacy/4965-mac.c      |  2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c       |  3 ++-
 include/net/mac80211.h                        |  1 +
 net/mac80211/ibss.c                           | 34 +++++++++++++++++++++++=
----
 net/mac80211/rc80211_minstrel_ht.c            |  3 +++
 9 files changed, 52 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_txrx.c
index e602c95..c028df7 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -448,6 +448,7 @@ static void ath9k_htc_tx_process(struct ath9k_htc_priv =
*priv,
 	struct ieee80211_conf *cur_conf =3D &priv->hw->conf;
 	bool txok;
 	int slot;
+	int hdrlen, padsize;
=20
 	slot =3D strip_drv_header(priv, skb);
 	if (slot < 0) {
@@ -504,6 +505,15 @@ send_mac80211:
=20
 	ath9k_htc_tx_clear_slot(priv, slot);
=20
+	/* Remove padding before handing frame back to mac80211 */
+	hdrlen =3D ieee80211_get_hdrlen_from_skb(skb);
+
+	padsize =3D hdrlen & 3;
+	if (padsize && skb->len > hdrlen + padsize) {
+		memmove(skb->data + padsize, skb->data, hdrlen);
+		skb_pull(skb, padsize);
+	}
+
 	/* Send status to mac80211 */
 	ieee80211_tx_status(priv->hw, skb);
 }
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index 16f8b20..026a2a0 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -802,7 +802,8 @@ void ath9k_set_hw_capab(struct ath_softc *sc, struct ie=
ee80211_hw *hw)
 		IEEE80211_HW_PS_NULLFUNC_STACK |
 		IEEE80211_HW_SPECTRUM_MGMT |
 		IEEE80211_HW_REPORTS_TX_ACK_STATUS |
-		IEEE80211_HW_SUPPORTS_RC_TABLE;
+		IEEE80211_HW_SUPPORTS_RC_TABLE |
+		IEEE80211_HW_SUPPORTS_HT_CCK_RATES;
=20
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT) {
 		hw->flags |=3D IEEE80211_HW_AMPDU_AGGREGATION;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 1737a3e..cb5a655 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -173,8 +173,7 @@ static void ath_restart_work(struct ath_softc *sc)
 {
 	ieee80211_queue_delayed_work(sc->hw, &sc->tx_complete_work, 0);
=20
-	if (AR_SREV_9340(sc->sc_ah) || AR_SREV_9485(sc->sc_ah) ||
-	    AR_SREV_9550(sc->sc_ah))
+	if (AR_SREV_9340(sc->sc_ah) || AR_SREV_9330(sc->sc_ah))
 		ieee80211_queue_delayed_work(sc->hw, &sc->hw_pll_work,
 				     msecs_to_jiffies(ATH_PLL_WORK_INTERVAL));
=20
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireles=
s/ath/carl9170/main.c
index 4a33c6e..349fa22 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1860,7 +1860,8 @@ void *carl9170_alloc(size_t priv_size)
 		     IEEE80211_HW_PS_NULLFUNC_STACK |
 		     IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC |
 		     IEEE80211_HW_SUPPORTS_RC_TABLE |
-		     IEEE80211_HW_SIGNAL_DBM;
+		     IEEE80211_HW_SIGNAL_DBM |
+		     IEEE80211_HW_SUPPORTS_HT_CCK_RATES;
=20
 	if (!modparam_noht) {
 		/*
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireles=
s/iwlegacy/4965-mac.c
index f2ed62e..7acf5ee 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -4464,9 +4464,9 @@ il4965_irq_tasklet(struct il_priv *il)
 			set_bit(S_RFKILL, &il->status);
 		} else {
 			clear_bit(S_RFKILL, &il->status);
-			wiphy_rfkill_set_hw_state(il->hw->wiphy, hw_rf_kill);
 			il_force_reset(il, true);
 		}
+		wiphy_rfkill_set_hw_state(il->hw->wiphy, hw_rf_kill);
=20
 		handled |=3D CSR_INT_BIT_RF_KILL;
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index 1f80ea5..1b41c8e 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -6133,7 +6133,8 @@ static int rt2800_probe_hw_mode(struct rt2x00_dev *rt=
2x00dev)
 	    IEEE80211_HW_SUPPORTS_PS |
 	    IEEE80211_HW_PS_NULLFUNC_STACK |
 	    IEEE80211_HW_AMPDU_AGGREGATION |
-	    IEEE80211_HW_REPORTS_TX_ACK_STATUS;
+	    IEEE80211_HW_REPORTS_TX_ACK_STATUS |
+	    IEEE80211_HW_SUPPORTS_HT_CCK_RATES;
=20
 	/*
 	 * Don't set IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING for USB devices
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 5b7a3da..551ba6a 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1499,6 +1499,7 @@ enum ieee80211_hw_flags {
 	IEEE80211_HW_SUPPORTS_RC_TABLE			=3D 1<<24,
 	IEEE80211_HW_P2P_DEV_ADDR_FOR_INTF		=3D 1<<25,
 	IEEE80211_HW_TIMING_BEACON_ONLY			=3D 1<<26,
+	IEEE80211_HW_SUPPORTS_HT_CCK_RATES		=3D 1<<27,
 };
=20
 /**
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index ea7b9c2..2d45643 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -36,7 +36,7 @@
=20
 static void __ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 				      const u8 *bssid, const int beacon_int,
-				      struct ieee80211_channel *chan,
+				      struct cfg80211_chan_def *req_chandef,
 				      const u32 basic_rates,
 				      const u16 capability, u64 tsf,
 				      bool creator)
@@ -51,6 +51,7 @@ static void __ieee80211_sta_join_ibss(struct ieee80211_su=
b_if_data *sdata,
 	u32 bss_change;
 	u8 supp_rates[IEEE80211_MAX_SUPP_RATES];
 	struct cfg80211_chan_def chandef;
+	struct ieee80211_channel *chan;
 	struct beacon_data *presp;
 	int frame_len;
=20
@@ -81,7 +82,9 @@ static void __ieee80211_sta_join_ibss(struct ieee80211_su=
b_if_data *sdata,
=20
 	sdata->drop_unencrypted =3D capability & WLAN_CAPABILITY_PRIVACY ? 1 : 0;
=20
-	chandef =3D ifibss->chandef;
+	/* make a copy of the chandef, it could be modified below. */
+	chandef =3D *req_chandef;
+	chan =3D chandef.chan;
 	if (!cfg80211_reg_can_beacon(local->hw.wiphy, &chandef)) {
 		chandef.width =3D NL80211_CHAN_WIDTH_20;
 		chandef.center_freq1 =3D chan->center_freq;
@@ -259,10 +262,12 @@ static void ieee80211_sta_join_ibss(struct ieee80211_=
sub_if_data *sdata,
 	struct cfg80211_bss *cbss =3D
 		container_of((void *)bss, struct cfg80211_bss, priv);
 	struct ieee80211_supported_band *sband;
+	struct cfg80211_chan_def chandef;
 	u32 basic_rates;
 	int i, j;
 	u16 beacon_int =3D cbss->beacon_interval;
 	const struct cfg80211_bss_ies *ies;
+	enum nl80211_channel_type chan_type;
 	u64 tsf;
=20
 	sdata_assert_lock(sdata);
@@ -270,6 +275,26 @@ static void ieee80211_sta_join_ibss(struct ieee80211_s=
ub_if_data *sdata,
 	if (beacon_int < 10)
 		beacon_int =3D 10;
=20
+	switch (sdata->u.ibss.chandef.width) {
+	case NL80211_CHAN_WIDTH_20_NOHT:
+	case NL80211_CHAN_WIDTH_20:
+	case NL80211_CHAN_WIDTH_40:
+		chan_type =3D cfg80211_get_chandef_type(&sdata->u.ibss.chandef);
+		cfg80211_chandef_create(&chandef, cbss->channel, chan_type);
+		break;
+	case NL80211_CHAN_WIDTH_5:
+	case NL80211_CHAN_WIDTH_10:
+		cfg80211_chandef_create(&chandef, cbss->channel,
+					NL80211_CHAN_WIDTH_20_NOHT);
+		chandef.width =3D sdata->u.ibss.chandef.width;
+		break;
+	default:
+		/* fall back to 20 MHz for unsupported modes */
+		cfg80211_chandef_create(&chandef, cbss->channel,
+					NL80211_CHAN_WIDTH_20_NOHT);
+		break;
+	}
+
 	sband =3D sdata->local->hw.wiphy->bands[cbss->channel->band];
=20
 	basic_rates =3D 0;
@@ -294,7 +319,7 @@ static void ieee80211_sta_join_ibss(struct ieee80211_su=
b_if_data *sdata,
=20
 	__ieee80211_sta_join_ibss(sdata, cbss->bssid,
 				  beacon_int,
-				  cbss->channel,
+				  &chandef,
 				  basic_rates,
 				  cbss->capability,
 				  tsf, false);
@@ -736,7 +761,7 @@ static void ieee80211_sta_create_ibss(struct ieee80211_=
sub_if_data *sdata)
 		sdata->drop_unencrypted =3D 0;
=20
 	__ieee80211_sta_join_ibss(sdata, bssid, sdata->vif.bss_conf.beacon_int,
-				  ifibss->chandef.chan, ifibss->basic_rates,
+				  &ifibss->chandef, ifibss->basic_rates,
 				  capability, 0, true);
 }
=20
@@ -1138,6 +1163,7 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_data=
 *sdata)
 	clear_bit(SDATA_STATE_OFFCHANNEL_BEACON_STOPPED, &sdata->state);
 	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BEACON_ENABLED |
 						BSS_CHANGED_IBSS);
+	ieee80211_vif_release_channel(sdata);
 	synchronize_rcu();
 	kfree(presp);
=20
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_mins=
trel_ht.c
index f5aed96..f3bbea1 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -828,6 +828,9 @@ minstrel_ht_update_cck(struct minstrel_priv *mp, struct=
 minstrel_ht_sta *mi,
 	if (sband->band !=3D IEEE80211_BAND_2GHZ)
 		return;
=20
+	if (!(mp->hw->flags & IEEE80211_HW_SUPPORTS_HT_CCK_RATES))
+		return;
+
 	mi->cck_supported =3D 0;
 	mi->cck_supported_short =3D 0;
 	for (i =3D 0; i < 4; i++) {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSF4vcAAoJEJctW/TcYTgGiT4QAJNIvtYp4g5L1RGvdyzMl/1Q
qirUXJACtU10Z9UwUWrWU+0WdpVwDK7g2aFXEAb0mplLR1h1+wMh1N0NcWZodnJ+
3AvC0ZORibbJ8jVkQTJ166UeRY5CDwaU3URF0k4cSmNBIyM3pRsNZEMqlVke6Fzi
TOYzGjg2dDmhjVw9bMZYogDK/ff/aQh/F8QKyj16J5cAaOPJ18X4x0X8paiAouG9
HzmZSMxHiJpTj1qSc0yHiSeDJx1juc1xg1JOyUxJqY0Jd1uBMTOnQY2VeBgk/u90
cRN8DyvtEmVkFlwGZxMjHGmOBixX/VKuZDf21sKOIvUEbWKNBZauTle4i6rigjBZ
oOyQSCDLhtV/dDvdEgw3WbtX9i7dx+ovQEBb1KlSpq+vG1XntvY2SDz+tspFfomN
ROri/oUHrkeR/34iTn/6qMS9Af2YwSxVRdCpYtJznKsjYo+U6Gk0qW8k/iFZSF78
yeNGxUUg8BosMwatKrA8+o9Xe+aoWPgiJyp8f+AGFJr4MicfDQMzL+F6xy1FIaLo
ZaEdDmYF4EpcCsS5O3ygvfZLRdY6geve+JjtZLtvJn3Deh6pEkcHB1oLaD97ie3P
ptjDT7Uhug9V34pvVOj/WGBMF/UvRCvesm1FvZr4HwvLmrqh3DVf2F3DDVmme9a7
fGMqRlVaCVCnwNrsHtS0
=01oj
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
