From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-10-15
Date: Tue, 15 Oct 2013 13:56:12 -0400
Message-ID: <20131015175611.GA15706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GvXjxJ+pjyke8COw"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

(Sorry for the repost -- mistyped Dave's email address the first time...)

Dave,

Please pull this batch of fixes intended for the 3.12 stream!

For the mac80211 bits, Johannes says:

"Jouni fixes a remain-on-channel vs. scan bug, and Felix fixes client TX
probing on VLANs."

And also:

"This time I have two fixes from Emmanuel for RF-kill issues, and fixed
two issues reported by Evan Huus and Thomas Lindroth respectively."

On top of those...

Avinash Patil adds a couple of mwifiex fixes to properly inform cfg80211
about some different types of disconnects, avoiding WARNINGs.

Mark Cave-Ayland corrects a pointer arithmetic problem in rtlwifi,
avoiding incorrect automatic gain calculations.

Solomon Peachy sends a cw1200 fix for locking around calls to
cw1200_irq_handler, addressing "lost interrupt" problems.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit e9e4ea74f06635f2ffc1dffe5ef40c854faa0a90:

  net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data (201=
3-10-11 17:50:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 39c253ed7817bf477189a132b114303c9aa2c2d2:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-10-15 13:05:21 -0400)

----------------------------------------------------------------

Avinash Patil (2):
      mwifiex: inform cfg80211 about disconnect if device is removed
      mwifiex: inform cfg80211 about disconnect for P2P client interface

Emmanuel Grumbach (2):
      mac80211: correctly close cancelled scans
      cfg80211: don't add p2p device while in RFKILL

Felix Fietkau (2):
      mac80211: use sta_info_get_bss() for nl80211 tx and client probing
      mac80211: update sta->last_rx on acked tx frames

Johannes Berg (2):
      wireless: radiotap: fix parsing buffer overrun
      mac80211: fix crash if bitrate calculation goes wrong

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jouni Malinen (1):
      mac80211: Run deferred scan if last roc_list item is not started

Mark Cave-Ayland (1):
      rtlwifi: rtl8192cu: Fix error in pointer arithmetic

Solomon Peachy (1):
      wireless: cw1200: acquire hwbus lock around cw1200_irq_handler() call.

 drivers/net/wireless/cw1200/cw1200_spi.c     |  2 ++
 drivers/net/wireless/mwifiex/join.c          | 10 ++++++++--
 drivers/net/wireless/mwifiex/sta_event.c     |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c |  3 ++-
 net/mac80211/cfg.c                           |  2 +-
 net/mac80211/ieee80211_i.h                   |  3 +++
 net/mac80211/offchannel.c                    |  2 ++
 net/mac80211/scan.c                          | 19 +++++++++++++++++++
 net/mac80211/status.c                        |  3 +++
 net/mac80211/tx.c                            |  3 ++-
 net/mac80211/util.c                          |  4 ++++
 net/wireless/core.c                          |  2 --
 net/wireless/core.h                          |  3 +++
 net/wireless/radiotap.c                      |  7 ++++++-
 14 files changed, 57 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/cw1200/cw1200_spi.c b/drivers/net/wireles=
s/cw1200/cw1200_spi.c
index 899cad3..755a0c8 100644
--- a/drivers/net/wireless/cw1200/cw1200_spi.c
+++ b/drivers/net/wireless/cw1200/cw1200_spi.c
@@ -237,7 +237,9 @@ static irqreturn_t cw1200_spi_irq_handler(int irq, void=
 *dev_id)
 	struct hwbus_priv *self =3D dev_id;
=20
 	if (self->core) {
+		cw1200_spi_lock(self);
 		cw1200_irq_handler(self->core);
+		cw1200_spi_unlock(self);
 		return IRQ_HANDLED;
 	} else {
 		return IRQ_NONE;
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwi=
fiex/join.c
index 9d7c0e6..37f873b 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -1422,13 +1422,19 @@ static int mwifiex_deauthenticate_infra(struct mwif=
iex_private *priv, u8 *mac)
  */
 int mwifiex_deauthenticate(struct mwifiex_private *priv, u8 *mac)
 {
+	int ret =3D 0;
+
 	if (!priv->media_connected)
 		return 0;
=20
 	switch (priv->bss_mode) {
 	case NL80211_IFTYPE_STATION:
 	case NL80211_IFTYPE_P2P_CLIENT:
-		return mwifiex_deauthenticate_infra(priv, mac);
+		ret =3D mwifiex_deauthenticate_infra(priv, mac);
+		if (ret)
+			cfg80211_disconnected(priv->netdev, 0, NULL, 0,
+					      GFP_KERNEL);
+		break;
 	case NL80211_IFTYPE_ADHOC:
 		return mwifiex_send_cmd_sync(priv,
 					     HostCmd_CMD_802_11_AD_HOC_STOP,
@@ -1440,7 +1446,7 @@ int mwifiex_deauthenticate(struct mwifiex_private *pr=
iv, u8 *mac)
 		break;
 	}
=20
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(mwifiex_deauthenticate);
=20
diff --git a/drivers/net/wireless/mwifiex/sta_event.c b/drivers/net/wireles=
s/mwifiex/sta_event.c
index 8b05752..8c351f7 100644
--- a/drivers/net/wireless/mwifiex/sta_event.c
+++ b/drivers/net/wireless/mwifiex/sta_event.c
@@ -118,7 +118,8 @@ mwifiex_reset_connect_state(struct mwifiex_private *pri=
v, u16 reason_code)
 	dev_dbg(adapter->dev,
 		"info: successfully disconnected from %pM: reason code %d\n",
 		priv->cfg_bssid, reason_code);
-	if (priv->bss_mode =3D=3D NL80211_IFTYPE_STATION) {
+	if (priv->bss_mode =3D=3D NL80211_IFTYPE_STATION ||
+	    priv->bss_mode =3D=3D NL80211_IFTYPE_P2P_CLIENT) {
 		cfg80211_disconnected(priv->netdev, reason_code, NULL, 0,
 				      GFP_KERNEL);
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/trx.c
index 763cf1d..5a060e5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -343,7 +343,8 @@ bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
 					(bool)GET_RX_DESC_PAGGR(pdesc));
 	rx_status->mactime =3D GET_RX_DESC_TSFL(pdesc);
 	if (phystatus) {
-		p_drvinfo =3D (struct rx_fwinfo_92c *)(pdesc + RTL_RX_DESC_SIZE);
+		p_drvinfo =3D (struct rx_fwinfo_92c *)(skb->data +
+						     stats->rx_bufshift);
 		rtl92c_translate_rx_signal_stuff(hw, skb, stats, pdesc,
 						 p_drvinfo);
 	}
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 2e7855a..629dee7 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -3518,7 +3518,7 @@ static int ieee80211_probe_client(struct wiphy *wiphy=
, struct net_device *dev,
 		return -EINVAL;
 	}
 	band =3D chanctx_conf->def.chan->band;
-	sta =3D sta_info_get(sdata, peer);
+	sta =3D sta_info_get_bss(sdata, peer);
 	if (sta) {
 		qos =3D test_sta_flag(sta, WLAN_STA_WME);
 	} else {
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index b618651..611abfc 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -893,6 +893,8 @@ struct tpt_led_trigger {
  *	that the scan completed.
  * @SCAN_ABORTED: Set for our scan work function when the driver reported
  *	a scan complete for an aborted scan.
+ * @SCAN_HW_CANCELLED: Set for our scan work function when the scan is bei=
ng
+ *	cancelled.
  */
 enum {
 	SCAN_SW_SCANNING,
@@ -900,6 +902,7 @@ enum {
 	SCAN_ONCHANNEL_SCANNING,
 	SCAN_COMPLETED,
 	SCAN_ABORTED,
+	SCAN_HW_CANCELLED,
 };
=20
 /**
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index acd1f71..0c2a294 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -394,6 +394,8 @@ void ieee80211_sw_roc_work(struct work_struct *work)
=20
 		if (started)
 			ieee80211_start_next_roc(local);
+		else if (list_empty(&local->roc_list))
+			ieee80211_run_deferred_scan(local);
 	}
=20
  out_unlock:
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 08afe74..d2d17a4 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -238,6 +238,9 @@ static bool ieee80211_prep_hw_scan(struct ieee80211_loc=
al *local)
 	enum ieee80211_band band;
 	int i, ielen, n_chans;
=20
+	if (test_bit(SCAN_HW_CANCELLED, &local->scanning))
+		return false;
+
 	do {
 		if (local->hw_scan_band =3D=3D IEEE80211_NUM_BANDS)
 			return false;
@@ -940,7 +943,23 @@ void ieee80211_scan_cancel(struct ieee80211_local *loc=
al)
 	if (!local->scan_req)
 		goto out;
=20
+	/*
+	 * We have a scan running and the driver already reported completion,
+	 * but the worker hasn't run yet or is stuck on the mutex - mark it as
+	 * cancelled.
+	 */
+	if (test_bit(SCAN_HW_SCANNING, &local->scanning) &&
+	    test_bit(SCAN_COMPLETED, &local->scanning)) {
+		set_bit(SCAN_HW_CANCELLED, &local->scanning);
+		goto out;
+	}
+
 	if (test_bit(SCAN_HW_SCANNING, &local->scanning)) {
+		/*
+		 * Make sure that __ieee80211_scan_completed doesn't trigger a
+		 * scan on another band.
+		 */
+		set_bit(SCAN_HW_CANCELLED, &local->scanning);
 		if (local->ops->cancel_hw_scan)
 			drv_cancel_hw_scan(local,
 				rcu_dereference_protected(local->scan_sdata,
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 368837f..78dc2e9 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -180,6 +180,9 @@ static void ieee80211_frame_acked(struct sta_info *sta,=
 struct sk_buff *skb)
 	struct ieee80211_local *local =3D sta->local;
 	struct ieee80211_sub_if_data *sdata =3D sta->sdata;
=20
+	if (local->hw.flags & IEEE80211_HW_REPORTS_TX_ACK_STATUS)
+		sta->last_rx =3D jiffies;
+
 	if (ieee80211_is_data_qos(mgmt->frame_control)) {
 		struct ieee80211_hdr *hdr =3D (void *) skb->data;
 		u8 *qc =3D ieee80211_get_qos_ctl(hdr);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 3456c04..70b5a05 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1120,7 +1120,8 @@ ieee80211_tx_prepare(struct ieee80211_sub_if_data *sd=
ata,
 		tx->sta =3D rcu_dereference(sdata->u.vlan.sta);
 		if (!tx->sta && sdata->dev->ieee80211_ptr->use_4addr)
 			return TX_DROP;
-	} else if (info->flags & IEEE80211_TX_CTL_INJECTED ||
+	} else if (info->flags & (IEEE80211_TX_CTL_INJECTED |
+				  IEEE80211_TX_INTFL_NL80211_FRAME_TX) ||
 		   tx->sdata->control_port_protocol =3D=3D tx->skb->protocol) {
 		tx->sta =3D sta_info_get_bss(sdata, hdr->addr1);
 	}
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 9c3200b..69e4ef5 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -2238,6 +2238,10 @@ u64 ieee80211_calculate_rx_timestamp(struct ieee8021=
1_local *local,
 	}
=20
 	rate =3D cfg80211_calculate_bitrate(&ri);
+	if (WARN_ONCE(!rate,
+		      "Invalid bitrate: flags=3D0x%x, idx=3D%d, vht_nss=3D%d\n",
+		      status->flag, status->rate_idx, status->vht_nss))
+		return 0;
=20
 	/* rewind from end of MPDU */
 	if (status->flag & RX_FLAG_MACTIME_END)
diff --git a/net/wireless/core.c b/net/wireless/core.c
index fe8d4f2..aff959e 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -958,8 +958,6 @@ static int cfg80211_netdev_notifier_call(struct notifie=
r_block *nb,
 	case NETDEV_PRE_UP:
 		if (!(wdev->wiphy->interface_modes & BIT(wdev->iftype)))
 			return notifier_from_errno(-EOPNOTSUPP);
-		if (rfkill_blocked(rdev->rfkill))
-			return notifier_from_errno(-ERFKILL);
 		ret =3D cfg80211_can_add_interface(rdev, wdev->iftype);
 		if (ret)
 			return notifier_from_errno(ret);
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 9ad43c6..3159e9c 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -411,6 +411,9 @@ static inline int
 cfg80211_can_add_interface(struct cfg80211_registered_device *rdev,
 			   enum nl80211_iftype iftype)
 {
+	if (rfkill_blocked(rdev->rfkill))
+		return -ERFKILL;
+
 	return cfg80211_can_change_interface(rdev, NULL, iftype);
 }
=20
diff --git a/net/wireless/radiotap.c b/net/wireless/radiotap.c
index 7d604c0..a271c27 100644
--- a/net/wireless/radiotap.c
+++ b/net/wireless/radiotap.c
@@ -97,6 +97,10 @@ int ieee80211_radiotap_iterator_init(
 	struct ieee80211_radiotap_header *radiotap_header,
 	int max_length, const struct ieee80211_radiotap_vendor_namespaces *vns)
 {
+	/* check the radiotap header can actually be present */
+	if (max_length < sizeof(struct ieee80211_radiotap_header))
+		return -EINVAL;
+
 	/* Linux only supports version 0 radiotap format */
 	if (radiotap_header->it_version)
 		return -EINVAL;
@@ -131,7 +135,8 @@ int ieee80211_radiotap_iterator_init(
 			 */
=20
 			if ((unsigned long)iterator->_arg -
-			    (unsigned long)iterator->_rtheader >
+			    (unsigned long)iterator->_rtheader +
+			    sizeof(uint32_t) >
 			    (unsigned long)iterator->_max_length)
 				return -EINVAL;
 		}
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSXYG7AAoJEJctW/TcYTgGyWYP+gIysc6DObzT14G2hD8TSXyR
ARecFTl6aV385JkLUrXOSvcla9cNXdwm/aXpn1hwcRS79VVvo4yzvbLoT+a2XX07
z/MDIhI8mhjALevoEgexyQSXTMzrEsMZ/OkfmoBlJpWNcuqL0rIi4ljrvhhZEi8r
aVJI4GG5sdedZCW511YfwmEkyDnV1kdka6DxLtb7in/Xe2h4rpYGyH6meOIK9dAw
2ePd6cKbMfvu9VlhVbTh+IcynMYZaVzkOHJVEi6CNEBggj6PuA2LoqtQ5Hpqozib
8JqbhXPBKRJRsENkWoRYojrO+Uxftm2iHr06fRKiieWrUpvXO1ig3DRceZR+UDu5
RXqlkMlUAr6R3pS8OOl4j23asMOSxIUTNnudBRA97c5ZajpDSOiZSKfV4Mv9ONtB
Nh5RwApm/ZfwTl+GKZ8bp08pFYOoRVZxuwcQZGXPDCqxo4IFhrM3BU6LckR0Spfp
b6o8l4+4hIb3ci9dq8bNZzuO+a613JUPnUM9g5buZ5ffXs8t9n0VyVq7TtjfkWLc
TNkwpsCgw3pkYQUbTKTuYIp2weDFyBvWlDzg59Zdg1kQaDvd+AP+JikjbHqeTmnb
2d+T1TlB2IK96YgvxE5yVKBPssg7f+fpnj/8P51K1FrhikecLjEorzsauPhQxB23
TQHcXJZ5RjBalO6WlXXM
=mr2Y
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--
