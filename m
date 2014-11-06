From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-11-06
Date: Thu, 6 Nov 2014 15:52:31 -0500
Message-ID: <20141106205231.GE4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35494 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaKFVAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:00:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.18 stream...

For the mac80211 bits, Johannes says:

"This contains another small set of fixes for 3.18, these are all
over the place and most of the bugs are old, one even dates back
to the original mac80211 we merged into the kernel."

For the iwlwifi bits, Emmanuel says:

"I fix here two issues that are related to the firmware
loading flow. A user reported that he couldn't load the
driver because the rfkill line was pulled up while we
were running the calibrations. This was happening while
booting the system: systemd was restoring the "disable
wifi settings" and that raised an RFKILL interrupt during
the calibration. Our driver didn't handle that properly
and this is now fixed."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 75a916e1944fea8347d2245c62567187e4eff9dd:

  rtlwifi: rtl8192se: Fix firmware loading (2014-10-30 15:00:23 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-11-04

for you to fetch changes up to 0c9a67c8f1d2b71a89f66349362412e9bf6becab:

  Merge tag 'mac80211-for-john-2014-11-04' of git://git.kernel.org/pub/scm/=
linux/kernel/git/jberg/mac80211 (2014-11-04 15:56:33 -0500)

----------------------------------------------------------------

Emmanuel Grumbach (2):
      iwlwifi: mvm: initialize the cur_ucode upon boot
      iwlwifi: fix RFkill while calibrating

Felix Fietkau (1):
      mac80211: flush keys for AP mode on ieee80211_do_stop

Johannes Berg (2):
      mac80211: properly flush delayed scan work on interface removal
      mac80211: fix use-after-free in defragmentation

John W. Linville (2):
      Merge tag 'iwlwifi-for-john-2014-11-03' of git://git.kernel.org/.../i=
wlwifi/iwlwifi-fixes
      Merge tag 'mac80211-for-john-2014-11-04' of git://git.kernel.org/.../=
jberg/mac80211

Junjie Mao (1):
      mac80211_hwsim: release driver when ieee80211_register_hw fails

Luciano Coelho (2):
      mac80211: use secondary channel offset IE also beacons during CSA
      mac80211: schedule the actual switch of the station before CSA count 0

 drivers/net/wireless/iwlwifi/mvm/fw.c       | 10 +++++++++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c |  1 +
 drivers/net/wireless/iwlwifi/mvm/mvm.h      |  1 +
 drivers/net/wireless/iwlwifi/mvm/ops.c      | 12 +++++++++++-
 drivers/net/wireless/iwlwifi/pcie/trans.c   |  4 ++--
 drivers/net/wireless/mac80211_hwsim.c       |  4 +++-
 net/mac80211/ibss.c                         |  2 +-
 net/mac80211/ieee80211_i.h                  |  3 +--
 net/mac80211/iface.c                        | 18 ++++++++++++------
 net/mac80211/mesh.c                         |  2 +-
 net/mac80211/mlme.c                         |  5 +++--
 net/mac80211/rx.c                           | 14 +++++++-------
 net/mac80211/spectmgmt.c                    | 18 ++++++------------
 13 files changed, 58 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/fw.c b/drivers/net/wireless/i=
wlwifi/mvm/fw.c
index e0d9f19650b0..eb03943f8463 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/iwlwifi/mvm/fw.c
@@ -284,7 +284,7 @@ int iwl_run_init_mvm_ucode(struct iwl_mvm *mvm, bool re=
ad_nvm)
=20
 	lockdep_assert_held(&mvm->mutex);
=20
-	if (WARN_ON_ONCE(mvm->init_ucode_complete))
+	if (WARN_ON_ONCE(mvm->init_ucode_complete || mvm->calibrating))
 		return 0;
=20
 	iwl_init_notification_wait(&mvm->notif_wait,
@@ -334,6 +334,8 @@ int iwl_run_init_mvm_ucode(struct iwl_mvm *mvm, bool re=
ad_nvm)
 		goto out;
 	}
=20
+	mvm->calibrating =3D true;
+
 	/* Send TX valid antennas before triggering calibrations */
 	ret =3D iwl_send_tx_ant_cfg(mvm, mvm->fw->valid_tx_ant);
 	if (ret)
@@ -358,11 +360,17 @@ int iwl_run_init_mvm_ucode(struct iwl_mvm *mvm, bool =
read_nvm)
 			MVM_UCODE_CALIB_TIMEOUT);
 	if (!ret)
 		mvm->init_ucode_complete =3D true;
+
+	if (ret && iwl_mvm_is_radio_killed(mvm)) {
+		IWL_DEBUG_RF_KILL(mvm, "RFKILL while calibrating.\n");
+		ret =3D 1;
+	}
 	goto out;
=20
 error:
 	iwl_remove_notification(&mvm->notif_wait, &calib_wait);
 out:
+	mvm->calibrating =3D false;
 	if (iwlmvm_mod_params.init_dbg && !mvm->nvm_data) {
 		/* we want to debug INIT and we have no NVM - fake */
 		mvm->nvm_data =3D kzalloc(sizeof(struct iwl_nvm_data) +
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 585fe5b7100f..b62405865b25 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -788,6 +788,7 @@ static void iwl_mvm_restart_cleanup(struct iwl_mvm *mvm)
=20
 	mvm->scan_status =3D IWL_MVM_SCAN_NONE;
 	mvm->ps_disabled =3D false;
+	mvm->calibrating =3D false;
=20
 	/* just in case one was running */
 	ieee80211_remain_on_channel_expired(mvm->hw);
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/=
iwlwifi/mvm/mvm.h
index b153ced7015b..845429c88cf4 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -548,6 +548,7 @@ struct iwl_mvm {
 	enum iwl_ucode_type cur_ucode;
 	bool ucode_loaded;
 	bool init_ucode_complete;
+	bool calibrating;
 	u32 error_event_table;
 	u32 log_event_table;
 	u32 umac_error_event_table;
diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c b/drivers/net/wireless/=
iwlwifi/mvm/ops.c
index 48cb25a93591..5b719ee8e789 100644
--- a/drivers/net/wireless/iwlwifi/mvm/ops.c
+++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
@@ -424,6 +424,7 @@ iwl_op_mode_mvm_start(struct iwl_trans *trans, const st=
ruct iwl_cfg *cfg,
 	}
 	mvm->sf_state =3D SF_UNINIT;
 	mvm->low_latency_agg_frame_limit =3D 6;
+	mvm->cur_ucode =3D IWL_UCODE_INIT;
=20
 	mutex_init(&mvm->mutex);
 	mutex_init(&mvm->d0i3_suspend_mutex);
@@ -752,6 +753,7 @@ void iwl_mvm_set_hw_ctkill_state(struct iwl_mvm *mvm, b=
ool state)
 static bool iwl_mvm_set_hw_rfkill_state(struct iwl_op_mode *op_mode, bool =
state)
 {
 	struct iwl_mvm *mvm =3D IWL_OP_MODE_GET_MVM(op_mode);
+	bool calibrating =3D ACCESS_ONCE(mvm->calibrating);
=20
 	if (state)
 		set_bit(IWL_MVM_STATUS_HW_RFKILL, &mvm->status);
@@ -760,7 +762,15 @@ static bool iwl_mvm_set_hw_rfkill_state(struct iwl_op_=
mode *op_mode, bool state)
=20
 	wiphy_rfkill_set_hw_state(mvm->hw->wiphy, iwl_mvm_is_radio_killed(mvm));
=20
-	return state && mvm->cur_ucode !=3D IWL_UCODE_INIT;
+	/* iwl_run_init_mvm_ucode is waiting for results, abort it */
+	if (calibrating)
+		iwl_abort_notification_waits(&mvm->notif_wait);
+
+	/*
+	 * Stop the device if we run OPERATIONAL firmware or if we are in the
+	 * middle of the calibrations.
+	 */
+	return state && (mvm->cur_ucode !=3D IWL_UCODE_INIT || calibrating);
 }
=20
 static void iwl_mvm_free_skb(struct iwl_op_mode *op_mode, struct sk_buff *=
skb)
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 3781b029e54a..160c3ebc48d0 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -915,7 +915,8 @@ static void iwl_trans_pcie_stop_device(struct iwl_trans=
 *trans)
 	 * restart. So don't process again if the device is
 	 * already dead.
 	 */
-	if (test_bit(STATUS_DEVICE_ENABLED, &trans->status)) {
+	if (test_and_clear_bit(STATUS_DEVICE_ENABLED, &trans->status)) {
+		IWL_DEBUG_INFO(trans, "DEVICE_ENABLED bit was set and is now cleared\n");
 		iwl_pcie_tx_stop(trans);
 		iwl_pcie_rx_stop(trans);
=20
@@ -945,7 +946,6 @@ static void iwl_trans_pcie_stop_device(struct iwl_trans=
 *trans)
 	/* clear all status bits */
 	clear_bit(STATUS_SYNC_HCMD_ACTIVE, &trans->status);
 	clear_bit(STATUS_INT_ENABLED, &trans->status);
-	clear_bit(STATUS_DEVICE_ENABLED, &trans->status);
 	clear_bit(STATUS_TPOWER_PMI, &trans->status);
 	clear_bit(STATUS_RFKILL, &trans->status);
=20
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/m=
ac80211_hwsim.c
index babbdc1ce741..c9ad4cf1adfb 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1987,7 +1987,7 @@ static int mac80211_hwsim_create_radio(int channels, =
const char *reg_alpha2,
 	if (err !=3D 0) {
 		printk(KERN_DEBUG "mac80211_hwsim: device_bind_driver failed (%d)\n",
 		       err);
-		goto failed_hw;
+		goto failed_bind;
 	}
=20
 	skb_queue_head_init(&data->pending);
@@ -2183,6 +2183,8 @@ static int mac80211_hwsim_create_radio(int channels, =
const char *reg_alpha2,
 	return idx;
=20
 failed_hw:
+	device_release_driver(data->dev);
+failed_bind:
 	device_unregister(data->dev);
 failed_drvdata:
 	ieee80211_free_hw(hw);
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 56b53571c807..509bc157ce55 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -805,7 +805,7 @@ ieee80211_ibss_process_chanswitch(struct ieee80211_sub_=
if_data *sdata,
=20
 	memset(&params, 0, sizeof(params));
 	memset(&csa_ie, 0, sizeof(csa_ie));
-	err =3D ieee80211_parse_ch_switch_ie(sdata, elems, beacon,
+	err =3D ieee80211_parse_ch_switch_ie(sdata, elems,
 					   ifibss->chandef.chan->band,
 					   sta_flags, ifibss->bssid, &csa_ie);
 	/* can't switch to destination channel, fail */
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index c2aaec4dfcf0..8c68da30595d 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1642,7 +1642,6 @@ void ieee80211_process_measurement_req(struct ieee802=
11_sub_if_data *sdata,
  * ieee80211_parse_ch_switch_ie - parses channel switch IEs
  * @sdata: the sdata of the interface which has received the frame
  * @elems: parsed 802.11 elements received with the frame
- * @beacon: indicates if the frame was a beacon or probe response
  * @current_band: indicates the current band
  * @sta_flags: contains information about own capabilities and restrictions
  *	to decide which channel switch announcements can be accepted. Only the
@@ -1656,7 +1655,7 @@ void ieee80211_process_measurement_req(struct ieee802=
11_sub_if_data *sdata,
  * Return: 0 on success, <0 on error and >0 if there is nothing to parse.
  */
 int ieee80211_parse_ch_switch_ie(struct ieee80211_sub_if_data *sdata,
-				 struct ieee802_11_elems *elems, bool beacon,
+				 struct ieee802_11_elems *elems,
 				 enum ieee80211_band current_band,
 				 u32 sta_flags, u8 *bssid,
 				 struct ieee80211_csa_ie *csa_ie);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index af237223a8cd..653f5eb07a27 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -766,10 +766,12 @@ static void ieee80211_do_stop(struct ieee80211_sub_if=
_data *sdata,
 	int i, flushed;
 	struct ps_data *ps;
 	struct cfg80211_chan_def chandef;
+	bool cancel_scan;
=20
 	clear_bit(SDATA_STATE_RUNNING, &sdata->state);
=20
-	if (rcu_access_pointer(local->scan_sdata) =3D=3D sdata)
+	cancel_scan =3D rcu_access_pointer(local->scan_sdata) =3D=3D sdata;
+	if (cancel_scan)
 		ieee80211_scan_cancel(local);
=20
 	/*
@@ -898,6 +900,8 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_d=
ata *sdata,
 		list_del(&sdata->u.vlan.list);
 		mutex_unlock(&local->mtx);
 		RCU_INIT_POINTER(sdata->vif.chanctx_conf, NULL);
+		/* see comment in the default case below */
+		ieee80211_free_keys(sdata, true);
 		/* no need to tell driver */
 		break;
 	case NL80211_IFTYPE_MONITOR:
@@ -923,17 +927,16 @@ static void ieee80211_do_stop(struct ieee80211_sub_if=
_data *sdata,
 		/*
 		 * When we get here, the interface is marked down.
 		 * Free the remaining keys, if there are any
-		 * (shouldn't be, except maybe in WDS mode?)
+		 * (which can happen in AP mode if userspace sets
+		 * keys before the interface is operating, and maybe
+		 * also in WDS mode)
 		 *
 		 * Force the key freeing to always synchronize_net()
 		 * to wait for the RX path in case it is using this
-		 * interface enqueuing frames * at this very time on
+		 * interface enqueuing frames at this very time on
 		 * another CPU.
 		 */
 		ieee80211_free_keys(sdata, true);
-
-		/* fall through */
-	case NL80211_IFTYPE_AP:
 		skb_queue_purge(&sdata->skb_queue);
 	}
=20
@@ -991,6 +994,9 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_d=
ata *sdata,
=20
 	ieee80211_recalc_ps(local, -1);
=20
+	if (cancel_scan)
+		flush_delayed_work(&local->scan_work);
+
 	if (local->open_count =3D=3D 0) {
 		ieee80211_stop_device(local);
=20
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index e9f99c1e3fad..0c8b2a77d312 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -874,7 +874,7 @@ ieee80211_mesh_process_chnswitch(struct ieee80211_sub_i=
f_data *sdata,
=20
 	memset(&params, 0, sizeof(params));
 	memset(&csa_ie, 0, sizeof(csa_ie));
-	err =3D ieee80211_parse_ch_switch_ie(sdata, elems, beacon, band,
+	err =3D ieee80211_parse_ch_switch_ie(sdata, elems, band,
 					   sta_flags, sdata->vif.addr,
 					   &csa_ie);
 	if (err < 0)
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 2de88704278b..93af0f1c9d99 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1072,7 +1072,7 @@ ieee80211_sta_process_chanswitch(struct ieee80211_sub=
_if_data *sdata,
=20
 	current_band =3D cbss->channel->band;
 	memset(&csa_ie, 0, sizeof(csa_ie));
-	res =3D ieee80211_parse_ch_switch_ie(sdata, elems, beacon, current_band,
+	res =3D ieee80211_parse_ch_switch_ie(sdata, elems, current_band,
 					   ifmgd->flags,
 					   ifmgd->associated->bssid, &csa_ie);
 	if (res	< 0)
@@ -1168,7 +1168,8 @@ ieee80211_sta_process_chanswitch(struct ieee80211_sub=
_if_data *sdata,
 		ieee80211_queue_work(&local->hw, &ifmgd->chswitch_work);
 	else
 		mod_timer(&ifmgd->chswitch_timer,
-			  TU_TO_EXP_TIME(csa_ie.count * cbss->beacon_interval));
+			  TU_TO_EXP_TIME((csa_ie.count - 1) *
+					 cbss->beacon_interval));
 }
=20
 static bool
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index b04ca4049c95..a37f9af634cb 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1678,11 +1678,14 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data =
*rx)
 	sc =3D le16_to_cpu(hdr->seq_ctrl);
 	frag =3D sc & IEEE80211_SCTL_FRAG;
=20
-	if (likely((!ieee80211_has_morefrags(fc) && frag =3D=3D 0) ||
-		   is_multicast_ether_addr(hdr->addr1))) {
-		/* not fragmented */
+	if (likely(!ieee80211_has_morefrags(fc) && frag =3D=3D 0))
+		goto out;
+
+	if (is_multicast_ether_addr(hdr->addr1)) {
+		rx->local->dot11MulticastReceivedFrameCount++;
 		goto out;
 	}
+
 	I802_DEBUG_INC(rx->local->rx_handlers_fragments);
=20
 	if (skb_linearize(rx->skb))
@@ -1775,10 +1778,7 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data *=
rx)
  out:
 	if (rx->sta)
 		rx->sta->rx_packets++;
-	if (is_multicast_ether_addr(hdr->addr1))
-		rx->local->dot11MulticastReceivedFrameCount++;
-	else
-		ieee80211_led_rx(rx->local);
+	ieee80211_led_rx(rx->local);
 	return RX_CONTINUE;
 }
=20
diff --git a/net/mac80211/spectmgmt.c b/net/mac80211/spectmgmt.c
index 6ab009070084..efeba56c913b 100644
--- a/net/mac80211/spectmgmt.c
+++ b/net/mac80211/spectmgmt.c
@@ -22,7 +22,7 @@
 #include "wme.h"
=20
 int ieee80211_parse_ch_switch_ie(struct ieee80211_sub_if_data *sdata,
-				 struct ieee802_11_elems *elems, bool beacon,
+				 struct ieee802_11_elems *elems,
 				 enum ieee80211_band current_band,
 				 u32 sta_flags, u8 *bssid,
 				 struct ieee80211_csa_ie *csa_ie)
@@ -91,19 +91,13 @@ int ieee80211_parse_ch_switch_ie(struct ieee80211_sub_i=
f_data *sdata,
 		return -EINVAL;
 	}
=20
-	if (!beacon && sec_chan_offs) {
+	if (sec_chan_offs) {
 		secondary_channel_offset =3D sec_chan_offs->sec_chan_offs;
-	} else if (beacon && ht_oper) {
-		secondary_channel_offset =3D
-			ht_oper->ht_param & IEEE80211_HT_PARAM_CHA_SEC_OFFSET;
 	} else if (!(sta_flags & IEEE80211_STA_DISABLE_HT)) {
-		/* If it's not a beacon, HT is enabled and the IE not present,
-		 * it's 20 MHz, 802.11-2012 8.5.2.6:
-		 *	This element [the Secondary Channel Offset Element] is
-		 *	present when switching to a 40 MHz channel. It may be
-		 *	present when switching to a 20 MHz channel (in which
-		 *	case the secondary channel offset is set to SCN).
-		 */
+		/* If the secondary channel offset IE is not present,
+		 * we can't know what's the post-CSA offset, so the
+		 * best we can do is use 20MHz.
+		*/
 		secondary_channel_offset =3D IEEE80211_HT_PARAM_CHA_SEC_NONE;
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUW9+PAAoJEJctW/TcYTgGC6EP/31YGE0JctGhV54t88YlqoVz
OmJqRdPmA+3jdt7Q6nkcikNO5S70riTz9ss+wbe8H8koi6OlESMtNPcBfqKSlb9h
KR697aeMt7ztRF2LLMctEC3NkMcd8B5Gog2uT+vOXhWAolxRYZgM3LvELSuyjXtR
P9hXNXJYxGTLQe6F71wZ8F4tUfyouIIkIAu1Q/APkpbyGkR8VoTPD++cbsZT9sfz
8SNqA8hI80pVQ/kCsciI+gjWzI/3TlDYrIzb3A3LzA6BkilBIMeImyo5M7r2qp+r
vWqUog02lUn+31gRZq5Ieb8MskB5Rz6mHH4atNyg5bLd+Bgz/oGVkLJmXD6LinDL
SlaEp+nxZx8UrV7ckTAHeFaVVwsNiRmQQJHK8PyCLeJ9IQR65PXNPqwfA6a7/yr3
fVKv4K2ygkDosGhVxiWhhl+dkdSK/VQHgzLn1gmMGi4fVEuchYAM+N1+n9pPlWHX
J+wmP5pq49t1MT3ayRDeDDJmS3FlR4mEF9zcdIlc3FqVQVu16cPf4bo2gAxmmk0A
Wrz/Dtz0oToh0VMbOFHLnm8qmInyHcWx9cJsRo+TVKKd5houbmpcMQbj/O64FrnG
CtKDzeoIhf54kxDItMv7G4Foo7HlAKo4tNJW+KcEu+NUJ6i5hohKc1cDqZMkI4jW
/WlzcTd5dCSmNfGXuBDO
=Mr5Y
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--
