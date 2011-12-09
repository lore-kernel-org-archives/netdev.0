From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wirelss 2011-12-09
Date: Fri, 9 Dec 2011 14:22:28 -0500
Message-ID: <20111209192228.GC14236@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0OAP2g/MAC+5xKAE"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit e7ab5f1c323e137120561daeec75e91a1bd9ec8b

Dave,

This is a collection of fixes intended for 3.2.

Gustavo describes the Blueooth bits thusly: "Some fixes for 3.2:
support for a new Marvell device, two module reference fixes, a memory
leak fix and finally a check in a HCI version check."

Additionally, we have an ath9k fix for a regression on single-stream
chips, a mac80211 fix for a race in aggregation start (looks big due
to moving some functions to avoid forward declarations), a fix for
some improper power state management in the rtlwifi suite, and a fix
for an ssb init regression on some SoCs.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1af32f0fcf33ddca52c8fd2b5bc84c129dcb1bdd:

  Merge branch 'batman-adv/maint' of git://git.open-mesh.org/linux-merge (2=
011-12-07 15:06:33 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Andrei Emeltchenko (1):
      Bluetooth: Correct version check in hci_setup

Bing Zhao (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8797

Cong Wang (1):
      btusb: fix a memory leak in btusb_send_frame()

David Herrmann (2):
      Bluetooth: cmtp: Fix module reference
      Bluetooth: bnep: Fix module reference

Felix Fietkau (1):
      ath9k: fix check for antenna diversity support

Hauke Mehrtens (1):
      ssb: fix init regression with SoCs

Johannes Berg (1):
      mac80211: fix another race in aggregation start

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Philipp Dreimann (1):
      rtl8192{ce,cu,de,se}: avoid problems because of possible ERFOFF -> ER=
FSLEEP transition

 drivers/bluetooth/Kconfig                    |    6 +-
 drivers/bluetooth/btmrvl_sdio.c              |   15 ++++-
 drivers/bluetooth/btusb.c                    |    3 +-
 drivers/net/wireless/ath/ath9k/main.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c |    2 +-
 drivers/ssb/driver_pcicore.c                 |    8 ++-
 net/bluetooth/bnep/core.c                    |    8 +--
 net/bluetooth/cmtp/core.c                    |    5 +-
 net/bluetooth/hci_event.c                    |    2 +-
 net/mac80211/agg-tx.c                        |   86 ++++++++++++----------=
---
 13 files changed, 76 insertions(+), 67 deletions(-)

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 11b41fd..5ccf142 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -188,7 +188,7 @@ config BT_MRVL
 	  The core driver to support Marvell Bluetooth devices.
=20
 	  This driver is required if you want to support
-	  Marvell Bluetooth devices, such as 8688/8787.
+	  Marvell Bluetooth devices, such as 8688/8787/8797.
=20
 	  Say Y here to compile Marvell Bluetooth driver
 	  into the kernel or say M to compile it as module.
@@ -201,8 +201,8 @@ config BT_MRVL_SDIO
 	  The driver for Marvell Bluetooth chipsets with SDIO interface.
=20
 	  This driver is required if you want to use Marvell Bluetooth
-	  devices with SDIO interface. Currently SD8688/SD8787 chipsets are
-	  supported.
+	  devices with SDIO interface. Currently SD8688/SD8787/SD8797
+	  chipsets are supported.
=20
 	  Say Y here to compile support for Marvell BT-over-SDIO driver
 	  into the kernel or say M to compile it as module.
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdi=
o.c
index 9ef4816..27b74b0 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -65,7 +65,7 @@ static const struct btmrvl_sdio_card_reg btmrvl_reg_8688 =
=3D {
 	.io_port_1 =3D 0x01,
 	.io_port_2 =3D 0x02,
 };
-static const struct btmrvl_sdio_card_reg btmrvl_reg_8787 =3D {
+static const struct btmrvl_sdio_card_reg btmrvl_reg_87xx =3D {
 	.cfg =3D 0x00,
 	.host_int_mask =3D 0x02,
 	.host_intstatus =3D 0x03,
@@ -92,7 +92,14 @@ static const struct btmrvl_sdio_device btmrvl_sdio_sd868=
8 =3D {
 static const struct btmrvl_sdio_device btmrvl_sdio_sd8787 =3D {
 	.helper		=3D NULL,
 	.firmware	=3D "mrvl/sd8787_uapsta.bin",
-	.reg		=3D &btmrvl_reg_8787,
+	.reg		=3D &btmrvl_reg_87xx,
+	.sd_blksz_fw_dl	=3D 256,
+};
+
+static const struct btmrvl_sdio_device btmrvl_sdio_sd8797 =3D {
+	.helper		=3D NULL,
+	.firmware	=3D "mrvl/sd8797_uapsta.bin",
+	.reg		=3D &btmrvl_reg_87xx,
 	.sd_blksz_fw_dl	=3D 256,
 };
=20
@@ -103,6 +110,9 @@ static const struct sdio_device_id btmrvl_sdio_ids[] =
=3D {
 	/* Marvell SD8787 Bluetooth device */
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x911A),
 			.driver_data =3D (unsigned long) &btmrvl_sdio_sd8787 },
+	/* Marvell SD8797 Bluetooth device */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x912A),
+			.driver_data =3D (unsigned long) &btmrvl_sdio_sd8797 },
=20
 	{ }	/* Terminating entry */
 };
@@ -1076,3 +1086,4 @@ MODULE_LICENSE("GPL v2");
 MODULE_FIRMWARE("sd8688_helper.bin");
 MODULE_FIRMWARE("sd8688.bin");
 MODULE_FIRMWARE("mrvl/sd8787_uapsta.bin");
+MODULE_FIRMWARE("mrvl/sd8797_uapsta.bin");
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index fe4ebc3..eabc437 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -777,9 +777,8 @@ skip_waking:
 		usb_mark_last_busy(data->udev);
 	}
=20
-	usb_free_urb(urb);
-
 done:
+	usb_free_urb(urb);
 	return err;
 }
=20
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 93fbe6f..d2348a5 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -286,7 +286,7 @@ static bool ath_complete_reset(struct ath_softc *sc, bo=
ol start)
 			ath_start_ani(common);
 	}
=20
-	if (ath9k_hw_ops(ah)->antdiv_comb_conf_get && sc->ant_rx !=3D 3) {
+	if ((ah->caps.hw_caps & ATH9K_HW_CAP_ANT_DIV_COMB) && sc->ant_rx !=3D 3) {
 		struct ath_hw_antcomb_conf div_ant_conf;
 		u8 lna_conf;
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/phy.c
index 592a10a..3b585aa 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -569,7 +569,7 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee=
80211_hw *hw,
 		}
 	case ERFSLEEP:{
 			if (ppsc->rfpwr_state =3D=3D ERFOFF)
-				break;
+				return false;
 			for (queue_id =3D 0, i =3D 0;
 			     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
 				ring =3D &pcipriv->dev.tx_ring[queue_id];
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/phy.c
index 7285290..e49cf22 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -548,7 +548,7 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee=
80211_hw *hw,
 		break;
 	case ERFSLEEP:
 		if (ppsc->rfpwr_state =3D=3D ERFOFF)
-			break;
+			return false;
 		for (queue_id =3D 0, i =3D 0;
 		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
 			ring =3D &pcipriv->dev.tx_ring[queue_id];
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8192de/phy.c
index 3ac7af1..0883349 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -3374,7 +3374,7 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_h=
w *hw,
 		break;
 	case ERFSLEEP:
 		if (ppsc->rfpwr_state =3D=3D ERFOFF)
-			break;
+			return false;
=20
 		for (queue_id =3D 0, i =3D 0;
 		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8192se/phy.c
index f27171a..f10ac1a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -602,7 +602,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw =
*hw,
 		}
 	case ERFSLEEP:
 			if (ppsc->rfpwr_state =3D=3D ERFOFF)
-				break;
+				return false;
=20
 			for (queue_id =3D 0, i =3D 0;
 			     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 84c934c..520e828 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -517,10 +517,14 @@ static void ssb_pcicore_pcie_setup_workarounds(struct=
 ssb_pcicore *pc)
=20
 static void __devinit ssb_pcicore_init_clientmode(struct ssb_pcicore *pc)
 {
-	ssb_pcicore_fix_sprom_core_index(pc);
+	struct ssb_device *pdev =3D pc->dev;
+	struct ssb_bus *bus =3D pdev->bus;
+
+	if (bus->bustype =3D=3D SSB_BUSTYPE_PCI)
+		ssb_pcicore_fix_sprom_core_index(pc);
=20
 	/* Disable PCI interrupts. */
-	ssb_write32(pc->dev, SSB_INTVEC, 0);
+	ssb_write32(pdev, SSB_INTVEC, 0);
=20
 	/* Additional PCIe always once-executed workarounds */
 	if (pc->dev->id.coreid =3D=3D SSB_DEV_PCIE) {
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 91bcd3a..1eea820 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -79,17 +79,12 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
=20
 static void __bnep_link_session(struct bnep_session *s)
 {
-	/* It's safe to call __module_get() here because sessions are added
-	   by the socket layer which has to hold the reference to this module.
-	 */
-	__module_get(THIS_MODULE);
 	list_add(&s->list, &bnep_session_list);
 }
=20
 static void __bnep_unlink_session(struct bnep_session *s)
 {
 	list_del(&s->list);
-	module_put(THIS_MODULE);
 }
=20
 static int bnep_send(struct bnep_session *s, void *data, size_t len)
@@ -530,6 +525,7 @@ static int bnep_session(void *arg)
=20
 	up_write(&bnep_session_sem);
 	free_netdev(dev);
+	module_put_and_exit(0);
 	return 0;
 }
=20
@@ -616,9 +612,11 @@ int bnep_add_connection(struct bnep_connadd_req *req, =
struct socket *sock)
=20
 	__bnep_link_session(s);
=20
+	__module_get(THIS_MODULE);
 	s->task =3D kthread_run(bnep_session, s, "kbnepd %s", dev->name);
 	if (IS_ERR(s->task)) {
 		/* Session thread start failed, gotta cleanup. */
+		module_put(THIS_MODULE);
 		unregister_netdev(dev);
 		__bnep_unlink_session(s);
 		err =3D PTR_ERR(s->task);
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 7d00ddf..5a6e634 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -67,14 +67,12 @@ static struct cmtp_session *__cmtp_get_session(bdaddr_t=
 *bdaddr)
=20
 static void __cmtp_link_session(struct cmtp_session *session)
 {
-	__module_get(THIS_MODULE);
 	list_add(&session->list, &cmtp_session_list);
 }
=20
 static void __cmtp_unlink_session(struct cmtp_session *session)
 {
 	list_del(&session->list);
-	module_put(THIS_MODULE);
 }
=20
 static void __cmtp_copy_session(struct cmtp_session *session, struct cmtp_=
conninfo *ci)
@@ -327,6 +325,7 @@ static int cmtp_session(void *arg)
 	up_write(&cmtp_session_sem);
=20
 	kfree(session);
+	module_put_and_exit(0);
 	return 0;
 }
=20
@@ -376,9 +375,11 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, =
struct socket *sock)
=20
 	__cmtp_link_session(session);
=20
+	__module_get(THIS_MODULE);
 	session->task =3D kthread_run(cmtp_session, session, "kcmtpd_ctr_%d",
 								session->num);
 	if (IS_ERR(session->task)) {
+		module_put(THIS_MODULE);
 		err =3D PTR_ERR(session->task);
 		goto unlink;
 	}
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index d7d96b6..643a41b 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -545,7 +545,7 @@ static void hci_setup(struct hci_dev *hdev)
 {
 	hci_setup_event_mask(hdev);
=20
-	if (hdev->lmp_ver > 1)
+	if (hdev->hci_ver > 1)
 		hci_send_cmd(hdev, HCI_OP_READ_LOCAL_COMMANDS, 0, NULL);
=20
 	if (hdev->features[6] & LMP_SIMPLE_PAIR) {
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index b064e4d..2e4b961 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -303,6 +303,38 @@ ieee80211_wake_queue_agg(struct ieee80211_local *local=
, int tid)
 	__release(agg_queue);
 }
=20
+/*
+ * splice packets from the STA's pending to the local pending,
+ * requires a call to ieee80211_agg_splice_finish later
+ */
+static void __acquires(agg_queue)
+ieee80211_agg_splice_packets(struct ieee80211_local *local,
+			     struct tid_ampdu_tx *tid_tx, u16 tid)
+{
+	int queue =3D ieee80211_ac_from_tid(tid);
+	unsigned long flags;
+
+	ieee80211_stop_queue_agg(local, tid);
+
+	if (WARN(!tid_tx, "TID %d gone but expected when splicing aggregates"
+			  " from the pending queue\n", tid))
+		return;
+
+	if (!skb_queue_empty(&tid_tx->pending)) {
+		spin_lock_irqsave(&local->queue_stop_reason_lock, flags);
+		/* copy over remaining packets */
+		skb_queue_splice_tail_init(&tid_tx->pending,
+					   &local->pending[queue]);
+		spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
+	}
+}
+
+static void __releases(agg_queue)
+ieee80211_agg_splice_finish(struct ieee80211_local *local, u16 tid)
+{
+	ieee80211_wake_queue_agg(local, tid);
+}
+
 void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
 {
 	struct tid_ampdu_tx *tid_tx;
@@ -314,19 +346,17 @@ void ieee80211_tx_ba_session_handle_start(struct sta_=
info *sta, int tid)
 	tid_tx =3D rcu_dereference_protected_tid_tx(sta, tid);
=20
 	/*
-	 * While we're asking the driver about the aggregation,
-	 * stop the AC queue so that we don't have to worry
-	 * about frames that came in while we were doing that,
-	 * which would require us to put them to the AC pending
-	 * afterwards which just makes the code more complex.
+	 * Start queuing up packets for this aggregation session.
+	 * We're going to release them once the driver is OK with
+	 * that.
 	 */
-	ieee80211_stop_queue_agg(local, tid);
-
 	clear_bit(HT_AGG_STATE_WANT_START, &tid_tx->state);
=20
 	/*
-	 * make sure no packets are being processed to get
-	 * valid starting sequence number
+	 * Make sure no packets are being processed. This ensures that
+	 * we have a valid starting sequence number and that in-flight
+	 * packets have been flushed out and no packets for this TID
+	 * will go into the driver during the ampdu_action call.
 	 */
 	synchronize_net();
=20
@@ -340,17 +370,15 @@ void ieee80211_tx_ba_session_handle_start(struct sta_=
info *sta, int tid)
 					" tid %d\n", tid);
 #endif
 		spin_lock_bh(&sta->lock);
+		ieee80211_agg_splice_packets(local, tid_tx, tid);
 		ieee80211_assign_tid_tx(sta, tid, NULL);
+		ieee80211_agg_splice_finish(local, tid);
 		spin_unlock_bh(&sta->lock);
=20
-		ieee80211_wake_queue_agg(local, tid);
 		kfree_rcu(tid_tx, rcu_head);
 		return;
 	}
=20
-	/* we can take packets again now */
-	ieee80211_wake_queue_agg(local, tid);
-
 	/* activate the timer for the recipient's addBA response */
 	mod_timer(&tid_tx->addba_resp_timer, jiffies + ADDBA_RESP_INTERVAL);
 #ifdef CONFIG_MAC80211_HT_DEBUG
@@ -466,38 +494,6 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta=
 *pubsta, u16 tid,
 }
 EXPORT_SYMBOL(ieee80211_start_tx_ba_session);
=20
-/*
- * splice packets from the STA's pending to the local pending,
- * requires a call to ieee80211_agg_splice_finish later
- */
-static void __acquires(agg_queue)
-ieee80211_agg_splice_packets(struct ieee80211_local *local,
-			     struct tid_ampdu_tx *tid_tx, u16 tid)
-{
-	int queue =3D ieee80211_ac_from_tid(tid);
-	unsigned long flags;
-
-	ieee80211_stop_queue_agg(local, tid);
-
-	if (WARN(!tid_tx, "TID %d gone but expected when splicing aggregates"
-			  " from the pending queue\n", tid))
-		return;
-
-	if (!skb_queue_empty(&tid_tx->pending)) {
-		spin_lock_irqsave(&local->queue_stop_reason_lock, flags);
-		/* copy over remaining packets */
-		skb_queue_splice_tail_init(&tid_tx->pending,
-					   &local->pending[queue]);
-		spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
-	}
-}
-
-static void __releases(agg_queue)
-ieee80211_agg_splice_finish(struct ieee80211_local *local, u16 tid)
-{
-	ieee80211_wake_queue_agg(local, tid);
-}
-
 static void ieee80211_agg_tx_operational(struct ieee80211_local *local,
 					 struct sta_info *sta, u16 tid)
 {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--0OAP2g/MAC+5xKAE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO4l/0AAoJEJctW/TcYTgG644P/1nLSHrFLyk4DIDVLgpceYD3
jJBaSg6c4PGN+5IFcYmdeVXTlfJrnBcuf+4bo57LhY4AfW7euR0Owy97kKLV0xxt
udgpR30nh4yV15IvdrST1Yr9ABMG9xN6Bo2jYbs+HcmxGKeJdpUkC4+8Tkh0Cr+n
kA0WteR7NzLx86HErhbKbCuBFFRPg1Kbextctv5QX0NkMSBtcsHKO8dIP4xDoGyz
0u929jjYPlLS3J9WMh9TYwbKYLJYSfO5uRUD3O0bveEkPRII93ahRcyPWPfDvdUu
0+ftMIN4xPGx3u7ft5dZjyNlGEMuC7t/oYBiu/GLVnDlaO6SKh0MjJX5sgN/hU2y
3TIuc21hnJe1CzNxdMi7mIfIUDTbdRGJCp5gMe4zcWwIRMUhM8vs+nrVHunMnzlq
FBfVMqV3o+WGUMzJ5arPvE2q9xstIMTe22YZjBhsMLHa1HNKK+QKGjh2WGtAX/oi
3wgSP9wNgEDGlUwS1Oo+3dOhTT0J8guXkIoxVe6jxUzkRrmoBwyvzGnAKZwNAwJE
NFEd4cj5YGwAKvWlqKedqRDTgHWcVCIkB1nyPHZcWL6kuMiwInq2bCU1l2flNXII
IuXPHea0TmoRJKr1M+pV08Aiop9zl4pYuPLohZdaYaqSUJy1a0vMiBdkQDbjvptH
VzaPORndgM8SxeUYpg5x
=XkJb
-----END PGP SIGNATURE-----

--0OAP2g/MAC+5xKAE--
