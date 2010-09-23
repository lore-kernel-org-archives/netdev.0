From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/8] posix clocks: introduce a sysfs presence.
Date: Thu, 23 Sep 2010 19:31:54 +0200
Message-ID: <8042297eb6aefe157d611d3252dc09cd2c4c6fd8.1285261534.git.richard.cochran@omicron.at>
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

This patch adds a 'timesource' class into sysfs. Each registered POSIX
clock appears by name under /sys/class/timesource. The idea is to
expose to user space the dynamic mapping between clock devices and
clock IDs.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 Documentation/ABI/testing/sysfs-timesource |   24 ++++++++++++++++
 drivers/char/mmtimer.c                     |    1 +
 include/linux/posix-timers.h               |    4 +++
 kernel/posix-cpu-timers.c                  |    2 +
 kernel/posix-timers.c                      |   40 ++++++++++++++++++++++++++++
 5 files changed, 71 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-timesource

diff --git a/Documentation/ABI/testing/sysfs-timesource b/Documentation/ABI/testing/sysfs-timesource
new file mode 100644
index 0000000..f991de2
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-timesource
@@ -0,0 +1,24 @@
+What:		/sys/class/timesource/
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran@gmail.com>
+Description:
+		This directory contains files and directories
+		providing a standardized interface to the available
+		time sources.
+
+What:		/sys/class/timesource/<name>/
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran@gmail.com>
+Description:
+		This directory contains the attributes of a time
+		source registered with the POSIX clock subsystem.
+
+What:		/sys/class/timesource/<name>/id
+Date:		September 2010
+Contact:	Richard Cochran <richardcochran@gmail.com>
+Description:
+		This file contains the clock ID (a non-negative
+		integer) of the named time source registered with the
+		POSIX clock subsystem. This value may be passed as the
+		first argument to the POSIX clock and timer system
+		calls. See man CLOCK_GETRES(2) and TIMER_CREATE(2).
diff --git a/drivers/char/mmtimer.c b/drivers/char/mmtimer.c
index ea7c99f..e9173e3 100644
--- a/drivers/char/mmtimer.c
+++ b/drivers/char/mmtimer.c
@@ -758,6 +758,7 @@ static int sgi_timer_set(struct k_itimer *timr, int flags,
 }
 
 static struct k_clock sgi_clock = {
+	.name = "sgi_cycle",
 	.res = 0,
 	.clock_set = sgi_clock_set,
 	.clock_get = sgi_clock_get,
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 08aa4da..64e6fee 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -67,7 +67,11 @@ struct k_itimer {
 	} it;
 };
 
+#define KCLOCK_MAX_NAME 32
+
 struct k_clock {
+	char name[KCLOCK_MAX_NAME];
+	struct device *dev;
 	clockid_t id;
 	int res;		/* in nanoseconds */
 	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index e1c2e7b..df9cbab 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -1611,6 +1611,7 @@ static long thread_cpu_nsleep_restart(struct restart_block *restart_block)
 static __init int init_posix_cpu_timers(void)
 {
 	struct k_clock process = {
+		.name = "process_cputime",
 		.clock_getres = process_cpu_clock_getres,
 		.clock_get = process_cpu_clock_get,
 		.clock_set = do_posix_clock_nosettime,
@@ -1619,6 +1620,7 @@ static __init int init_posix_cpu_timers(void)
 		.nsleep_restart = process_cpu_nsleep_restart,
 	};
 	struct k_clock thread = {
+		.name = "thread_cputime",
 		.clock_getres = thread_cpu_clock_getres,
 		.clock_get = thread_cpu_clock_get,
 		.clock_set = do_posix_clock_nosettime,
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 67fba5c..719aa11 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -46,6 +46,7 @@
 #include <linux/wait.h>
 #include <linux/workqueue.h>
 #include <linux/module.h>
+#include <linux/device.h>
 
 /*
  * Management arrays for POSIX timers.	 Timers are kept in slab memory
@@ -135,6 +136,8 @@ static struct k_clock posix_clocks[MAX_CLOCKS];
 static DECLARE_BITMAP(clocks_map, MAX_CLOCKS);
 static DEFINE_MUTEX(clocks_mux); /* protects 'posix_clocks' and 'clocks_map' */
 
+static struct class *timesource_class;
+
 /*
  * These ones are defined below.
  */
@@ -271,20 +274,40 @@ static int posix_get_coarse_res(const clockid_t which_clock, struct timespec *tp
 	*tp = ktime_to_timespec(KTIME_LOW_RES);
 	return 0;
 }
+
+/*
+ * sysfs attributes
+ */
+
+static ssize_t show_clock_id(struct device *dev,
+			     struct device_attribute *attr, char *page)
+{
+	struct k_clock *kc = dev_get_drvdata(dev);
+	return snprintf(page, PAGE_SIZE-1, "%d\n", kc->id);
+}
+
+static struct device_attribute timesource_dev_attrs[] = {
+	__ATTR(id,   0444, show_clock_id,   NULL),
+	__ATTR_NULL,
+};
+
 /*
  * Initialize everything, well, just everything in Posix clocks/timers ;)
  */
 static __init int init_posix_timers(void)
 {
 	struct k_clock clock_realtime = {
+		.name = "realtime",
 		.clock_getres = hrtimer_get_res,
 	};
 	struct k_clock clock_monotonic = {
+		.name = "monotonic",
 		.clock_getres = hrtimer_get_res,
 		.clock_get = posix_ktime_get_ts,
 		.clock_set = do_posix_clock_nosettime,
 	};
 	struct k_clock clock_monotonic_raw = {
+		.name = "monotonic_raw",
 		.clock_getres = hrtimer_get_res,
 		.clock_get = posix_get_monotonic_raw,
 		.clock_set = do_posix_clock_nosettime,
@@ -292,6 +315,7 @@ static __init int init_posix_timers(void)
 		.nsleep = no_nsleep,
 	};
 	struct k_clock clock_realtime_coarse = {
+		.name = "realtime_coarse",
 		.clock_getres = posix_get_coarse_res,
 		.clock_get = posix_get_realtime_coarse,
 		.clock_set = do_posix_clock_nosettime,
@@ -299,6 +323,7 @@ static __init int init_posix_timers(void)
 		.nsleep = no_nsleep,
 	};
 	struct k_clock clock_monotonic_coarse = {
+		.name = "monotonic_coarse",
 		.clock_getres = posix_get_coarse_res,
 		.clock_get = posix_get_monotonic_coarse,
 		.clock_set = do_posix_clock_nosettime,
@@ -306,6 +331,13 @@ static __init int init_posix_timers(void)
 		.nsleep = no_nsleep,
 	};
 
+	timesource_class = class_create(NULL, "timesource");
+	if (IS_ERR(timesource_class)) {
+		pr_err("posix-timers: failed to allocate timesource class\n");
+		return PTR_ERR(timesource_class);
+	}
+	timesource_class->dev_attrs = timesource_dev_attrs;
+
 	register_posix_clock(CLOCK_REALTIME, &clock_realtime);
 	register_posix_clock(CLOCK_MONOTONIC, &clock_monotonic);
 	register_posix_clock(CLOCK_MONOTONIC_RAW, &clock_monotonic_raw);
@@ -500,6 +532,14 @@ int register_posix_clock(const clockid_t id, struct k_clock *clock)
 	kc = &posix_clocks[id];
 	*kc = *clock;
 	kc->id = id;
+	kc->dev = device_create(timesource_class, NULL, MKDEV(0, 0),
+				kc, "%s", kc->name);
+	if (IS_ERR(kc->dev)) {
+		pr_err("failed to create device clock_id %d\n", id);
+		err = PTR_ERR(kc->dev);
+		goto out;
+	}
+	dev_set_drvdata(kc->dev, kc);
 	set_bit(id, clocks_map);
 out:
 	mutex_unlock(&clocks_mux);
-- 
1.7.0.4
