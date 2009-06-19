From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-06-19
Date: Fri, 19 Jun 2009 12:54:21 -0400
Message-ID: <20090619165420.GB2753@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another smattering of fixes intended fo 2.6.31.  Most of them
are minor, but worthwhile.  Also included is a USB ID for zd1211rw and
several patches from Alan Jenkins that are continuing fall-out from the
rfkill rewrite.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit cb2107be43d2fc5eadec58b92b54bf32c00bfff3:
  Dhananjay Phadke (1):
        netxen: fix tx ring accounting

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Alan Jenkins (4):
      rfkill: rfkill_set_block() when suspended nitpick
      rfkill: don't restore software blocked state on persistent devices
      eeepc-laptop: read rfkill soft-blocked state on resume
      rfkill: export persistent attribute in sysfs

Andrey Yurovsky (2):
      cfg80211: allow adding/deleting stations on mesh
      cfg80211: allow setting station parameters in mesh

Gabor Juhos (2):
      ath9k: wait for beacon frame along with CAB
      ath9k: restore PS mode, before we put the chip into FULL SLEEP state.

Hin-Tak Leung (1):
      zd1211rw: adding 083a:e503 as a ZD1211B device

Jiri Slaby (1):
      ath5k: fix beacon_int handling

Joe Perches (1):
      MAINTAINERS: Fix Atheros pattern paths

Johannes Berg (1):
      cfg80211: validate station settings

Jouni Malinen (2):
      ath9k: Fix PCI FATAL interrupts by restoring RETRY_TIMEOUT disabling
      ath5k: avoid PCI FATAL interrupts by restoring RETRY_TIMEOUT disabling

Troy Moure (1):
      acer-wmi: fix rfkill conversion

Zhu Yi (4):
      iwmc3200wifi: check for iwm_priv_init error
      iwmc3200wifi: add iwm_if_add and iwm_if_remove
      iwmc3200wifi: fix potential kernel oops on module removal
      iwmc3200wifi: add a mutex to protect iwm_reset_worker

 Documentation/rfkill.txt                   |    2 +
 MAINTAINERS                                |    6 +-
 drivers/net/wireless/ath/ath5k/base.c      |   11 +++-
 drivers/net/wireless/ath/ath9k/main.c      |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c       |   18 +++++
 drivers/net/wireless/ath/ath9k/recv.c      |    7 ++-
 drivers/net/wireless/iwmc3200wifi/iwm.h    |    4 +
 drivers/net/wireless/iwmc3200wifi/main.c   |   64 +++++++++++++++++--
 drivers/net/wireless/iwmc3200wifi/netdev.c |   49 +++++++++-----
 drivers/net/wireless/iwmc3200wifi/sdio.c   |   11 +++-
 drivers/net/wireless/zd1211rw/zd_usb.c     |    1 +
 drivers/platform/x86/acer-wmi.c            |    4 +-
 drivers/platform/x86/eeepc-laptop.c        |   50 ++++++++++++---
 drivers/platform/x86/thinkpad_acpi.c       |   14 ++--
 include/linux/rfkill.h                     |   33 ++++++++--
 net/rfkill/core.c                          |   56 +++++++++++-----
 net/wireless/nl80211.c                     |   95 +++++++++++++++++++++++-----
 17 files changed, 338 insertions(+), 89 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index c8acd86..b486050 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -111,6 +111,8 @@ following attributes:
 
 	name: Name assigned by driver to this key (interface or driver name).
 	type: Driver type string ("wlan", "bluetooth", etc).
+	persistent: Whether the soft blocked state is initialised from
+	            non-volatile storage at startup.
 	state: Current state of the transmitter
 		0: RFKILL_STATE_SOFT_BLOCKED
 			transmitter is turned off by software
diff --git a/MAINTAINERS b/MAINTAINERS
index 2cb7566..d820900 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -940,7 +940,7 @@ M:	me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
 S:	Maintained
-F:	drivers/net/wireless/ath5k/
+F:	drivers/net/wireless/ath/ath5k/
 
 ATHEROS ATH9K WIRELESS DRIVER
 P:	Luis R. Rodriguez
@@ -956,7 +956,7 @@ M:	senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
 S:	Supported
-F:	drivers/net/wireless/ath9k/
+F:	drivers/net/wireless/ath/ath9k/
 
 ATHEROS AR9170 WIRELESS DRIVER
 P:	Christian Lamparter
@@ -964,7 +964,7 @@ M:	chunkeey-S0/GAf8tV78@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://wireless.kernel.org/en/users/Drivers/ar9170
 S:	Maintained
-F:	drivers/net/wireless/ar9170/
+F:	drivers/net/wireless/ath/ar9170/
 
 ATI_REMOTE2 DRIVER
 P:	Ville Syrjala
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 55f7de0..ea04515 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -538,6 +538,7 @@ ath5k_pci_probe(struct pci_dev *pdev,
 	sc->iobase = mem; /* So we can unmap it on detach */
 	sc->cachelsz = csz * sizeof(u32); /* convert to bytes */
 	sc->opmode = NL80211_IFTYPE_STATION;
+	sc->bintval = 1000;
 	mutex_init(&sc->lock);
 	spin_lock_init(&sc->rxbuflock);
 	spin_lock_init(&sc->txbuflock);
@@ -686,6 +687,13 @@ ath5k_pci_resume(struct pci_dev *pdev)
 	if (err)
 		return err;
 
+	/*
+	 * Suspend/Resume resets the PCI configuration space, so we have to
+	 * re-disable the RETRY_TIMEOUT register (0x41) to keep
+	 * PCI Tx retries from interfering with C3 CPU state
+	 */
+	pci_write_config_byte(pdev, 0x41, 0);
+
 	err = request_irq(pdev->irq, ath5k_intr, IRQF_SHARED, "ath", sc);
 	if (err) {
 		ATH5K_ERR(sc, "request_irq failed\n");
@@ -2748,9 +2756,6 @@ static int ath5k_add_interface(struct ieee80211_hw *hw,
 		goto end;
 	}
 
-	/* Set to a reasonable value. Note that this will
-	 * be set to mac80211's value at ath5k_config(). */
-	sc->bintval = 1000;
 	ath5k_hw_set_lladdr(sc->ah, conf->mac_addr);
 
 	ret = 0;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 9f49a32..66a6c1f 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1196,8 +1196,8 @@ void ath_radio_disable(struct ath_softc *sc)
 
 	ath9k_hw_phy_disable(ah);
 	ath9k_hw_configpcipowersave(ah, 1);
-	ath9k_hw_setpower(ah, ATH9K_PM_FULL_SLEEP);
 	ath9k_ps_restore(sc);
+	ath9k_hw_setpower(ah, ATH9K_PM_FULL_SLEEP);
 }
 
 /*******************/
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index ccdf20a..170c5b3 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -87,6 +87,7 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	struct ath_softc *sc;
 	struct ieee80211_hw *hw;
 	u8 csz;
+	u32 val;
 	int ret = 0;
 	struct ath_hw *ah;
 
@@ -133,6 +134,14 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pci_set_master(pdev);
 
+	/*
+	 * Disable the RETRY_TIMEOUT register (0x41) to keep
+	 * PCI Tx retries from interfering with C3 CPU state.
+	 */
+	pci_read_config_dword(pdev, 0x40, &val);
+	if ((val & 0x0000ff00) != 0)
+		pci_write_config_dword(pdev, 0x40, val & 0xffff00ff);
+
 	ret = pci_request_region(pdev, 0, "ath9k");
 	if (ret) {
 		dev_err(&pdev->dev, "PCI memory region reserve error\n");
@@ -239,12 +248,21 @@ static int ath_pci_resume(struct pci_dev *pdev)
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct ath_wiphy *aphy = hw->priv;
 	struct ath_softc *sc = aphy->sc;
+	u32 val;
 	int err;
 
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 	pci_restore_state(pdev);
+	/*
+	 * Suspend/Resume resets the PCI configuration space, so we have to
+	 * re-disable the RETRY_TIMEOUT register (0x41) to keep
+	 * PCI Tx retries from interfering with C3 CPU state
+	 */
+	pci_read_config_dword(pdev, 0x40, &val);
+	if ((val & 0x0000ff00) != 0)
+		pci_write_config_dword(pdev, 0x40, val & 0xffff00ff);
 
 	/* Enable LED */
 	ath9k_hw_cfg_output(sc->sc_ah, ATH_LED_PIN,
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index f99f3a7..cece1c4 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -539,11 +539,14 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 	if (ath_beacon_dtim_pending_cab(skb)) {
 		/*
 		 * Remain awake waiting for buffered broadcast/multicast
-		 * frames.
+		 * frames. If the last broadcast/multicast frame is not
+		 * received properly, the next beacon frame will work as
+		 * a backup trigger for returning into NETWORK SLEEP state,
+		 * so we are waiting for it as well.
 		 */
 		DPRINTF(sc, ATH_DBG_PS, "Received DTIM beacon indicating "
 			"buffered broadcast/multicast frame(s)\n");
-		sc->sc_flags |= SC_OP_WAIT_FOR_CAB;
+		sc->sc_flags |= SC_OP_WAIT_FOR_CAB | SC_OP_WAIT_FOR_BEACON;
 		return;
 	}
 
diff --git a/drivers/net/wireless/iwmc3200wifi/iwm.h b/drivers/net/wireless/iwmc3200wifi/iwm.h
index 635c16e..77c339f 100644
--- a/drivers/net/wireless/iwmc3200wifi/iwm.h
+++ b/drivers/net/wireless/iwmc3200wifi/iwm.h
@@ -288,6 +288,7 @@ struct iwm_priv {
 	u8 *eeprom;
 	struct timer_list watchdog;
 	struct work_struct reset_worker;
+	struct mutex mutex;
 	struct rfkill *rfkill;
 
 	char private[0] __attribute__((__aligned__(NETDEV_ALIGN)));
@@ -315,8 +316,11 @@ extern const struct iw_handler_def iwm_iw_handler_def;
 void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 		   struct iwm_if_ops *if_ops);
 void iwm_if_free(struct iwm_priv *iwm);
+int iwm_if_add(struct iwm_priv *iwm);
+void iwm_if_remove(struct iwm_priv *iwm);
 int iwm_mode_to_nl80211_iftype(int mode);
 int iwm_priv_init(struct iwm_priv *iwm);
+void iwm_priv_deinit(struct iwm_priv *iwm);
 void iwm_reset(struct iwm_priv *iwm);
 void iwm_tx_credit_init_pools(struct iwm_priv *iwm,
 			      struct iwm_umac_notif_alive *alive);
diff --git a/drivers/net/wireless/iwmc3200wifi/main.c b/drivers/net/wireless/iwmc3200wifi/main.c
index 6a2640f..8be206d 100644
--- a/drivers/net/wireless/iwmc3200wifi/main.c
+++ b/drivers/net/wireless/iwmc3200wifi/main.c
@@ -112,6 +112,9 @@ static void iwm_statistics_request(struct work_struct *work)
 	iwm_send_umac_stats_req(iwm, 0);
 }
 
+int __iwm_up(struct iwm_priv *iwm);
+int __iwm_down(struct iwm_priv *iwm);
+
 static void iwm_reset_worker(struct work_struct *work)
 {
 	struct iwm_priv *iwm;
@@ -120,6 +123,19 @@ static void iwm_reset_worker(struct work_struct *work)
 
 	iwm = container_of(work, struct iwm_priv, reset_worker);
 
+	/*
+	 * XXX: The iwm->mutex is introduced purely for this reset work,
+	 * because the other users for iwm_up and iwm_down are only netdev
+	 * ndo_open and ndo_stop which are already protected by rtnl.
+	 * Please remove iwm->mutex together if iwm_reset_worker() is not
+	 * required in the future.
+	 */
+	if (!mutex_trylock(&iwm->mutex)) {
+		IWM_WARN(iwm, "We are in the middle of interface bringing "
+			 "UP/DOWN. Skip driver resetting.\n");
+		return;
+	}
+
 	if (iwm->umac_profile_active) {
 		profile = kmalloc(sizeof(struct iwm_umac_profile), GFP_KERNEL);
 		if (profile)
@@ -128,10 +144,10 @@ static void iwm_reset_worker(struct work_struct *work)
 			IWM_ERR(iwm, "Couldn't alloc memory for profile\n");
 	}
 
-	iwm_down(iwm);
+	__iwm_down(iwm);
 
 	while (retry++ < 3) {
-		ret = iwm_up(iwm);
+		ret = __iwm_up(iwm);
 		if (!ret)
 			break;
 
@@ -142,7 +158,7 @@ static void iwm_reset_worker(struct work_struct *work)
 		IWM_WARN(iwm, "iwm_up() failed: %d\n", ret);
 
 		kfree(profile);
-		return;
+		goto out;
 	}
 
 	if (profile) {
@@ -151,6 +167,9 @@ static void iwm_reset_worker(struct work_struct *work)
 		iwm_send_mlme_profile(iwm);
 		kfree(profile);
 	}
+
+ out:
+	mutex_unlock(&iwm->mutex);
 }
 
 static void iwm_watchdog(unsigned long data)
@@ -215,10 +234,21 @@ int iwm_priv_init(struct iwm_priv *iwm)
 	init_timer(&iwm->watchdog);
 	iwm->watchdog.function = iwm_watchdog;
 	iwm->watchdog.data = (unsigned long)iwm;
+	mutex_init(&iwm->mutex);
 
 	return 0;
 }
 
+void iwm_priv_deinit(struct iwm_priv *iwm)
+{
+	int i;
+
+	for (i = 0; i < IWM_TX_QUEUES; i++)
+		destroy_workqueue(iwm->txq[i].wq);
+
+	destroy_workqueue(iwm->rx_wq);
+}
+
 /*
  * We reset all the structures, and we reset the UMAC.
  * After calling this routine, you're expected to reload
@@ -466,7 +496,7 @@ void iwm_link_off(struct iwm_priv *iwm)
 
 	iwm_rx_free(iwm);
 
-	cancel_delayed_work(&iwm->stats_request);
+	cancel_delayed_work_sync(&iwm->stats_request);
 	memset(wstats, 0, sizeof(struct iw_statistics));
 	wstats->qual.updated = IW_QUAL_ALL_INVALID;
 
@@ -511,7 +541,7 @@ static int iwm_channels_init(struct iwm_priv *iwm)
 	return 0;
 }
 
-int iwm_up(struct iwm_priv *iwm)
+int __iwm_up(struct iwm_priv *iwm)
 {
 	int ret;
 	struct iwm_notif *notif_reboot, *notif_ack = NULL;
@@ -647,7 +677,18 @@ int iwm_up(struct iwm_priv *iwm)
 	return -EIO;
 }
 
-int iwm_down(struct iwm_priv *iwm)
+int iwm_up(struct iwm_priv *iwm)
+{
+	int ret;
+
+	mutex_lock(&iwm->mutex);
+	ret = __iwm_up(iwm);
+	mutex_unlock(&iwm->mutex);
+
+	return ret;
+}
+
+int __iwm_down(struct iwm_priv *iwm)
 {
 	int ret;
 
@@ -678,3 +719,14 @@ int iwm_down(struct iwm_priv *iwm)
 
 	return 0;
 }
+
+int iwm_down(struct iwm_priv *iwm)
+{
+	int ret;
+
+	mutex_lock(&iwm->mutex);
+	ret = __iwm_down(iwm);
+	mutex_unlock(&iwm->mutex);
+
+	return ret;
+}
diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/wireless/iwmc3200wifi/netdev.c
index 68e2c3b..aaa20c6 100644
--- a/drivers/net/wireless/iwmc3200wifi/netdev.c
+++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
@@ -114,32 +114,31 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 	iwm = wdev_to_iwm(wdev);
 	iwm->bus_ops = if_ops;
 	iwm->wdev = wdev;
-	iwm_priv_init(iwm);
+
+	ret = iwm_priv_init(iwm);
+	if (ret) {
+		dev_err(dev, "failed to init iwm_priv\n");
+		goto out_wdev;
+	}
+
 	wdev->iftype = iwm_mode_to_nl80211_iftype(iwm->conf.mode);
 
-	ndev = alloc_netdev_mq(0, "wlan%d", ether_setup,
-			       IWM_TX_QUEUES);
+	ndev = alloc_netdev_mq(0, "wlan%d", ether_setup, IWM_TX_QUEUES);
 	if (!ndev) {
 		dev_err(dev, "no memory for network device instance\n");
-		goto out_wdev;
+		goto out_priv;
 	}
 
 	ndev->netdev_ops = &iwm_netdev_ops;
 	ndev->wireless_handlers = &iwm_iw_handler_def;
 	ndev->ieee80211_ptr = wdev;
 	SET_NETDEV_DEV(ndev, wiphy_dev(wdev->wiphy));
-	ret = register_netdev(ndev);
-	if (ret < 0) {
-		dev_err(dev, "Failed to register netdev: %d\n", ret);
-		goto out_ndev;
-	}
-
 	wdev->netdev = ndev;
 
 	return iwm;
 
- out_ndev:
-	free_netdev(ndev);
+ out_priv:
+	iwm_priv_deinit(iwm);
 
  out_wdev:
 	iwm_wdev_free(iwm);
@@ -148,15 +147,29 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 
 void iwm_if_free(struct iwm_priv *iwm)
 {
-	int i;
-
 	if (!iwm_to_ndev(iwm))
 		return;
 
-	unregister_netdev(iwm_to_ndev(iwm));
 	free_netdev(iwm_to_ndev(iwm));
 	iwm_wdev_free(iwm);
-	destroy_workqueue(iwm->rx_wq);
-	for (i = 0; i < IWM_TX_QUEUES; i++)
-		destroy_workqueue(iwm->txq[i].wq);
+	iwm_priv_deinit(iwm);
+}
+
+int iwm_if_add(struct iwm_priv *iwm)
+{
+	struct net_device *ndev = iwm_to_ndev(iwm);
+	int ret;
+
+	ret = register_netdev(ndev);
+	if (ret < 0) {
+		dev_err(&ndev->dev, "Failed to register netdev: %d\n", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+void iwm_if_remove(struct iwm_priv *iwm)
+{
+	unregister_netdev(iwm_to_ndev(iwm));
 }
diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.c b/drivers/net/wireless/iwmc3200wifi/sdio.c
index b54da67..9166818 100644
--- a/drivers/net/wireless/iwmc3200wifi/sdio.c
+++ b/drivers/net/wireless/iwmc3200wifi/sdio.c
@@ -454,10 +454,18 @@ static int iwm_sdio_probe(struct sdio_func *func,
 
 	INIT_WORK(&hw->isr_worker, iwm_sdio_isr_worker);
 
+	ret = iwm_if_add(iwm);
+	if (ret) {
+		dev_err(dev, "add SDIO interface failed\n");
+		goto destroy_wq;
+	}
+
 	dev_info(dev, "IWM SDIO probe\n");
 
 	return 0;
 
+ destroy_wq:
+	destroy_workqueue(hw->isr_wq);
  debugfs_exit:
 	iwm_debugfs_exit(iwm);
  if_free:
@@ -471,9 +479,10 @@ static void iwm_sdio_remove(struct sdio_func *func)
 	struct iwm_priv *iwm = hw_to_iwm(hw);
 	struct device *dev = &func->dev;
 
+	iwm_if_remove(iwm);
+	destroy_workqueue(hw->isr_wq);
 	iwm_debugfs_exit(iwm);
 	iwm_if_free(iwm);
-	destroy_workqueue(hw->isr_wq);
 
 	sdio_set_drvdata(func, NULL);
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index f0e5e94..14a19ba 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -67,6 +67,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x083a, 0xe503), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x083a, 0xe506), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
diff --git a/drivers/platform/x86/acer-wmi.c b/drivers/platform/x86/acer-wmi.c
index 09a503e..be2fd6f 100644
--- a/drivers/platform/x86/acer-wmi.c
+++ b/drivers/platform/x86/acer-wmi.c
@@ -958,12 +958,12 @@ static void acer_rfkill_update(struct work_struct *ignored)
 
 	status = get_u32(&state, ACER_CAP_WIRELESS);
 	if (ACPI_SUCCESS(status))
-		rfkill_set_sw_state(wireless_rfkill, !!state);
+		rfkill_set_sw_state(wireless_rfkill, !state);
 
 	if (has_cap(ACER_CAP_BLUETOOTH)) {
 		status = get_u32(&state, ACER_CAP_BLUETOOTH);
 		if (ACPI_SUCCESS(status))
-			rfkill_set_sw_state(bluetooth_rfkill, !!state);
+			rfkill_set_sw_state(bluetooth_rfkill, !state);
 	}
 
 	schedule_delayed_work(&acer_rfkill_work, round_jiffies_relative(HZ));
diff --git a/drivers/platform/x86/eeepc-laptop.c b/drivers/platform/x86/eeepc-laptop.c
index 03bf522..8153b3e 100644
--- a/drivers/platform/x86/eeepc-laptop.c
+++ b/drivers/platform/x86/eeepc-laptop.c
@@ -180,6 +180,7 @@ static struct key_entry eeepc_keymap[] = {
  */
 static int eeepc_hotk_add(struct acpi_device *device);
 static int eeepc_hotk_remove(struct acpi_device *device, int type);
+static int eeepc_hotk_resume(struct acpi_device *device);
 
 static const struct acpi_device_id eeepc_device_ids[] = {
 	{EEEPC_HOTK_HID, 0},
@@ -194,6 +195,7 @@ static struct acpi_driver eeepc_hotk_driver = {
 	.ops = {
 		.add = eeepc_hotk_add,
 		.remove = eeepc_hotk_remove,
+		.resume = eeepc_hotk_resume,
 	},
 };
 
@@ -512,15 +514,12 @@ static int notify_brn(void)
 	return -1;
 }
 
-static void eeepc_rfkill_notify(acpi_handle handle, u32 event, void *data)
+static void eeepc_rfkill_hotplug(void)
 {
 	struct pci_dev *dev;
 	struct pci_bus *bus = pci_find_bus(0, 1);
 	bool blocked;
 
-	if (event != ACPI_NOTIFY_BUS_CHECK)
-		return;
-
 	if (!bus) {
 		printk(EEEPC_WARNING "Unable to find PCI bus 1?\n");
 		return;
@@ -551,6 +550,14 @@ static void eeepc_rfkill_notify(acpi_handle handle, u32 event, void *data)
 	rfkill_set_sw_state(ehotk->eeepc_wlan_rfkill, blocked);
 }
 
+static void eeepc_rfkill_notify(acpi_handle handle, u32 event, void *data)
+{
+	if (event != ACPI_NOTIFY_BUS_CHECK)
+		return;
+
+	eeepc_rfkill_hotplug();
+}
+
 static void eeepc_hotk_notify(acpi_handle handle, u32 event, void *data)
 {
 	static struct key_entry *key;
@@ -675,8 +682,8 @@ static int eeepc_hotk_add(struct acpi_device *device)
 		if (!ehotk->eeepc_wlan_rfkill)
 			goto wlan_fail;
 
-		rfkill_set_sw_state(ehotk->eeepc_wlan_rfkill,
-				    get_acpi(CM_ASL_WLAN) != 1);
+		rfkill_init_sw_state(ehotk->eeepc_wlan_rfkill,
+				     get_acpi(CM_ASL_WLAN) != 1);
 		result = rfkill_register(ehotk->eeepc_wlan_rfkill);
 		if (result)
 			goto wlan_fail;
@@ -693,8 +700,8 @@ static int eeepc_hotk_add(struct acpi_device *device)
 		if (!ehotk->eeepc_bluetooth_rfkill)
 			goto bluetooth_fail;
 
-		rfkill_set_sw_state(ehotk->eeepc_bluetooth_rfkill,
-				    get_acpi(CM_ASL_BLUETOOTH) != 1);
+		rfkill_init_sw_state(ehotk->eeepc_bluetooth_rfkill,
+				     get_acpi(CM_ASL_BLUETOOTH) != 1);
 		result = rfkill_register(ehotk->eeepc_bluetooth_rfkill);
 		if (result)
 			goto bluetooth_fail;
@@ -734,6 +741,33 @@ static int eeepc_hotk_remove(struct acpi_device *device, int type)
 	return 0;
 }
 
+static int eeepc_hotk_resume(struct acpi_device *device)
+{
+	if (ehotk->eeepc_wlan_rfkill) {
+		bool wlan;
+
+		/* Workaround - it seems that _PTS disables the wireless
+		   without notification or changing the value read by WLAN.
+		   Normally this is fine because the correct value is restored
+		   from the non-volatile storage on resume, but we need to do
+		   it ourself if case suspend is aborted, or we lose wireless.
+		 */
+		wlan = get_acpi(CM_ASL_WLAN);
+		set_acpi(CM_ASL_WLAN, wlan);
+
+		rfkill_set_sw_state(ehotk->eeepc_wlan_rfkill,
+				    wlan != 1);
+
+		eeepc_rfkill_hotplug();
+	}
+
+	if (ehotk->eeepc_bluetooth_rfkill)
+		rfkill_set_sw_state(ehotk->eeepc_bluetooth_rfkill,
+				    get_acpi(CM_ASL_BLUETOOTH) != 1);
+
+	return 0;
+}
+
 /*
  * Hwmon
  */
diff --git a/drivers/platform/x86/thinkpad_acpi.c b/drivers/platform/x86/thinkpad_acpi.c
index 86e9585..40d64c0 100644
--- a/drivers/platform/x86/thinkpad_acpi.c
+++ b/drivers/platform/x86/thinkpad_acpi.c
@@ -1163,8 +1163,8 @@ static int __init tpacpi_new_rfkill(const enum tpacpi_rfk_id id,
 {
 	struct tpacpi_rfk *atp_rfk;
 	int res;
-	bool initial_sw_state = false;
-	int initial_sw_status;
+	bool sw_state = false;
+	int sw_status;
 
 	BUG_ON(id >= TPACPI_RFK_SW_MAX || tpacpi_rfkill_switches[id]);
 
@@ -1185,17 +1185,17 @@ static int __init tpacpi_new_rfkill(const enum tpacpi_rfk_id id,
 	atp_rfk->id = id;
 	atp_rfk->ops = tp_rfkops;
 
-	initial_sw_status = (tp_rfkops->get_status)();
-	if (initial_sw_status < 0) {
+	sw_status = (tp_rfkops->get_status)();
+	if (sw_status < 0) {
 		printk(TPACPI_ERR
 			"failed to read initial state for %s, error %d\n",
-			name, initial_sw_status);
+			name, sw_status);
 	} else {
-		initial_sw_state = (initial_sw_status == TPACPI_RFK_RADIO_OFF);
+		sw_state = (sw_status == TPACPI_RFK_RADIO_OFF);
 		if (set_default) {
 			/* try to keep the initial state, since we ask the
 			 * firmware to preserve it across S5 in NVRAM */
-			rfkill_set_sw_state(atp_rfk->rfkill, initial_sw_state);
+			rfkill_init_sw_state(atp_rfk->rfkill, sw_state);
 		}
 	}
 	rfkill_set_hw_state(atp_rfk->rfkill, tpacpi_rfk_check_hwblock_state());
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index 16e39c7..e73e242 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -160,8 +160,9 @@ struct rfkill * __must_check rfkill_alloc(const char *name,
  * the rfkill structure. Before calling this function the driver needs
  * to be ready to service method calls from rfkill.
  *
- * If the software blocked state is not set before registration,
- * set_block will be called to initialize it to a default value.
+ * If rfkill_init_sw_state() is not called before registration,
+ * set_block() will be called to initialize the software blocked state
+ * to a default value.
  *
  * If the hardware blocked state is not set before registration,
  * it is assumed to be unblocked.
@@ -234,9 +235,11 @@ bool __must_check rfkill_set_hw_state(struct rfkill *rfkill, bool blocked);
  * rfkill drivers that get events when the soft-blocked state changes
  * (yes, some platforms directly act on input but allow changing again)
  * use this function to notify the rfkill core (and through that also
- * userspace) of the current state.  It is not necessary to notify on
- * resume; since hibernation can always change the soft-blocked state,
- * the rfkill core will unconditionally restore the previous state.
+ * userspace) of the current state.
+ *
+ * Drivers should also call this function after resume if the state has
+ * been changed by the user.  This only makes sense for "persistent"
+ * devices (see rfkill_init_sw_state()).
  *
  * This function can be called in any context, even from within rfkill
  * callbacks.
@@ -247,6 +250,22 @@ bool __must_check rfkill_set_hw_state(struct rfkill *rfkill, bool blocked);
 bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked);
 
 /**
+ * rfkill_init_sw_state - Initialize persistent software block state
+ * @rfkill: pointer to the rfkill class to modify.
+ * @state: the current software block state to set
+ *
+ * rfkill drivers that preserve their software block state over power off
+ * use this function to notify the rfkill core (and through that also
+ * userspace) of their initial state.  It should only be used before
+ * registration.
+ *
+ * In addition, it marks the device as "persistent", an attribute which
+ * can be read by userspace.  Persistent devices are expected to preserve
+ * their own state when suspended.
+ */
+void rfkill_init_sw_state(struct rfkill *rfkill, bool blocked);
+
+/**
  * rfkill_set_states - Set the internal rfkill block states
  * @rfkill: pointer to the rfkill class to modify.
  * @sw: the current software block state to set
@@ -307,6 +326,10 @@ static inline bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
 	return blocked;
 }
 
+static inline void rfkill_init_sw_state(struct rfkill *rfkill, bool blocked)
+{
+}
+
 static inline void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
 {
 }
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 4e68ab4..79693fe 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -56,7 +56,6 @@ struct rfkill {
 	u32			idx;
 
 	bool			registered;
-	bool			suspended;
 	bool			persistent;
 
 	const struct rfkill_ops	*ops;
@@ -224,7 +223,7 @@ static void rfkill_send_events(struct rfkill *rfkill, enum rfkill_operation op)
 
 static void rfkill_event(struct rfkill *rfkill)
 {
-	if (!rfkill->registered || rfkill->suspended)
+	if (!rfkill->registered)
 		return;
 
 	kobject_uevent(&rfkill->dev.kobj, KOBJ_CHANGE);
@@ -270,6 +269,9 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
 	unsigned long flags;
 	int err;
 
+	if (unlikely(rfkill->dev.power.power_state.event & PM_EVENT_SLEEP))
+		return;
+
 	/*
 	 * Some platforms (...!) generate input events which affect the
 	 * _hard_ kill state -- whenever something tries to change the
@@ -292,9 +294,6 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
 	rfkill->state |= RFKILL_BLOCK_SW_SETCALL;
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
-	if (unlikely(rfkill->dev.power.power_state.event & PM_EVENT_SLEEP))
-		return;
-
 	err = rfkill->ops->set_block(rfkill->data, blocked);
 
 	spin_lock_irqsave(&rfkill->lock, flags);
@@ -508,19 +507,32 @@ bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
 	blocked = blocked || hwblock;
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
-	if (!rfkill->registered) {
-		rfkill->persistent = true;
-	} else {
-		if (prev != blocked && !hwblock)
-			schedule_work(&rfkill->uevent_work);
+	if (!rfkill->registered)
+		return blocked;
 
-		rfkill_led_trigger_event(rfkill);
-	}
+	if (prev != blocked && !hwblock)
+		schedule_work(&rfkill->uevent_work);
+
+	rfkill_led_trigger_event(rfkill);
 
 	return blocked;
 }
 EXPORT_SYMBOL(rfkill_set_sw_state);
 
+void rfkill_init_sw_state(struct rfkill *rfkill, bool blocked)
+{
+	unsigned long flags;
+
+	BUG_ON(!rfkill);
+	BUG_ON(rfkill->registered);
+
+	spin_lock_irqsave(&rfkill->lock, flags);
+	__rfkill_set_sw_state(rfkill, blocked);
+	rfkill->persistent = true;
+	spin_unlock_irqrestore(&rfkill->lock, flags);
+}
+EXPORT_SYMBOL(rfkill_init_sw_state);
+
 void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
 {
 	unsigned long flags;
@@ -598,6 +610,15 @@ static ssize_t rfkill_idx_show(struct device *dev,
 	return sprintf(buf, "%d\n", rfkill->idx);
 }
 
+static ssize_t rfkill_persistent_show(struct device *dev,
+			       struct device_attribute *attr,
+			       char *buf)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	return sprintf(buf, "%d\n", rfkill->persistent);
+}
+
 static u8 user_state_from_blocked(unsigned long state)
 {
 	if (state & RFKILL_BLOCK_HW)
@@ -656,6 +677,7 @@ static struct device_attribute rfkill_dev_attrs[] = {
 	__ATTR(name, S_IRUGO, rfkill_name_show, NULL),
 	__ATTR(type, S_IRUGO, rfkill_type_show, NULL),
 	__ATTR(index, S_IRUGO, rfkill_idx_show, NULL),
+	__ATTR(persistent, S_IRUGO, rfkill_persistent_show, NULL),
 	__ATTR(state, S_IRUGO|S_IWUSR, rfkill_state_show, rfkill_state_store),
 	__ATTR(claim, S_IRUGO|S_IWUSR, rfkill_claim_show, rfkill_claim_store),
 	__ATTR_NULL
@@ -718,8 +740,6 @@ static int rfkill_suspend(struct device *dev, pm_message_t state)
 
 	rfkill_pause_polling(rfkill);
 
-	rfkill->suspended = true;
-
 	return 0;
 }
 
@@ -728,10 +748,10 @@ static int rfkill_resume(struct device *dev)
 	struct rfkill *rfkill = to_rfkill(dev);
 	bool cur;
 
-	cur = !!(rfkill->state & RFKILL_BLOCK_SW);
-	rfkill_set_block(rfkill, cur);
-
-	rfkill->suspended = false;
+	if (!rfkill->persistent) {
+		cur = !!(rfkill->state & RFKILL_BLOCK_SW);
+		rfkill_set_block(rfkill, cur);
+	}
 
 	rfkill_resume_polling(rfkill);
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 2416856..241bddd 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1687,13 +1687,52 @@ static int nl80211_set_station(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto out_rtnl;
 
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN) {
-		err = -EINVAL;
+	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
+	if (err)
 		goto out;
+
+	/* validate settings */
+	err = 0;
+
+	switch (dev->ieee80211_ptr->iftype) {
+	case NL80211_IFTYPE_AP:
+	case NL80211_IFTYPE_AP_VLAN:
+		/* disallow mesh-specific things */
+		if (params.plink_action)
+			err = -EINVAL;
+		break;
+	case NL80211_IFTYPE_STATION:
+		/* disallow everything but AUTHORIZED flag */
+		if (params.plink_action)
+			err = -EINVAL;
+		if (params.vlan)
+			err = -EINVAL;
+		if (params.supported_rates)
+			err = -EINVAL;
+		if (params.ht_capa)
+			err = -EINVAL;
+		if (params.listen_interval >= 0)
+			err = -EINVAL;
+		if (params.sta_flags_mask & ~BIT(NL80211_STA_FLAG_AUTHORIZED))
+			err = -EINVAL;
+		break;
+	case NL80211_IFTYPE_MESH_POINT:
+		/* disallow things mesh doesn't support */
+		if (params.vlan)
+			err = -EINVAL;
+		if (params.ht_capa)
+			err = -EINVAL;
+		if (params.listen_interval >= 0)
+			err = -EINVAL;
+		if (params.supported_rates)
+			err = -EINVAL;
+		if (params.sta_flags_mask)
+			err = -EINVAL;
+		break;
+	default:
+		err = -EINVAL;
 	}
 
-	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
 	if (err)
 		goto out;
 
@@ -1728,9 +1767,6 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 	if (!info->attrs[NL80211_ATTR_MAC])
 		return -EINVAL;
 
-	if (!info->attrs[NL80211_ATTR_STA_AID])
-		return -EINVAL;
-
 	if (!info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL])
 		return -EINVAL;
 
@@ -1745,9 +1781,11 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 	params.listen_interval =
 		nla_get_u16(info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL]);
 
-	params.aid = nla_get_u16(info->attrs[NL80211_ATTR_STA_AID]);
-	if (!params.aid || params.aid > IEEE80211_MAX_AID)
-		return -EINVAL;
+	if (info->attrs[NL80211_ATTR_STA_AID]) {
+		params.aid = nla_get_u16(info->attrs[NL80211_ATTR_STA_AID]);
+		if (!params.aid || params.aid > IEEE80211_MAX_AID)
+			return -EINVAL;
+	}
 
 	if (info->attrs[NL80211_ATTR_HT_CAPABILITY])
 		params.ht_capa =
@@ -1762,13 +1800,39 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto out_rtnl;
 
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN) {
-		err = -EINVAL;
+	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
+	if (err)
 		goto out;
+
+	/* validate settings */
+	err = 0;
+
+	switch (dev->ieee80211_ptr->iftype) {
+	case NL80211_IFTYPE_AP:
+	case NL80211_IFTYPE_AP_VLAN:
+		/* all ok but must have AID */
+		if (!params.aid)
+			err = -EINVAL;
+		break;
+	case NL80211_IFTYPE_MESH_POINT:
+		/* disallow things mesh doesn't support */
+		if (params.vlan)
+			err = -EINVAL;
+		if (params.aid)
+			err = -EINVAL;
+		if (params.ht_capa)
+			err = -EINVAL;
+		if (params.listen_interval >= 0)
+			err = -EINVAL;
+		if (params.supported_rates)
+			err = -EINVAL;
+		if (params.sta_flags_mask)
+			err = -EINVAL;
+		break;
+	default:
+		err = -EINVAL;
 	}
 
-	err = get_vlan(info->attrs[NL80211_ATTR_STA_VLAN], drv, &params.vlan);
 	if (err)
 		goto out;
 
@@ -1812,7 +1876,8 @@ static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
 		goto out_rtnl;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN) {
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN &&
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT) {
 		err = -EINVAL;
 		goto out;
 	}
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
