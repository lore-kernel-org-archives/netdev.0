From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 29 Apr 2010 11:19:36 +0200
Message-ID: <20100429091936.GA6703@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:17720 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932210Ab0D3Q4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:56:54 -0400
Received: by fg-out-1718.google.com with SMTP id 19so4458437fgg.1
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 09:56:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an infrastructure for hardware clocks that implement
IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
registration method to particular hardware clock drivers. Each clock is
exposed to user space as a character device with ioctls that allow tuning
of the PTP clock.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 Documentation/ptp/ptp.txt        |   78 ++++++++++
 Documentation/ptp/testptp.c      |  130 ++++++++++++++++
 Documentation/ptp/testptp.mk     |   33 ++++
 drivers/Kconfig                  |    2 +
 drivers/Makefile                 |    1 +
 drivers/ptp/Kconfig              |   26 ++++
 drivers/ptp/Makefile             |    5 +
 drivers/ptp/ptp_clock.c          |  302 ++++++++++++++++++++++++++++++++++++++
 include/linux/Kbuild             |    1 +
 include/linux/ptp_clock.h        |   37 +++++
 include/linux/ptp_clock_kernel.h |  134 +++++++++++++++++
 11 files changed, 749 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h

diff --git a/Documentation/ptp/ptp.txt b/Documentation/ptp/ptp.txt
new file mode 100644
index 0000000..35dc01a
--- /dev/null
+++ b/Documentation/ptp/ptp.txt
@@ -0,0 +1,78 @@
+
+* PTP infrastructure for Linux
+
+  This patch set introduces support for IEEE 1588 PTP clocks in
+  Linux. Together with the SO_TIMESTAMPING socket options, this
+  presents standardized method for developing PTP user space programs,
+  synchronizing Linux with external clocks, and using the ancillary
+  features of PTP hardware clocks.
+
+  A new class driver exports a kernel interface for specific clock
+  drivers and a user space interface. The infrastructure supports a
+  complete set of PTP functionality.
+
+  + Basic clock operations
+    - Set time
+    - Get time
+    - Shift the clock by a given offset atomically
+    - Adjust clock frequency
+
+  + Ancillary clock features
+    - One short or periodic alarms, with signal delivery to user program
+    - Time stamp external events
+    - Period output signals configurable from user space
+    - Synchronization of the Linux system time via the PPS subsystem
+
+** PTP kernel API
+
+   A PTP clock driver registers itself with the class driver. The
+   class driver handles all of the dealings with user space. The
+   author of a clock driver need only implement the details of
+   programming the clock hardware. The clock driver notifies the class
+   driver of asynchronous events (alarms and external time stamps) via
+   a simple message passing interface.
+
+   The class driver supports multiple PTP clock drivers. In normal use
+   cases, only one PTP clock is needed. However, for testing and
+   development, it can be useful to have more than one clock in a
+   single system, in order to allow performance comparisons.
+
+** PTP user space API
+
+   The class driver creates a character device for each registered PTP
+   clock. User space programs may control the clock via standardized
+   ioctls. A program may query, enable, configure, and disable the
+   ancillary clock features. User space can receive time stamped
+   events via blocking read() and poll(). One shot and periodic
+   signals may be configured via an ioctl API with similar semantics
+   to the POSIX timer_settime() system call.
+
+   As an real life example, the following two patches for ptpd version
+   1.0.0 demonstrate how the API works.
+
+   https://sourceforge.net/tracker/?func=detail&aid=2992845&group_id=139814&atid=744634
+
+   https://sourceforge.net/tracker/?func=detail&aid=2992847&group_id=139814&atid=744634
+
+** Supported hardware
+
+   + Standard Linux system timer
+     - No special PTP features
+     - For use with software time stamping
+
+   + Freescale eTSEC gianfar
+     - 2 Time stamp external triggers, programmable polarity (opt. interrupt)
+     - 2 Alarm registers (optional interrupt)
+     - 3 Periodic signals (optional interrupt)
+
+   + National DP83640
+     - 6 GPIOs programmable as inputs or outputs
+     - 6 GPIOs with dedicated functions (LED/JTAG/clock) can also be
+       used as general inputs or outputs
+     - GPIO inputs can time stamp external triggers
+     - GPIO outputs can produce periodic signals
+     - 1 interrupt pin
+
+   + Intel IXP465
+     - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
+     - Target Time (optional interrupt)
diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
new file mode 100644
index 0000000..d3ad918
--- /dev/null
+++ b/Documentation/ptp/testptp.c
@@ -0,0 +1,130 @@
+/*
+ * PTP 1588 clock support - User space test program
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
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/types.h>
+#include <time.h>
+#include <unistd.h>
+
+#include <linux/ptp_clock.h>
+
+static void usage (char* progname)
+{
+	fprintf(stderr,
+		"usage: %s [options] \n"
+		" -d name    device to open \n"
+		" -f val     adjust the ptp clock frequency by 'val' PPB \n"
+		" -g         get the ptp clock time \n"
+		" -h         prints this message \n"
+		" -s         set the ptp clock time from the system time \n"
+		" -t val     shift the ptp clock time by 'val' seconds \n"
+		" -v         query the ptp clock api version \n"
+		,progname);
+}
+
+int main(int argc,char *argv[])
+{
+	struct timespec ts;
+	char *progname;
+	int c, fd, val=0;
+
+	char *device = "/dev/ptp_clock_0";
+	int adjfreq=0x7fffffff;
+	int adjtime=0;
+	int gettime=0;
+	int settime=0;
+	int version=0;
+
+	progname = strrchr(argv[0],'/');
+	progname = progname ? 1+progname : argv[0];
+	while (EOF != (c = getopt(argc, argv, "d:f:ghst:v"))) {
+		switch (c) {
+		case 'd': device = optarg; break;
+		case 'f': adjfreq = atoi(optarg); break;
+		case 'g': gettime = 1; break;
+		case 's': settime = 1; break;
+		case 't': adjtime = atoi(optarg); break;
+		case 'v': version = 1; break;
+		case 'h': usage(progname); return 0;
+		case '?': usage(progname); return -1;
+		default:  usage(progname); return -1;
+		}
+	}
+
+	fd = open(device, O_RDWR);
+	if (fd < 0) {
+		fprintf(stderr,"cannot open %s: %s", device, strerror(errno));
+		return -1;
+	}
+
+	if (version) {
+		if (ioctl(fd, PTP_CLOCK_APIVERS, &val)) {
+			perror("PTP_CLOCK_APIVERS");
+		} else {
+			printf("version = 0x%08x \n",val);
+		}
+	}
+
+	if (0x7fffffff != adjfreq) {
+		if (ioctl(fd, PTP_CLOCK_ADJFREQ, adjfreq)) {
+			perror("PTP_CLOCK_ADJFREQ");
+		} else {
+			puts("frequency adjustment okay");
+		}
+	}
+
+	if (adjtime) {
+		ts.tv_sec = adjtime;
+		ts.tv_nsec = 0;
+		if (ioctl(fd, PTP_CLOCK_ADJTIME, &ts)) {
+			perror("PTP_CLOCK_ADJTIME");
+		} else {
+			puts("time shift okay");
+		}
+	}
+
+	if (gettime) {
+		if (ioctl(fd, PTP_CLOCK_GETTIME, &ts)) {
+			perror("PTP_CLOCK_GETTIME");
+		} else {
+			printf("clock time: %ld.%09ld or %s",
+			       ts.tv_sec, ts.tv_nsec, ctime(&ts.tv_sec));
+		}
+	}
+
+	if (settime) {
+		clock_gettime(CLOCK_REALTIME, &ts);
+		if (ioctl(fd, PTP_CLOCK_SETTIME, &ts)) {
+			perror("PTP_CLOCK_SETTIME");
+		} else {
+			puts("set time okay");
+		}
+	}
+
+	close(fd);
+	return 0;
+}
diff --git a/Documentation/ptp/testptp.mk b/Documentation/ptp/testptp.mk
new file mode 100644
index 0000000..4ef2d97
--- /dev/null
+++ b/Documentation/ptp/testptp.mk
@@ -0,0 +1,33 @@
+# PTP 1588 clock support - User space test program
+#
+# Copyright (C) 2010 OMICRON electronics GmbH
+#
+#  This program is free software; you can redistribute it and/or modify
+#  it under the terms of the GNU General Public License as published by
+#  the Free Software Foundation; either version 2 of the License, or
+#  (at your option) any later version.
+#
+#  This program is distributed in the hope that it will be useful,
+#  but WITHOUT ANY WARRANTY; without even the implied warranty of
+#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+#  GNU General Public License for more details.
+#
+#  You should have received a copy of the GNU General Public License
+#  along with this program; if not, write to the Free Software
+#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+
+CC        = $(CROSS_COMPILE)gcc
+INC       = -I$(KBUILD_OUTPUT)/usr/include
+CFLAGS    = -Wall $(INC)
+LDLIBS    = -lrt
+PROGS     = testptp
+
+all: $(PROGS)
+
+testptp: testptp.o
+
+clean:
+	rm -f testptp.o
+
+distclean: clean
+	rm -f $(PROGS)
diff --git a/drivers/Kconfig b/drivers/Kconfig
index a2b902f..774fbd7 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -52,6 +52,8 @@ source "drivers/spi/Kconfig"
 
 source "drivers/pps/Kconfig"
 
+source "drivers/ptp/Kconfig"
+
 source "drivers/gpio/Kconfig"
 
 source "drivers/w1/Kconfig"
diff --git a/drivers/Makefile b/drivers/Makefile
index 34f1e10..7dea7c8 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -74,6 +74,7 @@ obj-$(CONFIG_I2O)		+= message/
 obj-$(CONFIG_RTC_LIB)		+= rtc/
 obj-y				+= i2c/ media/
 obj-$(CONFIG_PPS)		+= pps/
+obj-$(CONFIG_PTP_1588_CLOCK)	+= ptp/
 obj-$(CONFIG_W1)		+= w1/
 obj-$(CONFIG_POWER_SUPPLY)	+= power/
 obj-$(CONFIG_HWMON)		+= hwmon/
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
new file mode 100644
index 0000000..c80a25b
--- /dev/null
+++ b/drivers/ptp/Kconfig
@@ -0,0 +1,26 @@
+#
+# PTP clock support configuration
+#
+
+menu "PTP clock support"
+
+config PTP_1588_CLOCK
+	tristate "PTP clock support"
+	depends on EXPERIMENTAL
+	help
+	  The IEEE 1588 standard defines a method to precisely
+	  synchronize distributed clocks over Ethernet networks. The
+	  standard defines a Precision Time Protocol (PTP), which can
+	  be used to achieve synchronization within a few dozen
+	  microseconds. In addition, with the help of special hardware
+	  time stamping units, it can be possible to achieve
+	  synchronization to within a few hundred nanoseconds.
+
+	  This driver adds support for PTP clocks as character
+	  devices. If you want to use a PTP clock, then you should
+	  also enable at least one clock driver as well.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ptp_clock.
+
+endmenu
diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
new file mode 100644
index 0000000..b86695c
--- /dev/null
+++ b/drivers/ptp/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for PTP 1588 clock support.
+#
+
+obj-$(CONFIG_PTP_1588_CLOCK)		+= ptp_clock.o
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
new file mode 100644
index 0000000..a5acac4
--- /dev/null
+++ b/drivers/ptp/ptp_clock.c
@@ -0,0 +1,302 @@
+/*
+ * PTP 1588 clock support
+ *
+ * Partially adapted from the Linux PPS driver.
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
+#include <linux/bitops.h>
+#include <linux/cdev.h>
+#include <linux/device.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/poll.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+
+#include <linux/ptp_clock_kernel.h>
+#include <linux/ptp_clock.h>
+
+#define PTP_MAX_CLOCKS BITS_PER_LONG
+
+struct ptp_clock {
+	struct list_head list;
+	struct cdev cdev;
+	struct device *dev;
+	struct ptp_clock_info *info;
+	dev_t devid;
+	int index; /* index into clocks.map, also the minor number */
+	struct mutex mux; /* one process at a time on a device */
+};
+
+
+/* private globals */
+
+static const struct file_operations ptp_fops;
+static dev_t ptp_devt;
+static struct class *ptp_class;
+
+static struct {
+	struct list_head list;
+	DECLARE_BITMAP(map, PTP_MAX_CLOCKS);
+} clocks;
+static DEFINE_SPINLOCK(clocks_lock); /* protects 'clocks' */
+
+/* public interface */
+
+struct ptp_clock* ptp_clock_register(struct ptp_clock_info *info)
+{
+	struct ptp_clock *ptp;
+	int err = 0, index, major = MAJOR(ptp_devt);
+	unsigned long flags;
+
+	/* Find a free clock slot and reserve it. */
+	err = -EBUSY;
+	spin_lock_irqsave(&clocks_lock, flags);
+	index = find_first_zero_bit(clocks.map, PTP_MAX_CLOCKS);
+	if (index < PTP_MAX_CLOCKS) {
+		set_bit(index, clocks.map);
+		spin_unlock_irqrestore(&clocks_lock, flags);
+	} else {
+		spin_unlock_irqrestore(&clocks_lock, flags);
+		goto no_clock;
+	}
+
+	/* Initialize a clock structure. */
+	err = -ENOMEM;
+	ptp = kzalloc(sizeof(struct ptp_clock), GFP_KERNEL);
+	if (ptp == NULL)
+		goto no_memory;
+
+	ptp->info = info;
+	ptp->devid = MKDEV(major, index);
+	ptp->index = index;
+	mutex_init(&ptp->mux);
+
+	/* Create a new device in our class. */
+	ptp->dev = device_create(ptp_class, NULL, ptp->devid, ptp,
+				 "ptp_clock_%d", ptp->index);
+	if (IS_ERR(ptp->dev))
+		goto no_device;
+
+	dev_set_drvdata(ptp->dev, ptp);
+
+	/* Register a character device. */
+	cdev_init(&ptp->cdev, &ptp_fops);
+	ptp->cdev.owner = info->owner;
+	err = cdev_add(&ptp->cdev, ptp->devid, 1);
+	if (err)
+		goto no_cdev;
+
+	/* Clock is ready, add it into the list. */
+	spin_lock_irqsave(&clocks_lock, flags);
+	list_add(&ptp->list, &clocks.list);
+	spin_unlock_irqrestore(&clocks_lock, flags);
+
+	return ptp;
+
+no_cdev:
+	device_destroy(ptp_class, ptp->devid);
+no_device:
+	mutex_destroy(&ptp->mux);
+	kfree(ptp);
+no_memory:
+	spin_lock_irqsave(&clocks_lock, flags);
+	clear_bit(index, clocks.map);
+	spin_unlock_irqrestore(&clocks_lock, flags);
+no_clock:
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(ptp_clock_register);
+
+int ptp_clock_unregister(struct ptp_clock *ptp)
+{
+	unsigned long flags;
+
+	/* Release the clock's resources. */
+	cdev_del(&ptp->cdev);
+	device_destroy(ptp_class, ptp->devid);
+	mutex_destroy(&ptp->mux);
+
+	/* Remove the clock from the list. */
+	spin_lock_irqsave(&clocks_lock, flags);
+	list_del(&ptp->list);
+	clear_bit(ptp->index, clocks.map);
+	spin_unlock_irqrestore(&clocks_lock, flags);
+
+	kfree(ptp);
+
+	return 0;
+}
+EXPORT_SYMBOL(ptp_clock_unregister);
+
+void ptp_clock_event(struct ptp_clock_event event)
+{
+}
+EXPORT_SYMBOL(ptp_clock_event);
+
+/* character device operations */
+
+static int ptp_ioctl(struct inode *node, struct file *fp,
+		      unsigned int cmd, unsigned long arg)
+{
+	struct ptp_clock *ptp = fp->private_data;
+	struct ptp_clock_info *ops = ptp->info;
+	void *priv = ops->priv;
+	struct timespec ts;
+	int err = 0;
+
+	switch (cmd) {
+
+	case PTP_CLOCK_APIVERS:
+		err = put_user(PTP_CLOCK_VERSION, (u32 __user*)arg);
+		break;
+
+	case PTP_CLOCK_ADJFREQ:
+		err = ops->adjfreq(priv, arg);
+		break;
+
+	case PTP_CLOCK_ADJTIME:
+		if (copy_from_user(&ts, (void __user*)arg, sizeof(ts)))
+			err = -EFAULT;
+		else
+			err = ops->adjtime(priv, &ts);
+		break;
+
+	case PTP_CLOCK_GETTIME:
+		err = ops->gettime(priv, &ts);
+		if (err)
+			break;
+		err = copy_to_user((void __user*)arg, &ts, sizeof(ts));
+		break;
+
+	case PTP_CLOCK_SETTIME:
+		if (copy_from_user(&ts, (void __user*)arg, sizeof(ts)))
+			err = -EFAULT;
+		else
+			err = ops->settime(priv, &ts);
+		break;
+
+	default:
+		err = -ENOTTY;
+		break;
+	}
+	return err;
+}
+
+static int ptp_open(struct inode *inode, struct file *fp)
+{
+	struct ptp_clock *ptp;
+	ptp = container_of(inode->i_cdev, struct ptp_clock, cdev);
+
+	if (mutex_lock_interruptible(&ptp->mux))
+		return -ERESTARTSYS;
+
+	fp->private_data = ptp;
+
+	return 0;
+}
+
+static unsigned int ptp_poll(struct file *fp, poll_table *wait)
+{
+	return 0;
+}
+
+static int ptp_release(struct inode *inode, struct file *fp)
+{
+	struct ptp_clock *ptp = fp->private_data;
+	mutex_unlock(&ptp->mux);
+	return 0;
+}
+
+static const struct file_operations ptp_fops = {
+	.owner		= THIS_MODULE,
+	.ioctl		= ptp_ioctl,
+	.open		= ptp_open,
+	.poll		= ptp_poll,
+	.release	= ptp_release,
+};
+
+/* sysfs */
+
+static ssize_t ptp_show_status(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	return sprintf(buf,
+		       "maximum adjustment:  %d\n"
+		       "programmable alarms: %d\n"
+		       "external timestamps: %d\n"
+		       "periodic outputs:    %d\n"
+		       "has pps:             %d\n"
+		       "device index:        %d\n"
+		       ,ptp->info->max_adj
+		       ,ptp->info->n_alarm
+		       ,ptp->info->n_ext_ts
+		       ,ptp->info->n_per_out
+		       ,ptp->info->pps
+		       ,ptp->index);
+}
+
+struct device_attribute ptp_attrs[] = {
+	__ATTR(capabilities, S_IRUGO, ptp_show_status, NULL),
+	__ATTR_NULL,
+};
+
+/* module operations */
+
+static void __exit ptp_exit(void)
+{
+	class_destroy(ptp_class);
+	unregister_chrdev_region(ptp_devt, PTP_MAX_CLOCKS);
+}
+
+static int __init ptp_init(void)
+{
+	int err;
+
+	INIT_LIST_HEAD(&clocks.list);
+
+	ptp_class = class_create(THIS_MODULE, "ptp");
+	if (!ptp_class) {
+		printk(KERN_ERR "ptp: failed to allocate class\n");
+		return -ENOMEM;
+	}
+	ptp_class->dev_attrs = ptp_attrs;
+
+	err = alloc_chrdev_region(&ptp_devt, 0, PTP_MAX_CLOCKS, "ptp");
+	if (err < 0) {
+		printk(KERN_ERR "ptp: failed to allocate char device region\n");
+		goto no_region;
+	}
+
+	pr_info("PTP clock support registered\n");
+	return 0;
+
+no_region:
+	class_destroy(ptp_class);
+	return err;
+}
+
+subsys_initcall(ptp_init);
+module_exit(ptp_exit);
+
+MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_DESCRIPTION("PTP clocks support");
+MODULE_LICENSE("GPL");
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 2fc8e14..9959fe4 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -140,6 +140,7 @@ header-y += pkt_sched.h
 header-y += posix_types.h
 header-y += ppdev.h
 header-y += prctl.h
+header-y += ptp_clock.h
 header-y += qnxtypes.h
 header-y += qnx4_fs.h
 header-y += radeonfb.h
diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h
new file mode 100644
index 0000000..5064b19
--- /dev/null
+++ b/include/linux/ptp_clock.h
@@ -0,0 +1,37 @@
+/*
+ * PTP 1588 clock support - user space interface
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
+
+#ifndef _PTP_CLOCK_H_
+#define _PTP_CLOCK_H_
+
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+#define PTP_CLOCK_VERSION 0x00000001
+
+#define PTP_CLK_MAGIC '='
+
+#define PTP_CLOCK_APIVERS _IOR (PTP_CLK_MAGIC, 1, __u32)
+#define PTP_CLOCK_ADJFREQ _IO  (PTP_CLK_MAGIC, 2)
+#define PTP_CLOCK_ADJTIME _IOW (PTP_CLK_MAGIC, 3, struct timespec)
+#define PTP_CLOCK_GETTIME _IOR (PTP_CLK_MAGIC, 4, struct timespec)
+#define PTP_CLOCK_SETTIME _IOW (PTP_CLK_MAGIC, 5, struct timespec)
+
+#endif
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
new file mode 100644
index 0000000..d43bdd2
--- /dev/null
+++ b/include/linux/ptp_clock_kernel.h
@@ -0,0 +1,134 @@
+/*
+ * PTP 1588 clock support
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
+
+#ifndef _PTP_CLOCK_KERNEL_H_
+#define _PTP_CLOCK_KERNEL_H_
+
+enum ptp_clock_events {
+	PTP_CLOCK_ALARM,
+	PTP_CLOCK_EXTTS,
+	PTP_CLOCK_PEROUT,
+	PTP_CLOCK_PPS,
+};
+
+/**
+ * struct ptp_clock_request - parameter for the enable() operation
+ *
+ * @type:  One of the ptp_clock_events enumeration values.
+ * @index: Selects one resource of the given type.
+ * @ts:    Desired one shot or recurring period for alarms and output signals.
+ */
+
+struct ptp_clock_request {
+	int type;
+	int index;
+	struct itimerspec ts;
+};
+
+/**
+ * struct ptp_clock_info - decribes a PTP hardware clock
+ *
+ * @owner:     The clock driver should set to THIS_MODULE.
+ * @name:      A short name to identify the clock.
+ * @max_adj:   The maximum possible frequency adjustment, in parts per billon.
+ * @n_alarm:   The number of programmable alarms.
+ * @n_ext_ts:  The number of external time stamp channels.
+ * @n_per_out: The number of programmable periodic signals.
+ * @pps:       Indicates whether the clock supports a PPS callback.
+ * @priv:      Passed to the clock operations, for the driver's private use.
+ *
+ * clock operations
+ *
+ * @adjfreq: Adjusts the frequency of the hardware clock.
+ *           parameter delta: Desired period change in parts per billion.
+ *
+ * @adjtime: Shifts the time of the hardware clock.
+ *           parameter ts: Desired change in seconds and nanoseconds.
+ *
+ * @gettime: Reads the current time from the hardware clock.
+ *           parameter ts: Holds the result.
+ *
+ * @settime: Set the current time on the hardware clock.
+ *           parameter ts: Time value to set.
+ *
+ * @enable:  Request driver to enable or disable an ancillary feature.
+ *           parameter request: Desired resource to enable or disable.
+ *           parameter on: Caller passes one to enable or zero to disable.
+ *
+ * The callbacks must all return zero on success, non-zero otherwise.
+ */
+
+struct ptp_clock_info {
+	struct module *owner;
+	char name[16];
+	s32 max_adj;
+	int n_alarm;
+	int n_ext_ts;
+	int n_per_out;
+	int pps;
+	void *priv;
+	int (*adjfreq)(void *priv, s32 delta);
+	int (*adjtime)(void *priv, struct timespec *ts);
+	int (*gettime)(void *priv, struct timespec *ts);
+	int (*settime)(void *priv, struct timespec *ts);
+	int (*enable) (void *priv, struct ptp_clock_request request, int on);
+};
+
+struct ptp_clock;
+
+/**
+ * ptp_clock_register() - register a PTP hardware clock driver
+ *
+ * @info:  Structure describing the new clock.
+ */
+
+extern struct ptp_clock* ptp_clock_register(struct ptp_clock_info *info);
+
+/**
+ * ptp_clock_unregister() - unregister a PTP hardware clock driver
+ *
+ * @ptp:  The clock to remove from service.
+ */
+
+extern int ptp_clock_unregister(struct ptp_clock *ptp);
+
+/**
+ * struct ptp_clock_event - decribes a PTP hardware clock event
+ *
+ * @type:  One of the ptp_clock_events enumeration values.
+ * @index: Identifies the source of the event.
+ * @timestamp: When the event occured.
+ */
+
+struct ptp_clock_event {
+	int type;
+	int index;
+	u64 timestamp;
+};
+
+/**
+ * ptp_clock_event() - notify the PTP layer about an event
+ *
+ * @event:  Message structure describing the event.
+ */
+
+extern void ptp_clock_event(struct ptp_clock_event event);
+
+#endif
-- 
1.6.0.4

