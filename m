From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] zd1211rw-d80211: Use LED class
Date: Mon, 11 Dec 2006 00:44:08 -0500
Message-ID: <200612110044.12205.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart12147486.8ybN2lWFc8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:64162 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762518AbWLKFo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 00:44:57 -0500
To: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart12147486.8ybN2lWFc8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

This makes zd1211rw-d80211 register an LED class to control the link LED
instead of trying to determine when the LED should be on based on the
current bssid. No default trigger is set since d80211 doesn't currently
have a link on/off LED trigger.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--
 drivers/net/wireless/d80211/zd1211rw/zd_chip.c |    2 +-
 drivers/net/wireless/d80211/zd1211rw/zd_chip.h |    2 +-
 drivers/net/wireless/d80211/zd1211rw/zd_mac.c  |   90=20
++++++++++--------------
 drivers/net/wireless/d80211/zd1211rw/zd_mac.h  |   23 +++++--
 drivers/net/wireless/d80211/zd1211rw/zd_usb.c  |   19 +++---
 drivers/net/wireless/d80211/zd1211rw/zd_usb.h  |    2 -
 6 files changed, 65 insertions(+), 73 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_chip.c=20
b/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
index daec7b6..97ff136 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
@@ -1321,7 +1321,7 @@ int zd_chip_control_leds(struct zd_chip
 	other_led =3D chip->link_led =3D=3D LED1 ? LED2 : LED1;
=20
 	switch (status) {
=2D	case LED_OFF:
+	case LED_DISABLED:
 		ioreqs[0].value =3D FW_LINK_OFF;
 		ioreqs[1].value =3D v[1] & ~(LED1|LED2);
 		break;
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_chip.h=20
b/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
index b9c225d..970b920 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
@@ -821,7 +821,7 @@ int zd_chip_lock_phy_regs(struct zd_chip
 int zd_chip_unlock_phy_regs(struct zd_chip *chip);
=20
 enum led_status {
=2D	LED_OFF =3D 0,
+	LED_DISABLED =3D 0, /* linux/leds.h took LED_OFF.. */
 	LED_SCANNING =3D 1,
 	LED_ASSOCIATED =3D 2,
 };
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c=20
b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
index 6ee650f..1c76e62 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
@@ -29,10 +29,6 @@
 #include "zd_rf.h"
 #include "zd_util.h"
=20
=2Dstatic void housekeeping_init(struct zd_mac *mac);
=2Dstatic void housekeeping_enable(struct zd_mac *mac);
=2Dstatic void housekeeping_disable(struct zd_mac *mac);
=2D
 int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type)
 {
 	int r;
@@ -137,7 +133,9 @@ static int zd_mac_open(struct ieee80211_
 	if (r < 0)
 		goto disable_rx;
=20
=2D	housekeeping_enable(mac);
+#ifdef CONFIG_LEDS_CLASS
+	led_classdev_resume(&mac->link_led);
+#endif
 	return 0;
 disable_rx:
 	zd_chip_disable_rx(chip);
@@ -161,8 +159,10 @@ static int zd_mac_stop(struct ieee80211_
 	 * frames to be processed by softmac after we have stopped it.
 	 */
=20
+#ifdef CONFIG_LEDS_CLASS
+	led_classdev_suspend(&mac->link_led);
+#endif
 	zd_chip_disable_rx(chip);
=2D	housekeeping_disable(mac);
=20
 	zd_chip_disable_hwint(chip);
 	zd_chip_switch_radio_off(chip);
@@ -552,10 +552,6 @@ static int zd_mac_config(struct ieee8021
 static int zd_mac_config_interface(struct ieee80211_hw *dev, int if_id,
 				   struct ieee80211_if_conf *conf)
 {
=2D	struct zd_mac *mac =3D zd_dev_mac(dev);
=2D
=2D	mac->associated =3D is_valid_ether_addr(conf->bssid);
=2D
 	/* TODO: do hardware bssid filtering */
 	return 0;
 }
@@ -570,6 +566,37 @@ static struct ieee80211_ops zd_ops =3D {
 	.config_interface	=3D zd_mac_config_interface,
 };
=20
+#ifdef CONFIG_LEDS_CLASS
+static void set_link_led(struct led_classdev *led_cdev,
+			 enum led_brightness brightness)
+{
+	struct zd_mac *mac =3D container_of(led_cdev, struct zd_mac, link_led);
+	int r;
+
+	r =3D zd_chip_control_leds(&mac->chip,
+		                 brightness ? LED_ASSOCIATED : LED_DISABLED);
+	if (r)
+		dev_err(zd_mac_dev(mac), "zd_chip_control_leds error %d\n", r);
+}
+
+int zd_mac_register_led(struct ieee80211_hw *dev)
+{
+	struct zd_mac *mac =3D zd_dev_mac(dev);
+	snprintf(mac->link_led_name, sizeof(mac->link_led_name),
+	         "wiphy%dlink", dev->index);
+	mac->link_led.name =3D mac->link_led_name;
+	mac->link_led.brightness_set =3D set_link_led;
+	mac->link_led.flags =3D LED_SUSPENDED;
+	return led_classdev_register(dev->dev, &mac->link_led);
+}
+
+void zd_mac_unregister_led(struct ieee80211_hw *dev)
+{
+	struct zd_mac *mac =3D zd_dev_mac(dev);
+	led_classdev_unregister(&mac->link_led);
+}
+#endif
+
 struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf)
 {
 	struct zd_mac *mac;
@@ -616,51 +643,8 @@ struct ieee80211_hw *zd_mac_alloc(struct
=20
 	skb_queue_head_init(&mac->tx_queue);
 	zd_chip_init(&mac->chip, dev, intf);
=2D	housekeeping_init(mac);
=20
 	SET_MODULE_OWNER(dev);
 	dev->dev =3D &intf->dev;
 	return dev;
 }
=2D
=2D#define LINK_LED_WORK_DELAY HZ
=2D
=2Dstatic void link_led_handler(void *p)
=2D{
=2D	struct zd_mac *mac =3D p;
=2D	struct zd_chip *chip =3D &mac->chip;
=2D	int is_associated;
=2D	int r;
=2D
=2D	spin_lock_irq(&mac->lock);
=2D	is_associated =3D mac->associated;
=2D	spin_unlock_irq(&mac->lock);
=2D
=2D	r =3D zd_chip_control_leds(chip,
=2D		                 is_associated ? LED_ASSOCIATED : LED_SCANNING);
=2D	if (r)
=2D		dev_err(zd_mac_dev(mac), "zd_chip_control_leds error %d\n", r);
=2D
=2D	queue_delayed_work(zd_workqueue, &mac->housekeeping.link_led_work,
=2D		           LINK_LED_WORK_DELAY);
=2D}
=2D
=2Dstatic void housekeeping_init(struct zd_mac *mac)
=2D{
=2D	INIT_WORK(&mac->housekeeping.link_led_work, link_led_handler, mac);
=2D}
=2D
=2Dstatic void housekeeping_enable(struct zd_mac *mac)
=2D{
=2D	dev_dbg_f(zd_mac_dev(mac), "\n");
=2D	queue_delayed_work(zd_workqueue, &mac->housekeeping.link_led_work,
=2D			   0);
=2D}
=2D
=2Dstatic void housekeeping_disable(struct zd_mac *mac)
=2D{
=2D	dev_dbg_f(zd_mac_dev(mac), "\n");
=2D	cancel_rearming_delayed_workqueue(zd_workqueue,
=2D		&mac->housekeeping.link_led_work);
=2D	zd_chip_control_leds(&mac->chip, LED_OFF);
=2D}
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h=20
b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
index e2ba410..f5817aa 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
@@ -19,6 +19,7 @@
 #define _ZD_MAC_H
=20
 #include <linux/kernel.h>
+#include <linux/leds.h>
 #include <net/d80211.h>
=20
 #include "zd_chip.h"
@@ -118,22 +119,20 @@ enum mac_flags {
 	MAC_FIXED_CHANNEL =3D 0x01,
 };
=20
=2Dstruct housekeeping {
=2D	struct work_struct link_led_work;
=2D};
=2D
 #define ZD_MAC_STATS_BUFFER_SIZE 16
=20
 struct zd_mac {
 	struct zd_chip chip;
 	spinlock_t lock;
 	struct ieee80211_hw *dev;
=2D	struct housekeeping housekeeping;
+#ifdef CONFIG_LEDS_CLASS
+	char link_led_name[32];
+	struct led_classdev link_led;
+#endif
 	u8 regdomain;
 	u8 default_regdomain;
 	u8 requested_channel;
 	int mode;
=2D	int associated;
 	u8 *hwaddr;
 	struct sk_buff_head tx_queue;
 	struct ieee80211_channel channels[14];
@@ -159,6 +158,18 @@ static inline struct zd_mac *zd_usb_to_m
 #define zd_mac_dev(mac) (zd_chip_dev(&(mac)->chip))
=20
 struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf);
+#ifdef CONFIG_LEDS_CLASS
+int zd_mac_register_led(struct ieee80211_hw *dev);
+void zd_mac_unregister_led(struct ieee80211_hw *dev);
+#else
+static inline int zd_mac_register_led(struct ieee80211_hw *dev)
+{
+	return 0;
+}
+static inline void zd_mac_unregister_led(struct ieee80211_hw *dev)
+{
+}
+#endif
 void zd_mac_clear(struct zd_mac *mac);
=20
 int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type);
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c=20
b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
index bacb019..171fb93 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
@@ -24,7 +24,6 @@
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <linux/usb.h>
=2D#include <linux/workqueue.h>
 #include <net/d80211.h>
=20
 #include "zd_def.h"
@@ -1058,6 +1057,14 @@ static int probe(struct usb_interface *i
 		goto error;
 	}
=20
+	r =3D zd_mac_register_led(dev);
+	if (r) {
+		dev_dbg_f(&intf->dev,
+			 "couldn't register LED. Error number %d\n", r);
+		ieee80211_unregister_hw(dev);
+		goto error;
+	}
+
 	dev_dbg_f(&intf->dev, "successful\n");
 	dev_info(&intf->dev,"wiphy%d\n", dev->index);
 	return 0;
@@ -1083,6 +1090,7 @@ static void disconnect(struct usb_interf
=20
 	dev_dbg_f(zd_usb_dev(usb), "\n");
=20
+	zd_mac_unregister_led(dev);
 	ieee80211_unregister_hw(dev);
=20
 	/* Just in case something has gone wrong! */
@@ -1108,20 +1116,12 @@ static struct usb_driver driver =3D {
 	.disconnect	=3D disconnect,
 };
=20
=2Dstruct workqueue_struct *zd_workqueue;
=2D
 static int __init usb_init(void)
 {
 	int r;
=20
 	pr_debug("%s usb_init()\n", driver.name);
=20
=2D	zd_workqueue =3D create_singlethread_workqueue(driver.name);
=2D	if (zd_workqueue =3D=3D NULL) {
=2D		printk(KERN_ERR "%s couldn't create workqueue\n", driver.name);
=2D		return -ENOMEM;
=2D	}
=2D
 	r =3D usb_register(&driver);
 	if (r) {
 		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
@@ -1137,7 +1137,6 @@ static void __exit usb_exit(void)
 {
 	pr_debug("%s usb_exit()\n", driver.name);
 	usb_deregister(&driver);
=2D	destroy_workqueue(zd_workqueue);
 }
=20
 module_init(usb_init);
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.h=20
b/drivers/net/wireless/d80211/zd1211rw/zd_usb.h
index 1379e48..cda2259 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_usb.h
@@ -238,6 +238,4 @@ int zd_usb_iowrite16v(struct zd_usb *usb
=20
 int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
=20
=2Dextern struct workqueue_struct *zd_workqueue;
=2D
 #endif /* _ZD_USB_H */
=2D-=20
1.4.4.1


--nextPart12147486.8ybN2lWFc8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfPAsT3Oqt9AH4aERAtzWAJ9QwZ2v/9LxVKEwWR9snkw69vSjVACdGPZ1
3jFdGRr0Fj4ybyV66v3MoEQ=
=wgSb
-----END PGP SIGNATURE-----

--nextPart12147486.8ybN2lWFc8--
