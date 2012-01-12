From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-01-12
Date: Thu, 12 Jan 2012 13:49:19 -0500
Message-ID: <20120112184919.GK11093@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 1140afa862842ac3e56678693050760edc4ecde9

Dave,

Here is a quick batch of wireless fixes intended for 3.3!

On the Bluetooth patches, Gustavo says this:

"A couple of fixes for the 3.3 release. The majority of the fixes are
related to the change from tasklets to workqueue in the Bluetooth
Core. The rest are important fixes over the tree. Exception is
'Bluetooth: Rename extfeatures', as the name says it is just a rename
and no harm, but it is a preparation for a following fix."

Also included is a fix from Jesper Juhl for a potential memory leak in
brcm80211, a one-line comment fix (plus a couple of lines of removing
unused code) from Mohammed Shafi Shajakhan in ath9k, a fix from Larry
Finger to prevent hitting a BUG in rtl8192se when an skb allocation
fails, a fix from Stanislaw Gruszka for a NULL pointer dereference
in mac80211, a fix from Rajkumar Manoharan for an ath9k regression
relating to channel noisefloor readings, and a fix from Johannes Berg
for a regression related to parsing station flags.

Hopefully all of these are fine for the merge window.  Please let me
know if there are problems!

Thanks,

John

---

The following changes since commit a8c1f65c79cbbb2f7da782d4c9d15639a9b94b27:

  igmp: Avoid zero delay when receiving odd mixture of IGMP queries (2012-0=
1-09 14:06:46 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Andre Guedes (5):
      Bluetooth: Rename extfeatures
      Bluetooth: Fix hci_cc_read_local_ext_features()
      Bluetooth: Fix adv_work delay
      Bluetooth: Queue adv_work on system workqueue
      Bluetooth: Fix mgmt_stop_discovery_failed()

Andrei Emeltchenko (1):
      Bluetooth: Correct packet len calculation

Gustavo F. Padovan (8):
      Bluetooth: Fix bacpy in l2cap_core.c
      Bluetooth: Fix context in rfcomm_sock_lock
      Bluetooth: Fix context in RFCOMM tty
      Bluetooth: Remove *_bh locks from SCO
      Bluetooth: Remove local_bh_disable() from hci_sock.c
      Bluetooth: Remove *_bh from socket list lock.
      Bluetooth: Don't use *_bh locks anymore
      Bluetooth: Keep chan->state and sk->sk_state in sync

Jesper Juhl (1):
      brcm80211: Don't leak 'vbuffer' in brcmf_sdbrcm_write_vars()

Johannes Berg (1):
      nl80211: fix old station flags compatibility

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-n=
ext

Larry Finger (1):
      rtl8192se: Fix BUG caused by failure to check skb allocation

Mohammed Shafi Shajakhan (1):
      ath9k_hw: fix a comment

Rajkumar Manoharan (1):
      ath9k: Fix regression in channelwidth switch at the same channel

Stanislaw Gruszka (1):
      mac80211: fix rx->key NULL pointer dereference in promiscuous mode

 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 -
 drivers/net/wireless/ath/ath9k/calib.c             |    1 +
 drivers/net/wireless/ath/ath9k/calib.h             |    1 -
 drivers/net/wireless/ath/ath9k/main.c              |    8 +---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    4 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |    4 ++
 include/net/bluetooth/hci_core.h                   |    4 +-
 net/bluetooth/af_bluetooth.c                       |    8 ++--
 net/bluetooth/hci_event.c                          |   22 +++++++-----
 net/bluetooth/hci_sock.c                           |    2 -
 net/bluetooth/l2cap_core.c                         |   26 +++++++-------
 net/bluetooth/l2cap_sock.c                         |    2 +
 net/bluetooth/mgmt.c                               |    4 +-
 net/bluetooth/rfcomm/sock.c                        |   12 +++---
 net/bluetooth/rfcomm/tty.c                         |   22 ++++++------
 net/bluetooth/sco.c                                |    8 ++--
 net/mac80211/wpa.c                                 |    2 +-
 net/wireless/nl80211.c                             |   34 ++++++++++++++++=
+--
 19 files changed, 99 insertions(+), 68 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.c
index 2589b38..2b0bfb8 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -46,7 +46,7 @@ static const int m2ThreshExt_off =3D 127;
  * @chan:
  *
  * This is the function to change channel on single-chip devices, that is
- * all devices after ar9280.
+ * for AR9300 family of chipsets.
  *
  * This function takes the channel value in MHz and sets
  * hardware channel value. Assumes writes have been enabled to analog bus.
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index b30e9fc..171ccf7 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -679,7 +679,6 @@ void ath9k_deinit_device(struct ath_softc *sc);
 void ath9k_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *hw);
 void ath9k_reload_chainmask_settings(struct ath_softc *sc);
=20
-void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw);
 bool ath9k_uses_beacons(int type);
=20
 #ifdef CONFIG_ATH9K_PCI
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/=
ath/ath9k/calib.c
index 172e33d..2f4b48e 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -400,6 +400,7 @@ bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_cha=
nnel *chan)
 	ah->noise =3D ath9k_hw_getchan_noise(ah, chan);
 	return true;
 }
+EXPORT_SYMBOL(ath9k_hw_getnf);
=20
 void ath9k_init_nfcal_hist_buffer(struct ath_hw *ah,
 				  struct ath9k_channel *chan)
diff --git a/drivers/net/wireless/ath/ath9k/calib.h b/drivers/net/wireless/=
ath/ath9k/calib.h
index 05b9dbf..3b33996 100644
--- a/drivers/net/wireless/ath/ath9k/calib.h
+++ b/drivers/net/wireless/ath/ath9k/calib.h
@@ -19,7 +19,6 @@
=20
 #include "hw.h"
=20
-#define AR_PHY_CCA_FILTERWINDOW_LENGTH_INIT     3
 #define AR_PHY_CCA_FILTERWINDOW_LENGTH          5
=20
 #define NUM_NF_READINGS       6
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index e267c92..4a00806 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1629,7 +1629,6 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 =
changed)
=20
 	if (changed & IEEE80211_CONF_CHANGE_CHANNEL) {
 		struct ieee80211_channel *curchan =3D hw->conf.channel;
-		struct ath9k_channel old_chan;
 		int pos =3D curchan->hw_value;
 		int old_pos =3D -1;
 		unsigned long flags;
@@ -1654,11 +1653,8 @@ static int ath9k_config(struct ieee80211_hw *hw, u32=
 changed)
 		 * Preserve the current channel values, before updating
 		 * the same channel
 		 */
-		if (old_pos =3D=3D pos) {
-			memcpy(&old_chan, &sc->sc_ah->channels[pos],
-				sizeof(struct ath9k_channel));
-			ah->curchan =3D &old_chan;
-		}
+		if (ah->curchan && (old_pos =3D=3D pos))
+			ath9k_hw_getnf(ah, ah->curchan);
=20
 		ath9k_cmn_update_ichannel(&sc->sc_ah->channels[pos],
 					  curchan, conf->channel_type);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 5a002a2..f7eeee1 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -3119,8 +3119,10 @@ static int brcmf_sdbrcm_write_vars(struct brcmf_sdio=
 *bus)
 		/* Verify NVRAM bytes */
 		brcmf_dbg(INFO, "Compare NVRAM dl & ul; varsize=3D%d\n", varsize);
 		nvram_ularray =3D kmalloc(varsize, GFP_ATOMIC);
-		if (!nvram_ularray)
+		if (!nvram_ularray) {
+			kfree(vbuffer);
 			return -ENOMEM;
+		}
=20
 		/* Upload image to verify downloaded contents. */
 		memset(nvram_ularray, 0xaa, varsize);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c b/drivers/net/wire=
less/rtlwifi/rtl8192se/fw.c
index 6f91a14..3fda6b1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
@@ -196,6 +196,8 @@ static bool _rtl92s_firmware_downloadcode(struct ieee80=
211_hw *hw,
 		/* Allocate skb buffer to contain firmware */
 		/* info and tx descriptor info. */
 		skb =3D dev_alloc_skb(frag_length);
+		if (!skb)
+			return false;
 		skb_reserve(skb, extra_descoffset);
 		seg_ptr =3D (u8 *)skb_put(skb, (u32)(frag_length -
 					extra_descoffset));
@@ -573,6 +575,8 @@ static bool _rtl92s_firmware_set_h2c_cmd(struct ieee802=
11_hw *hw, u8 h2c_cmd,
=20
 	len =3D _rtl92s_get_h2c_cmdlen(MAX_TRANSMIT_BUFFER_SIZE, 1, &cmd_len);
 	skb =3D dev_alloc_skb(len);
+	if (!skb)
+		return false;
 	cb_desc =3D (struct rtl_tcb_desc *)(skb->cb);
 	cb_desc->queue_index =3D TXCMD_QUEUE;
 	cb_desc->cmd_or_init =3D DESC_PACKET_TYPE_NORMAL;
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index 5e2e984..ea9231f 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -127,7 +127,7 @@ struct hci_dev {
 	__u8		major_class;
 	__u8		minor_class;
 	__u8		features[8];
-	__u8		extfeatures[8];
+	__u8		host_features[8];
 	__u8		commands[64];
 	__u8		ssp_mode;
 	__u8		hci_ver;
@@ -676,7 +676,7 @@ void hci_conn_del_sysfs(struct hci_conn *conn);
 #define lmp_le_capable(dev)        ((dev)->features[4] & LMP_LE)
=20
 /* ----- Extended LMP capabilities ----- */
-#define lmp_host_le_capable(dev)   ((dev)->extfeatures[0] & LMP_HOST_LE)
+#define lmp_host_le_capable(dev)   ((dev)->host_features[0] & LMP_HOST_LE)
=20
 /* ----- HCI protocols ----- */
 static inline int hci_proto_connect_ind(struct hci_dev *hdev, bdaddr_t *bd=
addr,
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index cdcfcab..ef92864 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -156,17 +156,17 @@ static int bt_sock_create(struct net *net, struct soc=
ket *sock, int proto,
=20
 void bt_sock_link(struct bt_sock_list *l, struct sock *sk)
 {
-	write_lock_bh(&l->lock);
+	write_lock(&l->lock);
 	sk_add_node(sk, &l->head);
-	write_unlock_bh(&l->lock);
+	write_unlock(&l->lock);
 }
 EXPORT_SYMBOL(bt_sock_link);
=20
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *sk)
 {
-	write_lock_bh(&l->lock);
+	write_lock(&l->lock);
 	sk_del_node_init(sk);
-	write_unlock_bh(&l->lock);
+	write_unlock(&l->lock);
 }
 EXPORT_SYMBOL(bt_sock_unlink);
=20
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 4221bd2..001307f 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -711,7 +711,14 @@ static void hci_cc_read_local_ext_features(struct hci_=
dev *hdev,
 	if (rp->status)
 		return;
=20
-	memcpy(hdev->extfeatures, rp->features, 8);
+	switch (rp->page) {
+	case 0:
+		memcpy(hdev->features, rp->features, 8);
+		break;
+	case 1:
+		memcpy(hdev->host_features, rp->features, 8);
+		break;
+	}
=20
 	hci_req_complete(hdev, HCI_OP_READ_LOCAL_EXT_FEATURES, rp->status);
 }
@@ -1047,9 +1054,7 @@ static void hci_cc_le_set_scan_enable(struct hci_dev =
*hdev,
 	case LE_SCANNING_DISABLED:
 		clear_bit(HCI_LE_SCAN, &hdev->dev_flags);
=20
-		cancel_delayed_work_sync(&hdev->adv_work);
-		queue_delayed_work(hdev->workqueue, &hdev->adv_work,
-						 jiffies + ADV_CLEAR_TIMEOUT);
+		schedule_delayed_work(&hdev->adv_work, ADV_CLEAR_TIMEOUT);
 		break;
=20
 	default:
@@ -2266,20 +2271,19 @@ static inline void hci_num_comp_pkts_evt(struct hci=
_dev *hdev, struct sk_buff *s
 	struct hci_ev_num_comp_pkts *ev =3D (void *) skb->data;
 	int i;
=20
-	skb_pull(skb, sizeof(*ev));
-
-	BT_DBG("%s num_hndl %d", hdev->name, ev->num_hndl);
-
 	if (hdev->flow_ctl_mode !=3D HCI_FLOW_CTL_MODE_PACKET_BASED) {
 		BT_ERR("Wrong event for mode %d", hdev->flow_ctl_mode);
 		return;
 	}
=20
-	if (skb->len < ev->num_hndl * 4) {
+	if (skb->len < sizeof(*ev) || skb->len < sizeof(*ev) +
+			ev->num_hndl * sizeof(struct hci_comp_pkts_info)) {
 		BT_DBG("%s bad parameters", hdev->name);
 		return;
 	}
=20
+	BT_DBG("%s num_hndl %d", hdev->name, ev->num_hndl);
+
 	for (i =3D 0; i < ev->num_hndl; i++) {
 		struct hci_comp_pkts_info *info =3D &ev->handles[i];
 		struct hci_conn *conn;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 6d94616..0dcc962 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -767,7 +767,6 @@ static int hci_sock_dev_event(struct notifier_block *th=
is, unsigned long event,
 		/* Detach sockets from device */
 		read_lock(&hci_sk_list.lock);
 		sk_for_each(sk, node, &hci_sk_list.head) {
-			local_bh_disable();
 			bh_lock_sock_nested(sk);
 			if (hci_pi(sk)->hdev =3D=3D hdev) {
 				hci_pi(sk)->hdev =3D NULL;
@@ -778,7 +777,6 @@ static int hci_sock_dev_event(struct notifier_block *th=
is, unsigned long event,
 				hci_dev_put(hdev);
 			}
 			bh_unlock_sock(sk);
-			local_bh_enable();
 		}
 		read_unlock(&hci_sk_list.lock);
 	}
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index aa78d8c..faf0b11 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -165,7 +165,7 @@ int l2cap_add_psm(struct l2cap_chan *chan, bdaddr_t *sr=
c, __le16 psm)
 {
 	int err;
=20
-	write_lock_bh(&chan_list_lock);
+	write_lock(&chan_list_lock);
=20
 	if (psm && __l2cap_global_chan_by_addr(psm, src)) {
 		err =3D -EADDRINUSE;
@@ -190,17 +190,17 @@ int l2cap_add_psm(struct l2cap_chan *chan, bdaddr_t *=
src, __le16 psm)
 	}
=20
 done:
-	write_unlock_bh(&chan_list_lock);
+	write_unlock(&chan_list_lock);
 	return err;
 }
=20
 int l2cap_add_scid(struct l2cap_chan *chan,  __u16 scid)
 {
-	write_lock_bh(&chan_list_lock);
+	write_lock(&chan_list_lock);
=20
 	chan->scid =3D scid;
=20
-	write_unlock_bh(&chan_list_lock);
+	write_unlock(&chan_list_lock);
=20
 	return 0;
 }
@@ -289,9 +289,9 @@ struct l2cap_chan *l2cap_chan_create(struct sock *sk)
=20
 	chan->sk =3D sk;
=20
-	write_lock_bh(&chan_list_lock);
+	write_lock(&chan_list_lock);
 	list_add(&chan->global_l, &chan_list);
-	write_unlock_bh(&chan_list_lock);
+	write_unlock(&chan_list_lock);
=20
 	INIT_DELAYED_WORK(&chan->chan_timer, l2cap_chan_timeout);
=20
@@ -306,9 +306,9 @@ struct l2cap_chan *l2cap_chan_create(struct sock *sk)
=20
 void l2cap_chan_destroy(struct l2cap_chan *chan)
 {
-	write_lock_bh(&chan_list_lock);
+	write_lock(&chan_list_lock);
 	list_del(&chan->global_l);
-	write_unlock_bh(&chan_list_lock);
+	write_unlock(&chan_list_lock);
=20
 	l2cap_chan_put(chan);
 }
@@ -543,14 +543,14 @@ static u8 l2cap_get_ident(struct l2cap_conn *conn)
 	 *  200 - 254 are used by utilities like l2ping, etc.
 	 */
=20
-	spin_lock_bh(&conn->lock);
+	spin_lock(&conn->lock);
=20
 	if (++conn->tx_ident > 128)
 		conn->tx_ident =3D 1;
=20
 	id =3D conn->tx_ident;
=20
-	spin_unlock_bh(&conn->lock);
+	spin_unlock(&conn->lock);
=20
 	return id;
 }
@@ -1190,7 +1190,7 @@ inline int l2cap_chan_connect(struct l2cap_chan *chan=
, __le16 psm, u16 cid, bdad
 	}
=20
 	/* Set destination address and psm */
-	bacpy(&bt_sk(sk)->dst, src);
+	bacpy(&bt_sk(sk)->dst, dst);
 	chan->psm =3D psm;
 	chan->dcid =3D cid;
=20
@@ -4702,7 +4702,7 @@ static int l2cap_debugfs_show(struct seq_file *f, voi=
d *p)
 {
 	struct l2cap_chan *c;
=20
-	read_lock_bh(&chan_list_lock);
+	read_lock(&chan_list_lock);
=20
 	list_for_each_entry(c, &chan_list, global_l) {
 		struct sock *sk =3D c->sk;
@@ -4715,7 +4715,7 @@ static int l2cap_debugfs_show(struct seq_file *f, voi=
d *p)
 					c->sec_level, c->mode);
 }
=20
-	read_unlock_bh(&chan_list_lock);
+	read_unlock(&chan_list_lock);
=20
 	return 0;
 }
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 9ca5616..c61d967 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -587,6 +587,7 @@ static int l2cap_sock_setsockopt(struct socket *sock, i=
nt level, int optname, ch
 			if (smp_conn_security(conn, sec.level))
 				break;
 			sk->sk_state =3D BT_CONFIG;
+			chan->state =3D BT_CONFIG;
=20
 		/* or for ACL link, under defer_setup time */
 		} else if (sk->sk_state =3D=3D BT_CONNECT2 &&
@@ -731,6 +732,7 @@ static int l2cap_sock_recvmsg(struct kiocb *iocb, struc=
t socket *sock, struct ms
=20
 	if (sk->sk_state =3D=3D BT_CONNECT2 && bt_sk(sk)->defer_setup) {
 		sk->sk_state =3D BT_CONFIG;
+		pi->chan->state =3D BT_CONFIG;
=20
 		__l2cap_connect_rsp_defer(pi->chan);
 		release_sock(sk);
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 2540944..bc8e59d 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -291,7 +291,7 @@ static u32 get_current_settings(struct hci_dev *hdev)
 	if (!(hdev->features[4] & LMP_NO_BREDR))
 		settings |=3D MGMT_SETTING_BREDR;
=20
-	if (hdev->extfeatures[0] & LMP_HOST_LE)
+	if (hdev->host_features[0] & LMP_HOST_LE)
 		settings |=3D MGMT_SETTING_LE;
=20
 	if (test_bit(HCI_AUTH, &hdev->flags))
@@ -2756,7 +2756,7 @@ int mgmt_stop_discovery_failed(struct hci_dev *hdev, =
u8 status)
 	if (!cmd)
 		return -ENOENT;
=20
-	err =3D cmd_status(cmd->sk, hdev->id, cmd->opcode, status);
+	err =3D cmd_status(cmd->sk, hdev->id, cmd->opcode, mgmt_status(status));
 	mgmt_pending_remove(cmd);
=20
 	return err;
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index aea2bdd..f066678 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -370,7 +370,7 @@ static int rfcomm_sock_bind(struct socket *sock, struct=
 sockaddr *addr, int addr
 		goto done;
 	}
=20
-	write_lock_bh(&rfcomm_sk_list.lock);
+	write_lock(&rfcomm_sk_list.lock);
=20
 	if (sa->rc_channel && __rfcomm_get_sock_by_addr(sa->rc_channel, &sa->rc_b=
daddr)) {
 		err =3D -EADDRINUSE;
@@ -381,7 +381,7 @@ static int rfcomm_sock_bind(struct socket *sock, struct=
 sockaddr *addr, int addr
 		sk->sk_state =3D BT_BOUND;
 	}
=20
-	write_unlock_bh(&rfcomm_sk_list.lock);
+	write_unlock(&rfcomm_sk_list.lock);
=20
 done:
 	release_sock(sk);
@@ -455,7 +455,7 @@ static int rfcomm_sock_listen(struct socket *sock, int =
backlog)
=20
 		err =3D -EINVAL;
=20
-		write_lock_bh(&rfcomm_sk_list.lock);
+		write_lock(&rfcomm_sk_list.lock);
=20
 		for (channel =3D 1; channel < 31; channel++)
 			if (!__rfcomm_get_sock_by_addr(channel, src)) {
@@ -464,7 +464,7 @@ static int rfcomm_sock_listen(struct socket *sock, int =
backlog)
 				break;
 			}
=20
-		write_unlock_bh(&rfcomm_sk_list.lock);
+		write_unlock(&rfcomm_sk_list.lock);
=20
 		if (err < 0)
 			goto done;
@@ -982,7 +982,7 @@ static int rfcomm_sock_debugfs_show(struct seq_file *f,=
 void *p)
 	struct sock *sk;
 	struct hlist_node *node;
=20
-	read_lock_bh(&rfcomm_sk_list.lock);
+	read_lock(&rfcomm_sk_list.lock);
=20
 	sk_for_each(sk, node, &rfcomm_sk_list.head) {
 		seq_printf(f, "%s %s %d %d\n",
@@ -991,7 +991,7 @@ static int rfcomm_sock_debugfs_show(struct seq_file *f,=
 void *p)
 				sk->sk_state, rfcomm_pi(sk)->channel);
 	}
=20
-	read_unlock_bh(&rfcomm_sk_list.lock);
+	read_unlock(&rfcomm_sk_list.lock);
=20
 	return 0;
 }
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index fa8f4de5..a2d4f51 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -76,7 +76,7 @@ struct rfcomm_dev {
 };
=20
 static LIST_HEAD(rfcomm_dev_list);
-static DEFINE_RWLOCK(rfcomm_dev_lock);
+static DEFINE_SPINLOCK(rfcomm_dev_lock);
=20
 static void rfcomm_dev_data_ready(struct rfcomm_dlc *dlc, struct sk_buff *=
skb);
 static void rfcomm_dev_state_change(struct rfcomm_dlc *dlc, int err);
@@ -146,7 +146,7 @@ static inline struct rfcomm_dev *rfcomm_dev_get(int id)
 {
 	struct rfcomm_dev *dev;
=20
-	read_lock(&rfcomm_dev_lock);
+	spin_lock(&rfcomm_dev_lock);
=20
 	dev =3D __rfcomm_dev_get(id);
=20
@@ -157,7 +157,7 @@ static inline struct rfcomm_dev *rfcomm_dev_get(int id)
 			rfcomm_dev_hold(dev);
 	}
=20
-	read_unlock(&rfcomm_dev_lock);
+	spin_unlock(&rfcomm_dev_lock);
=20
 	return dev;
 }
@@ -205,7 +205,7 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *req, s=
truct rfcomm_dlc *dlc)
 	if (!dev)
 		return -ENOMEM;
=20
-	write_lock_bh(&rfcomm_dev_lock);
+	spin_lock(&rfcomm_dev_lock);
=20
 	if (req->dev_id < 0) {
 		dev->id =3D 0;
@@ -290,7 +290,7 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *req, s=
truct rfcomm_dlc *dlc)
 	__module_get(THIS_MODULE);
=20
 out:
-	write_unlock_bh(&rfcomm_dev_lock);
+	spin_unlock(&rfcomm_dev_lock);
=20
 	if (err < 0)
 		goto free;
@@ -327,9 +327,9 @@ static void rfcomm_dev_del(struct rfcomm_dev *dev)
 	if (atomic_read(&dev->opened) > 0)
 		return;
=20
-	write_lock_bh(&rfcomm_dev_lock);
+	spin_lock(&rfcomm_dev_lock);
 	list_del_init(&dev->list);
-	write_unlock_bh(&rfcomm_dev_lock);
+	spin_unlock(&rfcomm_dev_lock);
=20
 	rfcomm_dev_put(dev);
 }
@@ -473,7 +473,7 @@ static int rfcomm_get_dev_list(void __user *arg)
=20
 	di =3D dl->dev_info;
=20
-	read_lock_bh(&rfcomm_dev_lock);
+	spin_lock(&rfcomm_dev_lock);
=20
 	list_for_each_entry(dev, &rfcomm_dev_list, list) {
 		if (test_bit(RFCOMM_TTY_RELEASED, &dev->flags))
@@ -488,7 +488,7 @@ static int rfcomm_get_dev_list(void __user *arg)
 			break;
 	}
=20
-	read_unlock_bh(&rfcomm_dev_lock);
+	spin_unlock(&rfcomm_dev_lock);
=20
 	dl->dev_num =3D n;
 	size =3D sizeof(*dl) + n * sizeof(*di);
@@ -766,9 +766,9 @@ static void rfcomm_tty_close(struct tty_struct *tty, st=
ruct file *filp)
 		rfcomm_dlc_unlock(dev->dlc);
=20
 		if (test_bit(RFCOMM_TTY_RELEASED, &dev->flags)) {
-			write_lock_bh(&rfcomm_dev_lock);
+			spin_lock(&rfcomm_dev_lock);
 			list_del_init(&dev->list);
-			write_unlock_bh(&rfcomm_dev_lock);
+			spin_unlock(&rfcomm_dev_lock);
=20
 			rfcomm_dev_put(dev);
 		}
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 5dc2f21..8bf26d1 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -482,7 +482,7 @@ static int sco_sock_bind(struct socket *sock, struct so=
ckaddr *addr, int addr_le
 		goto done;
 	}
=20
-	write_lock_bh(&sco_sk_list.lock);
+	write_lock(&sco_sk_list.lock);
=20
 	if (bacmp(src, BDADDR_ANY) && __sco_get_sock_by_addr(src)) {
 		err =3D -EADDRINUSE;
@@ -492,7 +492,7 @@ static int sco_sock_bind(struct socket *sock, struct so=
ckaddr *addr, int addr_le
 		sk->sk_state =3D BT_BOUND;
 	}
=20
-	write_unlock_bh(&sco_sk_list.lock);
+	write_unlock(&sco_sk_list.lock);
=20
 done:
 	release_sock(sk);
@@ -965,14 +965,14 @@ static int sco_debugfs_show(struct seq_file *f, void =
*p)
 	struct sock *sk;
 	struct hlist_node *node;
=20
-	read_lock_bh(&sco_sk_list.lock);
+	read_lock(&sco_sk_list.lock);
=20
 	sk_for_each(sk, node, &sco_sk_list.head) {
 		seq_printf(f, "%s %s %d\n", batostr(&bt_sk(sk)->src),
 				batostr(&bt_sk(sk)->dst), sk->sk_state);
 	}
=20
-	read_unlock_bh(&sco_sk_list.lock);
+	read_unlock(&sco_sk_list.lock);
=20
 	return 0;
 }
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 93aab07..422b798 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -106,7 +106,7 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_rx_d=
ata *rx)
 		if (status->flag & RX_FLAG_MMIC_ERROR)
 			goto mic_fail;
=20
-		if (!(status->flag & RX_FLAG_IV_STRIPPED))
+		if (!(status->flag & RX_FLAG_IV_STRIPPED) && rx->key)
 			goto update_iv;
=20
 		return RX_CONTINUE;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index b3d3cf8..afeea32 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2250,6 +2250,7 @@ static const struct nla_policy sta_flags_policy[NL802=
11_STA_FLAG_MAX + 1] =3D {
 };
=20
 static int parse_station_flags(struct genl_info *info,
+			       enum nl80211_iftype iftype,
 			       struct station_parameters *params)
 {
 	struct nlattr *flags[NL80211_STA_FLAG_MAX + 1];
@@ -2283,8 +2284,33 @@ static int parse_station_flags(struct genl_info *inf=
o,
 			     nla, sta_flags_policy))
 		return -EINVAL;
=20
-	params->sta_flags_mask =3D (1 << __NL80211_STA_FLAG_AFTER_LAST) - 1;
-	params->sta_flags_mask &=3D ~1;
+	/*
+	 * Only allow certain flags for interface types so that
+	 * other attributes are silently ignored. Remember that
+	 * this is backward compatibility code with old userspace
+	 * and shouldn't be hit in other cases anyway.
+	 */
+	switch (iftype) {
+	case NL80211_IFTYPE_AP:
+	case NL80211_IFTYPE_AP_VLAN:
+	case NL80211_IFTYPE_P2P_GO:
+		params->sta_flags_mask =3D BIT(NL80211_STA_FLAG_AUTHORIZED) |
+					 BIT(NL80211_STA_FLAG_SHORT_PREAMBLE) |
+					 BIT(NL80211_STA_FLAG_WME) |
+					 BIT(NL80211_STA_FLAG_MFP);
+		break;
+	case NL80211_IFTYPE_P2P_CLIENT:
+	case NL80211_IFTYPE_STATION:
+		params->sta_flags_mask =3D BIT(NL80211_STA_FLAG_AUTHORIZED) |
+					 BIT(NL80211_STA_FLAG_TDLS_PEER);
+		break;
+	case NL80211_IFTYPE_MESH_POINT:
+		params->sta_flags_mask =3D BIT(NL80211_STA_FLAG_AUTHENTICATED) |
+					 BIT(NL80211_STA_FLAG_MFP) |
+					 BIT(NL80211_STA_FLAG_AUTHORIZED);
+	default:
+		return -EINVAL;
+	}
=20
 	for (flag =3D 1; flag <=3D NL80211_STA_FLAG_MAX; flag++)
 		if (flags[flag])
@@ -2585,7 +2611,7 @@ static int nl80211_set_station(struct sk_buff *skb, s=
truct genl_info *info)
 	if (!rdev->ops->change_station)
 		return -EOPNOTSUPP;
=20
-	if (parse_station_flags(info, &params))
+	if (parse_station_flags(info, dev->ieee80211_ptr->iftype, &params))
 		return -EINVAL;
=20
 	if (info->attrs[NL80211_ATTR_STA_PLINK_ACTION])
@@ -2731,7 +2757,7 @@ static int nl80211_new_station(struct sk_buff *skb, s=
truct genl_info *info)
 	if (!rdev->ops->add_station)
 		return -EOPNOTSUPP;
=20
-	if (parse_station_flags(info, &params))
+	if (parse_station_flags(info, dev->ieee80211_ptr->iftype, &params))
 		return -EINVAL;
=20
 	switch (dev->ieee80211_ptr->iftype) {
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPDysvAAoJEJctW/TcYTgG8JIQAJJ938hpmVljN2xeYdHymOLJ
V7IP8xG9QazTCe574S7+uCj3juUNekJrL6MB31Jm7hPlhb3mCBcb4nCf2s3w9Lxv
/eaxs99G8Dmdp+qs1z673/sO1H9nwrxxoextfdudM8365hByvERUG1gaM3HVOLWA
fGN2Qr+n2qkuqQfSCq4Paq4okFZIpZVnk1rFxoU/VuXqyVQvNDy4FAua0ROPNzfa
guedQvMz2fzWn77qyNnj9+3D3w2sWonPcEtTjTALeDnR7VCkyUzwM1Q3xK+6rtSX
OfSWQ1N9HjAy+0VepvGvoUIrS5UfU6HHF31o7PbEHuC1g0+joMLsNxHZBe4CTDQD
GFloraG6pZNFk2JJaMvvM8gHeGjwXx1vS3t/PuamqHEBuBk6QCDdE6Zqcu6bnNfE
zghcLoS9mK77m5QBQmE9QjTDCVpQwEkulJpCNJ3oGWSQuj+WudKyEw7x9H8TvrrS
Oe3v17F7QpBa1SjCRU8B+aRid3X3yzjLKlNA9/iLOzAugQ39dRWUyaYD/aN/6hA/
XvAKJav5Gkfja48Yn8uDgehNZzCVZuDSSGb49zedCR688b244YkTZqQJOe6mYSgl
gUiF8Jqeh49WD67a4s2RVXIgCw56Anroo46UK/0+MT50hFsvE98GNX7yN/y3PaVt
cvlKMDHnsDoKvi+Pb5YI
=uc91
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
