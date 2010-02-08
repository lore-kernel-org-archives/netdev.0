From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 07/41] CAPI: Convert capi drivers rwlock into mutex
Date: Mon,  8 Feb 2010 21:12:11 +0100
Message-ID: <afc5cefa3ba6770536b9dea473f8c39320802995.1265659934.git.jan.kiszka@web.de>
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

Turn the lock protecting registered capi drivers into a mutex and apply
it consistently.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c      |   49 ++++++++++++++++++----------------------
 drivers/isdn/capi/kcapi.h      |    2 +-
 drivers/isdn/capi/kcapi_proc.c |    8 +++---
 3 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index f37c13b..c46964f 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -61,7 +61,7 @@ static char capi_manufakturer[64] = "AVM Berlin";
 #define NCCI2CTRL(ncci)    (((ncci) >> 24) & 0x7f)
 
 LIST_HEAD(capi_drivers);
-DEFINE_RWLOCK(capi_drivers_list_lock);
+DEFINE_MUTEX(capi_drivers_lock);
 
 static DEFINE_RWLOCK(application_lock);
 static DEFINE_MUTEX(controller_mutex);
@@ -540,11 +540,9 @@ EXPORT_SYMBOL(detach_capi_ctr);
 
 void register_capi_driver(struct capi_driver *driver)
 {
-	unsigned long flags;
-
-	write_lock_irqsave(&capi_drivers_list_lock, flags);
+	mutex_lock(&capi_drivers_lock);
 	list_add_tail(&driver->list, &capi_drivers);
-	write_unlock_irqrestore(&capi_drivers_list_lock, flags);
+	mutex_unlock(&capi_drivers_lock);
 }
 
 EXPORT_SYMBOL(register_capi_driver);
@@ -558,11 +556,9 @@ EXPORT_SYMBOL(register_capi_driver);
 
 void unregister_capi_driver(struct capi_driver *driver)
 {
-	unsigned long flags;
-
-	write_lock_irqsave(&capi_drivers_list_lock, flags);
+	mutex_lock(&capi_drivers_lock);
 	list_del(&driver->list);
-	write_unlock_irqrestore(&capi_drivers_list_lock, flags);
+	mutex_unlock(&capi_drivers_lock);
 }
 
 EXPORT_SYMBOL(unregister_capi_driver);
@@ -899,7 +895,6 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 	struct capi_driver *driver = NULL;
 	capiloaddata ldata;
 	struct list_head *l;
-	unsigned long flags;
 	int retval;
 
 	switch (cmd) {
@@ -919,7 +914,8 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 		cparams.irq = cdef.irq;
 		cparams.cardnr = cdef.cardnr;
 
-		read_lock_irqsave(&capi_drivers_list_lock, flags);
+		mutex_lock(&capi_drivers_lock);
+
                 switch (cdef.cardtype) {
 			case AVM_CARDTYPE_B1:
 				list_for_each(l, &capi_drivers) {
@@ -940,18 +936,15 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 				break;
 		}
 		if (!driver) {
-			read_unlock_irqrestore(&capi_drivers_list_lock, flags);
 			printk(KERN_ERR "kcapi: driver not loaded.\n");
-			return -EIO;
-		}
-		if (!driver->add_card) {
-			read_unlock_irqrestore(&capi_drivers_list_lock, flags);
+			retval = -EIO;
+		} else if (!driver->add_card) {
 			printk(KERN_ERR "kcapi: driver has no add card function.\n");
-			return -EIO;
-		}
+			retval = -EIO;
+		} else
+			retval = driver->add_card(driver, &cparams);
 
-		retval = driver->add_card(driver, &cparams);
-		read_unlock_irqrestore(&capi_drivers_list_lock, flags);
+		mutex_unlock(&capi_drivers_lock);
 		return retval;
 
 	case AVMB1_LOAD:
@@ -1107,6 +1100,8 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		cparams.cardtype = 0;
 		cdef.driver[sizeof(cdef.driver)-1] = 0;
 
+		mutex_lock(&capi_drivers_lock);
+
 		list_for_each(l, &capi_drivers) {
 			driver = list_entry(l, struct capi_driver, list);
 			if (strcmp(driver->name, cdef.driver) == 0)
@@ -1115,15 +1110,15 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		if (driver == NULL) {
 			printk(KERN_ERR "kcapi: driver \"%s\" not loaded.\n",
 					cdef.driver);
-			return -ESRCH;
-		}
-
-		if (!driver->add_card) {
+			retval = -ESRCH;
+		} else if (!driver->add_card) {
 			printk(KERN_ERR "kcapi: driver \"%s\" has no add card function.\n", cdef.driver);
-			return -EIO;
-		}
+			retval = -EIO;
+		} else
+			retval = driver->add_card(driver, &cparams);
 
-		return driver->add_card(driver, &cparams);
+		mutex_unlock(&capi_drivers_lock);
+		return retval;
 	}
 
 	default:
diff --git a/drivers/isdn/capi/kcapi.h b/drivers/isdn/capi/kcapi.h
index f62c53b..07c5850 100644
--- a/drivers/isdn/capi/kcapi.h
+++ b/drivers/isdn/capi/kcapi.h
@@ -30,7 +30,7 @@ enum {
 };
 
 extern struct list_head capi_drivers;
-extern rwlock_t capi_drivers_list_lock;
+extern struct mutex capi_drivers_lock;
 
 extern struct capi20_appl *capi_applications[CAPI_MAXAPPL];
 extern struct capi_ctr *capi_controller[CAPI_MAXCONTR];
diff --git a/drivers/isdn/capi/kcapi_proc.c b/drivers/isdn/capi/kcapi_proc.c
index 59fd16a..71b0761 100644
--- a/drivers/isdn/capi/kcapi_proc.c
+++ b/drivers/isdn/capi/kcapi_proc.c
@@ -238,9 +238,9 @@ static const struct file_operations proc_applstats_ops = {
 // ---------------------------------------------------------------------------
 
 static void *capi_driver_start(struct seq_file *seq, loff_t *pos)
-	__acquires(&capi_drivers_list_lock)
+	__acquires(&capi_drivers_lock)
 {
-	read_lock(&capi_drivers_list_lock);
+	mutex_lock(&capi_drivers_lock);
 	return seq_list_start(&capi_drivers, *pos);
 }
 
@@ -250,9 +250,9 @@ static void *capi_driver_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void capi_driver_stop(struct seq_file *seq, void *v)
-	__releases(&capi_drivers_list_lock)
+	__releases(&capi_drivers_lock)
 {
-	read_unlock(&capi_drivers_list_lock);
+	mutex_unlock(&capi_drivers_lock);
 }
 
 static int capi_driver_show(struct seq_file *seq, void *v)
-- 
1.6.0.2
