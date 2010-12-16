From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V7 3/8] posix clocks: introduce dynamic clocks
Date: Thu, 16 Dec 2010 16:43:11 +0100
Message-ID: <8debe4d48d9a6484b7fbd35d8888524155fed977.1292512461.git.richard.cochran@omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:43449 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447Ab0LPPnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 10:43:19 -0500
Content-Disposition: inline
In-Reply-To: <cover.1292512461.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for adding and removing posix clocks. The
clock lifetime cycle is patterned after usb devices. Each clock is
represented by a standard character device. In addition, the driver
may optionally implemented custom character device operations.

The dynamic posix clocks do not yet do anything useful. This patch
merely provides some needed infrastructure.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/posix-clock.h |  111 ++++++++++++++++++++++
 kernel/time/Makefile        |    3 +-
 kernel/time/posix-clock.c   |  217 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 330 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/posix-clock.h
 create mode 100644 kernel/time/posix-clock.c

diff --git a/include/linux/posix-clock.h b/include/linux/posix-clock.h
new file mode 100644
index 0000000..1ce7fb7
--- /dev/null
+++ b/include/linux/posix-clock.h
@@ -0,0 +1,111 @@
+/*
+ * posix-clock.h - support for dynamic clock devices
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _LINUX_POSIX_CLOCK_H_
+#define _LINUX_POSIX_CLOCK_H_
+
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/posix-timers.h>
+
+/**
+ * struct posix_clock_fops - character device operations
+ *
+ * Every posix clock is represented by a character device. Drivers may
+ * optionally offer extended capabilities by implementing these
+ * functions. The character device file operations are first handled
+ * by the clock device layer, then passed on to the driver by calling
+ * these functions.
+ *
+ * The clock device layer already uses fp->private_data, so drivers
+ * are provided their private data via the 'priv' paramenter.
+ */
+void *posix_clock_private(struct file *fp);
+
+struct posix_clock_fops {
+	int (*fasync)  (void *priv, int fd, struct file *file, int on);
+	int (*mmap)    (void *priv, struct vm_area_struct *vma);
+	int (*open)    (void *priv, fmode_t f_mode);
+	int (*release) (void *priv);
+	long (*ioctl)  (void *priv, unsigned int cmd, unsigned long arg);
+	long (*compat_ioctl) (void *priv, unsigned int cmd, unsigned long arg);
+	ssize_t (*read) (void *priv, uint flags, char __user *buf, size_t cnt);
+	unsigned int (*poll) (void *priv, struct file *file, poll_table *wait);
+};
+
+/**
+ * struct posix_clock_operations - functional interface to the clock
+ * @owner: The clock driver should set to THIS_MODULE.
+ * @fops:           Optional custom character device operations
+ * @clock_adjtime:  Adjust the clock
+ * @clock_gettime:  Read the current time
+ * @clock_getres:   Get the clock resolution
+ * @clock_settime:  Set the current time value
+ * @timer_create:   Create a new timer
+ * @timer_delete:   Remove a previously created timer
+ * @timer_gettime:  Get remaining time and interval of a timer
+ * @timer_setttime: Set a timer's initial expiration and interval
+ */
+struct posix_clock_operations {
+	struct module *owner;
+	struct posix_clock_fops fops;
+	int  (*clock_adjtime)(void *priv, struct timex *tx);
+	int  (*clock_gettime)(void *priv, struct timespec *ts);
+	int  (*clock_getres) (void *priv, struct timespec *ts);
+	int  (*clock_settime)(void *priv, const struct timespec *ts);
+	int  (*timer_create) (void *priv, struct k_itimer *kit);
+	int  (*timer_delete) (void *priv, struct k_itimer *kit);
+	void (*timer_gettime)(void *priv, struct k_itimer *kit,
+			      struct itimerspec *tsp);
+	int  (*timer_settime)(void *priv, struct k_itimer *kit, int flags,
+			      struct itimerspec *tsp, struct itimerspec *old);
+};
+
+/**
+ * struct posix_clock - an opaque type
+ */
+struct posix_clock;
+
+/**
+ * posix_clock_create() - register a new clock
+ * @cops:  Pointer to the clock's interface
+ * @devid: Allocated device id
+ * @priv:  Private data passed back to the driver via the interface functions
+ *
+ * A clock driver calls this function to register itself with the
+ * clock device subsystem. The 'cops' argument must point to
+ * persistent data, so the caller should pass a static global.
+ *
+ * Returns a pointer to a new clock device, or PTR_ERR on error.
+ */
+struct posix_clock *posix_clock_create(struct posix_clock_operations *cops,
+				       dev_t devid, void *priv);
+
+/**
+ * posix_clock_destroy() - unregister a clock
+ * @clk:    Pointer obtained via posix_clock_create()
+ *
+ * A clock driver calls this function to remove itself from the clock
+ * device subsystem. The posix_clock itself will remain (in an
+ * inactive state) until its reference count drops to zero, at which
+ * point it will be deallocated.
+ */
+void posix_clock_destroy(struct posix_clock *clk);
+
+#endif
diff --git a/kernel/time/Makefile b/kernel/time/Makefile
index ee26662..bb3c9b8 100644
--- a/kernel/time/Makefile
+++ b/kernel/time/Makefile
@@ -1,4 +1,5 @@
-obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o timecompare.o timeconv.o
+obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o \
+timecompare.o timeconv.o posix-clock.o
 
 obj-$(CONFIG_GENERIC_CLOCKEVENTS_BUILD)		+= clockevents.o
 obj-$(CONFIG_GENERIC_CLOCKEVENTS)		+= tick-common.o
diff --git a/kernel/time/posix-clock.c b/kernel/time/posix-clock.c
new file mode 100644
index 0000000..e5924c9
--- /dev/null
+++ b/kernel/time/posix-clock.c
@@ -0,0 +1,217 @@
+/*
+ * posix-clock.c - support for dynamic clock devices
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include <linux/cdev.h>
+#include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/posix-clock.h>
+#include <linux/slab.h>
+
+#define MAX_CLKDEV BITS_PER_LONG
+static DECLARE_BITMAP(clocks_map, MAX_CLKDEV);
+static DEFINE_MUTEX(clocks_mutex); /* protects 'clocks_map' */
+
+struct posix_clock {
+	struct posix_clock_operations *ops;
+	struct cdev cdev;
+	struct kref kref;
+	struct mutex mux;
+	void *priv;
+	int index;
+	bool zombie;
+};
+
+static void delete_clock(struct kref *kref);
+
+static ssize_t posix_clock_read(struct file *fp, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	if (clk->ops->fops.read)
+		return clk->ops->fops.read(clk->priv, fp->f_flags, buf, count);
+	else
+		return -EINVAL;
+}
+
+static unsigned int posix_clock_poll(struct file *fp, poll_table *wait)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	if (clk->ops->fops.poll)
+		return clk->ops->fops.poll(clk->priv, fp, wait);
+	else
+		return 0;
+}
+
+static int posix_clock_fasync(int fd, struct file *fp, int on)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	if (clk->ops->fops.fasync)
+		return clk->ops->fops.fasync(clk->priv, fd, fp, on);
+	else
+		return 0;
+}
+
+static int posix_clock_mmap(struct file *fp, struct vm_area_struct *vma)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	if (clk->ops->fops.mmap)
+		return clk->ops->fops.mmap(clk->priv, vma);
+	else
+		return -ENODEV;
+}
+
+static long posix_clock_ioctl(struct file *fp,
+			      unsigned int cmd, unsigned long arg)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	if (clk->ops->fops.ioctl)
+		return clk->ops->fops.ioctl(clk->priv, cmd, arg);
+	else
+		return -ENOTTY;
+}
+
+#ifdef CONFIG_COMPAT
+static long posix_clock_compat_ioctl(struct file *fp,
+				     unsigned int cmd, unsigned long arg)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	if (clk->ops->fops.compat_ioctl)
+		return clk->ops->fops.compat_ioctl(clk->priv, cmd, arg);
+	else
+		return -ENOTTY;
+}
+#endif
+
+static int posix_clock_open(struct inode *inode, struct file *fp)
+{
+	struct posix_clock *clk =
+		container_of(inode->i_cdev, struct posix_clock, cdev);
+
+	kref_get(&clk->kref);
+	fp->private_data = clk;
+
+	if (clk->ops->fops.open)
+		return clk->ops->fops.open(clk->priv, fp->f_mode);
+	else
+		return 0;
+}
+
+static int posix_clock_release(struct inode *inode, struct file *fp)
+{
+	struct posix_clock *clk = fp->private_data;
+	int err = 0;
+
+	if (clk->ops->fops.release)
+		err = clk->ops->fops.release(clk->priv);
+
+	kref_put(&clk->kref, delete_clock);
+
+	return err;
+}
+
+static const struct file_operations posix_clock_file_operations = {
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.read		= posix_clock_read,
+	.poll		= posix_clock_poll,
+	.unlocked_ioctl	= posix_clock_ioctl,
+	.open		= posix_clock_open,
+	.release	= posix_clock_release,
+	.fasync		= posix_clock_fasync,
+	.mmap		= posix_clock_mmap,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= posix_clock_compat_ioctl,
+#endif
+};
+
+struct posix_clock *posix_clock_create(struct posix_clock_operations *cops,
+				       dev_t devid, void *priv)
+{
+	struct posix_clock *clk;
+	int err;
+
+	mutex_lock(&clocks_mutex);
+
+	err = -ENOMEM;
+	clk = kzalloc(sizeof(*clk), GFP_KERNEL);
+	if (!clk)
+		goto no_memory;
+
+	err = -EBUSY;
+	clk->index = find_first_zero_bit(clocks_map, MAX_CLKDEV);
+	if (clk->index < MAX_CLKDEV)
+		set_bit(clk->index, clocks_map);
+	else
+		goto no_index;
+
+	clk->ops = cops;
+	clk->priv = priv;
+	kref_init(&clk->kref);
+	mutex_init(&clk->mux);
+
+	cdev_init(&clk->cdev, &posix_clock_file_operations);
+	clk->cdev.owner = clk->ops->owner;
+	err = cdev_add(&clk->cdev, devid, 1);
+	if (err)
+		goto no_cdev;
+
+	mutex_unlock(&clocks_mutex);
+	return clk;
+
+no_cdev:
+	mutex_destroy(&clk->mux);
+	clear_bit(clk->index, clocks_map);
+no_index:
+	kfree(clk);
+no_memory:
+	mutex_unlock(&clocks_mutex);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(posix_clock_create);
+
+static void delete_clock(struct kref *kref)
+{
+	struct posix_clock *clk =
+		container_of(kref, struct posix_clock, kref);
+
+	mutex_lock(&clocks_mutex);
+	clear_bit(clk->index, clocks_map);
+	mutex_unlock(&clocks_mutex);
+
+	mutex_destroy(&clk->mux);
+	kfree(clk);
+}
+
+void posix_clock_destroy(struct posix_clock *clk)
+{
+	cdev_del(&clk->cdev);
+
+	mutex_lock(&clk->mux);
+	clk->zombie = true;
+	mutex_unlock(&clk->mux);
+
+	kref_put(&clk->kref, delete_clock);
+}
+EXPORT_SYMBOL_GPL(posix_clock_destroy);
-- 
1.7.0.4

