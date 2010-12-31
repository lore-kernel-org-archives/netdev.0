From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V8 09/13] posix clocks: introduce dynamic clocks
Date: Fri, 31 Dec 2010 20:15:57 +0100
Message-ID: <c28004fc5d121c1dd5f842550663fc9d6f55a114.1293820862.git.richard.cochran@omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1293820862.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for adding and removing posix clocks. The
clock lifetime cycle is patterned after usb devices. Each clock is
represented by a standard character device. In addition, the driver
may optionally implemented custom character device operations.

The posix clock and timer system calls listed below now work with
dynamic posix clocks, as well as the traditional static clocks.
For the performance critical calls (eg clock_gettime) the code path
from the traditional static clocks is preserved.

The following system calls are affected:

   - clock_adjtime (brand new syscall)
   - clock_gettime
   - clock_getres
   - clock_settime
   - timer_create
   - timer_delete
   - timer_gettime
   - timer_settime

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 include/linux/posix-clock.h        |  137 +++++++++++
 include/linux/posix-timers.h       |    5 +-
 kernel/posix-timers.c              |   19 +-
 kernel/time/Makefile               |    3 +-
 kernel/time/posix-clock-syscalls.h |   39 +++
 kernel/time/posix-clock.c          |  454 ++++++++++++++++++++++++++++++++++++
 6 files changed, 648 insertions(+), 9 deletions(-)
 create mode 100644 include/linux/posix-clock.h
 create mode 100644 kernel/time/posix-clock-syscalls.h
 create mode 100644 kernel/time/posix-clock.c

diff --git a/include/linux/posix-clock.h b/include/linux/posix-clock.h
new file mode 100644
index 0000000..b8e3356
--- /dev/null
+++ b/include/linux/posix-clock.h
@@ -0,0 +1,137 @@
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
+ * struct posix_clock_operations - functional interface to the clock
+ *
+ * Every posix clock is represented by a character device. Drivers may
+ * optionally offer extended capabilities by implementing the
+ * character device methods. The character device file operations are
+ * first handled by the clock device layer, then passed on to the
+ * driver by calling these functions.
+ *
+ * Drivers should embed their posix_clock_operations within a private
+ * structure, obtaining a reference to it using container_of().
+ *
+ * @owner:          The clock driver should set to THIS_MODULE
+ * @clock_adjtime:  Adjust the clock
+ * @clock_gettime:  Read the current time
+ * @clock_getres:   Get the clock resolution
+ * @clock_settime:  Set the current time value
+ * @timer_create:   Create a new timer
+ * @timer_delete:   Remove a previously created timer
+ * @timer_gettime:  Get remaining time and interval of a timer
+ * @timer_setttime: Set a timer's initial expiration and interval
+ * @fasync:         Optional character device fasync method
+ * @mmap:           Optional character device mmap method
+ * @open:           Optional character device open method
+ * @release:        Optional character device release method
+ * @ioctl:          Optional character device ioctl method
+ * @read:           Optional character device read method
+ * @poll:           Optional character device poll method
+ */
+struct posix_clock_operations {
+	struct module *owner;
+
+	int  (*clock_adjtime)(struct posix_clock_operations *pc,
+			      struct timex *tx);
+
+	int  (*clock_gettime)(struct posix_clock_operations *pc,
+			      struct timespec *ts);
+
+	int  (*clock_getres) (struct posix_clock_operations *pc,
+			      struct timespec *ts);
+
+	int  (*clock_settime)(struct posix_clock_operations *pc,
+			      const struct timespec *ts);
+
+	int  (*timer_create) (struct posix_clock_operations *pc,
+			      struct k_itimer *kit);
+
+	int  (*timer_delete) (struct posix_clock_operations *pc,
+			      struct k_itimer *kit);
+
+	void (*timer_gettime)(struct posix_clock_operations *pc,
+			      struct k_itimer *kit, struct itimerspec *tsp);
+
+	int  (*timer_settime)(struct posix_clock_operations *pc,
+			      struct k_itimer *kit, int flags,
+			      struct itimerspec *tsp, struct itimerspec *old);
+	/*
+	 * Optional character device methods:
+	 */
+	int     (*fasync)  (struct posix_clock_operations *pc,
+			    int fd, struct file *file, int on);
+
+	long    (*ioctl)   (struct posix_clock_operations *pc,
+			    unsigned int cmd, unsigned long arg);
+
+	int     (*mmap)    (struct posix_clock_operations *pc,
+			    struct vm_area_struct *vma);
+
+	int     (*open)    (struct posix_clock_operations *pc, fmode_t f_mode);
+
+	uint    (*poll)    (struct posix_clock_operations *pc,
+			    struct file *file, poll_table *wait);
+
+	int     (*release) (struct posix_clock_operations *pc);
+
+	ssize_t (*read)    (struct posix_clock_operations *pc,
+			    uint flags, char __user *buf, size_t cnt);
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
+struct posix_clock *posix_clock_create(struct posix_clock_operations *pc,
+				       dev_t devid);
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
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index eef7f9c..1544482 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -33,7 +33,7 @@ struct cpu_timer_list {
 #define CPUCLOCK_PID(clock)		((pid_t) ~((clock) >> 3))
 #define CPUCLOCK_PERTHREAD(clock) \
 	(((clock) & (clockid_t) CPUCLOCK_PERTHREAD_MASK) != 0)
-#define CPUCLOCK_PID_MASK	7
+
 #define CPUCLOCK_PERTHREAD_MASK	4
 #define CPUCLOCK_WHICH(clock)	((clock) & (clockid_t) CPUCLOCK_CLOCK_MASK)
 #define CPUCLOCK_CLOCK_MASK	3
@@ -49,6 +49,9 @@ struct cpu_timer_list {
 #define MAKE_THREAD_CPUCLOCK(tid, clock) \
 	MAKE_PROCESS_CPUCLOCK((tid), (clock) | CPUCLOCK_PERTHREAD_MASK)
 
+#define FD_TO_CLOCKID(fd)	((~(clockid_t) (fd) << 3) | CLOCKFD)
+#define CLOCKID_TO_FD(clk)	((unsigned int) ~((clk) >> 3))
+
 /* POSIX.1b interval timer structure. */
 struct k_itimer {
 	struct list_head list;		/* free/ allocate list */
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 65b0599..9a92aef 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -41,12 +41,15 @@
 #include <linux/init.h>
 #include <linux/compiler.h>
 #include <linux/idr.h>
+#include <linux/posix-clock.h>
 #include <linux/posix-timers.h>
 #include <linux/syscalls.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
 #include <linux/module.h>
 
+#include "time/posix-clock-syscalls.h"
+
 /*
  * Management arrays for POSIX timers.	 Timers are kept in slab memory
  * Timer ids are allocated by an external routine that keeps track of the
@@ -545,7 +548,7 @@ static inline int dispatch_clock_getres(const clockid_t id, struct timespec *ts)
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_clock_getres(id, ts);
 
-	return -EINVAL;
+	return pc_clock_getres(id, ts);
 }
 
 static inline int dispatch_clock_set(const clockid_t id, struct timespec *ts)
@@ -558,7 +561,7 @@ static inline int dispatch_clock_set(const clockid_t id, struct timespec *ts)
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_clock_set(id, ts);
 
-	return -EINVAL;
+	return pc_clock_settime(id, ts);
 }
 
 static inline int dispatch_clock_get(const clockid_t id, struct timespec *ts)
@@ -571,7 +574,7 @@ static inline int dispatch_clock_get(const clockid_t id, struct timespec *ts)
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_clock_get(id, ts);
 
-	return -EINVAL;
+	return pc_clock_gettime(id, ts);
 }
 
 static inline int dispatch_clock_adj(const clockid_t id, struct timex *tx)
@@ -584,7 +587,7 @@ static inline int dispatch_clock_adj(const clockid_t id, struct timex *tx)
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_clock_adj(id, tx);
 
-	return -EINVAL;
+	return pc_clock_adjtime(id, tx);
 }
 
 static inline int dispatch_timer_create(struct k_itimer *kit)
@@ -599,7 +602,7 @@ static inline int dispatch_timer_create(struct k_itimer *kit)
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_timer_create(kit);
 
-	return -EINVAL;
+	return pc_timer_create(kit);
 }
 
 static inline int dispatch_nsleep(const clockid_t id, int flags,
@@ -647,7 +650,7 @@ static inline int dispatch_timer_set(struct k_itimer *kit, int flags,
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_timer_set(kit, flags, tsp, old);
 
-	return -EINVAL;
+	return pc_timer_settime(kit, flags, tsp, old);
 }
 
 static inline int dispatch_timer_del(struct k_itimer *kit)
@@ -662,7 +665,7 @@ static inline int dispatch_timer_del(struct k_itimer *kit)
 	if (clock_is_posix_cpu(id))
 		return posix_cpu_timer_del(kit);
 
-	return -EINVAL;
+	return pc_timer_delete(kit);
 }
 
 static inline void dispatch_timer_get(struct k_itimer *kit,
@@ -677,6 +680,8 @@ static inline void dispatch_timer_get(struct k_itimer *kit,
 	else if (clock_is_posix_cpu(id))
 
 		posix_cpu_timer_get(kit, tsp);
+	else
+		pc_timer_gettime(kit, tsp);
 }
 
 #define CLOCK_DISPATCH(clock, call, arglist) dispatch_##call arglist
diff --git a/kernel/time/Makefile b/kernel/time/Makefile
index ee26662..b042599 100644
--- a/kernel/time/Makefile
+++ b/kernel/time/Makefile
@@ -1,4 +1,5 @@
-obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o timecompare.o timeconv.o
+obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o timecompare.o
+obj-y += timeconv.o posix-clock.o
 
 obj-$(CONFIG_GENERIC_CLOCKEVENTS_BUILD)		+= clockevents.o
 obj-$(CONFIG_GENERIC_CLOCKEVENTS)		+= tick-common.o
diff --git a/kernel/time/posix-clock-syscalls.h b/kernel/time/posix-clock-syscalls.h
new file mode 100644
index 0000000..6afa204
--- /dev/null
+++ b/kernel/time/posix-clock-syscalls.h
@@ -0,0 +1,39 @@
+/*
+ * posix-clock-syscalls.h - support for dynamic clock devices
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
+#ifndef _POSIX_CLOCK_SYSCALLS_H_
+#define _POSIX_CLOCK_SYSCALLS_H_
+
+#include <linux/posix-timers.h>
+
+/*
+ * The following functions are only to be called from posix-timers.c
+ */
+
+int  pc_clock_adjtime(clockid_t id, struct timex *tx);
+int  pc_clock_gettime(clockid_t id, struct timespec *ts);
+int  pc_clock_getres(clockid_t id, struct timespec *ts);
+int  pc_clock_settime(clockid_t id, const struct timespec *ts);
+int  pc_timer_create(struct k_itimer *kt);
+int  pc_timer_delete(struct k_itimer *kt);
+void pc_timer_gettime(struct k_itimer *kt, struct itimerspec *ts);
+int  pc_timer_settime(struct k_itimer *kt, int flags,
+		      struct itimerspec *ts, struct itimerspec *old);
+
+#endif
diff --git a/kernel/time/posix-clock.c b/kernel/time/posix-clock.c
new file mode 100644
index 0000000..a34f183
--- /dev/null
+++ b/kernel/time/posix-clock.c
@@ -0,0 +1,454 @@
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
+#include <linux/file.h>
+#include <linux/mutex.h>
+#include <linux/posix-clock.h>
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/uaccess.h>
+
+#include "posix-clock-syscalls.h"
+
+struct posix_clock {
+	struct posix_clock_operations *ops;
+	struct cdev cdev;
+	struct kref kref;
+	/* Protects the 'zombie' field from concurrent access. */
+	struct mutex mutex;
+	/* If 'zombie' is true, then the hardware has disappeared. */
+	bool zombie;
+};
+
+static void delete_clock(struct kref *kref);
+
+/*
+ * Returns NULL if the posix_clock instance attached to 'fp' is old and stale.
+ */
+static struct posix_clock *get_posix_clock(struct file *fp)
+{
+	struct posix_clock *clk = fp->private_data;
+
+	mutex_lock(&clk->mutex);
+
+	if (!clk->zombie)
+		return clk;
+
+	mutex_unlock(&clk->mutex);
+
+	return NULL;
+}
+
+static void put_posix_clock(struct posix_clock *clk)
+{
+	mutex_unlock(&clk->mutex);
+}
+
+static ssize_t posix_clock_read(struct file *fp, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct posix_clock *clk = get_posix_clock(fp);
+	int err = -EINVAL;
+
+	if (!clk)
+		return -ENODEV;
+
+	if (clk->ops->read)
+		err = clk->ops->read(clk->ops, fp->f_flags, buf, count);
+
+	put_posix_clock(clk);
+
+	return err;
+}
+
+static unsigned int posix_clock_poll(struct file *fp, poll_table *wait)
+{
+	struct posix_clock *clk = get_posix_clock(fp);
+	int result = 0;
+
+	if (!clk)
+		return -ENODEV;
+
+	if (clk->ops->poll)
+		result = clk->ops->poll(clk->ops, fp, wait);
+
+	put_posix_clock(clk);
+
+	return result;
+}
+
+static int posix_clock_fasync(int fd, struct file *fp, int on)
+{
+	struct posix_clock *clk = get_posix_clock(fp);
+	int err = 0;
+
+	if (!clk)
+		return -ENODEV;
+
+	if (clk->ops->fasync)
+		err = clk->ops->fasync(clk->ops, fd, fp, on);
+
+	put_posix_clock(clk);
+
+	return err;
+}
+
+static int posix_clock_mmap(struct file *fp, struct vm_area_struct *vma)
+{
+	struct posix_clock *clk = get_posix_clock(fp);
+	int err = -ENODEV;
+
+	if (!clk)
+		return -ENODEV;
+
+	if (clk->ops->mmap)
+		err = clk->ops->mmap(clk->ops, vma);
+
+	put_posix_clock(clk);
+
+	return err;
+}
+
+static long posix_clock_ioctl(struct file *fp,
+			      unsigned int cmd, unsigned long arg)
+{
+	struct posix_clock *clk = get_posix_clock(fp);
+	int err = -ENOTTY;
+
+	if (!clk)
+		return -ENODEV;
+
+	if (clk->ops->ioctl)
+		err = clk->ops->ioctl(clk->ops, cmd, arg);
+
+	put_posix_clock(clk);
+
+	return err;
+}
+
+#ifdef CONFIG_COMPAT
+static long posix_clock_compat_ioctl(struct file *fp,
+				     unsigned int cmd, unsigned long arg)
+{
+	struct posix_clock *clk = get_posix_clock(fp);
+	int err = -ENOTTY;
+
+	if (!clk)
+		return -ENODEV;
+
+	if (clk->ops->ioctl)
+		err = clk->ops->ioctl(clk->ops, cmd, arg);
+
+	put_posix_clock(clk);
+
+	return err;
+}
+#endif
+
+static int posix_clock_open(struct inode *inode, struct file *fp)
+{
+	int err;
+	struct posix_clock *clk =
+		container_of(inode->i_cdev, struct posix_clock, cdev);
+
+	mutex_lock(&clk->mutex);
+
+	if (clk->zombie) {
+		err = -ENODEV;
+		goto out;
+	}
+	if (clk->ops->open)
+		err = clk->ops->open(clk->ops, fp->f_mode);
+	else
+		err = 0;
+
+	if (!err) {
+		kref_get(&clk->kref);
+		fp->private_data = clk;
+	}
+out:
+	mutex_unlock(&clk->mutex);
+	return err;
+}
+
+static int posix_clock_release(struct inode *inode, struct file *fp)
+{
+	struct posix_clock *clk = fp->private_data;
+	int err = 0;
+
+	if (clk->ops->release)
+		err = clk->ops->release(clk->ops);
+
+	kref_put(&clk->kref, delete_clock);
+
+	fp->private_data = NULL;
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
+struct posix_clock *posix_clock_create(struct posix_clock_operations *pc,
+				       dev_t devid)
+{
+	struct posix_clock *clk;
+	int err;
+
+	err = -ENOMEM;
+	clk = kzalloc(sizeof(*clk), GFP_KERNEL);
+	if (!clk)
+		goto no_memory;
+
+	clk->ops = pc;
+	kref_init(&clk->kref);
+	mutex_init(&clk->mutex);
+
+	cdev_init(&clk->cdev, &posix_clock_file_operations);
+	clk->cdev.owner = clk->ops->owner;
+	err = cdev_add(&clk->cdev, devid, 1);
+	if (err)
+		goto no_cdev;
+
+	return clk;
+
+no_cdev:
+	mutex_destroy(&clk->mutex);
+	kfree(clk);
+no_memory:
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(posix_clock_create);
+
+static void delete_clock(struct kref *kref)
+{
+	struct posix_clock *clk = container_of(kref, struct posix_clock, kref);
+	mutex_destroy(&clk->mutex);
+	kfree(clk);
+}
+
+void posix_clock_destroy(struct posix_clock *clk)
+{
+	cdev_del(&clk->cdev);
+
+	mutex_lock(&clk->mutex);
+	clk->zombie = true;
+	mutex_unlock(&clk->mutex);
+
+	kref_put(&clk->kref, delete_clock);
+}
+EXPORT_SYMBOL_GPL(posix_clock_destroy);
+
+struct posix_clock_desc {
+	struct file *fp;
+	struct posix_clock *clk;
+};
+
+static int get_clock_desc(const clockid_t id, struct posix_clock_desc *cd)
+{
+	struct file *fp = fget(CLOCKID_TO_FD(id));
+	int err = -EINVAL;
+
+	if (!fp)
+		return err;
+
+	if (fp->f_op->open != posix_clock_open || !fp->private_data)
+		goto out;
+
+	cd->fp = fp;
+	cd->clk = get_posix_clock(fp);
+
+	err = cd->clk ? 0 : -ENODEV;
+out:
+	if (err)
+		fput(fp);
+	return err;
+}
+
+static void put_clock_desc(struct posix_clock_desc *cd)
+{
+	put_posix_clock(cd->clk);
+	fput(cd->fp);
+}
+
+int pc_clock_adjtime(clockid_t id, struct timex *tx)
+{
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->clock_adjtime)
+		err = cd.clk->ops->clock_adjtime(cd.clk->ops, tx);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
+
+int pc_clock_gettime(clockid_t id, struct timespec *ts)
+{
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->clock_gettime)
+		err = cd.clk->ops->clock_gettime(cd.clk->ops, ts);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
+
+int pc_clock_getres(clockid_t id, struct timespec *ts)
+{
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->clock_getres)
+		err = cd.clk->ops->clock_getres(cd.clk->ops, ts);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
+
+int pc_clock_settime(clockid_t id, const struct timespec *ts)
+{
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->clock_settime)
+		err = cd.clk->ops->clock_settime(cd.clk->ops, ts);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
+
+int pc_timer_create(struct k_itimer *kit)
+{
+	clockid_t id = kit->it_clock;
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->timer_create)
+		err = cd.clk->ops->timer_create(cd.clk->ops, kit);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
+
+int pc_timer_delete(struct k_itimer *kit)
+{
+	clockid_t id = kit->it_clock;
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->timer_delete)
+		err = cd.clk->ops->timer_delete(cd.clk->ops, kit);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
+
+void pc_timer_gettime(struct k_itimer *kit, struct itimerspec *ts)
+{
+	clockid_t id = kit->it_clock;
+	struct posix_clock_desc cd;
+
+	if (get_clock_desc(id, &cd))
+		return;
+
+	if (cd.clk->ops->timer_gettime)
+		cd.clk->ops->timer_gettime(cd.clk->ops, kit, ts);
+
+	put_clock_desc(&cd);
+}
+
+int pc_timer_settime(struct k_itimer *kit, int flags,
+		     struct itimerspec *ts, struct itimerspec *old)
+{
+	clockid_t id = kit->it_clock;
+	struct posix_clock_desc cd;
+	int err;
+
+	err = get_clock_desc(id, &cd);
+	if (err)
+		return err;
+
+	if (cd.clk->ops->timer_settime)
+		err = cd.clk->ops->timer_settime(cd.clk->ops,
+						 kit, flags, ts, old);
+	else
+		err = -EOPNOTSUPP;
+
+	put_clock_desc(&cd);
+
+	return err;
+}
-- 
1.7.0.4
