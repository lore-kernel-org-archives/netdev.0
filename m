From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-07-08
Date: Fri, 8 Jul 2011 12:21:44 -0400
Message-ID: <20110708162144.GA15143@tuxdriver.com>
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

Dave,

Here is a final(?) batch of wireless-related fixes intended for 3.0.
Included are a fix for a TKIP replay vulnerability from Johannes, a
locking fix related to rfkill and a memory corruption fix from Luca,
an SSB initialization fix from Rafa=C5=82, an ath9k performance regress=
ion
fix from Rajkumar, and some fixes from Pavel for sysfs bad pointer
accesses in ath5k.

Also included are some Bluetooth fixes.  Gustavo described them thusly:

	There are here two regression fixes, a hidp deadlock hang up
	of the system fix from Peter Hurley. As the commit messages
	says it is a partial revert from a commit that adds kthread
	to hidp. And L2CAP incoming connection request fix that
	was breaking one test in the PTS suit, that is, breaking
	interop. Patch is based on code from Ilia Kolomisnky.  Also,
	a buffer overflow fix by Dan Rosenberg and finally Tomas
	Targownik fixed a memory leak on failed connections attempts
	that seems to be around since 2006!!

I also included a couple of device ID additions -- I hope that's OK.

Please let me know if there are problems!

John

---

The following changes since commit f8d9605243280f1870dd2c6c37a735b925c1=
5f3c:

  sctp: Enforce retransmission limit during shutdown (2011-07-07 14:08:=
44 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it for-davem

Christian Lamparter (1):
      carl9170: add NEC WL300NU-AG usbid

Dan Rosenberg (1):
      Bluetooth: Prevent buffer overflow in l2cap config request

Gustavo F. Padovan (1):
      Bluetooth: Fix regression with incoming L2CAP connections

Johannes Berg (1):
      mac80211: fix TKIP replay vulnerability

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into for-davem

Luciano Coelho (2):
      cfg80211: fix deadlock with rfkill/sched_scan by adding new mutex
      mac80211: fix ie memory allocation for scheduled scans

Pavel Roskin (2):
      ath5k: fix incorrect use of drvdata in sysfs code
      ath5k: fix incorrect use of drvdata in PCI suspend/resume code

Peter Hurley (1):
      Bluetooth: Fix hidp disconnect deadlocks and lost wakeup

Rafa=C5=82 Mi=C5=82ecki (1):
      ssb: fix init regression of hostmode PCI core

Rajkumar Manoharan (1):
      ath9k: Fix tx throughput drops for AR9003 chips with AES encrypti=
on

Tomas Targownik (1):
      Bluetooth: Fix memory leak under page timeouts

Yoann DI-RUZZA (1):
      rtlwifi: rtl8192cu: Add new USB ID for Netgear WNA1000M

 drivers/net/wireless/ath/ath5k/pci.c        |    7 +++++--
 drivers/net/wireless/ath/ath5k/sysfs.c      |    9 ++++++---
 drivers/net/wireless/ath/ath9k/xmit.c       |    3 ++-
 drivers/net/wireless/ath/carl9170/usb.c     |    2 ++
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c |    1 +
 drivers/ssb/driver_pcicore.c                |   18 +++++++++---------
 net/bluetooth/hci_conn.c                    |    3 +++
 net/bluetooth/hidp/core.c                   |   18 +++++++++++-------
 net/bluetooth/hidp/hidp.h                   |    1 +
 net/bluetooth/l2cap_core.c                  |    5 +++--
 net/mac80211/scan.c                         |    3 ++-
 net/mac80211/wpa.c                          |   16 +++++++++++++---
 net/wireless/core.c                         |   12 +++++++++---
 net/wireless/core.h                         |    2 ++
 net/wireless/nl80211.c                      |   24 ++++++++++++++++++-=
-----
 net/wireless/scan.c                         |   10 +++++-----
 16 files changed, 92 insertions(+), 42 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireles=
s/ath/ath5k/pci.c
index 296c316..f2c0c23 100644
--- a/drivers/net/wireless/ath/ath5k/pci.c
+++ b/drivers/net/wireless/ath/ath5k/pci.c
@@ -297,7 +297,9 @@ ath5k_pci_remove(struct pci_dev *pdev)
 #ifdef CONFIG_PM_SLEEP
 static int ath5k_pci_suspend(struct device *dev)
 {
-	struct ath5k_softc *sc =3D pci_get_drvdata(to_pci_dev(dev));
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct ieee80211_hw *hw =3D pci_get_drvdata(pdev);
+	struct ath5k_softc *sc =3D hw->priv;
=20
 	ath5k_led_off(sc);
 	return 0;
@@ -306,7 +308,8 @@ static int ath5k_pci_suspend(struct device *dev)
 static int ath5k_pci_resume(struct device *dev)
 {
 	struct pci_dev *pdev =3D to_pci_dev(dev);
-	struct ath5k_softc *sc =3D pci_get_drvdata(pdev);
+	struct ieee80211_hw *hw =3D pci_get_drvdata(pdev);
+	struct ath5k_softc *sc =3D hw->priv;
=20
 	/*
 	 * Suspend/Resume resets the PCI configuration space, so we have to
diff --git a/drivers/net/wireless/ath/ath5k/sysfs.c b/drivers/net/wirel=
ess/ath/ath5k/sysfs.c
index 929c68c..a073cdc 100644
--- a/drivers/net/wireless/ath/ath5k/sysfs.c
+++ b/drivers/net/wireless/ath/ath5k/sysfs.c
@@ -10,7 +10,8 @@ static ssize_t ath5k_attr_show_##name(struct device *=
dev,		\
 			struct device_attribute *attr,			\
 			char *buf)					\
 {									\
-	struct ath5k_softc *sc =3D dev_get_drvdata(dev);			\
+	struct ieee80211_hw *hw =3D dev_get_drvdata(dev);			\
+	struct ath5k_softc *sc =3D hw->priv;				\
 	return snprintf(buf, PAGE_SIZE, "%d\n", get); 			\
 }									\
 									\
@@ -18,7 +19,8 @@ static ssize_t ath5k_attr_store_##name(struct device =
*dev,		\
 			struct device_attribute *attr,			\
 			const char *buf, size_t count)			\
 {									\
-	struct ath5k_softc *sc =3D dev_get_drvdata(dev);			\
+	struct ieee80211_hw *hw =3D dev_get_drvdata(dev);			\
+	struct ath5k_softc *sc =3D hw->priv;				\
 	int val;							\
 									\
 	val =3D (int)simple_strtoul(buf, NULL, 10);			\
@@ -33,7 +35,8 @@ static ssize_t ath5k_attr_show_##name(struct device *=
dev,		\
 			struct device_attribute *attr,			\
 			char *buf)					\
 {									\
-	struct ath5k_softc *sc =3D dev_get_drvdata(dev);			\
+	struct ieee80211_hw *hw =3D dev_get_drvdata(dev);			\
+	struct ath5k_softc *sc =3D hw->priv;				\
 	return snprintf(buf, PAGE_SIZE, "%d\n", get); 			\
 }									\
 static DEVICE_ATTR(name, S_IRUGO, ath5k_attr_show_##name, NULL)
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wirele=
ss/ath/ath9k/xmit.c
index 3779b89..33443bc 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -671,7 +671,8 @@ static int ath_compute_num_delims(struct ath_softc =
*sc, struct ath_atx_tid *tid,
 	 * TODO - this could be improved to be dependent on the rate.
 	 *      The hardware can keep up at lower rates, but not higher rates
 	 */
-	if (fi->keyix !=3D ATH9K_TXKEYIX_INVALID)
+	if ((fi->keyix !=3D ATH9K_TXKEYIX_INVALID) &&
+	    !(sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA))
 		ndelim +=3D ATH_AGGR_ENCRYPTDELIM;
=20
 	/*
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wire=
less/ath/carl9170/usb.c
index 2fb53d0..333b69e 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -112,6 +112,8 @@ static struct usb_device_id carl9170_usb_ids[] =3D =
{
 	{ USB_DEVICE(0x04bb, 0x093f) },
 	/* NEC WL300NU-G */
 	{ USB_DEVICE(0x0409, 0x0249) },
+	/* NEC WL300NU-AG */
+	{ USB_DEVICE(0x0409, 0x02b4) },
 	/* AVM FRITZ!WLAN USB Stick N */
 	{ USB_DEVICE(0x057c, 0x8401) },
 	/* AVM FRITZ!WLAN USB Stick N 2.4 */
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/=
wireless/rtlwifi/rtl8192cu/sw.c
index 092e342..942f7a3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -298,6 +298,7 @@ static struct usb_device_id rtl8192c_usb_ids[] =3D =
{
 	{RTL_USB_DEVICE(0x06f8, 0xe033, rtl92cu_hal_cfg)}, /*Hercules - Edima=
x*/
 	{RTL_USB_DEVICE(0x07b8, 0x8188, rtl92cu_hal_cfg)}, /*Abocom - Abocom*=
/
 	{RTL_USB_DEVICE(0x07b8, 0x8189, rtl92cu_hal_cfg)}, /*Funai - Abocom*/
+	{RTL_USB_DEVICE(0x0846, 0x9041, rtl92cu_hal_cfg)}, /*NetGear WNA1000M=
*/
 	{RTL_USB_DEVICE(0x0Df6, 0x0052, rtl92cu_hal_cfg)}, /*Sitecom - Edimax=
*/
 	{RTL_USB_DEVICE(0x0eb0, 0x9071, rtl92cu_hal_cfg)}, /*NO Brand - Etop*=
/
 	/* HP - Lite-On ,8188CUS Slim Combo */
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.=
c
index 2a20dab..d6620ad 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -516,8 +516,17 @@ static void ssb_pcicore_pcie_setup_workarounds(str=
uct ssb_pcicore *pc)
=20
 static void ssb_pcicore_init_clientmode(struct ssb_pcicore *pc)
 {
+	ssb_pcicore_fix_sprom_core_index(pc);
+
 	/* Disable PCI interrupts. */
 	ssb_write32(pc->dev, SSB_INTVEC, 0);
+
+	/* Additional PCIe always once-executed workarounds */
+	if (pc->dev->id.coreid =3D=3D SSB_DEV_PCIE) {
+		ssb_pcicore_serdes_workaround(pc);
+		/* TODO: ASPM */
+		/* TODO: Clock Request Update */
+	}
 }
=20
 void ssb_pcicore_init(struct ssb_pcicore *pc)
@@ -529,8 +538,6 @@ void ssb_pcicore_init(struct ssb_pcicore *pc)
 	if (!ssb_device_is_enabled(dev))
 		ssb_device_enable(dev, 0);
=20
-	ssb_pcicore_fix_sprom_core_index(pc);
-
 #ifdef CONFIG_SSB_PCICORE_HOSTMODE
 	pc->hostmode =3D pcicore_is_in_hostmode(pc);
 	if (pc->hostmode)
@@ -538,13 +545,6 @@ void ssb_pcicore_init(struct ssb_pcicore *pc)
 #endif /* CONFIG_SSB_PCICORE_HOSTMODE */
 	if (!pc->hostmode)
 		ssb_pcicore_init_clientmode(pc);
-
-	/* Additional PCIe always once-executed workarounds */
-	if (dev->id.coreid =3D=3D SSB_DEV_PCIE) {
-		ssb_pcicore_serdes_workaround(pc);
-		/* TODO: ASPM */
-		/* TODO: Clock Request Update */
-	}
 }
=20
 static u32 ssb_pcie_read(struct ssb_pcicore *pc, u32 address)
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index d3a05b9..bcd158f 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -393,6 +393,9 @@ int hci_conn_del(struct hci_conn *conn)
=20
 	hci_dev_put(hdev);
=20
+	if (conn->handle =3D=3D 0)
+		kfree(conn);
+
 	return 0;
 }
=20
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index c405a95..43b4c2d 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -464,7 +464,8 @@ static void hidp_idle_timeout(unsigned long arg)
 {
 	struct hidp_session *session =3D (struct hidp_session *) arg;
=20
-	kthread_stop(session->task);
+	atomic_inc(&session->terminate);
+	wake_up_process(session->task);
 }
=20
 static void hidp_set_timer(struct hidp_session *session)
@@ -535,7 +536,8 @@ static void hidp_process_hid_control(struct hidp_se=
ssion *session,
 		skb_queue_purge(&session->ctrl_transmit);
 		skb_queue_purge(&session->intr_transmit);
=20
-		kthread_stop(session->task);
+		atomic_inc(&session->terminate);
+		wake_up_process(current);
 	}
 }
=20
@@ -706,9 +708,8 @@ static int hidp_session(void *arg)
 	add_wait_queue(sk_sleep(intr_sk), &intr_wait);
 	session->waiting_for_startup =3D 0;
 	wake_up_interruptible(&session->startup_queue);
-	while (!kthread_should_stop()) {
-		set_current_state(TASK_INTERRUPTIBLE);
-
+	set_current_state(TASK_INTERRUPTIBLE);
+	while (!atomic_read(&session->terminate)) {
 		if (ctrl_sk->sk_state !=3D BT_CONNECTED ||
 				intr_sk->sk_state !=3D BT_CONNECTED)
 			break;
@@ -726,6 +727,7 @@ static int hidp_session(void *arg)
 		hidp_process_transmit(session);
=20
 		schedule();
+		set_current_state(TASK_INTERRUPTIBLE);
 	}
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(intr_sk), &intr_wait);
@@ -1060,7 +1062,8 @@ int hidp_add_connection(struct hidp_connadd_req *=
req, struct socket *ctrl_sock,
 err_add_device:
 	hid_destroy_device(session->hid);
 	session->hid =3D NULL;
-	kthread_stop(session->task);
+	atomic_inc(&session->terminate);
+	wake_up_process(session->task);
=20
 unlink:
 	hidp_del_timer(session);
@@ -1111,7 +1114,8 @@ int hidp_del_connection(struct hidp_conndel_req *=
req)
 			skb_queue_purge(&session->ctrl_transmit);
 			skb_queue_purge(&session->intr_transmit);
=20
-			kthread_stop(session->task);
+			atomic_inc(&session->terminate);
+			wake_up_process(session->task);
 		}
 	} else
 		err =3D -ENOENT;
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index 19e9500..af1bcc8 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -142,6 +142,7 @@ struct hidp_session {
 	uint ctrl_mtu;
 	uint intr_mtu;
=20
+	atomic_t terminate;
 	struct task_struct *task;
=20
 	unsigned char keys[8];
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 56fdd91..ebff14c 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2323,7 +2323,8 @@ static inline int l2cap_config_req(struct l2cap_c=
onn *conn, struct l2cap_cmd_hdr
=20
 	sk =3D chan->sk;
=20
-	if (sk->sk_state !=3D BT_CONFIG) {
+	if ((bt_sk(sk)->defer_setup && sk->sk_state !=3D BT_CONNECT2) ||
+		 (!bt_sk(sk)->defer_setup && sk->sk_state !=3D BT_CONFIG)) {
 		struct l2cap_cmd_rej rej;
=20
 		rej.reason =3D cpu_to_le16(0x0002);
@@ -2334,7 +2335,7 @@ static inline int l2cap_config_req(struct l2cap_c=
onn *conn, struct l2cap_cmd_hdr
=20
 	/* Reject if config buffer is too small. */
 	len =3D cmd_len - sizeof(*req);
-	if (chan->conf_len + len > sizeof(chan->conf_req)) {
+	if (len < 0 || chan->conf_len + len > sizeof(chan->conf_req)) {
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_CONF_RSP,
 				l2cap_build_conf_rsp(chan, rsp,
 					L2CAP_CONF_REJECT, flags), rsp);
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 58ffa7d..669d2e3 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -877,7 +877,8 @@ int ieee80211_request_sched_scan_start(struct ieee8=
0211_sub_if_data *sdata,
 	for (i =3D 0; i < IEEE80211_NUM_BANDS; i++) {
 		local->sched_scan_ies.ie[i] =3D kzalloc(2 +
 						      IEEE80211_MAX_SSID_LEN +
-						      local->scan_ies_len,
+						      local->scan_ies_len +
+						      req->ie_len,
 						      GFP_KERNEL);
 		if (!local->sched_scan_ies.ie[i]) {
 			ret =3D -ENOMEM;
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index d91c1a2..8f6a302 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -86,6 +86,11 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_r=
x_data *rx)
 	struct sk_buff *skb =3D rx->skb;
 	struct ieee80211_rx_status *status =3D IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)skb->data;
+	int queue =3D rx->queue;
+
+	/* otherwise, TKIP is vulnerable to TID 0 vs. non-QoS replays */
+	if (rx->queue =3D=3D NUM_RX_DATA_QUEUES - 1)
+		queue =3D 0;
=20
 	/*
 	 * it makes no sense to check for MIC errors on anything other
@@ -148,8 +153,8 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_=
rx_data *rx)
=20
 update_iv:
 	/* update IV in key information to be able to detect replays */
-	rx->key->u.tkip.rx[rx->queue].iv32 =3D rx->tkip_iv32;
-	rx->key->u.tkip.rx[rx->queue].iv16 =3D rx->tkip_iv16;
+	rx->key->u.tkip.rx[queue].iv32 =3D rx->tkip_iv32;
+	rx->key->u.tkip.rx[queue].iv16 =3D rx->tkip_iv16;
=20
 	return RX_CONTINUE;
=20
@@ -241,6 +246,11 @@ ieee80211_crypto_tkip_decrypt(struct ieee80211_rx_=
data *rx)
 	struct ieee80211_key *key =3D rx->key;
 	struct sk_buff *skb =3D rx->skb;
 	struct ieee80211_rx_status *status =3D IEEE80211_SKB_RXCB(skb);
+	int queue =3D rx->queue;
+
+	/* otherwise, TKIP is vulnerable to TID 0 vs. non-QoS replays */
+	if (rx->queue =3D=3D NUM_RX_DATA_QUEUES - 1)
+		queue =3D 0;
=20
 	hdrlen =3D ieee80211_hdrlen(hdr->frame_control);
=20
@@ -261,7 +271,7 @@ ieee80211_crypto_tkip_decrypt(struct ieee80211_rx_d=
ata *rx)
 	res =3D ieee80211_tkip_decrypt_data(rx->local->wep_rx_tfm,
 					  key, skb->data + hdrlen,
 					  skb->len - hdrlen, rx->sta->sta.addr,
-					  hdr->addr1, hwaccel, rx->queue,
+					  hdr->addr1, hwaccel, queue,
 					  &rx->tkip_iv32,
 					  &rx->tkip_iv16);
 	if (res !=3D TKIP_DECRYPT_OK)
diff --git a/net/wireless/core.c b/net/wireless/core.c
index c22ef34..880dbe2 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -366,6 +366,7 @@ struct wiphy *wiphy_new(const struct cfg80211_ops *=
ops, int sizeof_priv)
=20
 	mutex_init(&rdev->mtx);
 	mutex_init(&rdev->devlist_mtx);
+	mutex_init(&rdev->sched_scan_mtx);
 	INIT_LIST_HEAD(&rdev->netdev_list);
 	spin_lock_init(&rdev->bss_lock);
 	INIT_LIST_HEAD(&rdev->bss_list);
@@ -701,6 +702,7 @@ void cfg80211_dev_free(struct cfg80211_registered_d=
evice *rdev)
 	rfkill_destroy(rdev->rfkill);
 	mutex_destroy(&rdev->mtx);
 	mutex_destroy(&rdev->devlist_mtx);
+	mutex_destroy(&rdev->sched_scan_mtx);
 	list_for_each_entry_safe(scan, tmp, &rdev->bss_list, list)
 		cfg80211_put_bss(&scan->pub);
 	cfg80211_rdev_free_wowlan(rdev);
@@ -737,12 +739,16 @@ static void wdev_cleanup_work(struct work_struct =
*work)
 		___cfg80211_scan_done(rdev, true);
 	}
=20
+	cfg80211_unlock_rdev(rdev);
+
+	mutex_lock(&rdev->sched_scan_mtx);
+
 	if (WARN_ON(rdev->sched_scan_req &&
 		    rdev->sched_scan_req->dev =3D=3D wdev->netdev)) {
 		__cfg80211_stop_sched_scan(rdev, false);
 	}
=20
-	cfg80211_unlock_rdev(rdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
=20
 	mutex_lock(&rdev->devlist_mtx);
 	rdev->opencount--;
@@ -830,9 +836,9 @@ static int cfg80211_netdev_notifier_call(struct not=
ifier_block * nb,
 			break;
 		case NL80211_IFTYPE_P2P_CLIENT:
 		case NL80211_IFTYPE_STATION:
-			cfg80211_lock_rdev(rdev);
+			mutex_lock(&rdev->sched_scan_mtx);
 			__cfg80211_stop_sched_scan(rdev, false);
-			cfg80211_unlock_rdev(rdev);
+			mutex_unlock(&rdev->sched_scan_mtx);
=20
 			wdev_lock(wdev);
 #ifdef CONFIG_CFG80211_WEXT
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 3dce1f1..a570ff9 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -65,6 +65,8 @@ struct cfg80211_registered_device {
 	struct work_struct scan_done_wk;
 	struct work_struct sched_scan_results_wk;
=20
+	struct mutex sched_scan_mtx;
+
 #ifdef CONFIG_NL80211_TESTMODE
 	struct genl_info *testmode_info;
 #endif
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index f07602d..cea3381 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3461,9 +3461,6 @@ static int nl80211_start_sched_scan(struct sk_buf=
f *skb,
 	if (!is_valid_ie_attr(info->attrs[NL80211_ATTR_IE]))
 		return -EINVAL;
=20
-	if (rdev->sched_scan_req)
-		return -EINPROGRESS;
-
 	if (!info->attrs[NL80211_ATTR_SCHED_SCAN_INTERVAL])
 		return -EINVAL;
=20
@@ -3502,12 +3499,21 @@ static int nl80211_start_sched_scan(struct sk_b=
uff *skb,
 	if (ie_len > wiphy->max_scan_ie_len)
 		return -EINVAL;
=20
+	mutex_lock(&rdev->sched_scan_mtx);
+
+	if (rdev->sched_scan_req) {
+		err =3D -EINPROGRESS;
+		goto out;
+	}
+
 	request =3D kzalloc(sizeof(*request)
 			+ sizeof(*request->ssids) * n_ssids
 			+ sizeof(*request->channels) * n_channels
 			+ ie_len, GFP_KERNEL);
-	if (!request)
-		return -ENOMEM;
+	if (!request) {
+		err =3D -ENOMEM;
+		goto out;
+	}
=20
 	if (n_ssids)
 		request->ssids =3D (void *)&request->channels[n_channels];
@@ -3605,6 +3611,7 @@ static int nl80211_start_sched_scan(struct sk_buf=
f *skb,
 out_free:
 	kfree(request);
 out:
+	mutex_unlock(&rdev->sched_scan_mtx);
 	return err;
 }
=20
@@ -3612,12 +3619,17 @@ static int nl80211_stop_sched_scan(struct sk_bu=
ff *skb,
 				   struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev =3D info->user_ptr[0];
+	int err;
=20
 	if (!(rdev->wiphy.flags & WIPHY_FLAG_SUPPORTS_SCHED_SCAN) ||
 	    !rdev->ops->sched_scan_stop)
 		return -EOPNOTSUPP;
=20
-	return __cfg80211_stop_sched_scan(rdev, false);
+	mutex_lock(&rdev->sched_scan_mtx);
+	err =3D __cfg80211_stop_sched_scan(rdev, false);
+	mutex_unlock(&rdev->sched_scan_mtx);
+
+	return err;
 }
=20
 static int nl80211_send_bss(struct sk_buff *msg, u32 pid, u32 seq, int=
 flags,
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 7a6c676..ae0c225 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -100,14 +100,14 @@ void __cfg80211_sched_scan_results(struct work_st=
ruct *wk)
 	rdev =3D container_of(wk, struct cfg80211_registered_device,
 			    sched_scan_results_wk);
=20
-	cfg80211_lock_rdev(rdev);
+	mutex_lock(&rdev->sched_scan_mtx);
=20
 	/* we don't have sched_scan_req anymore if the scan is stopping */
 	if (rdev->sched_scan_req)
 		nl80211_send_sched_scan_results(rdev,
 						rdev->sched_scan_req->dev);
=20
-	cfg80211_unlock_rdev(rdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
 }
=20
 void cfg80211_sched_scan_results(struct wiphy *wiphy)
@@ -123,9 +123,9 @@ void cfg80211_sched_scan_stopped(struct wiphy *wiph=
y)
 {
 	struct cfg80211_registered_device *rdev =3D wiphy_to_dev(wiphy);
=20
-	cfg80211_lock_rdev(rdev);
+	mutex_lock(&rdev->sched_scan_mtx);
 	__cfg80211_stop_sched_scan(rdev, true);
-	cfg80211_unlock_rdev(rdev);
+	mutex_unlock(&rdev->sched_scan_mtx);
 }
 EXPORT_SYMBOL(cfg80211_sched_scan_stopped);
=20
@@ -135,7 +135,7 @@ int __cfg80211_stop_sched_scan(struct cfg80211_regi=
stered_device *rdev,
 	int err;
 	struct net_device *dev;
=20
-	ASSERT_RDEV_LOCK(rdev);
+	lockdep_assert_held(&rdev->sched_scan_mtx);
=20
 	if (!rdev->sched_scan_req)
 		return 0;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
