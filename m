From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Wed, 31 Jan 2007 12:20:51 +0100
Message-ID: <200701311220.51971.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <20070130194023.4e2d5305@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "John Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:39119 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933035AbXAaLVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 06:21:12 -0500
Received: by nf-out-0910.google.com with SMTP id o25so519376nfa
        for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 03:21:10 -0800 (PST)
In-Reply-To: <20070130194023.4e2d5305@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hope you will be resubmitting this.

And here is the new version,
I didn't make the name const as requested
that field is being passed to the class_device_create
method which requires a char* argument.

But I have made the flag field.
And now this time the patch actually includes the
changes I promised in last mail.
(mutex, workqueue api, etc)

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

----

diff --git a/drivers/input/misc/Kconfig b/drivers/input/misc/Kconfig
index ba0e88c..6986d59 100644
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
index 0000000..d8fda73
--- /dev/null
+++ b/drivers/input/misc/rfkill.c
@@ -0,0 +1,999 @@
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
+#include <linux/workqueue.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/input.h>
+#include <linux/rfkill.h>
+
+MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("RF key support");
+MODULE_LICENSE("GPL");
+
+/*
+ * rfkill key structure.
+ */
+struct rfkill_key {
+	/*
+	 * For sysfs representation.
+	 */
+	struct class_device *cdev;
+
+	/*
+	 * Pointer to rfkill structure
+	 * that was filled in by key driver.
+	 */
+	const struct rfkill *rfkill;
+
+	/*
+	 * Pointer to type structure
+	 * that this key belongs to.
+	 */
+	struct rfkill_type *type;
+
+	/*
+	 * Current status of the key which controls the radio,
+	 * this value will change after the key state has changed
+	 * after polling, or the key driver has send the new state
+	 * manually.
+	 */
+#define RFKILL_KEY_RADIO_STATUS	1
+
+	unsigned long flags;
+
+	/*
+	 * Input device for this key.
+	 */
+	struct input_dev *input;
+
+	/*
+	 * List head structure to be used
+	 * to add this structure to the list.
+	 */
+	struct list_head entry;
+};
+
+/*
+ * rfkill type structure.
+ */
+struct rfkill_type {
+	/*
+	 * For sysfs representation.
+	 */
+	struct class_device *cdev;
+
+	/*
+	 * All access to the type structure and its
+	 * children (the keys) are protected by this mutex.
+	 */
+	struct mutex mutex;
+
+	/*
+	 * Name of this radio type.
+	 */
+	char *name;
+
+	/*
+	 * Key type identification. Value must be any
+	 * in the key_type enum.
+	 */
+	unsigned int key_type;
+
+	/*
+	 * List of rfkill_key structures.
+	 */
+	struct list_head key_list;
+
+	/*
+	 * Number of registered keys of this type.
+	 */
+	unsigned int key_count;
+
+	/*
+	 * The claim the user has over the toggling of the radio,
+	 * this can be any value of the user_claim enumeration.
+	 */
+	unsigned int user_claim;
+
+	/*
+	 * Number of keys that require polling
+	 */
+	unsigned int poll_required;
+
+	/*
+	 * Once key status change has been detected, the toggled
+	 * field should be set to indicate a notification to
+	 * user or driver should be performed. This is stored
+	 * globally since all keys within this type need to be
+	 * toggled.
+	 */
+#define RFKILL_TYPE_TOGGLED		1
+
+	/*
+	 * Current state of the radios in this type.
+	 */
+#define RFKILL_TYPE_RADIO_STATUS	2
+
+	unsigned long flags;
+
+	/*
+	 * Work structures for periodic polling,
+	 * as well as the scheduled radio toggling.
+	 */
+	struct work_struct toggle_work;
+	struct delayed_work poll_work;
+};
+
+/*
+ * rfkill master structure.
+ */
+struct rfkill_master {
+	/*
+	 * For sysfs representation.
+	 */
+	struct class *class;
+
+	/*
+	 * Reference to this modules structure.
+	 */
+	struct module *owner;
+
+	/*
+	 * List of available key types.
+	 */
+	struct rfkill_type* type[KEY_TYPE_MAX];
+};
+
+/*
+ * We only need 1 single master interface,
+ * make this a global variable since we always need it.
+ */
+static struct rfkill_master *master;
+
+/*
+ * Send toggle event to key driver.
+ */
+static void rfkill_toggle_radio_driver(struct rfkill_key *key)
+{
+	const struct rfkill *rfkill = key->rfkill;
+	struct rfkill_type *type = key->type;
+
+	/*
+	 * Check what the current radio status is, and perform
+	 * the correct action to toggle the radio. This will make
+	 * sure the correct event happens when either the key driver
+	 * of the user has requested to toggle this radio.
+	 */
+	if (!test_bit(RFKILL_TYPE_RADIO_STATUS, &type->flags))
+		rfkill->enable_radio(rfkill->data);
+	else
+		rfkill->disable_radio(rfkill->data);
+}
+
+/*
+ * Send toggle event to userspace through the input device.
+ */
+static void rfkill_toggle_radio_input(struct rfkill_key *key)
+{
+	input_report_key(key->input, KEY_RFKILL,
+		!test_bit(RFKILL_TYPE_RADIO_STATUS, &key->type->flags));
+	input_sync(key->input);
+}
+
+/*
+ * Loop through the list of registered keys and toggle each
+ * key if this type has been toggled (by either user or driver).
+ */
+static void rfkill_toggle_radio(struct work_struct *work)
+{
+	struct rfkill_type *type =
+		container_of(work, struct rfkill_type, toggle_work);
+	struct rfkill_key *key;
+
+	mutex_lock(&type->mutex);
+
+	/*
+	 * If this type hasn't been toggled by any of the keys
+	 * or the user we can skip the toggle run.
+	 */
+	if (!test_bit(RFKILL_TYPE_TOGGLED, &type->flags)) {
+		mutex_unlock(&type->mutex);
+		return;
+	}
+
+	list_for_each_entry(key, &type->key_list, entry) {
+		/*
+		 * Check what kind of claim the user has requested
+		 * on this key. This determined if we should send
+		 * a user and/or a driver notification.
+		 */
+		if (type->user_claim != USER_CLAIM_IGNORE)
+			rfkill_toggle_radio_input(key);
+		else if (type->user_claim != USER_CLAIM_SINGLE)
+			rfkill_toggle_radio_driver(key);
+	}
+
+	/*
+	 * Reset the radio_status and toggled field,
+	 * to respresent the correct status to the user,
+	 * and allow the status to be toggled again.
+	 */
+	change_bit(RFKILL_TYPE_RADIO_STATUS, &type->flags);
+	clear_bit(RFKILL_TYPE_TOGGLED, &type->flags);
+
+	mutex_unlock(&type->mutex);
+}
+
+/*
+ * Check the new status of the key, and determine if the key has been toggled.
+ * This function can be called upon request by the device driver or userspace.
+ */
+static int rfkill_check_status(struct rfkill_key *key, int status)
+{
+	struct rfkill_type *type = key->type;
+
+	/*
+	 * A key should be toggled if the current radio status does not
+	 * match the requested status. This check is required instead of
+	 * comparing it to the current key status since this function can
+	 * be called on request of the user as well. The user is able to
+	 * request a radio toggle to make sure the radio status will match
+	 * the key status if the new key status has been reported to
+	 * userspace only.
+	 * As a safety measure, we won't toggle a key twice.
+	 */
+	if (test_bit(RFKILL_TYPE_RADIO_STATUS, &type->flags) != !!status &&
+	    !test_bit(RFKILL_TYPE_TOGGLED, &type->flags)) {
+		set_bit(RFKILL_TYPE_TOGGLED, &type->flags);
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
+ * Wrapper around the rfkill_check_status function, this may only
+ * be called from the device driver status events. Besides calling
+ * rfkill_check_status it will also update the key_status field.
+ */
+static int rfkill_check_key(struct rfkill_key *key, int status)
+{
+	/*
+	 * Store the new key status, and only if the 2
+	 * are different the new status status should be
+	 * passed on to rfkill_check_status to determine
+	 * if any action should be performed.
+	 */
+	if (test_bit(RFKILL_KEY_RADIO_STATUS, &key->flags) == !!status)
+		return 0;
+
+	change_bit(RFKILL_KEY_RADIO_STATUS, &key->flags);
+	return rfkill_check_status(key, status);
+}
+
+/*
+ * Handler that is run frequently to determine the current status
+ * of all registered keys that require polling.
+ */
+static void rfkill_list_poll(struct work_struct *work)
+{
+	struct rfkill_type *type =
+		container_of(work, struct rfkill_type, poll_work.work);
+	const struct rfkill *rfkill;
+	struct rfkill_key *key;
+	int status = 0;
+
+	mutex_lock(&type->mutex);
+
+	list_for_each_entry(key, &type->key_list, entry) {
+		rfkill = key->rfkill;
+
+		/*
+		 * If the poll handler has not been given
+		 * the key driver should report events,
+		 * so we can ignore this key now.
+		 */
+		if (!rfkill->poll)
+			continue;
+
+		/*
+		 * Poll radio state and check if a radio toggle
+		 * has been requested by the key.
+		 */
+		if (rfkill_check_key(key, rfkill->poll(rfkill->data)))
+			status = 1;
+	}
+
+	mutex_unlock(&type->mutex);
+
+	/*
+	 * A radio toggle has been requested, schedule the toggle work thread.
+	 */
+	if (status)
+		schedule_work(&type->toggle_work);
+
+	/*
+	 * Check if we need to rearm ourselves.
+	 */
+	if (type->poll_required)
+		schedule_delayed_work(&type->poll_work, RFKILL_POLL_DELAY);
+}
+
+/**
+ * rfkill_report_event - Report change in key status to rfkill handler.
+ * @rfkill: rfkill structure registered by key driver
+ * @new_status: new key status
+ *
+ * This function should be called by the key driver if it has not provided
+ * a poll handler with rfkill. As soon as the key driver has determined
+ * the status of the key has changed it should report the new status
+ * through this function.
+ */
+void rfkill_report_event(struct rfkill *rfkill, int new_status)
+{
+	struct rfkill_type *type = rfkill->key->type;
+
+	mutex_lock(&type->mutex);
+
+	if (rfkill_check_key(rfkill->key, new_status))
+		schedule_work(&type->toggle_work);
+
+	mutex_unlock(&type->mutex);
+}
+EXPORT_SYMBOL_GPL(rfkill_report_event);
+
+/*
+ * Sysfs release functions.
+ */
+static void rfkill_class_device_release(struct class_device *cdev)
+{
+	kfree(class_get_devdata(cdev));
+}
+
+static void rfkill_class_release(struct class *class)
+{
+	kfree(master);
+	master = NULL;
+}
+
+/*
+ * rfkill key attribute to display the current key status.
+ */
+static ssize_t rfkill_key_status_show(struct class_device *cdev, char *buf)
+{
+	struct rfkill_key *key = class_get_devdata(cdev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return sprintf(buf, "%d",
+		test_bit(RFKILL_KEY_RADIO_STATUS, &key->flags));
+}
+
+static struct class_device_attribute cdev_attr_key_status =
+	__ATTR(status, S_IRUGO, rfkill_key_status_show, NULL);
+
+/*
+ * rfkill type attribute to display the current radio status.
+ */
+static ssize_t rfkill_type_status_show(struct class_device *cdev, char *buf)
+{
+	struct rfkill_type *type = class_get_devdata(cdev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return sprintf(buf, "%d",
+		test_bit(RFKILL_TYPE_RADIO_STATUS, &type->flags));
+}
+
+static struct class_device_attribute cdev_attr_type_status =
+	__ATTR(status, S_IRUGO, rfkill_type_status_show, NULL);
+
+/*
+ * rfkill type attribute to display/change the user claim
+ */
+static ssize_t rfkill_type_claim_show(struct class_device *cdev, char *buf)
+{
+	struct rfkill_type *type = class_get_devdata(cdev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return sprintf(buf, "%d", type->user_claim);
+}
+
+static ssize_t rfkill_type_claim_store(struct class_device *cdev,
+	const char * buf, size_t count)
+{
+	struct rfkill_type *type = class_get_devdata(cdev);
+	unsigned int claim = simple_strtoul(buf, NULL, 0);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (claim >= USER_CLAIM_MAX)
+		return -EINVAL;
+
+	mutex_lock(&type->mutex);
+
+	type->user_claim = claim;
+
+	mutex_unlock(&type->mutex);
+
+	return count;
+}
+
+static struct class_device_attribute cdev_attr_type_claim =
+	__ATTR(claim, S_IRUGO | S_IWUSR,
+		rfkill_type_claim_show, rfkill_type_claim_store);
+
+/*
+ * rfkill key sysfs creation/destruction.
+ */
+static int rfkill_key_sysfs_create(struct rfkill_key *key)
+{
+	int status;
+
+	key->cdev = class_device_create(master->class,
+					key->type->cdev,
+					key->rfkill->dev->devt,
+					key->rfkill->dev,
+					key->rfkill->dev_name);
+	if (unlikely(!key->cdev || IS_ERR(key->cdev)))
+		return PTR_ERR(key->cdev);
+
+	/*
+	 * Make sure this key can be freed when the class_device is freed.
+	 */
+	class_set_devdata(key->cdev, key);
+
+	/*
+	 * Create the sysfs files.
+	 */
+	status = class_device_create_file(key->cdev, &cdev_attr_key_status);
+	if (unlikely(status))
+		goto exit;
+
+	/*
+	 * The key belongs to the device structure the key driverdevt
+	 * has given us a reference to. But besides that device
+	 * this key also belongs to the input device that has been
+	 * created. We should create the link to that entry manually.
+	 */
+	status = sysfs_create_link(&key->cdev->kobj, &key->input->cdev.kobj,
+				   "idev");
+	if (unlikely(status))
+		goto exit_file;
+
+	return 0;
+
+exit_file:
+	class_device_remove_file(key->cdev, &cdev_attr_key_status);
+
+exit:
+	class_device_destroy(master->class, key->rfkill->dev->devt);
+	class_set_devdata (key->cdev, NULL);
+
+	return status;
+}
+
+static void rfkill_key_sysfs_release(struct rfkill_key *key)
+{
+	sysfs_remove_link(&key->cdev->kobj, "idev");
+	class_device_remove_file(key->cdev, &cdev_attr_key_status);
+	class_device_destroy(master->class, key->rfkill->dev->devt);
+}
+
+/*
+ * rfkill type sysfs creation/destruction.
+ */
+static int rfkill_type_sysfs_create(struct rfkill_type *type)
+{
+	int status;
+
+	type->cdev = class_device_create(master->class, NULL, type->key_type,
+					 NULL, type->name);
+	if (unlikely(!type->cdev || IS_ERR(type->cdev)))
+		return PTR_ERR(type->cdev);
+
+	/*
+	 * Make sure this key can be freed when the class_device is freed.
+	 */
+	class_set_devdata(type->cdev, type);
+
+	/*
+	 * Create the sysfs files.
+	 */
+	status = class_device_create_file(type->cdev, &cdev_attr_type_claim);
+	if (unlikely(status))
+		goto exit;
+
+	/*
+	 * Create the sysfs files.
+	 */
+	status = class_device_create_file(type->cdev, &cdev_attr_type_status);
+	if (unlikely(status))
+		goto exit_claim;
+
+	return 0;
+
+exit_claim:
+	class_device_remove_file(type->cdev, &cdev_attr_type_claim);
+
+exit:
+	class_device_destroy(type->cdev->class, type->key_type);
+	class_set_devdata (type->cdev, NULL);
+
+	return status;
+}
+
+static void rfkill_type_sysfs_release(struct rfkill_type *type)
+{
+	class_device_remove_file(type->cdev, &cdev_attr_type_status);
+	class_device_remove_file(type->cdev, &cdev_attr_type_claim);
+	class_device_destroy(type->cdev->class, type->key_type);
+}
+
+/*
+ * rfkill master sysfs creation/destruction.
+ */
+static int rfkill_master_sysfs_create(struct rfkill_master *master)
+{
+	master->class = class_create(master->owner, "rfkill");
+	if (unlikely(!master->class || IS_ERR(master->class)))
+		return PTR_ERR(master->class);
+
+	master->class->release = rfkill_class_device_release;
+	master->class->class_release = rfkill_class_release;
+
+	return 0;
+}
+
+static void rfkill_master_sysfs_release(struct rfkill_master *master)
+{
+	class_destroy(master->class);
+}
+
+/*
+ * Input device initialization/deinitialization handler.
+ */
+static struct input_dev* rfkill_register_input(struct rfkill_key *key)
+{
+	struct input_dev *input;
+	int status;
+	char *name;
+	char *phys;
+
+	input = input_allocate_device();
+	if (unlikely(!input))
+		return NULL;
+
+	/*
+	 * Link the private data to rfkill structure.
+	 */
+	input->private = key;
+
+	/*
+	 * Allocate the strings for the input device names.
+	 */
+	name = kasprintf(GFP_KERNEL, "rfkill %s",
+			 key->rfkill->dev_name);
+	phys = kasprintf(GFP_KERNEL, "rfkill/%s/%s",
+			 key->type->name, key->rfkill->dev_name);
+
+	if (!name || !phys)
+		goto exit;
+
+	input->name = name;
+	input->phys = phys;
+
+	/*
+	 * Initialize the input_id structure.
+	 */
+	input->id.bustype = BUS_HOST;
+	input->id.vendor = 0x0001;
+	input->id.product = 0x0001;
+	input->id.version = 0x0001;
+
+	input->evbit[0] = BIT(EV_KEY);
+	set_bit(KEY_RFKILL, input->keybit);
+
+	status = input_register_device(input);
+	if (status)
+		goto exit;
+
+	return input;
+
+exit:
+	kfree(name);
+	kfree(phys);
+
+	input_free_device(input);
+
+	return NULL;
+}
+
+static void rfkill_deregister_input(struct rfkill_key *key)
+{
+	const char *name;
+	const char *phys;
+
+	/*
+	 * The name and phys fields have been allocated
+	 * using kasprintf, this means they have to be
+	 * freed seperately.
+	 */
+	name = key->input->name;
+	phys = key->input->phys;
+
+	input_unregister_device(key->input);
+	kfree(name);
+	kfree(phys);
+	input_free_device(key->input);
+}
+
+/*
+ * Rfkill key initialization/deinitialization.
+ * These methods should only be called with the mutex held.
+ */
+static int rfkill_key_init(struct rfkill *rfkill, struct rfkill_key *key,
+	int status)
+{
+	/*
+	 * Initialize all variables.
+	 */
+	key->rfkill = rfkill;
+	rfkill->key = key;
+	key->type = master->type[rfkill->key_type];
+	if (status)
+		set_bit(RFKILL_KEY_RADIO_STATUS, &key->flags);
+	else
+		clear_bit(RFKILL_KEY_RADIO_STATUS, &key->flags);
+	INIT_LIST_HEAD(&key->entry);
+
+	/*
+	 * Create input device.
+	 */
+	key->input = rfkill_register_input(key);
+	if (!key->input)
+		goto exit;
+
+	/*
+	 * Create sysfs entry.
+	 */
+	if (rfkill_key_sysfs_create(key))
+		goto exit_input;
+
+	return 0;
+
+exit_input:
+	rfkill_deregister_input(key);
+
+exit:
+	rfkill->key = NULL;
+
+	return -ENOMEM;
+}
+
+static void rfkill_key_deinit(struct rfkill_key *key)
+{
+	if (key) {
+		rfkill_key_sysfs_release(key);
+		rfkill_deregister_input(key);
+	}
+}
+
+/*
+ * Rfkill type handler to check if the sysfs entries should
+ * be created or removed based on the number of registered keys.
+ */
+static void rfkill_add_type_key(struct rfkill_type *type,
+	struct rfkill_key *key)
+{
+	/*
+	 * Add key to the list.
+	 */
+	list_add(&key->entry, &type->key_list);
+	type->key_count++;
+}
+
+static void rfkill_del_type_key(struct rfkill_type *type,
+	struct rfkill_key *key)
+{
+	/*
+	 * Delete the rfkill structure from the list.
+	 */
+	list_del(&key->entry);
+	type->key_count--;
+}
+
+/**
+ * rfkill_register_key - Register a rfkill structure.
+ * @rfkill: rfkill structure to be registered
+ * @init_status: initial status of the key at the time this function is called
+ *
+ * This function should be called by the key driver when the rfkill structure
+ * needs to be registered. Immediately from registration the key driver
+ * should be able to receive calls through the poll, enable_radio and
+ * disable_radio handlers if those were registered.
+ */
+int rfkill_register_key(struct rfkill *rfkill, int init_status)
+{
+	struct rfkill_type *type;
+	struct rfkill_key *key;
+	int status;
+
+	if (!rfkill || !rfkill->enable_radio || !rfkill->disable_radio)
+		return -EINVAL;
+
+	/*
+	 * Check if the requested key_type was valid.
+	 */
+	if (rfkill->key_type >= KEY_TYPE_MAX)
+		return -EINVAL;
+
+	type = master->type[rfkill->key_type];
+
+	/*
+	 * Increase module use count to prevent this
+	 * module to be unloaded while there are still
+	 * registered keys.
+	 */
+	if (!try_module_get(master->owner))
+		return -EBUSY;
+
+	mutex_lock(&type->mutex);
+
+	key = kzalloc(sizeof(struct rfkill_key), GFP_KERNEL);
+	if (unlikely(!key)) {
+		status = -ENOMEM;
+		goto exit;
+	}
+
+	/*
+	 * Initialize key, and add it to the type structure.
+	 */
+	key->type = type;
+	status = rfkill_key_init(rfkill, key, init_status);
+	if (status)
+		goto exit_key;
+
+	/*
+	 * Add key to the specified type.
+	 */
+	rfkill_add_type_key(type, key);
+
+	/*
+	 * Check if we need polling, and if we do
+	 * increase the poll required counter and check
+	 * if we weren't polling yet.
+	 */
+	if (rfkill->poll && !type->poll_required++)
+		schedule_delayed_work(&type->poll_work, RFKILL_POLL_DELAY);
+
+	mutex_unlock(&type->mutex);
+
+	return 0;
+
+exit_key:
+	kfree(key);
+
+exit:
+	mutex_unlock(&type->mutex);
+	module_put(master->owner);
+
+	return status;
+}
+EXPORT_SYMBOL_GPL(rfkill_register_key);
+
+/**
+ * rfkill_deregister_key - Deregister a previously registered rfkill structure.
+ * @rfkill: rfkill structure to be deregistered
+ *
+ * This function should be called by the key driver when the rfkill structure
+ * needs to be deregistered. This function may only be called if it was
+ * previously registered with rfkill_register_key.
+ */
+int rfkill_deregister_key(struct rfkill *rfkill)
+{
+	struct rfkill_type *type;
+
+	if (!rfkill || !rfkill->key)
+		return -EINVAL;
+
+	type = rfkill->key->type;
+
+	mutex_lock(&type->mutex);
+
+	/*
+	 * Cancel delayed work if this is the last key
+	 * that requires polling. It is not bad if the
+	 * workqueue is still running, the workqueue
+	 * will not rearm itself since the poll_required
+	 * variable has been cleared, and we have
+	 * protected the list with a mutex.
+	 */
+	if (rfkill->poll && !--type->poll_required)
+		cancel_delayed_work(&type->poll_work);
+
+	/*
+	 * Deinitialize key, and remove it from the type.
+	 */
+	rfkill_del_type_key(type, rfkill->key);
+	rfkill_key_deinit(rfkill->key);
+
+	mutex_unlock(&type->mutex);
+
+	/*
+	 * rfkill entry has been removed,
+	 * decrease module use count.
+	 */
+	module_put(master->owner);
+	
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rfkill_deregister_key);
+
+/*
+ * Rfkill type initialization/deinitialization.
+ */
+static int rfkill_type_init(unsigned int key_type, char *name)
+{
+	struct rfkill_type *type;
+	int status;
+
+	type = kzalloc(sizeof(struct rfkill_type), GFP_KERNEL);
+	if (unlikely(!type))
+		return -ENOMEM;
+
+	/*
+	 * Initialize all variables.
+	 */
+	mutex_init(&type->mutex);
+	type->name = name;
+	type->key_type = key_type;
+	INIT_LIST_HEAD(&type->key_list);
+	clear_bit(RFKILL_TYPE_TOGGLED, &type->flags);
+	type->key_count = 0;
+	type->poll_required = 0;
+
+	/*
+	 * Work structures for periodic polling,
+	 * as well as the scheduled radio toggling.
+	 */
+	INIT_WORK(&type->toggle_work, &rfkill_toggle_radio);
+	INIT_DELAYED_WORK(&type->poll_work, &rfkill_list_poll);
+
+	/*
+	 * Create sysfs entry.
+	 */
+	status = rfkill_type_sysfs_create(type);
+	if (status) {
+		printk(KERN_ERR "Failed to create sysfs entry %s", name);
+		goto exit;
+	}
+
+	master->type[key_type] = type;
+
+	return 0;
+
+exit:
+	kfree(type);
+
+	return status;
+}
+
+static void rfkill_type_deinit(unsigned int key_type)
+{
+	rfkill_type_sysfs_release(master->type[key_type]);
+}
+
+/*
+ * Rfkill master initialization/deinitialization.
+ */
+static int rfkill_master_init(void)
+{
+	int status;
+
+	master = kzalloc(sizeof(struct rfkill_master), GFP_KERNEL);
+	if (unlikely(!master))
+		return -ENOMEM;
+
+	/*
+	 * Set the module owner reference.
+	 */
+	master->owner = THIS_MODULE;
+
+	/*
+	 * Create sysfs entry.
+	 */
+	status = rfkill_master_sysfs_create(master);
+	if (status) {
+		printk(KERN_ERR "Failed to create master sysfs entry");
+		goto exit;
+	}
+
+	/*
+	 * Create and initialize all type structures.
+	 */
+	status = rfkill_type_init(KEY_TYPE_WLAN, "wlan");
+	if (status)
+		goto exit_master;
+
+	status = rfkill_type_init(KEY_TYPE_BlUETOOTH, "bluetooth");
+	if (status)
+		goto exit_wlan;
+
+	status = rfkill_type_init(KEY_TYPE_IRDA, "irda");
+	if (status)
+		goto exit_bluetooth;
+
+	return 0;
+
+exit_bluetooth:
+	rfkill_type_deinit(KEY_TYPE_BlUETOOTH);
+
+exit_wlan:
+	rfkill_type_deinit(KEY_TYPE_WLAN);
+
+exit_master:
+	rfkill_master_sysfs_release(master);
+
+exit:
+	kfree(master);
+	master = NULL;
+
+	return status;
+}
+
+static void rfkill_master_deinit(void)
+{
+	if (master) {
+		rfkill_type_deinit(KEY_TYPE_IRDA);
+		rfkill_type_deinit(KEY_TYPE_BlUETOOTH);
+		rfkill_type_deinit(KEY_TYPE_WLAN);
+		rfkill_master_sysfs_release(master);
+	}
+}
+
+/*
+ * Module initialization/deinitialization.
+ */
+static int __init rfkill_init(void)
+{
+	printk(KERN_INFO "Loading rfkill driver.\n");
+
+	return rfkill_master_init();
+}
+
+static void __exit rfkill_exit(void)
+{
+	rfkill_master_deinit();
+
+	printk(KERN_INFO "Unloading rfkill driver.\n");
+}
+
+module_init(rfkill_init);
+module_exit(rfkill_exit);
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
new file mode 100644
index 0000000..4f45429
--- /dev/null
+++ b/include/linux/rfkill.h
@@ -0,0 +1,140 @@
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
+	Laptops are quite often equipped with an RF key to enable or
+	disable the radio of the wireless device attached to that key.
+	This wireless device usually is an integrated wireless network device,
+	infrared or bluetooth device.
+	There are 3 catagories of radio control keys:
+	 A) The key directly toggles the hardware radio, and does not send an
+	    event to userspace.
+	 B) The key does not toggle the hardware radio, and does not send an
+	    event to userspace.
+	 C) The key does not toggle the hardware radio, but does send an event
+	    to userspace.
+	Catagory (A) should create an input device themselves and send an
+	KEY_RFKILL event over that input device.
+	Catagory (B) should register themselves with rkfkill and allow rfkill
+	to toggle the radio and report events to userspace.
+	Catagory (C) should register with rfkill, who will listen to userspace
+	requests to toggle the radio and will send the signal to the driver.
+
+	The rfkill driver will contain a list of all devices with an RF button,
+	and hardware drivers need to register their hardware to the rfkill
+	interface. Rfkill will then take care of everything. If the RF key
+	requires polling to obtain the status this will be handled by rfkill.
+	If the RF key does not require polling but sends for example interrupts,
+	the hardware driver can report the change of status to rfkill, without
+	having to do any other action.
+
+	For each registered hardware button an input device will be created.
+	If this input device has been opened by the user, rfkill will send a
+	signal to userspace instead of the hardware about the new button
+	status. This will allow userpace to perform the correct steps
+	in order to bring down all interfaces.
+
+	Through sysfs it is also possible the user requests the toggling of
+	the radio, this means that the radio could be toggled even without
+	pressing the radio key.
+ */
+
+#ifndef RFKILL_H
+#define RFKILL_H
+
+#include <linux/device.h>
+
+/*
+ * The keys will be periodically checked if the
+ * key has been toggled. By default this will be 100ms.
+ */
+#define RFKILL_POLL_DELAY	( HZ / 10 )
+
+/**
+ * enum key_type - Key type for rfkill keys.
+ * KEY_TYPE_WLAN: key type for Wireless network devices.
+ * KEY_TYPE_BlUETOOTH: key type for bluetooth devices.
+ * KEY_TYPE_IRDA: key type for infrared devices.
+ */
+enum key_type {
+	KEY_TYPE_WLAN = 0,
+	KEY_TYPE_BlUETOOTH = 1,
+	KEY_TYPE_IRDA = 2,
+	KEY_TYPE_MAX = 3,
+};
+
+/**
+ * enum user_claim - Users' claim on rfkill key.
+ * @USER_CLAIM_IGNORE: Don't notify user of key events.
+ * @USER_CLAIM_NOTIFY: Notify user of key events, but
+ * 	still automatically toggle the radio.
+ * @USER_CLAIM_SINGLE: Notify user of key events, and
+ * 	do not toggle the radio anymore.
+ */
+enum user_claim {
+	USER_CLAIM_IGNORE = 0,
+	USER_CLAIM_NOTIFY = 1,
+	USER_CLAIM_SINGLE = 2,
+	USER_CLAIM_MAX = 3,
+};
+
+/**
+ * struct rfkill - rfkill button control structure.
+ * @dev_name: Name of the interface. This will become the name
+ * 	of the input device which will be created for this button.
+ * @dev: Pointer to the device structure to which this button belongs to.
+ * @data: Pointer to the RF button drivers private data which will be
+ * 	passed along with the radio and polling handlers.
+ * @poll(void *data): Optional handler which will frequently be
+ * 	called to determine the current status of the RF button.
+ * @enable_radio(void *data): Optional handler to enable the radio
+ * 	once the RF button has been pressed and the hardware does enable
+ * 	the radio automaticly.
+ * @disable_radio(void *data): Optional handler to disable the radio
+ * 	once the RF button has been pressed and the hardware does disable
+ * 	the radio automaticly.
+ * @key_type: Radio type which the button controls, the value stored
+ * 	here should be a value from enum key_type.
+ * @key: Internal pointer that should not be touched by key driver.
+ *
+ * This structure can be used by a key driver to register the key
+ * to the rfkill driver in order to take control of the reporting
+ * to userspace or handling of radio status.
+ */
+struct rfkill {
+	char *dev_name;
+
+	struct device *dev;
+
+	void *data;
+	int (*poll)(void *data);
+	void (*enable_radio)(void *data);
+	void (*disable_radio)(void *data);
+
+	unsigned int key_type;
+
+	struct rfkill_key *key;
+};
+
+int rfkill_register_key(struct rfkill *rfkill, int init_status);
+int rfkill_deregister_key(struct rfkill *rfkill);
+void rfkill_report_event(struct rfkill *rfkill, int new_status);
+
+#endif /* RFKILL_H */
