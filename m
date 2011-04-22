From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V15 1/4] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 22 Apr 2011 12:03:08 +0200
Message-ID: <e43d206e8e8af8a29dfb4adce744619f5092d492.1303466103.git.richard.cochran@omicron.at>
References: <cover.1303466102.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1303466102.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds an infrastructure for hardware clocks that implement
IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
registration method to particular hardware clock drivers. Each clock is
presented as a standard POSIX clock.

The ancillary clock features are exposed in two different ways, via
the sysfs and by a character device.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-ptp |   98 +++++++++
 Documentation/ptp/ptp.txt           |   89 ++++++++
 Documentation/ptp/testptp.c         |  381 +++++++++++++++++++++++++++++++++++
 Documentation/ptp/testptp.mk        |   33 +++
 drivers/Kconfig                     |    2 +
 drivers/Makefile                    |    1 +
 drivers/ptp/Kconfig                 |   30 +++
 drivers/ptp/Makefile                |    6 +
 drivers/ptp/ptp_chardev.c           |  159 +++++++++++++++
 drivers/ptp/ptp_clock.c             |  343 +++++++++++++++++++++++++++++++
 drivers/ptp/ptp_private.h           |   92 +++++++++
 drivers/ptp/ptp_sysfs.c             |  230 +++++++++++++++++++++
 include/linux/Kbuild                |    1 +
 include/linux/ptp_classify.h        |    7 +
 include/linux/ptp_clock.h           |   84 ++++++++
 include/linux/ptp_clock_kernel.h    |  139 +++++++++++++
 16 files changed, 1695 insertions(+), 0 deletions(-)
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
index 0000000..d40d2b5
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-ptp
@@ -0,0 +1,98 @@
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
+		outputs. To enable a periodic output, write five
+		integers into the file: channel index, start time
+		seconds, start time nanoseconds, period seconds, and
+		period nanoseconds. To disable a periodic output, set
+		all the seconds and nanoseconds values to zero.
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
index 0000000..ae8fef8
--- /dev/null
+++ b/Documentation/ptp/ptp.txt
@@ -0,0 +1,89 @@
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
+   The class driver also creates a character device for each
+   registered clock. User space can use an open file descriptor from
+   the character device as a POSIX clock id and may call
+   clock_gettime, clock_settime, and clock_adjtime.  These calls
+   implement the basic clock operations.
+
+   User space programs may control the clock using standardized
+   ioctls. A program may query, enable, configure, and disable the
+   ancillary clock features. User space can receive time stamped
+   events via blocking read() and poll(). One shot and periodic
+   signals may be configured via the POSIX timer_settime() system
+   call.
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
index 0000000..f59ded0
--- /dev/null
+++ b/Documentation/ptp/testptp.c
@@ -0,0 +1,381 @@
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
+
+#ifndef ADJ_SETOFFSET
+#define ADJ_SETOFFSET 0x0100
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
+static clockid_t get_clockid(int fd)
+{
+#define CLOCKFD 3
+#define FD_TO_CLOCKID(fd)	((~(clockid_t) (fd) << 3) | CLOCKFD)
+
+	return FD_TO_CLOCKID(fd);
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
+static long ppb_to_scaled_ppm(int ppb)
+{
+	/*
+	 * The 'freq' field in the 'struct timex' is in parts per
+	 * million, but with a 16 bit binary fractional field.
+	 * Instead of calculating either one of
+	 *
+	 *    scaled_ppm = (ppb / 1000) << 16  [1]
+	 *    scaled_ppm = (ppb << 16) / 1000  [2]
+	 *
+	 * we simply use double precision math, in order to avoid the
+	 * truncation in [1] and the possible overflow in [2].
+	 */
+	return (long) (ppb * 65.536);
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
+		" -f val     adjust the ptp clock frequency by 'val' ppb\n"
+		" -g         get the ptp clock time\n"
+		" -h         prints this message\n"
+		" -p val     enable output with a period of 'val' nanoseconds\n"
+		" -P val     enable or disable (val=1|0) the system clock PPS\n"
+		" -s         set the ptp clock time from the system time\n"
+		" -S         set the system time from the ptp clock time\n"
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
+	while (EOF != (c = getopt(argc, argv, "a:A:cd:e:f:ghp:P:sSt:v"))) {
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
+		case 'S':
+			settime = 2;
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
+	fd = open(device, O_RDWR);
+	if (fd < 0) {
+		fprintf(stderr, "opening %s: %s\n", device, strerror(errno));
+		return -1;
+	}
+
+	clkid = get_clockid(fd);
+	if (CLOCK_INVALID == clkid) {
+		fprintf(stderr, "failed to read clock id\n");
+		return -1;
+	}
+
+	if (capabilities) {
+		if (ioctl(fd, PTP_CLOCK_GETCAPS, &caps)) {
+			perror("PTP_CLOCK_GETCAPS");
+		} else {
+			printf("capabilities:\n"
+			       "  %d maximum frequency adjustment (ppb)\n"
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
+		tx.freq = ppb_to_scaled_ppm(adjfreq);
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
+		if (clock_adjtime(clkid, &tx) < 0) {
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
+	if (settime == 1) {
+		clock_gettime(CLOCK_REALTIME, &ts);
+		if (clock_settime(clkid, &ts)) {
+			perror("clock_settime");
+		} else {
+			puts("set time okay");
+		}
+	}
+
+	if (settime == 2) {
+		clock_gettime(clkid, &ts);
+		if (clock_settime(CLOCK_REALTIME, &ts)) {
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
index 177c7d1..6fd7446 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -54,6 +54,8 @@ source "drivers/spi/Kconfig"
 
 source "drivers/pps/Kconfig"
 
+source "drivers/ptp/Kconfig"
+
 source "drivers/gpio/Kconfig"
 
 source "drivers/w1/Kconfig"
diff --git a/drivers/Makefile b/drivers/Makefile
index 3f135b6..71ebbf9 100644
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
index 0000000..70d4bb1
--- /dev/null
+++ b/drivers/ptp/Kconfig
@@ -0,0 +1,30 @@
+#
+# PTP clock support configuration
+#
+
+menu "PTP clock support"
+
+comment "Enable Device Drivers -> PPS to see the PTP clock options."
+	depends on PPS=n
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
index 0000000..a8d03ae
--- /dev/null
+++ b/drivers/ptp/ptp_chardev.c
@@ -0,0 +1,159 @@
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
+#include <linux/posix-clock.h>
+#include <linux/poll.h>
+#include <linux/sched.h>
+
+#include "ptp_private.h"
+
+int ptp_open(struct posix_clock *pc, fmode_t fmode)
+{
+	return 0;
+}
+
+long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
+{
+	struct ptp_clock_caps caps;
+	struct ptp_clock_request req;
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+	struct ptp_clock_info *ops = ptp->info;
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
+		err = ops->enable(ops, &req, enable);
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
+		err = ops->enable(ops, &req, enable);
+		break;
+
+	case PTP_ENABLE_PPS:
+		if (!capable(CAP_SYS_TIME))
+			return -EPERM;
+		req.type = PTP_CLK_REQ_PPS;
+		enable = arg ? 1 : 0;
+		err = ops->enable(ops, &req, enable);
+		break;
+
+	default:
+		err = -ENOTTY;
+		break;
+	}
+	return err;
+}
+
+unsigned int ptp_poll(struct posix_clock *pc, struct file *fp, poll_table *wait)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+
+	poll_wait(fp, &ptp->tsev_wq, wait);
+
+	return queue_cnt(&ptp->tsevq) ? POLLIN : 0;
+}
+
+ssize_t ptp_read(struct posix_clock *pc,
+		 uint rdflags, char __user *buf, size_t cnt)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+	struct timestamp_event_queue *queue = &ptp->tsevq;
+	struct ptp_extts_event event[PTP_BUF_TIMESTAMPS];
+	unsigned long flags;
+	size_t qcnt, i;
+
+	if (cnt % sizeof(struct ptp_extts_event) != 0)
+		return -EINVAL;
+
+	if (cnt > sizeof(event))
+		cnt = sizeof(event);
+
+	cnt = cnt / sizeof(struct ptp_extts_event);
+
+	if (mutex_lock_interruptible(&ptp->tsevq_mux))
+		return -ERESTARTSYS;
+
+	if (wait_event_interruptible(ptp->tsev_wq,
+				     ptp->defunct || queue_cnt(queue))) {
+		mutex_unlock(&ptp->tsevq_mux);
+		return -ERESTARTSYS;
+	}
+
+	if (ptp->defunct)
+		return -ENODEV;
+
+	spin_lock_irqsave(&queue->lock, flags);
+
+	qcnt = queue_cnt(queue);
+
+	if (cnt > qcnt)
+		cnt = qcnt;
+
+	for (i = 0; i < cnt; i++) {
+		event[i] = queue->buf[queue->head];
+		queue->head = (queue->head + 1) % PTP_MAX_TIMESTAMPS;
+	}
+
+	spin_unlock_irqrestore(&queue->lock, flags);
+
+	cnt = cnt * sizeof(struct ptp_extts_event);
+
+	mutex_unlock(&ptp->tsevq_mux);
+
+	if (copy_to_user(buf, event, cnt)) {
+		mutex_unlock(&ptp->tsevq_mux);
+		return -EFAULT;
+	}
+
+	return cnt;
+}
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
new file mode 100644
index 0000000..cf3f999
--- /dev/null
+++ b/drivers/ptp/ptp_clock.c
@@ -0,0 +1,343 @@
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
+#include <linux/bitops.h>
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/posix-clock.h>
+#include <linux/pps_kernel.h>
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/uaccess.h>
+
+#include "ptp_private.h"
+
+#define PTP_MAX_ALARMS 4
+#define PTP_MAX_CLOCKS 8
+#define PTP_PPS_DEFAULTS (PPS_CAPTUREASSERT | PPS_OFFSETASSERT)
+#define PTP_PPS_EVENT PPS_CAPTUREASSERT
+#define PTP_PPS_MODE (PTP_PPS_DEFAULTS | PPS_CANWAIT | PPS_TSFMT_TSPEC)
+
+/* private globals */
+
+static dev_t ptp_devt;
+static struct class *ptp_class;
+
+static DECLARE_BITMAP(ptp_clocks_map, PTP_MAX_CLOCKS);
+static DEFINE_MUTEX(ptp_clocks_mutex); /* protects 'ptp_clocks_map' */
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
+	unsigned long flags;
+	s64 seconds;
+	u32 remainder;
+
+	seconds = div_u64_rem(src->timestamp, 1000000000, &remainder);
+
+	spin_lock_irqsave(&queue->lock, flags);
+
+	dst = &queue->buf[queue->tail];
+	dst->index = src->index;
+	dst->t.sec = seconds;
+	dst->t.nsec = remainder;
+
+	if (!queue_free(queue))
+		queue->head = (queue->head + 1) % PTP_MAX_TIMESTAMPS;
+
+	queue->tail = (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
+
+	spin_unlock_irqrestore(&queue->lock, flags);
+}
+
+static s32 scaled_ppm_to_ppb(long ppm)
+{
+	/*
+	 * The 'freq' field in the 'struct timex' is in parts per
+	 * million, but with a 16 bit binary fractional field.
+	 *
+	 * We want to calculate
+	 *
+	 *    ppb = scaled_ppm * 1000 / 2^16
+	 *
+	 * which simplifies to
+	 *
+	 *    ppb = scaled_ppm * 125 / 2^13
+	 */
+	s64 ppb = 1 + ppm;
+	ppb *= 125;
+	ppb >>= 13;
+	return (s32) ppb;
+}
+
+/* posix clock implementation */
+
+static int ptp_clock_getres(struct posix_clock *pc, struct timespec *tp)
+{
+	return 1; /* always round timer functions to one nanosecond */
+}
+
+static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+	return ptp->info->settime(ptp->info, tp);
+}
+
+static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+	return ptp->info->gettime(ptp->info, tp);
+}
+
+static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+	struct ptp_clock_info *ops;
+	int err = -EOPNOTSUPP;
+
+	ops = ptp->info;
+
+	if (tx->modes & ADJ_SETOFFSET) {
+		struct timespec ts;
+		ktime_t kt;
+		s64 delta;
+
+		ts.tv_sec  = tx->time.tv_sec;
+		ts.tv_nsec = tx->time.tv_usec;
+
+		if (!(tx->modes & ADJ_NANO))
+			ts.tv_nsec *= 1000;
+
+		if ((unsigned long) ts.tv_nsec >= NSEC_PER_SEC)
+			return -EINVAL;
+
+		kt = timespec_to_ktime(ts);
+		delta = ktime_to_ns(kt);
+		err = ops->adjtime(ops, delta);
+
+	} else if (tx->modes & ADJ_FREQUENCY) {
+
+		err = ops->adjfreq(ops, scaled_ppm_to_ppb(tx->freq));
+	}
+
+	return err;
+}
+
+static struct posix_clock_operations ptp_clock_ops = {
+	.owner		= THIS_MODULE,
+	.clock_adjtime	= ptp_clock_adjtime,
+	.clock_gettime	= ptp_clock_gettime,
+	.clock_getres	= ptp_clock_getres,
+	.clock_settime	= ptp_clock_settime,
+	.ioctl		= ptp_ioctl,
+	.open		= ptp_open,
+	.poll		= ptp_poll,
+	.read		= ptp_read,
+};
+
+static void delete_ptp_clock(struct posix_clock *pc)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+
+	mutex_destroy(&ptp->tsevq_mux);
+
+	/* Remove the clock from the bit map. */
+	mutex_lock(&ptp_clocks_mutex);
+	clear_bit(ptp->index, ptp_clocks_map);
+	mutex_unlock(&ptp_clocks_mutex);
+
+	kfree(ptp);
+}
+
+/* public interface */
+
+struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
+{
+	struct ptp_clock *ptp;
+	int err = 0, index, major = MAJOR(ptp_devt);
+
+	if (info->n_alarm > PTP_MAX_ALARMS)
+		return ERR_PTR(-EINVAL);
+
+	/* Find a free clock slot and reserve it. */
+	err = -EBUSY;
+	mutex_lock(&ptp_clocks_mutex);
+	index = find_first_zero_bit(ptp_clocks_map, PTP_MAX_CLOCKS);
+	if (index < PTP_MAX_CLOCKS)
+		set_bit(index, ptp_clocks_map);
+	else
+		goto no_slot;
+
+	/* Initialize a clock structure. */
+	err = -ENOMEM;
+	ptp = kzalloc(sizeof(struct ptp_clock), GFP_KERNEL);
+	if (ptp == NULL)
+		goto no_memory;
+
+	ptp->clock.ops = ptp_clock_ops;
+	ptp->clock.release = delete_ptp_clock;
+	ptp->info = info;
+	ptp->devid = MKDEV(major, index);
+	ptp->index = index;
+	spin_lock_init(&ptp->tsevq.lock);
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
+		ptp->pps_source = pps_register_source(&pps, PTP_PPS_DEFAULTS);
+		if (!ptp->pps_source) {
+			pr_err("failed to register pps source\n");
+			goto no_pps;
+		}
+	}
+
+	/* Create a posix clock. */
+	err = posix_clock_register(&ptp->clock, ptp->devid);
+	if (err) {
+		pr_err("failed to create posix clock\n");
+		goto no_clock;
+	}
+
+	mutex_unlock(&ptp_clocks_mutex);
+	return ptp;
+
+no_clock:
+	if (ptp->pps_source)
+		pps_unregister_source(ptp->pps_source);
+no_pps:
+	ptp_cleanup_sysfs(ptp);
+no_sysfs:
+	device_destroy(ptp_class, ptp->devid);
+no_device:
+	mutex_destroy(&ptp->tsevq_mux);
+	kfree(ptp);
+no_memory:
+	clear_bit(index, ptp_clocks_map);
+no_slot:
+	mutex_unlock(&ptp_clocks_mutex);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(ptp_clock_register);
+
+int ptp_clock_unregister(struct ptp_clock *ptp)
+{
+	ptp->defunct = 1;
+	wake_up_interruptible(&ptp->tsev_wq);
+
+	/* Release the clock's resources. */
+	if (ptp->pps_source)
+		pps_unregister_source(ptp->pps_source);
+	ptp_cleanup_sysfs(ptp);
+	device_destroy(ptp_class, ptp->devid);
+
+	posix_clock_unregister(&ptp->clock);
+	return 0;
+}
+EXPORT_SYMBOL(ptp_clock_unregister);
+
+void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *event)
+{
+	struct pps_event_time evt;
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
+		pps_get_ts(&evt);
+		pps_event(ptp->pps_source, &evt, PTP_PPS_EVENT, NULL);
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
index 0000000..4d5b508
--- /dev/null
+++ b/drivers/ptp/ptp_private.h
@@ -0,0 +1,92 @@
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
+#include <linux/device.h>
+#include <linux/mutex.h>
+#include <linux/posix-clock.h>
+#include <linux/ptp_clock.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/time.h>
+
+#define PTP_MAX_TIMESTAMPS 128
+#define PTP_BUF_TIMESTAMPS 30
+
+struct timestamp_event_queue {
+	struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
+	int head;
+	int tail;
+	spinlock_t lock;
+};
+
+struct ptp_clock {
+	struct posix_clock clock;
+	struct device *dev;
+	struct ptp_clock_info *info;
+	dev_t devid;
+	int index; /* index into clocks.map */
+	struct pps_device *pps_source;
+	struct timestamp_event_queue tsevq; /* simple fifo for time stamps */
+	struct mutex tsevq_mux; /* one process at a time reading the fifo */
+	wait_queue_head_t tsev_wq;
+	int defunct; /* tells readers to go away when clock is being removed */
+};
+
+/*
+ * The function queue_cnt() is safe for readers to call without
+ * holding q->lock. Readers use this function to verify that the queue
+ * is nonempty before proceeding with a dequeue operation. The fact
+ * that a writer might concurrently increment the tail does not
+ * matter, since the queue remains nonempty nonetheless.
+ */
+static inline int queue_cnt(struct timestamp_event_queue *q)
+{
+	int cnt = q->tail - q->head;
+	return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
+}
+
+/*
+ * see ptp_chardev.c
+ */
+
+long ptp_ioctl(struct posix_clock *pc,
+	       unsigned int cmd, unsigned long arg);
+
+int ptp_open(struct posix_clock *pc, fmode_t fmode);
+
+ssize_t ptp_read(struct posix_clock *pc,
+		 uint flags, char __user *buf, size_t cnt);
+
+uint ptp_poll(struct posix_clock *pc,
+	      struct file *fp, poll_table *wait);
+
+/*
+ * see ptp_sysfs.c
+ */
+
+extern struct device_attribute ptp_dev_attrs[];
+
+int ptp_cleanup_sysfs(struct ptp_clock *ptp);
+
+int ptp_populate_sysfs(struct ptp_clock *ptp);
+
+#endif
diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
new file mode 100644
index 0000000..2f93926
--- /dev/null
+++ b/drivers/ptp/ptp_sysfs.c
@@ -0,0 +1,230 @@
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
+
+#include "ptp_private.h"
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
+	err = ops->enable(ops, &req, enable ? 1 : 0);
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
+	struct ptp_extts_event event;
+	unsigned long flags;
+	size_t qcnt;
+	int cnt = 0;
+
+	memset(&event, 0, sizeof(event));
+
+	if (mutex_lock_interruptible(&ptp->tsevq_mux))
+		return -ERESTARTSYS;
+
+	spin_lock_irqsave(&queue->lock, flags);
+	qcnt = queue_cnt(queue);
+	if (qcnt) {
+		event = queue->buf[queue->head];
+		queue->head = (queue->head + 1) % PTP_MAX_TIMESTAMPS;
+	}
+	spin_unlock_irqrestore(&queue->lock, flags);
+
+	if (!qcnt)
+		goto out;
+
+	cnt = snprintf(page, PAGE_SIZE, "%u %lld %u\n",
+		       event.index, event.t.sec, event.t.nsec);
+out:
+	mutex_unlock(&ptp->tsevq_mux);
+	return cnt;
+}
+
+static ssize_t period_store(struct device *dev,
+			    struct device_attribute *attr,
+			    const char *buf, size_t count)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	struct ptp_clock_info *ops = ptp->info;
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
+	err = ops->enable(ops, &req, enable);
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
+	err = ops->enable(ops, &req, enable ? 1 : 0);
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
+	if (info->n_per_out)
+		device_remove_file(dev, &dev_attr_period);
+
+	if (info->pps)
+		device_remove_file(dev, &dev_attr_pps_enable);
+
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
+	if (info->n_per_out)
+		device_remove_file(dev, &dev_attr_period);
+out3:
+	if (info->n_ext_ts)
+		device_remove_file(dev, &dev_attr_fifo);
+out2:
+	if (info->n_ext_ts)
+		device_remove_file(dev, &dev_attr_extts_enable);
+out1:
+	return err;
+}
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 75cf611..4585836 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -302,6 +302,7 @@ header-y += ppp-comp.h
 header-y += ppp_defs.h
 header-y += pps.h
 header-y += prctl.h
+header-y += ptp_clock.h
 header-y += ptrace.h
 header-y += qnx4_fs.h
 header-y += qnxtypes.h
diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
index 943a85a..e07e274 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -25,6 +25,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/ip.h>
 #include <linux/filter.h>
 #ifdef __KERNEL__
 #include <linux/in.h>
@@ -58,6 +59,12 @@
 #define OFF_NEXT	6
 #define OFF_UDP_DST	2
 
+#define OFF_PTP_SOURCE_UUID	22 /* PTPv1 only */
+#define OFF_PTP_SEQUENCE_ID	30
+#define OFF_PTP_CONTROL		32 /* PTPv1 only */
+
+#define IPV4_HLEN(data) (((struct iphdr *)(data + OFF_IHL))->ihl << 2)
+
 #define IP6_HLEN	40
 #define UDP_HLEN	8
 
diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h
new file mode 100644
index 0000000..94e981f
--- /dev/null
+++ b/include/linux/ptp_clock.h
@@ -0,0 +1,84 @@
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
+	int rsv[15];   /* Reserved for future use. */
+};
+
+struct ptp_extts_request {
+	unsigned int index;  /* Which channel to configure. */
+	unsigned int flags;  /* Bit field for PTP_xxx flags. */
+	unsigned int rsv[2]; /* Reserved for future use. */
+};
+
+struct ptp_perout_request {
+	struct ptp_clock_time start;  /* Absolute start time. */
+	struct ptp_clock_time period; /* Desired period, zero means disable. */
+	unsigned int index;           /* Which channel to configure. */
+	unsigned int flags;           /* Reserved for future use. */
+	unsigned int rsv[4];          /* Reserved for future use. */
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
+	unsigned int flags;      /* Reserved for future use. */
+	unsigned int rsv[2];     /* Reserved for future use. */
+};
+
+#endif
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
new file mode 100644
index 0000000..dd2e44f
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
+ *
+ * clock operations
+ *
+ * @adjfreq:  Adjusts the frequency of the hardware clock.
+ *            parameter delta: Desired period change in parts per billion.
+ *
+ * @adjtime:  Shifts the time of the hardware clock.
+ *            parameter delta: Desired change in nanoseconds.
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
+ * Drivers should embed their ptp_clock_info within a private
+ * structure, obtaining a reference to it using container_of().
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
+	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
+	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
+	int (*gettime)(struct ptp_clock_info *ptp, struct timespec *ts);
+	int (*settime)(struct ptp_clock_info *ptp, const struct timespec *ts);
+	int (*enable)(struct ptp_clock_info *ptp,
+		      struct ptp_clock_request *request, int on);
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
