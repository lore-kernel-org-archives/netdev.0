From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Fri, 30 Mar 2007 01:29:09 -0400
Message-ID: <200703300129.10751.dtor@insightbb.com>
References: <200612031936.34343.IvDoorn@gmail.com> <200701311220.51971.IvDoorn@gmail.com> <200703300127.40849.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933307AbXC3F3P@vger.kernel.org>
In-Reply-To: <200703300127.40849.dtor@insightbb.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Input: polled device skeleton

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---
 drivers/input/misc/Kconfig         |   11 ++
 drivers/input/misc/Makefile        |    1 
 drivers/input/misc/input-polldev.c |  149 +++++++++++++++++++++++++++++++++++++
 include/linux/input-polldev.h      |   46 +++++++++++
 4 files changed, 207 insertions(+)

Index: linux/drivers/input/misc/Kconfig
===================================================================
--- linux.orig/drivers/input/misc/Kconfig
+++ linux/drivers/input/misc/Kconfig
@@ -81,6 +81,17 @@ config INPUT_UINPUT
 	  To compile this driver as a module, choose M here: the
 	  module will be called uinput.
 
+config INPUT_POLLDEV
+	tristate "Polled input device skeleton"
+	help
+	  Say Y here if you are using a driver for an input
+	  device that periodically polls hardware state. This
+	  option is only useful for out-of-tree drivers since
+	  in-tree drivers select it automatically.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called input-polldev.
+
 config HP_SDC_RTC
 	tristate "HP SDC Real Time Clock"       
 	depends on GSC || HP300
Index: linux/drivers/input/misc/Makefile
===================================================================
--- linux.orig/drivers/input/misc/Makefile
+++ linux/drivers/input/misc/Makefile
@@ -4,6 +4,7 @@
 
 # Each configuration option enables a list of files.
 
+obj-$(CONFIG_INPUT_POLLDEV)		+= input-polldev.o
 obj-$(CONFIG_INPUT_SPARCSPKR)		+= sparcspkr.o
 obj-$(CONFIG_INPUT_PCSPKR)		+= pcspkr.o
 obj-$(CONFIG_INPUT_M68K_BEEP)		+= m68kspkr.o
Index: linux/drivers/input/misc/input-polldev.c
===================================================================
--- /dev/null
+++ linux/drivers/input/misc/input-polldev.c
@@ -0,0 +1,149 @@
+/*
+ * Generic implementation of a polled input device
+
+ * Copyright (c) 2007 Dmitry Torokhov
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/jiffies.h>
+#include <linux/input-polldev.h>
+
+static DEFINE_MUTEX(polldev_mutex);
+static int polldev_users;
+static struct workqueue_struct *polldev_wq;
+
+static void input_polled_device_work(struct work_struct *work)
+{
+	struct input_polled_dev *dev =
+		container_of(work, struct input_polled_dev, work.work);
+
+	dev->poll(dev);
+	queue_delayed_work(polldev_wq, &dev->work,
+			   msecs_to_jiffies(dev->poll_interval));
+}
+
+static int input_open_polled_device(struct input_dev *input)
+{
+	struct input_polled_dev *dev = input->private;
+	int retval;
+
+	retval = mutex_lock_interruptible(&polldev_mutex);
+	if (retval)
+		return retval;
+
+	if (!polldev_users++) {
+		polldev_wq = create_singlethread_workqueue("ipolldevd");
+		if (!polldev_wq) {
+			printk(KERN_ERR "input-polldev: failed to create "
+				"ipolldevd workqueue\n");
+			goto out;
+		}
+	}
+
+	if (dev->flush)
+		dev->flush(dev);
+	queue_delayed_work(polldev_wq, &dev->work,
+			   msecs_to_jiffies(dev->poll_interval));
+
+ out:
+	mutex_unlock(&polldev_mutex);
+	return retval;
+}
+
+static void input_close_polled_device(struct input_dev *input)
+{
+	struct input_polled_dev *dev = input->private;
+
+	cancel_rearming_delayed_workqueue(polldev_wq, &dev->work);
+
+	mutex_lock(&polldev_mutex);
+	if (!--polldev_users)
+		destroy_workqueue(polldev_wq);
+	mutex_unlock(&polldev_mutex);
+}
+
+/**
+ * input_allocate_polled_device - allocated memory polled device
+ *
+ * The function allocates memory for a polled device and also
+ * for an input device associated with this polled device.
+ */
+struct input_polled_dev *input_allocate_polled_device(void)
+{
+	struct input_polled_dev *dev;
+
+	dev = kzalloc(sizeof(struct input_polled_dev), GFP_KERNEL);
+	if (!dev)
+		return NULL;
+
+	dev->input = input_allocate_device();
+	if (!dev->input) {
+		kfree(dev);
+		return NULL;
+	}
+
+	return dev;
+}
+EXPORT_SYMBOL(input_allocate_polled_device);
+
+/**
+ * input_free_polled_device - free memory allocated for polled device
+ * @dev: device to free
+ *
+ * The function frees memory allocated for pollign device and drops
+ * reference to the associated input device (if present).
+ */
+void input_free_polled_device(struct input_polled_dev *dev)
+{
+	if (dev) {
+		input_free_device(dev->input);
+		kfree(dev);
+	}
+}
+EXPORT_SYMBOL(input_free_polled_device);
+
+/**
+ * input_register_polled_device - register polled device
+ * @dev: device to register
+ *
+ * The function registers previously initialized polled input device
+ * with input layer. The device should be allocated with call to
+ * input_allocate_polled_device(). Callers should also set up poll()
+ * method and set up capabilities (id, name, phys, bits) of the
+ * corresponing input_dev structure.
+ */
+int input_register_polled_device(struct input_polled_dev *dev)
+{
+	struct input_dev *input = dev->input;
+
+	INIT_DELAYED_WORK(&dev->work, input_polled_device_work);
+	if (!dev->poll_interval)
+		dev->poll_interval = 500;
+	input->private = dev;
+	input->open = input_open_polled_device;
+	input->close = input_close_polled_device;
+
+	return input_register_device(input);
+}
+EXPORT_SYMBOL(input_register_polled_device);
+
+/**
+ * input_unregister_polled_device - unregister polled device
+ * @dev: device to unregister
+ *
+ * The function unregisters previously registered polled input
+ * device from input layer. Polling is stopped and device is
+ * ready to be freed with call to input_free_polled_device().
+ * Callers should not attempt to access dev->input pointer
+ * after calling this function.
+ */
+void input_unregister_polled_device(struct input_polled_dev *dev)
+{
+	input_unregister_device(dev->input);
+	dev->input = NULL;
+}
+EXPORT_SYMBOL(input_unregister_polled_device);
+
Index: linux/include/linux/input-polldev.h
===================================================================
--- /dev/null
+++ linux/include/linux/input-polldev.h
@@ -0,0 +1,46 @@
+#ifndef _INPUT_POLLDEV_H
+#define _INPUT_POLLDEV_H
+
+/*
+ * Copyright (c) 2007 Dmitry Torokhov
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/input.h>
+#include <linux/workqueue.h>
+
+/**
+ * struct input_polled_dev - simple polled input device
+ * @private: private driver data
+ * @flush: driver-supplied method that flushes device's state upon
+ *	opening (optional)
+ * @poll: driver-supplied method that polls the device and posts
+ *	input events (mandatory).
+ * @poll_interval: specifies how often the poll() method shoudl be called.
+ * @input: input device structire associated with the polled device.
+ *	Must be properly initialized by the driver (id, name, phys, bits).
+ *
+ * Polled input device provides a skeleton for supporting simple input
+ * devices that do not raise interrupts but have to be periodically
+ * scanned to detect changes in their state.
+ */
+struct input_polled_dev {
+	void *private;
+
+	void (*flush)(struct input_polled_dev *dev);
+	void (*poll)(struct input_polled_dev *dev);
+	unsigned int poll_interval; /* msec */
+
+	struct input_dev *input;
+	struct delayed_work work;
+};
+
+struct input_polled_dev *input_allocate_polled_device(void);
+void input_free_polled_device(struct input_polled_dev *dev);
+int input_register_polled_device(struct input_polled_dev *dev);
+void input_unregister_polled_device(struct input_polled_dev *dev);
+
+#endif
