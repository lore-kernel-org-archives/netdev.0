From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Mon, 29 May 2006 17:58:03 +0200
Message-ID: <200605291758.07930.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart15324764.HhOezulzXW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:43630 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751111AbWE2PzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 May 2006 11:55:25 -0400
Received: by nf-out-0910.google.com with SMTP id m18so172650nfc
        for <netdev@vger.kernel.org>; Mon, 29 May 2006 08:55:24 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200605251716.00742.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart15324764.HhOezulzXW
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I made a small update on this patch, only a small compile fix
and small bugfix.

The thing I would like to know now, is if the current approach
is the desired situation.

=2D Should only 1 input device be created, or multiple devices?

=2D Should instead of KEY_RADIO new keys be created (KEY_RADIO_WIFI
and KEY_RADIO_BLUETOOTH for example) or should instead input_event
be used and instead of "1", other values be passed to indicate the device w=
hich
has triggered the event?

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff --git a/drivers/input/misc/Kconfig b/drivers/input/misc/Kconfig
index 4bad588..212caad 100644
=2D-- a/drivers/input/misc/Kconfig
+++ b/drivers/input/misc/Kconfig
@@ -79,4 +79,14 @@ config HP_SDC_RTC
 	  Say Y here if you want to support the built-in real time clock
 	  of the HP SDC controller.
=20
+config RADIOBTN
+	tristate "Hardware radio button support"
+	help
+	  Say Y here if you have an integrated WiFi or Bluetooth device
+	  which contains an hardware button for enabling or disabling the radio.
+	  When this driver is used, this driver will make sure the radio will
+	  be correctly enabled and disabled when needed. It will then also
+	  use the created input device to signal user space of this event
+	  which allows userspace to take additional actions.
+
 endif
diff --git a/drivers/input/misc/Makefile b/drivers/input/misc/Makefile
index 415c491..9af3d98 100644
=2D-- a/drivers/input/misc/Makefile
+++ b/drivers/input/misc/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_INPUT_UINPUT)		+=3D uinput.o
 obj-$(CONFIG_INPUT_WISTRON_BTNS)	+=3D wistron_btns.o
 obj-$(CONFIG_HP_SDC_RTC)		+=3D hp_sdc_rtc.o
 obj-$(CONFIG_INPUT_IXP4XX_BEEPER)	+=3D ixp4xx-beeper.o
+obj-$(CONFIG_RADIOBTN)			+=3D radiobtn.o
\ No newline at end of file
diff --git a/drivers/input/misc/radiobtn.c b/drivers/input/misc/radiobtn.c
new file mode 100644
index 0000000..8d3b84a
=2D-- /dev/null
+++ b/drivers/input/misc/radiobtn.c
@@ -0,0 +1,163 @@
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
+	Radio hardware button support
+	Poll frequently all registered hardware for hardware button status,
+	if changed enabled or disable the radio of that hardware device.
+	Send signal to input device to inform userspace about the new status.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/input.h>
+#include <linux/radiobtn.h>
+
+MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("Radio hardware button support");
+MODULE_LICENSE("GPL");
+
+void radiobtn_poll(unsigned long data)
+{
+	struct radio_button *radiobtn =3D (struct radio_button*)data;
+	int state;
+
+	/*
+	 * Poll for the new state.
+	 * Check if the state has changed.
+	 */
+	state =3D !!radiobtn->button_poll(radiobtn->data);
+	if (state !=3D radiobtn->current_state) {
+		radiobtn->current_state =3D state;
+
+		/*
+		 * Enable or disable the radio when this
+		 * should be done in software.
+		 */
+		if (state && radiobtn->enable_radio)
+			radiobtn->enable_radio(radiobtn->data);
+		else if (!state && radiobtn->disable_radio)
+			radiobtn->disable_radio(radiobtn->data);
+
+		/*
+		 * Report key event.
+		 */
+		input_report_key(radiobtn->input_dev, KEY_RADIO, 1);
+		input_sync(radiobtn->input_dev);
+		input_report_key(radiobtn->input_dev, KEY_RADIO, 0);
+		input_sync(radiobtn->input_dev);
+	}
+
+	/*
+	 * Check if polling has been disabled.
+	 */
+	if (radiobtn->poll_delay !=3D 0) {
+		radiobtn->poll_timer.expires =3D
+			jiffies + msecs_to_jiffies(radiobtn->poll_delay);
+		add_timer(&radiobtn->poll_timer);
+	}
+}
+
+int radiobtn_register_device(struct radio_button *radiobtn)
+{
+	int status;
+
+	/*
+	 * Check if all mandatory fields have been set.
+	 */
+	if (radiobtn->poll_delay =3D=3D 0 || radiobtn->button_poll =3D=3D NULL)
+		return -EINVAL;
+
+	/*
+	 * Allocate, initialize and register input device.
+	 */
+	radiobtn->input_dev =3D input_allocate_device();
+	if (!radiobtn->input_dev) {
+		printk(KERN_ERR "Failed to allocate input device %s.\n",
+			radiobtn->dev_name);
+		return -ENOMEM;
+	}
+
+	radiobtn->input_dev->name =3D "Radio button";
+	radiobtn->input_dev->phys =3D strcat("radiobtn/", radiobtn->dev_name);
+	radiobtn->input_dev->id.bustype =3D BUS_HOST;
+	set_bit(KEY_RADIO, radiobtn->input_dev->keybit);
+
+	status =3D input_register_device(radiobtn->input_dev);
+	if (status) {
+		printk(KERN_ERR "Failed to register input device %s.\n",
+			radiobtn->dev_name);
+		input_free_device(radiobtn->input_dev);
+		return status;
+	}
+
+	/*
+	 * Set the initial state of the button.
+	 */
+	radiobtn->current_state =3D radiobtn->button_poll(radiobtn->data);
+
+	/*
+	 * Initialize timer.
+	 */
+	init_timer(&radiobtn->poll_timer);
+	radiobtn->poll_timer.function =3D radiobtn_poll;
+	radiobtn->poll_timer.data =3D (unsigned long)radiobtn;
+	radiobtn->poll_timer.expires =3D
+		jiffies + msecs_to_jiffies(radiobtn->poll_delay);
+	add_timer(&radiobtn->poll_timer);
+
+	printk(KERN_INFO "Created new %s: %s.\n",
+		radiobtn->input_dev->name, radiobtn->input_dev->phys);
+
+	return 0;
+}
+
+void radiobtn_unregister_device(struct radio_button *radiobtn)
+{
+	/*
+	 * Stop timer.
+	 */
+	radiobtn->poll_delay =3D 0;
+	del_timer_sync(&radiobtn->poll_timer);
+
+	/*
+	 * Remove input device.
+	 */
+	input_unregister_device(radiobtn->input_dev);
+	input_free_device(radiobtn->input_dev);
+}
+
+static int __init radiobtn_init(void)
+{
+	printk(KERN_INFO "Loading radio button driver.\n");
+	return 0;
+}
+
+static void __exit radiobtn_exit(void)
+{
+	printk(KERN_INFO "Unloading radio button driver.\n");
+}
+
+EXPORT_SYMBOL(radiobtn_register_device);
+EXPORT_SYMBOL(radiobtn_unregister_device);
+
+module_init(radiobtn_init);
+module_exit(radiobtn_exit);
diff --git a/include/linux/radiobtn.h b/include/linux/radiobtn.h
new file mode 100644
index 0000000..3467606
=2D-- /dev/null
+++ b/include/linux/radiobtn.h
@@ -0,0 +1,84 @@
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
+	Radio hardware button support
+	Laptops are quite often equiped with support with a hardware button
+	to enabled and disable the radio of the integrated wireless network
+	or bluetooth interface.
+	Altough some devices will make sure that when pressed the radio
+	is disabled in hardware, other device depend on the software
+	to enabled or disable the radio accordingly.
+	This driver will create an input device and will poll registered
+	hardware frequently to listen if the button has been pressed.
+	When the device requires the software to disable or enable
+	the radio it will do so correctly, but it will also in all cases
+	send a signal to the input device to inform any listening daemon
+	the state has changed and will allow userspace to handle certain
+	tasks as well if required.
+ */
+
+#ifndef RADIOBTN_H
+#define RADIOBTN_H
+
+#include <linux/input.h>
+
+/**
+ * struct radio_button - radio hardware structure.
+ * @dev_name: Name of the interface. This will become the name
+ * 	of the input device created in /dev/radio/.
+ * @data: Private data which will be passed along with the radio handlers.
+ * @button_poll(unsigned long data): Handler which will be called
+ * 	with the poll_delay interval.
+ * @enable_radio(unsigned long data): Optional handler to enable the radio
+ * 	once the button has been pressed when the hardware does not do this
+ * 	automaticly.
+ * @disable_radio(unsigned long data): Optional handler to disable the rad=
io
+ * 	once the button has been pressed when the hardware does not do this
+ * 	automaticly.
+ * @poll_delay: Delay in msecs between each poll.
+ * @current_state: Current state of the button.
+ * 	(Should not be touched by driver)
+ * @input_dev: Pointer to input device for this radio button.
+ * 	(Should not be touched by driver)
+ * @poll_timer: Timer used to poll for the button status.
+ *	(Should not be touched by driver)
+ */
+struct radio_button {
+	const char *dev_name;
+
+	unsigned long data;
+
+	int (*button_poll)(unsigned long data);
+	void (*enable_radio)(unsigned long data);
+	void (*disable_radio)(unsigned long data);
+
+	unsigned int poll_delay;
+
+	unsigned int current_state;
+
+	struct input_dev *input_dev;
+
+	struct timer_list poll_timer;
+};
+
+int radiobtn_register_device(struct radio_button *);
+void radiobtn_unregister_device(struct radio_button *);
+
+#endif /* RADIOBTN_H */

--nextPart15324764.HhOezulzXW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEexoPaqndE37Em0gRAunHAJ4z7MRYDYZ6VpAV/EzDZVkFFRslMQCeMElw
tEohelreKukaqPmiAFPOLww=
=AnAp
-----END PGP SIGNATURE-----

--nextPart15324764.HhOezulzXW--
