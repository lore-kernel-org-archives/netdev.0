From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v1 3/3] async: add driver asynch levels
Date: Sun, 31 Aug 2014 02:03:20 -0700
Message-ID: <1409475800-17573-4-git-send-email-mcgrof@do-not-panic.com>
References: <1409475800-17573-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, oleg@redhat.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409475800-17573-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Joseph bisected and found that Tetsuo Handa's commit 786235ee
"kthread: make kthread_create() killable" modified kthread_create()
to bail as soon as SIGKILL is received [0] [1]. This is causing some
issues with some drivers and at times boot. There are other patches which
could also enable the SIGKILL trigger on driver loading though:

70834d30 "usermodehelper: use UMH_WAIT_PROC consistently"
b3449922 "usermodehelper: introduce umh_complete(sub_info)"
d0bd587a "usermodehelper: implement UMH_KILLABLE"
9d944ef3 "usermodehelper: kill umh_wait, renumber UMH_* constants"
5b9bd473 "usermodehelper: ____call_usermodehelper() doesn't need do_exit()"
3e63a93b "kmod: introduce call_modprobe() helper"
1cc684ab "kmod: make __request_module() killable"

All of these went in on 3.4 upstream, and were part of the fixes for
CVE-2012-4398 [2] and documented more properly on Red Hat's bugzilla [3].
Any of these patches may contribute to having a module be properly
killed now, but 786235ee is the latest in the series. For instance on
SLE12 cxgb4 has been fond to get the SIGKILL even though SLE12 does not
yet have 786235ee merged [4].

Joseph found that the systemd-udevd process sends SIGKILL to systemd's
usage of kmod for module loading if probe on a driver takes over 30
seconds [5] [6]. When this happens probe will fail on any driver, its why
booting on some systems will fail if the driver happens to be a storage
related driver. When helping debug the issue Tetsuo suggested fixing this
issue by modifying kthread_create() to not leave upon SIGKILL immediately
if the source of the SIGKILL was the OOM, and actually wait for 10 seconds
more before completing the kill [7]. This work around would in turn only
help by adding an extra 10 second delay increasing in effect the systemd
timeout by an extra 10 seconds. Drivers which take more than 40 seconds
should then still fail to load on kernels with this work around patch.
Upon review of this patch Oleg rejected this change [8] and the discussion
was punted out to systemd-devel to see if the default timeout could be
increased from 30 seconds to 120 [9]. The opinion of the systemd maintainers
was that the driver's behavior should be fixed [10]. Linus seems to agree [11],
however more recently even networking drivers have been reported to fail
on probe since just writing the firmware to a device and kicking it can take
easy over 60 seconds [4]. Benjamim was able to trace the issues recently
reported on cxgb4 down to the same systemd-udevd 30 second timeout [6].

Folks are a bit confused here though -- its not only module initialization
which is being penalized, because the driver core will immediately trigger
the driver's own bus probe routine if autoprobe is enabled each driver's
probe routine must also complete within the same 30 second timeout.
This means not only should driver's init complete within the set
default systemd timeout of 30 seconds but so should the probe routine, and
probe would obviously also have less time given that the timeout is
for both the module's init() and its own bus' probe(). Quite a bit of
driver's fail to complete the bus' probe within 30 seconds, its
not the init routine that takes long.

We'll need a solution to split up asynch probing then. This solution
provides a more generic module-agnostic solution which could be used by
any init() caller and ends up respecting the same init levels as when
things are built-in.

[0]  http://thread.gmane.org/gmane.linux.ubuntu.devel.kernel.general/39123
[1]  https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1276705
[2]  http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2012-4398
[3]  https://bugzilla.redhat.com/show_bug.cgi?id=CVE-2012-4398
[4]  https://bugzilla.novell.com/show_bug.cgi?id=877622
[5]  http://article.gmane.org/gmane.linux.kernel/1669550
[6]  https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1297248
[7]  https://launchpadlibrarian.net/169657493/kthread-defer-leaving.patch
[8]  http://article.gmane.org/gmane.linux.kernel/1669604
[9]  http://lists.freedesktop.org/archives/systemd-devel/2014-March/018006.html
[10] http://article.gmane.org/gmane.comp.sysutils.systemd.devel/17860
[11] http://article.gmane.org/gmane.linux.kernel/1671333

Cc: Tejun Heo <tj@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Joseph Salisbury <joseph.salisbury@canonical.com>
Cc: Kay Sievers <kay@vrfy.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Pierre Fersing <pierre-fersing@pierref.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Benjamin Poirier <bpoirier@suse.de>
Cc: Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>
Cc: Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>
Cc: Sreekanth Reddy <sreekanth.reddy@avagotech.com>
Cc: Abhijit Mahajan <abhijit.mahajan@avagotech.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: MPT-FusionLinux.pdl@avagotech.com
Cc: linux-scsi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 include/linux/async.h |  4 ++++
 include/linux/init.h  | 34 ++++++++++++++++++++++++++++++++++
 kernel/async.c        | 33 +++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+)

diff --git a/include/linux/async.h b/include/linux/async.h
index 6b0226b..e06544b 100644
--- a/include/linux/async.h
+++ b/include/linux/async.h
@@ -40,9 +40,13 @@ struct async_domain {
 extern async_cookie_t async_schedule(async_func_t func, void *data);
 extern async_cookie_t async_schedule_domain(async_func_t func, void *data,
 					    struct async_domain *domain);
+extern async_cookie_t async_schedule_level(async_func_t func, void *data,
+					   int level);
+
 void async_unregister_domain(struct async_domain *domain);
 extern void async_synchronize_full(void);
 extern void async_synchronize_full_domain(struct async_domain *domain);
+extern void async_synchronize_level(int level);
 extern void async_synchronize_cookie(async_cookie_t cookie);
 extern void async_synchronize_cookie_domain(async_cookie_t cookie,
 					    struct async_domain *domain);
diff --git a/include/linux/init.h b/include/linux/init.h
index 3b69b1a..6ba7e4f 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -282,6 +282,7 @@ void __init parse_early_options(char *cmdline);
  * be one per module.
  */
 #define module_init(x)	__initcall(x);
+#define module_init_async(x)	__initcall(x);
 
 /**
  * module_exit() - driver exit entry point
@@ -294,9 +295,12 @@ void __init parse_early_options(char *cmdline);
  * There can only be one per module.
  */
 #define module_exit(x)	__exitcall(x);
+#define module_exit_async(x)	__exitcall(x);
 
 #else /* MODULE */
 
+#include <linux/async.h>
+
 /*
  * In most cases loadable modules do not need custom
  * initcall levels. There are still some valid cases where
@@ -335,9 +339,39 @@ void __init parse_early_options(char *cmdline);
 	{ return exitfn; }					\
 	void cleanup_module(void) __attribute__((alias(#exitfn)));
 
+#define drv_init_async(initfn, __level)				\
+	static int ___init_ret;					\
+	static void _drv_init_async_##initfn(void *data, async_cookie_t cookie) \
+	{							\
+		initcall_t fn = data;				\
+		async_synchronize_level(__level - 1);		\
+		___init_ret = fn();				\
+		if (___init_ret !=0)				\
+			printk(KERN_DEBUG			\
+			       "async init routine failed: " #initfn "(): %d\n", ___init_ret); \
+	}							\
+	static __init int __drv_init_async_##initfn(void)	\
+	{							\
+		async_schedule_level(_drv_init_async_##initfn, initfn, __level); \
+		return 0;					\
+	}							\
+	drv_init(__drv_init_async_##initfn);
+
+#define drv_exit_async(exitfn, level)				\
+	static __exit void __drv_exit_async##exitfn(void)	\
+	{							\
+		async_synchronize_level(level);			\
+		if (___init_ret == 0)				\
+			exitfn();				\
+	}							\
+	drv_exit(__drv_exit_async##exitfn);
+
 #define module_init(initfn)	drv_init(initfn);
 #define module_exit(exitfn)	drv_exit(exitfn);
 
+#define module_init_async(fn)			drv_init_async(fn, 7)
+#define module_exit_async(exitfn)		drv_exit_async(exitfn, 7)
+
 #define __setup_param(str, unique_id, fn)	/* nothing */
 #define __setup(str, func) 			/* nothing */
 #endif
diff --git a/kernel/async.c b/kernel/async.c
index 362b3d6..4d80a36 100644
--- a/kernel/async.c
+++ b/kernel/async.c
@@ -68,6 +68,20 @@ static LIST_HEAD(async_global_pending);	/* pending from all registered doms */
 static ASYNC_DOMAIN(async_dfl_domain);
 static DEFINE_SPINLOCK(async_lock);
 
+#define ASYNC_DOMAIN_LEVEL(level) \
+	{ .pending = LIST_HEAD_INIT(async_level_domains[level-1].pending), \
+	.registered = 0 }
+
+static struct async_domain async_level_domains[] = {
+	ASYNC_DOMAIN_LEVEL(1),
+	ASYNC_DOMAIN_LEVEL(2),
+	ASYNC_DOMAIN_LEVEL(3),
+	ASYNC_DOMAIN_LEVEL(4),
+	ASYNC_DOMAIN_LEVEL(5),
+	ASYNC_DOMAIN_LEVEL(6),
+	ASYNC_DOMAIN_LEVEL(7),
+};
+
 struct async_entry {
 	struct list_head	domain_list;
 	struct list_head	global_list;
@@ -237,6 +251,14 @@ async_cookie_t async_schedule_domain(async_func_t func, void *data,
 }
 EXPORT_SYMBOL_GPL(async_schedule_domain);
 
+async_cookie_t async_schedule_level(async_func_t func, void *data, int level)
+{
+	if (level <= 0 || level > ARRAY_SIZE(async_level_domains))
+		return __async_schedule_sync(func, data);
+	return async_schedule_domain(func, data, &async_level_domains[level-1]);
+}
+EXPORT_SYMBOL_GPL(async_schedule_level);
+
 /**
  * async_synchronize_full - synchronize all asynchronous function calls
  *
@@ -279,6 +301,17 @@ void async_synchronize_full_domain(struct async_domain *domain)
 }
 EXPORT_SYMBOL_GPL(async_synchronize_full_domain);
 
+void async_synchronize_level(int level)
+{
+	int i;
+	if (level <= 0 || level > ARRAY_SIZE(async_level_domains))
+		return;
+
+	for (i=1; i <= level; i++)
+		async_synchronize_full_domain(&async_level_domains[i-1]);
+}
+EXPORT_SYMBOL_GPL(async_synchronize_level);
+
 /**
  * async_synchronize_cookie_domain - synchronize asynchronous function calls within a certain domain with cookie checkpointing
  * @cookie: async_cookie_t to use as checkpoint
-- 
2.0.3
