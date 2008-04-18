From: Mark Asselstine <mark.asselstine@windriver.com>
Subject: [PATCH] Removal of debug code containing deprecated calls to cli()/sti()
Date: Fri, 18 Apr 2008 10:51:02 -0400
Message-ID: <1208530262-8555-1-git-send-email-mark.asselstine@windriver.com>
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org, asselsm@gmail.com,
	Mark Asselstine <mark.asselstine@windriver.com>
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37647 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019AbYDROvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 10:51:09 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code within NS_DEBUG_SPINLOCKS contained deprecated cli()/sti() function calls.
NS_DEBUG_SPINLOCKS and the associated code seems to be of little use these days
so the strategy of removing this code rather then updating it to use spinlocks
has been taken.

Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
---
 drivers/atm/nicstar.c |   72 -------------------------------------------------
 drivers/atm/nicstar.h |   12 --------
 2 files changed, 0 insertions(+), 84 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 0c205b0..230ccc5 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -125,84 +125,12 @@
 #define ATM_SKB(s) (&(s)->atm)
 #endif
 
-   /* Spinlock debugging stuff */
-#ifdef NS_DEBUG_SPINLOCKS /* See nicstar.h */
-#define ns_grab_int_lock(card,flags) \
- do { \
-    unsigned long nsdsf, nsdsf2; \
-    local_irq_save(flags); \
-    save_flags(nsdsf); cli();\
-    if (nsdsf & (1<<9)) printk ("nicstar.c: ints %sabled -> enabled.\n", \
-                                (flags)&(1<<9)?"en":"dis"); \
-    if (spin_is_locked(&(card)->int_lock) && \
-        (card)->cpu_int == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) int_lock already locked at line %d (cpu %d)\n", \
-              __LINE__, smp_processor_id(), (card)->has_int_lock, \
-              (card)->cpu_int); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    if (spin_is_locked(&(card)->res_lock) && \
-        (card)->cpu_res == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) res_lock locked at line %d (cpu %d)(trying int)\n", \
-              __LINE__, smp_processor_id(), (card)->has_res_lock, \
-              (card)->cpu_res); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    spin_lock_irq(&(card)->int_lock); \
-    (card)->has_int_lock = __LINE__; \
-    (card)->cpu_int = smp_processor_id(); \
-    restore_flags(nsdsf); } while (0)
-#define ns_grab_res_lock(card,flags) \
- do { \
-    unsigned long nsdsf, nsdsf2; \
-    local_irq_save(flags); \
-    save_flags(nsdsf); cli();\
-    if (nsdsf & (1<<9)) printk ("nicstar.c: ints %sabled -> enabled.\n", \
-                                (flags)&(1<<9)?"en":"dis"); \
-    if (spin_is_locked(&(card)->res_lock) && \
-        (card)->cpu_res == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) res_lock already locked at line %d (cpu %d)\n", \
-              __LINE__, smp_processor_id(), (card)->has_res_lock, \
-              (card)->cpu_res); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    spin_lock_irq(&(card)->res_lock); \
-    (card)->has_res_lock = __LINE__; \
-    (card)->cpu_res = smp_processor_id(); \
-    restore_flags(nsdsf); } while (0)
-#define ns_grab_scq_lock(card,scq,flags) \
- do { \
-    unsigned long nsdsf, nsdsf2; \
-    local_irq_save(flags); \
-    save_flags(nsdsf); cli();\
-    if (nsdsf & (1<<9)) printk ("nicstar.c: ints %sabled -> enabled.\n", \
-                                (flags)&(1<<9)?"en":"dis"); \
-    if (spin_is_locked(&(scq)->lock) && \
-        (scq)->cpu_lock == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) this scq_lock already locked at line %d (cpu %d)\n", \
-              __LINE__, smp_processor_id(), (scq)->has_lock, \
-              (scq)->cpu_lock); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    if (spin_is_locked(&(card)->res_lock) && \
-        (card)->cpu_res == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) res_lock locked at line %d (cpu %d)(trying scq)\n", \
-              __LINE__, smp_processor_id(), (card)->has_res_lock, \
-              (card)->cpu_res); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    spin_lock_irq(&(scq)->lock); \
-    (scq)->has_lock = __LINE__; \
-    (scq)->cpu_lock = smp_processor_id(); \
-    restore_flags(nsdsf); } while (0)
-#else /* !NS_DEBUG_SPINLOCKS */
 #define ns_grab_int_lock(card,flags) \
         spin_lock_irqsave(&(card)->int_lock,(flags))
 #define ns_grab_res_lock(card,flags) \
         spin_lock_irqsave(&(card)->res_lock,(flags))
 #define ns_grab_scq_lock(card,scq,flags) \
         spin_lock_irqsave(&(scq)->lock,flags)
-#endif /* NS_DEBUG_SPINLOCKS */
 
 
 /* Function declarations ******************************************************/
diff --git a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
index 5997bcb..6010e3d 100644
--- a/drivers/atm/nicstar.h
+++ b/drivers/atm/nicstar.h
@@ -28,8 +28,6 @@
 
 /* Options ********************************************************************/
 
-#undef NS_DEBUG_SPINLOCKS
-
 #define NS_MAX_CARDS 4		/* Maximum number of NICStAR based cards
 				   controlled by the device driver. Must
                                    be <= 5 */
@@ -721,10 +719,6 @@ typedef struct scq_info
    wait_queue_head_t scqfull_waitq;
    volatile char full;			/* SCQ full indicator */
    spinlock_t lock;			/* SCQ spinlock */
-#ifdef NS_DEBUG_SPINLOCKS
-   volatile long has_lock;
-   volatile int cpu_lock;
-#endif /* NS_DEBUG_SPINLOCKS */
 } scq_info;
 
 
@@ -810,12 +804,6 @@ typedef struct ns_dev
    unsigned intcnt;			/* Interrupt counter */
    spinlock_t int_lock;		/* Interrupt lock */
    spinlock_t res_lock;		/* Card resource lock */
-#ifdef NS_DEBUG_SPINLOCKS
-   volatile long has_int_lock;
-   volatile int cpu_int;
-   volatile long has_res_lock;
-   volatile int cpu_res;
-#endif /* NS_DEBUG_SPINLOCKS */
 } ns_dev;
 
 
-- 
1.5.4.3

