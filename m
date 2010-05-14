From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 14 May 2010 18:45:29 +0200
Message-ID: <aa2a85799677c08001b152c2921d0e55d5693ffa.1273855017.git.richard.cochran@omicron.at>
References: <cover.1273855016.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59049 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0ENQpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 12:45:19 -0400
Received: by fxm6 with SMTP id 6so1700042fxm.19
        for <netdev@vger.kernel.org>; Fri, 14 May 2010 09:45:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1273855016.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an infrastructure for hardware clocks that implement
IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
registration method to particular hardware clock drivers. Each clock is
exposed to user space as a character device with ioctls that allow tuning
of the PTP clock.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 Documentation/ptp/ptp.txt        |   95 +++++++
 Documentation/ptp/testptp.c      |  245 ++++++++++++++++++
 Documentation/ptp/testptp.mk     |   33 +++
 drivers/Kconfig                  |    2 +
 drivers/Makefile                 |    1 +
 drivers/ptp/Kconfig              |   26 ++
 drivers/ptp/Makefile             |    5 +
 drivers/ptp/ptp_clock.c          |  512 ++++++++++++++++++++++++++++++++++++++
 include/linux/Kbuild             |    1 +
 include/linux/ptp_clock.h        |   79 ++++++
 include/linux/ptp_clock_kernel.h |  137 ++++++++++
 11 files changed, 1136 insertions(+), 0 deletions(-)
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
index 0000000..46858b3
--- /dev/null
+++ b/Documentation/ptp/ptp.txt
@@ -0,0 +1,95 @@
+
+* PTP infrastructure for Linux
+
+  This patch set introduces support for IEEE 1588 PTP clocks in
+  Linux. Together with the SO_TIMESTAMPING socket options, this
+  presents a standardized method for developing PTP user space
+  programs, synchronizing Linux with external clocks, and using the
+  ancillary features of PTP hardware clocks.
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
+   clock. User space programs may control the clock using standardized
+   ioctls. A program may query, enable, configure, and disable the
+   ancillary clock features. User space can receive time stamped
+   events via blocking read() and poll(). One shot and periodic
+   signals may be configured via an ioctl API with semantics similar
+   to the POSIX timer_settime() system call.
+
+   As an real life example, the following two patches for ptpd version
+   1.0.0 demonstrate how the API works.
+
+   https://sourceforge.net/tracker/?func=detail&aid=2992845&group_id=139814&atid=744634
+
+   https://sourceforge.net/tracker/?func=detail&aid=2992847&group_id=139814&atid=744634
+
+** Writing clock drivers
+
+   Clock drivers include include/linux/ptp_clock_kernel.h and register
+   themselves by presenting a 'struct ptp_clock_info' to the
+   registration method. Clock drivers must implement all of the
+   functions in the interface. If a clock does not offer a particular
+   ancillary feature, then the driver should just return -EOPNOTSUPP
+   from those functions.
+
+   Drivers must ensure that all of the methods in interface are
+   reentrant. Since most hardware implementations treat the time value
+   as a 64 bit integer accessed as two 32 bit registers, drivers
+   should use spin_lock_irqsave/spin_unlock_irqrestore to protect
+   against concurrent access. This locking cannot be accomplished in
+   class driver, since the lock may also be needed by the clock
+   driver's interrupt service routine.
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
index 0000000..ed2ceea
--- /dev/null
+++ b/Documentation/ptp/testptp.c
@@ -0,0 +1,245 @@
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
+#include <signal.h>
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
+static void handle_alarm(int s)
+{
+	printf("received signal %d \n", s);
+}
+
+static int install_handler(int signum, void (*handler)(int))
+{
+	struct sigaction action;
+	sigset_t mask;
+
+	/* Unblock the signal. */
+	sigemptyset(&mask);
+	sigaddset(&mask, signum);
+	sigprocmask(SIG_UNBLOCK, &mask, NULL);
+
+	/* Install the signal handler. */
+	action.sa_handler = handler;
+	action.sa_flags = 0;
+	sigemptyset(&action.sa_mask);
+	sigaction(signum, &action, NULL);
+
+	return 0;
+}
+
+static void usage (char* progname)
+{
+	fprintf(stderr,
+		"usage: %s [options] \n"
+		" -a val     request a one-shot alarm after 'val' seconds \n"
+		" -A val     request a periodic alarm every 'val' seconds \n"
+		" -c         query the ptp clock's capabilities \n"
+		" -d name    device to open \n"
+		" -e val     read 'val' external time stamp events \n"
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
+	struct ptp_clock_caps caps;
+	struct ptp_clock_timer timer;
+	struct ptp_extts_event event;
+	struct ptp_clock_request request;
+	struct timespec ts;
+	char *progname;
+	int c, cnt, fd, val=0;
+
+	char *device = "/dev/ptp_clock_0";
+	int adjfreq=0x7fffffff;
+	int adjtime=0;
+	int capabilities=0;
+	int extts=0;
+	int gettime=0;
+	int oneshot=0;
+	int periodic=0;
+	int settime=0;
+	int version=0;
+
+	progname = strrchr(argv[0],'/');
+	progname = progname ? 1+progname : argv[0];
+	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghst:v"))) {
+		switch (c) {
+		case 'a': oneshot = atoi(optarg); break;
+		case 'A': periodic = atoi(optarg); break;
+		case 'c': capabilities = 1; break;
+		case 'd': device = optarg; break;
+		case 'e': extts = atoi(optarg); break;
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
+	if (capabilities) {
+		if (ioctl(fd, PTP_CLOCK_GETCAPS, &caps)) {
+			perror("PTP_CLOCK_GETCAPS");
+		} else {
+			printf("capabilities: \n"
+			       "  %d maximum frequency adjustment (PPB) \n"
+			       "  %d programmable alarms \n"
+			       "  %d external time stamp channels \n"
+			       "  %d programmable periodic signals \n"
+			       "  %d pulse per second \n",
+			       caps.max_adj,
+			       caps.n_alarm,
+			       caps.n_ext_ts,
+			       caps.n_per_out,
+			       caps.pps);
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
+	if (extts) {
+		memset(&request, 0, sizeof(request));
+		request.type = PTP_REQUEST_EXTTS;
+		request.index = 0;
+		request.flags = PTP_ENABLE_FEATURE;
+		if (ioctl(fd, PTP_FEATURE_REQUEST, &request)) {
+			perror("PTP_FEATURE_REQUEST");
+			extts = 0;
+		} else {
+			puts("set timer okay");
+		}
+		for (; extts; extts--) {
+			cnt = read(fd, &event, sizeof(event));
+			if (cnt != sizeof(event)) {
+				perror("read");
+				break;
+			}
+			printf("event index %d at %ld.%09ld \n", event.index,
+			       event.ts.tv_sec, event.ts.tv_nsec);
+		}
+		/* Disable the feature again. */
+		request.flags = 0;
+		if (ioctl(fd, PTP_FEATURE_REQUEST, &request)) {
+			perror("PTP_FEATURE_REQUEST");
+		}
+	}
+
+	if (oneshot) {
+		install_handler(SIGALRM, handle_alarm);
+		memset(&timer, 0, sizeof(timer));
+		timer.signum = SIGALRM;
+		timer.tsp.it_value.tv_sec = oneshot;
+		if (ioctl(fd, PTP_CLOCK_SETTIMER, &timer)) {
+			perror("PTP_CLOCK_SETTIMER");
+		} else {
+			puts("set timer okay");
+		}
+		pause();
+	}
+
+	if (periodic) {
+		install_handler(SIGALRM, handle_alarm);
+		memset(&timer, 0, sizeof(timer));
+		timer.signum = SIGALRM;
+		timer.tsp.it_value.tv_sec = periodic;
+		timer.tsp.it_interval.tv_sec = periodic;
+		if (ioctl(fd, PTP_CLOCK_SETTIMER, &timer)) {
+			perror("PTP_CLOCK_SETTIMER");
+		} else {
+			puts("set timer okay");
+		}
+		while (1) {
+			pause();
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
index f42a030..84228bc 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -75,6 +75,7 @@ obj-$(CONFIG_I2O)		+= message/
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
index 0000000..1d94d31
--- /dev/null
+++ b/drivers/ptp/ptp_clock.c
@@ -0,0 +1,512 @@
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
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+
+#include <linux/ptp_clock_kernel.h>
+#include <linux/ptp_clock.h>
+
+#define PTP_MAX_ALARMS 4
+#define PTP_MAX_CLOCKS BITS_PER_LONG
+#define PTP_MAX_TIMESTAMPS 128
+
+struct alarm {
+	struct pid *pid;
+	int sig;
+};
+
+struct timestamp_event_queue {
+	struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
+	int head;
+	int tail;
+	int overflow;
+};
+
+struct ptp_clock {
+	struct list_head list;
+	struct cdev cdev;
+	struct device *dev;
+	struct ptp_clock_info *info;
+	dev_t devid;
+	int index; /* index into clocks.map, also the minor number */
+
+	struct alarm alarm[PTP_MAX_ALARMS];
+	struct mutex alarm_mux; /* one process at a time setting an alarm */
+
+	struct timestamp_event_queue tsevq; /* simple fifo for time stamps */
+	struct mutex tsevq_mux; /* one process at a time reading the fifo */
+	wait_queue_head_t tsev_wq;
+};
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
+/* time stamp event queue operations */
+
+static inline int queue_cnt(struct timestamp_event_queue *q)
+{	
+	int cnt = q->tail - q->head;
+	return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
+}
+
+static inline int queue_free(struct timestamp_event_queue *q)
+{
+	return PTP_MAX_TIMESTAMPS - queue_cnt(q) - 1;
+}
+
+static void enqueue_external_timestamp(struct timestamp_event_queue *queue,
+				       struct ptp_clock_event *src)
+{
+	struct ptp_extts_event *dst;
+	u32 remainder;
+
+	dst = &queue->buf[ queue->tail ];
+
+	dst->index = src->index;
+	dst->ts.tv_sec = div_u64_rem(src->timestamp, 1000000000, &remainder);
+	dst->ts.tv_nsec = remainder;
+
+	if (!queue_free(queue))
+		queue->overflow++;
+
+	queue->tail = (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
+}
+
+/* public interface */
+
+struct ptp_clock* ptp_clock_register(struct ptp_clock_info *info)
+{
+	struct ptp_clock *ptp;
+	int err = 0, index, major = MAJOR(ptp_devt);
+	unsigned long flags;
+
+	if (info->n_alarm > PTP_MAX_ALARMS)
+		return ERR_PTR(-EINVAL);
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
+	mutex_init(&ptp->alarm_mux);
+	mutex_init(&ptp->tsevq_mux);
+	init_waitqueue_head(&ptp->tsev_wq);
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
+	mutex_destroy(&ptp->alarm_mux);
+	mutex_destroy(&ptp->tsevq_mux);
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
+	mutex_destroy(&ptp->alarm_mux);
+	mutex_destroy(&ptp->tsevq_mux);
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
+void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *event)
+{
+	switch (event->type) {
+
+	case PTP_CLOCK_ALARM:
+		kill_pid(ptp->alarm[ event->index ].pid,
+			 ptp->alarm[ event->index ].sig, 1);
+		break;
+
+	case PTP_CLOCK_EXTTS:
+		enqueue_external_timestamp(&ptp->tsevq, event);
+		wake_up_interruptible(&ptp->tsev_wq);
+		break;
+
+	case PTP_CLOCK_PPS:
+		break;
+	}
+}
+EXPORT_SYMBOL(ptp_clock_event);
+
+/* character device operations */
+
+static int ptp_ioctl(struct inode *node, struct file *fp,
+		      unsigned int cmd, unsigned long arg)
+{
+	struct ptp_clock_caps caps;
+	struct ptp_clock_request req;
+	struct ptp_clock_timer timer;
+	struct ptp_clock *ptp = fp->private_data;
+	struct ptp_clock_info *ops = ptp->info;
+	void *priv = ops->priv;
+	struct timespec ts;
+	int flags, index;
+	int err = 0;
+
+	switch (cmd) {
+
+	case PTP_CLOCK_APIVERS:
+		err = put_user(PTP_CLOCK_VERSION, (u32 __user*)arg);
+		break;
+
+	case PTP_CLOCK_ADJFREQ:
+		if (!capable(CAP_SYS_TIME))
+			return -EPERM;
+		err = ops->adjfreq(priv, arg);
+		break;
+
+	case PTP_CLOCK_ADJTIME:
+		if (!capable(CAP_SYS_TIME))
+			return -EPERM;
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
+		if (!capable(CAP_SYS_TIME))
+			return -EPERM;
+		if (copy_from_user(&ts, (void __user*)arg, sizeof(ts)))
+			err = -EFAULT;
+		else
+			err = ops->settime(priv, &ts);
+		break;
+
+	case PTP_CLOCK_GETCAPS:
+		memset(&caps, 0, sizeof(caps));
+		caps.max_adj = ptp->info->max_adj;
+		caps.n_alarm = ptp->info->n_alarm;
+		caps.n_ext_ts = ptp->info->n_ext_ts;
+		caps.n_per_out = ptp->info->n_per_out;
+		caps.pps = ptp->info->pps;
+		err = copy_to_user((void __user*)arg, &caps, sizeof(caps));
+		break;
+
+	case PTP_CLOCK_GETTIMER:
+		if (copy_from_user(&timer, (void __user*)arg, sizeof(timer))) {
+			err = -EFAULT;
+			break;
+		}
+		index = timer.alarm_index;
+		if (index < 0 || index >= ptp->info->n_alarm) {
+			err = -EINVAL;
+			break;
+		}
+		err = ops->gettimer(priv, index, &timer.tsp);
+		if (err)
+			break;
+		err = copy_to_user((void __user*)arg, &timer, sizeof(timer));
+		break;
+
+	case PTP_CLOCK_SETTIMER:
+		if (copy_from_user(&timer, (void __user*)arg, sizeof(timer))) {
+			err = -EFAULT;
+			break;
+		}
+		index = timer.alarm_index;
+		if (index < 0 || index >= ptp->info->n_alarm) {
+			err = -EINVAL;
+			break;
+		}
+		if (!valid_signal(timer.signum))
+			return -EINVAL;
+		flags = timer.flags;
+		if (flags & (flags != TIMER_ABSTIME)) {
+			err = -EINVAL;
+			break;
+		}
+		if (mutex_lock_interruptible(&ptp->alarm_mux))
+			return -ERESTARTSYS;
+
+		if (ptp->alarm[index].pid)
+			put_pid(ptp->alarm[index].pid);
+
+		ptp->alarm[index].pid = get_pid(task_pid(current));
+		ptp->alarm[index].sig = timer.signum;
+		err = ops->settimer(priv, index, flags, &timer.tsp);
+
+		mutex_unlock(&ptp->alarm_mux);
+		break;
+
+	case PTP_FEATURE_REQUEST:
+		if (copy_from_user(&req, (void __user*)arg, sizeof(req))) {
+			err = -EFAULT;
+			break;
+		}
+		switch (req.type) {
+		case PTP_REQUEST_EXTTS:
+		case PTP_REQUEST_PEROUT:
+			break;
+		case PTP_REQUEST_PPS:
+			if (!capable(CAP_SYS_TIME))
+				return -EPERM;
+			break;
+		default:
+			err = -EINVAL;
+			break;
+		}
+		if (err)
+			break;
+		err = ops->enable(priv, &req,
+				  req.flags & PTP_ENABLE_FEATURE ? 1 : 0);
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
+	fp->private_data = ptp;
+
+	return 0;
+}
+
+static unsigned int ptp_poll(struct file *fp, poll_table *wait)
+{
+	struct ptp_clock *ptp = fp->private_data;
+
+	poll_wait(fp, &ptp->tsev_wq, wait);
+
+	return queue_cnt(&ptp->tsevq) ? POLLIN : 0;
+}
+
+static ssize_t ptp_read(struct file *fp, char __user *buf,
+			size_t cnt, loff_t *off)
+{
+	struct ptp_clock *ptp = fp->private_data;
+	struct timestamp_event_queue *queue = &ptp->tsevq;
+	struct ptp_extts_event *event;
+	size_t qcnt;
+
+	if (mutex_lock_interruptible(&ptp->tsevq_mux))
+		return -ERESTARTSYS;
+
+	cnt = cnt / sizeof(struct ptp_extts_event);
+
+	if (wait_event_interruptible(ptp->tsev_wq,
+				     (qcnt = queue_cnt(&ptp->tsevq)))) {
+		mutex_unlock(&ptp->tsevq_mux);
+		return -ERESTARTSYS;
+	}
+
+	if (cnt > qcnt)
+		cnt = qcnt;
+
+	event = &queue->buf[ queue->head ];
+
+	if (copy_to_user(buf, event, cnt * sizeof(struct ptp_extts_event))) {
+		mutex_unlock(&ptp->tsevq_mux);
+		return -EFAULT;
+	}
+	queue->head = (queue->head + cnt) % PTP_MAX_TIMESTAMPS;
+
+	mutex_unlock(&ptp->tsevq_mux);
+
+	return cnt * sizeof(struct ptp_extts_event);
+}
+
+static int ptp_release(struct inode *inode, struct file *fp)
+{
+	struct ptp_clock *ptp;
+	struct itimerspec ts = {{0,0},{0,0}};
+	int i;
+
+	ptp = container_of(inode->i_cdev, struct ptp_clock, cdev);
+
+	for (i = 0; i < ptp->info->n_alarm; i++) {
+		if (ptp->alarm[i].pid) {
+			ptp->info->settimer(ptp->info->priv, i, 0, &ts);
+			put_pid(ptp->alarm[i].pid);
+			ptp->alarm[i].pid = NULL;
+		}
+	}
+	return 0;
+}
+
+static const struct file_operations ptp_fops = {
+	.owner		= THIS_MODULE,
+	.ioctl		= ptp_ioctl,
+	.open		= ptp_open,
+	.poll		= ptp_poll,
+	.read		= ptp_read,
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
index 0000000..5a509c5
--- /dev/null
+++ b/include/linux/ptp_clock.h
@@ -0,0 +1,79 @@
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
+#define PTP_ENABLE_FEATURE (1<<0)
+#define PTP_RISING_EDGE    (1<<1)
+#define PTP_FALLING_EDGE   (1<<2)
+
+enum ptp_request_types {
+	PTP_REQUEST_EXTTS,
+	PTP_REQUEST_PEROUT,
+	PTP_REQUEST_PPS,
+};
+
+struct ptp_clock_caps {
+	__s32 max_adj; /* Maximum frequency adjustment, parts per billon. */
+	int n_alarm;   /* Number of programmable alarms. */
+	int n_ext_ts;  /* Number of external time stamp channels. */
+	int n_per_out; /* Number of programmable periodic signals. */
+	int pps;       /* Whether the clock supports a PPS callback. */
+};
+
+struct ptp_clock_timer {
+	int alarm_index;       /* Which alarm to query or configure. */
+	int signum;            /* Requested signal. */
+	int flags;             /* Zero or TIMER_ABSTIME, see TIMER_SETTIME(2) */
+	struct itimerspec tsp; /* See TIMER_SETTIME(2) */
+};
+
+struct ptp_clock_request {
+	int type;  /* One of the ptp_request_types enumeration values. */
+	int index; /* Which channel to configure. */
+	struct timespec ts; /* For period signals, the desired period. */
+	int flags; /* Bit field for PTP_ENABLE_FEATURE or other flags. */
+};
+
+struct ptp_extts_event {
+	int index;
+	struct timespec ts;
+};
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
+#define PTP_CLOCK_GETCAPS   _IOR  (PTP_CLK_MAGIC, 6, struct ptp_clock_caps)
+#define PTP_CLOCK_GETTIMER  _IOWR (PTP_CLK_MAGIC, 7, struct ptp_clock_timer)
+#define PTP_CLOCK_SETTIMER  _IOW  (PTP_CLK_MAGIC, 8, struct ptp_clock_timer)
+#define PTP_FEATURE_REQUEST _IOW  (PTP_CLK_MAGIC, 9, struct ptp_clock_request)
+
+#endif
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
new file mode 100644
index 0000000..b1fb2a7
--- /dev/null
+++ b/include/linux/ptp_clock_kernel.h
@@ -0,0 +1,137 @@
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
+#include <linux/ptp_clock.h>
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
+ * @adjfreq:  Adjusts the frequency of the hardware clock.
+ *            parameter delta: Desired period change in parts per billion.
+ *
+ * @adjtime:  Shifts the time of the hardware clock.
+ *            parameter ts: Desired change in seconds and nanoseconds.
+ *
+ * @gettime:  Reads the current time from the hardware clock.
+ *            parameter ts: Holds the result.
+ *
+ * @settime:  Set the current time on the hardware clock.
+ *            parameter ts: Time value to set.
+ *
+ * @gettimer: Reads the time remaining from the given timer.
+ *            parameter index: Which alarm to query.
+ *            parameter ts: Holds the result.
+ *
+ * @settimer: Arms the given timer for periodic or one shot operation.
+ *            parameter index: Which alarm to set.
+ *            parameter abs: TIMER_ABSTIME, or zero for relative timer.
+ *            parameter ts: Alarm time and period to set.
+ *
+ * @enable:   Request driver to enable or disable an ancillary feature.
+ *            parameter request: Desired resource to enable or disable.
+ *            parameter on: Caller passes one to enable or zero to disable.
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
+	int (*gettimer)(void *priv, int index, struct itimerspec *ts);
+	int (*settimer)(void *priv, int index, int abs, struct itimerspec *ts);
+	int (*enable)(void *priv, struct ptp_clock_request *request, int on);
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
+
+enum ptp_clock_events {
+	PTP_CLOCK_ALARM,
+	PTP_CLOCK_EXTTS,
+	PTP_CLOCK_PPS,
+};
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
+ * This function should only be called from interrupt context.
+ *
+ * @ptp:    The clock obtained from ptp_clock_register().
+ * @event:  Message structure describing the event.
+ */
+
+extern void ptp_clock_event(struct ptp_clock *ptp,
+			    struct ptp_clock_event *event);
+
+#endif
-- 
1.6.3.3

