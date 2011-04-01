From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-04-01
Date: Fri, 1 Apr 2011 10:12:26 -0400
Message-ID: <20110401141224.GA3253@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Here is another batch of fixes intended for 2.6.39.  This round include=
s
a number of Bluetooth fixes.

On the Bluetooth front, we have a WARNING fix related to debugobjects, =
a
fix for L2CAP channel hang, a fix for an unlock without a lock, a fix t=
o
check for LE connections before discarding data, a fix for
synchronization after HCI_RESET, an accounting fix for unacked frames,
and a device ID addition.

=46or wireless LANs, an iwlegacy fix to prevent a possible crash during=
 a
firmware restart, a carl9170 fix to generate BlockAckReq if the
transmission of an AMPDU subframe fails (i.e. an interop fix), an
iwl3945 change to disable hw scan by default due to a number of related
problems, a related debug message change to avoid some confusion, a fix
for aggregation frame reordering, a cfg80211 fix to avoid
double-unlinking a BSS entry, a trio of NULL pointer deref fixes, an
ath9k fix to avoid a bus error during restart, a minstrel_ht fix to
avoid a crash when no supported MCS rates are found, and some new devic=
e
IDs for rt2x00.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c100c8f4c3c6f2a407bdbaaad2c4f1062e6a=
473a:

  appletalk: Fix OOPS in atalk_release(). (2011-03-31 18:59:10 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Andrei Emeltchenko (1):
      Bluetooth: delete hanging L2CAP channel

Christian Lamparter (1):
      carl9170: Fix tx aggregation problems with some clients

Daniel Halperin (1):
      mac80211: fix aggregation frame release during timeout

=46elix Fietkau (2):
      mac80211: fix a crash in minstrel_ht in HT mode with no supported=
 MCS rates
      ath9k: fix a chip wakeup related crash in ath9k_start

Gustavo F. Padovan (1):
      Bluetooth: Fix HCI_RESET command synchronization

Johan Hedberg (1):
      Bluetooth: Fix missing hci_dev_lock_bh in user_confirm_reply

Johannes Berg (1):
      iwlegacy: fix bugs in change_interface

Juuso Oikarinen (1):
      cfg80211: fix BSS double-unlinking (continued)

Marc-Antoine Perennou (1):
      Bluetooth: add support for Apple MacBook Pro 8,2

Mariusz Kozlowski (2):
      mac80211: fix possible NULL pointer dereference
      cfg80211:: fix possible NULL pointer dereference

Petr =C5=A0tetiar (1):
      mac80211: fix NULL pointer dereference in ieee80211_key_alloc()

Stanislaw Gruszka (2):
      iwl3945: do not deprecate software scan
      iwl3945: disable hw scan by default

Suraj Sumangala (1):
      Bluetooth: Increment unacked_frames count only the first transmit

Thomas Gleixner (1):
      Bluetooth: Fix warning with hci_cmd_timer

Vinicius Costa Gomes (1):
      Bluetooth: Fix sending LE data over USB

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800usb.c add and identify ids

 drivers/bluetooth/btusb.c                    |    6 ++++-
 drivers/net/wireless/ath/ath9k/main.c        |    4 +++
 drivers/net/wireless/ath/carl9170/carl9170.h |    1 +
 drivers/net/wireless/ath/carl9170/main.c     |    1 +
 drivers/net/wireless/ath/carl9170/tx.c       |    7 ++++++
 drivers/net/wireless/iwlegacy/iwl-core.c     |   10 ++++++++
 drivers/net/wireless/iwlegacy/iwl3945-base.c |    7 ++---
 drivers/net/wireless/rt2x00/rt2800usb.c      |   10 ++++++--
 include/net/bluetooth/hci.h                  |    2 +
 net/bluetooth/hci_core.c                     |   10 ++++++-
 net/bluetooth/hci_event.c                    |    4 ++-
 net/bluetooth/l2cap_core.c                   |    4 ++-
 net/bluetooth/l2cap_sock.c                   |    5 ++-
 net/bluetooth/mgmt.c                         |    2 +
 net/mac80211/key.c                           |    7 +++--
 net/mac80211/rc80211_minstrel_ht.c           |   25 +++++++++++++++---=
---
 net/mac80211/rx.c                            |    3 +-
 net/wireless/scan.c                          |   31 +++++++++++++++++-=
-------
 18 files changed, 104 insertions(+), 35 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 8668114..762a510 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -71,6 +71,9 @@ static struct usb_device_id btusb_table[] =3D {
 	/* Apple MacBookAir3,1, MacBookAir3,2 */
 	{ USB_DEVICE(0x05ac, 0x821b) },
=20
+	/* Apple MacBookPro8,2 */
+	{ USB_DEVICE(0x05ac, 0x821a) },
+
 	/* AVM BlueFRITZ! USB v2.0 */
 	{ USB_DEVICE(0x057c, 0x3800) },
=20
@@ -690,7 +693,8 @@ static int btusb_send_frame(struct sk_buff *skb)
 		break;
=20
 	case HCI_ACLDATA_PKT:
-		if (!data->bulk_tx_ep || hdev->conn_hash.acl_num < 1)
+		if (!data->bulk_tx_ep || (hdev->conn_hash.acl_num < 1 &&
+						hdev->conn_hash.le_num < 1))
 			return -ENODEV;
=20
 		urb =3D usb_alloc_urb(0, GFP_ATOMIC);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wirele=
ss/ath/ath9k/main.c
index 5248257..dddb85d 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1048,6 +1048,8 @@ static int ath9k_start(struct ieee80211_hw *hw)
 		"Starting driver with initial channel: %d MHz\n",
 		curchan->center_freq);
=20
+	ath9k_ps_wakeup(sc);
+
 	mutex_lock(&sc->mutex);
=20
 	/* setup initial channel */
@@ -1143,6 +1145,8 @@ static int ath9k_start(struct ieee80211_hw *hw)
 mutex_unlock:
 	mutex_unlock(&sc->mutex);
=20
+	ath9k_ps_restore(sc);
+
 	return r;
 }
=20
diff --git a/drivers/net/wireless/ath/carl9170/carl9170.h b/drivers/net=
/wireless/ath/carl9170/carl9170.h
index c6a5fae..9cad061 100644
--- a/drivers/net/wireless/ath/carl9170/carl9170.h
+++ b/drivers/net/wireless/ath/carl9170/carl9170.h
@@ -443,6 +443,7 @@ struct carl9170_ba_stats {
 	u8 ampdu_len;
 	u8 ampdu_ack_len;
 	bool clear;
+	bool req;
 };
=20
 struct carl9170_sta_info {
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wir=
eless/ath/carl9170/main.c
index ede3d7e..89fe60a 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1355,6 +1355,7 @@ static int carl9170_op_ampdu_action(struct ieee80=
211_hw *hw,
 		tid_info =3D rcu_dereference(sta_info->agg[tid]);
=20
 		sta_info->stats[tid].clear =3D true;
+		sta_info->stats[tid].req =3D false;
=20
 		if (tid_info) {
 			bitmap_zero(tid_info->bitmap, CARL9170_BAW_SIZE);
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wirel=
ess/ath/carl9170/tx.c
index 0ef70b6..cb70ed7 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -383,6 +383,7 @@ static void carl9170_tx_status_process_ampdu(struct=
 ar9170 *ar,
=20
 	if (sta_info->stats[tid].clear) {
 		sta_info->stats[tid].clear =3D false;
+		sta_info->stats[tid].req =3D false;
 		sta_info->stats[tid].ampdu_len =3D 0;
 		sta_info->stats[tid].ampdu_ack_len =3D 0;
 	}
@@ -391,10 +392,16 @@ static void carl9170_tx_status_process_ampdu(stru=
ct ar9170 *ar,
 	if (txinfo->status.rates[0].count =3D=3D 1)
 		sta_info->stats[tid].ampdu_ack_len++;
=20
+	if (!(txinfo->flags & IEEE80211_TX_STAT_ACK))
+		sta_info->stats[tid].req =3D true;
+
 	if (super->f.mac_control & cpu_to_le16(AR9170_TX_MAC_IMM_BA)) {
 		super->s.rix =3D sta_info->stats[tid].ampdu_len;
 		super->s.cnt =3D sta_info->stats[tid].ampdu_ack_len;
 		txinfo->flags |=3D IEEE80211_TX_STAT_AMPDU;
+		if (sta_info->stats[tid].req)
+			txinfo->flags |=3D IEEE80211_TX_STAT_AMPDU_NO_BACK;
+
 		sta_info->stats[tid].clear =3D true;
 	}
 	spin_unlock_bh(&tid_info->lock);
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.c b/drivers/net/wir=
eless/iwlegacy/iwl-core.c
index d418b64..a209a0e 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.c
+++ b/drivers/net/wireless/iwlegacy/iwl-core.c
@@ -1805,6 +1805,15 @@ iwl_legacy_mac_change_interface(struct ieee80211=
_hw *hw,
=20
 	mutex_lock(&priv->mutex);
=20
+	if (!ctx->vif || !iwl_legacy_is_ready_rf(priv)) {
+		/*
+		 * Huh? But wait ... this can maybe happen when
+		 * we're in the middle of a firmware restart!
+		 */
+		err =3D -EBUSY;
+		goto out;
+	}
+
 	interface_modes =3D ctx->interface_modes | ctx->exclusive_interface_m=
odes;
=20
 	if (!(interface_modes & BIT(newtype))) {
@@ -1832,6 +1841,7 @@ iwl_legacy_mac_change_interface(struct ieee80211_=
hw *hw,
 	/* success */
 	iwl_legacy_teardown_interface(priv, vif, true);
 	vif->type =3D newtype;
+	vif->p2p =3D newp2p;
 	err =3D iwl_legacy_setup_interface(priv, ctx);
 	WARN_ON(err);
 	/*
diff --git a/drivers/net/wireless/iwlegacy/iwl3945-base.c b/drivers/net=
/wireless/iwlegacy/iwl3945-base.c
index ab87e1b..28eb3d8 100644
--- a/drivers/net/wireless/iwlegacy/iwl3945-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl3945-base.c
@@ -93,6 +93,7 @@ MODULE_LICENSE("GPL");
 struct iwl_mod_params iwl3945_mod_params =3D {
 	.sw_crypto =3D 1,
 	.restart_fw =3D 1,
+	.disable_hw_scan =3D 1,
 	/* the rest are 0 by default */
 };
=20
@@ -3960,8 +3961,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev=
, const struct pci_device_id *e
 	 * "the hard way", rather than using device's scan.
 	 */
 	if (iwl3945_mod_params.disable_hw_scan) {
-		dev_printk(KERN_DEBUG, &(pdev->dev),
-			"sw scan support is deprecated\n");
+		IWL_DEBUG_INFO(priv, "Disabling hw_scan\n");
 		iwl3945_hw_ops.hw_scan =3D NULL;
 	}
=20
@@ -4280,8 +4280,7 @@ MODULE_PARM_DESC(swcrypto,
 		"using software crypto (default 1 [software])");
 module_param_named(disable_hw_scan, iwl3945_mod_params.disable_hw_scan=
,
 		int, S_IRUGO);
-MODULE_PARM_DESC(disable_hw_scan,
-		"disable hardware scanning (default 0) (deprecated)");
+MODULE_PARM_DESC(disable_hw_scan, "disable hardware scanning (default =
1)");
 #ifdef CONFIG_IWLWIFI_LEGACY_DEBUG
 module_param_named(debug, iwlegacy_debug_level, uint, S_IRUGO | S_IWUS=
R);
 MODULE_PARM_DESC(debug, "debug output mask");
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wire=
less/rt2x00/rt2800usb.c
index 4e36865..37509d0 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -730,8 +730,12 @@ static struct usb_device_id rt2800usb_device_table=
[] =3D {
 	{ USB_DEVICE(0x050d, 0x8053), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x050d, 0x805c), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x050d, 0x815c), USB_DEVICE_DATA(&rt2800usb_ops) },
+	{ USB_DEVICE(0x050d, 0x825b), USB_DEVICE_DATA(&rt2800usb_ops) },
+	{ USB_DEVICE(0x050d, 0x935a), USB_DEVICE_DATA(&rt2800usb_ops) },
+	{ USB_DEVICE(0x050d, 0x935b), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Buffalo */
 	{ USB_DEVICE(0x0411, 0x00e8), USB_DEVICE_DATA(&rt2800usb_ops) },
+	{ USB_DEVICE(0x0411, 0x016f), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Conceptronic */
 	{ USB_DEVICE(0x14b2, 0x3c06), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x14b2, 0x3c07), USB_DEVICE_DATA(&rt2800usb_ops) },
@@ -818,6 +822,7 @@ static struct usb_device_id rt2800usb_device_table[=
] =3D {
 	/* Pegatron */
 	{ USB_DEVICE(0x1d4d, 0x000c), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x1d4d, 0x000e), USB_DEVICE_DATA(&rt2800usb_ops) },
+	{ USB_DEVICE(0x1d4d, 0x0011), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Philips */
 	{ USB_DEVICE(0x0471, 0x200f), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Planex */
@@ -899,6 +904,8 @@ static struct usb_device_id rt2800usb_device_table[=
] =3D {
 	{ USB_DEVICE(0x148f, 0x3572), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Sitecom */
 	{ USB_DEVICE(0x0df6, 0x0041), USB_DEVICE_DATA(&rt2800usb_ops) },
+	/* Toshiba */
+	{ USB_DEVICE(0x0930, 0x0a07), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Zinwell */
 	{ USB_DEVICE(0x5a57, 0x0284), USB_DEVICE_DATA(&rt2800usb_ops) },
 #endif
@@ -961,7 +968,6 @@ static struct usb_device_id rt2800usb_device_table[=
] =3D {
 	{ USB_DEVICE(0x05a6, 0x0101), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x1d4d, 0x0002), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x1d4d, 0x0010), USB_DEVICE_DATA(&rt2800usb_ops) },
-	{ USB_DEVICE(0x1d4d, 0x0011), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Planex */
 	{ USB_DEVICE(0x2019, 0x5201), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x2019, 0xab24), USB_DEVICE_DATA(&rt2800usb_ops) },
@@ -975,8 +981,6 @@ static struct usb_device_id rt2800usb_device_table[=
] =3D {
 	/* Sweex */
 	{ USB_DEVICE(0x177f, 0x0153), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x177f, 0x0313), USB_DEVICE_DATA(&rt2800usb_ops) },
-	/* Toshiba */
-	{ USB_DEVICE(0x0930, 0x0a07), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Zyxel */
 	{ USB_DEVICE(0x0586, 0x341a), USB_DEVICE_DATA(&rt2800usb_ops) },
 #endif
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index ec6acf2..2c0d309 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -84,6 +84,8 @@ enum {
 	HCI_SERVICE_CACHE,
 	HCI_LINK_KEYS,
 	HCI_DEBUG_KEYS,
+
+	HCI_RESET,
 };
=20
 /* HCI ioctl defines */
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index b372fb8..2216620 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -186,6 +186,7 @@ static void hci_reset_req(struct hci_dev *hdev, uns=
igned long opt)
 	BT_DBG("%s %ld", hdev->name, opt);
=20
 	/* Reset device */
+	set_bit(HCI_RESET, &hdev->flags);
 	hci_send_cmd(hdev, HCI_OP_RESET, 0, NULL);
 }
=20
@@ -213,8 +214,10 @@ static void hci_init_req(struct hci_dev *hdev, uns=
igned long opt)
 	/* Mandatory initialization */
=20
 	/* Reset */
-	if (!test_bit(HCI_QUIRK_NO_RESET, &hdev->quirks))
+	if (!test_bit(HCI_QUIRK_NO_RESET, &hdev->quirks)) {
+			set_bit(HCI_RESET, &hdev->flags);
 			hci_send_cmd(hdev, HCI_OP_RESET, 0, NULL);
+	}
=20
 	/* Read Local Supported Features */
 	hci_send_cmd(hdev, HCI_OP_READ_LOCAL_FEATURES, 0, NULL);
@@ -584,6 +587,9 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	hci_req_cancel(hdev, ENODEV);
 	hci_req_lock(hdev);
=20
+	/* Stop timer, it might be running */
+	del_timer_sync(&hdev->cmd_timer);
+
 	if (!test_and_clear_bit(HCI_UP, &hdev->flags)) {
 		hci_req_unlock(hdev);
 		return 0;
@@ -623,7 +629,6 @@ static int hci_dev_do_close(struct hci_dev *hdev)
=20
 	/* Drop last sent command */
 	if (hdev->sent_cmd) {
-		del_timer_sync(&hdev->cmd_timer);
 		kfree_skb(hdev->sent_cmd);
 		hdev->sent_cmd =3D NULL;
 	}
@@ -1074,6 +1079,7 @@ static void hci_cmd_timer(unsigned long arg)
=20
 	BT_ERR("%s command tx timeout", hdev->name);
 	atomic_set(&hdev->cmd_cnt, 1);
+	clear_bit(HCI_RESET, &hdev->flags);
 	tasklet_schedule(&hdev->cmd_task);
 }
=20
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 3fbfa50..cebe7588 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -183,6 +183,8 @@ static void hci_cc_reset(struct hci_dev *hdev, stru=
ct sk_buff *skb)
=20
 	BT_DBG("%s status 0x%x", hdev->name, status);
=20
+	clear_bit(HCI_RESET, &hdev->flags);
+
 	hci_req_complete(hdev, HCI_OP_RESET, status);
 }
=20
@@ -1847,7 +1849,7 @@ static inline void hci_cmd_status_evt(struct hci_=
dev *hdev, struct sk_buff *skb)
 	if (ev->opcode !=3D HCI_OP_NOP)
 		del_timer(&hdev->cmd_timer);
=20
-	if (ev->ncmd) {
+	if (ev->ncmd && !test_bit(HCI_RESET, &hdev->flags)) {
 		atomic_set(&hdev->cmd_cnt, 1);
 		if (!skb_queue_empty(&hdev->cmd_q))
 			tasklet_schedule(&hdev->cmd_task);
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index c9f9cec..ca27f3a 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1116,7 +1116,9 @@ int l2cap_ertm_send(struct sock *sk)
 		bt_cb(skb)->tx_seq =3D pi->next_tx_seq;
 		pi->next_tx_seq =3D (pi->next_tx_seq + 1) % 64;
=20
-		pi->unacked_frames++;
+		if (bt_cb(skb)->retries =3D=3D 1)
+			pi->unacked_frames++;
+
 		pi->frames_sent++;
=20
 		if (skb_queue_is_last(TX_QUEUE(sk), skb))
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index fc85e7a..f77308e 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -923,8 +923,9 @@ void __l2cap_sock_close(struct sock *sk, int reason=
)
 			rsp.status =3D cpu_to_le16(L2CAP_CS_NO_INFO);
 			l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 					L2CAP_CONN_RSP, sizeof(rsp), &rsp);
-		} else
-			l2cap_chan_del(sk, reason);
+		}
+
+		l2cap_chan_del(sk, reason);
 		break;
=20
 	case BT_CONNECT:
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 0054c74..4476d8e 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -1230,6 +1230,8 @@ static int user_confirm_reply(struct sock *sk, u1=
6 index, unsigned char *data,
 	if (!hdev)
 		return cmd_status(sk, index, mgmt_op, ENODEV);
=20
+	hci_dev_lock_bh(hdev);
+
 	if (!test_bit(HCI_UP, &hdev->flags)) {
 		err =3D cmd_status(sk, index, mgmt_op, ENETDOWN);
 		goto failed;
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 8c02469..af3c564 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -342,7 +342,7 @@ struct ieee80211_key *ieee80211_key_alloc(u32 ciphe=
r, int idx, size_t key_len,
 		if (IS_ERR(key->u.ccmp.tfm)) {
 			err =3D PTR_ERR(key->u.ccmp.tfm);
 			kfree(key);
-			key =3D ERR_PTR(err);
+			return ERR_PTR(err);
 		}
 		break;
 	case WLAN_CIPHER_SUITE_AES_CMAC:
@@ -360,7 +360,7 @@ struct ieee80211_key *ieee80211_key_alloc(u32 ciphe=
r, int idx, size_t key_len,
 		if (IS_ERR(key->u.aes_cmac.tfm)) {
 			err =3D PTR_ERR(key->u.aes_cmac.tfm);
 			kfree(key);
-			key =3D ERR_PTR(err);
+			return ERR_PTR(err);
 		}
 		break;
 	}
@@ -400,11 +400,12 @@ int ieee80211_key_link(struct ieee80211_key *key,
 {
 	struct ieee80211_key *old_key;
 	int idx, ret;
-	bool pairwise =3D key->conf.flags & IEEE80211_KEY_FLAG_PAIRWISE;
+	bool pairwise;
=20
 	BUG_ON(!sdata);
 	BUG_ON(!key);
=20
+	pairwise =3D key->conf.flags & IEEE80211_KEY_FLAG_PAIRWISE;
 	idx =3D key->conf.keyidx;
 	key->local =3D sdata->local;
 	key->sdata =3D sdata;
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_=
minstrel_ht.c
index 8212a8b..dbdebed 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -659,18 +659,14 @@ minstrel_ht_update_caps(void *priv, struct ieee80=
211_supported_band *sband,
 	struct ieee80211_mcs_info *mcs =3D &sta->ht_cap.mcs;
 	struct ieee80211_local *local =3D hw_to_local(mp->hw);
 	u16 sta_cap =3D sta->ht_cap.cap;
+	int n_supported =3D 0;
 	int ack_dur;
 	int stbc;
 	int i;
=20
 	/* fall back to the old minstrel for legacy stations */
-	if (!sta->ht_cap.ht_supported) {
-		msp->is_ht =3D false;
-		memset(&msp->legacy, 0, sizeof(msp->legacy));
-		msp->legacy.r =3D msp->ratelist;
-		msp->legacy.sample_table =3D msp->sample_table;
-		return mac80211_minstrel.rate_init(priv, sband, sta, &msp->legacy);
-	}
+	if (!sta->ht_cap.ht_supported)
+		goto use_legacy;
=20
 	BUILD_BUG_ON(ARRAY_SIZE(minstrel_mcs_groups) !=3D
 		MINSTREL_MAX_STREAMS * MINSTREL_STREAM_GROUPS);
@@ -725,7 +721,22 @@ minstrel_ht_update_caps(void *priv, struct ieee802=
11_supported_band *sband,
=20
 		mi->groups[i].supported =3D
 			mcs->rx_mask[minstrel_mcs_groups[i].streams - 1];
+
+		if (mi->groups[i].supported)
+			n_supported++;
 	}
+
+	if (!n_supported)
+		goto use_legacy;
+
+	return;
+
+use_legacy:
+	msp->is_ht =3D false;
+	memset(&msp->legacy, 0, sizeof(msp->legacy));
+	msp->legacy.r =3D msp->ratelist;
+	msp->legacy.sample_table =3D msp->sample_table;
+	return mac80211_minstrel.rate_init(priv, sband, sta, &msp->legacy);
 }
=20
 static void
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 5c1930b..aa5cc37 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -612,7 +612,8 @@ static void ieee80211_sta_reorder_release(struct ie=
ee80211_hw *hw,
 				skipped++;
 				continue;
 			}
-			if (!time_after(jiffies, tid_agg_rx->reorder_time[j] +
+			if (skipped &&
+			    !time_after(jiffies, tid_agg_rx->reorder_time[j] +
 					HT_RX_REORDER_BUF_TIMEOUT))
 				goto set_release_timer;
=20
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index ea427f4..fbf6f33 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -124,6 +124,15 @@ void cfg80211_bss_age(struct cfg80211_registered_d=
evice *dev,
 }
=20
 /* must hold dev->bss_lock! */
+static void __cfg80211_unlink_bss(struct cfg80211_registered_device *d=
ev,
+				  struct cfg80211_internal_bss *bss)
+{
+	list_del_init(&bss->list);
+	rb_erase(&bss->rbn, &dev->bss_tree);
+	kref_put(&bss->ref, bss_release);
+}
+
+/* must hold dev->bss_lock! */
 void cfg80211_bss_expire(struct cfg80211_registered_device *dev)
 {
 	struct cfg80211_internal_bss *bss, *tmp;
@@ -134,9 +143,7 @@ void cfg80211_bss_expire(struct cfg80211_registered=
_device *dev)
 			continue;
 		if (!time_after(jiffies, bss->ts + IEEE80211_SCAN_RESULT_EXPIRE))
 			continue;
-		list_del(&bss->list);
-		rb_erase(&bss->rbn, &dev->bss_tree);
-		kref_put(&bss->ref, bss_release);
+		__cfg80211_unlink_bss(dev, bss);
 		expired =3D true;
 	}
=20
@@ -585,16 +592,23 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
 	struct cfg80211_internal_bss *res;
 	size_t ielen =3D len - offsetof(struct ieee80211_mgmt,
 				      u.probe_resp.variable);
-	size_t privsz =3D wiphy->bss_priv_size;
+	size_t privsz;
+
+	if (WARN_ON(!mgmt))
+		return NULL;
+
+	if (WARN_ON(!wiphy))
+		return NULL;
=20
 	if (WARN_ON(wiphy->signal_type =3D=3D CFG80211_SIGNAL_TYPE_UNSPEC &&
 	            (signal < 0 || signal > 100)))
 		return NULL;
=20
-	if (WARN_ON(!mgmt || !wiphy ||
-		    len < offsetof(struct ieee80211_mgmt, u.probe_resp.variable)))
+	if (WARN_ON(len < offsetof(struct ieee80211_mgmt, u.probe_resp.variab=
le)))
 		return NULL;
=20
+	privsz =3D wiphy->bss_priv_size;
+
 	res =3D kzalloc(sizeof(*res) + privsz + ielen, gfp);
 	if (!res)
 		return NULL;
@@ -662,11 +676,8 @@ void cfg80211_unlink_bss(struct wiphy *wiphy, stru=
ct cfg80211_bss *pub)
=20
 	spin_lock_bh(&dev->bss_lock);
 	if (!list_empty(&bss->list)) {
-		list_del_init(&bss->list);
+		__cfg80211_unlink_bss(dev, bss);
 		dev->bss_generation++;
-		rb_erase(&bss->rbn, &dev->bss_tree);
-
-		kref_put(&bss->ref, bss_release);
 	}
 	spin_unlock_bh(&dev->bss_lock);
 }
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
