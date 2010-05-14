From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 2/3] ptp: Added a clock that uses the Linux system time.
Date: Fri, 14 May 2010 18:46:07 +0200
Message-ID: <1ab9bca5dc0cca780db602de874381fb2d1ae6fb.1273855017.git.richard.cochran@omicron.at>
References: <cover.1273855016.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55971 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab0ENQpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 12:45:55 -0400
Received: by fxm6 with SMTP id 6so1700672fxm.19
        for <netdev@vger.kernel.org>; Fri, 14 May 2010 09:45:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1273855016.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This PTP clock simply uses the NTP time adjustment system calls. The
driver can be used in systems that lack a special hardware PTP clock.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/ptp/Kconfig     |   12 ++++
 drivers/ptp/Makefile    |    1 +
 drivers/ptp/ptp_linux.c |  136 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/time/ntp.c       |    2 +
 4 files changed, 151 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ptp/ptp_linux.c

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index c80a25b..9390d44 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -23,4 +23,16 @@ config PTP_1588_CLOCK
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp_clock.
 
+config PTP_1588_CLOCK_LINUX
+	tristate "Linux system timer as PTP clock"
+	depends on PTP_1588_CLOCK
+	help
+	  This driver adds support for using the standard Linux time
+	  source as a PTP clock. This clock is only useful if your PTP
+	  programs are using software time stamps for the PTP Ethernet
+	  packets.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ptp_linux.
+
 endmenu
diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
index b86695c..1651d52 100644
--- a/drivers/ptp/Makefile
+++ b/drivers/ptp/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_PTP_1588_CLOCK)		+= ptp_clock.o
+obj-$(CONFIG_PTP_1588_CLOCK_LINUX)	+= ptp_linux.o
diff --git a/drivers/ptp/ptp_linux.c b/drivers/ptp/ptp_linux.c
new file mode 100644
index 0000000..f0dbfc6
--- /dev/null
+++ b/drivers/ptp/ptp_linux.c
@@ -0,0 +1,136 @@
+/*
+ * PTP 1588 clock using the Linux system clock
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
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/hrtimer.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/timex.h>
+
+#include <linux/ptp_clock_kernel.h>
+
+static struct ptp_clock *linux_clock;
+
+DEFINE_SPINLOCK(adjtime_lock);
+
+static int ptp_linux_adjfreq(void *priv, s32 delta)
+{
+	struct timex txc;
+	s64 tmp = delta;
+	int err;
+	txc.freq = div_s64(tmp<<16, 1000);
+	txc.modes = ADJ_FREQUENCY;
+	err = do_adjtimex(&txc);
+	return err < 0 ? err : 0;
+}
+
+static int ptp_linux_adjtime(void *priv, struct timespec *ts)
+{
+	s64 delta;
+	ktime_t now;
+	struct timespec t2;
+	unsigned long flags;
+	int err;
+
+	delta = 1000000000LL * ts->tv_sec + ts->tv_nsec;
+
+	spin_lock_irqsave(&adjtime_lock, flags);
+
+	now = ktime_get_real();
+
+	now = delta < 0 ? ktime_sub_ns(now,-delta) : ktime_add_ns(now,delta);
+
+	t2 = ktime_to_timespec(now);
+
+	err = do_settimeofday(&t2);
+
+	spin_unlock_irqrestore(&adjtime_lock, flags);
+
+	return err;
+}
+
+static int ptp_linux_gettime(void *priv, struct timespec *ts)
+{
+	getnstimeofday(ts);
+	return 0;
+}
+
+static int ptp_linux_settime(void *priv, struct timespec *ts)
+{
+	return do_settimeofday(ts);
+}
+
+static int ptp_linux_gettimer(void *priv, int index, struct itimerspec *ts)
+{
+	/* We do not offer any ancillary features at all. */
+	return -EOPNOTSUPP;
+}
+
+static int ptp_linux_settimer(void *p, int i, int abs, struct itimerspec *ts)
+{
+	/* We do not offer any ancillary features at all. */
+	return -EOPNOTSUPP;
+}
+
+static int ptp_linux_enable(void *priv, struct ptp_clock_request *rq, int on)
+{
+	/* We do not offer any ancillary features at all. */
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info ptp_linux_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "Linux timer",
+	.max_adj	= 512000,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+	.priv		= NULL,
+	.adjfreq	= ptp_linux_adjfreq,
+	.adjtime	= ptp_linux_adjtime,
+	.gettime	= ptp_linux_gettime,
+	.settime	= ptp_linux_settime,
+	.gettimer	= ptp_linux_gettimer,
+	.settimer	= ptp_linux_settimer,
+	.enable		= ptp_linux_enable,
+};
+
+/* module operations */
+
+static void __exit ptp_linux_exit(void)
+{
+	ptp_clock_unregister(linux_clock);
+}
+
+static int __init ptp_linux_init(void)
+{
+	linux_clock = ptp_clock_register(&ptp_linux_caps);
+
+	return IS_ERR(linux_clock) ? PTR_ERR(linux_clock) : 0;
+}
+
+module_init(ptp_linux_init);
+module_exit(ptp_linux_exit);
+
+MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_DESCRIPTION("PTP clock using the Linux system timer");
+MODULE_LICENSE("GPL");
diff --git a/kernel/time/ntp.c b/kernel/time/ntp.c
index 7c0f180..efd1ff8 100644
--- a/kernel/time/ntp.c
+++ b/kernel/time/ntp.c
@@ -14,6 +14,7 @@
 #include <linux/timex.h>
 #include <linux/time.h>
 #include <linux/mm.h>
+#include <linux/module.h>
 
 /*
  * NTP timekeeping variables:
@@ -535,6 +536,7 @@ int do_adjtimex(struct timex *txc)
 
 	return result;
 }
+EXPORT_SYMBOL(do_adjtimex);
 
 static int __init ntp_tick_adj_setup(char *str)
 {
-- 
1.6.3.3

