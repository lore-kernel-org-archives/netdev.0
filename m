From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-06-04
Date: Wed, 4 Jun 2008 16:55:14 -0400
Message-ID: <20080604205514.GB32186@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

NOTE: This accounts for the net-2.6 rebase and drops the controversial
wireless.h patch...

Dave,

A smattering of fixes for 2.6.26...nothing major...

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 7dccf1f4e1696c79bff064c3770867cc53cbc71c:
  Jarek Poplawski (1):
        ax25: Fix NULL pointer dereference and lockup.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrew Morton (1):
      airo warning fix

Dan Williams (1):
      ipw2200: expire and use oldest BSS on adhoc create

Felix Homann (1):
      USB ID for Philips CPWUA054/00 Wireless USB Adapter 11g

Holger Schurig (1):
      libertas: fix command size for CMD_802_11_SUBSCRIBE_EVENT

Michael Buesch (2):
      b43legacy: Fix controller restart crash
      ssb: Fix context assertion in ssb_pcicore_dev_irqvecs_enable

 drivers/net/wireless/airo.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c   |   17 +++++++++--------
 drivers/net/wireless/ipw2200.c          |   27 +++++++++++++++++++++++++--
 drivers/net/wireless/libertas/debugfs.c |    4 ++--
 drivers/net/wireless/p54/p54usb.c       |    1 +
 drivers/ssb/driver_pcicore.c            |    4 ++--
 6 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 4e1c690..32019fb 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2905,7 +2905,7 @@ EXPORT_SYMBOL(init_airo_card);
 
 static int waitbusy (struct airo_info *ai) {
 	int delay = 0;
-	while ((IN4500 (ai, COMMAND) & COMMAND_BUSY) && (delay < 10000)) {
+	while ((IN4500(ai, COMMAND) & COMMAND_BUSY) && (delay < 10000)) {
 		udelay (10);
 		if ((++delay % 20) == 0)
 			OUT4500(ai, EVACK, EV_CLEARCOMMANDBUSY);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 14a5eea..204077c 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3039,7 +3039,6 @@ static void b43legacy_set_pretbtt(struct b43legacy_wldev *dev)
 /* Locking: wl->mutex */
 static void b43legacy_wireless_core_exit(struct b43legacy_wldev *dev)
 {
-	struct b43legacy_wl *wl = dev->wl;
 	struct b43legacy_phy *phy = &dev->phy;
 	u32 macctl;
 
@@ -3054,12 +3053,6 @@ static void b43legacy_wireless_core_exit(struct b43legacy_wldev *dev)
 	macctl |= B43legacy_MACCTL_PSM_JMP0;
 	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
 
-	mutex_unlock(&wl->mutex);
-	/* Must unlock as it would otherwise deadlock. No races here.
-	 * Cancel possibly pending workqueues. */
-	cancel_work_sync(&dev->restart_work);
-	mutex_lock(&wl->mutex);
-
 	b43legacy_leds_exit(dev);
 	b43legacy_rng_exit(dev->wl);
 	b43legacy_pio_free(dev);
@@ -3486,6 +3479,8 @@ static void b43legacy_chip_reset(struct work_struct *work)
 		}
 	}
 out:
+	if (err)
+		wl->current_dev = NULL; /* Failed to init the dev. */
 	mutex_unlock(&wl->mutex);
 	if (err)
 		b43legacyerr(wl, "Controller restart FAILED\n");
@@ -3618,9 +3613,11 @@ static void b43legacy_one_core_detach(struct ssb_device *dev)
 	struct b43legacy_wldev *wldev;
 	struct b43legacy_wl *wl;
 
+	/* Do not cancel ieee80211-workqueue based work here.
+	 * See comment in b43legacy_remove(). */
+
 	wldev = ssb_get_drvdata(dev);
 	wl = wldev->wl;
-	cancel_work_sync(&wldev->restart_work);
 	b43legacy_debugfs_remove_device(wldev);
 	b43legacy_wireless_core_detach(wldev);
 	list_del(&wldev->list);
@@ -3789,6 +3786,10 @@ static void b43legacy_remove(struct ssb_device *dev)
 	struct b43legacy_wl *wl = ssb_get_devtypedata(dev);
 	struct b43legacy_wldev *wldev = ssb_get_drvdata(dev);
 
+	/* We must cancel any work here before unregistering from ieee80211,
+	 * as the ieee80211 unreg will destroy the workqueue. */
+	cancel_work_sync(&wldev->restart_work);
+
 	B43legacy_WARN_ON(!wl);
 	if (wl->current_dev == wldev)
 		ieee80211_unregister_hw(wl->hw);
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index d74c061..7293367 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -7558,8 +7558,31 @@ static int ipw_associate(void *data)
 	    priv->ieee->iw_mode == IW_MODE_ADHOC &&
 	    priv->config & CFG_ADHOC_CREATE &&
 	    priv->config & CFG_STATIC_ESSID &&
-	    priv->config & CFG_STATIC_CHANNEL &&
-	    !list_empty(&priv->ieee->network_free_list)) {
+	    priv->config & CFG_STATIC_CHANNEL) {
+		/* Use oldest network if the free list is empty */
+		if (list_empty(&priv->ieee->network_free_list)) {
+			struct ieee80211_network *oldest = NULL;
+			struct ieee80211_network *target;
+			DECLARE_MAC_BUF(mac);
+
+			list_for_each_entry(target, &priv->ieee->network_list, list) {
+				if ((oldest == NULL) ||
+				    (target->last_scanned < oldest->last_scanned))
+					oldest = target;
+			}
+
+			/* If there are no more slots, expire the oldest */
+			list_del(&oldest->list);
+			target = oldest;
+			IPW_DEBUG_ASSOC("Expired '%s' (%s) from "
+					"network list.\n",
+					escape_essid(target->ssid,
+						     target->ssid_len),
+					print_mac(mac, target->bssid));
+			list_add_tail(&target->list,
+				      &priv->ieee->network_free_list);
+		}
+
 		element = priv->ieee->network_free_list.next;
 		network = list_entry(element, struct ieee80211_network, list);
 		ipw_adhoc_create(priv, network);
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index ad2fabc..0aa0ce3 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -312,8 +312,8 @@ static ssize_t lbs_threshold_write(uint16_t tlv_type, uint16_t event_mask,
 	if (tlv_type != TLV_TYPE_BCNMISS)
 		tlv->freq = freq;
 
-	/* The command header, the event mask, and the one TLV */
-	events->hdr.size = cpu_to_le16(sizeof(events->hdr) + 2 + sizeof(*tlv));
+	/* The command header, the action, the event mask, and one TLV */
+	events->hdr.size = cpu_to_le16(sizeof(events->hdr) + 4 + sizeof(*tlv));
 
 	ret = lbs_cmd_with_response(priv, CMD_802_11_SUBSCRIBE_EVENT, events);
 
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 98ddbb3..1610a73 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -49,6 +49,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x5041, 0x2235)},	/* Linksys WUSB54G Portable */
 
 	/* Version 2 devices (3887) */
+	{USB_DEVICE(0x0471, 0x1230)},   /* Philips CPWUA054/00 */
 	{USB_DEVICE(0x050d, 0x7050)},	/* Belkin F5D7050 ver 1000 */
 	{USB_DEVICE(0x0572, 0x2000)},	/* Cohiba Proto board */
 	{USB_DEVICE(0x0572, 0x2002)},	/* Cohiba Proto board */
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 75def13..d28c538 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -537,12 +537,12 @@ int ssb_pcicore_dev_irqvecs_enable(struct ssb_pcicore *pc,
 	int err = 0;
 	u32 tmp;
 
-	might_sleep();
