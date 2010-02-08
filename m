From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 11/41] CAPI: Rework application locking
Date: Mon,  8 Feb 2010 21:12:15 +0100
Message-ID: <6910ecb2ed7918dcb79d22c7c1545d2fcdaa8473.1265659934.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop the application rw-lock in favour of RCU. This synchronizes
capi20_release against capi_ctr_handle_message which may dereference an
application from (soft-)IRQ context. Any other access to the application
list is now protected by the capi_controller_lock as well. This also
allows to safely inspect applications for /proc dumping by holding
capi_controller_lock.

At this chance, drop some useless release_in_progress checks where we
obtained the application pointer from the list (which becomes NULL on
release_in_progress).

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c      |   52 +++++++++++++++++-----------------------
 drivers/isdn/capi/kcapi_proc.c |   11 +++++---
 2 files changed, 29 insertions(+), 34 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index a99f7e3..0b4c8a7 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -34,6 +34,7 @@
 #include <linux/b1lli.h>
 #endif
 #include <linux/mutex.h>
+#include <linux/rcupdate.h>
 
 static int showcapimsgs = 0;
 
@@ -64,8 +65,6 @@ DEFINE_MUTEX(capi_drivers_lock);
 struct capi_ctr *capi_controller[CAPI_MAXCONTR];
 DEFINE_MUTEX(capi_controller_lock);
 
-static DEFINE_RWLOCK(application_lock);
-
 struct capi20_appl *capi_applications[CAPI_MAXAPPL];
 
 static int ncontrollers;
@@ -103,7 +102,7 @@ static inline struct capi20_appl *get_capi_appl_by_nr(u16 applid)
 	if (applid - 1 >= CAPI_MAXAPPL)
 		return NULL;
 
-	return capi_applications[applid - 1];
+	return rcu_dereference(capi_applications[applid - 1]);
 }
 
 /* -------- util functions ------------------------------------ */
@@ -186,7 +185,7 @@ static void notify_up(u32 contr)
 
 		for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
 			ap = get_capi_appl_by_nr(applid);
-			if (!ap || ap->release_in_progress)
+			if (!ap)
 				continue;
 			register_appl(ctr, applid, &ap->rparam);
 		}
@@ -216,7 +215,7 @@ static void ctr_down(struct capi_ctr *ctr, int new_state)
 
 	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
 		ap = get_capi_appl_by_nr(applid);
-		if (ap && !ap->release_in_progress)
+		if (ap)
 			capi_ctr_put(ctr);
 	}
 
@@ -336,7 +335,6 @@ void capi_ctr_handle_message(struct capi_ctr *ctr, u16 appl,
 	struct capi20_appl *ap;
 	int showctl = 0;
 	u8 cmd, subcmd;
-	unsigned long flags;
 	_cdebbuf *cdb;
 
 	if (ctr->state != CAPI_CTR_RUNNING) {
@@ -384,10 +382,10 @@ void capi_ctr_handle_message(struct capi_ctr *ctr, u16 appl,
 
 	}
 
-	read_lock_irqsave(&application_lock, flags);
+	rcu_read_lock();
 	ap = get_capi_appl_by_nr(CAPIMSG_APPID(skb->data));
-	if ((!ap) || (ap->release_in_progress)) {
-		read_unlock_irqrestore(&application_lock, flags);
+	if (!ap) {
+		rcu_read_unlock();
 		cdb = capi_message2str(skb->data);
 		if (cdb) {
 			printk(KERN_ERR "kcapi: handle_message: applid %d state released (%s)\n",
@@ -401,7 +399,7 @@ void capi_ctr_handle_message(struct capi_ctr *ctr, u16 appl,
 	}
 	skb_queue_tail(&ap->recv_queue, skb);
 	schedule_work(&ap->recv_work);
-	read_unlock_irqrestore(&application_lock, flags);
+	rcu_read_unlock();
 
 	return;
 
@@ -656,40 +654,35 @@ u16 capi20_register(struct capi20_appl *ap)
 {
 	int i;
 	u16 applid;
-	unsigned long flags;
 
 	DBG("");
 
 	if (ap->rparam.datablklen < 128)
 		return CAPI_LOGBLKSIZETOSMALL;
 
-	write_lock_irqsave(&application_lock, flags);
+	ap->nrecvctlpkt = 0;
+	ap->nrecvdatapkt = 0;
+	ap->nsentctlpkt = 0;
+	ap->nsentdatapkt = 0;
+	mutex_init(&ap->recv_mtx);
+	skb_queue_head_init(&ap->recv_queue);
+	INIT_WORK(&ap->recv_work, recv_handler);
+	ap->release_in_progress = 0;
+
+	mutex_lock(&capi_controller_lock);
 
 	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
 		if (capi_applications[applid - 1] == NULL)
 			break;
 	}
 	if (applid > CAPI_MAXAPPL) {
-		write_unlock_irqrestore(&application_lock, flags);
+		mutex_unlock(&capi_controller_lock);
 		return CAPI_TOOMANYAPPLS;
 	}
 
 	ap->applid = applid;
 	capi_applications[applid - 1] = ap;
 
-	ap->nrecvctlpkt = 0;
-	ap->nrecvdatapkt = 0;
-	ap->nsentctlpkt = 0;
-	ap->nsentdatapkt = 0;
-	mutex_init(&ap->recv_mtx);
-	skb_queue_head_init(&ap->recv_queue);
-	INIT_WORK(&ap->recv_work, recv_handler);
-	ap->release_in_progress = 0;
-
-	write_unlock_irqrestore(&application_lock, flags);
-	
-	mutex_lock(&capi_controller_lock);
-
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
 		if (!capi_controller[i] ||
 		    capi_controller[i]->state != CAPI_CTR_RUNNING)
@@ -721,16 +714,15 @@ EXPORT_SYMBOL(capi20_register);
 u16 capi20_release(struct capi20_appl *ap)
 {
 	int i;
-	unsigned long flags;
 
 	DBG("applid %#x", ap->applid);
 
-	write_lock_irqsave(&application_lock, flags);
+	mutex_lock(&capi_controller_lock);
+
 	ap->release_in_progress = 1;
 	capi_applications[ap->applid - 1] = NULL;
-	write_unlock_irqrestore(&application_lock, flags);
 
-	mutex_lock(&capi_controller_lock);
+	synchronize_rcu();
 
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
 		if (!capi_controller[i] ||
diff --git a/drivers/isdn/capi/kcapi_proc.c b/drivers/isdn/capi/kcapi_proc.c
index 3e6e17a..ea2dff6 100644
--- a/drivers/isdn/capi/kcapi_proc.c
+++ b/drivers/isdn/capi/kcapi_proc.c
@@ -139,9 +139,11 @@ static const struct file_operations proc_contrstats_ops = {
 //      applid nrecvctlpkt nrecvdatapkt nsentctlpkt nsentdatapkt
 // ---------------------------------------------------------------------------
 
-static void *
-applications_start(struct seq_file *seq, loff_t *pos)
+static void *applications_start(struct seq_file *seq, loff_t *pos)
+	__acquires(capi_controller_lock)
 {
+	mutex_lock(&capi_controller_lock);
+
 	if (*pos < CAPI_MAXAPPL)
 		return &capi_applications[*pos];
 
@@ -158,9 +160,10 @@ applications_next(struct seq_file *seq, void *v, loff_t *pos)
 	return NULL;
 }
 
-static void
-applications_stop(struct seq_file *seq, void *v)
+static void applications_stop(struct seq_file *seq, void *v)
+	__releases(capi_controller_lock)
 {
+	mutex_unlock(&capi_controller_lock);
 }
 
 static int
-- 
1.6.0.2
