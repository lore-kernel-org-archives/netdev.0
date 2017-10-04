From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 12/13] kthread: Convert callback to use from_timer()
Date: Wed,  4 Oct 2017 16:27:06 -0700
Message-ID: <1507159627-127660-13-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>,
        Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len Brown <len.brown@intel.com>,
        Manish Chopra <ma
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer
to all timer callbacks, switch kthread to use from_timer() and pass the
timer pointer explicitly.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Mladek <pmladek@suse.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/kthread.h | 10 +++++-----
 kernel/kthread.c        | 10 ++++------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 0d622b350d3f..35cbe3b0ce5b 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -75,7 +75,7 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
  */
 struct kthread_work;
 typedef void (*kthread_work_func_t)(struct kthread_work *work);
-void kthread_delayed_work_timer_fn(unsigned long __data);
+void kthread_delayed_work_timer_fn(struct timer_list *t);
 
 enum {
 	KTW_FREEZABLE		= 1 << 0,	/* freeze during suspend */
@@ -116,8 +116,8 @@ struct kthread_delayed_work {
 
 #define KTHREAD_DELAYED_WORK_INIT(dwork, fn) {				\
 	.work = KTHREAD_WORK_INIT((dwork).work, (fn)),			\
-	.timer = __TIMER_INITIALIZER(kthread_delayed_work_timer_fn,	\
-				     (unsigned long)&(dwork),		\
+	.timer = __TIMER_INITIALIZER((TIMER_FUNC_TYPE)kthread_delayed_work_timer_fn,\
+				     (TIMER_DATA_TYPE)&(dwork.timer),	\
 				     TIMER_IRQSAFE),			\
 	}
 
@@ -164,8 +164,8 @@ extern void __kthread_init_worker(struct kthread_worker *worker,
 	do {								\
 		kthread_init_work(&(dwork)->work, (fn));		\
 		__setup_timer(&(dwork)->timer,				\
-			      kthread_delayed_work_timer_fn,		\
-			      (unsigned long)(dwork),			\
+			      (TIMER_FUNC_TYPE)kthread_delayed_work_timer_fn,\
+			      (TIMER_DATA_TYPE)&(dwork)->timer,		\
 			      TIMER_IRQSAFE);				\
 	} while (0)
 
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 1c19edf82427..ba3992c8c375 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -798,15 +798,14 @@ EXPORT_SYMBOL_GPL(kthread_queue_work);
 /**
  * kthread_delayed_work_timer_fn - callback that queues the associated kthread
  *	delayed work when the timer expires.
- * @__data: pointer to the data associated with the timer
+ * @t: pointer to the expired timer
  *
  * The format of the function is defined by struct timer_list.
  * It should have been called from irqsafe timer with irq already off.
  */
-void kthread_delayed_work_timer_fn(unsigned long __data)
+void kthread_delayed_work_timer_fn(struct timer_list *t)
 {
-	struct kthread_delayed_work *dwork =
-		(struct kthread_delayed_work *)__data;
+	struct kthread_delayed_work *dwork = from_timer(dwork, t, timer);
 	struct kthread_work *work = &dwork->work;
 	struct kthread_worker *worker = work->worker;
 
@@ -837,8 +836,7 @@ void __kthread_queue_delayed_work(struct kthread_worker *worker,
 	struct timer_list *timer = &dwork->timer;
 	struct kthread_work *work = &dwork->work;
 
-	WARN_ON_ONCE(timer->function != kthread_delayed_work_timer_fn ||
-		     timer->data != (unsigned long)dwork);
+	WARN_ON_ONCE(timer->function != (TIMER_FUNC_TYPE)kthread_delayed_work_timer_fn);
 
 	/*
 	 * If @delay is 0, queue @dwork->work immediately.  This is for
-- 
2.7.4
