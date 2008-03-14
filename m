From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-03-13
Date: Thu, 13 Mar 2008 21:05:04 -0400
Message-ID: <20080314010504.GA31964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3973 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbYCNBVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2008 21:21:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here are a few more fixes for 2.6.25.  The rt2x00 one is a bit big, but
it is needed to fix kernel.org bug 9585 (a NULL pointer dereference).
There is also a work-around for a firmware bug on the PS3 wireless
driver, as well as some one liners.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit f1dd9c379cac7d5a76259e7dffcd5f8edc697d17:
  Zhang Yanmin (1):
        [NET]: Fix tbench regression in 2.6.25-rc1

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Harvey Harrison (1):
      b43: phy.c fix typo in register write

Ivo van Doorn (1):
      rt2x00: Add suspend/resume handlers to rt2x00rfkill

Jan Slupski (1):
      prism54: support for 124a:4025 - another version of IOGear GWU513 802.11g

Masakazu Mokuno (2):
      PS3: gelic: ignore scan info from zero SSID beacons
      PS3: gelic: change the prefix of the net interface for wireless

Pavel Roskin (1):
      ath5k: disable irq handling in ath5k_hw_detach()

 drivers/net/ps3_gelic_wireless.c           |   29 ++++---
 drivers/net/wireless/ath5k/hw.c            |    2 +
 drivers/net/wireless/b43/phy.c             |    2 +-
 drivers/net/wireless/p54usb.c              |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h       |    3 +
 drivers/net/wireless/rt2x00/rt2x00dev.c    |   35 ++++-----
 drivers/net/wireless/rt2x00/rt2x00lib.h    |   20 ++++--
 drivers/net/wireless/rt2x00/rt2x00rfkill.c |  116 ++++++++++++++++++----------
 8 files changed, 127 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index daf5aba..ddbc6e4 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -1644,13 +1644,24 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 	}
 
 	/* put them in the newtork_list */
-	scan_info = wl->buf;
-	scan_info_size = 0;
-	i = 0;
-	while (scan_info_size < data_len) {
+	for (i = 0, scan_info_size = 0, scan_info = wl->buf;
+	     scan_info_size < data_len;
+	     i++, scan_info_size += be16_to_cpu(scan_info->size),
+	     scan_info = (void *)scan_info + be16_to_cpu(scan_info->size)) {
 		pr_debug("%s:size=%d bssid=%s scan_info=%p\n", __func__,
 			 be16_to_cpu(scan_info->size),
 			 print_mac(mac, &scan_info->bssid[2]), scan_info);
+
+		/*
+		 * The wireless firmware may return invalid channel 0 and/or
+		 * invalid rate if the AP emits zero length SSID ie. As this
+		 * scan information is useless, ignore it
+		 */
+		if (!be16_to_cpu(scan_info->channel) || !scan_info->rate[0]) {
+			pr_debug("%s: invalid scan info\n", __func__);
+			continue;
+		}
+
 		found = 0;
 		oldest = NULL;
 		list_for_each_entry(target, &wl->network_list, list) {
@@ -1687,10 +1698,6 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 					 GFP_KERNEL);
 		if (!target->hwinfo) {
 			pr_info("%s: kzalloc failed\n", __func__);
-			i++;
-			scan_info_size += be16_to_cpu(scan_info->size);
-			scan_info = (void *)scan_info +
-				be16_to_cpu(scan_info->size);
 			continue;
 		}
 		/* copy hw scan info */
@@ -1709,10 +1716,6 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 			if (scan_info->ext_rate[r])
 				target->rate_ext_len++;
 		list_move_tail(&target->list, &wl->network_list);
-		/* bump pointer */
-		i++;
-		scan_info_size += be16_to_cpu(scan_info->size);
-		scan_info = (void *)scan_info + be16_to_cpu(scan_info->size);
 	}
 	memset(&data, 0, sizeof(data));
 	wireless_send_event(port_to_netdev(wl_port(wl)), SIOCGIWSCAN, &data,
@@ -2389,6 +2392,8 @@ static struct net_device *gelic_wl_alloc(struct gelic_card *card)
 	if (!netdev)
 		return NULL;
 
+	strcpy(netdev->name, "wlan%d");
+
 	port = netdev_priv(netdev);
 	port->netdev = netdev;
 	port->card = card;
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index c2de2d9..0175743 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -427,6 +427,8 @@ void ath5k_hw_detach(struct ath5k_hw *ah)
 {
 	ATH5K_TRACE(ah->ah_sc);
 
+	__set_bit(ATH_STAT_INVALID, ah->ah_sc->status);
+
 	if (ah->ah_rf_banks != NULL)
 		kfree(ah->ah_rf_banks);
 
diff --git a/drivers/net/wireless/b43/phy.c b/drivers/net/wireless/b43/phy.c
index 71507b2..575c543 100644
--- a/drivers/net/wireless/b43/phy.c
+++ b/drivers/net/wireless/b43/phy.c
@@ -860,7 +860,7 @@ static void b43_phy_ww(struct b43_wldev *dev)
 	b43_phy_write(dev, B43_PHY_OFDM(0xBB),
 		(b43_phy_read(dev, B43_PHY_OFDM(0xBB)) & 0xF000) | 0x0053);
 	b43_phy_write(dev, B43_PHY_OFDM61,
-		(b43_phy_read(dev, B43_PHY_OFDM61 & 0xFE1F)) | 0x0120);
+		(b43_phy_read(dev, B43_PHY_OFDM61) & 0xFE1F) | 0x0120);
 	b43_phy_write(dev, B43_PHY_OFDM(0x13),
 		(b43_phy_read(dev, B43_PHY_OFDM(0x13)) & 0x0FFF) | 0x3000);
 	b43_phy_write(dev, B43_PHY_OFDM(0x14),
diff --git a/drivers/net/wireless/p54usb.c b/drivers/net/wireless/p54usb.c
index e7d4aee..98ddbb3 100644
--- a/drivers/net/wireless/p54usb.c
+++ b/drivers/net/wireless/p54usb.c
@@ -63,6 +63,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0cde, 0x0008)},	/* Sagem XG703A */
 	{USB_DEVICE(0x0d8e, 0x3762)},	/* DLink DWL-G120 Cohiba */
 	{USB_DEVICE(0x09aa, 0x1000)},	/* Spinnaker Proto board */
+	{USB_DEVICE(0x124a, 0x4025)},	/* IOGear GWU513 (GW3887IK chip) */
 	{USB_DEVICE(0x13b1, 0x000a)},	/* Linksys WUSB54G ver 2 */
 	{USB_DEVICE(0x13B1, 0x000C)},	/* Linksys WUSB54AG */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 05927b9..6c72542 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -620,6 +620,9 @@ struct rt2x00_dev {
 	 * This will only be compiled in when required.
 	 */
 #ifdef CONFIG_RT2X00_LIB_RFKILL
+unsigned long rfkill_state;
+#define RFKILL_STATE_ALLOCATED		1
+#define RFKILL_STATE_REGISTERED		2
 	struct rfkill *rfkill;
 	struct input_polled_dev *poll_dev;
 #endif /* CONFIG_RT2X00_LIB_RFKILL */
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 0d51f47..bc846ba 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1098,7 +1098,7 @@ static void rt2x00lib_uninitialize(struct rt2x00_dev *rt2x00dev)
 		return;
 
 	/*
-	 * Unregister rfkill.
+	 * Unregister extra components.
 	 */
 	rt2x00rfkill_unregister(rt2x00dev);
 
@@ -1139,11 +1139,9 @@ static int rt2x00lib_initialize(struct rt2x00_dev *rt2x00dev)
 	__set_bit(DEVICE_INITIALIZED, &rt2x00dev->flags);
 
 	/*
-	 * Register the rfkill handler.
+	 * Register the extra components.
 	 */
-	status = rt2x00rfkill_register(rt2x00dev);
-	if (status)
-		goto exit_unitialize;
+	rt2x00rfkill_register(rt2x00dev);
 
 	return 0;
 
@@ -1313,15 +1311,9 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	}
 
 	/*
-	 * Allocatie rfkill.
-	 */
-	retval = rt2x00rfkill_allocate(rt2x00dev);
-	if (retval)
-		goto exit;
-
-	/*
-	 * Open the debugfs entry.
+	 * Register extra components.
 	 */
+	rt2x00rfkill_allocate(rt2x00dev);
 	rt2x00debug_register(rt2x00dev);
 
 	__set_bit(DEVICE_PRESENT, &rt2x00dev->flags);
@@ -1350,13 +1342,9 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00dev)
 	rt2x00lib_uninitialize(rt2x00dev);
 
 	/*
-	 * Close debugfs entry.
+	 * Free extra components
 	 */
 	rt2x00debug_deregister(rt2x00dev);
-
-	/*
-	 * Free rfkill
-	 */
 	rt2x00rfkill_free(rt2x00dev);
 
 	/*
@@ -1395,11 +1383,15 @@ int rt2x00lib_suspend(struct rt2x00_dev *rt2x00dev, pm_message_t state)
 	__set_bit(DEVICE_STARTED_SUSPEND, &rt2x00dev->flags);
 
 	/*
-	 * Disable radio and unitialize all items
-	 * that must be recreated on resume.
+	 * Disable radio.
 	 */
 	rt2x00lib_stop(rt2x00dev);
 	rt2x00lib_uninitialize(rt2x00dev);
+
+	/*
+	 * Suspend/disable extra components.
+	 */
+	rt2x00rfkill_suspend(rt2x00dev);
 	rt2x00debug_deregister(rt2x00dev);
 
 exit:
@@ -1422,9 +1414,10 @@ int rt2x00lib_resume(struct rt2x00_dev *rt2x00dev)
 	NOTICE(rt2x00dev, "Waking up.\n");
 
 	/*
-	 * Open the debugfs entry.
+	 * Restore/enable extra components.
 	 */
 	rt2x00debug_register(rt2x00dev);
+	rt2x00rfkill_resume(rt2x00dev);
 
 	/*
 	 * Only continue if mac80211 had open interfaces.
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index 1adbd28..ce58c65 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -100,28 +100,36 @@ static inline void rt2x00debug_dump_frame(struct rt2x00_dev *rt2x00dev,
  * RFkill handlers.
  */
 #ifdef CONFIG_RT2X00_LIB_RFKILL
-int rt2x00rfkill_register(struct rt2x00_dev *rt2x00dev);
+void rt2x00rfkill_register(struct rt2x00_dev *rt2x00dev);
 void rt2x00rfkill_unregister(struct rt2x00_dev *rt2x00dev);
-int rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev);
+void rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev);
 void rt2x00rfkill_free(struct rt2x00_dev *rt2x00dev);
+void rt2x00rfkill_suspend(struct rt2x00_dev *rt2x00dev);
+void rt2x00rfkill_resume(struct rt2x00_dev *rt2x00dev);
 #else
-static inline int rt2x00rfkill_register(struct rt2x00_dev *rt2x00dev)
+static inline void rt2x00rfkill_register(struct rt2x00_dev *rt2x00dev)
 {
-	return 0;
 }
 
 static inline void rt2x00rfkill_unregister(struct rt2x00_dev *rt2x00dev)
 {
 }
 
-static inline int rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
+static inline void rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
 {
-	return 0;
 }
 
 static inline void rt2x00rfkill_free(struct rt2x00_dev *rt2x00dev)
 {
 }
+
+static inline void rt2x00rfkill_suspend(struct rt2x00_dev *rt2x00dev)
+{
+}
+
+static inline void rt2x00rfkill_resume(struct rt2x00_dev *rt2x00dev)
+{
+}
 #endif /* CONFIG_RT2X00_LIB_RFKILL */
 
 #endif /* RT2X00LIB_H */
diff --git a/drivers/net/wireless/rt2x00/rt2x00rfkill.c b/drivers/net/wireless/rt2x00/rt2x00rfkill.c
index 34a96d4..f955775 100644
--- a/drivers/net/wireless/rt2x00/rt2x00rfkill.c
+++ b/drivers/net/wireless/rt2x00/rt2x00rfkill.c
@@ -69,56 +69,81 @@ static void rt2x00rfkill_poll(struct input_polled_dev *poll_dev)
 	}
 }
 
-int rt2x00rfkill_register(struct rt2x00_dev *rt2x00dev)
+void rt2x00rfkill_register(struct rt2x00_dev *rt2x00dev)
 {
-	int retval;
-
-	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags))
-		return 0;
+	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags) ||
+	    !test_bit(RFKILL_STATE_ALLOCATED, &rt2x00dev->rfkill_state))
+		return;
 
-	retval = rfkill_register(rt2x00dev->rfkill);
-	if (retval) {
+	if (rfkill_register(rt2x00dev->rfkill)) {
 		ERROR(rt2x00dev, "Failed to register rfkill handler.\n");
-		return retval;
+		return;
 	}
 
-	retval = input_register_polled_device(rt2x00dev->poll_dev);
-	if (retval) {
+	if (input_register_polled_device(rt2x00dev->poll_dev)) {
 		ERROR(rt2x00dev, "Failed to register polled device.\n");
 		rfkill_unregister(rt2x00dev->rfkill);
-		return retval;
+		return;
 	}
 
+	__set_bit(RFKILL_STATE_REGISTERED, &rt2x00dev->rfkill_state);
+
 	/*
 	 * Force initial poll which will detect the initial device state,
 	 * and correctly sends the signal to the rfkill layer about this
 	 * state.
 	 */
 	rt2x00rfkill_poll(rt2x00dev->poll_dev);
-
-	return 0;
 }
 
 void rt2x00rfkill_unregister(struct rt2x00_dev *rt2x00dev)
 {
-	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags))
+	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags) ||
+	    !test_bit(RFKILL_STATE_REGISTERED, &rt2x00dev->rfkill_state))
 		return;
 
 	input_unregister_polled_device(rt2x00dev->poll_dev);
 	rfkill_unregister(rt2x00dev->rfkill);
+
+	__clear_bit(RFKILL_STATE_REGISTERED, &rt2x00dev->rfkill_state);
 }
 
-int rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
+static struct input_polled_dev *
+rt2x00rfkill_allocate_polldev(struct rt2x00_dev *rt2x00dev)
 {
-	struct device *device = wiphy_dev(rt2x00dev->hw->wiphy);
+	struct input_polled_dev *poll_dev;
+
+	poll_dev = input_allocate_polled_device();
+	if (!poll_dev)
+		return NULL;
+
+	poll_dev->private = rt2x00dev;
+	poll_dev->poll = rt2x00rfkill_poll;
+	poll_dev->poll_interval = RFKILL_POLL_INTERVAL;
+
+	poll_dev->input->name = rt2x00dev->ops->name;
+	poll_dev->input->phys = wiphy_name(rt2x00dev->hw->wiphy);
+	poll_dev->input->id.bustype = BUS_HOST;
+	poll_dev->input->id.vendor = 0x1814;
+	poll_dev->input->id.product = rt2x00dev->chip.rt;
+	poll_dev->input->id.version = rt2x00dev->chip.rev;
+	poll_dev->input->dev.parent = wiphy_dev(rt2x00dev->hw->wiphy);
+	poll_dev->input->evbit[0] = BIT(EV_KEY);
+	set_bit(KEY_WLAN, poll_dev->input->keybit);
+
+	return poll_dev;
+}
 
+void rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
+{
 	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags))
-		return 0;
+		return;
 
-	rt2x00dev->rfkill = rfkill_allocate(device, RFKILL_TYPE_WLAN);
+	rt2x00dev->rfkill =
+	    rfkill_allocate(wiphy_dev(rt2x00dev->hw->wiphy), RFKILL_TYPE_WLAN);
 	if (!rt2x00dev->rfkill) {
 		ERROR(rt2x00dev, "Failed to allocate rfkill handler.\n");
-		goto exit;
+		return;
 	}
 
 	rt2x00dev->rfkill->name = rt2x00dev->ops->name;
@@ -126,40 +151,49 @@ int rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
 	rt2x00dev->rfkill->state = -1;
 	rt2x00dev->rfkill->toggle_radio = rt2x00rfkill_toggle_radio;
 
-	rt2x00dev->poll_dev = input_allocate_polled_device();
+	rt2x00dev->poll_dev = rt2x00rfkill_allocate_polldev(rt2x00dev);
 	if (!rt2x00dev->poll_dev) {
 		ERROR(rt2x00dev, "Failed to allocate polled device.\n");
-		goto exit_free_rfkill;
+		rfkill_free(rt2x00dev->rfkill);
+		rt2x00dev->rfkill = NULL;
+		return;
 	}
 
-	rt2x00dev->poll_dev->private = rt2x00dev;
-	rt2x00dev->poll_dev->poll = rt2x00rfkill_poll;
-	rt2x00dev->poll_dev->poll_interval = RFKILL_POLL_INTERVAL;
+	return;
+}
 
-	rt2x00dev->poll_dev->input->name = rt2x00dev->ops->name;
-	rt2x00dev->poll_dev->input->phys = wiphy_name(rt2x00dev->hw->wiphy);
-	rt2x00dev->poll_dev->input->id.bustype = BUS_HOST;
-	rt2x00dev->poll_dev->input->id.vendor = 0x1814;
-	rt2x00dev->poll_dev->input->id.product = rt2x00dev->chip.rt;
-	rt2x00dev->poll_dev->input->id.version = rt2x00dev->chip.rev;
-	rt2x00dev->poll_dev->input->dev.parent = device;
-	rt2x00dev->poll_dev->input->evbit[0] = BIT(EV_KEY);
-	set_bit(KEY_WLAN, rt2x00dev->poll_dev->input->keybit);
+void rt2x00rfkill_free(struct rt2x00_dev *rt2x00dev)
+{
+	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags) ||
+	    !test_bit(RFKILL_STATE_ALLOCATED, &rt2x00dev->rfkill_state))
+		return;
 
-	return 0;
+	input_free_polled_device(rt2x00dev->poll_dev);
+	rt2x00dev->poll_dev = NULL;
 
-exit_free_rfkill:
 	rfkill_free(rt2x00dev->rfkill);
-
-exit:
-	return -ENOMEM;
+	rt2x00dev->rfkill = NULL;
 }
 
-void rt2x00rfkill_free(struct rt2x00_dev *rt2x00dev)
+void rt2x00rfkill_suspend(struct rt2x00_dev *rt2x00dev)
 {
-	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags))
+	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags) ||
+	    !test_bit(RFKILL_STATE_ALLOCATED, &rt2x00dev->rfkill_state))
 		return;
 
 	input_free_polled_device(rt2x00dev->poll_dev);
-	rfkill_free(rt2x00dev->rfkill);
+	rt2x00dev->poll_dev = NULL;
+}
+
+void rt2x00rfkill_resume(struct rt2x00_dev *rt2x00dev)
+{
+	if (!test_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags) ||
+	    !test_bit(RFKILL_STATE_ALLOCATED, &rt2x00dev->rfkill_state))
+		return;
+
+	rt2x00dev->poll_dev = rt2x00rfkill_allocate_polldev(rt2x00dev);
+	if (!rt2x00dev->poll_dev) {
+		ERROR(rt2x00dev, "Failed to allocate polled device.\n");
+		return;
+	}
 }
-- 
John W. Linville
linville@tuxdriver.com
