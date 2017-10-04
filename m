From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 11/13] timer: Remove expires argument from __TIMER_INITIALIZER()
Date: Wed,  4 Oct 2017 16:27:05 -0700
Message-ID: <1507159627-127660-12-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
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
        Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Manish Chopra <manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Mark Gross <mark.gross-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Martin K. Petersen" <ma
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The expires field is normally initialized during the first mod_timer()
call. It was unused by all callers, so remove it from the macro.

Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 include/linux/kthread.h   | 2 +-
 include/linux/timer.h     | 5 ++---
 include/linux/workqueue.h | 2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 82e197eeac91..0d622b350d3f 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -117,7 +117,7 @@ struct kthread_delayed_work {
 #define KTHREAD_DELAYED_WORK_INIT(dwork, fn) {				\
 	.work = KTHREAD_WORK_INIT((dwork).work, (fn)),			\
 	.timer = __TIMER_INITIALIZER(kthread_delayed_work_timer_fn,	\
-				     0, (unsigned long)&(dwork),	\
+				     (unsigned long)&(dwork),		\
 				     TIMER_IRQSAFE),			\
 	}
 
diff --git a/include/linux/timer.h b/include/linux/timer.h
index 91e5a2cc81b5..10685c33e679 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -63,10 +63,9 @@ struct timer_list {
 
 #define TIMER_TRACE_FLAGMASK	(TIMER_MIGRATING | TIMER_DEFERRABLE | TIMER_PINNED | TIMER_IRQSAFE)
 
-#define __TIMER_INITIALIZER(_function, _expires, _data, _flags) { \
+#define __TIMER_INITIALIZER(_function, _data, _flags) {		\
 		.entry = { .next = TIMER_ENTRY_STATIC },	\
 		.function = (_function),			\
-		.expires = (_expires),				\
 		.data = (_data),				\
 		.flags = (_flags),				\
 		__TIMER_LOCKDEP_MAP_INITIALIZER(		\
@@ -75,7 +74,7 @@ struct timer_list {
 
 #define DEFINE_TIMER(_name, _function)				\
 	struct timer_list _name =				\
-		__TIMER_INITIALIZER(_function, 0, 0, 0)
+		__TIMER_INITIALIZER(_function, 0, 0)
 
 void init_timer_key(struct timer_list *timer, unsigned int flags,
 		    const char *name, struct lock_class_key *key);
diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 1c49431f3121..f4960260feaf 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -176,7 +176,7 @@ struct execute_work {
 #define __DELAYED_WORK_INITIALIZER(n, f, tflags) {			\
 	.work = __WORK_INITIALIZER((n).work, (f)),			\
 	.timer = __TIMER_INITIALIZER(delayed_work_timer_fn,		\
-				     0, (unsigned long)&(n),		\
+				     (unsigned long)&(n),		\
 				     (tflags) | TIMER_IRQSAFE),		\
 	}
 
-- 
2.7.4
