From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-06-18
Date: Mon, 18 Jun 2012 15:59:48 -0400
Message-ID: <20120618195947.GA30590@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 8cfe523a1294da65ef95b6ed7b0f7db5629f8d88

Dave,

This is a batch of fixes intended for 3.5...

This includes pulls from the mac80211 and bluetooth trees -- soon
I'll be completely irrelevant!

Says Johannes:

	I've included David's fix for leaving a scan request dangling if we
	abort a connection while polling it, a few kernel-doc fixes, Michal's
	fix to interface validation and two fixes from Eliad, one to avoid a
	possible deadlock and one to not call the driver unexpectedly.

Says Gustavo:

	A few fixes to 3.5. The issues fixed by these patches were
	found at the last UPS testing session. They fix several bugs
	with LE devices.

The bluetooth batch adds an event handler that is a little bigger
than I'd like to see in a fix, but it seems reasonably safe and
self-contained.

Along with the fixes from those trees, this includes a few driver
fixes:

	-- an mwifiex fix from Avinash Patil to ensure that privacy
	settings are set correctly in AP mode;

	-- an rndis_wlan fix from Jussi Kivilinna for a reversed
	'matching bssid' check;

	-- an ath9k fix from Mohammed Shafi Shajakhan for a WARNING
	observable during suspend/resume;

	-- another ath9k fix to remove an obsolete and problematic
	check of interface types, ibid.;

	-- another ath9k fix to prevent a soft lockup on AR9485
	devices, ibid.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 31fdc5553b42abd7e29bb7b89f6ba07514eb4763:

  net: remove my future former mail address (2012-06-17 16:29:38 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Ashok Nagarajan (1):
      mac80211: add missing kernel-doc

Avinash Patil (1):
      mwifiex: fix incorrect privacy setting in beacon and probe response

David Spinadel (1):
      mac80211: stop polling in disassociation

Eliad Peller (2):
      cfg80211: fix potential deadlock in regulatory
      mac80211: check sdata_running on ieee80211_set_bitrate_mask

Johan Hedberg (4):
      Bluetooth: Fix SMP pairing method selection
      Bluetooth: Fix deadlock and crash when SMP pairing times out
      Bluetooth: Fix SMP security elevation from medium to high
      Bluetooth: Add support for encryption key refresh

Johannes Berg (1):
      mac80211: add some missing kernel-doc

John W. Linville (3):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jussi Kivilinna (1):
      rndis_wlan: fix matching bssid check in rndis_check_bssid_list()

Michal Kazior (1):
      cfg80211: check iface combinations only when iface is running

Mohammed Shafi Shajakhan (3):
      ath9k: Fix a WARNING on suspend/resume with IBSS
      ath9k: remove incompatible IBSS interface check in change_iface
      ath9k: Fix softlockup in AR9485

Vishal Agarwal (1):
      Bluetooth: Fix LE pairing completion on connection failure

 drivers/net/wireless/ath/ath9k/main.c  |   27 ++++++------------
 drivers/net/wireless/mwifiex/uap_cmd.c |   11 +++++++
 drivers/net/wireless/rndis_wlan.c      |    2 +-
 include/net/bluetooth/hci.h            |    6 ++++
 include/net/mac80211.h                 |    6 ++++
 net/bluetooth/hci_event.c              |   48 ++++++++++++++++++++++++++++=
++++
 net/bluetooth/l2cap_core.c             |    7 ++++-
 net/bluetooth/mgmt.c                   |   18 ++++++++++++
 net/bluetooth/smp.c                    |   11 ++++--
 net/mac80211/cfg.c                     |    3 ++
 net/mac80211/mlme.c                    |    4 +-
 net/mac80211/sta_info.h                |    5 +++
 net/wireless/reg.c                     |    2 +-
 net/wireless/util.c                    |    2 +-
 14 files changed, 124 insertions(+), 28 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 4de4473..dac1a27 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -971,6 +971,15 @@ void ath_hw_pll_work(struct work_struct *work)
 					    hw_pll_work.work);
 	u32 pll_sqsum;
=20
+	/*
+	 * ensure that the PLL WAR is executed only
+	 * after the STA is associated (or) if the
+	 * beaconing had started in interfaces that
+	 * uses beacons.
+	 */
+	if (!(sc->sc_flags & SC_OP_BEACONS))
+		return;
+
 	if (AR_SREV_9485(sc->sc_ah)) {
=20
 		ath9k_ps_wakeup(sc);
@@ -1443,15 +1452,6 @@ static int ath9k_add_interface(struct ieee80211_hw *=
hw,
 		}
 	}
=20
-	if ((ah->opmode =3D=3D NL80211_IFTYPE_ADHOC) ||
-	    ((vif->type =3D=3D NL80211_IFTYPE_ADHOC) &&
-	     sc->nvifs > 0)) {
-		ath_err(common, "Cannot create ADHOC interface when other"
-			" interfaces already exist.\n");
-		ret =3D -EINVAL;
-		goto out;
-	}
-
 	ath_dbg(common, CONFIG, "Attach a VIF of type: %d\n", vif->type);
=20
 	sc->nvifs++;
@@ -1476,15 +1476,6 @@ static int ath9k_change_interface(struct ieee80211_h=
w *hw,
 	mutex_lock(&sc->mutex);
 	ath9k_ps_wakeup(sc);
=20
-	/* See if new interface type is valid. */
-	if ((new_type =3D=3D NL80211_IFTYPE_ADHOC) &&
-	    (sc->nvifs > 1)) {
-		ath_err(common, "When using ADHOC, it must be the only"
-			" interface.\n");
-		ret =3D -EINVAL;
-		goto out;
-	}
-
 	if (ath9k_uses_beacons(new_type) &&
 	    !ath9k_uses_beacons(vif->type)) {
 		if (sc->nbcnvifs >=3D ATH_BCBUF) {
diff --git a/drivers/net/wireless/mwifiex/uap_cmd.c b/drivers/net/wireless/=
mwifiex/uap_cmd.c
index 8173ab6..89f9a2a 100644
--- a/drivers/net/wireless/mwifiex/uap_cmd.c
+++ b/drivers/net/wireless/mwifiex/uap_cmd.c
@@ -27,6 +27,17 @@ int mwifiex_set_secure_params(struct mwifiex_private *pr=
iv,
 			      struct cfg80211_ap_settings *params) {
 	int i;
=20
+	if (!params->privacy) {
+		bss_config->protocol =3D PROTOCOL_NO_SECURITY;
+		bss_config->key_mgmt =3D KEY_MGMT_NONE;
+		bss_config->wpa_cfg.length =3D 0;
+		priv->sec_info.wep_enabled =3D 0;
+		priv->sec_info.wpa_enabled =3D 0;
+		priv->sec_info.wpa2_enabled =3D 0;
+
+		return 0;
+	}
+
 	switch (params->auth_type) {
 	case NL80211_AUTHTYPE_OPEN_SYSTEM:
 		bss_config->auth_mode =3D WLAN_AUTH_OPEN;
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis=
_wlan.c
index 2e9e6af..dfcd02a 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2110,7 +2110,7 @@ resize_buf:
 	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
 		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
 		    matched) {
-			if (!ether_addr_equal(bssid->mac, match_bssid))
+			if (ether_addr_equal(bssid->mac, match_bssid))
 				*matched =3D true;
 		}
=20
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index 66a7b57..3def64b 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -1144,6 +1144,12 @@ struct extended_inquiry_info {
 	__u8     data[240];
 } __packed;
=20
+#define HCI_EV_KEY_REFRESH_COMPLETE	0x30
+struct hci_ev_key_refresh_complete {
+	__u8	status;
+	__le16	handle;
+} __packed;
+
 #define HCI_EV_IO_CAPA_REQUEST		0x31
 struct hci_ev_io_capa_request {
 	bdaddr_t bdaddr;
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 1937c7d..95e39b6 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1940,6 +1940,11 @@ enum ieee80211_rate_control_changed {
  *	to also unregister the device. If it returns 1, then mac80211
  *	will also go through the regular complete restart on resume.
  *
+ * @set_wakeup: Enable or disable wakeup when WoWLAN configuration is
+ *	modified. The reason is that device_set_wakeup_enable() is
+ *	supposed to be called when the configuration changes, not only
+ *	in suspend().
+ *
  * @add_interface: Called when a netdevice attached to the hardware is
  *	enabled. Because it is not called for monitor mode devices, @start
  *	and @stop must be implemented.
@@ -2966,6 +2971,7 @@ __le16 ieee80211_ctstoself_duration(struct ieee80211_=
hw *hw,
  * ieee80211_generic_frame_duration - Calculate the duration field for a f=
rame
  * @hw: pointer obtained from ieee80211_alloc_hw().
  * @vif: &struct ieee80211_vif pointer from the add_interface callback.
+ * @band: the band to calculate the frame duration on
  * @frame_len: the length of the frame.
  * @rate: the rate at which the frame is going to be transmitted.
  *
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 4eefb7f..94ad124 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -3043,6 +3043,50 @@ static inline void hci_extended_inquiry_result_evt(s=
truct hci_dev *hdev, struct
 	hci_dev_unlock(hdev);
 }
=20
+static void hci_key_refresh_complete_evt(struct hci_dev *hdev,
+					 struct sk_buff *skb)
+{
+	struct hci_ev_key_refresh_complete *ev =3D (void *) skb->data;
+	struct hci_conn *conn;
+
+	BT_DBG("%s status %u handle %u", hdev->name, ev->status,
+	       __le16_to_cpu(ev->handle));
+
+	hci_dev_lock(hdev);
+
+	conn =3D hci_conn_hash_lookup_handle(hdev, __le16_to_cpu(ev->handle));
+	if (!conn)
+		goto unlock;
+
+	if (!ev->status)
+		conn->sec_level =3D conn->pending_sec_level;
+
+	clear_bit(HCI_CONN_ENCRYPT_PEND, &conn->flags);
+
+	if (ev->status && conn->state =3D=3D BT_CONNECTED) {
+		hci_acl_disconn(conn, HCI_ERROR_AUTH_FAILURE);
+		hci_conn_put(conn);
+		goto unlock;
+	}
+
+	if (conn->state =3D=3D BT_CONFIG) {
+		if (!ev->status)
+			conn->state =3D BT_CONNECTED;
+
+		hci_proto_connect_cfm(conn, ev->status);
+		hci_conn_put(conn);
+	} else {
+		hci_auth_cfm(conn, ev->status);
+
+		hci_conn_hold(conn);
+		conn->disc_timeout =3D HCI_DISCONN_TIMEOUT;
+		hci_conn_put(conn);
+	}
+
+unlock:
+	hci_dev_unlock(hdev);
+}
+
 static inline u8 hci_get_auth_req(struct hci_conn *conn)
 {
 	/* If remote requests dedicated bonding follow that lead */
@@ -3559,6 +3603,10 @@ void hci_event_packet(struct hci_dev *hdev, struct s=
k_buff *skb)
 		hci_extended_inquiry_result_evt(hdev, skb);
 		break;
=20
+	case HCI_EV_KEY_REFRESH_COMPLETE:
+		hci_key_refresh_complete_evt(hdev, skb);
+		break;
+
 	case HCI_EV_IO_CAPA_REQUEST:
 		hci_io_capa_request_evt(hdev, skb);
 		break;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 24f144b..8394e36 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1295,7 +1295,12 @@ static void security_timeout(struct work_struct *wor=
k)
 	struct l2cap_conn *conn =3D container_of(work, struct l2cap_conn,
 						security_timer.work);
=20
-	l2cap_conn_del(conn->hcon, ETIMEDOUT);
+	BT_DBG("conn %p", conn);
+
+	if (test_and_clear_bit(HCI_CONN_LE_SMP_PEND, &conn->hcon->flags)) {
+		smp_chan_destroy(conn);
+		l2cap_conn_del(conn->hcon, ETIMEDOUT);
+	}
 }
=20
 static struct l2cap_conn *l2cap_conn_add(struct hci_conn *hcon, u8 status)
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 25d2207..991d5b6 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -1873,6 +1873,22 @@ static void pairing_complete_cb(struct hci_conn *con=
n, u8 status)
 		pairing_complete(cmd, mgmt_status(status));
 }
=20
+static void le_connect_complete_cb(struct hci_conn *conn, u8 status)
+{
+	struct pending_cmd *cmd;
+
+	BT_DBG("status %u", status);
+
+	if (!status)
+		return;
+
+	cmd =3D find_pairing(conn);
+	if (!cmd)
+		BT_DBG("Unable to find a pending command");
+	else
+		pairing_complete(cmd, mgmt_status(status));
+}
+
 static int pair_device(struct sock *sk, struct hci_dev *hdev, void *data,
 		       u16 len)
 {
@@ -1934,6 +1950,8 @@ static int pair_device(struct sock *sk, struct hci_de=
v *hdev, void *data,
 	/* For LE, just connecting isn't a proof that the pairing finished */
 	if (cp->addr.type =3D=3D BDADDR_BREDR)
 		conn->connect_cfm_cb =3D pairing_complete_cb;
+	else
+		conn->connect_cfm_cb =3D le_connect_complete_cb;
=20
 	conn->security_cfm_cb =3D pairing_complete_cb;
 	conn->disconn_cfm_cb =3D pairing_complete_cb;
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 6fc7c47..37df4e9 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -648,7 +648,7 @@ static u8 smp_cmd_pairing_rsp(struct l2cap_conn *conn, =
struct sk_buff *skb)
=20
 	auth |=3D (req->auth_req | rsp->auth_req) & SMP_AUTH_MITM;
=20
-	ret =3D tk_request(conn, 0, auth, rsp->io_capability, req->io_capability);
+	ret =3D tk_request(conn, 0, auth, req->io_capability, rsp->io_capability);
 	if (ret)
 		return SMP_UNSPECIFIED;
=20
@@ -703,7 +703,7 @@ static u8 smp_cmd_pairing_random(struct l2cap_conn *con=
n, struct sk_buff *skb)
 	return 0;
 }
=20
-static u8 smp_ltk_encrypt(struct l2cap_conn *conn)
+static u8 smp_ltk_encrypt(struct l2cap_conn *conn, u8 sec_level)
 {
 	struct smp_ltk *key;
 	struct hci_conn *hcon =3D conn->hcon;
@@ -712,6 +712,9 @@ static u8 smp_ltk_encrypt(struct l2cap_conn *conn)
 	if (!key)
 		return 0;
=20
+	if (sec_level > BT_SECURITY_MEDIUM && !key->authenticated)
+		return 0;
+
 	if (test_and_set_bit(HCI_CONN_ENCRYPT_PEND, &hcon->flags))
 		return 1;
=20
@@ -732,7 +735,7 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn,=
 struct sk_buff *skb)
=20
 	hcon->pending_sec_level =3D authreq_to_seclevel(rp->auth_req);
=20
-	if (smp_ltk_encrypt(conn))
+	if (smp_ltk_encrypt(conn, hcon->pending_sec_level))
 		return 0;
=20
 	if (test_and_set_bit(HCI_CONN_LE_SMP_PEND, &hcon->flags))
@@ -771,7 +774,7 @@ int smp_conn_security(struct l2cap_conn *conn, __u8 sec=
_level)
 		return 1;
=20
 	if (hcon->link_mode & HCI_LM_MASTER)
-		if (smp_ltk_encrypt(conn))
+		if (smp_ltk_encrypt(conn, sec_level))
 			goto done;
=20
 	if (test_and_set_bit(HCI_CONN_LE_SMP_PEND, &hcon->flags))
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index e9cecca..7d5108a 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2093,6 +2093,9 @@ static int ieee80211_set_bitrate_mask(struct wiphy *w=
iphy,
 	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
 	int i, ret;
=20
+	if (!ieee80211_sdata_running(sdata))
+		return -ENETDOWN;
+
 	if (local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL) {
 		ret =3D drv_set_bitrate_mask(local, sdata, mask);
 		if (ret)
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 91d84cc..66e4fcd 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1352,6 +1352,8 @@ static void ieee80211_set_disassoc(struct ieee80211_s=
ub_if_data *sdata,
 	if (WARN_ON(!ifmgd->associated))
 		return;
=20
+	ieee80211_stop_poll(sdata);
+
 	memcpy(bssid, ifmgd->associated->bssid, ETH_ALEN);
=20
 	ifmgd->associated =3D NULL;
@@ -2612,8 +2614,6 @@ static void ieee80211_sta_connection_lost(struct ieee=
80211_sub_if_data *sdata,
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
 	u8 frame_buf[DEAUTH_DISASSOC_LEN];
=20
-	ieee80211_stop_poll(sdata);
-
 	ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DEAUTH, reason,
 			       false, frame_buf);
 	mutex_unlock(&ifmgd->mtx);
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 3bb24a1..a470e11 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -271,6 +271,9 @@ struct sta_ampdu_mlme {
  * @plink_timer: peer link watch timer
  * @plink_timer_was_running: used by suspend/resume to restore timers
  * @t_offset: timing offset relative to this host
+ * @t_offset_setpoint: reference timing offset of this sta to be used when
+ * 	calculating clockdrift
+ * @ch_type: peer's channel type
  * @debugfs: debug filesystem info
  * @dead: set to true when sta is unlinked
  * @uploaded: set to true when sta is uploaded to the driver
@@ -278,6 +281,8 @@ struct sta_ampdu_mlme {
  * @sta: station information we share with the driver
  * @sta_state: duplicates information about station state (for debug)
  * @beacon_loss_count: number of times beacon loss has triggered
+ * @supports_40mhz: tracks whether the station advertised 40 MHz support
+ *	as we overwrite its HT parameters with the currently used value
  */
 struct sta_info {
 	/* General information, mostly static */
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 15f3474..baf5704 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1389,7 +1389,7 @@ static void reg_set_request_processed(void)
 	spin_unlock(&reg_requests_lock);
=20
 	if (last_request->initiator =3D=3D NL80211_REGDOM_SET_BY_USER)
-		cancel_delayed_work_sync(&reg_timeout);
+		cancel_delayed_work(&reg_timeout);
=20
 	if (need_more_processing)
 		schedule_work(&reg_work);
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 8f2d68f..316cfd0 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -804,7 +804,7 @@ int cfg80211_change_iface(struct cfg80211_registered_de=
vice *rdev,
 	     ntype =3D=3D NL80211_IFTYPE_P2P_CLIENT))
 		return -EBUSY;
=20
-	if (ntype !=3D otype) {
+	if (ntype !=3D otype && netif_running(dev)) {
 		err =3D cfg80211_can_change_interface(rdev, dev->ieee80211_ptr,
 						    ntype);
 		if (err)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP34izAAoJEJctW/TcYTgG0hIP/2DRt3UGr20hsR9pH0W/ftCK
ckSI0nArpLp19MCPq7YrCTgfAQBY82m/mph0Cz8B9nLYNpxyReXrXdqNTFbpl50L
JuVmdZhNziAP5/RvMo2PenYhoGWyvnkrPDEbrdfnUL5T/Pq0oTHeiNbPopBQhHyl
KwCIKYLGewyr/NzIVeOb7xg6EdH6mAAi/eTDO+Fjy9pEd22XCvVaJAS894howTJS
PWe+PnPTAdNmNXO3+Mc+BJt3wtsgNp133g8g0eAcBhu8QfmLrXKVz1Op0htapstp
+JLYa2ySY2N39efnNHW9wZvjly0cOnZd22hnRHsGDAHrED7+qV3rFZM5CmHQy1GO
VZNMUGuWicTdVvfHbjnABchfrpgNFlrqHUJ4d6rv+tWJDusCBg1o+YuH3FkG37Ty
tHnOWJvkSP3fYyDFjgyChGHGcKLc4TJ9JwBCZYSKPKGREZ19Xd94xzGf92oQvsMF
cq3+Fx+TRGHvi8irk1I7ymfMtOZzpv75FbcWbh7GYJakfmaNjTZot0d5sj1e/0tC
OPirHeEFwC5vIhfUUR4QymqD070cDAacwOeLXHyYDHLFHicmedxouVeX8y0LNk0D
wra3fnGEG4g18/ykgVmrh8yGtht43YpIQRdsjdqGCadZqU2NX1qbUgS0l3YUtpks
jV1cxxaXIif6hMAMH+7n
=GYVp
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
