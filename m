From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/8] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 23 Sep 2010 19:32:21 +0200
Message-ID: <4fc4b8b4efbff0ee9b37f5a72bf9e3168d0d4216.1285261535.git.richard.cochran@omicron.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
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
In-Reply-To: <cover.1285261533.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds an infrastructure for hardware clocks that implement
IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
registration method to particular hardware clock drivers. Each clock is
presented as a standard POSIX clock.

The ancillary clock features are exposed in two different ways, via
the sysfs and by a character device.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-ptp |  107 ++++++++++
 Documentation/ptp/ptp.txt           |   94 +++++++++
 Documentation/ptp/testptp.c         |  358 ++++++++++++++++++++++++++++++++
 Documentation/ptp/testptp.mk        |   33 +++
 drivers/Kconfig                     |    2 +
 drivers/Makefile                    |    1 +
 drivers/ptp/Kconfig                 |   27 +++
 drivers/ptp/Makefile                |    6 +
 drivers/ptp/ptp_chardev.c           |  178 ++++++++++++++++
 drivers/ptp/ptp_clock.c             |  382 +++++++++++++++++++++++++++++++++++
 drivers/ptp/ptp_private.h           |   64 ++++++
 drivers/ptp/ptp_sysfs.c             |  235 +++++++++++++++++++++
 include/linux/Kbuild                |    1 +
 include/linux/ptp_clock.h           |   79 +++++++
 include/linux/ptp_clock_kernel.h    |  139 +++++++++++++
 15 files changed, 1706 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-ptp
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_chardev.c
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_private.h
 create mode 100644 drivers/ptp/ptp_sysfs.c
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h

diff --git a/Documentation/ABI/testing/sysfs-ptp b/Documentation/ABI/testing/sysfs-ptp
new file mode 100644
index 0000000..47142ce
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-ptp
@@ -0,0 +1,107 @@
+What:		/sys/class/ptp/
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This directory contains files and directories
+		providing a standardized interface to the ancillary
+		features of PTP hardware clocks.
+
+What:		/sys/class/ptp/ptpN/
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This directory contains the attributes of the Nth PTP
+		hardware clock registered into the PTP class driver
+		subsystem.
+
+What:		/sys/class/ptp/ptpN/clock_id
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file contains the POSIX clock ID (a non-negative
+		integer) corresponding to the PTP hardware clock. This
+		value may be passed as the first argument to the POSIX
+		clock and timer system calls. See man CLOCK_GETRES(2)
+		and TIMER_CREATE(2).
+
+What:		/sys/class/ptp/ptpN/clock_name
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file contains the name of the PTP hardware clock
+		as a human readable string.
+
+What:		/sys/class/ptp/ptpN/max_adjustment
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file contains the PTP hardware clock's maximum
+		frequency adjustment value (a positive integer) in
+		parts per billion.
+
+What:		/sys/class/ptp/ptpN/n_alarms
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file contains the number of periodic or one shot
+		alarms offer by the PTP hardware clock.
+
+What:		/sys/class/ptp/ptpN/n_external_timestamps
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file contains the number of external timestamp
+		channels offered by the PTP hardware clock.
+
+What:		/sys/class/ptp/ptpN/n_periodic_outputs
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file contains the number of programmable periodic
+		output channels offered by the PTP hardware clock.
+
+What:		/sys/class/ptp/ptpN/pps_avaiable
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file indicates whether the PTP hardware clock
+		supports a Pulse Per Second to the host CPU. Reading
+		"1" means that the PPS is supported, while "0" means
+		not supported.
+
+What:		/sys/class/ptp/ptpN/extts_enable
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This write-only file enables or disables external
+		timestamps. To enable external timestamps, write the
+		channel index followed by a "1" into the file.
+		To disable external timestamps, write the channel
+		index followed by a "0" into the file.
+
+What:		/sys/class/ptp/ptpN/fifo
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This file provides timestamps on external events, in
+		the form of three integers: channel index, seconds,
+		and nanoseconds.
+
+What:		/sys/class/ptp/ptpN/period
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This write-only file enables or disables periodic
+		outputs. To enable a periodic output, write three
+		integers into the file: channel index, seconds, and
+		nanoseconds. To disable a periodic output, set seconds
+		and nanoseconds to zero.
+
+What:		/sys/class/ptp/ptpN/pps_enable
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+Description:
+		This write-only file enables or disables delivery of
+		PPS events to the Linux PPS subsystem. To enable PPS
+		events, write a "1" into the file. To disable events,
+		write a "0" into the file.
diff --git a/Documentation/ptp/ptp.txt b/Documentation/ptp/ptp.txt
new file mode 100644
index 0000000..d198772
--- /dev/null
+++ b/Documentation/ptp/ptp.txt
@@ -0,0 +1,94 @@
+
+* PTP hardware clock infrastructure for Linux
+
+  This patch set introduces support for IEEE 1588 PTP clocks in
+  Linux. Together with the SO_TIMESTAMPING socket options, this
+  presents a standardized method for developing PTP user space
+  programs, synchronizing Linux with external clocks, and using the
+  ancillary features of PTP hardware clocks.
+
+  A new class driver exports a kernel interface for specific clock
+  drivers and a user space interface. The infrastructure supports a
+  complete set of PTP hardware clock functionality.
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
+** PTP hardware clock kernel API
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
+** PTP hardware clock user space API
+
+   Each clock is presented as a POSIX clock id. User space can
+   discover the clock id by reading the appropriate sysfs file (see
+   Documentation/ABI/testing/sysfs-ptp for details). Using the clock
+   id, user space may call clock_gettime, clock_settime, and
+   clock_adjtime. These calls implement the basic clock operations.
+
+   The class driver also creates a character device for each
+   registered clock. User space programs may control the clock using
+   standardized ioctls. A program may query, enable, configure, and
+   disable the ancillary clock features. User space can receive time
+   stamped events via blocking read() and poll(). One shot and
+   periodic signals may be configured via the POSIX timer_settime()
+   system call.
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
index 0000000..1d907a9
--- /dev/null
+++ b/Documentation/ptp/testptp.c
@@ -0,0 +1,358 @@
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
+#include <math.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/timex.h>
+#include <sys/types.h>
+#include <time.h>
+#include <unistd.h>
+
+#include <linux/ptp_clock.h>
+
+#define DEVICE "/dev/ptp0"
+#define ATTRIBUTE "/sys/class/ptp/ptp0/clock_id"
+
+#ifndef ADJ_SETOFFSET
+#define ADJ_SETOFFSET 0x0040
+#endif
+
+#ifndef CLOCK_INVALID
+#define CLOCK_INVALID -1
+#endif
+
+/* When glibc offers the syscall, this will go away. */
+#include <sys/syscall.h>
+static int clock_adjtime(clockid_t id, struct timex *tx)
+{
+	return syscall(__NR_clock_adjtime, id, tx);
+}
+
+static clockid_t get_clockid(void)
+{
+	clockid_t id = CLOCK_INVALID;
+	FILE *fp = fopen(ATTRIBUTE, "r");
+	if (!fp) {
+		return CLOCK_INVALID;
+	}
+	if (1 != fscanf(fp, " %d", &id)) {
+		fprintf(stderr, "failed to scan clock id\n");
+	}
+	return id;
+}
+
+static void handle_alarm(int s)
+{
+	printf("received signal %d\n", s);
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
+static void usage(char *progname)
+{
+	fprintf(stderr,
+		"usage: %s [options]\n"
+		" -a val     request a one-shot alarm after 'val' seconds\n"
+		" -A val     request a periodic alarm every 'val' seconds\n"
+		" -c         query the ptp clock's capabilities\n"
+		" -d name    device to open\n"
+		" -e val     read 'val' external time stamp events\n"
+		" -f val     adjust the ptp clock frequency by 'val' PPB\n"
+		" -g         get the ptp clock time\n"
+		" -h         prints this message\n"
+		" -p val     enable output with a period of 'val' nanoseconds\n"
+		" -P val     enable or disable (val=1|0) the system clock PPS\n"
+		" -s         set the ptp clock time from the system time\n"
+		" -t val     shift the ptp clock time by 'val' seconds\n",
+		progname);
+}
+
+int main(int argc, char *argv[])
+{
+	struct ptp_clock_caps caps;
+	struct ptp_extts_event event;
+	struct ptp_extts_request extts_request;
+	struct ptp_perout_request perout_request;
+	struct timespec ts;
+	struct timex tx;
+
+	static timer_t timerid;
+	struct itimerspec timeout;
+	struct sigevent sigevent;
+
+	char *progname;
+	int c, cnt, fd;
+
+	char *device = DEVICE;
+	clockid_t clkid;
+	int adjfreq = 0x7fffffff;
+	int adjtime = 0;
+	int capabilities = 0;
+	int extts = 0;
+	int gettime = 0;
+	int oneshot = 0;
+	int periodic = 0;
+	int perout = -1;
+	int pps = -1;
+	int settime = 0;
+
+	progname = strrchr(argv[0], '/');
+	progname = progname ? 1+progname : argv[0];
+	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghp:P:st:v"))) {
+		switch (c) {
+		case 'a':
+			oneshot = atoi(optarg);
+			break;
+		case 'A':
+			periodic = atoi(optarg);
+			break;
+		case 'c':
+			capabilities = 1;
+			break;
+		case 'd':
+			device = optarg;
+			break;
+		case 'e':
+			extts = atoi(optarg);
+			break;
+		case 'f':
+			adjfreq = atoi(optarg);
+			break;
+		case 'g':
+			gettime = 1;
+			break;
+		case 'p':
+			perout = atoi(optarg);
+			break;
+		case 'P':
+			pps = atoi(optarg);
+			break;
+		case 's':
+			settime = 1;
+			break;
+		case 't':
+			adjtime = atoi(optarg);
+			break;
+		case 'h':
+			usage(progname);
+			return 0;
+		case '?':
+		default:
+			usage(progname);
+			return -1;
+		}
+	}
+
+	clkid = get_clockid();
+	if (CLOCK_INVALID == clkid) {
+		fprintf(stderr, "failed to read clock id\n");
+		return -1;
+	}
+
+	fd = open(device, O_RDWR);
+	if (fd < 0) {
+		fprintf(stderr, "cannot open %s: %s", device, strerror(errno));
+		return -1;
+	}
+
+	if (capabilities) {
+		if (ioctl(fd, PTP_CLOCK_GETCAPS, &caps)) {
+			perror("PTP_CLOCK_GETCAPS");
+		} else {
+			printf("capabilities:\n"
+			       "  %d maximum frequency adjustment (PPB)\n"
+			       "  %d programmable alarms\n"
+			       "  %d external time stamp channels\n"
+			       "  %d programmable periodic signals\n"
+			       "  %d pulse per second\n",
+			       caps.max_adj,
+			       caps.n_alarm,
+			       caps.n_ext_ts,
+			       caps.n_per_out,
+			       caps.pps);
+		}
+	}
+
+	if (0x7fffffff != adjfreq) {
+		memset(&tx, 0, sizeof(tx));
+		tx.modes = ADJ_FREQUENCY;
+		tx.freq = (long) (adjfreq * 65.536);
+		if (clock_adjtime(clkid, &tx)) {
+			perror("clock_adjtime");
+		} else {
+			puts("frequency adjustment okay");
+		}
+	}
+
+	if (adjtime) {
+		memset(&tx, 0, sizeof(tx));
+		tx.modes = ADJ_SETOFFSET;
+		tx.time.tv_sec = adjtime;
+		tx.time.tv_usec = 0;
+		if (clock_adjtime(clkid, &tx)) {
+			perror("clock_adjtime");
+		} else {
+			puts("time shift okay");
+		}
+	}
+
+	if (gettime) {
+		if (clock_gettime(clkid, &ts)) {
+			perror("clock_gettime");
+		} else {
+			printf("clock time: %ld.%09ld or %s",
+			       ts.tv_sec, ts.tv_nsec, ctime(&ts.tv_sec));
+		}
+	}
+
+	if (settime) {
+		clock_gettime(CLOCK_REALTIME, &ts);
+		if (clock_settime(clkid, &ts)) {
+			perror("clock_settime");
+		} else {
+			puts("set time okay");
+		}
+	}
+
+	if (extts) {
+		memset(&extts_request, 0, sizeof(extts_request));
+		extts_request.index = 0;
+		extts_request.flags = PTP_ENABLE_FEATURE;
+		if (ioctl(fd, PTP_EXTTS_REQUEST, &extts_request)) {
+			perror("PTP_EXTTS_REQUEST");
+			extts = 0;
+		} else {
+			puts("external time stamp request okay");
+		}
+		for (; extts; extts--) {
+			cnt = read(fd, &event, sizeof(event));
+			if (cnt != sizeof(event)) {
+				perror("read");
+				break;
+			}
+			printf("event index %u at %lld.%09u\n", event.index,
+			       event.t.sec, event.t.nsec);
+			fflush(stdout);
+		}
+		/* Disable the feature again. */
+		extts_request.flags = 0;
+		if (ioctl(fd, PTP_EXTTS_REQUEST, &extts_request)) {
+			perror("PTP_EXTTS_REQUEST");
+		}
+	}
+
+	if (oneshot) {
+		install_handler(SIGALRM, handle_alarm);
+		/* Create a timer. */
+		sigevent.sigev_notify = SIGEV_SIGNAL;
+		sigevent.sigev_signo = SIGALRM;
+		if (timer_create(clkid, &sigevent, &timerid)) {
+			perror("timer_create");
+			return -1;
+		}
+		/* Start the timer. */
+		memset(&timeout, 0, sizeof(timeout));
+		timeout.it_value.tv_sec = oneshot;
+		if (timer_settime(timerid, 0, &timeout, NULL)) {
+			perror("timer_settime");
+			return -1;
+		}
+		pause();
+		timer_delete(timerid);
+	}
+
+	if (periodic) {
+		install_handler(SIGALRM, handle_alarm);
+		/* Create a timer. */
+		sigevent.sigev_notify = SIGEV_SIGNAL;
+		sigevent.sigev_signo = SIGALRM;
+		if (timer_create(clkid, &sigevent, &timerid)) {
+			perror("timer_create");
+			return -1;
+		}
+		/* Start the timer. */
+		memset(&timeout, 0, sizeof(timeout));
+		timeout.it_interval.tv_sec = periodic;
+		timeout.it_value.tv_sec = periodic;
+		if (timer_settime(timerid, 0, &timeout, NULL)) {
+			perror("timer_settime");
+			return -1;
+		}
+		while (1) {
+			pause();
+		}
+		timer_delete(timerid);
+	}
+
+	if (perout >= 0) {
+		if (clock_gettime(clkid, &ts)) {
+			perror("clock_gettime");
+			return -1;
+		}
+		memset(&perout_request, 0, sizeof(perout_request));
+		perout_request.index = 0;
+		perout_request.start.sec = ts.tv_sec + 2;
+		perout_request.start.nsec = 0;
+		perout_request.period.sec = 0;
+		perout_request.period.nsec = perout;
+		if (ioctl(fd, PTP_PEROUT_REQUEST, &perout_request)) {
+			perror("PTP_PEROUT_REQUEST");
+		} else {
+			puts("periodic output request okay");
+		}
+	}
+
+	if (pps != -1) {
+		int enable = pps ? 1 : 0;
+		if (ioctl(fd, PTP_ENABLE_PPS, enable)) {
+			perror("PTP_ENABLE_PPS");
+		} else {
+			puts("pps for system time request okay");
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
index a2aea53..802d100 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -76,6 +76,7 @@ obj-$(CONFIG_I2O)		+= message/
 obj-$(CONFIG_RTC_LIB)		+= rtc/
 obj-y				+= i2c/ media/
 obj-$(CONFIG_PPS)		+= pps/
+obj-$(CONFIG_PTP_1588_CLOCK)	+= ptp/
 obj-$(CONFIG_W1)		+= w1/
 obj-$(CONFIG_POWER_SUPPLY)	+= power/
 obj-$(CONFIG_HWMON)		+= hwmon/
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
new file mode 100644
index 0000000..17be208
--- /dev/null
+++ b/drivers/ptp/Kconfig
@@ -0,0 +1,27 @@
+#
+# PTP clock support configuration
+#
+
+menu "PTP clock support"
+
+config PTP_1588_CLOCK
+	tristate "PTP clock support"
+	depends on EXPERIMENTAL
+	depends on PPS
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
+	  will be called ptp.
+
+endmenu
diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
new file mode 100644
index 0000000..480e2af
--- /dev/null
+++ b/drivers/ptp/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for PTP 1588 clock support.
+#
+
+ptp-y					:= ptp_clock.o ptp_chardev.o ptp_sysfs.o
+obj-$(CONFIG_PTP_1588_CLOCK)		+= ptp.o
diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
new file mode 100644
index 0000000..096da3b
--- /dev/null
+++ b/drivers/ptp/ptp_chardev.c
@@ -0,0 +1,178 @@
+/*
+ * PTP 1588 clock support - character device implementation.
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
+#include <linux/module.h>
+#include <linux/poll.h>
+#include <linux/sched.h>
+
+#include <ptp_private.h>
+
+static int ptp_open(struct inode *inode, struct file *fp)
+{
+	struct ptp_clock *ptp;
+
+	ptp = container_of(inode->i_cdev, struct ptp_clock, cdev);
+	fp->private_data = ptp;
+	return 0;
+}
+
+static long ptp_ioctl(struct file *fp, unsigned int cmd, unsigned long arg)
+{
+	struct ptp_clock_caps caps;
+	struct ptp_clock_request req;
+	struct ptp_clock *ptp = fp->private_data;
+	struct ptp_clock_info *ops = ptp->info;
+	void *priv = ops->priv;
+	int enable, err = 0;
+
+	switch (cmd) {
+
+	case PTP_CLOCK_GETCAPS:
+		memset(&caps, 0, sizeof(caps));
+		caps.max_adj = ptp->info->max_adj;
+		caps.n_alarm = ptp->info->n_alarm;
+		caps.n_ext_ts = ptp->info->n_ext_ts;
+		caps.n_per_out = ptp->info->n_per_out;
+		caps.pps = ptp->info->pps;
+		err = copy_to_user((void __user *)arg, &caps, sizeof(caps));
+		break;
+
+	case PTP_EXTTS_REQUEST:
+		if (copy_from_user(&req.extts, (void __user *)arg,
+				   sizeof(req.extts))) {
+			err = -EFAULT;
+			break;
+		}
+		if (req.extts.index >= ops->n_ext_ts) {
+			err = -EINVAL;
+			break;
+		}
+		req.type = PTP_CLK_REQ_EXTTS;
+		enable = req.extts.flags & PTP_ENABLE_FEATURE ? 1 : 0;
+		err = ops->enable(priv, &req, enable);
+		break;
+
+	case PTP_PEROUT_REQUEST:
+		if (copy_from_user(&req.perout, (void __user *)arg,
+				   sizeof(req.perout))) {
+			err = -EFAULT;
+			break;
+		}
+		if (req.perout.index >= ops->n_per_out) {
+			err = -EINVAL;
+			break;
+		}
+		req.type = PTP_CLK_REQ_PEROUT;
+		enable = req.perout.period.sec || req.perout.period.nsec;
+		err = ops->enable(priv, &req, enable);
+		break;
+
+	case PTP_ENABLE_PPS:
+		if (!capable(CAP_SYS_TIME))
+			return -EPERM;
+		req.type = PTP_CLK_REQ_PPS;
+		enable = arg ? 1 : 0;
+		err = ops->enable(priv, &req, enable);
+		break;
+
+	default:
+		err = -ENOTTY;
+		break;
+	}
+	return err;
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
+	event = &queue->buf[queue->head];
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
+	ptp = container_of(inode->i_cdev, struct ptp_clock, cdev);
+	return 0;
+}
+
+static const struct file_operations ptp_fops = {
+	.owner		= THIS_MODULE,
+	.unlocked_ioctl	= ptp_ioctl,
+	.open		= ptp_open,
+	.poll		= ptp_poll,
+	.read		= ptp_read,
+	.release	= ptp_release,
+};
+
+int ptp_register_chardev(struct ptp_clock *ptp)
+{
+	int err;
+
+	cdev_init(&ptp->cdev, &ptp_fops);
+	ptp->cdev.owner = ptp->info->owner;
+	err = cdev_add(&ptp->cdev, ptp->devid, 1);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+int ptp_unregister_chardev(struct ptp_clock *ptp)
+{
+	cdev_del(&ptp->cdev);
+	return 0;
+}
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
new file mode 100644
index 0000000..3a62a90
--- /dev/null
+++ b/drivers/ptp/ptp_clock.c
@@ -0,0 +1,382 @@
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
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/posix-timers.h>
+#include <linux/pps_kernel.h>
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/uaccess.h>
+
+#include <ptp_private.h>
+
+#define PTP_MAX_ALARMS 4
+#define PTP_MAX_CLOCKS (MAX_CLOCKS/2)
+#define PTP_PPS_DEFAULTS (PPS_CAPTUREASSERT | PPS_OFFSETASSERT)
+#define PTP_PPS_EVENT PPS_CAPTUREASSERT
+#define PTP_PPS_MODE (PTP_PPS_DEFAULTS | PPS_CANWAIT | PPS_TSFMT_TSPEC)
+
+/* private globals */
+
+extern struct device_attribute ptp_dev_attrs[]; /* see ptp_sysfs.c */
+static dev_t ptp_devt;
+static struct class *ptp_class;
+
+static struct {
+	struct list_head list;
+	DECLARE_BITMAP(map, PTP_MAX_CLOCKS);
+	struct ptp_clock *data[MAX_CLOCKS];
+} clocks;
+static DEFINE_MUTEX(clocks_mux); /* protects 'clocks' */
+
+static struct ptp_clock *clockid_to_ptpclock(const clockid_t clkid)
+{
+	return clocks.data[clkid];
+}
+
+/* time stamp event queue operations */
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
+	dst = &queue->buf[queue->tail];
+
+	dst->index = src->index;
+	dst->t.sec = div_u64_rem(src->timestamp, 1000000000, &remainder);
+	dst->t.nsec = remainder;
+
+	if (!queue_free(queue))
+		queue->overflow++;
+
+	queue->tail = (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
+}
+
+/* posix clock implementation */
+
+static int ptp_clock_getres(const clockid_t clkid, struct timespec *tp)
+{
+	return 1; /* always round timer functions to one nanosecond */
+}
+
+static int ptp_clock_set(const clockid_t clkid, struct timespec *tp)
+{
+	struct ptp_clock *ptp;
+	int err;
+
+	mutex_lock(&clocks_mux);
+	ptp = clockid_to_ptpclock(clkid);
+	err = ptp->info->settime(ptp->info->priv, tp);
+	mutex_unlock(&clocks_mux);
+	return err;
+}
+
+static int ptp_clock_get(const clockid_t clkid, struct timespec *tp)
+{
+	struct ptp_clock *ptp;
+	int err;
+
+	mutex_lock(&clocks_mux);
+	ptp = clockid_to_ptpclock(clkid);
+	err = ptp->info->gettime(ptp->info->priv, tp);
+	mutex_unlock(&clocks_mux);
+	return err;
+}
+
+static int ptp_clock_adj(const clockid_t clkid, struct timex *tx)
+{
+	struct ptp_clock *ptp;
+	struct ptp_clock_info *ops;
+	int err = -ENODEV;
+
+	mutex_lock(&clocks_mux);
+	ptp = clockid_to_ptpclock(clkid);
+	if (!ptp)
+		goto out;
+	ops = ptp->info;
+	err = -EOPNOTSUPP;
+
+	if (tx->modes & ADJ_SETOFFSET) {
+		struct timespec ts;
+		ts.tv_sec = tx->time.tv_sec;
+		ts.tv_nsec = tx->modes & ADJ_NANO ? tx->time.tv_usec :
+			tx->time.tv_usec * 1000;
+		err = ops->adjtime(ops->priv, &ts);
+
+	} else if (tx->modes & ADJ_FREQUENCY) {
+		s64 ppb = 1 + tx->freq;
+		ppb *= 125;
+		ppb >>= 13;
+		err = ops->adjfreq(ops->priv, (s32)ppb);
+	}
+
+out:
+	mutex_unlock(&clocks_mux);
+	return err;
+}
+
+static int ptp_timer_create(struct k_itimer *timer)
+{
+	return -EOPNOTSUPP;
+}
+
+static int ptp_nsleep(const clockid_t clkid, int flags,
+		      struct timespec *ts, struct timespec __user *u)
+{
+	return -EOPNOTSUPP;
+}
+
+static long ptp_nsleep_restart(struct restart_block *restart_block)
+{
+	return -EOPNOTSUPP;
+}
+
+static int ptp_timer_set(struct k_itimer *timer, int flags,
+			 struct itimerspec *newits, struct itimerspec *oldits)
+{
+	return -EOPNOTSUPP;
+}
+
+static int ptp_timer_del(struct k_itimer *timer)
+{
+	return -EOPNOTSUPP;
+}
+
+static void ptp_timer_get(struct k_itimer *timer, struct itimerspec *its)
+{
+}
+
+/* public interface */
+
+struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
+{
+	struct k_clock clk;
+	struct ptp_clock *ptp;
+	int err = 0, index, major = MAJOR(ptp_devt);
+
+	if (info->n_alarm > PTP_MAX_ALARMS)
+		return ERR_PTR(-EINVAL);
+
+	/* Find a free clock slot and reserve it. */
+	err = -EBUSY;
+	mutex_lock(&clocks_mux);
+	index = find_first_zero_bit(clocks.map, PTP_MAX_CLOCKS);
+	if (index < PTP_MAX_CLOCKS)
+		set_bit(index, clocks.map);
+	else
+		goto no_slot;
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
+	mutex_init(&ptp->tsevq_mux);
+	init_waitqueue_head(&ptp->tsev_wq);
+
+	/* Create a new device in our class. */
+	ptp->dev = device_create(ptp_class, NULL, ptp->devid, ptp,
+				 "ptp%d", ptp->index);
+	if (IS_ERR(ptp->dev))
+		goto no_device;
+
+	dev_set_drvdata(ptp->dev, ptp);
+
+	err = ptp_register_chardev(ptp);
+	if (err)
+		goto no_chardev;
+
+	err = ptp_populate_sysfs(ptp);
+	if (err)
+		goto no_sysfs;
+
+	/* Register a new PPS source. */
+	if (info->pps) {
+		struct pps_source_info pps;
+		memset(&pps, 0, sizeof(pps));
+		snprintf(pps.name, PPS_MAX_NAME_LEN, "ptp%d", index);
+		pps.mode = PTP_PPS_MODE;
+		pps.owner = info->owner;
+		err = pps_register_source(&pps, PTP_PPS_DEFAULTS);
+		if (err < 0) {
+			pr_err("failed to register pps source\n");
+			goto no_pps;
+		} else
+			ptp->pps_source = err;
+	}
+
+	/* Create a posix clock. */
+	memset(&clk, 0, sizeof(clk));
+	clk.clock_getres	= ptp_clock_getres;
+	clk.clock_set		= ptp_clock_set;
+	clk.clock_get		= ptp_clock_get;
+	clk.clock_adj		= ptp_clock_adj;
+	clk.timer_create	= ptp_timer_create;
+	clk.nsleep		= ptp_nsleep;
+	clk.nsleep_restart	= ptp_nsleep_restart;
+	clk.timer_set		= ptp_timer_set;
+	clk.timer_del		= ptp_timer_del;
+	clk.timer_get		= ptp_timer_get;
+
+	snprintf(clk.name, KCLOCK_MAX_NAME, "ptp%d", index);
+
+	ptp->clock_id = create_posix_clock(&clk);
+	if (CLOCK_INVALID == ptp->clock_id) {
+		pr_err("failed to create posix clock\n");
+		err = -EBUSY;
+		goto no_clock;
+	}
+
+	/* Prevent this module from unloading. */
+	try_module_get(info->owner);
+
+	/* Clock is ready, add it into the list. */
+	list_add(&ptp->list, &clocks.list);
+	clocks.data[ptp->clock_id] = ptp;
+
+	mutex_unlock(&clocks_mux);
+	return ptp;
+
+no_clock:
+	if (ptp->info->pps)
+		pps_unregister_source(ptp->pps_source);
+no_pps:
+	ptp_cleanup_sysfs(ptp);
+no_sysfs:
+	ptp_unregister_chardev(ptp);
+no_chardev:
+	device_destroy(ptp_class, ptp->devid);
+no_device:
+	mutex_destroy(&ptp->tsevq_mux);
+	kfree(ptp);
+no_memory:
+	clear_bit(index, clocks.map);
+no_slot:
+	mutex_unlock(&clocks_mux);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(ptp_clock_register);
+
+int ptp_clock_unregister(struct ptp_clock *ptp)
+{
+	/* Release the clock's resources. */
+	if (ptp->info->pps)
+		pps_unregister_source(ptp->pps_source);
+	ptp_cleanup_sysfs(ptp);
+	ptp_unregister_chardev(ptp);
+	device_destroy(ptp_class, ptp->devid);
+	mutex_destroy(&ptp->tsevq_mux);
+
+	/* Remove the clock from the list. */
+	mutex_lock(&clocks_mux);
+	clocks.data[ptp->clock_id] = NULL;
+	list_del(&ptp->list);
+	clear_bit(ptp->index, clocks.map);
+	mutex_unlock(&clocks_mux);
+
+	kfree(ptp);
+
+	return 0;
+}
+EXPORT_SYMBOL(ptp_clock_unregister);
+
+void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *event)
+{
+	struct timespec ts;
+	struct pps_ktime pps_ts;
+
+	switch (event->type) {
+
+	case PTP_CLOCK_ALARM:
+		break;
+
+	case PTP_CLOCK_EXTTS:
+		enqueue_external_timestamp(&ptp->tsevq, event);
+		wake_up_interruptible(&ptp->tsev_wq);
+		break;
+
+	case PTP_CLOCK_PPS:
+		getnstimeofday(&ts);
+		pps_ts.sec = ts.tv_sec;
+		pps_ts.nsec = ts.tv_nsec;
+		pps_event(ptp->pps_source, &pps_ts, PTP_PPS_EVENT, NULL);
+		break;
+	}
+}
+EXPORT_SYMBOL(ptp_clock_event);
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
+	if (IS_ERR(ptp_class)) {
+		pr_err("ptp: failed to allocate class\n");
+		return PTR_ERR(ptp_class);
+	}
+
+	err = alloc_chrdev_region(&ptp_devt, 0, PTP_MAX_CLOCKS, "ptp");
+	if (err < 0) {
+		pr_err("ptp: failed to allocate device region\n");
+		goto no_region;
+	}
+
+	ptp_class->dev_attrs = ptp_dev_attrs;
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
+MODULE_AUTHOR("Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>");
+MODULE_DESCRIPTION("PTP clocks support");
+MODULE_LICENSE("GPL");
diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
new file mode 100644
index 0000000..2cb46ac
--- /dev/null
+++ b/drivers/ptp/ptp_private.h
@@ -0,0 +1,64 @@
+/*
+ * PTP 1588 clock support - private declarations for the core module.
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
+#ifndef _PTP_PRIVATE_H_
+#define _PTP_PRIVATE_H_
+
+#include <linux/cdev.h>
+#include <linux/mutex.h>
+#include <linux/ptp_clock.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/time.h>
+
+#define PTP_MAX_TIMESTAMPS 128
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
+	struct device *dev;
+	struct ptp_clock_info *info;
+	clockid_t clock_id;
+	dev_t devid;
+	int index; /* index into clocks.map */
+	int pps_source;
+	struct timestamp_event_queue tsevq; /* simple fifo for time stamps */
+	struct mutex tsevq_mux; /* one process at a time reading the fifo */
+	wait_queue_head_t tsev_wq;
+	struct cdev cdev;
+};
+
+static inline int queue_cnt(struct timestamp_event_queue *q)
+{
+	int cnt = q->tail - q->head;
+	return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
+}
+
+int ptp_register_chardev(struct ptp_clock *ptp);
+int ptp_unregister_chardev(struct ptp_clock *ptp);
+
+int ptp_cleanup_sysfs(struct ptp_clock *ptp);
+int ptp_populate_sysfs(struct ptp_clock *ptp);
+
+#endif
diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
new file mode 100644
index 0000000..7b5764e
--- /dev/null
+++ b/drivers/ptp/ptp_sysfs.c
@@ -0,0 +1,235 @@
+/*
+ * PTP 1588 clock support - sysfs interface.
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
+#include <linux/capability.h>
+#include <linux/device.h>
+
+#include <ptp_private.h>
+
+static ssize_t clock_id_show(struct device *dev,
+			     struct device_attribute *attr, char *page)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	return snprintf(page, PAGE_SIZE-1, "%d\n", ptp->clock_id);
+}
+
+static ssize_t clock_name_show(struct device *dev,
+			       struct device_attribute *attr, char *page)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	return snprintf(page, PAGE_SIZE-1, "%s\n", ptp->info->name);
+}
+
+#define PTP_SHOW_INT(name)						\
+static ssize_t name##_show(struct device *dev,				\
+			   struct device_attribute *attr, char *page)	\
+{									\
+	struct ptp_clock *ptp = dev_get_drvdata(dev);			\
+	return snprintf(page, PAGE_SIZE-1, "%d\n", ptp->info->name);	\
+}
+
+PTP_SHOW_INT(max_adj);
+PTP_SHOW_INT(n_alarm);
+PTP_SHOW_INT(n_ext_ts);
+PTP_SHOW_INT(n_per_out);
+PTP_SHOW_INT(pps);
+
+#define PTP_RO_ATTR(_var, _name) {				\
+	.attr	= { .name = __stringify(_name), .mode = 0444 },	\
+	.show	= _var##_show,					\
+}
+
+struct device_attribute ptp_dev_attrs[] = {
+	PTP_RO_ATTR(clock_id,	clock_id),
+	PTP_RO_ATTR(clock_name,	clock_name),
+	PTP_RO_ATTR(max_adj,	max_adjustment),
+	PTP_RO_ATTR(n_alarm,	n_alarms),
+	PTP_RO_ATTR(n_ext_ts,	n_external_timestamps),
+	PTP_RO_ATTR(n_per_out,	n_periodic_outputs),
+	PTP_RO_ATTR(pps,	pps_available),
+	__ATTR_NULL,
+};
+
+static ssize_t extts_enable_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	struct ptp_clock_info *ops = ptp->info;
+	void *priv = ops->priv;
+	struct ptp_clock_request req = { .type = PTP_CLK_REQ_EXTTS };
+	int cnt, enable;
+	int err = -EINVAL;
+
+	cnt = sscanf(buf, "%u %d", &req.extts.index, &enable);
+	if (cnt != 2)
+		goto out;
+	if (req.extts.index >= ops->n_ext_ts)
+		goto out;
+
+	err = ops->enable(priv, &req, enable ? 1 : 0);
+	if (err)
+		goto out;
+
+	return count;
+out:
+	return err;
+}
+
+static ssize_t extts_fifo_show(struct device *dev,
+			       struct device_attribute *attr, char *page)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	struct timestamp_event_queue *queue = &ptp->tsevq;
+	struct ptp_extts_event *event;
+	size_t qcnt;
+	int cnt;
+
+	if (mutex_lock_interruptible(&ptp->tsevq_mux))
+		return -ERESTARTSYS;
+
+	qcnt = queue_cnt(&ptp->tsevq);
+	if (!qcnt) {
+		mutex_unlock(&ptp->tsevq_mux);
+		return 0;
+	}
+	event = &queue->buf[queue->head];
+
+	cnt = snprintf(page, PAGE_SIZE, "%u %lld %u\n",
+		       event->index, event->t.sec, event->t.nsec);
+
+	queue->head = (1 + queue->head) % PTP_MAX_TIMESTAMPS;
+
+	mutex_unlock(&ptp->tsevq_mux);
+
+	return cnt;
+}
+
+static ssize_t period_store(struct device *dev,
+			    struct device_attribute *attr,
+			    const char *buf, size_t count)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	struct ptp_clock_info *ops = ptp->info;
+	void *priv = ops->priv;
+	struct ptp_clock_request req = { .type = PTP_CLK_REQ_PEROUT };
+	int cnt, enable, err = -EINVAL;
+
+	cnt = sscanf(buf, "%u %lld %u %lld %u", &req.perout.index,
+		     &req.perout.start.sec, &req.perout.start.nsec,
+		     &req.perout.period.sec, &req.perout.period.nsec);
+	if (cnt != 5)
+		goto out;
+	if (req.perout.index >= ops->n_per_out)
+		goto out;
+
+	enable = req.perout.period.sec || req.perout.period.nsec;
+	err = ops->enable(priv, &req, enable);
+	if (err)
+		goto out;
+
+	return count;
+out:
+	return err;
+}
+
+static ssize_t pps_enable_store(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	struct ptp_clock_info *ops = ptp->info;
+	void *priv = ops->priv;
+	struct ptp_clock_request req = { .type = PTP_CLK_REQ_PPS };
+	int cnt, enable;
+	int err = -EINVAL;
+
+	if (!capable(CAP_SYS_TIME))
+		return -EPERM;
+
+	cnt = sscanf(buf, "%d", &enable);
+	if (cnt != 1)
+		goto out;
+
+	err = ops->enable(priv, &req, enable ? 1 : 0);
+	if (err)
+		goto out;
+
+	return count;
+out:
+	return err;
+}
+
+static DEVICE_ATTR(extts_enable, 0220, NULL, extts_enable_store);
+static DEVICE_ATTR(fifo,         0444, extts_fifo_show, NULL);
+static DEVICE_ATTR(period,       0220, NULL, period_store);
+static DEVICE_ATTR(pps_enable,   0220, NULL, pps_enable_store);
+
+int ptp_cleanup_sysfs(struct ptp_clock *ptp)
+{
+	struct device *dev = ptp->dev;
+	struct ptp_clock_info *info = ptp->info;
+
+	if (info->n_ext_ts) {
+		device_remove_file(dev, &dev_attr_extts_enable);
+		device_remove_file(dev, &dev_attr_fifo);
+	}
+	if (info->n_per_out) {
+		device_remove_file(dev, &dev_attr_period);
+	}
+	if (info->pps) {
+		device_remove_file(dev, &dev_attr_pps_enable);
+	}
+	return 0;
+}
+
+int ptp_populate_sysfs(struct ptp_clock *ptp)
+{
+	struct device *dev = ptp->dev;
+	struct ptp_clock_info *info = ptp->info;
+	int err;
+
+	if (info->n_ext_ts) {
+		err = device_create_file(dev, &dev_attr_extts_enable);
+		if (err)
+			goto out1;
+		err = device_create_file(dev, &dev_attr_fifo);
+		if (err)
+			goto out2;
+	}
+	if (info->n_per_out) {
+		err = device_create_file(dev, &dev_attr_period);
+		if (err)
+			goto out3;
+	}
+	if (info->pps) {
+		err = device_create_file(dev, &dev_attr_pps_enable);
+		if (err)
+			goto out4;
+	}
+	return 0;
+out4:
+	device_remove_file(dev, &dev_attr_period);
+out3:
+	device_remove_file(dev, &dev_attr_fifo);
+out2:
+	device_remove_file(dev, &dev_attr_extts_enable);
+out1:
+	return err;
+}
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 626b629..1e2468a 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -295,6 +295,7 @@ header-y += ppp-comp.h
 header-y += ppp_defs.h
 header-y += pps.h
 header-y += prctl.h
+header-y += ptp_clock.h
 header-y += ptrace.h
 header-y += qnx4_fs.h
 header-y += qnxtypes.h
diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h
new file mode 100644
index 0000000..b4ef2cb
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
+/* PTP_xxx bits, for the flags field within the request structures. */
+#define PTP_ENABLE_FEATURE (1<<0)
+#define PTP_RISING_EDGE    (1<<1)
+#define PTP_FALLING_EDGE   (1<<2)
+
+/*
+ * struct ptp_clock_time - represents a time value
+ *
+ * The sign of the seconds field applies to the whole value. The
+ * nanoseconds field is always unsigned. The reserved field is
+ * included for sub-nanosecond resolution, should the demand for
+ * this ever appear.
+ *
+ */
+struct ptp_clock_time {
+	__s64 sec;  /* seconds */
+	__u32 nsec; /* nanoseconds */
+	__u32 reserved;
+};
+
+struct ptp_clock_caps {
+	int max_adj;   /* Maximum frequency adjustment in parts per billon. */
+	int n_alarm;   /* Number of programmable alarms. */
+	int n_ext_ts;  /* Number of external time stamp channels. */
+	int n_per_out; /* Number of programmable periodic signals. */
+	int pps;       /* Whether the clock supports a PPS callback. */
+};
+
+struct ptp_extts_request {
+	unsigned int index; /* Which channel to configure. */
+	unsigned int flags; /* Bit field for PTP_xxx flags. */
+};
+
+struct ptp_perout_request {
+	struct ptp_clock_time start;  /* Absolute start time. */
+	struct ptp_clock_time period; /* Desired period, zero means disable. */
+	unsigned int index;           /* Which channel to configure. */
+	unsigned int flags;           /* Reserved for future use. */
+};
+
+#define PTP_CLK_MAGIC '='
+
+#define PTP_CLOCK_GETCAPS  _IOR(PTP_CLK_MAGIC, 1, struct ptp_clock_caps)
+#define PTP_EXTTS_REQUEST  _IOW(PTP_CLK_MAGIC, 2, struct ptp_extts_request)
+#define PTP_PEROUT_REQUEST _IOW(PTP_CLK_MAGIC, 3, struct ptp_perout_request)
+#define PTP_ENABLE_PPS     _IOW(PTP_CLK_MAGIC, 4, int)
+
+struct ptp_extts_event {
+	struct ptp_clock_time t; /* Time event occured. */
+	unsigned int index;      /* Which channel produced the event. */
+};
+
+#endif
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
new file mode 100644
index 0000000..1f8d9e0
--- /dev/null
+++ b/include/linux/ptp_clock_kernel.h
@@ -0,0 +1,139 @@
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
+
+struct ptp_clock_request {
+	enum {
+		PTP_CLK_REQ_EXTTS,
+		PTP_CLK_REQ_PEROUT,
+		PTP_CLK_REQ_PPS,
+	} type;
+	union {
+		struct ptp_extts_request extts;
+		struct ptp_perout_request perout;
+	};
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
+extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info);
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
1.7.0.4
