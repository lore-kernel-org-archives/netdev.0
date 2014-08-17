From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init()
	and module_long_probe_exit()
Date: Sun, 17 Aug 2014 19:46:24 +0200
Message-ID: <20140817174624.GE3347@wotan.suse.de>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com> <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com> <20140813175101.GA7156@redhat.com> <20140814231028.GQ21930@wotan.suse.de> <20140815143902.GB13222@redhat.com> <20140816025007.GB3347@wotan.suse.de> <s5h1tsfwqi2.wl-tiwai@suse.de> <20140817122527.GA30546@redhat.com> <20140817124803.GA31996@redhat.com> <20140817125505.GA32429@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Takashi Iwai <tiwai@suse.de>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140817125505.GA32429@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 17, 2014 at 02:55:05PM +0200, Oleg Nesterov wrote:
> Damn, sorry for noise ;)
> 
> I was going to suggest to introduce module_put_and_exit() to simplify
> this and potentially other users, but it already exists. So this code
> can use it too without additional complications.

In the last iteration that I have stress tested for corner cases I just
get_task_struct() on the init and then put_task_struct() at the exit, is that
fine too or are there reasons to prefer the module stuff?

Note that technically the issue is not that init is taking long its probe that
takes long but since the driver core runs it immediately after init on buses
that autoprobe probe is also then collaterally of concern, but see the other
reply for that.

Moving this to device.h worked better as you don't have to add extra
lines on drivers to include kthread.h.

diff --git a/include/linux/device.h b/include/linux/device.h
index 43d183a..dc7c0ba7 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -27,6 +27,7 @@
 #include <linux/ratelimit.h>
 #include <linux/uidgid.h>
 #include <linux/gfp.h>
+#include <linux/kthread.h>
 #include <asm/device.h>
 
 struct device;
@@ -1227,4 +1228,72 @@ static void __exit __driver##_exit(void) \
 } \
 module_exit(__driver##_exit);
 
+#ifndef MODULE
+
+#define module_long_probe_init(x)      __initcall(x);
+#define module_long_probe_exit(x)      __exitcall(x);
+
+#else
+/*
+ * Linux device drivers must strive to handle driver initialization
+ * within less than 30 seconds, if device probing takes longer
+ * for whatever reason asynchronous probing of devices / loading
+ * firmware should be used. If a driver takes longer than 30 second
+ * on the initialization path this macro can be used to help annotate
+ * the driver as needing work and prevent userspace init processes
+ * from killing drivers not loading within a specified timeout.
+ *
+ * module probe will return immediately and since we are not waiting
+ * for the kthread to end on init we won't be able to inform userspace
+ * of the result of the full init sequence. Probing should initialize
+ * the device driver, probing for devices should be handled asynchronously
+ * behind the scenes.
+ *
+ * Drivers that use this helper should be considered broken and in need
+ * of some serious love.
+ */
+#define module_long_probe_init(initfn)				\
+	static struct task_struct *__init_thread;		\
+	static int _long_probe_##initfn(void *arg)		\
+	{							\
+		return initfn();				\
+	}							\
+	static inline __init int __long_probe_##initfn(void)	\
+	{							\
+		__init_thread = kthread_create(_long_probe_##initfn,\
+					       NULL,		\
+					       #initfn);	\
+		if (IS_ERR(__init_thread))			\
+			return PTR_ERR(__init_thread);		\
+		/*						\
+		 * callback won't check kthread_should_stop()	\
+		 * before bailing, so we need to protect it	\
+		 * before running it.				\
+		 */						\
+		get_task_struct(__init_thread); 		\
+		wake_up_process(__init_thread);			\
+		return 0;					\
+	}							\
+	module_init(__long_probe_##initfn);
+
+/* To be used by modules that require module_long_probe_init() */
+#define module_long_probe_exit(exitfn)				\
+	static inline void __long_probe_##exitfn(void)		\
+	{							\
+		int err;					\
+		/*						\
+		 * exitfn() will not be run if the driver's	\
+		 * real probe which is run on the kthread	\
+		 * failed for whatever reason, this will	\
+		 * wait for it to end.				\
+		 */						\
+		err = kthread_stop(__init_thread);		\
+		if (!err)					\
+			exitfn();				\
+		put_task_struct(__init_thread);	 		\
+	}							\
+	module_exit(__long_probe_##exitfn);
+
+#endif /* MODULE */
+
 #endif /* _DEVICE_H_ */
