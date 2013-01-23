From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-01-23
Date: Wed, 23 Jan 2013 15:16:06 -0500
Message-ID: <20130123201605.GC5221@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38575 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab3AWUaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 15:30:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a batch of fixes intende for the 3.8 stream.

Regarding the iwlwifi bits, Johannes says this:

"Please pull to get a single fix from Emmanuel for a bug I introduced due
to misunderstanding the code."

Regarding the mac80211 bits, Johannes says this:

"I have a few small fixes for you:
 * some mesh frames would cause encryption warnings -- fixes from Bob
 * scanning would pretty much break an association if we transmitted
   anything to the AP while scanning -- fix from Stanislaw
 * mode injection was broken by channel contexts -- fix from Felix
 * FT roaming was broken: hardware crypto would get disabled by it"

Along with that, a handful of other fixes confined to specific drivers.

Avinash Patil fixes a typo in a NULL check in mwifiex.

Larry Finger fixes a build warning in rtlwifi.  Seems safe...

Stanislaw Gruszka fixes iwlegacy to prevent microcode errors when
switching from IBSS mode to STA mode.

Felix Fietkau provides a trio of ath9k fixes related to proper tuning.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5d0feaff230c0abfe4a112e6f09f096ed99e0b2d:

  r8169: remove the obsolete and incorrect AMD workaround (2013-01-23 13:51=
:47 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to e91d1694d362f065c51eb07b46b19e8b33c92777:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-01-23 14:34:00 -0500)

----------------------------------------------------------------

Avinash Patil (1):
      mwifiex: fix typo in PCIe adapter NULL check

Bob Copeland (2):
      mac80211: set NEED_TXPROCESSING for PERR frames
      mac80211: add encrypt headroom to PERR frames

Emmanuel Grumbach (1):
      iwlwifi: audit single frames from AGG queue in RS

Felix Fietkau (4):
      mac80211: fix monitor mode injection
      ath9k_hw: fix calibration issues on chainmask that don't include chai=
n 0
      ath9k_hw: fix chain swap setting when setting rx chainmask to 5
      ath9k: allow setting arbitrary antenna masks on AR9003+

Johannes Berg (1):
      mac80211: fix FT roaming

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: Fix build warning introduced by commit a290593

Stanislaw Gruszka (2):
      mac80211: synchronize scan off/on-channel and PS states
      iwlegacy: fix IBSS cleanup

 drivers/net/wireless/ath/ath9k/ar9003_calib.c |  2 ++
 drivers/net/wireless/ath/ath9k/ar9003_phy.c   | 27 ++++++---------------
 drivers/net/wireless/ath/ath9k/hw.h           |  1 +
 drivers/net/wireless/ath/ath9k/main.c         |  3 +++
 drivers/net/wireless/iwlegacy/common.c        | 35 +++++++++++------------=
----
 drivers/net/wireless/iwlwifi/dvm/tx.c         |  2 ++
 drivers/net/wireless/mwifiex/pcie.c           |  2 +-
 drivers/net/wireless/rtlwifi/Kconfig          |  4 +--
 net/mac80211/cfg.c                            | 12 ++++++++-
 net/mac80211/ieee80211_i.h                    |  6 ++---
 net/mac80211/mesh_hwmp.c                      |  5 +++-
 net/mac80211/offchannel.c                     | 19 ++++++---------
 net/mac80211/scan.c                           | 15 ++++--------
 net/mac80211/tx.c                             |  9 ++++---
 14 files changed, 67 insertions(+), 75 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wi=
reless/ath/ath9k/ar9003_calib.c
index 8b0d8dc..56317b0 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -976,6 +976,8 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 					  AR_PHY_CL_TAB_1,
 					  AR_PHY_CL_TAB_2 };
=20
+	ar9003_hw_set_chain_masks(ah, ah->caps.rx_chainmask, ah->caps.tx_chainmas=
k);
+
 	if (rtt) {
 		if (!ar9003_hw_rtt_restore(ah, chan))
 			run_rtt_cal =3D true;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.c
index ce19c09..3afc24b 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -586,32 +586,19 @@ static void ar9003_hw_init_bb(struct ath_hw *ah,
 	ath9k_hw_synth_delay(ah, chan, synthDelay);
 }
=20
-static void ar9003_hw_set_chain_masks(struct ath_hw *ah, u8 rx, u8 tx)
+void ar9003_hw_set_chain_masks(struct ath_hw *ah, u8 rx, u8 tx)
 {
-	switch (rx) {
-	case 0x5:
+	if (ah->caps.tx_chainmask =3D=3D 5 || ah->caps.rx_chainmask =3D=3D 5)
 		REG_SET_BIT(ah, AR_PHY_ANALOG_SWAP,
 			    AR_PHY_SWAP_ALT_CHAIN);
-	case 0x3:
-	case 0x1:
-	case 0x2:
-	case 0x7:
-		REG_WRITE(ah, AR_PHY_RX_CHAINMASK, rx);
-		REG_WRITE(ah, AR_PHY_CAL_CHAINMASK, rx);
-		break;
-	default:
-		break;
-	}
+
+	REG_WRITE(ah, AR_PHY_RX_CHAINMASK, rx);
+	REG_WRITE(ah, AR_PHY_CAL_CHAINMASK, rx);
=20
 	if ((ah->caps.hw_caps & ATH9K_HW_CAP_APM) && (tx =3D=3D 0x7))
-		REG_WRITE(ah, AR_SELFGEN_MASK, 0x3);
-	else
-		REG_WRITE(ah, AR_SELFGEN_MASK, tx);
+		tx =3D 3;
=20
-	if (tx =3D=3D 0x5) {
-		REG_SET_BIT(ah, AR_PHY_ANALOG_SWAP,
-			    AR_PHY_SWAP_ALT_CHAIN);
-	}
+	REG_WRITE(ah, AR_SELFGEN_MASK, tx);
 }
=20
 /*
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index 7f1a8e9..9d26fc5 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -1066,6 +1066,7 @@ void ar9003_paprd_setup_gain_table(struct ath_hw *ah,=
 int chain);
 int ar9003_paprd_init_table(struct ath_hw *ah);
 bool ar9003_paprd_is_done(struct ath_hw *ah);
 bool ar9003_is_paprd_enabled(struct ath_hw *ah);
+void ar9003_hw_set_chain_masks(struct ath_hw *ah, u8 rx, u8 tx);
=20
 /* Hardware family op attach helpers */
 void ar5008_hw_attach_phy_ops(struct ath_hw *ah);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 3796e65..dd91f8f 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1826,6 +1826,9 @@ static u32 fill_chainmask(u32 cap, u32 new)
=20
 static bool validate_antenna_mask(struct ath_hw *ah, u32 val)
 {
+	if (AR_SREV_9300_20_OR_LATER(ah))
+		return true;
+
 	switch (val & 0x7) {
 	case 0x1:
 	case 0x3:
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/=
iwlegacy/common.c
index 7e16d10..90b8970 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -3958,17 +3958,21 @@ il_connection_init_rx_config(struct il_priv *il)
=20
 	memset(&il->staging, 0, sizeof(il->staging));
=20
-	if (!il->vif) {
+	switch (il->iw_mode) {
+	case NL80211_IFTYPE_UNSPECIFIED:
 		il->staging.dev_type =3D RXON_DEV_TYPE_ESS;
-	} else if (il->vif->type =3D=3D NL80211_IFTYPE_STATION) {
+		break;
+	case NL80211_IFTYPE_STATION:
 		il->staging.dev_type =3D RXON_DEV_TYPE_ESS;
 		il->staging.filter_flags =3D RXON_FILTER_ACCEPT_GRP_MSK;
-	} else if (il->vif->type =3D=3D NL80211_IFTYPE_ADHOC) {
+		break;
+	case NL80211_IFTYPE_ADHOC:
 		il->staging.dev_type =3D RXON_DEV_TYPE_IBSS;
 		il->staging.flags =3D RXON_FLG_SHORT_PREAMBLE_MSK;
 		il->staging.filter_flags =3D
 		    RXON_FILTER_BCON_AWARE_MSK | RXON_FILTER_ACCEPT_GRP_MSK;
-	} else {
+		break;
+	default:
 		IL_ERR("Unsupported interface type %d\n", il->vif->type);
 		return;
 	}
@@ -4550,8 +4554,7 @@ out:
 EXPORT_SYMBOL(il_mac_add_interface);
=20
 static void
-il_teardown_interface(struct il_priv *il, struct ieee80211_vif *vif,
-		      bool mode_change)
+il_teardown_interface(struct il_priv *il, struct ieee80211_vif *vif)
 {
 	lockdep_assert_held(&il->mutex);
=20
@@ -4560,9 +4563,7 @@ il_teardown_interface(struct il_priv *il, struct ieee=
80211_vif *vif,
 		il_force_scan_end(il);
 	}
=20
-	if (!mode_change)
-		il_set_mode(il);
-
+	il_set_mode(il);
 }
=20
 void
@@ -4575,8 +4576,8 @@ il_mac_remove_interface(struct ieee80211_hw *hw, stru=
ct ieee80211_vif *vif)
=20
 	WARN_ON(il->vif !=3D vif);
 	il->vif =3D NULL;
-
-	il_teardown_interface(il, vif, false);
+	il->iw_mode =3D NL80211_IFTYPE_UNSPECIFIED;
+	il_teardown_interface(il, vif);
 	memset(il->bssid, 0, ETH_ALEN);
=20
 	D_MAC80211("leave\n");
@@ -4685,18 +4686,10 @@ il_mac_change_interface(struct ieee80211_hw *hw, st=
ruct ieee80211_vif *vif,
 	}
=20
 	/* success */
-	il_teardown_interface(il, vif, true);
 	vif->type =3D newtype;
 	vif->p2p =3D false;
-	err =3D il_set_mode(il);
-	WARN_ON(err);
-	/*
-	 * We've switched internally, but submitting to the
-	 * device may have failed for some reason. Mask this
-	 * error, because otherwise mac80211 will not switch
-	 * (and set the interface type back) and we'll be
-	 * out of sync with it.
-	 */
+	il->iw_mode =3D newtype;
+	il_teardown_interface(il, vif);
 	err =3D 0;
=20
 out:
diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/i=
wlwifi/dvm/tx.c
index a790599..31534f7 100644
--- a/drivers/net/wireless/iwlwifi/dvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
@@ -1079,6 +1079,8 @@ static void iwlagn_set_tx_status(struct iwl_priv *pri=
v,
 {
 	u16 status =3D le16_to_cpu(tx_resp->status.status);
=20
+	info->flags &=3D ~IEEE80211_TX_CTL_AMPDU;
+
 	info->status.rates[0].count =3D tx_resp->failure_frame + 1;
 	info->flags |=3D iwl_tx_status_to_mac80211(status);
 	iwlagn_hwrate_to_tx_control(priv, le32_to_cpu(tx_resp->rate_n_flags),
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwi=
fiex/pcie.c
index 13fbc4e..b879e13 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -161,7 +161,7 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, p=
m_message_t state)
=20
 	if (pdev) {
 		card =3D (struct pcie_service_card *) pci_get_drvdata(pdev);
-		if (!card || card->adapter) {
+		if (!card || !card->adapter) {
 			pr_err("Card or adapter structure is not valid\n");
 			return 0;
 		}
diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rt=
lwifi/Kconfig
index 21b1bbb..b80bc46 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -57,12 +57,12 @@ config RTL8192CU
=20
 config RTLWIFI
 	tristate
-	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE
+	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE || RTL8723AE
 	default m
=20
 config RTLWIFI_DEBUG
 	bool "Additional debugging output"
-	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE
+	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE || RTL8723AE
 	default y
=20
 config RTL8192C_COMMON
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 47e0aca..516fbc9 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -164,7 +164,17 @@ static int ieee80211_add_key(struct wiphy *wiphy, stru=
ct net_device *dev,
 			sta =3D sta_info_get(sdata, mac_addr);
 		else
 			sta =3D sta_info_get_bss(sdata, mac_addr);
-		if (!sta) {
+		/*
+		 * The ASSOC test makes sure the driver is ready to
+		 * receive the key. When wpa_supplicant has roamed
+		 * using FT, it attempts to set the key before
+		 * association has completed, this rejects that attempt
+		 * so it will set the key again after assocation.
+		 *
+		 * TODO: accept the key if we have a station entry and
+		 *       add it to the device after the station.
+		 */
+		if (!sta || !test_sta_flag(sta, WLAN_STA_ASSOC)) {
 			ieee80211_key_free(sdata->local, key);
 			err =3D -ENOENT;
 			goto out_unlock;
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8563b9a..2ed065c 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1358,10 +1358,8 @@ int ieee80211_request_sched_scan_stop(struct ieee802=
11_sub_if_data *sdata);
 void ieee80211_sched_scan_stopped_work(struct work_struct *work);
=20
 /* off-channel helpers */
-void ieee80211_offchannel_stop_vifs(struct ieee80211_local *local,
-				    bool offchannel_ps_enable);
-void ieee80211_offchannel_return(struct ieee80211_local *local,
-				 bool offchannel_ps_disable);
+void ieee80211_offchannel_stop_vifs(struct ieee80211_local *local);
+void ieee80211_offchannel_return(struct ieee80211_local *local);
 void ieee80211_roc_setup(struct ieee80211_local *local);
 void ieee80211_start_next_roc(struct ieee80211_local *local);
 void ieee80211_roc_purge(struct ieee80211_sub_if_data *sdata);
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 47aeee2..2659e42 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -215,6 +215,7 @@ static void prepare_frame_for_deferred_tx(struct ieee80=
211_sub_if_data *sdata,
 	skb->priority =3D 7;
=20
 	info->control.vif =3D &sdata->vif;
+	info->flags |=3D IEEE80211_TX_INTFL_NEED_TXPROCESSING;
 	ieee80211_set_qos_hdr(sdata, skb);
 }
=20
@@ -246,11 +247,13 @@ int mesh_path_error_tx(u8 ttl, u8 *target, __le32 tar=
get_sn,
 		return -EAGAIN;
=20
 	skb =3D dev_alloc_skb(local->tx_headroom +
+			    IEEE80211_ENCRYPT_HEADROOM +
+			    IEEE80211_ENCRYPT_TAILROOM +
 			    hdr_len +
 			    2 + 15 /* PERR IE */);
 	if (!skb)
 		return -1;
-	skb_reserve(skb, local->tx_headroom);
+	skb_reserve(skb, local->tx_headroom + IEEE80211_ENCRYPT_HEADROOM);
 	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, hdr_len);
 	memset(mgmt, 0, hdr_len);
 	mgmt->frame_control =3D cpu_to_le16(IEEE80211_FTYPE_MGMT |
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index a5379ae..a3ad4c3 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -102,8 +102,7 @@ static void ieee80211_offchannel_ps_disable(struct ieee=
80211_sub_if_data *sdata)
 	ieee80211_sta_reset_conn_monitor(sdata);
 }
=20
-void ieee80211_offchannel_stop_vifs(struct ieee80211_local *local,
-				    bool offchannel_ps_enable)
+void ieee80211_offchannel_stop_vifs(struct ieee80211_local *local)
 {
 	struct ieee80211_sub_if_data *sdata;
=20
@@ -134,8 +133,7 @@ void ieee80211_offchannel_stop_vifs(struct ieee80211_lo=
cal *local,
=20
 		if (sdata->vif.type !=3D NL80211_IFTYPE_MONITOR) {
 			netif_tx_stop_all_queues(sdata->dev);
-			if (offchannel_ps_enable &&
-			    (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION) &&
+			if (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION &&
 			    sdata->u.mgd.associated)
 				ieee80211_offchannel_ps_enable(sdata);
 		}
@@ -143,8 +141,7 @@ void ieee80211_offchannel_stop_vifs(struct ieee80211_lo=
cal *local,
 	mutex_unlock(&local->iflist_mtx);
 }
=20
-void ieee80211_offchannel_return(struct ieee80211_local *local,
-				 bool offchannel_ps_disable)
+void ieee80211_offchannel_return(struct ieee80211_local *local)
 {
 	struct ieee80211_sub_if_data *sdata;
=20
@@ -163,11 +160,9 @@ void ieee80211_offchannel_return(struct ieee80211_loca=
l *local,
 			continue;
=20
 		/* Tell AP we're back */
-		if (offchannel_ps_disable &&
-		    sdata->vif.type =3D=3D NL80211_IFTYPE_STATION) {
-			if (sdata->u.mgd.associated)
-				ieee80211_offchannel_ps_disable(sdata);
-		}
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_STATION &&
+		    sdata->u.mgd.associated)
+			ieee80211_offchannel_ps_disable(sdata);
=20
 		if (sdata->vif.type !=3D NL80211_IFTYPE_MONITOR) {
 			/*
@@ -385,7 +380,7 @@ void ieee80211_sw_roc_work(struct work_struct *work)
 			local->tmp_channel =3D NULL;
 			ieee80211_hw_config(local, 0);
=20
-			ieee80211_offchannel_return(local, true);
+			ieee80211_offchannel_return(local);
 		}
=20
 		ieee80211_recalc_idle(local);
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index d59fc68..bf82e69 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -292,7 +292,7 @@ static void __ieee80211_scan_completed(struct ieee80211=
_hw *hw, bool aborted,
 	if (!was_hw_scan) {
 		ieee80211_configure_filter(local);
 		drv_sw_scan_complete(local);
-		ieee80211_offchannel_return(local, true);
+		ieee80211_offchannel_return(local);
 	}
=20
 	ieee80211_recalc_idle(local);
@@ -341,7 +341,7 @@ static int ieee80211_start_sw_scan(struct ieee80211_loc=
al *local)
 	local->next_scan_state =3D SCAN_DECISION;
 	local->scan_channel_idx =3D 0;
=20
-	ieee80211_offchannel_stop_vifs(local, true);
+	ieee80211_offchannel_stop_vifs(local);
=20
 	ieee80211_configure_filter(local);
=20
@@ -678,12 +678,8 @@ static void ieee80211_scan_state_suspend(struct ieee80=
211_local *local,
 	local->scan_channel =3D NULL;
 	ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL);
=20
-	/*
-	 * Re-enable vifs and beaconing.  Leave PS
-	 * in off-channel state..will put that back
-	 * on-channel at the end of scanning.
-	 */
-	ieee80211_offchannel_return(local, false);
+	/* disable PS */
+	ieee80211_offchannel_return(local);
=20
 	*next_delay =3D HZ / 5;
 	/* afterwards, resume scan & go to next channel */
@@ -693,8 +689,7 @@ static void ieee80211_scan_state_suspend(struct ieee802=
11_local *local,
 static void ieee80211_scan_state_resume(struct ieee80211_local *local,
 					unsigned long *next_delay)
 {
-	/* PS already is in off-channel mode */
-	ieee80211_offchannel_stop_vifs(local, false);
+	ieee80211_offchannel_stop_vifs(local);
=20
 	if (local->ops->flush) {
 		drv_flush(local, false);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index e9eadc4..467c1d1 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1673,10 +1673,13 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_=
buff *skb,
 			chanctx_conf =3D
 				rcu_dereference(tmp_sdata->vif.chanctx_conf);
 	}
-	if (!chanctx_conf)
-		goto fail_rcu;
=20
-	chan =3D chanctx_conf->def.chan;
+	if (chanctx_conf)
+		chan =3D chanctx_conf->def.chan;
+	else if (!local->use_chanctx)
+		chan =3D local->_oper_channel;
+	else
+		goto fail_rcu;
=20
 	/*
 	 * Frame injection is not allowed if beaconing is not allowed
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRAEUFAAoJEJctW/TcYTgG6XQP+gO8iSNAwCPOuDTCQn6GC96n
gATUR7cEyrseEQJjtw6uJWX7BPTGAMdbwdlh2he2QsuxHyYxMN8sVMHn2+GoLhyh
Jff2kTbqg+o9PrHOQP8ZYro4mUL3Va0aLUAwvCNK/bEIwyvibPMDO0NOzEeV7fXs
L8m8+22iM3r4PhWBqocsL0jpcT3nnzbbPBiQO1I3Ju0KxbWaCEp7xyCpsp42ymqG
OjihBq/MKrKSZslgZnEaxa2ztmaXynfJEOCm7AMSSwTeW23UQIiw+PwLirsSvjeZ
MinhCW03Z9vTArih9l9IQ9oRFEv48DHECyzY1wipwjxy+8qIdi3PnanweFXDczkA
xAj/rqn5gp1SuelWJrwnwSjwVyi1CwcejSQWuTRL7DOompRnmzK4P1RsOvasIzPN
RggHVbov3s80rFB7rfsYHQqOhoduhVXXP+Bf/161U7GSR+gWoMzXTeGmQ5IcATNg
Dn31FjFLeQeGDBoD9hAXQg7YHFej5oJ3rPosgZJ5bUEuFhrj8DeJqD9peuL6e2nE
TudTatdasYk2cl8YV2+Jxlv3QahiVO58Ty7/hXqv2jx2zAt2oAGpNqS8xFKQGYL7
+97QiheA4nOuIuEvqy86OThz5StnZCRdESwiODTCniRcqYodB2GtZ+SQzN9WV3h/
+v73f2/S3XZm6RtiOMJf
=ZrEK
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--
