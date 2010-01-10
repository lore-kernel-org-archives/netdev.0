From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 09/31] CAPI: Rework controller state notifier
Date: Sun, 10 Jan 2010 11:24:18 +0100
Message-ID: <8e3958099a662c289ade88dc1992916ff5e228cf.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:60059 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab0AVXW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:22:26 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another step towards proper locking: Rework the callback provided to
capidrv for controller state changes. This is so far attached to an
application, which would require us to hold the corresponding lock
across notification calls.

But there is no direct relation between a controller up/down event and
an application, so let's decouple them and provide a notifier call chain
for those events instead. This notifier chain is first of all used
internally. Here we request the highest priority to unsure that
housekeeping work is done before any other notifications. The chain is
exported via [un]register_capictr_notifier to our only user, capidrv, to
replace the racy and unfixable capi20_set_callback.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capidrv.c |   22 ++++++--
 drivers/isdn/capi/kcapi.c   |  112 +++++++++++++++++++-----------------------
 include/linux/kernelcapi.h  |   17 ++-----
 3 files changed, 72 insertions(+), 79 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 52118a9..de11764 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -2209,19 +2209,24 @@ static int capidrv_delcontr(u16 contr)
 }
 
 
-static void lower_callback(unsigned int cmd, u32 contr, void *data)
+static int
+lower_callback(struct notifier_block *nb, unsigned long val, void *v)
 {
+	capi_profile profile;
+	u32 contr = (long)v;
 
-	switch (cmd) {
-	case KCI_CONTRUP:
+	switch (val) {
+	case CAPICTR_UP:
 		printk(KERN_INFO "capidrv: controller %hu upn", contr);
-		(void) capidrv_addcontr(contr, (capi_profile *) data);
+		if (capi20_get_profile(contr, &profile) == CAPI_NOERROR)
+			(void) capidrv_addcontr(contr, &profile);
 		break;
-	case KCI_CONTRDOWN:
+	case CAPICTR_DOWN:
 		printk(KERN_INFO "capidrv: controller %hu downn", contr);
 		(void) capidrv_delcontr(contr);
 		break;
 	}
+	return NOTIFY_OK;
 }
 
 /*
@@ -2283,6 +2288,10 @@ static void __exit proc_exit(void)
     }
 }
 
+static struct notifier_block capictr_nb = {
+	.notifier_call = lower_callback,
+};
+
 static int __init capidrv_init(void)
 {
 	capi_profile profile;
@@ -2299,7 +2308,7 @@ static int __init capidrv_init(void)
 		return -EIO;
 	}
 
-	capi20_set_callback(&global.ap, lower_callback);
+	register_capictr_notifier(&capictr_nb);
 
 	errcode = capi20_get_profile(0, &profile);
 	if (errcode != CAPI_NOERROR) {
@@ -2321,6 +2330,7 @@ static int __init capidrv_init(void)
 
 static void __exit capidrv_exit(void)
 {
+	unregister_capictr_notifier(&capictr_nb);
 	capi20_release(&global.ap);
 
 	proc_exit();
diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 3fcc95b..0fda05d 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -44,12 +44,10 @@ module_param(showcapimsgs, uint, 0);
 
 /* ------------------------------------------------------------- */
 
-struct capi_notifier {
+struct capictr_event {
 	struct work_struct work;
-	unsigned int cmd;
+	unsigned int type;
 	u32 controller;
-	u16 applid;
-	u32 ncci;
 };
 
 /* ------------------------------------------------------------- */
@@ -71,6 +69,8 @@ struct capi_ctr *capi_controller[CAPI_MAXCONTR];
 
 static int ncontrollers;
 
+static BLOCKING_NOTIFIER_HEAD(ctr_notifier_list);
+
 /* -------- controller ref counting -------------------------------------- */
 
 static inline struct capi_ctr *
@@ -165,8 +165,6 @@ static void release_appl(struct capi_ctr *ctr, u16 applid)
 	capi_ctr_put(ctr);
 }
 
-/* -------- KCI_CONTRUP --------------------------------------- */
-
 static void notify_up(u32 contr)
 {
 	struct capi20_appl *ap;
@@ -188,16 +186,11 @@ static void notify_up(u32 contr)
 			if (!ap || ap->release_in_progress)
 				continue;
 			register_appl(ctr, applid, &ap->rparam);
-			if (ap->callback && !ap->release_in_progress)
-				ap->callback(KCI_CONTRUP, contr,
-					     &ctr->profile);
 		}
 	} else
 		printk(KERN_WARNING "%s: invalid contr %dn", __func__, contr);
 }
 
-/* -------- KCI_CONTRDOWN ------------------------------------- */
-
 static void ctr_down(struct capi_ctr *ctr)
 {
 	struct capi20_appl *ap;
@@ -215,11 +208,8 @@ static void ctr_down(struct capi_ctr *ctr)
 
 	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
 		ap = get_capi_appl_by_nr(applid);
-		if (ap && !ap->release_in_progress) {
-			if (ap->callback)
-				ap->callback(KCI_CONTRDOWN, ctr->cnr, NULL);
+		if (ap && !ap->release_in_progress)
 			capi_ctr_put(ctr);
-		}
 	}
 }
 
@@ -237,45 +227,63 @@ static void notify_down(u32 contr)
 		printk(KERN_WARNING "%s: invalid contr %dn", __func__, contr);
 }
 
-static void notify_handler(struct work_struct *work)
+static int
+notify_handler(struct notifier_block *nb, unsigned long val, void *v)
 {
-	struct capi_notifier *np =
-		container_of(work, struct capi_notifier, work);
+	u32 contr = (long)v;
 
-	switch (np->cmd) {
-	case KCI_CONTRUP:
-		notify_up(np->controller);
+	switch (val) {
+	case CAPICTR_UP:
+		notify_up(contr);
 		break;
-	case KCI_CONTRDOWN:
-		notify_down(np->controller);
+	case CAPICTR_DOWN:
+		notify_down(contr);
 		break;
 	}
+	return NOTIFY_OK;
+}
+
+static void do_notify_work(struct work_struct *work)
+{
+	struct capictr_event *event =
+		container_of(work, struct capictr_event, work);
 
-	kfree(np);
+	blocking_notifier_call_chain(&ctr_notifier_list, event->type,
+				     (void *)(long)event->controller);
+	kfree(event);
 }
 
 /*
  * The notifier will result in adding/deleteing of devices. Devices can
  * only removed in user process, not in bh.
  */
-static int notify_push(unsigned int cmd, u32 controller, u16 applid, u32 ncci)
+static int notify_push(unsigned int event_type, u32 controller)
 {
-	struct capi_notifier *np = kmalloc(sizeof(*np), GFP_ATOMIC);
+	struct capictr_event *event = kmalloc(sizeof(*event), GFP_ATOMIC);
 
-	if (!np)
+	if (!event)
 		return -ENOMEM;
 
-	INIT_WORK(&np->work, notify_handler);
-	np->cmd = cmd;
-	np->controller = controller;
-	np->applid = applid;
-	np->ncci = ncci;
+	INIT_WORK(&event->work, do_notify_work);
+	event->type = event_type;
+	event->controller = controller;
 
-	schedule_work(&np->work);
+	schedule_work(&event->work);
 	return 0;
 }
 
-	
+int register_capictr_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&ctr_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_capictr_notifier);
+
+int unregister_capictr_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&ctr_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_capictr_notifier);
+
 /* -------- Receiver ------------------------------------------ */
 
 static void recv_handler(struct work_struct *work)
@@ -401,7 +409,7 @@ void capi_ctr_ready(struct capi_ctr *ctr)
 	printk(KERN_NOTICE "kcapi: controller [%03d] "%s" ready.n",
 	       ctr->cnr, ctr->name);
 
-	notify_push(KCI_CONTRUP, ctr->cnr, 0, 0);
+	notify_push(CAPICTR_UP, ctr->cnr);
 }
 
 EXPORT_SYMBOL(capi_ctr_ready);
@@ -418,7 +426,7 @@ void capi_ctr_down(struct capi_ctr *ctr)
 {
 	printk(KERN_NOTICE "kcapi: controller [%03d] down.n", ctr->cnr);
 
-	notify_push(KCI_CONTRDOWN, ctr->cnr, 0, 0);
+	notify_push(CAPICTR_DOWN, ctr->cnr);
 }
 
 EXPORT_SYMBOL(capi_ctr_down);
@@ -637,7 +645,6 @@ u16 capi20_register(struct capi20_appl *ap)
 	ap->nrecvdatapkt = 0;
 	ap->nsentctlpkt = 0;
 	ap->nsentdatapkt = 0;
-	ap->callback = NULL;
 	mutex_init(&ap->recv_mtx);
 	skb_queue_head_init(&ap->recv_queue);
 	INIT_WORK(&ap->recv_work, recv_handler);
@@ -1141,30 +1148,6 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 
 EXPORT_SYMBOL(capi20_manufacturer);
 
-/* temporary hack */
-
-/**
- * capi20_set_callback() - set CAPI application notification callback function
- * @ap:		CAPI application descriptor structure.
- * @callback:	callback function (NULL to remove).
- *
- * If not NULL, the callback function will be called to notify the
- * application of the addition or removal of a controller.
- * The first argument (cmd) will tell whether the controller was added
- * (KCI_CONTRUP) or removed (KCI_CONTRDOWN).
- * The second argument (contr) will be the controller number.
- * For cmd==KCI_CONTRUP the third argument (data) will be a pointer to the
- * new controller's capability profile structure.
- */
-
-void capi20_set_callback(struct capi20_appl *ap,
-			 void (*callback) (unsigned int cmd, __u32 contr, void *data))
-{
-	ap->callback = callback;
-}
-
-EXPORT_SYMBOL(capi20_set_callback);
-
 /* ------------------------------------------------------------- */
 /* -------- Init & Cleanup ------------------------------------- */
 /* ------------------------------------------------------------- */
@@ -1173,10 +1156,17 @@ EXPORT_SYMBOL(capi20_set_callback);
  * init / exit functions
  */
 
+static struct notifier_block capictr_nb = {
+	.notifier_call = notify_handler,
+	.priority = INT_MAX,
+};
+
 static int __init kcapi_init(void)
 {
 	int err;
 
+	register_capictr_notifier(&capictr_nb);
+
 	err = cdebug_init();
 	if (!err)
 		kcapi_proc_init();
diff --git a/include/linux/kernelcapi.h b/include/linux/kernelcapi.h
index a53e932..9c26839 100644
--- a/include/linux/kernelcapi.h
+++ b/include/linux/kernelcapi.h
@@ -48,9 +48,7 @@ typedef struct kcapi_carddef {
 #include <linux/list.h>
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
-
-#define	KCI_CONTRUP	0	/* arg: struct capi_profile */
-#define	KCI_CONTRDOWN	1	/* arg: NULL */
+#include <linux/notifier.h>
 
 struct capi20_appl {
 	u16 applid;
@@ -67,11 +65,6 @@ struct capi20_appl {
 	struct sk_buff_head recv_queue;
 	struct work_struct recv_work;
 	int release_in_progress;
-
-	/* ugly hack to allow for notification of added/removed
-	 * controllers. The Right Way (tm) is known. XXX
-	 */
-	void (*callback) (unsigned int cmd, __u32 contr, void *data);
 };
 
 u16 capi20_isinstalled(void);
@@ -84,11 +77,11 @@ u16 capi20_get_serial(u32 contr, u8 serial[CAPI_SERIAL_LEN]);
 u16 capi20_get_profile(u32 contr, struct capi_profile *profp);
 int capi20_manufacturer(unsigned int cmd, void __user *data);
 
-/* temporary hack XXX */
-void capi20_set_callback(struct capi20_appl *ap, 
-			 void (*callback) (unsigned int cmd, __u32 contr, void *data));
-
+#define CAPICTR_UP			0
+#define CAPICTR_DOWN			1
 
+int register_capictr_notifier(struct notifier_block *nb);
+int unregister_capictr_notifier(struct notifier_block *nb);
 
 #define CAPI_NOERROR                      0x0000
 
-- 
1.6.0.2

