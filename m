From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-04-20
Date: Mon, 20 Apr 2009 17:10:25 -0400
Message-ID: <20090420211024.GI3369@tuxdriver.com>
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

Another quick round of fixes for 2.6.30.  There are several related
to suspend/resume problems, the deactivation of some broken powersave
code in p54, the change of an nl80211 allocation to GFP_ATOMIC, a fix
for misbegotten beacon losses during scanning, a fix for a copy/paste
error that opens a remotely exploitable(!) bug, the addition of a
space that was breaking a printk conversion in iwl3945, the removal
of an unused Kconfig option.  The last two are obvious and help to
avoid confusion, so they seem worthwhile to me.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit c40af84a6726f63e35740d26f841992e8f31f92c:
  Herbert Xu (1):
        tun: Fix sk_sleep races when attaching/detaching

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (2):
      p54: deactivate broken powersave function
      ar9170usb: fix hang on resume

Ivo van Doorn (1):
      rt2x00: Don't free register information on suspend

Joe Perches (1):
      iwl3945-base.c: Add missing space to debug print

Joerg Albert (1):
      mwl8k: fix module re-insertion bug

Johannes Berg (1):
      mac80211: fix basic rate bitmap calculation

Jouni Malinen (1):
      nl80211: Make nl80211_send_mlme_event() atomic

Kalle Valo (1):
      mac80211: fix beacon loss detection after scan

Robert P. J. Day (1):
      MAC80211: Remove unused MAC80211_VERBOSE_SPECT_MGMT_DEBUG.

 drivers/net/wireless/ar9170/usb.c           |  110 ++++++++++++++++++++++-----
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
 drivers/net/wireless/mwl8k.c                |    4 +-
 drivers/net/wireless/p54/p54common.c        |    2 -
 drivers/net/wireless/rt2x00/rt2x00pci.c     |   18 +----
 drivers/net/wireless/rt2x00/rt2x00usb.c     |   18 +----
 net/mac80211/Kconfig                        |    7 --
 net/mac80211/mlme.c                         |   12 +++-
 net/wireless/nl80211.c                      |    4 +-
 9 files changed, 107 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/ar9170/usb.c b/drivers/net/wireless/ar9170/usb.c
index c9e422e..fddda47 100644
--- a/drivers/net/wireless/ar9170/usb.c
+++ b/drivers/net/wireless/ar9170/usb.c
@@ -623,6 +623,39 @@ static int ar9170_usb_open(struct ar9170 *ar)
 	return 0;
 }
 
+static int ar9170_usb_init_device(struct ar9170_usb *aru)
+{
+	int err;
+
+	err = ar9170_usb_alloc_rx_irq_urb(aru);
+	if (err)
+		goto err_out;
+
+	err = ar9170_usb_alloc_rx_bulk_urbs(aru);
+	if (err)
+		goto err_unrx;
+
+	err = ar9170_usb_upload_firmware(aru);
+	if (err) {
+		err = ar9170_echo_test(&aru->common, 0x60d43110);
+		if (err) {
+			/* force user invention, by disabling the device */
+			err = usb_driver_set_configuration(aru->udev, -1);
+			dev_err(&aru->udev->dev, "device is in a bad state. "
+						 "please reconnect it!\n");
+			goto err_unrx;
+		}
+	}
+
+	return 0;
+
+err_unrx:
+	ar9170_usb_cancel_urbs(aru);
+
+err_out:
+	return err;
+}
+
 static int ar9170_usb_probe(struct usb_interface *intf,
 			const struct usb_device_id *id)
 {
@@ -658,32 +691,16 @@ static int ar9170_usb_probe(struct usb_interface *intf,
 
 	err = ar9170_usb_reset(aru);
 	if (err)
-		goto err_unlock;
+		goto err_freehw;
 
 	err = ar9170_usb_request_firmware(aru);
 	if (err)
-		goto err_unlock;
+		goto err_freehw;
 
-	err = ar9170_usb_alloc_rx_irq_urb(aru);
+	err = ar9170_usb_init_device(aru);
 	if (err)
 		goto err_freefw;
 
-	err = ar9170_usb_alloc_rx_bulk_urbs(aru);
-	if (err)
-		goto err_unrx;
-
-	err = ar9170_usb_upload_firmware(aru);
-	if (err) {
-		err = ar9170_echo_test(&aru->common, 0x60d43110);
-		if (err) {
-			/* force user invention, by disabling the device */
-			err = usb_driver_set_configuration(aru->udev, -1);
-			dev_err(&aru->udev->dev, "device is in a bad state. "
-						 "please reconnect it!\n");
-			goto err_unrx;
-		}
-	}
-
 	err = ar9170_usb_open(ar);
 	if (err)
 		goto err_unrx;
@@ -703,7 +720,7 @@ err_freefw:
 	release_firmware(aru->init_values);
 	release_firmware(aru->firmware);
 
-err_unlock:
+err_freehw:
 	usb_set_intfdata(intf, NULL);
 	usb_put_dev(udev);
 	ieee80211_free_hw(ar->hw);
@@ -730,12 +747,65 @@ static void ar9170_usb_disconnect(struct usb_interface *intf)
 	ieee80211_free_hw(aru->common.hw);
 }
 
+#ifdef CONFIG_PM
+static int ar9170_suspend(struct usb_interface *intf,
+			  pm_message_t  message)
+{
+	struct ar9170_usb *aru = usb_get_intfdata(intf);
+
+	if (!aru)
+		return -ENODEV;
+
+	aru->common.state = AR9170_IDLE;
+	ar9170_usb_cancel_urbs(aru);
+
+	return 0;
+}
+
+static int ar9170_resume(struct usb_interface *intf)
+{
+	struct ar9170_usb *aru = usb_get_intfdata(intf);
+	int err;
+
+	if (!aru)
+		return -ENODEV;
+
+	usb_unpoison_anchored_urbs(&aru->rx_submitted);
+	usb_unpoison_anchored_urbs(&aru->tx_submitted);
+
+	/*
+	 * FIXME: firmware upload will fail on resume.
+	 * but this is better than a hang!
+	 */
+
+	err = ar9170_usb_init_device(aru);
+	if (err)
+		goto err_unrx;
+
+	err = ar9170_usb_open(&aru->common);
+	if (err)
+		goto err_unrx;
+
+	return 0;
+
+err_unrx:
+	aru->common.state = AR9170_IDLE;
+	ar9170_usb_cancel_urbs(aru);
+
+	return err;
+}
+#endif /* CONFIG_PM */
+
 static struct usb_driver ar9170_driver = {
 	.name = "ar9170usb",
 	.probe = ar9170_usb_probe,
 	.disconnect = ar9170_usb_disconnect,
 	.id_table = ar9170_usb_ids,
 	.soft_unbind = 1,
+#ifdef CONFIG_PM
+	.suspend = ar9170_suspend,
+	.resume = ar9170_resume,
+#endif /* CONFIG_PM */
 };
 
 static int __init ar9170_init(void)
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 8d738d7..da61ecd 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4075,7 +4075,7 @@ static int iwl3945_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	if (!static_key) {
 		sta_id = iwl3945_hw_find_station(priv, addr);
 		if (sta_id == IWL_INVALID_STATION) {
-			IWL_DEBUG_MAC80211(priv, "leave - %pMnot in station map.\n",
+			IWL_DEBUG_MAC80211(priv, "leave - %pM not in station map.\n",
 					    addr);
 			return -EINVAL;
 		}
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 57a0268..b5dbf6d 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -3720,12 +3720,12 @@ err_free_reg:
 	return rc;
 }
 
-static void __devexit mwl8k_remove(struct pci_dev *pdev)
+static void __devexit mwl8k_shutdown(struct pci_dev *pdev)
 {
 	printk(KERN_ERR "===>%s(%u)\n", __func__, __LINE__);
 }
 
-static void __devexit mwl8k_shutdown(struct pci_dev *pdev)
+static void __devexit mwl8k_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct mwl8k_priv *priv;
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 0c1b057..c8f0232 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -2543,8 +2543,6 @@ struct ieee80211_hw *p54_init_common(size_t priv_data_len)
 	priv->basic_rate_mask = 0x15f;
 	skb_queue_head_init(&priv->tx_queue);
 	dev->flags = IEEE80211_HW_RX_INCLUDES_FCS |
-		     IEEE80211_HW_SUPPORTS_PS |
-		     IEEE80211_HW_PS_NULLFUNC_STACK |
 		     IEEE80211_HW_SIGNAL_DBM |
 		     IEEE80211_HW_NOISE_DBM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 43fa0f8..9730b4f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -369,8 +369,6 @@ int rt2x00pci_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	if (retval)
 		return retval;
 
-	rt2x00pci_free_reg(rt2x00dev);
-
 	pci_save_state(pci_dev);
 	pci_disable_device(pci_dev);
 	return pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
@@ -381,7 +379,6 @@ int rt2x00pci_resume(struct pci_dev *pci_dev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pci_dev);
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	int retval;
 
 	if (pci_set_power_state(pci_dev, PCI_D0) ||
 	    pci_enable_device(pci_dev) ||
@@ -390,20 +387,7 @@ int rt2x00pci_resume(struct pci_dev *pci_dev)
 		return -EIO;
 	}
 
-	retval = rt2x00pci_alloc_reg(rt2x00dev);
-	if (retval)
-		return retval;
-
-	retval = rt2x00lib_resume(rt2x00dev);
-	if (retval)
-		goto exit_free_reg;
-
-	return 0;
-
-exit_free_reg:
-	rt2x00pci_free_reg(rt2x00dev);
-
-	return retval;
+	return rt2x00lib_resume(rt2x00dev);
 }
 EXPORT_SYMBOL_GPL(rt2x00pci_resume);
 #endif /* CONFIG_PM */
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 7d50ca8..5015448 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -702,8 +702,6 @@ int rt2x00usb_suspend(struct usb_interface *usb_intf, pm_message_t state)
 	if (retval)
 		return retval;
 
-	rt2x00usb_free_reg(rt2x00dev);
-
 	/*
 	 * Decrease usbdev refcount.
 	 */
@@ -717,24 +715,10 @@ int rt2x00usb_resume(struct usb_interface *usb_intf)
 {
 	struct ieee80211_hw *hw = usb_get_intfdata(usb_intf);
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	int retval;
 
 	usb_get_dev(interface_to_usbdev(usb_intf));
 
-	retval = rt2x00usb_alloc_reg(rt2x00dev);
-	if (retval)
-		return retval;
-
-	retval = rt2x00lib_resume(rt2x00dev);
-	if (retval)
-		goto exit_free_reg;
-
-	return 0;
-
-exit_free_reg:
-	rt2x00usb_free_reg(rt2x00dev);
-
-	return retval;
+	return rt2x00lib_resume(rt2x00dev);
 }
 EXPORT_SYMBOL_GPL(rt2x00usb_resume);
 #endif /* CONFIG_PM */
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index f3d9ae3..ecc3faf 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -202,10 +202,3 @@ config MAC80211_DEBUG_COUNTERS
 	  and show them in debugfs.
 
 	  If unsure, say N.
-
-config MAC80211_VERBOSE_SPECT_MGMT_DEBUG
-	bool "Verbose Spectrum Management (IEEE 802.11h)debugging"
-	depends on MAC80211_DEBUG_MENU
-	---help---
-	  Say Y here to print out verbose Spectrum Management (IEEE 802.11h)
-	  debug messages.
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 1619e0c..132938b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1366,7 +1366,7 @@ static void ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 
 	for (i = 0; i < elems.ext_supp_rates_len; i++) {
 		int rate = (elems.ext_supp_rates[i] & 0x7f) * 5;
-		bool is_basic = !!(elems.supp_rates[i] & 0x80);
+		bool is_basic = !!(elems.ext_supp_rates[i] & 0x80);
 
 		if (rate > 110)
 			have_higher_than_11mbit = true;
@@ -1913,9 +1913,17 @@ static void ieee80211_sta_work(struct work_struct *work)
 
 static void ieee80211_restart_sta_timer(struct ieee80211_sub_if_data *sdata)
 {
-	if (sdata->vif.type == NL80211_IFTYPE_STATION)
+	if (sdata->vif.type == NL80211_IFTYPE_STATION) {
+		/*
+		 * Need to update last_beacon to avoid beacon loss
+		 * test to trigger.
+		 */
+		sdata->u.mgd.last_beacon = jiffies;
+
+
 		queue_work(sdata->local->hw.workqueue,
 			   &sdata->u.mgd.work);
+	}
 }
 
 /* interface setup */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 353e1a4..2456e4e 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3334,7 +3334,7 @@ static void nl80211_send_mlme_event(struct cfg80211_registered_device *rdev,
 	struct sk_buff *msg;
 	void *hdr;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
 	if (!msg)
 		return;
 
@@ -3353,7 +3353,7 @@ static void nl80211_send_mlme_event(struct cfg80211_registered_device *rdev,
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
