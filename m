From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: cleanups
Date: Sat, 12 Aug 2006 18:00:17 +0100 (BST)
Message-ID: <20060812170017.278D08E7782@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:57956 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932574AbWHLRAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 13:00:14 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Add static to 2 internal functions. Thanks goes to Adrian Bunk, who found that.

Also made some modifications to the clear functions:

After a discussion on the mailing list, I implemented this code to
have on the one hand sufficient test in debug mode, but on the
other hand reduce the overhead for structure clearing to a
minimum.

A new macro ZD_MEMCLEAR is introduced, which produces code if
DEBUG is set. Locks are not set anymore for structure clearing,
but in debug mode, there is a verification, that the locks have
not been set.

Finally, removed a misleading comment regarding locking in the disconnect
path.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -664,7 +664,7 @@ resubmit:
 	usb_submit_urb(urb, GFP_ATOMIC);
 }
 
-struct urb *alloc_urb(struct zd_usb *usb)
+static struct urb *alloc_urb(struct zd_usb *usb)
 {
 	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	struct urb *urb;
@@ -688,7 +688,7 @@ struct urb *alloc_urb(struct zd_usb *usb
 	return urb;
 }
 
-void free_urb(struct urb *urb)
+static void free_urb(struct urb *urb)
 {
 	if (!urb)
 		return;
@@ -908,7 +908,7 @@ void zd_usb_clear(struct zd_usb *usb)
 {
 	usb_set_intfdata(usb->intf, NULL);
 	usb_put_intf(usb->intf);
-	memset(usb, 0, sizeof(*usb));
+	ZD_MEMCLEAR(usb, sizeof(*usb));
 	/* FIXME: usb_interrupt, usb_tx, usb_rx? */
 }
 
@@ -1098,7 +1098,6 @@ static void disconnect(struct usb_interf
 	 */
 	usb_reset_device(interface_to_usbdev(intf));
 
-	/* If somebody still waits on this lock now, this is an error. */
 	zd_netdev_free(netdev);
 	dev_dbg(&intf->dev, "disconnected\n");
 }
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -42,12 +42,11 @@ void zd_chip_init(struct zd_chip *chip,
 
 void zd_chip_clear(struct zd_chip *chip)
 {
-	mutex_lock(&chip->mutex);
+	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	zd_usb_clear(&chip->usb);
 	zd_rf_clear(&chip->rf);
-	mutex_unlock(&chip->mutex);
 	mutex_destroy(&chip->mutex);
-	memset(chip, 0, sizeof(*chip));
+	ZD_MEMCLEAR(chip, sizeof(*chip));
 }
 
 static int scnprint_mac_oui(const u8 *addr, char *buffer, size_t size)
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_def.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_def.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_def.h
@@ -45,4 +45,10 @@ do { \
 #  define ZD_ASSERT(x) do { } while (0)
 #endif
 
+#ifdef DEBUG
+#  define ZD_MEMCLEAR(pointer, size) memset((pointer), 0xff, (size))
+#else
+#  define ZD_MEMCLEAR(pointer, size) do { } while (0)
+#endif
+
 #endif /* _ZD_DEF_H */
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -127,11 +127,9 @@ out:
 
 void zd_mac_clear(struct zd_mac *mac)
 {
-	/* Aquire the lock. */
-	spin_lock(&mac->lock);
-	spin_unlock(&mac->lock);
 	zd_chip_clear(&mac->chip);
-	memset(mac, 0, sizeof(*mac));
+	ZD_ASSERT(!spin_is_locked(&mac->lock));
+	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
 }
 
 static int reset_mode(struct zd_mac *mac)
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -121,9 +121,9 @@ enum mac_flags {
 };
 
 struct zd_mac {
-	struct net_device *netdev;
 	struct zd_chip chip;
 	spinlock_t lock;
+	struct net_device *netdev;
 	/* Unlocked reading possible */
 	struct iw_statistics iw_stats;
 	u8 qual_average;
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_rf.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_rf.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -56,7 +56,7 @@ void zd_rf_init(struct zd_rf *rf)
 
 void zd_rf_clear(struct zd_rf *rf)
 {
-	memset(rf, 0, sizeof(*rf));
+	ZD_MEMCLEAR(rf, sizeof(*rf));
 }
 
 int zd_rf_init_hw(struct zd_rf *rf, u8 type)

