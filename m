From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-11-06
Date: Fri, 6 Nov 2009 15:40:34 -0500
Message-ID: <20091106204034.GI2782@tuxdriver.com>
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

Three more intended for 2.6.32, two oops fixes and a revert of a patch
that traded one bug for another.  One of the oops fixes reorders some
cancel_delayed_work_sync calls and the other does some bit testing to
avoid scheduling work after a device has been removed.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit bcfe3c2046fc4f16544f2b127f1b159dd1fcad8b:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

John W. Linville (1):
      Revert "ipw2200: fix oops on missing firmware"

Larry Finger (1):
      rtl8187: Fix kernel oops when device is removed when LEDS enabled

Sean Cross (1):
      rt2x00: Don't queue ieee80211 work after USB removal

 drivers/net/wireless/ipw2x00/ipw2100.c       |    5 +----
 drivers/net/wireless/ipw2x00/ipw2200.c       |    2 --
 drivers/net/wireless/ipw2x00/libipw.h        |    1 -
 drivers/net/wireless/ipw2x00/libipw_module.c |   14 +++++---------
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    4 ++--
 drivers/net/wireless/rt2x00/rt2x00link.c     |   11 +++++++----
 drivers/net/wireless/rt2x00/rt2x00usb.c      |    9 ++++++++-
 drivers/net/wireless/rtl818x/rtl8187_leds.c  |    4 ++--
 8 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index a741d37..240cff1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6325,10 +6325,8 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
       fail:
 	if (dev) {
-		if (registered) {
-			unregister_ieee80211(priv->ieee);
+		if (registered)
 			unregister_netdev(dev);
-		}
 
 		ipw2100_hw_stop_adapter(priv);
 
@@ -6385,7 +6383,6 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 		/* Unregister the device first - this results in close()
 		 * being called if the device is open.  If we free storage
 		 * first, then close() will crash. */
-		unregister_ieee80211(priv->ieee);
 		unregister_netdev(dev);
 
 		/* ipw2100_down will ensure that there is no more pending work
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 04341a2..8d58e6e 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11821,7 +11821,6 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 		if (err) {
 			IPW_ERROR("Failed to register promiscuous network "
 				  "device (error %d).\n", err);
-			unregister_ieee80211(priv->ieee);
 			unregister_netdev(priv->net_dev);
 			goto out_remove_sysfs;
 		}
@@ -11872,7 +11871,6 @@ static void __devexit ipw_pci_remove(struct pci_dev *pdev)
 
 	mutex_unlock(&priv->mutex);
 
-	unregister_ieee80211(priv->ieee);
 	unregister_netdev(priv->net_dev);
 
 	if (priv->rxq) {
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index f42ade6..bf45391 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -1020,7 +1020,6 @@ static inline int libipw_is_cck_rate(u8 rate)
 /* ieee80211.c */
 extern void free_ieee80211(struct net_device *dev, int monitor);
 extern struct net_device *alloc_ieee80211(int sizeof_priv, int monitor);
-extern void unregister_ieee80211(struct libipw_device *ieee);
 extern int libipw_change_mtu(struct net_device *dev, int new_mtu);
 
 extern void libipw_networks_age(struct libipw_device *ieee,
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index be5b809..a0e9f6a 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -235,19 +235,16 @@ void free_ieee80211(struct net_device *dev, int monitor)
 	libipw_networks_free(ieee);
 
 	/* free cfg80211 resources */
-	if (!monitor)
+	if (!monitor) {
+		wiphy_unregister(ieee->wdev.wiphy);
+		kfree(ieee->a_band.channels);
+		kfree(ieee->bg_band.channels);
 		wiphy_free(ieee->wdev.wiphy);
+	}
 
 	free_netdev(dev);
 }
 
-void unregister_ieee80211(struct libipw_device *ieee)
-{
-	wiphy_unregister(ieee->wdev.wiphy);
-	kfree(ieee->a_band.channels);
-	kfree(ieee->bg_band.channels);
-}
-
 #ifdef CONFIG_LIBIPW_DEBUG
 
 static int debug = 0;
@@ -333,4 +330,3 @@ module_init(libipw_init);
 
 EXPORT_SYMBOL(alloc_ieee80211);
 EXPORT_SYMBOL(free_ieee80211);
-EXPORT_SYMBOL(unregister_ieee80211);
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 71761b3..73bbec5 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -815,6 +815,8 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 
 	mutex_init(&rt2x00dev->csr_mutex);
 
+	set_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags);
+
 	/*
 	 * Make room for rt2x00_intf inside the per-interface
 	 * structure ieee80211_vif.
@@ -871,8 +873,6 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	rt2x00leds_register(rt2x00dev);
 	rt2x00debug_register(rt2x00dev);
 
-	set_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags);
-
 	return 0;
 
 exit:
diff --git a/drivers/net/wireless/rt2x00/rt2x00link.c b/drivers/net/wireless/rt2x00/rt2x00link.c
index c64db0b..c708d0b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00link.c
+++ b/drivers/net/wireless/rt2x00/rt2x00link.c
@@ -362,8 +362,9 @@ void rt2x00link_start_tuner(struct rt2x00_dev *rt2x00dev)
 
 	rt2x00link_reset_tuner(rt2x00dev, false);
 
-	ieee80211_queue_delayed_work(rt2x00dev->hw,
-				     &link->work, LINK_TUNE_INTERVAL);
+	if (test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		ieee80211_queue_delayed_work(rt2x00dev->hw,
+					     &link->work, LINK_TUNE_INTERVAL);
 }
 
 void rt2x00link_stop_tuner(struct rt2x00_dev *rt2x00dev)
@@ -469,8 +470,10 @@ static void rt2x00link_tuner(struct work_struct *work)
 	 * Increase tuner counter, and reschedule the next link tuner run.
 	 */
 	link->count++;
-	ieee80211_queue_delayed_work(rt2x00dev->hw,
-				     &link->work, LINK_TUNE_INTERVAL);
+
+	if (test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		ieee80211_queue_delayed_work(rt2x00dev->hw,
+					     &link->work, LINK_TUNE_INTERVAL);
 }
 
 void rt2x00link_register(struct rt2x00_dev *rt2x00dev)
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 5015448..f02b48a 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -47,6 +47,8 @@ int rt2x00usb_vendor_request(struct rt2x00_dev *rt2x00dev,
 	    (requesttype == USB_VENDOR_REQUEST_IN) ?
 	    usb_rcvctrlpipe(usb_dev, 0) : usb_sndctrlpipe(usb_dev, 0);
 
+	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		return -ENODEV;
 
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		status = usb_control_msg(usb_dev, pipe, request, requesttype,
@@ -60,8 +62,10 @@ int rt2x00usb_vendor_request(struct rt2x00_dev *rt2x00dev,
 		 * -ENODEV: Device has disappeared, no point continuing.
 		 * All other errors: Try again.
 		 */
-		else if (status == -ENODEV)
+		else if (status == -ENODEV) {
+			clear_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags);
 			break;
+		}
 	}
 
 	ERROR(rt2x00dev,
@@ -161,6 +165,9 @@ int rt2x00usb_regbusy_read(struct rt2x00_dev *rt2x00dev,
 {
 	unsigned int i;
 
+	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		return -ENODEV;
+
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00usb_register_read_lock(rt2x00dev, offset, reg);
 		if (!rt2x00_get_field32(*reg, field))
diff --git a/drivers/net/wireless/rtl818x/rtl8187_leds.c b/drivers/net/wireless/rtl818x/rtl8187_leds.c
index a1c670f..cf8a4a4 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_leds.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_leds.c
@@ -210,10 +210,10 @@ void rtl8187_leds_exit(struct ieee80211_hw *dev)
 
 	/* turn the LED off before exiting */
 	ieee80211_queue_delayed_work(dev, &priv->led_off, 0);
-	cancel_delayed_work_sync(&priv->led_off);
-	cancel_delayed_work_sync(&priv->led_on);
 	rtl8187_unregister_led(&priv->led_rx);
 	rtl8187_unregister_led(&priv->led_tx);
+	cancel_delayed_work_sync(&priv->led_off);
+	cancel_delayed_work_sync(&priv->led_on);
 }
 #endif /* def CONFIG_RTL8187_LED */
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
