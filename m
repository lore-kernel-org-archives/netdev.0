From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 13/13] workqueue: Convert callback to use from_timer()
Date: Wed,  4 Oct 2017 16:27:07 -0700
Message-ID: <1507159627-127660-14-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        Chris Metcalf <cmetcalf-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Harish Patil <harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Julian Wiedmann <jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Manish Chopra <manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Mark Gross <mark.gross-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer
to all timer callbacks, switch workqueue to use from_timer() and pass the
timer pointer explicitly.

Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 include/linux/workqueue.h | 15 ++++++++-------
 kernel/workqueue.c        |  7 +++----
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index f4960260feaf..f3c47a05fd06 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -17,7 +17,7 @@ struct workqueue_struct;
 
 struct work_struct;
 typedef void (*work_func_t)(struct work_struct *work);
-void delayed_work_timer_fn(unsigned long __data);
+void delayed_work_timer_fn(struct timer_list *t);
 
 /*
  * The first word is the work queue pointer and the flags rolled into
@@ -175,8 +175,8 @@ struct execute_work {
 
 #define __DELAYED_WORK_INITIALIZER(n, f, tflags) {			\
 	.work = __WORK_INITIALIZER((n).work, (f)),			\
-	.timer = __TIMER_INITIALIZER(delayed_work_timer_fn,		\
-				     (unsigned long)&(n),		\
+	.timer = __TIMER_INITIALIZER((TIMER_FUNC_TYPE)delayed_work_timer_fn,\
+				     (TIMER_DATA_TYPE)&(n.timer),	\
 				     (tflags) | TIMER_IRQSAFE),		\
 	}
 
@@ -241,8 +241,9 @@ static inline unsigned int work_static(struct work_struct *work) { return 0; }
 #define __INIT_DELAYED_WORK(_work, _func, _tflags)			\
 	do {								\
 		INIT_WORK(&(_work)->work, (_func));			\
-		__setup_timer(&(_work)->timer, delayed_work_timer_fn,	\
-			      (unsigned long)(_work),			\
+		__setup_timer(&(_work)->timer,				\
+			      (TIMER_FUNC_TYPE)delayed_work_timer_fn,	\
+			      (TIMER_DATA_TYPE)&(_work)->timer,		\
 			      (_tflags) | TIMER_IRQSAFE);		\
 	} while (0)
 
@@ -250,8 +251,8 @@ static inline unsigned int work_static(struct work_struct *work) { return 0; }
 	do {								\
 		INIT_WORK_ONSTACK(&(_work)->work, (_func));		\
 		__setup_timer_on_stack(&(_work)->timer,			\
-				       delayed_work_timer_fn,		\
-				       (unsigned long)(_work),		\
+				       (TIMER_FUNC_TYPE)delayed_work_timer_fn,\
+				       (TIMER_DATA_TYPE)&(_work)->timer,\
 				       (_tflags) | TIMER_IRQSAFE);	\
 	} while (0)
 
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index a5361fc6215d..c77fdf6bf24f 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1492,9 +1492,9 @@ bool queue_work_on(int cpu, struct workqueue_struct *wq,
 }
 EXPORT_SYMBOL(queue_work_on);
 
-void delayed_work_timer_fn(unsigned long __data)
+void delayed_work_timer_fn(struct timer_list *t)
 {
-	struct delayed_work *dwork = (struct delayed_work *)__data;
+	struct delayed_work *dwork = from_timer(dwork, t, timer);
 
 	/* should have been called from irqsafe timer with irq already off */
 	__queue_work(dwork->cpu, dwork->wq, &dwork->work);
@@ -1508,8 +1508,7 @@ static void __queue_delayed_work(int cpu, struct workqueue_struct *wq,
 	struct work_struct *work = &dwork->work;
 
 	WARN_ON_ONCE(!wq);
-	WARN_ON_ONCE(timer->function != delayed_work_timer_fn ||
-		     timer->data != (unsigned long)dwork);
+	WARN_ON_ONCE(timer->function != (TIMER_FUNC_TYPE)delayed_work_timer_fn);
 	WARN_ON_ONCE(timer_pending(timer));
 	WARN_ON_ONCE(!list_empty(&work->entry));
 
-- 
2.7.4
