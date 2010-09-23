From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 5/8] ptp: Added a simulated PTP hardware clock.
Date: Thu, 23 Sep 2010 19:32:58 +0200
Message-ID: <ff8fc26fb6555af9d6102cc0717b985674881396.1285261535.git.richard.cochran@omicron.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <cover.1285261533.git.richard.cochran@omicron.at>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds a driver that simulates a PTP hardware clock. The
driver serves as a simple example for writing real clock driver and
can be used for testing the PTP clock API.

The basic clock operations are implemented using the system clock,
and the ancillary clock operations are simulated.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/ptp/Kconfig     |   14 ++++
 drivers/ptp/Makefile    |    1 +
 drivers/ptp/ptp_linux.c |  165 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/time/ntp.c       |    2 +
 4 files changed, 182 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ptp/ptp_linux.c

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 17be208..94f329f 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -24,4 +24,18 @@ config PTP_1588_CLOCK
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp.
 
+config PTP_1588_CLOCK_LINUX
+	tristate "Simulated PTP clock"
+	depends on PTP_1588_CLOCK
+	help
+	  This driver adds support for a simulated PTP clock. It
+	  implements the basic clock operations by using the standard
+	  Linux system time. The driver simulates the ancillary clock
+	  operations. This clock can be used to test PTP programs
+	  provided they use software time stamps for the PTP Ethernet
+	  packets.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ptp_linux.
+
 endmenu
diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
index 480e2af..266d4f2 100644
--- a/drivers/ptp/Makefile
+++ b/drivers/ptp/Makefile
@@ -4,3 +4,4 @@
 
 ptp-y					:= ptp_clock.o ptp_chardev.o ptp_sysfs.o
 obj-$(CONFIG_PTP_1588_CLOCK)		+= ptp.o
+obj-$(CONFIG_PTP_1588_CLOCK_LINUX)	+= ptp_linux.o
diff --git a/drivers/ptp/ptp_linux.c b/drivers/ptp/ptp_linux.c
new file mode 100644
index 0000000..57b3da4
--- /dev/null
+++ b/drivers/ptp/ptp_linux.c
@@ -0,0 +1,165 @@
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
+static int ptp_linux_adjfreq(void *priv, s32 ppb)
+{
+	struct timex txc;
+	s64 tmp = ppb;
+	int err;
+	pr_debug("ptp_linux: adjfreq ppb=%d\n", ppb);
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
+	now = delta < 0 ? ktime_sub_ns(now, -delta) : ktime_add_ns(now, delta);
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
+#define sim(x...) pr_warn("ptp_linux simulation: " x)
+
+static int ptp_linux_enable(void *priv, struct ptp_clock_request *rq, int on)
+{
+	struct ptp_clock_event event;
+	ktime_t kt;
+	int i;
+
+	switch (rq->type) {
+
+	case PTP_CLK_REQ_EXTTS:
+		if (on) {
+			sim("enable external timestamped events\n");
+			for (i = 0; i < 100; i++) {
+				kt = ktime_get_real();
+				event.type = PTP_CLOCK_EXTTS;
+				event.index = 0;
+				event.timestamp = ktime_to_ns(kt);
+				ptp_clock_event(linux_clock, &event);
+			}
+		} else
+			sim("disable external timestamped events\n");
+		break;
+
+	case PTP_CLK_REQ_PEROUT:
+		if (on)
+			sim("channel %d start %lld %u period %lld %u\n",
+			    rq->perout.index,
+			    rq->perout.start.sec, rq->perout.start.nsec,
+			    rq->perout.period.sec, rq->perout.period.nsec);
+		else
+			sim("periodic output %d disabled\n", rq->perout.index);
+		break;
+
+	case PTP_CLK_REQ_PPS:
+		if (on)
+			sim("clock to host PPS enabled\n");
+		else
+			sim("clock to host PPS disabled\n");
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static struct ptp_clock_info ptp_linux_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "Linux timer",
+	.max_adj	= 512000,
+	.n_alarm	= 0,
+	.n_ext_ts	= 1,
+	.n_per_out	= 1,
+	.pps		= 1,
+	.priv		= NULL,
+	.adjfreq	= ptp_linux_adjfreq,
+	.adjtime	= ptp_linux_adjtime,
+	.gettime	= ptp_linux_gettime,
+	.settime	= ptp_linux_settime,
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
index c631168..eba3bcf 100644
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
1.7.0.4
