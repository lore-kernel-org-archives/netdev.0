From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-02-20
Date: Mon, 20 Feb 2012 15:37:40 -0500
Message-ID: <20120220203740.GD6740@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 9d4990a260ce395493848640bed94fb55f440f10

Dave,

Here is another batch of fixes intended for 3.3.  Most of the fixes
this time are for Bluetooth.

Quoth Johan Hedberg <johan.hedberg@gmail.com>:

"Here's one (hopefully) last set of important Bluetooth fixes intended
for 3.3:

- One important SSP fix which fixes security level upgrade handling
  (this was breaking connections with many devices).
- An update to btusb fixing invalid flag usage with usb_submit_urb() as
  well as one new vendor ID for a Broadcom device.
- One compilation warning fix for a bogus inline declaration
- Fix proper timeout value for l2cap_set_timer and sk_sndtimeo and
  hci_conn_put
- Fix a lockdep warning with Bluetooth sockets
- Deadlock fix in hci_conn_hold
- RFCOMM reference counting fix
- QUIRK_NO_RESET fix which was breaking suspend with some laptops
- Two fixes related to synchronization with cancel_delayed_work()"

Along with the Bluetooth fixes, we have a handful of wireless LAN
fixes.  First is an mwifiex fix from Amitkumar Karwar that does
proper initializations to ensure that associations can occur in
all conditions.  Next is a mac80211 fix from Felix Fietkau to add a
check to rate_control_tx_status that avoids a crash in minstrel_ht.
This pairs with a mac80211 fix from Johannes Berg to ensure that
mac80211 rate control is initialized properly before being called.
Finally, we have an ath9k fix from Pavel Roskin to ensure that ath9k's
rate control processes rate control information in Tx status reports
properly.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 64f0a836f600e9c31ffd511713ab5d328aa96ac8:

  b44: remove __exit from b44_pci_exit() (2012-02-19 18:57:51 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Amitkumar Karwar (1):
      mwifiex: clear previous security setting during association

Andre Guedes (1):
      Bluetooth: Fix potential deadlock

Andrzej Kaczmarek (2):
      Bluetooth: Fix sk_sndtimeo initialization for L2CAP socket
      Bluetooth: l2cap_set_timer needs jiffies as timeout value

Daniel Wagner (1):
      Bluetooth: Don't mark non xfer isoc endpoint URBs with URB_ISO_ASAP

Felix Fietkau (1):
      mac80211: do not call rate control .tx_status before .rate_init

Johan Hedberg (2):
      Bluetooth: Remove bogus inline declaration from l2cap_chan_connect
      Bluetooth: Add missing QUIRK_NO_RESET test to hci_dev_do_close

Johannes Berg (1):
      mac80211: call rate control only after init

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0a5c 21f3) for BCM20702A0

Octavian Purdila (2):
      Bluetooth: silence lockdep warning
      Bluetooth: Fix RFCOMM session reference counting issue

Pavel Roskin (1):
      ath9k: stop on rates with idx -1 in ath9k rate control's .tx_status

Peter Hurley (1):
      Bluetooth: Fix l2cap conn failures for ssp devices

Ulisses Furquim (2):
      Bluetooth: Remove usage of __cancel_delayed_work()
      Bluetooth: Fix possible use after free in delete path

Vinicius Costa Gomes (1):
      Bluetooth: Fix using an absolute timeout on hci_conn_put()

 drivers/bluetooth/btusb.c               |    4 +---
 drivers/net/wireless/ath/ath9k/rc.c     |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c |    8 +++++++-
 include/net/bluetooth/bluetooth.h       |    2 ++
 include/net/bluetooth/hci_core.h        |    6 +++---
 include/net/bluetooth/l2cap.h           |   12 ++++++------
 net/bluetooth/af_bluetooth.c            |   12 +++++-------
 net/bluetooth/hci_conn.c                |    4 ++++
 net/bluetooth/hci_core.c                |    3 ++-
 net/bluetooth/l2cap_core.c              |   24 ++++++++++++++----------
 net/bluetooth/l2cap_sock.c              |    4 +++-
 net/bluetooth/rfcomm/core.c             |   18 ++++++++++++------
 net/bluetooth/rfcomm/sock.c             |    2 ++
 net/mac80211/debugfs_sta.c              |    4 ++--
 net/mac80211/rate.c                     |    2 +-
 net/mac80211/rate.h                     |    3 ++-
 net/mac80211/sta_info.h                 |    2 ++
 17 files changed, 69 insertions(+), 43 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index f00f596..789c9b5 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -102,6 +102,7 @@ static struct usb_device_id btusb_table[] =3D {
=20
 	/* Broadcom BCM20702A0 */
 	{ USB_DEVICE(0x0a5c, 0x21e3) },
+	{ USB_DEVICE(0x0a5c, 0x21f3) },
 	{ USB_DEVICE(0x413c, 0x8197) },
=20
 	{ }	/* Terminating entry */
@@ -726,9 +727,6 @@ static int btusb_send_frame(struct sk_buff *skb)
 		usb_fill_bulk_urb(urb, data->udev, pipe,
 				skb->data, skb->len, btusb_tx_complete, skb);
=20
-		if (skb->priority >=3D HCI_PRIO_MAX - 1)
-			urb->transfer_flags  =3D URB_ISO_ASAP;
-
 		hdev->stat.acl_tx++;
 		break;
=20
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath=
/ath9k/rc.c
index 635b592..a427a16 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1346,7 +1346,7 @@ static void ath_tx_status(void *priv, struct ieee8021=
1_supported_band *sband,
 	fc =3D hdr->frame_control;
 	for (i =3D 0; i < sc->hw->max_rates; i++) {
 		struct ieee80211_tx_rate *rate =3D &tx_info->status.rates[i];
-		if (!rate->count)
+		if (rate->idx < 0 || !rate->count)
 			break;
=20
 		final_ts_idx =3D i;
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index c3b6c46..5b2972b 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -841,7 +841,12 @@ mwifiex_cfg80211_assoc(struct mwifiex_private *priv, s=
ize_t ssid_len, u8 *ssid,
 		ret =3D mwifiex_set_rf_channel(priv, channel,
 						priv->adapter->channel_type);
=20
-	ret =3D mwifiex_set_encode(priv, NULL, 0, 0, 1);	/* Disable keys */
+	/* As this is new association, clear locally stored
+	 * keys and security related flags */
+	priv->sec_info.wpa_enabled =3D false;
+	priv->sec_info.wpa2_enabled =3D false;
+	priv->wep_key_curr_index =3D 0;
+	ret =3D mwifiex_set_encode(priv, NULL, 0, 0, 1);
=20
 	if (mode =3D=3D NL80211_IFTYPE_ADHOC) {
 		/* "privacy" is set only for ad-hoc mode */
@@ -886,6 +891,7 @@ mwifiex_cfg80211_assoc(struct mwifiex_private *priv, si=
ze_t ssid_len, u8 *ssid,
 			dev_dbg(priv->adapter->dev,
 				"info: setting wep encryption"
 				" with key len %d\n", sme->key_len);
+			priv->wep_key_curr_index =3D sme->key_idx;
 			ret =3D mwifiex_set_encode(priv, sme->key, sme->key_len,
 							sme->key_idx, 0);
 		}
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/blue=
tooth.h
index abaad6e..4a82ca0 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -256,4 +256,6 @@ void l2cap_exit(void);
 int sco_init(void);
 void sco_exit(void);
=20
+void bt_sock_reclassify_lock(struct sock *sk, int proto);
+
 #endif /* __BLUETOOTH_H */
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index ea9231f..453893b 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -540,7 +540,7 @@ void hci_conn_put_device(struct hci_conn *conn);
 static inline void hci_conn_hold(struct hci_conn *conn)
 {
 	atomic_inc(&conn->refcnt);
-	cancel_delayed_work_sync(&conn->disc_work);
+	cancel_delayed_work(&conn->disc_work);
 }
=20
 static inline void hci_conn_put(struct hci_conn *conn)
@@ -559,9 +559,9 @@ static inline void hci_conn_put(struct hci_conn *conn)
 		} else {
 			timeo =3D msecs_to_jiffies(10);
 		}
-		cancel_delayed_work_sync(&conn->disc_work);
+		cancel_delayed_work(&conn->disc_work);
 		queue_delayed_work(conn->hdev->workqueue,
-					&conn->disc_work, jiffies + timeo);
+					&conn->disc_work, timeo);
 	}
 }
=20
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 68f5891..b1664ed 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -611,7 +611,7 @@ static inline void l2cap_set_timer(struct l2cap_chan *c=
han,
 {
 	BT_DBG("chan %p state %d timeout %ld", chan, chan->state, timeout);
=20
-	if (!__cancel_delayed_work(work))
+	if (!cancel_delayed_work(work))
 		l2cap_chan_hold(chan);
 	schedule_delayed_work(work, timeout);
 }
@@ -619,20 +619,20 @@ static inline void l2cap_set_timer(struct l2cap_chan =
*chan,
 static inline void l2cap_clear_timer(struct l2cap_chan *chan,
 					struct delayed_work *work)
 {
-	if (__cancel_delayed_work(work))
+	if (cancel_delayed_work(work))
 		l2cap_chan_put(chan);
 }
=20
 #define __set_chan_timer(c, t) l2cap_set_timer(c, &c->chan_timer, (t))
 #define __clear_chan_timer(c) l2cap_clear_timer(c, &c->chan_timer)
 #define __set_retrans_timer(c) l2cap_set_timer(c, &c->retrans_timer, \
-		L2CAP_DEFAULT_RETRANS_TO);
+		msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
 #define __clear_retrans_timer(c) l2cap_clear_timer(c, &c->retrans_timer)
 #define __set_monitor_timer(c) l2cap_set_timer(c, &c->monitor_timer, \
-		L2CAP_DEFAULT_MONITOR_TO);
+		msecs_to_jiffies(L2CAP_DEFAULT_MONITOR_TO));
 #define __clear_monitor_timer(c) l2cap_clear_timer(c, &c->monitor_timer)
 #define __set_ack_timer(c) l2cap_set_timer(c, &chan->ack_timer, \
-		L2CAP_DEFAULT_ACK_TO);
+		msecs_to_jiffies(L2CAP_DEFAULT_ACK_TO));
 #define __clear_ack_timer(c) l2cap_clear_timer(c, &c->ack_timer)
=20
 static inline int __seq_offset(struct l2cap_chan *chan, __u16 seq1, __u16 =
seq2)
@@ -834,7 +834,7 @@ int l2cap_add_scid(struct l2cap_chan *chan,  __u16 scid=
);
 struct l2cap_chan *l2cap_chan_create(struct sock *sk);
 void l2cap_chan_close(struct l2cap_chan *chan, int reason);
 void l2cap_chan_destroy(struct l2cap_chan *chan);
-inline int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid,
+int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid,
 								bdaddr_t *dst);
 int l2cap_chan_send(struct l2cap_chan *chan, struct msghdr *msg, size_t le=
n,
 								u32 priority);
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index ef92864..72eb187 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -71,19 +71,16 @@ static const char *const bt_slock_key_strings[BT_MAX_PR=
OTO] =3D {
 	"slock-AF_BLUETOOTH-BTPROTO_AVDTP",
 };
=20
-static inline void bt_sock_reclassify_lock(struct socket *sock, int proto)
+void bt_sock_reclassify_lock(struct sock *sk, int proto)
 {
-	struct sock *sk =3D sock->sk;
-
-	if (!sk)
-		return;
-
+	BUG_ON(!sk);
 	BUG_ON(sock_owned_by_user(sk));
=20
 	sock_lock_init_class_and_name(sk,
 			bt_slock_key_strings[proto], &bt_slock_key[proto],
 				bt_key_strings[proto], &bt_lock_key[proto]);
 }
+EXPORT_SYMBOL(bt_sock_reclassify_lock);
=20
 int bt_sock_register(int proto, const struct net_proto_family *ops)
 {
@@ -145,7 +142,8 @@ static int bt_sock_create(struct net *net, struct socke=
t *sock, int proto,
=20
 	if (bt_proto[proto] && try_module_get(bt_proto[proto]->owner)) {
 		err =3D bt_proto[proto]->create(net, sock, proto, kern);
-		bt_sock_reclassify_lock(sock, proto);
+		if (!err)
+			bt_sock_reclassify_lock(sock->sk, proto);
 		module_put(bt_proto[proto]->owner);
 	}
=20
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 3db4324..07bc69e 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -635,6 +635,10 @@ static int hci_conn_auth(struct hci_conn *conn, __u8 s=
ec_level, __u8 auth_type)
=20
 	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
 		struct hci_cp_auth_requested cp;
+
+		/* encrypt must be pending if auth is also pending */
+		set_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend);
+
 		cp.handle =3D cpu_to_le16(conn->handle);
 		hci_send_cmd(conn->hdev, HCI_OP_AUTH_REQUESTED,
 							sizeof(cp), &cp);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 9de9371..5aeb624 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -640,7 +640,8 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	/* Reset device */
 	skb_queue_purge(&hdev->cmd_q);
 	atomic_set(&hdev->cmd_cnt, 1);
-	if (!test_bit(HCI_RAW, &hdev->flags)) {
+	if (!test_bit(HCI_RAW, &hdev->flags) &&
+				test_bit(HCI_QUIRK_NO_RESET, &hdev->quirks)) {
 		set_bit(HCI_INIT, &hdev->flags);
 		__hci_request(hdev, hci_reset_req, 0,
 					msecs_to_jiffies(250));
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index faf0b11..32d338c 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1018,10 +1018,10 @@ static void l2cap_conn_del(struct hci_conn *hcon, i=
nt err)
 	hci_chan_del(conn->hchan);
=20
 	if (conn->info_state & L2CAP_INFO_FEAT_MASK_REQ_SENT)
-		__cancel_delayed_work(&conn->info_timer);
+		cancel_delayed_work_sync(&conn->info_timer);
=20
 	if (test_and_clear_bit(HCI_CONN_LE_SMP_PEND, &hcon->pend)) {
-		__cancel_delayed_work(&conn->security_timer);
+		cancel_delayed_work_sync(&conn->security_timer);
 		smp_chan_destroy(conn);
 	}
=20
@@ -1120,7 +1120,7 @@ static struct l2cap_chan *l2cap_global_chan_by_psm(in=
t state, __le16 psm, bdaddr
 	return c1;
 }
=20
-inline int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid=
, bdaddr_t *dst)
+int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid, bdadd=
r_t *dst)
 {
 	struct sock *sk =3D chan->sk;
 	bdaddr_t *src =3D &bt_sk(sk)->src;
@@ -2574,7 +2574,7 @@ static inline int l2cap_command_rej(struct l2cap_conn=
 *conn, struct l2cap_cmd_hd
=20
 	if ((conn->info_state & L2CAP_INFO_FEAT_MASK_REQ_SENT) &&
 					cmd->ident =3D=3D conn->info_ident) {
-		__cancel_delayed_work(&conn->info_timer);
+		cancel_delayed_work(&conn->info_timer);
=20
 		conn->info_state |=3D L2CAP_INFO_FEAT_MASK_REQ_DONE;
 		conn->info_ident =3D 0;
@@ -2970,7 +2970,8 @@ static inline int l2cap_config_rsp(struct l2cap_conn =
*conn, struct l2cap_cmd_hdr
=20
 	default:
 		sk->sk_err =3D ECONNRESET;
-		__set_chan_timer(chan, L2CAP_DISC_REJ_TIMEOUT);
+		__set_chan_timer(chan,
+				msecs_to_jiffies(L2CAP_DISC_REJ_TIMEOUT));
 		l2cap_send_disconn_req(conn, chan, ECONNRESET);
 		goto done;
 	}
@@ -3120,7 +3121,7 @@ static inline int l2cap_information_rsp(struct l2cap_=
conn *conn, struct l2cap_cm
 			conn->info_state & L2CAP_INFO_FEAT_MASK_REQ_DONE)
 		return 0;
=20
-	__cancel_delayed_work(&conn->info_timer);
+	cancel_delayed_work(&conn->info_timer);
=20
 	if (result !=3D L2CAP_IR_SUCCESS) {
 		conn->info_state |=3D L2CAP_INFO_FEAT_MASK_REQ_DONE;
@@ -4478,7 +4479,8 @@ static inline void l2cap_check_encryption(struct l2ca=
p_chan *chan, u8 encrypt)
 	if (encrypt =3D=3D 0x00) {
 		if (chan->sec_level =3D=3D BT_SECURITY_MEDIUM) {
 			__clear_chan_timer(chan);
-			__set_chan_timer(chan, L2CAP_ENC_TIMEOUT);
+			__set_chan_timer(chan,
+					msecs_to_jiffies(L2CAP_ENC_TIMEOUT));
 		} else if (chan->sec_level =3D=3D BT_SECURITY_HIGH)
 			l2cap_chan_close(chan, ECONNREFUSED);
 	} else {
@@ -4499,7 +4501,7 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 stat=
us, u8 encrypt)
=20
 	if (hcon->type =3D=3D LE_LINK) {
 		smp_distribute_keys(conn, 0);
-		__cancel_delayed_work(&conn->security_timer);
+		cancel_delayed_work(&conn->security_timer);
 	}
=20
 	rcu_read_lock();
@@ -4546,7 +4548,8 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 stat=
us, u8 encrypt)
 					L2CAP_CONN_REQ, sizeof(req), &req);
 			} else {
 				__clear_chan_timer(chan);
-				__set_chan_timer(chan, L2CAP_DISC_TIMEOUT);
+				__set_chan_timer(chan,
+					msecs_to_jiffies(L2CAP_DISC_TIMEOUT));
 			}
 		} else if (chan->state =3D=3D BT_CONNECT2) {
 			struct l2cap_conn_rsp rsp;
@@ -4566,7 +4569,8 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 stat=
us, u8 encrypt)
 				}
 			} else {
 				l2cap_state_change(chan, BT_DISCONN);
-				__set_chan_timer(chan, L2CAP_DISC_TIMEOUT);
+				__set_chan_timer(chan,
+					msecs_to_jiffies(L2CAP_DISC_TIMEOUT));
 				res =3D L2CAP_CR_SEC_BLOCK;
 				stat =3D L2CAP_CS_NO_INFO;
 			}
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index c61d967..401d942 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -849,6 +849,8 @@ static struct l2cap_chan *l2cap_sock_new_connection_cb(=
void *data)
 	if (!sk)
 		return NULL;
=20
+	bt_sock_reclassify_lock(sk, BTPROTO_L2CAP);
+
 	l2cap_sock_init(sk, parent);
=20
 	return l2cap_pi(sk)->chan;
@@ -1002,7 +1004,7 @@ static struct sock *l2cap_sock_alloc(struct net *net,=
 struct socket *sock, int p
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
=20
 	sk->sk_destruct =3D l2cap_sock_destruct;
-	sk->sk_sndtimeo =3D L2CAP_CONN_TIMEOUT;
+	sk->sk_sndtimeo =3D msecs_to_jiffies(L2CAP_CONN_TIMEOUT);
=20
 	sock_reset_flag(sk, SOCK_ZAPPED);
=20
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 501649b..8a60238 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1164,12 +1164,18 @@ static int rfcomm_recv_ua(struct rfcomm_session *s,=
 u8 dlci)
 			break;
=20
 		case BT_DISCONN:
-			/* When socket is closed and we are not RFCOMM
-			 * initiator rfcomm_process_rx already calls
-			 * rfcomm_session_put() */
-			if (s->sock->sk->sk_state !=3D BT_CLOSED)
-				if (list_empty(&s->dlcs))
-					rfcomm_session_put(s);
+			/* rfcomm_session_put is called later so don't do
+			 * anything here otherwise we will mess up the session
+			 * reference counter:
+			 *
+			 * (a) when we are the initiator dlc_unlink will drive
+			 * the reference counter to 0 (there is no initial put
+			 * after session_add)
+			 *
+			 * (b) when we are not the initiator rfcomm_rx_process
+			 * will explicitly call put to balance the initial hold
+			 * done after session add.
+			 */
 			break;
 		}
 	}
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index f066678..22169c3 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -956,6 +956,8 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 cha=
nnel, struct rfcomm_dlc *
 	if (!sk)
 		goto done;
=20
+	bt_sock_reclassify_lock(sk, BTPROTO_RFCOMM);
+
 	rfcomm_sock_init(sk, parent);
 	bacpy(&bt_sk(sk)->src, &src);
 	bacpy(&bt_sk(sk)->dst, &dst);
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index 2406b3e..d86217d 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -63,14 +63,14 @@ static ssize_t sta_flags_read(struct file *file, char _=
_user *userbuf,
 	test_sta_flag(sta, WLAN_STA_##flg) ? #flg "\n" : ""
=20
 	int res =3D scnprintf(buf, sizeof(buf),
-			    "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
+			    "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
 			    TEST(AUTH), TEST(ASSOC), TEST(PS_STA),
 			    TEST(PS_DRIVER), TEST(AUTHORIZED),
 			    TEST(SHORT_PREAMBLE),
 			    TEST(WME), TEST(WDS), TEST(CLEAR_PS_FILT),
 			    TEST(MFP), TEST(BLOCK_BA), TEST(PSPOLL),
 			    TEST(UAPSD), TEST(SP), TEST(TDLS_PEER),
-			    TEST(TDLS_PEER_AUTH));
+			    TEST(TDLS_PEER_AUTH), TEST(RATE_CONTROL));
 #undef TEST
 	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
 }
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 5a5a776..ad64f4d 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -336,7 +336,7 @@ void rate_control_get_rate(struct ieee80211_sub_if_data=
 *sdata,
 	int i;
 	u32 mask;
=20
-	if (sta) {
+	if (sta && test_sta_flag(sta, WLAN_STA_RATE_CONTROL)) {
 		ista =3D &sta->sta;
 		priv_sta =3D sta->rate_ctrl_priv;
 	}
diff --git a/net/mac80211/rate.h b/net/mac80211/rate.h
index 168427b..80cfc00 100644
--- a/net/mac80211/rate.h
+++ b/net/mac80211/rate.h
@@ -41,7 +41,7 @@ static inline void rate_control_tx_status(struct ieee8021=
1_local *local,
 	struct ieee80211_sta *ista =3D &sta->sta;
 	void *priv_sta =3D sta->rate_ctrl_priv;
=20
-	if (!ref)
+	if (!ref || !test_sta_flag(sta, WLAN_STA_RATE_CONTROL))
 		return;
=20
 	ref->ops->tx_status(ref->priv, sband, ista, priv_sta, skb);
@@ -62,6 +62,7 @@ static inline void rate_control_rate_init(struct sta_info=
 *sta)
 	sband =3D local->hw.wiphy->bands[local->hw.conf.channel->band];
=20
 	ref->ops->rate_init(ref->priv, sband, ista, priv_sta);
+	set_sta_flag(sta, WLAN_STA_RATE_CONTROL);
 }
=20
 static inline void rate_control_rate_update(struct ieee80211_local *local,
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 6f77f12..bfed851 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -52,6 +52,7 @@
  * @WLAN_STA_SP: Station is in a service period, so don't try to
  *	reply to other uAPSD trigger frames or PS-Poll.
  * @WLAN_STA_4ADDR_EVENT: 4-addr event was already sent for this frame.
+ * @WLAN_STA_RATE_CONTROL: rate control was initialized for this station.
  */
 enum ieee80211_sta_info_flags {
 	WLAN_STA_AUTH,
@@ -71,6 +72,7 @@ enum ieee80211_sta_info_flags {
 	WLAN_STA_UAPSD,
 	WLAN_STA_SP,
 	WLAN_STA_4ADDR_EVENT,
+	WLAN_STA_RATE_CONTROL,
 };
=20
 enum ieee80211_sta_state {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPQq8TAAoJEJctW/TcYTgGj1cQAJtPFkYP1aiGrYSK11DMVoxA
nkjtkW9npwmvLD6mRP5XpeKegkLCeulMlzgHWNBZp7Ex0ZDchprZXq77k8Pnixvb
/IcTbno3Vz0X95tqlPcTm3rYw5fOF9Pi421IAPFub2hLaEYls2384yH7JInnSjiY
/ll+M4dm3w7FFKRUYEqrmE8OZeBC6a0qib/JFg3na45B1x02K9+QBP84eaSFrMY2
MyPsZWGAI1GFgZ0590iotGodtyS5bg7JpKAj7axXiJYx7h8DGJ9VIZ9G3KzeqdHj
mU8UtfonSLYtnVDlgVh32hzo2kZU8DcaTKFkBP6k1sx7U2R9iNq26xVpSiW3DaMn
427tfhlpm+7H7hU75dcj7vDyNsGY9CCUtg/uL4KKpWQ5iM3XEQquvRzJqoflvssi
7eh8Hf2hGhAOiO+Byme2z/1gnx4akqjG2xmVHZTv8Y82WnSqVSj7ewPiuZR4Pu2W
fiJjnVvs3Ja0YEetzCHyZ/HEBtasS1SKnBvalBOSKXcVUpnUmiIxUpg0PzJaQZAJ
/Lp037nJMSmVTI94H/FKUAZeqCfKnqxw3ovkvI/SO/OTRBDtKlxARPm7XrZZirKT
bV5iRaBK1Jf8STf1gsZ8benBCnOq4KpFYaLVlpX10/+qzA1gZAb0j+wrsXO4aAI/
bXls6rA7bwThRM8d71HX
=maPG
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
