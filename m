From: Dmitry Torokhov <dtor@insightbb.com>
Subject: [RFC] RF Kill
Date: Tue, 10 Apr 2007 01:58:56 -0400
Message-ID: <200704100158.58451.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivdoorn@gmail.com, linville@tuxdriver.com,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:45742 "EHLO
	asav14.insightbb.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030360AbXDJF7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 01:59:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is a modified version of rfkill patch that provides infrastructure
for controlling state of RF transmitters found on various cards. It
works as follows:

Network card drivers that are able to control state of their RF
transmitters allocate and register rfkill structures. Every rfkill
structure belongs to one of RF classes (WLAN, Bluetooth or IRDA)
and exports its name, type, state and "user_claim" through sysfs.
Drivers implementing RF switches must supply toggle_radio() method
for controlling switch.  

There is also an input handler that catches KEY_WLAN and KEY_BLUETOOTH
events passing through input system and toggles state of all RF
switches of appropriate type registered with rfkill system (unless
a switch was claimed by userspace in which case it is left alone).
I think this provides basic functionality that most of the users need
and any advanced control will have to be done from userspace.

Creation of input devices that emit KEY_WLAN and KEY_BLUETOOTH is
outside of scope of rfkill infrastructure but input core will
provide a skeleton for easy implementation of simple polled buttons.

-- 
Dmitry


From: Ivo van Doorn <ivdoorn@gmail.com>

rfkill - Add support for input key to control wireless radio

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>
Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

 include/linux/rfkill.h    |   85 +++++++++
 net/Kconfig               |    1 
 net/Makefile              |    1 
 net/rfkill/Kconfig        |   24 ++
 net/rfkill/Makefile       |    6 
 net/rfkill/rfkill-input.c |  169 +++++++++++++++++++
 net/rfkill/rfkill.c       |  400 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 686 insertions(+)

Index: work/include/linux/rfkill.h
===================================================================
--- /dev/null
+++ work/include/linux/rfkill.h
@@ -0,0 +1,85 @@
+#ifndef __RFKILL_H
+#define __RFKILL_H
+
+/*
+ * Copyright (C) 2006 Ivo van Doorn
+ * Copyright (C) 2007 Dmitry Torokhov
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the
+ * Free Software Foundation, Inc.,
+ * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+#include <linux/device.h>
+
+/**
+ * enum rfkill_type - type of rfkill switch.
+ * RFKILL_TYPE_WLAN: switch is no a Wireless network devices.
+ * RFKILL_TYPE_BlUETOOTH: switch is on a bluetooth device.
+ * RFKILL_TYPE_IRDA: switch is on an infrared devices.
+ */
+enum rfkill_type {
+	RFKILL_TYPE_WLAN = 0,
+	RFKILL_TYPE_BLUETOOTH = 1,
+	RFKILL_TYPE_IRDA = 2,
+	RFKILL_TYPE_MAX = 3,
+};
+
+enum rfkill_state {
+	RFKILL_STATE_OFF	= 0,
+	RFKILL_STATE_ON		= 1,
+};
+
+/**
+ * struct rfkill - rfkill control structure.
+ * @name: Name of the switch.
+ * @type: Radio type which the button controls, the value stored
+ *	here should be a value from enum rfkill_type.
+ * @state: State of the switch (on/off).
+ * @user_claim: Set when the switch is controlled exlusively by userspace.
+ * @mutex: Guards switch state transitions
+ * @data: Pointer to the RF button drivers private data which will be
+ *	passed along when toggling radio state.
+ * @toggle_radio(): Mandatory handler to control state of the radio.
+ * @dev: Device structure integrating the switch into device tree.
+ * @node: Used to place switch into list of all switches known to the
+ *	the system.
+ *
+ * This structure represents a RF switch located on a network device.
+ */
+struct rfkill {
+	char *name;
+	enum rfkill_type type;
+
+	enum rfkill_state state;
+	bool user_claim;
+
+	struct mutex mutex;
+
+	void *data;
+	int (*toggle_radio)(void *data, enum rfkill_state state);
+
+	struct device dev;
+	struct list_head node;
+};
+#define to_rfkill(d)	container_of(d, struct rfkill, dev)
+
+struct rfkill *rfkill_allocate(struct device *parent, enum rfkill_type type);
+void rfkill_free(struct rfkill *rfkill);
+int rfkill_register(struct rfkill *rfkill);
+void rfkill_unregister(struct rfkill *rfkill);
+
+void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state);
+
+#endif /* RFKILL_H */
Index: work/net/Kconfig
===================================================================
--- work.orig/net/Kconfig
+++ work/net/Kconfig
@@ -220,6 +220,7 @@ source "net/ax25/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/ieee80211/Kconfig"
+source "net/rfkill/Kconfig"
 
 config WIRELESS_EXT
 	bool
Index: work/net/Makefile
===================================================================
--- work.orig/net/Makefile
+++ work/net/Makefile
@@ -48,6 +48,7 @@ obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
+obj-$(CONFIG_RFKILL)		+= rfkill/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
Index: work/net/rfkill/Kconfig
===================================================================
--- /dev/null
+++ work/net/rfkill/Kconfig
@@ -0,0 +1,24 @@
+#
+# RF switch subsystem configuration
+#
+menuconfig RFKILL
+	tristate "RF switch subsystem support"
+	help
+	  Say Y here if you want to have control over RF switches
+	  found on many WiFi, Bluetooth and IRDA cards.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called rfkill.
+
+config RFKILL_INPUT
+	tristate "Input layer to RF switch connector"
+	depends on RFKILL && INPUT
+	help
+	  Say Y here if you want kernel automatically toggle state
+	  of RF switches on and off when user presses appropriate
+	  button or a key on the keyboard. Without this module you
+	  need a some kind of userspace application to control
+	  state of the switches.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called rfkill-input.
Index: work/net/rfkill/Makefile
===================================================================
--- /dev/null
+++ work/net/rfkill/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the RF switch subsystem.
+#
+
+obj-$(CONFIG_RFKILL)			+= rfkill.o
+obj-$(CONFIG_RFKILL_INPUT)		+= rfkill-input.o
Index: work/net/rfkill/rfkill-input.c
===================================================================
--- /dev/null
+++ work/net/rfkill/rfkill-input.c
@@ -0,0 +1,169 @@
+/*
+ * Input layer to RF Kill interface connector
+ *
+ * Copyright (c) 2007 Dmitry Torokhov
+ */
+
+/*
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/input.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/rfkill.h>
+
+MODULE_AUTHOR("Dmitry Torokhov <dtor@mail.ru>");
+MODULE_DESCRIPTION("Input layer to RF switch connector");
+MODULE_LICENSE("GPL");
+
+struct rfkill_task {
+	struct work_struct work;
+	enum rfkill_type type;
+	struct mutex mutex; /* ensures that task is serialized */
+	spinlock_t lock; /* for accessing last and desired state */
+	unsigned long last; /* last schedule */
+	enum rfkill_state desired_state; /* on/off */
+	enum rfkill_state current_state; /* on/off */
+};
+
+static void rfkill_task_handler(struct work_struct *work)
+{
+	struct rfkill_task *task = container_of(work, struct rfkill_task, work);
+	enum rfkill_state state;
+
+	mutex_lock(&task->mutex);
+
+	spin_lock_irq(&task->lock);
+	state = task->desired_state;
+	spin_unlock_irq(&task->lock);
+
+	if (state != task->current_state) {
+		rfkill_switch_all(task->type, state);
+		task->current_state = state;
+	}
+
+	mutex_unlock(&task->mutex);
+}
+
+static void rfkill_schedule_toggle(struct rfkill_task *task)
+{
+	unsigned int flags;
+
+	spin_lock_irqsave(&task->lock, flags);
+
+	if (time_after(jiffies, task->last + msecs_to_jiffies(200))) {
+		task->desired_state = !task->desired_state;
+		task->last = jiffies;
+		schedule_work(&task->work);
+	}
+
+	spin_unlock_irqrestore(&task->lock, flags);
+}
+
+#define DECLARE_RFKILL_TASK(n, t)			\
+	struct rfkill_task n = {			\
+		.work = __WORK_INITIALIZER(n.work,	\
+				rfkill_task_handler),	\
+		.type = t,				\
+		.mutex = __MUTEX_INITIALIZER(n.mutex),	\
+		.lock = __SPIN_LOCK_UNLOCKED(n.lock),	\
+		.desired_state = RFKILL_STATE_ON,	\
+		.current_state = RFKILL_STATE_ON,	\
+	}
+
+static DECLARE_RFKILL_TASK(rfkill_wlan, RFKILL_TYPE_WLAN);
+static DECLARE_RFKILL_TASK(rfkill_bt, RFKILL_TYPE_BLUETOOTH);
+
+static void rfkill_event(struct input_handle *handle, unsigned int type,
+		        unsigned int code, int down)
+{
+	if (type == EV_KEY && down == 1) {
+		switch (code) {
+			case KEY_WLAN:
+				rfkill_schedule_toggle(&rfkill_wlan);
+				break;
+			case KEY_BLUETOOTH:
+				rfkill_schedule_toggle(&rfkill_bt);
+				break;
+			default:
+				break;
+		}
+	}
+}
+
+static int rfkill_connect(struct input_handler *handler, struct input_dev *dev,
+			  const struct input_device_id *id)
+{
+	struct input_handle *handle;
+	int error;
+
+	handle = kzalloc(sizeof(struct input_handle), GFP_KERNEL);
+	if (!handle)
+		return -ENOMEM;
+
+	handle->dev = dev;
+	handle->handler = handler;
+	handle->name = "rfkill";
+
+	error = input_register_handle(handle);
+	if (error)
+		goto err_free_handle;
+
+	error = input_open_device(handle);
+	if (error)
+		goto err_unregister_handle;
+
+	return 0;
+
+ err_unregister_handle:
+	input_unregister_handle(handle);
+ err_free_handle:
+	kfree(handle);
+	return error;
+}
+
+static void rfkill_disconnect(struct input_handle *handle)
+{
+	input_close_device(handle);
+	input_unregister_handle(handle);
+	kfree(handle);
+}
+
+static const struct input_device_id rfkill_ids[] = {
+	{
+		.flags = INPUT_DEVICE_ID_MATCH_EVBIT | INPUT_DEVICE_ID_MATCH_KEYBIT,
+		.evbit = { BIT(EV_KEY) },
+		.keybit = { [LONG(KEY_WLAN)] = BIT(KEY_WLAN) }
+	},
+	{
+		.flags = INPUT_DEVICE_ID_MATCH_EVBIT | INPUT_DEVICE_ID_MATCH_KEYBIT,
+		.evbit = { BIT(EV_KEY) },
+		.keybit = { [LONG(KEY_BLUETOOTH)] = BIT(KEY_BLUETOOTH) }
+	},
+};
+
+static struct input_handler rfkill_handler = {
+	.event =	rfkill_event,
+	.connect =	rfkill_connect,
+	.disconnect =	rfkill_disconnect,
+	.name =		"rfkill",
+	.id_table =	rfkill_ids,
+};
+
+static int __init rfkill_handler_init(void)
+{
+	return input_register_handler(&rfkill_handler);
+}
+
+static void __exit rfkill_handler_exit(void)
+{
+	input_unregister_handler(&rfkill_handler);
+	flush_scheduled_work();
+}
+
+module_init(rfkill_handler_init);
+module_exit(rfkill_handler_exit);
Index: work/net/rfkill/rfkill.c
===================================================================
--- /dev/null
+++ work/net/rfkill/rfkill.c
@@ -0,0 +1,400 @@
+/*
+ * Copyright (C) 2006 Ivo van Doorn
+ * Copyright (C) 2007 Dmitry Torokhov
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the
+ * Free Software Foundation, Inc.,
+ * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/workqueue.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/rfkill.h>
+
+MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("RF switch support");
+MODULE_LICENSE("GPL");
+
+static LIST_HEAD(rfkill_list);	/* list of registered rf switches */
+static DEFINE_MUTEX(rfkill_mutex);
+
+static enum rfkill_state rfkill_states[RFKILL_TYPE_MAX];
+
+static int rfkill_toggle_radio(struct rfkill *rfkill,
+				enum rfkill_state state)
+{
+	int retval;
+
+	retval = mutex_lock_interruptible(&rfkill->mutex);
+	if (retval)
+		return retval;
+
+	if (state != rfkill->state) {
+		retval = rfkill->toggle_radio(rfkill->data, state);
+		if (!retval)
+			rfkill->state = state;
+	}
+
+	mutex_unlock(&rfkill->mutex);
+	return retval;
+}
+
+/**
+ * rfkill_switch_all - Toggle state of all switches of given type
+ * @type: type of interfaces to be affeceted
+ * @state: the new state
+ *
+ * This function toggles state of all switches of given type unless
+ * a specific switch is claimed by userspace in which case it is
+ * left alone.
+ */
+
+void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state)
+{
+	struct rfkill *rfkill;
+
+	mutex_lock(&rfkill_mutex);
+
+	rfkill_states[type] = state;
+
+	list_for_each_entry(rfkill, &rfkill_list, node) {
+		if (!rfkill->user_claim)
+			rfkill_toggle_radio(rfkill, state);
+	}
+
+	mutex_unlock(&rfkill_mutex);
+}
+EXPORT_SYMBOL(rfkill_switch_all);
+
+static ssize_t rfkill_name_show(struct device *dev,
+				struct device_attribute *attr,
+				char *buf)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	return sprintf(buf, "%s\n", rfkill->name);
+}
+
+static ssize_t rfkill_type_show(struct device *dev,
+				struct device_attribute *attr,
+				char *buf)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+	const char *type;
+
+	switch (rfkill->type) {
+	case RFKILL_TYPE_WLAN:
+		type = "wlan";
+		break;
+	case RFKILL_TYPE_BLUETOOTH:
+		type = "bluetooth";
+		break;
+	case RFKILL_TYPE_IRDA:
+		type = "irda";
+		break;
+	default:
+		BUG();
+	}
+
+	return sprintf(buf, "%s\n", type);
+}
+
+static ssize_t rfkill_state_show(struct device *dev,
+				 struct device_attribute *attr,
+				 char *buf)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	return sprintf(buf, "%d\n", rfkill->state);
+}
+
+static ssize_t rfkill_state_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+	unsigned int state = simple_strtoul(buf, NULL, 0);
+	int error;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	error = rfkill_toggle_radio(rfkill,
+			state ? RFKILL_STATE_ON : RFKILL_STATE_OFF);
+	if (error)
+		return error;
+
+	return count;
+}
+
+static ssize_t rfkill_claim_show(struct device *dev,
+				 struct device_attribute *attr,
+				 char *buf)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	return sprintf(buf, "%d", rfkill->user_claim);
+}
+
+static ssize_t rfkill_claim_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+	bool claim = !!simple_strtoul(buf, NULL, 0);
+	int error;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	/*
+	 * Take the global lock to make sure the kernel is not in
+	 * the middle of rfkill_toggle_all
+	 */
+	error = mutex_lock_interruptible(&rfkill_mutex);
+	if (error)
+		return error;
+
+	if (rfkill->user_claim != claim) {
+		if (!claim)
+			rfkill_toggle_radio(rfkill,
+					    rfkill_states[rfkill->type]);
+		rfkill->user_claim = claim;
+	}
+
+	mutex_unlock(&rfkill_mutex);
+
+	return count;
+}
+
+static struct device_attribute rfkill_dev_attrs[] = {
+	__ATTR(name, S_IRUGO, rfkill_name_show, NULL),
+	__ATTR(type, S_IRUGO, rfkill_type_show, NULL),
+	__ATTR(state, S_IRUGO, rfkill_state_show, rfkill_state_store),
+	__ATTR(claim, S_IRUGO|S_IWUSR, rfkill_claim_show, rfkill_claim_store),
+	__ATTR_NULL
+};
+
+static void rfkill_release(struct device *dev)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	kfree(rfkill);
+	module_put(THIS_MODULE);
+}
+
+static int rfkill_suspend(struct device *dev, pm_message_t state)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	if (dev->power.power_state.event != state.event) {
+		if (state.event == PM_EVENT_SUSPEND) {
+			mutex_lock(&rfkill->mutex);
+
+			if (rfkill->state == RFKILL_STATE_ON)
+				rfkill->toggle_radio(rfkill->data,
+						     RFKILL_STATE_OFF);
+
+			mutex_unlock(&rfkill->mutex);
+		}
+
+		dev->power.power_state = state;
+	}
+
+	return 0;
+}
+
+static int rfkill_resume(struct device *dev)
+{
+	struct rfkill *rfkill = to_rfkill(dev);
+
+	if (dev->power.power_state.event != PM_EVENT_ON) {
+		mutex_lock(&rfkill->mutex);
+
+		if (rfkill->state == RFKILL_STATE_ON)
+			rfkill->toggle_radio(rfkill->data, RFKILL_STATE_ON);
+
+		mutex_unlock(&rfkill->mutex);
+	}
+
+	dev->power.power_state = PMSG_ON;
+	return 0;
+}
+
+static struct class rfkill_class = {
+	.name		= "rfkill",
+	.dev_release	= rfkill_release,
+	.dev_attrs	= rfkill_dev_attrs,
+	.suspend	= rfkill_suspend,
+	.resume		= rfkill_resume,
+};
+
+static int rfkill_add_switch(struct rfkill *rfkill)
+{
+	int retval;
+
+	retval = mutex_lock_interruptible(&rfkill_mutex);
+	if (retval)
+		return retval;
+
+	retval = rfkill_toggle_radio(rfkill, rfkill_states[rfkill->type]);
+	if (retval)
+		goto out;
+
+	list_add_tail(&rfkill->node, &rfkill_list);
+
+ out:
+	mutex_unlock(&rfkill_mutex);
+	return retval;
+}
+
+static void rfkill_remove_switch(struct rfkill *rfkill)
+{
+	mutex_lock(&rfkill_mutex);
+	list_del_init(&rfkill->node);
+	rfkill_toggle_radio(rfkill, RFKILL_STATE_OFF);
+	mutex_unlock(&rfkill_mutex);
+}
+
+/**
+ * rfkill_allocate - allocate memory for rfkill structure.
+ * @parent: device that has rf switch on it
+ * @type: type of the switch (wlan, bluetooth, irda)
+ *
+ * This function should be called by the network driver when it needs
+ * rfkill structure. Once the structure is allocated the driver shoud
+ * finish its initialization by setting name, private data, enable_radio
+ * and disable_radio methods and then register it with rfkill_register().
+ * NOTE: If registration fails the structure shoudl be freed by calling
+ * rfkill_free() otherwise rfkill_unregister() should be used.
+ */
+struct rfkill *rfkill_allocate(struct device *parent, enum rfkill_type type)
+{
+	struct rfkill *rfkill;
+	struct device *dev;
+
+	rfkill = kzalloc(sizeof(struct rfkill), GFP_KERNEL);
+	if (rfkill)
+		return NULL;
+
+	mutex_init(&rfkill->mutex);
+	INIT_LIST_HEAD(&rfkill->node);
+	rfkill->type = type;
+
+	dev = &rfkill->dev;
+	dev->class = &rfkill_class;
+	dev->parent = parent;
+	device_initialize(dev);
+
+	return rfkill;
+}
+EXPORT_SYMBOL(rfkill_allocate);
+
+/**
+ * rfkill_free - Mark rfkill structure for deletion
+ * @rfkill: rfkill structure to be destroyed
+ *
+ * Decrements reference count of rfkill structure so it is destoryed.
+ * Note that rfkill_free() should _not_ be called after rfkill_unregister().
+ */
+void rfkill_free(struct rfkill *rfkill)
+{
+	if (rfkill)
+		put_device(&rfkill->dev);
+}
+EXPORT_SYMBOL(rfkill_free);
+
+/**
+ * rfkill_register - Register a rfkill structure.
+ * @rfkill: rfkill structure to be registered
+ *
+ * This function should be called by the network driver when the rfkill
+ * structure needs to be registered. Immediately from registration the
+ * switch driver should be able to service calls to toggle_radio.
+ */
+int rfkill_register(struct rfkill *rfkill)
+{
+	static atomic_t rfkill_no = ATOMIC_INIT(0);
+	struct device *dev = &rfkill->dev;
+	int error;
+
+	if (!rfkill->toggle_radio)
+		return -EINVAL;
+
+	error = rfkill_add_switch(rfkill);
+	if (error)
+		return error;
+
+	snprintf(dev->bus_id, sizeof(dev->bus_id),
+		 "rfkill%ld", (long)atomic_inc_return(&rfkill_no) - 1);
+
+	error = device_add(dev);
+	if (error) {
+		rfkill_remove_switch(rfkill);
+		return error;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(rfkill_register);
+
+/**
+ * rfkill_unregister - Uegister a rfkill structure.
+ * @rfkill: rfkill structure to be unregistered
+ *
+ * This function should be called by the network driver during device
+ * teardown to destroy rfkill structure. Note that rfkill_free() should
+ * _not_ be called after rfkill_unregister().
+ */
+void rfkill_unregister(struct rfkill *rfkill)
+{
+	device_del(&rfkill->dev);
+	rfkill_remove_switch(rfkill);
+	put_device(&rfkill->dev);
+}
+EXPORT_SYMBOL(rfkill_unregister);
+
+/*
+ * Rfkill module initialization/deinitialization.
+ */
+static int __init rfkill_init(void)
+{
+	int error;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(rfkill_states); i++)
+		rfkill_states[i] = RFKILL_STATE_ON;
+
+	error = class_register(&rfkill_class);
+	if (error) {
+		printk(KERN_ERR "rfkill: unable to register rfkill class\n");
+		return error;
+	}
+
+	return 0;
+}
+
+static void __exit rfkill_exit(void)
+{
+	class_unregister(&rfkill_class);
+}
+
+module_init(rfkill_init);
+module_exit(rfkill_exit);
+
