From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-03-27
Date: Tue, 27 Mar 2012 14:32:42 -0400
Message-ID: <20120327183242.GB20938@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51065 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707Ab2C0SrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 14:47:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 643c61e119459e9d750087b7b34be94491efebf9

Dave,

Here is a little round-up of fixes intended for 3.4...

First, we have a MAINTAINERS update -- not truly a "fix", but it might
help to keep unwanted traffic out of Bob's inbox.  We also have a
removal of an outdated comment that was overlooked when the related
code was removed.

Beyond those, we have a fix for a memory leak in ath9k, a cfg80211
fix to prevent passing bad info over nl80211 to userspace, a tuning
fix for some rtlwifi family drivers, a couple of minor ath9k tuning
fixes, a mac80211 use-after-free fix, a couple of rt2x00 thinko fixes,
an iwlegacy fix to properly set BSSID after an association, and an
iwlegacy fix to avoid an oops by properly reinitializing a variable
after reset.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 8a78335442cea429afb2b964318b6e257448ea00:

  usbnet: consider device busy at each recieved packet (2012-03-22 23:04:27=
 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Bob Copeland (1):
      ath5k: drop self from MAINTAINERS

Eliad Peller (1):
      mac80211: remove outdated comment

Eric Dumazet (1):
      ath9k: fix a memory leak in ath_rx_tasklet()

John W. Linville (1):
      cfg80211: allow CFG80211_SIGNAL_TYPE_UNSPEC in station_info

Larry Finger (1):
      rtlwifi: rtl8192ce: rtl8192cu: rtl8192de: Fix low-gain setting when s=
canning

Rajkumar Manoharan (2):
      ath9k: fix max noise floor threshold
      ath9k: reduce listen time period

Stanislaw Gruszka (5):
      iwlegacy: do not nulify il->vif on reset
      iwlegacy: fix BSSID setting
      rt2x00: rt2800usb: schedule txdone work on timeout
      rt2x00: rt2800usb: fix status register reread logic
      mac80211: fix possible tid_rx->reorder_timer use after free

 MAINTAINERS                                        |    1 -
 drivers/net/wireless/ath/ath9k/calib.c             |    5 +--
 drivers/net/wireless/ath/ath9k/init.c              |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    4 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 -
 drivers/net/wireless/iwlegacy/4965-mac.c           |    2 -
 drivers/net/wireless/iwlegacy/common.c             |   31 +++++++++++-----=
---
 drivers/net/wireless/rt2x00/rt2800usb.c            |   10 +++++-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    2 +-
 include/net/cfg80211.h                             |    6 ++-
 net/mac80211/agg-rx.c                              |    3 +-
 net/mac80211/main.c                                |    3 --
 net/wireless/nl80211.c                             |   29 ++++++++++++----=
--
 14 files changed, 58 insertions(+), 44 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 92f9924..0ddc77fe 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1247,7 +1247,6 @@ ATHEROS ATH5K WIRELESS DRIVER
 M:	Jiri Slaby <jirislaby@gmail.com>
 M:	Nick Kossifidis <mickflemm@gmail.com>
 M:	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
-M:	Bob Copeland <me@bobcopeland.com>
 L:	linux-wireless@vger.kernel.org
 L:	ath5k-devel@lists.ath5k.org
 W:	http://wireless.kernel.org/en/users/Drivers/ath5k
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/=
ath/ath9k/calib.c
index 2f4b48e..e5cceb0 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -20,7 +20,6 @@
=20
 /* Common calibration code */
=20
-#define ATH9K_NF_TOO_HIGH	-60
=20
 static int16_t ath9k_hw_get_nf_hist_mid(int16_t *nfCalBuffer)
 {
@@ -346,10 +345,10 @@ static void ath9k_hw_nf_sanitize(struct ath_hw *ah, s=
16 *nf)
 			"NF calibrated [%s] [chain %d] is %d\n",
 			(i >=3D 3 ? "ext" : "ctl"), i % 3, nf[i]);
=20
-		if (nf[i] > ATH9K_NF_TOO_HIGH) {
+		if (nf[i] > limit->max) {
 			ath_dbg(common, CALIBRATE,
 				"NF[%d] (%d) > MAX (%d), correcting to MAX\n",
-				i, nf[i], ATH9K_NF_TOO_HIGH);
+				i, nf[i], limit->max);
 			nf[i] =3D limit->max;
 		} else if (nf[i] < limit->min) {
 			ath_dbg(common, CALIBRATE,
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index 60159f4..cb00645 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -680,7 +680,7 @@ void ath9k_set_hw_capab(struct ath_softc *sc, struct ie=
ee80211_hw *hw)
 	hw->queues =3D 4;
 	hw->max_rates =3D 4;
 	hw->channel_change_time =3D 5000;
-	hw->max_listen_interval =3D 10;
+	hw->max_listen_interval =3D 1;
 	hw->max_rate_tries =3D 10;
 	hw->sta_data_size =3D sizeof(struct ath_node);
 	hw->vif_data_size =3D sizeof(struct ath_vif);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/a=
th/ath9k/recv.c
index f4ae3ba..1c4583c 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1913,13 +1913,13 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush,=
 bool hp)
 		if (sc->rx.frag) {
 			int space =3D skb->len - skb_tailroom(hdr_skb);
=20
-			sc->rx.frag =3D NULL;
-
 			if (pskb_expand_head(hdr_skb, 0, space, GFP_ATOMIC) < 0) {
 				dev_kfree_skb(skb);
 				goto requeue_drop_frag;
 			}
=20
+			sc->rx.frag =3D NULL;
+
 			skb_copy_from_linear_data(skb, skb_put(hdr_skb, skb->len),
 						  skb->len);
 			dev_kfree_skb_any(skb);
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireles=
s/iwlegacy/3945-mac.c
index 0c12093..faec404 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -2673,8 +2673,6 @@ il3945_bg_restart(struct work_struct *data)
=20
 	if (test_and_clear_bit(S_FW_ERROR, &il->status)) {
 		mutex_lock(&il->mutex);
-		/* FIXME: vif can be dereferenced */
-		il->vif =3D NULL;
 		il->is_open =3D 0;
 		mutex_unlock(&il->mutex);
 		il3945_down(il);
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireles=
s/iwlegacy/4965-mac.c
index 7b54dbb..b88bb27 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -5651,8 +5651,6 @@ il4965_bg_restart(struct work_struct *data)
=20
 	if (test_and_clear_bit(S_FW_ERROR, &il->status)) {
 		mutex_lock(&il->mutex);
-		/* FIXME: do we dereference vif without mutex locked ? */
-		il->vif =3D NULL;
 		il->is_open =3D 0;
=20
 		__il4965_down(il);
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/=
iwlegacy/common.c
index e5ac047..eaf24945 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4508,6 +4508,7 @@ il_mac_add_interface(struct ieee80211_hw *hw, struct =
ieee80211_vif *vif)
 {
 	struct il_priv *il =3D hw->priv;
 	int err;
+	bool reset;
=20
 	mutex_lock(&il->mutex);
 	D_MAC80211("enter: type %d, addr %pM\n", vif->type, vif->addr);
@@ -4518,7 +4519,12 @@ il_mac_add_interface(struct ieee80211_hw *hw, struct=
 ieee80211_vif *vif)
 		goto out;
 	}
=20
-	if (il->vif) {
+	/*
+	 * We do not support multiple virtual interfaces, but on hardware reset
+	 * we have to add the same interface again.
+	 */
+	reset =3D (il->vif =3D=3D vif);
+	if (il->vif && !reset) {
 		err =3D -EOPNOTSUPP;
 		goto out;
 	}
@@ -4528,8 +4534,11 @@ il_mac_add_interface(struct ieee80211_hw *hw, struct=
 ieee80211_vif *vif)
=20
 	err =3D il_set_mode(il);
 	if (err) {
-		il->vif =3D NULL;
-		il->iw_mode =3D NL80211_IFTYPE_STATION;
+		IL_WARN("Fail to set mode %d\n", vif->type);
+		if (!reset) {
+			il->vif =3D NULL;
+			il->iw_mode =3D NL80211_IFTYPE_STATION;
+		}
 	}
=20
 out:
@@ -5279,9 +5288,9 @@ il_mac_bss_info_changed(struct ieee80211_hw *hw, stru=
ct ieee80211_vif *vif,
 		D_MAC80211("BSSID %pM\n", bss_conf->bssid);
=20
 		/*
-		 * If there is currently a HW scan going on in the
-		 * background then we need to cancel it else the RXON
-		 * below/in post_associate will fail.
+		 * If there is currently a HW scan going on in the background,
+		 * then we need to cancel it, otherwise sometimes we are not
+		 * able to authenticate (FIXME: why ?)
 		 */
 		if (il_scan_cancel_timeout(il, 100)) {
 			D_MAC80211("leave - scan abort failed\n");
@@ -5290,14 +5299,10 @@ il_mac_bss_info_changed(struct ieee80211_hw *hw, st=
ruct ieee80211_vif *vif,
 		}
=20
 		/* mac80211 only sets assoc when in STATION mode */
-		if (vif->type =3D=3D NL80211_IFTYPE_ADHOC || bss_conf->assoc) {
-			memcpy(il->staging.bssid_addr, bss_conf->bssid,
-			       ETH_ALEN);
+		memcpy(il->staging.bssid_addr, bss_conf->bssid, ETH_ALEN);
=20
-			/* currently needed in a few places */
-			memcpy(il->bssid, bss_conf->bssid, ETH_ALEN);
-		} else
-			il->staging.filter_flags &=3D ~RXON_FILTER_ASSOC_MSK;
+		/* FIXME: currently needed in a few places */
+		memcpy(il->bssid, bss_conf->bssid, ETH_ALEN);
 	}
=20
 	/*
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index cd490ab..001735f 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -163,7 +163,13 @@ static bool rt2800usb_tx_sta_fifo_read_completed(struc=
t rt2x00_dev *rt2x00dev,
=20
 		/* Reschedule urb to read TX status again instantly */
 		return true;
-	} else if (rt2800usb_txstatus_pending(rt2x00dev)) {
+	}
+
+	/* Check if there is any entry that timedout waiting on TX status */
+	if (rt2800usb_txstatus_timeout(rt2x00dev))
+		queue_work(rt2x00dev->workqueue, &rt2x00dev->txdone_work);
+
+	if (rt2800usb_txstatus_pending(rt2x00dev)) {
 		/* Read register after 250 us */
 		hrtimer_start(&rt2x00dev->txstatus_timer, ktime_set(0, 250000),
 			      HRTIMER_MODE_REL);
@@ -178,7 +184,7 @@ stop_reading:
 	 * here again if status reading is needed.
 	 */
 	if (rt2800usb_txstatus_pending(rt2x00dev) &&
-	    test_and_set_bit(TX_STATUS_READING, &rt2x00dev->flags))
+	    !test_and_set_bit(TX_STATUS_READING, &rt2x00dev->flags))
 		return true;
 	else
 		return false;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/n=
et/wireless/rtlwifi/rtl8192c/phy_common.c
index 1eec3a0..4c01624 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -1893,7 +1893,7 @@ void rtl92c_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	case IO_CMD_PAUSE_DM_BY_SCAN:
 		rtlphy->initgain_backup.xaagccore1 =3D dm_digtable.cur_igvalue;
-		dm_digtable.cur_igvalue =3D 0x17;
+		dm_digtable.cur_igvalue =3D 0x37;
 		rtl92c_dm_write_dig(hw);
 		break;
 	default:
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8192de/phy.c
index 34591eeb..28fc5fb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -3077,7 +3077,7 @@ static void rtl92d_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	case IO_CMD_PAUSE_DM_BY_SCAN:
 		rtlphy->initgain_backup.xaagccore1 =3D de_digtable.cur_igvalue;
-		de_digtable.cur_igvalue =3D 0x17;
+		de_digtable.cur_igvalue =3D 0x37;
 		rtl92d_dm_write_dig(hw);
 		break;
 	default:
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 69b7ad3..5ccac72 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -619,8 +619,10 @@ struct sta_bss_parameters {
  * @llid: mesh local link id
  * @plid: mesh peer link id
  * @plink_state: mesh peer link state
- * @signal: signal strength of last received packet in dBm
- * @signal_avg: signal strength average in dBm
+ * @signal: the signal strength, type depends on the wiphy's signal_type
+	NOTE: For CFG80211_SIGNAL_TYPE_MBM, value is expressed in _dBm_.
+ * @signal_avg: avg signal strength, type depends on the wiphy's signal_ty=
pe
+	NOTE: For CFG80211_SIGNAL_TYPE_MBM, value is expressed in _dBm_.
  * @txrate: current unicast bitrate from this station
  * @rxrate: current unicast bitrate to this station
  * @rx_packets: packets received from this station
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 1068f66..64d3ce5 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -49,6 +49,8 @@ static void ieee80211_free_tid_rx(struct rcu_head *h)
 		container_of(h, struct tid_ampdu_rx, rcu_head);
 	int i;
=20
+	del_timer_sync(&tid_rx->reorder_timer);
+
 	for (i =3D 0; i < tid_rx->buf_size; i++)
 		dev_kfree_skb(tid_rx->reorder_buf[i]);
 	kfree(tid_rx->reorder_buf);
@@ -91,7 +93,6 @@ void ___ieee80211_stop_rx_ba_session(struct sta_info *sta=
, u16 tid,
 				     tid, WLAN_BACK_RECIPIENT, reason);
=20
 	del_timer_sync(&tid_rx->session_timer);
-	del_timer_sync(&tid_rx->reorder_timer);
=20
 	call_rcu(&tid_rx->rcu_head, ieee80211_free_tid_rx);
 }
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b581a24..1633648 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -102,9 +102,6 @@ int ieee80211_hw_config(struct ieee80211_local *local, =
u32 changed)
=20
 	might_sleep();
=20
-	/* If this off-channel logic ever changes,  ieee80211_on_oper_channel
-	 * may need to change as well.
-	 */
 	offchannel_flag =3D local->hw.conf.flags & IEEE80211_CONF_OFFCHANNEL;
 	if (local->scan_channel) {
 		chan =3D local->scan_channel;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 4c1eb94..e49da27 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2386,7 +2386,9 @@ nla_put_failure:
 }
=20
 static int nl80211_send_station(struct sk_buff *msg, u32 pid, u32 seq,
-				int flags, struct net_device *dev,
+				int flags,
+				struct cfg80211_registered_device *rdev,
+				struct net_device *dev,
 				const u8 *mac_addr, struct station_info *sinfo)
 {
 	void *hdr;
@@ -2425,12 +2427,18 @@ static int nl80211_send_station(struct sk_buff *msg=
, u32 pid, u32 seq,
 	if (sinfo->filled & STATION_INFO_PLINK_STATE)
 		NLA_PUT_U8(msg, NL80211_STA_INFO_PLINK_STATE,
 			    sinfo->plink_state);
-	if (sinfo->filled & STATION_INFO_SIGNAL)
-		NLA_PUT_U8(msg, NL80211_STA_INFO_SIGNAL,
-			   sinfo->signal);
-	if (sinfo->filled & STATION_INFO_SIGNAL_AVG)
-		NLA_PUT_U8(msg, NL80211_STA_INFO_SIGNAL_AVG,
-			   sinfo->signal_avg);
+	switch (rdev->wiphy.signal_type) {
+	case CFG80211_SIGNAL_TYPE_MBM:
+		if (sinfo->filled & STATION_INFO_SIGNAL)
+			NLA_PUT_U8(msg, NL80211_STA_INFO_SIGNAL,
+				   sinfo->signal);
+		if (sinfo->filled & STATION_INFO_SIGNAL_AVG)
+			NLA_PUT_U8(msg, NL80211_STA_INFO_SIGNAL_AVG,
+				   sinfo->signal_avg);
+		break;
+	default:
+		break;
+	}
 	if (sinfo->filled & STATION_INFO_TX_BITRATE) {
 		if (!nl80211_put_sta_rate(msg, &sinfo->txrate,
 					  NL80211_STA_INFO_TX_BITRATE))
@@ -2523,7 +2531,7 @@ static int nl80211_dump_station(struct sk_buff *skb,
 		if (nl80211_send_station(skb,
 				NETLINK_CB(cb->skb).pid,
 				cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				netdev, mac_addr,
+				dev, netdev, mac_addr,
 				&sinfo) < 0)
 			goto out;
=20
@@ -2568,7 +2576,7 @@ static int nl80211_get_station(struct sk_buff *skb, s=
truct genl_info *info)
 		return -ENOMEM;
=20
 	if (nl80211_send_station(msg, info->snd_pid, info->snd_seq, 0,
-				 dev, mac_addr, &sinfo) < 0) {
+				 rdev, dev, mac_addr, &sinfo) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
 	}
@@ -7596,7 +7604,8 @@ void nl80211_send_sta_event(struct cfg80211_registere=
d_device *rdev,
 	if (!msg)
 		return;
=20
-	if (nl80211_send_station(msg, 0, 0, 0, dev, mac_addr, sinfo) < 0) {
+	if (nl80211_send_station(msg, 0, 0, 0,
+				 rdev, dev, mac_addr, sinfo) < 0) {
 		nlmsg_free(msg);
 		return;
 	}
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPcgfKAAoJEJctW/TcYTgGesAP/2utd0r4gQJvpv3R98JF+PxK
NK9Iooyi1XKuMJMEWc5XZpXcDW9QJCWVXon6DGI9fgFavVGN8QSTiVHLEsbdJD8u
JMZ11iUnWOZ5ol/BTuyIjkRfUwUOFHo97SBMnUeyVzbK0JW/9nKsYSrHPiC5SRGP
IHCJzyPKAwZV1irNg0K5sexLzBOxe+DinureUG21nV2GcXtmY1s95GLgtl9lx4lO
mNko01ylDVNcAEFoc28UFYxzZ8UjwcnwASf3aQvYrjA8zwe6VhEe5QcaAFEllgxT
YAgXJI4pE2kPb9LnDD35bgTxkgY0ws3bct+DgJdQT9Xmnnl6XEeRNyl5ZJ+px2cV
XXovOSXvHr+nKrIRvIiOPoCnkzGEHX9zaS6ksXZmfpcoXKoH5E++YFpCmJ68KZ1+
CxnjM6sLkGYII8Me5mGuIq3UHzGa72KvjS01Qp0xSMFGdz5cHU2hRkAdTpQzTbiU
gGXcevVEBGgTvdrx6ajtXZ6ocbZB3R0amfZbkILeX3w9XZntosb/04E6vqAjttit
fzVJvMFXGnoRKBaZd067xy82Y8bT6z6ZN2p5V1qSFmCtBMgWX75WRQ7kH0XNj9Dk
GG240I7E76zlrIezN/1OSytSFd8Pql+C1w+hrYdvvmWlFd6Dkci4Se+DhuUOcPRI
gtkA6Yt/RT5n40NUxlev
=q4CS
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
