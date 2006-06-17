From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Sat, 17 Jun 2006 17:05:55 +0200
Message-ID: <200606171705.59498.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <200606041002.33696.IvDoorn@gmail.com> <200606041214.45999.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1166125.fGln2aiExR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:925 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751630AbWFQPCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 11:02:10 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1037028nfa
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2006 08:02:08 -0700 (PDT)
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200606041214.45999.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1166125.fGln2aiExR
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> > Except for the bluetooth radio key (which should be supported by the
> > radiobtn interface as well) the other buttons have support through alre=
ady
> > excisting input devices if I am correct.
>=20
> You are wrong for quite a bunch of laptop models. That's why I pointed yo=
u to=20
> the wistron_btns driver. Alternatively, look at the acerhk driver=20
> (http://www2.informatik.hu-berlin.de/~tauber/acerhk/). Many systems have =
a=20
> number of additional buttons that need to be handled by a special driver,=
 all=20
> sent to userspace, and just one of them to trigger the wireless card. Oth=
er=20
> models just handle the button in ACPI and generate an additional ACPI eve=
nt.
>=20
> Looking at the RT2400-driver, I see what you want to accomplish: Take the=
 view=20
> of the WLAN card on the hardware controlled button enable/disable and=20
> generate events on it. However, in many cases it is another driver (see=20
> above) that sets or clears this state, and this should be the instance to=
=20
> send the input event.
>=20
> Note that I do not have objections against the driver being included in t=
he=20
> kernel - it just does not qualify as generic radiobutton support, but I k=
now=20
> it's hard to find a good name ;-)
>=20
> Looking at the code only: There should be an additional non-polling inter=
face=20
> for drivers that can generate events on the own.

Sorry for the late reply, but I have been quite busy with other things late=
ly.
I have created an updated patch, that is more generic than the previous.
I have also renamed it to "laptopkey".

With this approach more buttons can be registered,
it includes the optional field to report an update of the key status
to the driver that registered it, and it supports for non-polling keys.

By default all events will go over the default input device, but a driver
can choose to create additional input devices.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

=2D--

diff --git a/drivers/input/misc/Kconfig b/drivers/input/misc/Kconfig
index 4bad588..097ae8c 100644
=2D-- a/drivers/input/misc/Kconfig
+++ b/drivers/input/misc/Kconfig
@@ -79,4 +79,12 @@ config HP_SDC_RTC
 	  Say Y here if you want to support the built-in real time clock
 	  of the HP SDC controller.
=20
+config LAPTOPKEY
+	tristate "Laptop keys support"
+	help
+	 Say Y here if you have laptop with additional keys like hardware
+	 wireless or bluetooth radio control, or other (programmable) keys.
+	 This driver will create an input device to which other hardware
+	 drivers can register their keys to.
+
 endif
diff --git a/drivers/input/misc/Makefile b/drivers/input/misc/Makefile
index 415c491..e691fab 100644
=2D-- a/drivers/input/misc/Makefile
+++ b/drivers/input/misc/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_INPUT_UINPUT)		+=3D uinput.o
 obj-$(CONFIG_INPUT_WISTRON_BTNS)	+=3D wistron_btns.o
 obj-$(CONFIG_HP_SDC_RTC)		+=3D hp_sdc_rtc.o
 obj-$(CONFIG_INPUT_IXP4XX_BEEPER)	+=3D ixp4xx-beeper.o
+obj-$(CONFIG_LAPTOPKEY)			+=3D laptopkey.o
diff --git a/drivers/input/misc/laptopkey.c b/drivers/input/misc/laptopkey.c
new file mode 100644
index 0000000..7731554
=2D-- /dev/null
+++ b/drivers/input/misc/laptopkey.c
@@ -0,0 +1,231 @@
+/*
+	Copyright (C) 2006 Ivo van Doorn
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/laptopkey.h>
+
+MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("Laptop keys support");
+MODULE_LICENSE("GPL");
+
+/*
+ * Default laptop_key_device structure.
+ */
+static struct laptop_key_device default_keydev =3D {
+	.dev_name	=3D "laptopbtn",
+	.delay		=3D 100,
+};
+
+void laptopkey_key_event(struct laptop_key *key, int status)
+{
+	/*
+	 * Check if the hardware needs to be informed of
+	 * the status change.
+	 */
+	if (key->key_event)
+		key->key_event(key->data, status);
+
+	/*
+	 * Send input event to userspace.
+	 */
+	input_report_key(key->keydev->input_dev, key->key, status);
+	input_sync(key->keydev->input_dev);
+
+}
+
+static void laptopkey_poll(unsigned long data)
+{
+	struct laptop_key_device *keydev =3D (struct laptop_key_device *)data;
+	struct laptop_key *key;
+	struct list_head *entry;
+	int status;
+
+	list_for_each(entry, &keydev->list){
+		key =3D list_entry(entry, struct laptop_key, entry);
+
+		/*
+		 * Check if this key requires polling.
+		 * Otherwise just skip this key,
+		 * and move to the next one.
+		 */
+		if (!key->key_poll)
+			continue;
+
+		/*
+		 * Poll the status, and report a key event
+		 * when the status has changed.
+		 */
+		status =3D !!key->key_poll(key->data);
+		if (status !=3D key->current_status) {
+			laptopkey_key_event(key, status);
+			key->current_status =3D status;
+		}
+	}
+
+	/*
+	 * Check if the polling can continue.
+	 */
+	if (keydev->delay =3D=3D 0)
+		return;
+
+	mod_timer(&keydev->timer, jiffies + msecs_to_jiffies(keydev->delay));
+}
+
+void laptopkey_dev_add_key(struct laptop_key_device *keydev,
+			  struct laptop_key *key)
+{
+	/*
+	 * If polling is enabled, obtain the initial
+	 * status from the polling functions, otherwise
+	 * set it to 0.
+	 */
+	if (key->key_poll)
+		key->current_status =3D key->key_poll(key->data);
+	else
+		key->current_status =3D 0;
+
+	/*
+	 * Add key to key device.
+	 */
+	key->keydev =3D keydev;
+	list_add(&key->entry, &keydev->list);
+
+	/*
+	 * Add key to the input device.
+	 */
+	set_bit(key->key, keydev->input_dev->keybit);
+}
+
+void laptopkey_dev_del_key(struct laptop_key_device *keydev,
+			   struct laptop_key *key)
+{
+	/*
+	 * Remove list from device.
+	 */
+	list_del(&key->entry);
+
+	/*
+	 * Remove key to the input device.
+	 */
+	clear_bit(key->key, keydev->input_dev->keybit);
+}
+
+void laptopkey_add_key(struct laptop_key *key)
+{
+	laptopkey_dev_add_key(&default_keydev, key);
+}
+
+void laptopkey_del_key(struct laptop_key *key)
+{
+	laptopkey_dev_del_key(&default_keydev, key);
+}
+
+int laptopkey_register_device(struct laptop_key_device *keydev)
+{
+	int status;
+
+	/*
+	 * Create the input device
+	 */
+	keydev->input_dev =3D input_allocate_device();
+	if (!keydev->input_dev) {
+		printk(KERN_ERR "Failed to allocate input device %s.\n",
+			keydev->dev_name);
+		return -ENOMEM;
+	}
+
+	/*
+	 * Initialize the input device
+	 */
+	keydev->input_dev->name =3D "Laptop keys";
+	keydev->input_dev->phys =3D keydev->dev_name;
+	keydev->input_dev->id.bustype =3D BUS_HOST;
+
+	/*
+	 * Register the input device
+	 */
+	status =3D input_register_device(keydev->input_dev);
+	if (status) {
+		printk(KERN_ERR "Failed to register input device %s.\n",
+			keydev->dev_name);
+		input_free_device(keydev->input_dev);
+		return status;
+	}
+
+	/*
+	 * Initialize list head.
+	 */
+	INIT_LIST_HEAD(&keydev->list);
+
+	/*
+	 * Initialize timer.
+	 */
+	init_timer(&keydev->timer);
+	keydev->timer.function =3D laptopkey_poll;
+	keydev->timer.data =3D (unsigned long)keydev;
+	keydev->timer.expires =3D jiffies + msecs_to_jiffies(keydev->delay);
+	add_timer(&keydev->timer);
+
+	printk(KERN_INFO "Created new %s: %s.\n",
+		keydev->input_dev->name, keydev->input_dev->phys);
+
+	return 0;
+}
+
+void laptopkey_unregister_device(struct laptop_key_device *keydev)
+{
+	/*
+	 * Clear the delay field before deleting the timer,
+	 * to prevent the scheduled work to rearm itself.
+	 */
+	keydev->delay =3D 0;
+	del_timer_sync(&keydev->timer);
+
+	/*
+	 * Remove input device.
+	 */
+	input_unregister_device(keydev->input_dev);
+	input_free_device(keydev->input_dev);
+}
+
+static int __init radiobtn_init(void)
+{
+	printk(KERN_INFO "Loading radio button driver.\n");
+	return laptopkey_register_device(&default_keydev);
+}
+
+static void __exit radiobtn_exit(void)
+{
+	laptopkey_unregister_device(&default_keydev);
+	printk(KERN_INFO "Unloading radio button driver.\n");
+}
+
+EXPORT_SYMBOL(laptopkey_add_key);
+EXPORT_SYMBOL(laptopkey_del_key);
+EXPORT_SYMBOL(laptopkey_register_device);
+EXPORT_SYMBOL(laptopkey_unregister_device);
+EXPORT_SYMBOL(laptopkey_dev_add_key);
+EXPORT_SYMBOL(laptopkey_dev_del_key);
+EXPORT_SYMBOL(laptopkey_key_event);
+
+module_init(radiobtn_init);
+module_exit(radiobtn_exit);
diff --git a/include/linux/laptopkey.h b/include/linux/laptopkey.h
new file mode 100644
index 0000000..063ecf5
=2D-- /dev/null
+++ b/include/linux/laptopkey.h
@@ -0,0 +1,131 @@
+/*
+	Copyright (C) 2006 Ivo van Doorn
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Laptop keys support
+
+	INTRODUCTION
+	Laptops are quite often equiped with additional hardware keys.
+	This includes the radio keys for wireless and bluetooth devices,
+	but also other (programmable) keys.
+	This driver will create a generic layer between hardware and
+	userspace. Drivers can add keys to the input device for
+	frequent polling and reporting the status to userspace.
+
+	INPUT DEVICES
+	When loading this driver the main input device is directly created.
+	When desired drivers can also register a new laptop_key_device
+	which creates a new input device to which the laptop keys can be
+	registered.
+
+	POLLING
+	In the laptop_key_device structure the delay is set, this delay
+	is used to determine the polling interval in which each key will be
+	polled for its status. When the key_poll field is not set, the
+	key will not be polled.
+
+	STATUS REPORTING
+	When the status has changed, an input event will be send to userspace.
+	The key field will be used as reported key in that input event.
+	When the status of the key has changed, this event will also be send to
+	the driver that registered the key when the key_event field has been
+	set. It is also possible for keys to skip the polling and inform
+	this driver of the event directly.
+ */
+
+#ifndef LAPTOPKEY_H
+#define LAPTOPKEY_H
+
+#include <linux/input.h>
+#include <linux/list.h>
+
+/**
+ * struct laptop_key_device - laptop key device structure
+ * @dev_name: Name of the input device.
+ * @delay: When polling is required for any of the keys,
+ *	this polling delay (in ms) will be used.
+ * @list: All laptop keys are part of a linked list.
+ *	This field should not be touched by any driver.
+ * @input_dev: This is the input device created for this laptop_key_device.
+ *	This field should not be touched by any driver.
+ * @timer: The timer structure for the frequent polling of the keys.
+ *	This field should not be touched by any driver.
+ */
+struct laptop_key_device {
+	const char *dev_name;
+
+	unsigned int delay;
+
+	struct list_head list;
+
+	struct input_dev *input_dev;
+
+	struct timer_list timer;
+};
+
+/**
+ * struct laptop_key - laptop key structure
+ * @key: Key type that is send to userspace.
+ *	should be any of the KEY_* defines from <linux/input.h>
+ * @data: private data that is send as argument with the
+ *	functions key_poll and key_event.
+ * @current_status: Current status of the button is stored here.
+ * @key_poll: This function is used to determine the current state
+ *	of the key. This field only needs to be set when polling is required.
+ * @key_event: This function is used when the key status has changed, it w=
ill
+ *	then send the new key status as argument to inform the hardware
+ *	of the change. This field is only required when the hardware needs to
+ *	be informed of the change.
+ * @keydev: laptop_key_device structure this key is attached to.
+ *	This field should not be touched by any driver.
+ * @entry: All laptop keys are part of a linked list. This field should not
+ *	be touched by any driver.
+ */
+struct laptop_key {
+	unsigned int key;
+	unsigned long data;
+	int current_status;
+
+	int (*key_poll)(unsigned long data);
+	void (*key_event)(unsigned long data, int status);
+
+	struct laptop_key_device *keydev;
+	struct list_head entry;
+};
+
+/*
+ * Functions when using the main input device.
+ */
+void laptopkey_add_key(struct laptop_key *);
+void laptopkey_del_key(struct laptop_key *);
+
+/*
+ * Functions when using a seperate input device.
+ */
+int laptopkey_register_device(struct laptop_key_device *);
+void laptopkey_unregister_device(struct laptop_key_device *);
+void laptopkey_dev_add_key(struct laptop_key_device *, struct laptop_key *=
);
+void laptopkey_dev_del_key(struct laptop_key_device *, struct laptop_key *=
);
+
+/*
+ * Manually report a key event.
+ */
+void laptopkey_key_event(struct laptop_key *, int status);
+
+#endif /* LAPTOPKEY_H */

--nextPart1166125.fGln2aiExR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBElBpXaqndE37Em0gRAscOAKCl+UuHgp99yoNo+avRxJ3DlvUUlACgrhTn
ZZDpu+hNPa0CbuyxWQxJD4k=
=5NLw
-----END PGP SIGNATURE-----

--nextPart1166125.fGln2aiExR--
