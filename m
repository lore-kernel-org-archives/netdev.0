From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH 1/2] driver core: add device_poll interface
Date: Mon, 26 Jan 2015 16:46:32 -0600
Message-ID: <1422312393-61485-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jaeden.amero@ni.com, ben.shelton@ni.com, brad.mouring@ni.com,
	rich.tollerton@ni.com
To: gregkh@suse.de, davem@davemloft.net, jeff.westfahl@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Westfahl <jeff.westfahl@ni.com>

Add the device_poll interface to the driver core. This is a generic
interface that any struct device can take advantage of to dynamically
switch between using interrupts and polling. Many drivers can be easily
modified to take advantage of this feature if desired.

This interface is most likely to be used along with the RT patch. It has
only been used thus far on Ethernet interfaces. Even with the standard
RT change to threaded interrupts for all devices, some RT applications
can be sensitive to even the minimal hardware interrupt that still occurs
with threaded interrupt handlers. The device_poll interface can be used
to completely eliminate all hardware interrupts for a device and the
associated jitter.

This is a standalone feature that should be submitted for review and
possible inclusion in mainline, or maybe in the RT patch.

Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
---
 drivers/base/Kconfig        |   3 +
 drivers/base/Makefile       |   1 +
 drivers/base/poll.c         | 327 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/device_poll.h | 105 ++++++++++++++
 4 files changed, 436 insertions(+)
 create mode 100644 drivers/base/poll.c
 create mode 100644 include/linux/device_poll.h

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 21cf46f..d23df71 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -174,4 +174,7 @@ config SYS_HYPERVISOR
 
 source "drivers/base/regmap/Kconfig"
 
+config DEVICE_POLL
+	bool
+
 endmenu
diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 99a375a..92ab7f3 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_MODULES)	+= module.o
 endif
 obj-$(CONFIG_SYS_HYPERVISOR) += hypervisor.o
 obj-$(CONFIG_REGMAP)	+= regmap/
+obj-$(CONFIG_DEVICE_POLL) += poll.o
 
 ccflags-$(CONFIG_DEBUG_DRIVER) := -DDEBUG
 
diff --git a/drivers/base/poll.c b/drivers/base/poll.c
new file mode 100644
index 0000000..911a296
--- /dev/null
+++ b/drivers/base/poll.c
@@ -0,0 +1,327 @@
+/*
+ * Copyright (C) 2014 National Instruments Corp.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/device_poll.h>
+#include <linux/device.h>
+#include <linux/sysfs.h>
+#include <linux/sched.h>
+#include <linux/stat.h>
+#include <linux/kthread.h>
+#include <linux/delay.h>
+
+/* sysfs attributes */
+
+#define to_ext_attr(x) container_of(x, struct dev_ext_attribute, attr)
+
+/* get sysfs attributes */
+
+ssize_t device_poll_get_interval(struct device *dev,
+				 struct device_attribute *attr, char *buf)
+{
+	struct dev_ext_attribute *ea = to_ext_attr(attr);
+	struct device_poll *device_poll = ea->var;
+
+	return sprintf(buf, "%d\n", device_poll->interval);
+}
+
+static ssize_t device_poll_get_policy(struct device *dev,
+				      struct device_attribute *attr, char *buf)
+{
+	struct dev_ext_attribute *ea = to_ext_attr(attr);
+	struct device_poll *device_poll = ea->var;
+
+	switch (device_poll->policy) {
+	case SCHED_NORMAL:
+		return sprintf(buf, "SCHED_NORMAL (SCHED_OTHER)\n");
+	case SCHED_FIFO:
+		return sprintf(buf, "SCHED_FIFO\n");
+	case SCHED_RR:
+		return sprintf(buf, "SCHED_RR\n");
+	case SCHED_BATCH:
+		return sprintf(buf, "SCHED_BATCH\n");
+	case SCHED_IDLE:
+		return sprintf(buf, "SCHED_IDLE\n");
+	default:
+		return sprintf(buf, "unknown\n");
+	}
+}
+
+static ssize_t device_poll_get_priority(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct dev_ext_attribute *ea = to_ext_attr(attr);
+	struct device_poll *device_poll = ea->var;
+
+	return sprintf(buf, "%d\n", device_poll->priority);
+}
+
+/* set sysfs attributes */
+
+static ssize_t device_poll_set_interval(struct device *dev,
+					struct device_attribute *attr,
+					const char *buf, size_t size)
+{
+	struct dev_ext_attribute *ea = to_ext_attr(attr);
+	struct device_poll *device_poll = ea->var;
+	int interval;
+	int ret = 0;
+
+	if (device_poll->use_capability && !capable(device_poll->capability))
+		return -EPERM;
+
+	if (0 > kstrtoint(buf, 0, &interval))
+		return -EINVAL;
+
+	device_poll->ops->lock(device_poll);
+	if (device_poll->interval != interval) {
+		device_poll->interval = interval;
+
+		ret = device_poll->ops->reinit(device_poll);
+	}
+	device_poll->ops->unlock(device_poll);
+
+	if (ret)
+		return ret;
+
+	return size;
+}
+
+static ssize_t device_poll_set_policy(struct device *dev,
+				      struct device_attribute *attr,
+				      const char *buf, size_t size)
+{
+	struct dev_ext_attribute *ea = to_ext_attr(attr);
+	struct device_poll *device_poll = ea->var;
+	char policy_str[16] = { 0 };
+	int policy;
+	struct sched_param param;
+
+	if (device_poll->use_capability && !capable(device_poll->capability))
+		return -EPERM;
+
+	if (1 != sscanf(buf, "%15s", policy_str))
+		return -EINVAL;
+
+	if ((0 == strcmp(policy_str, "SCHED_NORMAL") ||
+	     (0 == strcmp(policy_str, "SCHED_OTHER"))))
+		policy = SCHED_NORMAL;
+	else if (0 == strcmp(policy_str, "SCHED_FIFO"))
+		policy = SCHED_FIFO;
+	else if (0 == strcmp(policy_str, "SCHED_RR"))
+		policy = SCHED_RR;
+	else if (0 == strcmp(policy_str, "SCHED_BATCH"))
+		policy = SCHED_BATCH;
+	else if (0 == strcmp(policy_str, "SCHED_IDLE"))
+		policy = SCHED_IDLE;
+	else
+		return -EINVAL;
+
+	device_poll->ops->lock(device_poll);
+	if (device_poll->policy != policy) {
+		device_poll->policy = policy;
+
+		if (device_poll->task) {
+			param.sched_priority = device_poll->priority;
+			sched_setscheduler(device_poll->task,
+					   device_poll->policy,
+					   &param);
+		}
+	}
+	device_poll->ops->unlock(device_poll);
+
+	return size;
+}
+
+static ssize_t device_poll_set_priority(struct device *dev,
+					struct device_attribute *attr,
+					const char *buf, size_t size)
+{
+	struct dev_ext_attribute *ea = to_ext_attr(attr);
+	struct device_poll *device_poll = ea->var;
+	int priority;
+	struct sched_param param;
+
+	if (device_poll->use_capability && !capable(device_poll->capability))
+		return -EPERM;
+
+	if (0 > kstrtoint(buf, 0, &priority))
+		return -EINVAL;
+
+	device_poll->ops->lock(device_poll);
+	if (device_poll->priority != priority) {
+		device_poll->priority = priority;
+
+		if (device_poll->task) {
+			param.sched_priority = device_poll->priority;
+			sched_setscheduler(device_poll->task,
+					   device_poll->policy,
+					   &param);
+		}
+	}
+	device_poll->ops->unlock(device_poll);
+
+	return size;
+}
+
+/* sysfs attributes */
+
+static const DEVICE_ATTR(interval, S_IWUSR | S_IRUGO,
+			 device_poll_get_interval, device_poll_set_interval);
+
+static const DEVICE_ATTR(policy, S_IWUSR | S_IRUGO,
+			 device_poll_get_policy, device_poll_set_policy);
+
+static const DEVICE_ATTR(priority, S_IWUSR | S_IRUGO,
+			 device_poll_get_priority, device_poll_set_priority);
+
+/* device_poll internal functions */
+
+static int device_poll_thread(void *info)
+{
+	struct device_poll *device_poll = info;
+	int polling_interval;
+	int polling_interval_us;
+	struct sched_param param;
+
+	polling_interval = device_poll->interval;
+
+	/* If we got changed to interrupt mode before the polling thread
+	   started. */
+	if (unlikely(0 >= polling_interval)) {
+		while (!kthread_should_stop())
+			usleep(1);
+		return -EINTR;
+	}
+
+	polling_interval_us = polling_interval * 1000;
+
+	param.sched_priority = device_poll->priority;
+	sched_setscheduler(current, device_poll->policy, &param);
+
+	while (!kthread_should_stop()) {
+		/* Ensure changes to device_poll->enabled made on other CPUs
+		   are seen here. */
+		smp_rmb();
+		if (device_poll->enabled)
+			device_poll->ops->interrupt(device_poll);
+
+		if (20 > polling_interval)
+			usleep_range(polling_interval_us, polling_interval_us);
+		else
+			msleep(polling_interval);
+	}
+
+	return 0;
+}
+
+/* device_poll external functions */
+
+int device_poll_init(struct device_poll *device_poll)
+{
+	int ret;
+
+	if (!device_poll || !device_poll->device || !device_poll->ops)
+		return -EINVAL;
+
+	if (!device_poll->ops->reinit || !device_poll->ops->lock ||
+	    !device_poll->ops->unlock || !device_poll->ops->interrupt)
+		return -EINVAL;
+
+	if (device_poll->use_capability && !cap_valid(device_poll->capability))
+		return -EINVAL;
+
+	device_poll->task = NULL;
+	device_poll->enabled = 0;
+
+	device_poll->interval_attr.attr = dev_attr_interval;
+	device_poll->policy_attr.attr = dev_attr_policy;
+	device_poll->priority_attr.attr = dev_attr_priority;
+
+	device_poll->interval_attr.var = device_poll;
+	device_poll->policy_attr.var = device_poll;
+	device_poll->priority_attr.var = device_poll;
+
+	if (device_poll->use_capability) {
+		device_poll->interval_attr.attr.attr.mode |= S_IWUGO;
+		device_poll->policy_attr.attr.attr.mode |= S_IWUGO;
+		device_poll->priority_attr.attr.attr.mode |= S_IWUGO;
+	}
+
+	sysfs_attr_init(&device_poll->interval_attr.attr.attr);
+	sysfs_attr_init(&device_poll->policy_attr.attr.attr);
+	sysfs_attr_init(&device_poll->priority_attr.attr.attr);
+
+	device_poll->attrs[0] = &device_poll->interval_attr.attr.attr;
+	device_poll->attrs[1] = &device_poll->policy_attr.attr.attr;
+	device_poll->attrs[2] = &device_poll->priority_attr.attr.attr;
+	device_poll->attrs[3] = NULL;
+
+	device_poll->attr_group.name = "device_poll";
+	device_poll->attr_group.attrs = device_poll->attrs;
+
+	ret = sysfs_create_group(&device_poll->device->kobj,
+				 &device_poll->attr_group);
+	if (ret)
+		device_poll_exit(device_poll);
+
+	return ret;
+}
+EXPORT_SYMBOL(device_poll_init);
+
+void device_poll_exit(struct device_poll *device_poll)
+{
+	if (!device_poll || !device_poll->device)
+		return;
+
+	sysfs_remove_group(&device_poll->device->kobj,
+			   &device_poll->attr_group);
+}
+EXPORT_SYMBOL(device_poll_exit);
+
+int device_poll_request_irq(struct device_poll *device_poll)
+{
+	int err;
+
+	if (!device_poll)
+		return -EINVAL;
+
+	/* If interrupts are enabled. */
+	if (device_poll->interval <= 0)
+		return -ERANGE;
+
+	/* Start up the polling thread. */
+	device_poll->task = kthread_run(device_poll_thread,
+					device_poll, "poll/%s",
+					dev_name(device_poll->device));
+	if (IS_ERR(device_poll->task)) {
+		err = PTR_ERR(device_poll->task);
+		device_poll->task = NULL;
+		dev_err(device_poll->device,
+			"Unable to create polling thread: %d\n", err);
+		return err;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(device_poll_request_irq);
+
+void device_poll_free_irq(struct device_poll *device_poll)
+{
+	if (device_poll_is_active(device_poll)) {
+		kthread_stop(device_poll->task);
+		device_poll->task = NULL;
+	}
+}
+EXPORT_SYMBOL(device_poll_free_irq);
diff --git a/include/linux/device_poll.h b/include/linux/device_poll.h
new file mode 100644
index 0000000..846a3b4
--- /dev/null
+++ b/include/linux/device_poll.h
@@ -0,0 +1,105 @@
+/*
+ * Copyright (C) 2014 National Instruments Corp.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _LINUX_DEVICE_POLL_H_
+#define _LINUX_DEVICE_POLL_H_
+
+#ifdef CONFIG_DEVICE_POLL
+
+#include <linux/device.h>
+
+struct device_poll;
+
+struct device_poll_ops {
+	/* Reinitialize, if the mode changes. */
+	int (*reinit)(struct device_poll *device_poll);
+
+	/* Lock and unlock, for consistency when changing settings. */
+	void (*lock)(struct device_poll *device_poll);
+	void (*unlock)(struct device_poll *device_poll);
+
+	/* Polled interrupt handler. */
+	void (*interrupt)(struct device_poll *device_poll);
+};
+
+struct device_poll {
+	/* The following must be initialized by the driver before calling
+	   device_poll_init. */
+
+	/* The device for which we're polling. */
+	struct device *device;
+
+	/* Device operations. */
+	struct device_poll_ops *ops;
+
+	/* A capability can be specified to allow non-root users to modify
+	   the sysfs attributes. */
+	bool use_capability;
+	int capability;
+
+	/* Polling interval in milliseconds. A value of 0 or less means
+	   use interrupts. */
+	int interval;
+
+	/* Polling task policy and priority, such as SCHED_FIFO 10. */
+	int policy;
+	int priority;
+
+	/* The following are internal struct members and should not be touched
+	   by drivers. */
+
+	struct task_struct *task;
+	int enabled;
+
+	struct dev_ext_attribute interval_attr;
+	struct dev_ext_attribute policy_attr;
+	struct dev_ext_attribute priority_attr;
+	struct attribute *attrs[4];
+	struct attribute_group attr_group;
+};
+
+int device_poll_init(struct device_poll *device_poll);
+void device_poll_exit(struct device_poll *device_poll);
+
+int device_poll_request_irq(struct device_poll *device_poll);
+void device_poll_free_irq(struct device_poll *device_poll);
+
+static inline int device_poll_is_active(struct device_poll *device_poll)
+{
+	return likely(device_poll) && (device_poll->task != NULL);
+}
+
+static inline void device_poll_enable_irq(struct device_poll *device_poll)
+{
+	if (device_poll_is_active(device_poll)) {
+		device_poll->enabled = 1;
+		/* Ensure changes to device_poll->enabled are seen by the
+		   polling thread. */
+		smp_wmb();
+	}
+}
+
+static inline void device_poll_disable_irq(struct device_poll *device_poll)
+{
+	if (device_poll_is_active(device_poll)) {
+		device_poll->enabled = 0;
+		/* Ensure changes to device_poll->enabled are seen by the
+		   polling thread. */
+		smp_wmb();
+	}
+}
+
+#endif
+
+#endif /* _LINUX_DEVICE_POLL_H_ */
-- 
1.9.1
