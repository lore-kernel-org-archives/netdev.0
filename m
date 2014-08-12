From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v3 1/3] init / kthread: add module_long_probe_init() and module_long_probe_exit()
Date: Tue, 12 Aug 2014 15:28:25 -0700
Message-ID: <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com>
Cc: tiwai@suse.de, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Tetsuo bisected and found that commit 786235ee "kthread: make
kthread_create() killable" modified kthread_create() to bail as
soon as SIGKILL is received. This is causing some issues with
some drivers and at times boot. Joseph then found that failures
occur as the systemd-udevd process sends SIGKILL to modprobe if
probe on a driver takes over 30 seconds. When this happens probe
will fail on any driver, its why booting on some system will fail
if the driver happens to be a storage related driver. Some folks
have suggested fixing this by modifying kthread_create() to not
leave upon SIGKILL [3], upon review Oleg rejected this change and
the discussion was punted out to systemd to see if the default
timeout could be increased from 30 seconds to 120. The opinion of
the systemd maintainers is that the driver's behavior should
be fixed [4]. Linus seems to agree [5], however more recently even
networking drivers have been reported to fail on probe since just
writing the firmware to a device and kicking it can take easy over
60 seconds [6]. Benjamim was able to trace the issues recently
reported on cxgb4 down to the same systemd-udevd 30 second timeout [6].

This is an alternative solution which enables drivers that are
known to take long to use kthread_run(), this avoids the 30 second
timeout and lets us annotate drivers with long init sequences that
need some love.

[0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1276705
[1] https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1297248
[2] http://lists.freedesktop.org/archives/systemd-devel/2014-March/018006.html
[3] http://thread.gmane.org/gmane.linux.ubuntu.devel.kernel.general/39123
[4] http://article.gmane.org/gmane.comp.sysutils.systemd.devel/17860
[5] http://article.gmane.org/gmane.linux.kernel/1671333
[6] https://bugzilla.novell.com/show_bug.cgi?id=877622

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
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>
Cc: Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>
Cc: Sreekanth Reddy <sreekanth.reddy@avagotech.com>
Cc: Abhijit Mahajan <abhijit.mahajan@avagotech.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: MPT-FusionLinux.pdl@avagotech.com
Cc: linux-scsi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---

A few implementation notes:

1) Two wrappers are used to simply enable the same prototype
   as expected on modules for module_init()

2) The new helpers are stuffed under kthread.h since including
   kthread.h on init.h caused major issues which are not easy
   to resolve, in fact even including kernel.h in init.h cases
   some issues. We could have keep this under init.h if we ifef'd
   on _LINUX_KTHREAD_H as well but this seems a bit cleaner.

 include/linux/kthread.h | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 13d5520..2b5555a 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_KTHREAD_H
 #define _LINUX_KTHREAD_H
 /* Simple interface for creating and stopping kernel threads without mess. */
+#include <linux/init.h>
 #include <linux/err.h>
 #include <linux/sched.h>
 
@@ -128,4 +129,38 @@ bool queue_kthread_work(struct kthread_worker *worker,
 void flush_kthread_work(struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
+#ifndef MODULE
+
+#define module_long_probe_init(x)      __initcall(x);
+#define module_long_probe_exit(x)      __exitcall(x);
+
+#else
+/* To be used by modules which can take over 30 seconds at probe */
+#define module_long_probe_init(initfn)				\
+	static struct task_struct *__init_thread;		\
+	static int _long_probe_##initfn(void *arg)		\
+	{							\
+		return initfn();				\
+	}							\
+	static inline __init int __long_probe_##initfn(void)	\
+	{							\
+		__init_thread = kthread_run(_long_probe_##initfn,\
+					    NULL,		\
+					    #initfn);		\
+		if (IS_ERR(__init_thread))			\
+			return PTR_ERR(__init_thread);		\
+		return 0;					\
+	}							\
+	module_init(__long_probe_##initfn);
+/* To be used by modules that require module_long_probe_init() */
+#define module_long_probe_exit(exitfn)				\
+	static inline void __long_probe_##exitfn(void)		\
+	{							\
+		exitfn();					\
+		if (__init_thread)				\
+			kthread_stop(__init_thread);		\
+	}							\
+	module_exit(__long_probe_##exitfn);
+#endif /* MODULE */
+
 #endif /* _LINUX_KTHREAD_H */
-- 
2.0.3
