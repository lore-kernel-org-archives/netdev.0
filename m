From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: bcm43xx for d80211 softirq loop
Date: Mon, 14 Aug 2006 10:21:14 +0200
Message-ID: <44E0327A.1080300@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
	<44E0300D.1000402@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <44E0300D.1000402-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
List-Unsubscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://bat.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Here's the patch I used to find out which tasklet was giving me a hard 
time with bcm43xx and d80211. I don't really expect this to be applied 
anywhere but didn't want to sit on it either.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

--- wireless-dev.orig/include/linux/interrupt.h    2006-08-13 
00:49:46.346865273 +0200
+++ wireless-dev/include/linux/interrupt.h    2006-08-13 
16:23:39.449545098 +0200
@@ -14,6 +14,7 @@
 #include <asm/atomic.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
+#include <linux/stringify.h>
 
 /*
  * These correspond to the IORESOURCE_IRQ_* defines in
@@ -267,6 +268,10 @@ struct tasklet_struct
     atomic_t count;
     void (*func)(unsigned long);
     unsigned long data;
+#ifdef CONFIG_DEBUG_TASKLETS
+    char *name;
+    unsigned int reschedule_count;
+#endif
 };
 
 #define DECLARE_TASKLET(name, func, data) \
@@ -348,8 +353,25 @@ static inline void tasklet_hi_enable(str
 
 extern void tasklet_kill(struct tasklet_struct *t);
 extern void tasklet_kill_immediate(struct tasklet_struct *t, unsigned 
int cpu);
-extern void tasklet_init(struct tasklet_struct *t,
-             void (*func)(unsigned long), unsigned long data);
+extern void _tasklet_init(struct tasklet_struct *t,
+              void (*func)(unsigned long), unsigned long data);
+#ifndef CONFIG_DEBUG_TASKLETS
+#define tasklet_init    _tasklet_init
+/* ignore name in the non-debug version, use a macro so the
+ * compiler can discard the string... */
+#define tasklet_init_named(t, func, data, name)    \
+    _tasklet_init(t, func, data)
+#else
+#define tasklet_init(t, func, data)    do {        \
+    _tasklet_init(t, func, data);            \
+    (t)->name = __FILE__ ":" __stringify(__LINE__);    \
+    } while (0)
+#define tasklet_init_named(t, func, data, name)    \
+    do {                    \
+    _tasklet_init(t, func, data);        \
+    (t)->name = (name);            \
+    } while (0)
+#endif
 
 /*
  * Autoprobing for irqs:
--- wireless-dev.orig/kernel/softirq.c    2006-08-13 00:56:37.206865273 
+0200
+++ wireless-dev/kernel/softirq.c    2006-08-13 16:34:31.079545098 +0200
@@ -385,9 +385,22 @@ static void tasklet_action(struct softir
                 if (!test_and_clear_bit(TASKLET_STATE_SCHED, &t->state))
                     BUG();
                 t->func(t->data);
+#ifdef CONFIG_DEBUG_TASKLETS
+                t->reschedule_count = 0;
+#endif
                 tasklet_unlock(t);
                 continue;
             }
+#ifdef CONFIG_DEBUG_TASKLETS
+            /* 10000 is arbitrary... how much should it be?
+             * on my system, 10000 is quite a long time... */
+            if (t->reschedule_count++ > 10000) {
+                printk(KERN_ERR "tasklet %s is scheduled but hasn't been"
+                    " enabled for too long!\n", t->name);
+                tasklet_unlock(t);
+                continue;
+            }
+#endif
             tasklet_unlock(t);
         }
 
@@ -433,7 +446,7 @@ static void tasklet_hi_action(struct sof
 }
 
 
-void tasklet_init(struct tasklet_struct *t,
+void _tasklet_init(struct tasklet_struct *t,
           void (*func)(unsigned long), unsigned long data)
 {
     t->next = NULL;
@@ -443,7 +456,7 @@ void tasklet_init(struct tasklet_struct
     t->data = data;
 }
 
-EXPORT_SYMBOL(tasklet_init);
+EXPORT_SYMBOL(_tasklet_init);
 
 void tasklet_kill(struct tasklet_struct *t)
 {
--- wireless-dev.orig/lib/Kconfig.debug    2006-08-13 01:00:56.016865273 
+0200
+++ wireless-dev/lib/Kconfig.debug    2006-08-13 16:00:15.419545098 +0200
@@ -93,6 +93,16 @@ config SCHEDSTATS
       application, you can say N to avoid the very slight overhead
       this adds.
 
+config DEBUG_TASKLETS
+    bool "Debug runaway tasklets"
+    depends on DEBUG_KERNEL
+    help
+      If you say Y here, additional code will be inserted into the
+      lowlevel tasklet code in order to debug tasklets that are
+      scheduled but not enabled. If such a tasklet is found and
+      not enabled within a number of iterations, it is un-scheduled
+      and the kernel reports it.
+
 config DEBUG_SLAB
     bool "Debug slab memory allocations"
     depends on DEBUG_KERNEL && SLAB
