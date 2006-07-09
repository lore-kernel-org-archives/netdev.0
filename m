From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: [PATCH RFC]rfkill - Hardware button support for Wireless cards
Date: Sun, 9 Jul 2006 17:49:15 +0200
Message-ID: <a32f33a40607090849h737287a0k9f4d95669aa0ce9c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, "Stefan Rompf" <stefan@loplof.de>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Vojtech Pavlik" <vojtech@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:57696 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932489AbWGIPtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 11:49:16 -0400
Received: by py-out-1112.google.com with SMTP id 57so684293pya
        for <netdev@vger.kernel.org>; Sun, 09 Jul 2006 08:49:15 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have been quite busy lately, hence the reason for this late continuance
of the Hardware button support for Wireless cards discussion.
I have CC'ed the people who discussed this in earlier threads.

With the suggestions made by Vojtech Pavlik I have created the rfkill driver,
for which I would like to know if this is the acceptable approach.

This rfkill driver looks a bit like the previous version I had send,
but this version does pay attention if the input device has been opened
and if an event should be send to userspace in that case.

I was however unsure about where the KEY_RFKILL should be added
in linux/input.h. I again placed this driver in drivers/input/misc but perhaps
this should go into drivers/net instead?

I hope I am on the right track. :)

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---
diff --git a/drivers/input/misc/Kconfig b/drivers/input/misc/Kconfig
index 4bad588..837021a 100644
--- a/drivers/input/misc/Kconfig
+++ b/drivers/input/misc/Kconfig
@@ -79,4 +79,19 @@ config HP_SDC_RTC
 	  Say Y here if you want to support the built-in real time clock
 	  of the HP SDC controller.

+config RFKILL
+	tristate "RF button support"
+	help
+	  If you say yes here, the rfkill driver will be build
+	  which allowed network devices to register their hardware
+	  RF button which controls the radio state. This driver
+	  will then create an input device for it.
+
+	  When the input device is not used, the rfkill driver
+	  will make sure that when the RF button is pressed the radio
+	  is enabled or disabled accordingly. When the input device
+	  has been opened by the user this radio control will be left
+	  to the user, and rfkill will only send the RF button status
+	  change to userspace.
+
 endif
diff --git a/drivers/input/misc/Makefile b/drivers/input/misc/Makefile
index 415c491..e788a1b 100644
--- a/drivers/input/misc/Makefile
+++ b/drivers/input/misc/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_INPUT_UINPUT)		+= uinput.o
 obj-$(CONFIG_INPUT_WISTRON_BTNS)	+= wistron_btns.o
 obj-$(CONFIG_HP_SDC_RTC)		+= hp_sdc_rtc.o
 obj-$(CONFIG_INPUT_IXP4XX_BEEPER)	+= ixp4xx-beeper.o
+obj-$(CONFIG_RFKILL)			+= rfkill.o
diff --git a/drivers/input/misc/rfkill.c b/drivers/input/misc/rfkill.c
new file mode 100644
index 0000000..da576e5
--- /dev/null
+++ b/drivers/input/misc/rfkill.c
@@ -0,0 +1,209 @@
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
+#include <linux/timer.h>
+#include <linux/rfkill.h>
+
+#include <asm/atomic.h>
+
+MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("RF button support");
+MODULE_LICENSE("GPL");
+
+/*
+ * List of all registered buttons.
+ */
+static struct list_head rfkill_list;
+static spinlock_t rfkill_list_lock;
+
+/*
+ * Polling timer, poll_delay and use count.
+ */
+static struct timer_list poll_timer;
+static atomic_t poll_required;
+
+static void rfkill_toggle_radio(int new_status)
+{
+	struct list_head *entry;
+	struct rfkill *rfkill;
+
+	/*
+	 * Go through the list of all radio's to toggle the radio state.
+	 */
+	list_for_each(entry, &rfkill_list) {
+		rfkill =  list_entry(entry, struct rfkill, entry);
+
+		rfkill->current_status = new_status;
+
+		/*
+		* If the input_device has been opened
+		* all radio events should be send to user space.
+		*/
+		if (rfkill->input_dev->users) {
+			input_report_key(rfkill->input_dev,
+				KEY_RFKILL, new_status);
+			input_sync(rfkill->input_dev);
+		}
+	
+		/*
+		* If the hardware does not toggle the radio status automaticly,
+		* we should take care of it.
+		*/
+		if (new_status && rfkill->enable_radio)
+			rfkill->enable_radio(rfkill->data);
+		else if (!new_status && rfkill->disable_radio)
+			rfkill->disable_radio(rfkill->data);
+	}
+}
+
+static void rfkill_poll_button(unsigned long data)
+{
+	struct list_head *entry;
+	struct rfkill *rfkill;
+	int status;
+
+	spin_lock(&rfkill_list_lock);
+
+	list_for_each(entry, &rfkill_list) {
+		rfkill =  list_entry(entry, struct rfkill, entry);
+
+		if (!rfkill->poll)
+			continue;
+
+		status = !!rfkill->poll(rfkill->data);
+
+		if (status != rfkill->current_status) {
+			rfkill_toggle_radio(status);
+			break;
+		}
+	}
+
+	spin_unlock(&rfkill_list_lock);
+
+	/*
+	 * Check if polling is still required.
+	 */
+	if (atomic_read(&poll_required)) {
+		poll_timer.expires = jiffies + RFKILL_POLL_DELAY;
+		add_timer(&poll_timer);
+	}
+}
+
+void rfkill_button_event(struct rfkill *rfkill, int status)
+{
+	if (status != rfkill->current_status) {
+		spin_lock(&rfkill_list_lock);
+		rfkill_toggle_radio(status);
+		spin_unlock(&rfkill_list_lock);
+	}
+}
+EXPORT_SYMBOL(rfkill_button_event);
+
+int rfkill_add_device(struct rfkill *rfkill)
+{
+	int status;
+
+	/*
+	 * Allocate, initialize and register input device.
+	 */
+	rfkill->input_dev = input_allocate_device();
+	if (!rfkill->input_dev) {
+		printk(KERN_ERR "Failed to allocate input device %s.\n",
+			rfkill->dev_name);
+		return -ENOMEM;
+	}
+
+	rfkill->input_dev->name = "Radio button";
+	rfkill->input_dev->phys = rfkill->dev_name;
+	rfkill->input_dev->id.bustype = BUS_HOST;
+	set_bit(KEY_RFKILL, rfkill->input_dev->keybit);
+
+	status = input_register_device(rfkill->input_dev);
+	if (status) {
+		printk(KERN_ERR "Failed to register input device %s.\n",
+			rfkill->dev_name);
+		input_free_device(rfkill->input_dev);
+		return status;
+	}
+
+	INIT_LIST_HEAD(&rfkill->entry);
+
+	spin_lock(&rfkill_list_lock);
+	list_add(&rfkill->entry, &rfkill_list);
+	spin_unlock(&rfkill_list_lock);
+
+	/*
+	 * If polling is required the poll_required counter should be
+	 * increased. If it was previously 0 we should start the polling timer.
+	 */
+	if (rfkill->poll) {
+		if (!atomic_read(&poll_required)) {
+			poll_timer.expires = jiffies + RFKILL_POLL_DELAY;
+			add_timer(&poll_timer);
+		}
+		atomic_inc(&poll_required);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(rfkill_add_device);
+
+void rfkill_del_device(struct rfkill *rfkill)
+{
+	spin_lock(&rfkill_list_lock);
+
+	/*
+	 * Check if this button required polling and if this
+	 * was the last button that required polling.
+	 */
+	if (rfkill->poll && atomic_dec_and_test(&poll_required))
+		del_timer(&poll_timer);
+
+	list_del(&rfkill->entry);
+
+	spin_unlock(&rfkill_list_lock);
+}
+EXPORT_SYMBOL(rfkill_del_device);
+
+static int __init radiobtn_init(void)
+{
+	printk(KERN_INFO "Loading rfkill driver.\n");
+
+	INIT_LIST_HEAD(&rfkill_list);
+	spin_lock_init(&rfkill_list_lock);
+
+	init_timer(&poll_timer);
+	poll_timer.function = rfkill_poll_button;
+	poll_timer.data = 0;
+	atomic_set(&poll_required, 0);
+
+	return 0;
+}
+
+static void __exit radiobtn_exit(void)
+{
+	printk(KERN_INFO "Unloading rfkill driver.\n");
+}
+
+module_init(radiobtn_init);
+module_exit(radiobtn_exit);
diff --git a/include/linux/input.h b/include/linux/input.h
index ce1a756..d460620 100644
--- a/include/linux/input.h
+++ b/include/linux/input.h
@@ -486,6 +486,7 @@ #define KEY_PREVIOUS		0x19c
 #define KEY_DIGITS		0x19d
 #define KEY_TEEN		0x19e
 #define KEY_TWEN		0x19f
+#define KEY_RFKILL		0x1a0

 #define KEY_DEL_EOL		0x1c0
 #define KEY_DEL_EOS		0x1c1
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
new file mode 100644
index 0000000..2e1c740
--- /dev/null
+++ b/include/linux/rfkill.h
@@ -0,0 +1,98 @@
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
+	RF button support
+	Laptops are quite often equiped with a RF button to enable or
+	disable the radio of the network device attached to that button.
+	This network device usually is an integrated wireless network device,
+	or bluetooth device.
+	Some of these devices will disable the radio automaticly when the
+	RF button has been pressed, while other devices need to be polled
+	for the RF button status.
+	But in all cases the only interface that will have its radio disabled
+	will be the device that has the RF button attached to it. But it could
+	be desired that userspace performs this disabling of all radios in case
+	there are also interfaces without a RF button that need to be disabled.
+
+	The rfkill driver will contain a list of all devices with a RF button,
+	hardware drivers need to register their hardware to teh rfkill
+	interface it can take care of everything. If the RF button requires
+	polling to obtain the status this will be handled by rfkill as well.
+	Once the status of the button has changed and the hardware does not
+	automaticly enable or disable the radio rfkill provides with the
+	interface to do this correctly.
+
+	For each registered hardware button an input device will be created.
+	If this input device has been opened by the user, rfkill will send a
+	signal to userspace instead of the hardware about the new button
+	status. This will allow userpace to perform the correct steps
+	in order to bring down all interfaces.
+ */
+
+#ifndef RFKILL_H
+#define RFKILL_H
+
+#include <linux/list.h>
+#include <linux/input.h>
+
+#define RFKILL_POLL_DELAY	( HZ / 10 ) /* 100 ms */
+
+/**
+ * struct rfkill - rfkill button control structure.
+ * @dev_name: Name of the interface. This will become the name
+ * 	of the input device which will be created for this button.
+ * @data: Private data which will be passed along with the radio and polling
+ * 	handlers.
+ * @poll(unsigned long data): Optional handler which will frequently be
+ * 	called to determine the current status of the RF button.
+ * @enable_radio(unsigned long data): Optional handler to enable the radio
+ * 	once the RF button has been pressed and the hardware does enable
+ * 	the radio automaticly.
+ * @disable_radio(unsigned long data): Optional handler to disable the radio
+ * 	once the RF button has been pressed and the hardware does disable
+ * 	the radio automaticly.
+ * @current_status: Contains the current status of the radio as it was
+ * 	previously indicated by the radio. This field may only be changed
+ * 	by the driver at initialization time.
+ */
+struct rfkill {
+	const char *dev_name;
+
+	unsigned long data;
+
+	int (*poll)(unsigned long data);
+	void (*enable_radio)(unsigned long data);
+	void (*disable_radio)(unsigned long data);
+
+	unsigned int current_status;
+
+	/*
+	 * These fields are private to rfkill, and
+	 * should not be used by the RF button driver.
+	 */
+	struct list_head entry;
+	struct input_dev *input_dev;
+};
+
+void rfkill_button_event(struct rfkill *rfkill, int status);
+int rfkill_add_device(struct rfkill *rfkill);
+void rfkill_del_device(struct rfkill *rfkill);
+
+#endif /* RFKILL_H */
