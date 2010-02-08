From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 10/41] CAPI: Rework locking of controller data structures
Date: Mon,  8 Feb 2010 21:12:14 +0100
Message-ID: <7ac50632f644616b61607fb17972bd05f4fe9979.1265659934.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:43154 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779Ab0BHUNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:04 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch applies the mutex so far only protecting the controller list
to (almost) all accesses of controller data structures. It also reworks
waiting on state changes in old_capi_manufacturer so that it no longer
poll and holds a module reference to the controller owner while waiting
(the latter was partly done already). Modification and checking of the
blocked state remains racy by design, the caller is responsible for
dealing with this.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c      |  291 ++++++++++++++++++++++++++++------------
 drivers/isdn/capi/kcapi.h      |    5 +-
 drivers/isdn/capi/kcapi_proc.c |    5 +
 include/linux/isdn/capilli.h   |    5 +-
 4 files changed, 217 insertions(+), 89 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index e08914d..a99f7e3 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -61,11 +61,12 @@ static char capi_manufakturer[64] = "AVM Berlin";
 LIST_HEAD(capi_drivers);
 DEFINE_MUTEX(capi_drivers_lock);
 
+struct capi_ctr *capi_controller[CAPI_MAXCONTR];
+DEFINE_MUTEX(capi_controller_lock);
+
 static DEFINE_RWLOCK(application_lock);
-static DEFINE_MUTEX(controller_mutex);
 
 struct capi20_appl *capi_applications[CAPI_MAXAPPL];
-struct capi_ctr *capi_controller[CAPI_MAXCONTR];
 
 static int ncontrollers;
 
@@ -171,13 +172,15 @@ static void notify_up(u32 contr)
 	struct capi_ctr *ctr;
 	u16 applid;
 
+	mutex_lock(&capi_controller_lock);
+
 	if (showcapimsgs & 1)
 	        printk(KERN_DEBUG "kcapi: notify up contr %d\n", contr);
 
 	ctr = get_capi_ctr_by_nr(contr);
 	if (ctr) {
 		if (ctr->state == CAPI_CTR_RUNNING)
-			return;
+			goto unlock_out;
 
 		ctr->state = CAPI_CTR_RUNNING;
 
@@ -187,19 +190,24 @@ static void notify_up(u32 contr)
 				continue;
 			register_appl(ctr, applid, &ap->rparam);
 		}
+
+		wake_up_interruptible_all(&ctr->state_wait_queue);
 	} else
 		printk(KERN_WARNING "%s: invalid contr %d\n", __func__, contr);
+
+unlock_out:
+	mutex_unlock(&capi_controller_lock);
 }
 
-static void ctr_down(struct capi_ctr *ctr)
+static void ctr_down(struct capi_ctr *ctr, int new_state)
 {
 	struct capi20_appl *ap;
 	u16 applid;
 
-	if (ctr->state == CAPI_CTR_DETECTED)
+	if (ctr->state == CAPI_CTR_DETECTED || ctr->state == CAPI_CTR_DETACHED)
 		return;
 
-	ctr->state = CAPI_CTR_DETECTED;
+	ctr->state = new_state;
 
 	memset(ctr->manu, 0, sizeof(ctr->manu));
 	memset(&ctr->version, 0, sizeof(ctr->version));
@@ -211,20 +219,26 @@ static void ctr_down(struct capi_ctr *ctr)
 		if (ap && !ap->release_in_progress)
 			capi_ctr_put(ctr);
 	}
+
+	wake_up_interruptible_all(&ctr->state_wait_queue);
 }
 
 static void notify_down(u32 contr)
 {
 	struct capi_ctr *ctr;
 
+	mutex_lock(&capi_controller_lock);
+
 	if (showcapimsgs & 1)
 		printk(KERN_DEBUG "kcapi: notify down contr %d\n", contr);
 
 	ctr = get_capi_ctr_by_nr(contr);
 	if (ctr)
-		ctr_down(ctr);
+		ctr_down(ctr, CAPI_CTR_DETECTED);
 	else
 		printk(KERN_WARNING "%s: invalid contr %d\n", __func__, contr);
+
+	mutex_unlock(&capi_controller_lock);
 }
 
 static int
@@ -436,6 +450,9 @@ EXPORT_SYMBOL(capi_ctr_down);
  * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to stop data flow.
+ *
+ * Note: The caller is responsible for synchronizing concurrent state changes
+ * as well as invocations of capi_ctr_handle_message.
  */
 
 void capi_ctr_suspend_output(struct capi_ctr *ctr)
@@ -454,6 +471,9 @@ EXPORT_SYMBOL(capi_ctr_suspend_output);
  * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to resume data flow.
+ *
+ * Note: The caller is responsible for synchronizing concurrent state changes
+ * as well as invocations of capi_ctr_handle_message.
  */
 
 void capi_ctr_resume_output(struct capi_ctr *ctr)
@@ -481,21 +501,19 @@ int attach_capi_ctr(struct capi_ctr *ctr)
 {
 	int i;
 
-	mutex_lock(&controller_mutex);
+	mutex_lock(&capi_controller_lock);
 
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
 		if (!capi_controller[i])
 			break;
 	}
 	if (i == CAPI_MAXCONTR) {
-		mutex_unlock(&controller_mutex);
+		mutex_unlock(&capi_controller_lock);
 		printk(KERN_ERR "kcapi: out of controller slots\n");
 	   	return -EBUSY;
 	}
 	capi_controller[i] = ctr;
 
-	mutex_unlock(&controller_mutex);
-
 	ctr->nrecvctlpkt = 0;
 	ctr->nrecvdatapkt = 0;
 	ctr->nsentctlpkt = 0;
@@ -504,11 +522,15 @@ int attach_capi_ctr(struct capi_ctr *ctr)
 	ctr->state = CAPI_CTR_DETECTED;
 	ctr->blocked = 0;
 	ctr->traceflag = showcapimsgs;
+	init_waitqueue_head(&ctr->state_wait_queue);
 
 	sprintf(ctr->procfn, "capi/controllers/%d", ctr->cnr);
 	ctr->procent = proc_create_data(ctr->procfn, 0, NULL, ctr->proc_fops, ctr);
 
 	ncontrollers++;
+
+	mutex_unlock(&capi_controller_lock);
+
 	printk(KERN_NOTICE "kcapi: controller [%03d]: %s attached\n",
 			ctr->cnr, ctr->name);
 	return 0;
@@ -527,19 +549,29 @@ EXPORT_SYMBOL(attach_capi_ctr);
 
 int detach_capi_ctr(struct capi_ctr *ctr)
 {
-	ctr_down(ctr);
+	int err = 0;
 
-	ncontrollers--;
+	mutex_lock(&capi_controller_lock);
 
-	if (ctr->procent) {
-		remove_proc_entry(ctr->procfn, NULL);
-		ctr->procent = NULL;
+	ctr_down(ctr, CAPI_CTR_DETACHED);
+
+	if (capi_controller[ctr->cnr - 1] != ctr) {
+		err = -EINVAL;
+		goto unlock_out;
 	}
 	capi_controller[ctr->cnr - 1] = NULL;
+	ncontrollers--;
+
+	if (ctr->procent)
+		remove_proc_entry(ctr->procfn, NULL);
+
 	printk(KERN_NOTICE "kcapi: controller [%03d]: %s unregistered\n",
 	       ctr->cnr, ctr->name);
 
-	return 0;
+unlock_out:
+	mutex_unlock(&capi_controller_lock);
+
+	return err;
 }
 
 EXPORT_SYMBOL(detach_capi_ctr);
@@ -589,13 +621,21 @@ EXPORT_SYMBOL(unregister_capi_driver);
 
 u16 capi20_isinstalled(void)
 {
+	u16 ret = CAPI_REGNOTINSTALLED;
 	int i;
-	for (i = 0; i < CAPI_MAXCONTR; i++) {
+
+	mutex_lock(&capi_controller_lock);
+
+	for (i = 0; i < CAPI_MAXCONTR; i++)
 		if (capi_controller[i] &&
-		    capi_controller[i]->state == CAPI_CTR_RUNNING)
-			return CAPI_NOERROR;
-	}
-	return CAPI_REGNOTINSTALLED;
+		    capi_controller[i]->state == CAPI_CTR_RUNNING) {
+			ret = CAPI_NOERROR;
+			break;
+		}
+
+	mutex_unlock(&capi_controller_lock);
+
+	return ret;
 }
 
 EXPORT_SYMBOL(capi20_isinstalled);
@@ -648,14 +688,16 @@ u16 capi20_register(struct capi20_appl *ap)
 
 	write_unlock_irqrestore(&application_lock, flags);
 	
-	mutex_lock(&controller_mutex);
+	mutex_lock(&capi_controller_lock);
+
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
 		if (!capi_controller[i] ||
 		    capi_controller[i]->state != CAPI_CTR_RUNNING)
 			continue;
 		register_appl(capi_controller[i], applid, &ap->rparam);
 	}
-	mutex_unlock(&controller_mutex);
+
+	mutex_unlock(&capi_controller_lock);
 
 	if (showcapimsgs & 1) {
 		printk(KERN_DEBUG "kcapi: appl %d up\n", applid);
@@ -688,14 +730,16 @@ u16 capi20_release(struct capi20_appl *ap)
 	capi_applications[ap->applid - 1] = NULL;
 	write_unlock_irqrestore(&application_lock, flags);
 
-	mutex_lock(&controller_mutex);
+	mutex_lock(&capi_controller_lock);
+
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
 		if (!capi_controller[i] ||
 		    capi_controller[i]->state != CAPI_CTR_RUNNING)
 			continue;
 		release_appl(capi_controller[i], ap->applid);
 	}
-	mutex_unlock(&controller_mutex);
+
+	mutex_unlock(&capi_controller_lock);
 
 	flush_scheduled_work();
 	skb_queue_purge(&ap->recv_queue);
@@ -734,6 +778,12 @@ u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 	    || !capi_cmd_valid(CAPIMSG_COMMAND(skb->data))
 	    || !capi_subcmd_valid(CAPIMSG_SUBCOMMAND(skb->data)))
 		return CAPI_ILLCMDORSUBCMDORMSGTOSMALL;
+
+	/*
+	 * The controller reference is protected by the existence of the
+	 * application passed to us. We assume that the caller properly
+	 * synchronizes this service with capi20_release.
+	 */
 	ctr = get_capi_ctr_by_nr(CAPIMSG_CONTROLLER(skb->data));
 	if (!ctr || ctr->state != CAPI_CTR_RUNNING) {
 		ctr = get_capi_ctr_by_nr(1); /* XXX why? */
@@ -798,16 +848,24 @@ EXPORT_SYMBOL(capi20_put_message);
 u16 capi20_get_manufacturer(u32 contr, u8 *buf)
 {
 	struct capi_ctr *ctr;
+	u16 ret;
 
 	if (contr == 0) {
 		strlcpy(buf, capi_manufakturer, CAPI_MANUFACTURER_LEN);
 		return CAPI_NOERROR;
 	}
+
+	mutex_lock(&capi_controller_lock);
+
 	ctr = get_capi_ctr_by_nr(contr);
-	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
-		return CAPI_REGNOTINSTALLED;
-	strlcpy(buf, ctr->manu, CAPI_MANUFACTURER_LEN);
-	return CAPI_NOERROR;
+	if (ctr && ctr->state == CAPI_CTR_RUNNING) {
+		strlcpy(buf, ctr->manu, CAPI_MANUFACTURER_LEN);
+		ret = CAPI_NOERROR;
+	} else
+		ret = CAPI_REGNOTINSTALLED;
+
+	mutex_unlock(&capi_controller_lock);
+	return ret;
 }
 
 EXPORT_SYMBOL(capi20_get_manufacturer);
@@ -825,17 +883,24 @@ EXPORT_SYMBOL(capi20_get_manufacturer);
 u16 capi20_get_version(u32 contr, struct capi_version *verp)
 {
 	struct capi_ctr *ctr;
+	u16 ret;
 
 	if (contr == 0) {
 		*verp = driver_version;
 		return CAPI_NOERROR;
 	}
+
+	mutex_lock(&capi_controller_lock);
+
 	ctr = get_capi_ctr_by_nr(contr);
-	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
-		return CAPI_REGNOTINSTALLED;
+	if (ctr && ctr->state == CAPI_CTR_RUNNING) {
+		memcpy(verp, &ctr->version, sizeof(capi_version));
+		ret = CAPI_NOERROR;
+	} else
+		ret = CAPI_REGNOTINSTALLED;
 
-	memcpy(verp, &ctr->version, sizeof(capi_version));
-	return CAPI_NOERROR;
+	mutex_unlock(&capi_controller_lock);
+	return ret;
 }
 
 EXPORT_SYMBOL(capi20_get_version);
@@ -853,17 +918,24 @@ EXPORT_SYMBOL(capi20_get_version);
 u16 capi20_get_serial(u32 contr, u8 *serial)
 {
 	struct capi_ctr *ctr;
+	u16 ret;
 
 	if (contr == 0) {
 		strlcpy(serial, driver_serial, CAPI_SERIAL_LEN);
 		return CAPI_NOERROR;
 	}
+
+	mutex_lock(&capi_controller_lock);
+
 	ctr = get_capi_ctr_by_nr(contr);
-	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
-		return CAPI_REGNOTINSTALLED;
+	if (ctr && ctr->state == CAPI_CTR_RUNNING) {
+		strlcpy(serial, ctr->serial, CAPI_SERIAL_LEN);
+		ret = CAPI_NOERROR;
+	} else
+		ret = CAPI_REGNOTINSTALLED;
 
-	strlcpy(serial, ctr->serial, CAPI_SERIAL_LEN);
-	return CAPI_NOERROR;
+	mutex_unlock(&capi_controller_lock);
+	return ret;
 }
 
 EXPORT_SYMBOL(capi20_get_serial);
@@ -881,21 +953,64 @@ EXPORT_SYMBOL(capi20_get_serial);
 u16 capi20_get_profile(u32 contr, struct capi_profile *profp)
 {
 	struct capi_ctr *ctr;
+	u16 ret;
 
 	if (contr == 0) {
 		profp->ncontroller = ncontrollers;
 		return CAPI_NOERROR;
 	}
+
+	mutex_lock(&capi_controller_lock);
+
 	ctr = get_capi_ctr_by_nr(contr);
-	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
-		return CAPI_REGNOTINSTALLED;
+	if (ctr && ctr->state == CAPI_CTR_RUNNING) {
+		memcpy(profp, &ctr->profile, sizeof(struct capi_profile));
+		ret = CAPI_NOERROR;
+	} else
+		ret = CAPI_REGNOTINSTALLED;
 
-	memcpy(profp, &ctr->profile, sizeof(struct capi_profile));
-	return CAPI_NOERROR;
+	mutex_unlock(&capi_controller_lock);
+	return ret;
 }
 
 EXPORT_SYMBOL(capi20_get_profile);
 
+/* Must be called with capi_controller_lock held. */
+static int wait_on_ctr_state(struct capi_ctr *ctr, unsigned int state)
+{
+	DEFINE_WAIT(wait);
+	int retval = 0;
+
+	ctr = capi_ctr_get(ctr);
+	if (!ctr)
+		return -ESRCH;
+
+	for (;;) {
+		prepare_to_wait(&ctr->state_wait_queue, &wait,
+				TASK_INTERRUPTIBLE);
+
+		if (ctr->state == state)
+			break;
+		if (ctr->state == CAPI_CTR_DETACHED) {
+			retval = -ESRCH;
+			break;
+		}
+		if (signal_pending(current)) {
+			retval = -EINTR;
+			break;
+		}
+
+		mutex_unlock(&capi_controller_lock);
+		schedule();
+		mutex_lock(&capi_controller_lock);
+	}
+	finish_wait(&ctr->state_wait_queue, &wait);
+
+	capi_ctr_put(ctr);
+
+	return retval;
+}
+
 #ifdef AVMB1_COMPAT
 static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 {
@@ -973,27 +1088,30 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 					   sizeof(avmb1_loadandconfigdef)))
 				return -EFAULT;
 		}
+
+		mutex_lock(&capi_controller_lock);
+
 		ctr = get_capi_ctr_by_nr(ldef.contr);
-		if (!ctr)
-			return -EINVAL;
-		ctr = capi_ctr_get(ctr);
-		if (!ctr)
-			return -ESRCH;
+		if (!ctr) {
+			retval = -EINVAL;
+			goto load_unlock_out;
+		}
+
 		if (ctr->load_firmware == NULL) {
 			printk(KERN_DEBUG "kcapi: load: no load function\n");
-			capi_ctr_put(ctr);
-			return -ESRCH;
+			retval = -ESRCH;
+			goto load_unlock_out;
 		}
 
 		if (ldef.t4file.len <= 0) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: length of t4file is %d ?\n", ldef.t4file.len);
-			capi_ctr_put(ctr);
-			return -EINVAL;
+			retval = -EINVAL;
+			goto load_unlock_out;
 		}
 		if (ldef.t4file.data == NULL) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: dataptr is 0\n");
-			capi_ctr_put(ctr);
-			return -EINVAL;
+			retval = -EINVAL;
+			goto load_unlock_out;
 		}
 
 		ldata.firmware.user = 1;
@@ -1005,52 +1123,47 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 
 		if (ctr->state != CAPI_CTR_DETECTED) {
 			printk(KERN_INFO "kcapi: load: contr=%d not in detect state\n", ldef.contr);
-			capi_ctr_put(ctr);
-			return -EBUSY;
+			retval = -EBUSY;
+			goto load_unlock_out;
 		}
 		ctr->state = CAPI_CTR_LOADING;
 
 		retval = ctr->load_firmware(ctr, &ldata);
-
 		if (retval) {
 			ctr->state = CAPI_CTR_DETECTED;
-			capi_ctr_put(ctr);
-			return retval;
+			goto load_unlock_out;
 		}
 
-		while (ctr->state != CAPI_CTR_RUNNING) {
-
-			msleep_interruptible(100);	/* 0.1 sec */
+		retval = wait_on_ctr_state(ctr, CAPI_CTR_RUNNING);
 
-			if (signal_pending(current)) {
-				capi_ctr_put(ctr);
-				return -EINTR;
-			}
-		}
-		capi_ctr_put(ctr);
-		return 0;
+load_unlock_out:
+		mutex_unlock(&capi_controller_lock);
+		return retval;
 
 	case AVMB1_RESETCARD:
 		if (copy_from_user(&rdef, data, sizeof(avmb1_resetdef)))
 			return -EFAULT;
+
+		retval = 0;
+
+		mutex_lock(&capi_controller_lock);
+
 		ctr = get_capi_ctr_by_nr(rdef.contr);
-		if (!ctr)
-			return -ESRCH;
+		if (!ctr) {
+			retval = -ESRCH;
+			goto reset_unlock_out;
+		}
 
 		if (ctr->state == CAPI_CTR_DETECTED)
-			return 0;
+			goto reset_unlock_out;
 
 		ctr->reset_ctr(ctr);
 
-		while (ctr->state > CAPI_CTR_DETECTED) {
-
-			msleep_interruptible(100);	/* 0.1 sec */
-
-			if (signal_pending(current))
-				return -EINTR;
-		}
-		return 0;
+		retval = wait_on_ctr_state(ctr, CAPI_CTR_DETECTED);
 
+reset_unlock_out:
+		mutex_unlock(&capi_controller_lock);
+		return retval;
 	}
 	return -EINVAL;
 }
@@ -1068,6 +1181,7 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 int capi20_manufacturer(unsigned int cmd, void __user *data)
 {
 	struct capi_ctr *ctr;
+	int retval;
 
 	switch (cmd) {
 #ifdef AVMB1_COMPAT
@@ -1085,14 +1199,20 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		if (copy_from_user(&fdef, data, sizeof(kcapi_flagdef)))
 			return -EFAULT;
 
+		mutex_lock(&capi_controller_lock);
+
 		ctr = get_capi_ctr_by_nr(fdef.contr);
-		if (!ctr)
-			return -ESRCH;
+		if (ctr) {
+			ctr->traceflag = fdef.flag;
+			printk(KERN_INFO "kcapi: contr [%03d] set trace=%d\n",
+			       ctr->cnr, ctr->traceflag);
+			retval = 0;
+		} else
+			retval = -ESRCH;
+
+		mutex_unlock(&capi_controller_lock);
 
-		ctr->traceflag = fdef.flag;
-		printk(KERN_INFO "kcapi: contr [%03d] set trace=%d\n",
-		       ctr->cnr, ctr->traceflag);
-		return 0;
+		return retval;
 	}
 	case KCAPI_CMD_ADDCARD:
 	{
@@ -1100,7 +1220,6 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		struct capi_driver *driver = NULL;
 		capicardparams cparams;
 		kcapi_carddef cdef;
-		int retval;
 
 		if ((retval = copy_from_user(&cdef, data, sizeof(cdef))))
 			return retval;
diff --git a/drivers/isdn/capi/kcapi.h b/drivers/isdn/capi/kcapi.h
index 07c5850..f4620b3 100644
--- a/drivers/isdn/capi/kcapi.h
+++ b/drivers/isdn/capi/kcapi.h
@@ -24,6 +24,7 @@ printk(KERN_DEBUG "%s: " format "\n" , __func__ , ## arg); \
 #endif
 
 enum {
+	CAPI_CTR_DETACHED = 0,
 	CAPI_CTR_DETECTED = 1,
 	CAPI_CTR_LOADING  = 2,
 	CAPI_CTR_RUNNING  = 3,
@@ -32,8 +33,10 @@ enum {
 extern struct list_head capi_drivers;
 extern struct mutex capi_drivers_lock;
 
-extern struct capi20_appl *capi_applications[CAPI_MAXAPPL];
 extern struct capi_ctr *capi_controller[CAPI_MAXCONTR];
+extern struct mutex capi_controller_lock;
+
+extern struct capi20_appl *capi_applications[CAPI_MAXAPPL];
 
 #ifdef CONFIG_PROC_FS
 
diff --git a/drivers/isdn/capi/kcapi_proc.c b/drivers/isdn/capi/kcapi_proc.c
index 71b0761..3e6e17a 100644
--- a/drivers/isdn/capi/kcapi_proc.c
+++ b/drivers/isdn/capi/kcapi_proc.c
@@ -35,7 +35,10 @@ static char *state2str(unsigned short state)
 // ---------------------------------------------------------------------------
 
 static void *controller_start(struct seq_file *seq, loff_t *pos)
+	__acquires(capi_controller_lock)
 {
+	mutex_lock(&capi_controller_lock);
+
 	if (*pos < CAPI_MAXCONTR)
 		return &capi_controller[*pos];
 
@@ -52,7 +55,9 @@ static void *controller_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void controller_stop(struct seq_file *seq, void *v)
+	__releases(capi_controller_lock)
 {
+	mutex_unlock(&capi_controller_lock);
 }
 
 static int controller_show(struct seq_file *seq, void *v)
diff --git a/include/linux/isdn/capilli.h b/include/linux/isdn/capilli.h
index 856f38e..11b57c4 100644
--- a/include/linux/isdn/capilli.h
+++ b/include/linux/isdn/capilli.h
@@ -66,9 +66,10 @@ struct capi_ctr {
 	unsigned long nsentdatapkt;
 
 	int cnr;				/* controller number */
-	volatile unsigned short state;		/* controller state */
-	volatile int blocked;			/* output blocked */
+	unsigned short state;			/* controller state */
+	int blocked;				/* output blocked */
 	int traceflag;				/* capi trace */
+	wait_queue_head_t state_wait_queue;
 
 	struct proc_dir_entry *procent;
         char procfn[128];
-- 
1.6.0.2

