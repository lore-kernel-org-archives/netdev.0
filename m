From: akpm@osdl.org
Subject: [patch 1/2] cancel_rearming_delayed_work()
Date: Sun, 30 Jan 2005 22:33:01 -0800
Message-ID: <200501310633.j0V6X0l01364@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org, arjan@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Add library functions to reliably kill off a delayed work whose handler
re-adds the delayed work.  One for keventd, one for caller-owned workqueues.
DESC
make cancel_rearming_delayed_workqueue static
EDESC
From: Arjan van de Ven <arjan@infradead.org>

cancel_rearming_delayed_workqueue() is only used inside workqueue.c; make
this function static (the more useful wrapper around it later in that
function remains non-static and exported)

Signed-off-by: Arjan van de Ven <arjan@infradead.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/linux/workqueue.h |    1 +
 25-akpm/kernel/workqueue.c        |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff -puN kernel/workqueue.c~cancel_rearming_delayed_work kernel/workqueue.c
--- 25/kernel/workqueue.c~cancel_rearming_delayed_work	2004-11-30 23:46:09.387318016 -0800
+++ 25-akpm/kernel/workqueue.c	2004-11-30 23:46:21.763436560 -0800
@@ -423,6 +423,30 @@ void flush_scheduled_work(void)
 	flush_workqueue(keventd_wq);
 }
 
+/**
+ * cancel_rearming_delayed_workqueue - reliably kill off a delayed
+ *			work whose handler rearms the delayed work.
+ * @wq:   the controlling workqueue structure
+ * @work: the delayed work struct
+ */
+static void cancel_rearming_delayed_workqueue(struct workqueue_struct *wq,
+					struct work_struct *work)
+{
+	while (!cancel_delayed_work(work))
+		flush_workqueue(wq);
+}
+
+/**
+ * cancel_rearming_delayed_work - reliably kill off a delayed keventd
+ *			work whose handler rearms the delayed work.
+ * @work: the delayed work struct
+ */
+void cancel_rearming_delayed_work(struct work_struct *work)
+{
+	cancel_rearming_delayed_workqueue(keventd_wq, work);
+}
+EXPORT_SYMBOL(cancel_rearming_delayed_work);
+
 int keventd_up(void)
 {
 	return keventd_wq != NULL;
diff -puN include/linux/workqueue.h~cancel_rearming_delayed_work include/linux/workqueue.h
--- 25/include/linux/workqueue.h~cancel_rearming_delayed_work	2004-11-30 23:46:09.388317864 -0800
+++ 25-akpm/include/linux/workqueue.h	2004-11-30 23:46:21.762436712 -0800
@@ -70,6 +70,7 @@ extern int current_is_keventd(void);
 extern int keventd_up(void);
 
 extern void init_workqueues(void);
+void cancel_rearming_delayed_work(struct work_struct *work);
 
 /*
  * Kill off a pending schedule_delayed_work().  Note that the work callback
_
