From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-01-17
Date: Thu, 17 Jan 2013 12:32:40 -0500
Message-ID: <20130117173239.GA2098@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

(This message comes to you from Santa Clara, CA -- where I found
frost on the windshield this morning!)

Dave,

This batch of fixes is intended for 3.8...

Included is a Bluetooth pull.  Gustavo says:

"A few fixes for 3.8. Five of them are just new devices ids addition.
Apart from the that there is fix to a kernel memory leak to userspace from
Anderson Lizardo, two interoperability fixes from Jaganath Kanakkassery and
Szymon Janc. And a crash fix by me."

Along with that, Amitkumar Karwar brings a pair of mwifiex fixes for
problems related to handling of band information within the driver.
These problems can lead to association failures.

Sujith Manoharan fixes a memory leak in the ath9k_htc code (originally
reported by Larry Finger).

The big hero this round is Felix Fietkau.  Felix gives us seven
ath9k fixes, including a fix for a race condition, the removal of a
double-free, and a fix for a deadlock, among others.

These have all been in linux-next for at least a couple of days,
with no complaints so far.  Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fa1e492aa3cbafba9f8fc6d05e5b08a3091daf4a:

  ipv4: Don't update the pmtu on mtu locked routes (2013-01-17 03:39:36 -05=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 811477de5f6d65baea69f25cb5528d428b82cc9c:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-01-17 12:07:44 -0500)

----------------------------------------------------------------

AceLan Kao (3):
      Bluetooth: Add support for IMC Networks [13d3:3393]
      Bluetooth: Add support for Foxconn / Hon Hai [0489:e04e]
      Bluetooth: Add support for Foxconn / Hon Hai [0489:e056]

Amitkumar Karwar (2):
      mwifiex: update config_bands during infra association
      mwifiex: correct config_bands handling for ibss network

Anderson Lizardo (1):
      Bluetooth: Fix incorrect strncpy() in hidp_setup_hid()

Daniel Schaal (1):
      Bluetooth: Add support for GC-WB300D PCIe [04ca:3006] to ath3k.

Felix Fietkau (7):
      ath9k: do not link receive buffers during flush
      ath9k: fix double-free bug on beacon generate failure
      ath9k: remove the WARN_ON that triggers if generating a beacon fails
      ath9k: add a better fix for the rx tasklet vs rx flush race
      ath9k: fix rx flush handling
      ath9k: remove sc->rx.rxbuflock to fix a deadlock
      ath9k: disable the tasklet before taking the PCU lock

Gustavo Padovan (1):
      Bluetooth: Check if the hci connection exists in SCO shutdown

Jaganath Kanakkassery (1):
      Bluetooth: Fix authentication if acl data comes before remote feature=
 evt

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Piotr Haber (1):
      brcmsmac: increase timer reference count for new timers only

Sergio Cambra (1):
      Bluetooth device 04ca:3008 should use ath3k

Sujith Manoharan (1):
      ath9k_htc: Fix memory leak

Szymon Janc (1):
      Bluetooth: Fix sending HCI commands after reset

 drivers/bluetooth/ath3k.c                          | 10 ++++
 drivers/bluetooth/btusb.c                          |  5 ++
 drivers/net/wireless/ath/ath9k/ath9k.h             |  3 --
 drivers/net/wireless/ath/ath9k/beacon.c            |  2 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  1 -
 drivers/net/wireless/ath/ath9k/debug.h             |  2 -
 drivers/net/wireless/ath/ath9k/htc_hst.c           |  2 +
 drivers/net/wireless/ath/ath9k/main.c              | 19 +++-----
 drivers/net/wireless/ath/ath9k/recv.c              | 54 ++++++------------=
----
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  7 +--
 drivers/net/wireless/mwifiex/cfg80211.c            | 17 +------
 drivers/net/wireless/mwifiex/sta_ioctl.c           | 14 ++++++
 net/bluetooth/hci_core.c                           |  8 ----
 net/bluetooth/hci_event.c                          |  2 +-
 net/bluetooth/hidp/core.c                          |  2 +-
 net/bluetooth/l2cap_core.c                         | 11 +++++
 net/bluetooth/sco.c                                |  2 +-
 17 files changed, 73 insertions(+), 88 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index b00000e..33c9a44 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -77,10 +77,15 @@ static struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x0CF3, 0x311D) },
 	{ USB_DEVICE(0x13d3, 0x3375) },
 	{ USB_DEVICE(0x04CA, 0x3005) },
+	{ USB_DEVICE(0x04CA, 0x3006) },
+	{ USB_DEVICE(0x04CA, 0x3008) },
 	{ USB_DEVICE(0x13d3, 0x3362) },
 	{ USB_DEVICE(0x0CF3, 0xE004) },
 	{ USB_DEVICE(0x0930, 0x0219) },
 	{ USB_DEVICE(0x0489, 0xe057) },
+	{ USB_DEVICE(0x13d3, 0x3393) },
+	{ USB_DEVICE(0x0489, 0xe04e) },
+	{ USB_DEVICE(0x0489, 0xe056) },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE02C) },
@@ -104,10 +109,15 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
 	{ USB_DEVICE(0x0cf3, 0x311D), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3006), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe057), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x13d3, 0x3393), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe04e), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe056), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Atheros AR5BBU22 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE03C), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index a1d4ede..7e351e3 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -135,10 +135,15 @@ static struct usb_device_id blacklist_table[] =3D {
 	{ USB_DEVICE(0x0cf3, 0x311d), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3006), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe057), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x13d3, 0x3393), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe04e), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0489, 0xe056), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe02c), .driver_info =3D BTUSB_IGNORE },
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index 86e26a1..42794c5 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -317,7 +317,6 @@ struct ath_rx {
 	u32 *rxlink;
 	u32 num_pkts;
 	unsigned int rxfilter;
-	spinlock_t rxbuflock;
 	struct list_head rxbuf;
 	struct ath_descdma rxdma;
 	struct ath_buf *rx_bufptr;
@@ -328,7 +327,6 @@ struct ath_rx {
=20
 int ath_startrecv(struct ath_softc *sc);
 bool ath_stoprecv(struct ath_softc *sc);
-void ath_flushrecv(struct ath_softc *sc);
 u32 ath_calcrxfilter(struct ath_softc *sc);
 int ath_rx_init(struct ath_softc *sc, int nbufs);
 void ath_rx_cleanup(struct ath_softc *sc);
@@ -646,7 +644,6 @@ void ath_ant_comb_update(struct ath_softc *sc);
 enum sc_op_flags {
 	SC_OP_INVALID,
 	SC_OP_BEACONS,
-	SC_OP_RXFLUSH,
 	SC_OP_ANI_RUN,
 	SC_OP_PRIM_STA_VIF,
 	SC_OP_HW_RESET,
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless=
/ath/ath9k/beacon.c
index 531fffd..2ca355e 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -147,6 +147,7 @@ static struct ath_buf *ath9k_beacon_generate(struct iee=
e80211_hw *hw,
 				 skb->len, DMA_TO_DEVICE);
 		dev_kfree_skb_any(skb);
 		bf->bf_buf_addr =3D 0;
+		bf->bf_mpdu =3D NULL;
 	}
=20
 	skb =3D ieee80211_beacon_get(hw, vif);
@@ -359,7 +360,6 @@ void ath9k_beacon_tasklet(unsigned long data)
 		return;
=20
 	bf =3D ath9k_beacon_generate(sc->hw, vif);
-	WARN_ON(!bf);
=20
 	if (sc->beacon.bmisscnt !=3D 0) {
 		ath_dbg(common, BSTUCK, "resume beacon xmit after %u misses\n",
diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/=
ath/ath9k/debug.c
index 13ff9ed..e585fc8 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -861,7 +861,6 @@ static ssize_t read_file_recv(struct file *file, char _=
_user *user_buf,
 	RXS_ERR("RX-LENGTH-ERR", rx_len_err);
 	RXS_ERR("RX-OOM-ERR", rx_oom_err);
 	RXS_ERR("RX-RATE-ERR", rx_rate_err);
-	RXS_ERR("RX-DROP-RXFLUSH", rx_drop_rxflush);
 	RXS_ERR("RX-TOO-MANY-FRAGS", rx_too_many_frags_err);
=20
 	PHY_ERR("UNDERRUN ERR", ATH9K_PHYERR_UNDERRUN);
diff --git a/drivers/net/wireless/ath/ath9k/debug.h b/drivers/net/wireless/=
ath/ath9k/debug.h
index 375c3b4..6df2ab6 100644
--- a/drivers/net/wireless/ath/ath9k/debug.h
+++ b/drivers/net/wireless/ath/ath9k/debug.h
@@ -216,7 +216,6 @@ struct ath_tx_stats {
  * @rx_oom_err:  No. of frames dropped due to OOM issues.
  * @rx_rate_err:  No. of frames dropped due to rate errors.
  * @rx_too_many_frags_err:  Frames dropped due to too-many-frags received.
- * @rx_drop_rxflush: No. of frames dropped due to RX-FLUSH.
  * @rx_beacons:  No. of beacons received.
  * @rx_frags:  No. of rx-fragements received.
  */
@@ -235,7 +234,6 @@ struct ath_rx_stats {
 	u32 rx_oom_err;
 	u32 rx_rate_err;
 	u32 rx_too_many_frags_err;
-	u32 rx_drop_rxflush;
 	u32 rx_beacons;
 	u32 rx_frags;
 };
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireles=
s/ath/ath9k/htc_hst.c
index 4a9570d..aac4a40 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -344,6 +344,8 @@ void ath9k_htc_txcompletion_cb(struct htc_target *htc_h=
andle,
 			endpoint->ep_callbacks.tx(endpoint->ep_callbacks.priv,
 						  skb, htc_hdr->endpoint_id,
 						  txok);
+		} else {
+			kfree_skb(skb);
 		}
 	}
=20
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index be30a9a..3796e65 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -182,7 +182,7 @@ static void ath_restart_work(struct ath_softc *sc)
 	ath_start_ani(sc);
 }
=20
-static bool ath_prepare_reset(struct ath_softc *sc, bool retry_tx, bool fl=
ush)
+static bool ath_prepare_reset(struct ath_softc *sc, bool retry_tx)
 {
 	struct ath_hw *ah =3D sc->sc_ah;
 	bool ret =3D true;
@@ -202,14 +202,6 @@ static bool ath_prepare_reset(struct ath_softc *sc, bo=
ol retry_tx, bool flush)
 	if (!ath_drain_all_txq(sc, retry_tx))
 		ret =3D false;
=20
-	if (!flush) {
-		if (ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
-			ath_rx_tasklet(sc, 1, true);
-		ath_rx_tasklet(sc, 1, false);
-	} else {
-		ath_flushrecv(sc);
-	}
-
 	return ret;
 }
=20
@@ -262,11 +254,11 @@ static int ath_reset_internal(struct ath_softc *sc, s=
truct ath9k_channel *hchan,
 	struct ath_common *common =3D ath9k_hw_common(ah);
 	struct ath9k_hw_cal_data *caldata =3D NULL;
 	bool fastcc =3D true;
-	bool flush =3D false;
 	int r;
=20
 	__ath_cancel_work(sc);
=20
+	tasklet_disable(&sc->intr_tq);
 	spin_lock_bh(&sc->sc_pcu_lock);
=20
 	if (!(sc->hw->conf.flags & IEEE80211_CONF_OFFCHANNEL)) {
@@ -276,11 +268,10 @@ static int ath_reset_internal(struct ath_softc *sc, s=
truct ath9k_channel *hchan,
=20
 	if (!hchan) {
 		fastcc =3D false;
-		flush =3D true;
 		hchan =3D ah->curchan;
 	}
=20
-	if (!ath_prepare_reset(sc, retry_tx, flush))
+	if (!ath_prepare_reset(sc, retry_tx))
 		fastcc =3D false;
=20
 	ath_dbg(common, CONFIG, "Reset to %u MHz, HT40: %d fastcc: %d\n",
@@ -302,6 +293,8 @@ static int ath_reset_internal(struct ath_softc *sc, str=
uct ath9k_channel *hchan,
=20
 out:
 	spin_unlock_bh(&sc->sc_pcu_lock);
+	tasklet_enable(&sc->intr_tq);
+
 	return r;
 }
=20
@@ -804,7 +797,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 		ath9k_hw_cfg_gpio_input(ah, ah->led_pin);
 	}
=20
-	ath_prepare_reset(sc, false, true);
+	ath_prepare_reset(sc, false);
=20
 	if (sc->rx.frag) {
 		dev_kfree_skb_any(sc->rx.frag);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/a=
th/ath9k/recv.c
index d4df98a..90752f2 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -254,8 +254,6 @@ rx_init_fail:
=20
 static void ath_edma_start_recv(struct ath_softc *sc)
 {
-	spin_lock_bh(&sc->rx.rxbuflock);
-
 	ath9k_hw_rxena(sc->sc_ah);
=20
 	ath_rx_addbuffer_edma(sc, ATH9K_RX_QUEUE_HP,
@@ -267,8 +265,6 @@ static void ath_edma_start_recv(struct ath_softc *sc)
 	ath_opmode_init(sc);
=20
 	ath9k_hw_startpcureceive(sc->sc_ah, !!(sc->hw->conf.flags & IEEE80211_CON=
F_OFFCHANNEL));
-
-	spin_unlock_bh(&sc->rx.rxbuflock);
 }
=20
 static void ath_edma_stop_recv(struct ath_softc *sc)
@@ -285,8 +281,6 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 	int error =3D 0;
=20
 	spin_lock_init(&sc->sc_pcu_lock);
-	spin_lock_init(&sc->rx.rxbuflock);
-	clear_bit(SC_OP_RXFLUSH, &sc->sc_flags);
=20
 	common->rx_bufsize =3D IEEE80211_MAX_MPDU_LEN / 2 +
 			     sc->sc_ah->caps.rx_status_len;
@@ -447,7 +441,6 @@ int ath_startrecv(struct ath_softc *sc)
 		return 0;
 	}
=20
-	spin_lock_bh(&sc->rx.rxbuflock);
 	if (list_empty(&sc->rx.rxbuf))
 		goto start_recv;
=20
@@ -468,26 +461,31 @@ start_recv:
 	ath_opmode_init(sc);
 	ath9k_hw_startpcureceive(ah, !!(sc->hw->conf.flags & IEEE80211_CONF_OFFCH=
ANNEL));
=20
-	spin_unlock_bh(&sc->rx.rxbuflock);
-
 	return 0;
 }
=20
+static void ath_flushrecv(struct ath_softc *sc)
+{
+	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
+		ath_rx_tasklet(sc, 1, true);
+	ath_rx_tasklet(sc, 1, false);
+}
+
 bool ath_stoprecv(struct ath_softc *sc)
 {
 	struct ath_hw *ah =3D sc->sc_ah;
 	bool stopped, reset =3D false;
=20
-	spin_lock_bh(&sc->rx.rxbuflock);
 	ath9k_hw_abortpcurecv(ah);
 	ath9k_hw_setrxfilter(ah, 0);
 	stopped =3D ath9k_hw_stopdmarecv(ah, &reset);
=20
+	ath_flushrecv(sc);
+
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
 		ath_edma_stop_recv(sc);
 	else
 		sc->rx.rxlink =3D NULL;
-	spin_unlock_bh(&sc->rx.rxbuflock);
=20
 	if (!(ah->ah_flags & AH_UNPLUGGED) &&
 	    unlikely(!stopped)) {
@@ -499,15 +497,6 @@ bool ath_stoprecv(struct ath_softc *sc)
 	return stopped && !reset;
 }
=20
-void ath_flushrecv(struct ath_softc *sc)
-{
-	set_bit(SC_OP_RXFLUSH, &sc->sc_flags);
-	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
-		ath_rx_tasklet(sc, 1, true);
-	ath_rx_tasklet(sc, 1, false);
-	clear_bit(SC_OP_RXFLUSH, &sc->sc_flags);
-}
-
 static bool ath_beacon_dtim_pending_cab(struct sk_buff *skb)
 {
 	/* Check whether the Beacon frame has DTIM indicating buffered bc/mc */
@@ -744,6 +733,7 @@ static struct ath_buf *ath_get_next_rx_buf(struct ath_s=
oftc *sc,
 			return NULL;
 	}
=20
+	list_del(&bf->list);
 	if (!bf->bf_mpdu)
 		return bf;
=20
@@ -1059,16 +1049,12 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush,=
 bool hp)
 		dma_type =3D DMA_FROM_DEVICE;
=20
 	qtype =3D hp ? ATH9K_RX_QUEUE_HP : ATH9K_RX_QUEUE_LP;
-	spin_lock_bh(&sc->rx.rxbuflock);
=20
 	tsf =3D ath9k_hw_gettsf64(ah);
 	tsf_lower =3D tsf & 0xffffffff;
=20
 	do {
 		bool decrypt_error =3D false;
-		/* If handling rx interrupt and flush is in progress =3D> exit */
-		if (test_bit(SC_OP_RXFLUSH, &sc->sc_flags) && (flush =3D=3D 0))
-			break;
=20
 		memset(&rs, 0, sizeof(rs));
 		if (edma)
@@ -1111,15 +1097,6 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, =
bool hp)
=20
 		ath_debug_stat_rx(sc, &rs);
=20
-		/*
-		 * If we're asked to flush receive queue, directly
-		 * chain it back at the queue without processing it.
-		 */
-		if (test_bit(SC_OP_RXFLUSH, &sc->sc_flags)) {
-			RX_STAT_INC(rx_drop_rxflush);
-			goto requeue_drop_frag;
-		}
-
 		memset(rxs, 0, sizeof(struct ieee80211_rx_status));
=20
 		rxs->mactime =3D (tsf & ~0xffffffffULL) | rs.rs_tstamp;
@@ -1254,19 +1231,18 @@ requeue_drop_frag:
 			sc->rx.frag =3D NULL;
 		}
 requeue:
+		list_add_tail(&bf->list, &sc->rx.rxbuf);
+		if (flush)
+			continue;
+
 		if (edma) {
-			list_add_tail(&bf->list, &sc->rx.rxbuf);
 			ath_rx_edma_buf_link(sc, qtype);
 		} else {
-			list_move_tail(&bf->list, &sc->rx.rxbuf);
 			ath_rx_buf_link(sc, bf);
-			if (!flush)
-				ath9k_hw_rxena(ah);
+			ath9k_hw_rxena(ah);
 		}
 	} while (1);
=20
-	spin_unlock_bh(&sc->rx.rxbuflock);
-
 	if (!(ah->imask & ATH9K_INT_RXEOL)) {
 		ah->imask |=3D (ATH9K_INT_RXEOL | ATH9K_INT_RXORN);
 		ath9k_hw_set_interrupts(ah);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/driver=
s/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 1fbd8ec..0f71d1d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1407,9 +1407,10 @@ void brcms_add_timer(struct brcms_timer *t, uint ms,=
 int periodic)
 #endif
 	t->ms =3D ms;
 	t->periodic =3D (bool) periodic;
-	t->set =3D true;
-
-	atomic_inc(&t->wl->callbacks);
+	if (!t->set) {
+		t->set =3D true;
+		atomic_inc(&t->wl->callbacks);
+	}
=20
 	ieee80211_queue_delayed_work(hw, &t->dly_wrk, msecs_to_jiffies(ms));
 }
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index efe525b..cdb11b3 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1459,7 +1459,7 @@ mwifiex_cfg80211_assoc(struct mwifiex_private *priv, =
size_t ssid_len, u8 *ssid,
 	struct cfg80211_ssid req_ssid;
 	int ret, auth_type =3D 0;
 	struct cfg80211_bss *bss =3D NULL;
-	u8 is_scanning_required =3D 0, config_bands =3D 0;
+	u8 is_scanning_required =3D 0;
=20
 	memset(&req_ssid, 0, sizeof(struct cfg80211_ssid));
=20
@@ -1478,19 +1478,6 @@ mwifiex_cfg80211_assoc(struct mwifiex_private *priv,=
 size_t ssid_len, u8 *ssid,
 	/* disconnect before try to associate */
 	mwifiex_deauthenticate(priv, NULL);
=20
-	if (channel) {
-		if (mode =3D=3D NL80211_IFTYPE_STATION) {
-			if (channel->band =3D=3D IEEE80211_BAND_2GHZ)
-				config_bands =3D BAND_B | BAND_G | BAND_GN;
-			else
-				config_bands =3D BAND_A | BAND_AN;
-
-			if (!((config_bands | priv->adapter->fw_bands) &
-			      ~priv->adapter->fw_bands))
-				priv->adapter->config_bands =3D config_bands;
-		}
-	}
-
 	/* As this is new association, clear locally stored
 	 * keys and security related flags */
 	priv->sec_info.wpa_enabled =3D false;
@@ -1707,7 +1694,7 @@ static int mwifiex_set_ibss_params(struct mwifiex_pri=
vate *priv,
=20
 		if (cfg80211_get_chandef_type(&params->chandef) !=3D
 						NL80211_CHAN_NO_HT)
-			config_bands |=3D BAND_GN;
+			config_bands |=3D BAND_G | BAND_GN;
 	} else {
 		if (cfg80211_get_chandef_type(&params->chandef) =3D=3D
 						NL80211_CHAN_NO_HT)
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index 60e88b5..f542bb8 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -283,6 +283,20 @@ int mwifiex_bss_start(struct mwifiex_private *priv, st=
ruct cfg80211_bss *bss,
 		if (ret)
 			goto done;
=20
+		if (bss_desc) {
+			u8 config_bands =3D 0;
+
+			if (mwifiex_band_to_radio_type((u8) bss_desc->bss_band)
+			    =3D=3D HostCmd_SCAN_RADIO_TYPE_BG)
+				config_bands =3D BAND_B | BAND_G | BAND_GN;
+			else
+				config_bands =3D BAND_A | BAND_AN;
+
+			if (!((config_bands | adapter->fw_bands) &
+			      ~adapter->fw_bands))
+				adapter->config_bands =3D config_bands;
+		}
+
 		ret =3D mwifiex_check_network_compatibility(priv, bss_desc);
 		if (ret)
 			goto done;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 596660d..0f78e34 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2810,14 +2810,6 @@ static void hci_acldata_packet(struct hci_dev *hdev,=
 struct sk_buff *skb)
 	if (conn) {
 		hci_conn_enter_active_mode(conn, BT_POWER_FORCE_ACTIVE_OFF);
=20
-		hci_dev_lock(hdev);
-		if (test_bit(HCI_MGMT, &hdev->dev_flags) &&
-		    !test_and_set_bit(HCI_CONN_MGMT_CONNECTED, &conn->flags))
-			mgmt_device_connected(hdev, &conn->dst, conn->type,
-					      conn->dst_type, 0, NULL, 0,
-					      conn->dev_class);
-		hci_dev_unlock(hdev);
-
 		/* Send to upper protocol */
 		l2cap_recv_acldata(conn, skb, flags);
 		return;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 705078a..81b4448 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -2688,7 +2688,7 @@ static void hci_cmd_complete_evt(struct hci_dev *hdev=
, struct sk_buff *skb)
 	if (ev->opcode !=3D HCI_OP_NOP)
 		del_timer(&hdev->cmd_timer);
=20
-	if (ev->ncmd) {
+	if (ev->ncmd && !test_bit(HCI_RESET, &hdev->flags)) {
 		atomic_set(&hdev->cmd_cnt, 1);
 		if (!skb_queue_empty(&hdev->cmd_q))
 			queue_work(hdev->workqueue, &hdev->cmd_work);
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index b2bcbe2..a7352ff 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -931,7 +931,7 @@ static int hidp_setup_hid(struct hidp_session *session,
 	hid->version =3D req->version;
 	hid->country =3D req->country;
=20
-	strncpy(hid->name, req->name, 128);
+	strncpy(hid->name, req->name, sizeof(req->name) - 1);
=20
 	snprintf(hid->phys, sizeof(hid->phys), "%pMR",
 		 &bt_sk(session->ctrl_sock->sk)->src);
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 2c78208..22e6583 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -3727,6 +3727,17 @@ sendresp:
 static int l2cap_connect_req(struct l2cap_conn *conn,
 			     struct l2cap_cmd_hdr *cmd, u8 *data)
 {
+	struct hci_dev *hdev =3D conn->hcon->hdev;
+	struct hci_conn *hcon =3D conn->hcon;
+
+	hci_dev_lock(hdev);
+	if (test_bit(HCI_MGMT, &hdev->dev_flags) &&
+	    !test_and_set_bit(HCI_CONN_MGMT_CONNECTED, &hcon->flags))
+		mgmt_device_connected(hdev, &hcon->dst, hcon->type,
+				      hcon->dst_type, 0, NULL, 0,
+				      hcon->dev_class);
+	hci_dev_unlock(hdev);
+
 	l2cap_connect(conn, cmd, data, L2CAP_CONN_RSP, 0);
 	return 0;
 }
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 531a93d..57f250c 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -352,7 +352,7 @@ static void __sco_sock_close(struct sock *sk)
=20
 	case BT_CONNECTED:
 	case BT_CONFIG:
-		if (sco_pi(sk)->conn) {
+		if (sco_pi(sk)->conn->hcon) {
 			sk->sk_state =3D BT_DISCONN;
 			sco_sock_set_timer(sk, SCO_DISCONN_TIMEOUT);
 			hci_conn_put(sco_pi(sk)->conn->hcon);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ReaqsoxgOBHFXBhH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ+DW3AAoJEJctW/TcYTgGorYP/1tMiRIYQvJ8P8hVRC80zDAz
b8uFB30DTo5YPFnggFFgxcRlR2g4PesyrreaHyIUD/mFczTwOAv/PEhcArCipaWs
sVxKvmYdeqrSXDI+zrBg8HRFomj92h1TN7wtfKaMqxXG/2cG9cY0LQ5i6L8mCsVW
ILvDpQ76c+ZWHiBlrJ7UF2hCopnQ6dKxd3uZom3w389dtRX2ix46klunpcAEZFTn
R5KRdTccNSKcSgWh04rcVaTaZeVPC6DPbWiokV14su2wMM3KXFg+lCCMTfU3Auai
N7JqDfdaKvy+LJrwMBoEGxta2Yabpn31374lnP7SFdOIn2SmSWf4k/FilB4ws7vp
hsiWf2R4fxRuMqnzQPtW7Nx3N5Zo3YsaNYEv1lf3xZLd/PJYAqeSEs15L0WHEguq
VXK58eb3m6yanMbs8446zJle7EFP1znI/ERa4ER3lIuydRjFFvNX/O3J2Qd3oMsB
/Nj/gVTjdtWwH9V8KV0g4q2Ww7zyprsb4DftdamI6nLTwfCdtwPnKSbPAjL7sunJ
1h/fJTFA7h8lM1fT69MvBuKAVmxwlzxSz3K4Ravx1EEYXx2CUAWlw/RkJNjFNaLT
Pd208Nf2bnKEjoFj3C6iHCmDrnesMoWYMvQVHCGH7e9nM25orr7Jtygh+3O7yj5c
T8v27OUfl8kNazogQD5s
=jF6+
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--
