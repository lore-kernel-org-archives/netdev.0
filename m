From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-07-27
Date: Wed, 27 Jul 2011 14:49:21 -0400
Message-ID: <20110727184920.GB16431@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a handful of fixes intended for 3.1.  This includes a
user-visible typo fix, a fix for a user after free in the new pn533
NFC driver, a cfg80211 fix for a possible NULL pointer dereference,
a fix for an invalid memory access in b43, and another b43 fix for
a memory corruption problem.

On top of that b43 memory corruption fix, there is a patch to remove
BROKEN from the B43_BCMA Kconfig entry, which is key to enabling
support for some of the more modern Broadcom wireless hardware.
I'm sure the Rafa=C5=82 (and a number of others) would love to see that
merged while the 3.1 merge window is still open as well.

Please let me know if there are problems...

Thanks!

John

---

The following changes since commit 41bf37117b47fc5ce2aae91f6a108e7e42e0=
b046:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/linville/wireless-next-2.6 into for-davem (2011-07-22 17:51:16 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Dan Carpenter (1):
      NFC: pn533: use after free in pn533_disconnect()

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Mihai Moldovan (1):
      wireless: fix a typo in ignore_reg_update

Pavel Roskin (1):
      b43: fix invalid memory access in b43_ssb_remove()

Rafa=C5=82 Mi=C5=82ecki (2):
      b43: bus: fix memory corruption when setting driver's data
      b43: bcma: drop BROKEN

Sven Neumann (1):
      cfg80211: really ignore the regulatory request

 drivers/net/wireless/b43/Kconfig |    2 +-
 drivers/net/wireless/b43/bus.c   |    2 ++
 drivers/net/wireless/b43/main.c  |    5 +++--
 drivers/nfc/pn533.c              |    2 +-
 net/wireless/reg.c               |    7 ++++---
 5 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b4=
3/Kconfig
index d2293dc..3cab843 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -28,7 +28,7 @@ config B43
=20
 config B43_BCMA
 	bool "Support for BCMA bus"
-	depends on B43 && BCMA && BROKEN
+	depends on B43 && BCMA
 	default y
=20
 config B43_SSB
diff --git a/drivers/net/wireless/b43/bus.c b/drivers/net/wireless/b43/=
bus.c
index 64c3f65..05f6c7b 100644
--- a/drivers/net/wireless/b43/bus.c
+++ b/drivers/net/wireless/b43/bus.c
@@ -244,10 +244,12 @@ void b43_bus_set_wldev(struct b43_bus_dev *dev, v=
oid *wldev)
 #ifdef CONFIG_B43_BCMA
 	case B43_BUS_BCMA:
 		bcma_set_drvdata(dev->bdev, wldev);
+		break;
 #endif
 #ifdef CONFIG_B43_SSB
 	case B43_BUS_SSB:
 		ssb_set_drvdata(dev->sdev, wldev);
+		break;
 #endif
 	}
 }
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 73fbf03..a92cde8 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5350,6 +5350,7 @@ static void b43_ssb_remove(struct ssb_device *sde=
v)
 {
 	struct b43_wl *wl =3D ssb_get_devtypedata(sdev);
 	struct b43_wldev *wldev =3D ssb_get_drvdata(sdev);
+	struct b43_bus_dev *dev =3D wldev->dev;
=20
 	/* We must cancel any work here before unregistering from ieee80211,
 	 * as the ieee80211 unreg will destroy the workqueue. */
@@ -5365,14 +5366,14 @@ static void b43_ssb_remove(struct ssb_device *s=
dev)
 		ieee80211_unregister_hw(wl->hw);
 	}
=20
-	b43_one_core_detach(wldev->dev);
+	b43_one_core_detach(dev);
=20
 	if (list_empty(&wl->devlist)) {
 		b43_leds_unregister(wl);
 		/* Last core on the chip unregistered.
 		 * We can destroy common struct b43_wl.
 		 */
-		b43_wireless_exit(wldev->dev, wl);
+		b43_wireless_exit(dev, wl);
 	}
 }
=20
diff --git a/drivers/nfc/pn533.c b/drivers/nfc/pn533.c
index 0372315..c77e054 100644
--- a/drivers/nfc/pn533.c
+++ b/drivers/nfc/pn533.c
@@ -1596,7 +1596,7 @@ static void pn533_disconnect(struct usb_interface=
 *interface)
 	usb_free_urb(dev->out_urb);
 	kfree(dev);
=20
-	nfc_dev_info(&dev->interface->dev, "NXP PN533 NFC device disconnected=
");
+	nfc_dev_info(&interface->dev, "NXP PN533 NFC device disconnected");
 }
=20
 static struct usb_driver pn533_driver =3D {
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 1ad0f39..02751db 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -903,7 +903,7 @@ static bool ignore_reg_update(struct wiphy *wiphy,
 	    initiator !=3D NL80211_REGDOM_SET_BY_COUNTRY_IE &&
 	    !is_world_regdom(last_request->alpha2)) {
 		REG_DBG_PRINT("Ignoring regulatory request %s "
-			      "since the driver requires its own regulaotry "
+			      "since the driver requires its own regulatory "
 			      "domain to be set first",
 			      reg_initiator_name(initiator));
 		return true;
@@ -1125,12 +1125,13 @@ void wiphy_update_regulatory(struct wiphy *wiph=
y,
 	enum ieee80211_band band;
=20
 	if (ignore_reg_update(wiphy, initiator))
-		goto out;
+		return;
+
 	for (band =3D 0; band < IEEE80211_NUM_BANDS; band++) {
 		if (wiphy->bands[band])
 			handle_band(wiphy, band, initiator);
 	}
-out:
+
 	reg_process_beacons(wiphy);
 	reg_process_ht_flags(wiphy);
 	if (wiphy->reg_notifier)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
