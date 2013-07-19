From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-07-19
Date: Fri, 19 Jul 2013 13:19:10 -0400
Message-ID: <20130719171910.GD7641@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this batch of fixes intended for the 3.11 tree...

Alexey Khoroshilov fixes a suspend-related race in ath9k_htc.

Arnd Bergmann corrects the alignment of a structure in the ssb code
to be compatible with ARM devices.

Bob Copeland provides an ath5k fix that corrects a mistaken variable
initialization.

Felix Fietkau corrects some frame accounting for dropped frames
in ath9k.

Geert Uytterhoeven brings a Kconfig fix to indicate the DMA
requirements for rt2x00.

Larry Finger offers two rtlwifi fixes: one that properly initializes
a callback; and, a scattered collection of Kconfig, Makefile, and
EXPORT_SYMBOL changes that correct some build problems.

Finally, Sujith Manoharan provides an ath9k fix to disable a feature
on a specific hardware device.

Please let me know if there are any problems!

Thanks,

John

---

The following changes since commit ecb2cf1a6b63825a258ff4fe0d7f3070fbe4676b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-07-18=
 20:08:47 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 876fbb5d3ebab01685fef3839d245481c30eab5f:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-07-19 12:54:28 -0400)

----------------------------------------------------------------

Alexey Khoroshilov (1):
      ath9k_htc: fix data race between request_firmware_nowait() callback a=
nd suspend()

Arnd Bergmann (1):
      ssb: fix alignment of struct bcma_device_id

Bob Copeland (1):
      ath5k: fix extra set bit in multicast mask

Felix Fietkau (1):
      ath9k: fix tx pending frames accounting for dropped packets

Geert Uytterhoeven (1):
      rt2x00: RT2X00 should depend on HAS_DMA

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (2):
      rtlwifi: Initialize power-setting callback for USB devices
      rtlwifi: Fix build errors for unusual cases

Sujith Manoharan (1):
      ath9k_hw: Fix multicast search for AR9002 family

 drivers/net/wireless/ath/ath5k/mac80211-ops.c |  2 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c   | 10 +++-
 drivers/net/wireless/ath/ath9k/hif_usb.c      |  9 ++--
 drivers/net/wireless/ath/ath9k/xmit.c         | 44 ++++++++++------
 drivers/net/wireless/rt2x00/Kconfig           |  2 +-
 drivers/net/wireless/rtlwifi/Kconfig          | 72 ++++++++++++++++++-----=
----
 drivers/net/wireless/rtlwifi/Makefile         | 10 ++--
 drivers/net/wireless/rtlwifi/base.c           | 19 +++++--
 drivers/net/wireless/rtlwifi/base.h           |  2 +-
 drivers/net/wireless/rtlwifi/core.c           |  1 +
 drivers/net/wireless/rtlwifi/debug.c          |  1 +
 drivers/net/wireless/rtlwifi/efuse.c          |  1 +
 drivers/net/wireless/rtlwifi/pci.c            | 22 +++-----
 drivers/net/wireless/rtlwifi/ps.c             | 16 ++++++
 drivers/net/wireless/rtlwifi/ps.h             |  1 +
 drivers/net/wireless/rtlwifi/usb.c            |  9 ++++
 include/linux/mod_devicetable.h               |  5 +-
 17 files changed, 154 insertions(+), 72 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/mac80211-ops.c b/drivers/net/wi=
reless/ath/ath5k/mac80211-ops.c
index 81b686c..40825d4 100644
--- a/drivers/net/wireless/ath/ath5k/mac80211-ops.c
+++ b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
@@ -325,7 +325,7 @@ ath5k_prepare_multicast(struct ieee80211_hw *hw,
 	struct netdev_hw_addr *ha;
=20
 	mfilt[0] =3D 0;
-	mfilt[1] =3D 1;
+	mfilt[1] =3D 0;
=20
 	netdev_hw_addr_list_for_each(ha, mc_list) {
 		/* calculate XOR of eight 6-bit values */
diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wire=
less/ath/ath9k/ar5008_phy.c
index d1acfe9..1576d58 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -610,7 +610,15 @@ static void ar5008_hw_override_ini(struct ath_hw *ah,
 	REG_SET_BIT(ah, AR_DIAG_SW, (AR_DIAG_RX_DIS | AR_DIAG_RX_ABORT));
=20
 	if (AR_SREV_9280_20_OR_LATER(ah)) {
-		val =3D REG_READ(ah, AR_PCU_MISC_MODE2);
+		/*
+		 * For AR9280 and above, there is a new feature that allows
+		 * Multicast search based on both MAC Address and Key ID.
+		 * By default, this feature is enabled. But since the driver
+		 * is not using this feature, we switch it off; otherwise
+		 * multicast search based on MAC addr only will fail.
+		 */
+		val =3D REG_READ(ah, AR_PCU_MISC_MODE2) &
+			(~AR_ADHOC_MCAST_KEYID_ENABLE);
=20
 		if (!AR_SREV_9271(ah))
 			val &=3D ~AR_PCU_MISC_MODE2_HWWAR1;
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireles=
s/ath/ath9k/hif_usb.c
index 9e582e1..2469db5 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -1082,7 +1082,7 @@ static void ath9k_hif_usb_firmware_fail(struct hif_de=
vice_usb *hif_dev)
 	struct device *dev =3D &hif_dev->udev->dev;
 	struct device *parent =3D dev->parent;
=20
-	complete(&hif_dev->fw_done);
+	complete_all(&hif_dev->fw_done);
=20
 	if (parent)
 		device_lock(parent);
@@ -1131,7 +1131,7 @@ static void ath9k_hif_usb_firmware_cb(const struct fi=
rmware *fw, void *context)
=20
 	release_firmware(fw);
 	hif_dev->flags |=3D HIF_USB_READY;
-	complete(&hif_dev->fw_done);
+	complete_all(&hif_dev->fw_done);
=20
 	return;
=20
@@ -1316,7 +1316,10 @@ static int ath9k_hif_usb_suspend(struct usb_interfac=
e *interface,
 	if (!(hif_dev->flags & HIF_USB_START))
 		ath9k_htc_suspend(hif_dev->htc_handle);
=20
-	ath9k_hif_usb_dealloc_urbs(hif_dev);
+	wait_for_completion(&hif_dev->fw_done);
+
+	if (hif_dev->flags & HIF_USB_READY)
+		ath9k_hif_usb_dealloc_urbs(hif_dev);
=20
 	return 0;
 }
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index c59ae43..9279927 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -146,6 +146,28 @@ static void ath_set_rates(struct ieee80211_vif *vif, s=
truct ieee80211_sta *sta,
 			       ARRAY_SIZE(bf->rates));
 }
=20
+static void ath_txq_skb_done(struct ath_softc *sc, struct ath_txq *txq,
+			     struct sk_buff *skb)
+{
+	int q;
+
+	q =3D skb_get_queue_mapping(skb);
+	if (txq =3D=3D sc->tx.uapsdq)
+		txq =3D sc->tx.txq_map[q];
+
+	if (txq !=3D sc->tx.txq_map[q])
+		return;
+
+	if (WARN_ON(--txq->pending_frames < 0))
+		txq->pending_frames =3D 0;
+
+	if (txq->stopped &&
+	    txq->pending_frames < sc->tx.txq_max_pending[q]) {
+		ieee80211_wake_queue(sc->hw, q);
+		txq->stopped =3D false;
+	}
+}
+
 static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 {
 	struct ath_txq *txq =3D tid->ac->txq;
@@ -167,6 +189,7 @@ static void ath_tx_flush_tid(struct ath_softc *sc, stru=
ct ath_atx_tid *tid)
 		if (!bf) {
 			bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
 			if (!bf) {
+				ath_txq_skb_done(sc, txq, skb);
 				ieee80211_free_txskb(sc->hw, skb);
 				continue;
 			}
@@ -811,6 +834,7 @@ ath_tx_get_tid_subframe(struct ath_softc *sc, struct at=
h_txq *txq,
=20
 		if (!bf) {
 			__skb_unlink(skb, &tid->buf_q);
+			ath_txq_skb_done(sc, txq, skb);
 			ieee80211_free_txskb(sc->hw, skb);
 			continue;
 		}
@@ -1824,6 +1848,7 @@ static void ath_tx_send_ampdu(struct ath_softc *sc, s=
truct ath_txq *txq,
=20
 	bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
 	if (!bf) {
+		ath_txq_skb_done(sc, txq, skb);
 		ieee80211_free_txskb(sc->hw, skb);
 		return;
 	}
@@ -2090,6 +2115,7 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_b=
uff *skb,
=20
 	bf =3D ath_tx_setup_buffer(sc, txq, tid, skb);
 	if (!bf) {
+		ath_txq_skb_done(sc, txq, skb);
 		if (txctl->paprd)
 			dev_kfree_skb_any(skb);
 		else
@@ -2189,7 +2215,7 @@ static void ath_tx_complete(struct ath_softc *sc, str=
uct sk_buff *skb,
 	struct ieee80211_tx_info *tx_info =3D IEEE80211_SKB_CB(skb);
 	struct ath_common *common =3D ath9k_hw_common(sc->sc_ah);
 	struct ieee80211_hdr * hdr =3D (struct ieee80211_hdr *)skb->data;
-	int q, padpos, padsize;
+	int padpos, padsize;
 	unsigned long flags;
=20
 	ath_dbg(common, XMIT, "TX complete: skb: %p\n", skb);
@@ -2225,21 +2251,7 @@ static void ath_tx_complete(struct ath_softc *sc, st=
ruct sk_buff *skb,
 	spin_unlock_irqrestore(&sc->sc_pm_lock, flags);
=20
 	__skb_queue_tail(&txq->complete_q, skb);
-
-	q =3D skb_get_queue_mapping(skb);
-	if (txq =3D=3D sc->tx.uapsdq)
-		txq =3D sc->tx.txq_map[q];
-
-	if (txq =3D=3D sc->tx.txq_map[q]) {
-		if (WARN_ON(--txq->pending_frames < 0))
-			txq->pending_frames =3D 0;
-
-		if (txq->stopped &&
-		    txq->pending_frames < sc->tx.txq_max_pending[q]) {
-			ieee80211_wake_queue(sc->hw, q);
-			txq->stopped =3D false;
-		}
-	}
+	ath_txq_skb_done(sc, txq, skb);
 }
=20
 static void ath_tx_complete_buf(struct ath_softc *sc, struct ath_buf *bf,
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2=
x00/Kconfig
index 9b915d3..3e60a31 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -1,6 +1,6 @@
 menuconfig RT2X00
 	tristate "Ralink driver support"
-	depends on MAC80211
+	depends on MAC80211 && HAS_DMA
 	---help---
 	  This will enable the support for the Ralink drivers,
 	  developed in the rt2x00 project <http://rt2x00.serialmonkey.com>.
diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rt=
lwifi/Kconfig
index 7253de3..c2ffce7 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -1,27 +1,20 @@
-config RTLWIFI
-	tristate "Realtek wireless card support"
-	depends on MAC80211
-	select FW_LOADER
-	---help---
-	  This is common code for RTL8192CE/RTL8192CU/RTL8192SE/RTL8723AE
-	  drivers.  This module does nothing by itself - the various front-end
-	  drivers need to be enabled to support any desired devices.
-
-	  If you choose to build as a module, it'll be called rtlwifi.
-
-config RTLWIFI_DEBUG
-	bool "Debugging output for rtlwifi driver family"
-	depends on RTLWIFI
+menuconfig RTL_CARDS
+	tristate "Realtek rtlwifi family of devices"
+	depends on MAC80211 && (PCI || USB)
 	default y
 	---help---
-	To use the module option that sets the dynamic-debugging level for,
-	the front-end driver, this parameter must be "Y". For memory-limited
-	systems, choose "N". If in doubt, choose "Y".
+	  This option will enable support for the Realtek mac80211-based
+	  wireless drivers. Drivers rtl8192ce, rtl8192cu, rtl8192se, rtl8192de,
+	  rtl8723eu, and rtl8188eu share some common code.
+
+if RTL_CARDS
=20
 config RTL8192CE
 	tristate "Realtek RTL8192CE/RTL8188CE Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
 	select RTL8192C_COMMON
+	select RTLWIFI
+	select RTLWIFI_PCI
 	---help---
 	This is the driver for Realtek RTL8192CE/RTL8188CE 802.11n PCIe
 	wireless network adapters.
@@ -30,7 +23,9 @@ config RTL8192CE
=20
 config RTL8192SE
 	tristate "Realtek RTL8192SE/RTL8191SE PCIe Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
 	---help---
 	This is the driver for Realtek RTL8192SE/RTL8191SE 802.11n PCIe
 	wireless network adapters.
@@ -39,7 +34,9 @@ config RTL8192SE
=20
 config RTL8192DE
 	tristate "Realtek RTL8192DE/RTL8188DE PCIe Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
 	---help---
 	This is the driver for Realtek RTL8192DE/RTL8188DE 802.11n PCIe
 	wireless network adapters.
@@ -48,7 +45,9 @@ config RTL8192DE
=20
 config RTL8723AE
 	tristate "Realtek RTL8723AE PCIe Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
 	---help---
 	This is the driver for Realtek RTL8723AE 802.11n PCIe
 	wireless network adapters.
@@ -57,7 +56,9 @@ config RTL8723AE
=20
 config RTL8188EE
 	tristate "Realtek RTL8188EE Wireless Network Adapter"
-	depends on RTLWIFI && PCI
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
 	---help---
 	This is the driver for Realtek RTL8188EE 802.11n PCIe
 	wireless network adapters.
@@ -66,7 +67,9 @@ config RTL8188EE
=20
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
-	depends on RTLWIFI && USB
+	depends on USB
+	select RTLWIFI
+	select RTLWIFI_USB
 	select RTL8192C_COMMON
 	---help---
 	This is the driver for Realtek RTL8192CU/RTL8188CU 802.11n USB
@@ -74,7 +77,28 @@ config RTL8192CU
=20
 	If you choose to build it as a module, it will be called rtl8192cu
=20
+config RTLWIFI
+	tristate
+	select FW_LOADER
+
+config RTLWIFI_PCI
+	tristate
+
+config RTLWIFI_USB
+	tristate
+
+config RTLWIFI_DEBUG
+	bool "Debugging output for rtlwifi driver family"
+	depends on RTLWIFI
+	default y
+	---help---
+	To use the module option that sets the dynamic-debugging level for,
+	the front-end driver, this parameter must be "Y". For memory-limited
+	systems, choose "N". If in doubt, choose "Y".
+
 config RTL8192C_COMMON
 	tristate
 	depends on RTL8192CE || RTL8192CU
-	default m
+	default y
+
+endif
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wireless/r=
tlwifi/Makefile
index ff02b87..d56f023 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -12,13 +12,11 @@ rtlwifi-objs	:=3D		\
=20
 rtl8192c_common-objs +=3D		\
=20
-ifneq ($(CONFIG_PCI),)
-rtlwifi-objs	+=3D pci.o
-endif
+obj-$(CONFIG_RTLWIFI_PCI)	+=3D rtl_pci.o
+rtl_pci-objs	:=3D		pci.o
=20
-ifneq ($(CONFIG_USB),)
-rtlwifi-objs	+=3D usb.o
-endif
+obj-$(CONFIG_RTLWIFI_USB)	+=3D rtl_usb.o
+rtl_usb-objs	:=3D		usb.o
=20
 obj-$(CONFIG_RTL8192C_COMMON)	+=3D rtl8192c/
 obj-$(CONFIG_RTL8192CE)		+=3D rtl8192ce/
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtl=
wifi/base.c
index 9d558ac..7651f5a 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -172,6 +172,7 @@ u8 rtl_tid_to_ac(u8 tid)
 {
 	return tid_to_ac[tid];
 }
+EXPORT_SYMBOL_GPL(rtl_tid_to_ac);
=20
 static void _rtl_init_hw_ht_capab(struct ieee80211_hw *hw,
 				  struct ieee80211_sta_ht_cap *ht_cap)
@@ -406,6 +407,7 @@ void rtl_deinit_deferred_work(struct ieee80211_hw *hw)
 	cancel_delayed_work(&rtlpriv->works.ps_rfon_wq);
 	cancel_delayed_work(&rtlpriv->works.fwevt_wq);
 }
+EXPORT_SYMBOL_GPL(rtl_deinit_deferred_work);
=20
 void rtl_init_rfkill(struct ieee80211_hw *hw)
 {
@@ -439,6 +441,7 @@ void rtl_deinit_rfkill(struct ieee80211_hw *hw)
 {
 	wiphy_rfkill_stop_polling(hw->wiphy);
 }
+EXPORT_SYMBOL_GPL(rtl_deinit_rfkill);
=20
 int rtl_init_core(struct ieee80211_hw *hw)
 {
@@ -489,10 +492,12 @@ int rtl_init_core(struct ieee80211_hw *hw)
=20
 	return 0;
 }
+EXPORT_SYMBOL_GPL(rtl_init_core);
=20
 void rtl_deinit_core(struct ieee80211_hw *hw)
 {
 }
+EXPORT_SYMBOL_GPL(rtl_deinit_core);
=20
 void rtl_init_rx_config(struct ieee80211_hw *hw)
 {
@@ -501,6 +506,7 @@ void rtl_init_rx_config(struct ieee80211_hw *hw)
=20
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RCR, (u8 *) (&mac->rx_conf));
 }
+EXPORT_SYMBOL_GPL(rtl_init_rx_config);
=20
 /*********************************************************
  *
@@ -879,6 +885,7 @@ bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct s=
k_buff *skb)
=20
 	return true;
 }
+EXPORT_SYMBOL_GPL(rtl_tx_mgmt_proc);
=20
 void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 		      struct ieee80211_tx_info *info,
@@ -1052,6 +1059,7 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct =
sk_buff *skb, u8 is_tx)
=20
 	return true;
 }
+EXPORT_SYMBOL_GPL(rtl_action_proc);
=20
 /*should call before software enc*/
 u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is=
_tx)
@@ -1125,6 +1133,7 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struc=
t sk_buff *skb, u8 is_tx)
=20
 	return false;
 }
+EXPORT_SYMBOL_GPL(rtl_is_special_data);
=20
 /*********************************************************
  *
@@ -1300,6 +1309,7 @@ void rtl_beacon_statistic(struct ieee80211_hw *hw, st=
ruct sk_buff *skb)
=20
 	rtlpriv->link_info.bcn_rx_inperiod++;
 }
+EXPORT_SYMBOL_GPL(rtl_beacon_statistic);
=20
 void rtl_watchdog_wq_callback(void *data)
 {
@@ -1793,6 +1803,7 @@ void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *=
data, unsigned int len)
=20
 	mac->vendor =3D vendor;
 }
+EXPORT_SYMBOL_GPL(rtl_recognize_peer);
=20
 /*********************************************************
  *
@@ -1849,6 +1860,7 @@ struct attribute_group rtl_attribute_group =3D {
 	.name =3D "rtlsysfs",
 	.attrs =3D rtl_sysfs_entries,
 };
+EXPORT_SYMBOL_GPL(rtl_attribute_group);
=20
 MODULE_AUTHOR("lizhaoming	<chaoming_li@realsil.com.cn>");
 MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
@@ -1856,7 +1868,8 @@ MODULE_AUTHOR("Larry Finger	<Larry.FInger@lwfinger.ne=
t>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Realtek 802.11n PCI wireless core");
=20
-struct rtl_global_var global_var =3D {};
+struct rtl_global_var rtl_global_var =3D {};
+EXPORT_SYMBOL_GPL(rtl_global_var);
=20
 static int __init rtl_core_module_init(void)
 {
@@ -1864,8 +1877,8 @@ static int __init rtl_core_module_init(void)
 		pr_err("Unable to register rtl_rc, use default RC !!\n");
=20
 	/* init some global vars */
-	INIT_LIST_HEAD(&global_var.glb_priv_list);
-	spin_lock_init(&global_var.glb_list_lock);
+	INIT_LIST_HEAD(&rtl_global_var.glb_priv_list);
+	spin_lock_init(&rtl_global_var.glb_list_lock);
=20
 	return 0;
 }
diff --git a/drivers/net/wireless/rtlwifi/base.h b/drivers/net/wireless/rtl=
wifi/base.h
index 8576bc3..0e5fe09 100644
--- a/drivers/net/wireless/rtlwifi/base.h
+++ b/drivers/net/wireless/rtlwifi/base.h
@@ -147,7 +147,7 @@ void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *da=
ta, unsigned int len);
 u8 rtl_tid_to_ac(u8 tid);
 extern struct attribute_group rtl_attribute_group;
 void rtl_easy_concurrent_retrytimer_callback(unsigned long data);
-extern struct rtl_global_var global_var;
+extern struct rtl_global_var rtl_global_var;
 int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
 			 bool isht, u8 desc_rate, bool first_ampdu);
 bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb);
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtl=
wifi/core.c
index ee84844..733b7ce 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1330,3 +1330,4 @@ const struct ieee80211_ops rtl_ops =3D {
 	.rfkill_poll =3D rtl_op_rfkill_poll,
 	.flush =3D rtl_op_flush,
 };
+EXPORT_SYMBOL_GPL(rtl_ops);
diff --git a/drivers/net/wireless/rtlwifi/debug.c b/drivers/net/wireless/rt=
lwifi/debug.c
index 7d52d3d..76e2086 100644
--- a/drivers/net/wireless/rtlwifi/debug.c
+++ b/drivers/net/wireless/rtlwifi/debug.c
@@ -51,3 +51,4 @@ void rtl_dbgp_flag_init(struct ieee80211_hw *hw)
=20
 	/*Init Debug flag enable condition */
 }
+EXPORT_SYMBOL_GPL(rtl_dbgp_flag_init);
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rt=
lwifi/efuse.c
index 9e38941..838a1ed 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -229,6 +229,7 @@ void read_efuse_byte(struct ieee80211_hw *hw, u16 _offs=
et, u8 *pbuf)
=20
 	*pbuf =3D (u8) (value32 & 0xff);
 }
+EXPORT_SYMBOL_GPL(read_efuse_byte);
=20
 void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *=
pbuf)
 {
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index c97e9d3..703f839 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -35,6 +35,13 @@
 #include "efuse.h"
 #include <linux/export.h>
 #include <linux/kmemleak.h>
+#include <linux/module.h>
+
+MODULE_AUTHOR("lizhaoming	<chaoming_li@realsil.com.cn>");
+MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
+MODULE_AUTHOR("Larry Finger	<Larry.FInger@lwfinger.net>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("PCI basic driver for rtlwifi");
=20
 static const u16 pcibridge_vendors[PCI_BRIDGE_VENDOR_MAX] =3D {
 	PCI_VENDOR_ID_INTEL,
@@ -1008,19 +1015,6 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee=
80211_hw *hw)
 	return;
 }
=20
-static void rtl_lps_change_work_callback(struct work_struct *work)
-{
-	struct rtl_works *rtlworks =3D
-	    container_of(work, struct rtl_works, lps_change_work);
-	struct ieee80211_hw *hw =3D rtlworks->hw;
-	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
-
-	if (rtlpriv->enter_ps)
-		rtl_lps_enter(hw);
-	else
-		rtl_lps_leave(hw);
-}
-
 static void _rtl_pci_init_trx_var(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
@@ -1899,7 +1893,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	rtlpriv->rtlhal.interface =3D INTF_PCI;
 	rtlpriv->cfg =3D (struct rtl_hal_cfg *)(id->driver_data);
 	rtlpriv->intf_ops =3D &rtl_pci_ops;
-	rtlpriv->glb_var =3D &global_var;
+	rtlpriv->glb_var =3D &rtl_global_var;
=20
 	/*
 	 *init dbgp flags before all
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwi=
fi/ps.c
index 884bcea..298b615 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -269,6 +269,7 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
=20
 	spin_unlock_irqrestore(&rtlpriv->locks.ips_lock, flags);
 }
+EXPORT_SYMBOL_GPL(rtl_ips_nic_on);
=20
 /*for FW LPS*/
=20
@@ -518,6 +519,7 @@ void rtl_swlps_beacon(struct ieee80211_hw *hw, void *da=
ta, unsigned int len)
 			 "u_bufferd: %x, m_buffered: %x\n", u_buffed, m_buffed);
 	}
 }
+EXPORT_SYMBOL_GPL(rtl_swlps_beacon);
=20
 void rtl_swlps_rf_awake(struct ieee80211_hw *hw)
 {
@@ -611,6 +613,19 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 			MSECS(sleep_intv * mac->vif->bss_conf.beacon_int - 40));
 }
=20
+void rtl_lps_change_work_callback(struct work_struct *work)
+{
+	struct rtl_works *rtlworks =3D
+	    container_of(work, struct rtl_works, lps_change_work);
+	struct ieee80211_hw *hw =3D rtlworks->hw;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (rtlpriv->enter_ps)
+		rtl_lps_enter(hw);
+	else
+		rtl_lps_leave(hw);
+}
+EXPORT_SYMBOL_GPL(rtl_lps_change_work_callback);
=20
 void rtl_swlps_wq_callback(void *data)
 {
@@ -922,3 +937,4 @@ void rtl_p2p_info(struct ieee80211_hw *hw, void *data, =
unsigned int len)
 	else
 		rtl_p2p_noa_ie(hw, data, len - FCS_LEN);
 }
+EXPORT_SYMBOL_GPL(rtl_p2p_info);
diff --git a/drivers/net/wireless/rtlwifi/ps.h b/drivers/net/wireless/rtlwi=
fi/ps.h
index 4d682b7..88bd76e 100644
--- a/drivers/net/wireless/rtlwifi/ps.h
+++ b/drivers/net/wireless/rtlwifi/ps.h
@@ -49,5 +49,6 @@ void rtl_swlps_rf_awake(struct ieee80211_hw *hw);
 void rtl_swlps_rf_sleep(struct ieee80211_hw *hw);
 void rtl_p2p_ps_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
 void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len);
+void rtl_lps_change_work_callback(struct work_struct *work);
=20
 #endif
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index a3532e0..e56778c 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -32,6 +32,13 @@
 #include "ps.h"
 #include "rtl8192c/fw_common.h"
 #include <linux/export.h>
+#include <linux/module.h>
+
+MODULE_AUTHOR("lizhaoming	<chaoming_li@realsil.com.cn>");
+MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
+MODULE_AUTHOR("Larry Finger	<Larry.FInger@lwfinger.net>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("USB basic driver for rtlwifi");
=20
 #define	REALTEK_USB_VENQT_READ			0xC0
 #define	REALTEK_USB_VENQT_WRITE			0x40
@@ -1070,6 +1077,8 @@ int rtl_usb_probe(struct usb_interface *intf,
 	spin_lock_init(&rtlpriv->locks.usb_lock);
 	INIT_WORK(&rtlpriv->works.fill_h2c_cmd,
 		  rtl_fill_h2c_cmd_work_callback);
+	INIT_WORK(&rtlpriv->works.lps_change_work,
+		  rtl_lps_change_work_callback);
=20
 	rtlpriv->usb_data_index =3D 0;
 	init_completion(&rtlpriv->firmware_loading_complete);
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetabl=
e.h
index b62d4af..45e9214 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -361,7 +361,8 @@ struct ssb_device_id {
 	__u16	vendor;
 	__u16	coreid;
 	__u8	revision;
-};
+	__u8	__pad;
+} __attribute__((packed, aligned(2)));
 #define SSB_DEVICE(_vendor, _coreid, _revision)  \
 	{ .vendor =3D _vendor, .coreid =3D _coreid, .revision =3D _revision, }
 #define SSB_DEVTABLE_END  \
@@ -377,7 +378,7 @@ struct bcma_device_id {
 	__u16	id;
 	__u8	rev;
 	__u8	class;
-};
+} __attribute__((packed,aligned(2)));
 #define BCMA_CORE(_manuf, _id, _rev, _class)  \
 	{ .manuf =3D _manuf, .id =3D _id, .rev =3D _rev, .class =3D _class, }
 #define BCMA_CORETABLE_END  \
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJR6XUNAAoJEJctW/TcYTgGE8gQAIi0p+vGM4+k6RNZx/qM2BPf
mQKnLj9OEQPjQkWnIUtcvizI1SApsrneeZd7HH4S5J2ajIF84DSEeYNnP3PPunjx
AF29vgZ0le92H5O8XgeMXe70z57e7p/VaYs0onKAo9huBlxuNYrzfqHHMl+IfjAu
htAInRttUOP3+u6ddI+uqU+yxvyUHv3xK6LmGMDKNvquFVNRN3DA9L8TiVAkAXrO
/0tF8VPqnubk37qorKm3XejWfoPDneoT5cNBkLVwjlNL/98+5AB1okviYwigUXsG
dLkBGjcMwMQBoU88EMz5Os4cpxmOPiqyQs2UoJWsQ+OGgMWE1ZpVLoUb2m0JYumo
W2wj9kSgjMXkXOshxg36dHihQFFXLA1mSVynCv5f4CuXm39gc6c0u88QQPuyCFD7
cwBO9s0Zm+AnlzkAURnBMTxX2xSa9/Xrymnk6VaO+BnAZoaefmtd5B4B+kfm5a4y
XwMtHeysqnpz6w68DjJxbQS2rD4Yf/kDknwqS3ChJukoI8QtjPcbP2XKIhgxh8WD
mIEYNEJkfxo4AKYl5UswTfiQlPuxLUK32jPLKGKmQfU/068apeH5opL+Z9FCffl4
LBIemXABd163RNuP+vVYUv+YCpsR9qhRejvlgopITryRfwhUY+ivjmZNlirzPYzD
KT1KoJyxzpsKt7Uz1KyG
=h0Y9
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
