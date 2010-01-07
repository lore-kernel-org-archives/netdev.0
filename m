From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 10/31] CAPI: Rework locking of controller data structures
Date: Thu, 7 Jan 2010 12:04:59 +0100
Message-ID: <97a7c858e6cef8ff9996295f097d14136d2ec59a.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:39128 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab0AVXW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:22:26 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch applies the mutex so far only protecting the controller list
to (almost) all accesses of controller data structures.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c      |  259 +++++++++++++++++++++++++++-------------
 drivers/isdn/capi/kcapi.h      |    4 +-
 drivers/isdn/capi/kcapi_proc.c |    5 +
 3 files changed, 186 insertions(+), 82 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 0fda05d..964650a 100644
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
 	        printk(KERN_DEBUG "kcapi: notify up contr %dn", contr);
 
 	ctr = get_capi_ctr_by_nr(contr);
 	if (ctr) {
 		if (ctr->state == CAPI_CTR_RUNNING)
-			return;
+			goto unlock_out;
 
 		ctr->state = CAPI_CTR_RUNNING;
 
@@ -189,6 +192,9 @@ static void notify_up(u32 contr)
 		}
 	} else
 		printk(KERN_WARNING "%s: invalid contr %dn", __func__, contr);
+
+unlock_out:
+	mutex_unlock(&capi_controller_lock);
 }
 
 static void ctr_down(struct capi_ctr *ctr)
@@ -217,6 +223,8 @@ static void notify_down(u32 contr)
 {
 	struct capi_ctr *ctr;
 
+	mutex_lock(&capi_controller_lock);
+
 	if (showcapimsgs & 1)
 		printk(KERN_DEBUG "kcapi: notify down contr %dn", contr);
 
@@ -225,6 +233,8 @@ static void notify_down(u32 contr)
 		ctr_down(ctr);
 	else
 		printk(KERN_WARNING "%s: invalid contr %dn", __func__, contr);
+
+	mutex_unlock(&capi_controller_lock);
 }
 
 static int
@@ -481,21 +491,19 @@ int attach_capi_ctr(struct capi_ctr *ctr)
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
 		printk(KERN_ERR "kcapi: out of controller slotsn");
 	   	return -EBUSY;
 	}
 	capi_controller[i] = ctr;
 
-	mutex_unlock(&controller_mutex);
-
 	ctr->nrecvctlpkt = 0;
 	ctr->nrecvdatapkt = 0;
 	ctr->nsentctlpkt = 0;
@@ -513,6 +521,9 @@ int attach_capi_ctr(struct capi_ctr *ctr)
 	}
 
 	ncontrollers++;
+
+	mutex_unlock(&capi_controller_lock);
+
 	printk(KERN_NOTICE "kcapi: controller [%03d]: %s attachedn",
 			ctr->cnr, ctr->name);
 	return 0;
@@ -531,19 +542,29 @@ EXPORT_SYMBOL(attach_capi_ctr);
 
 int detach_capi_ctr(struct capi_ctr *ctr)
 {
+	int err = 0;
+
+	mutex_lock(&capi_controller_lock);
+
 	ctr_down(ctr);
 
+	if (capi_controller[ctr->cnr - 1] != ctr) {
+		err = -EINVAL;
+		goto unlock_out;
+	}
+	capi_controller[ctr->cnr - 1] = NULL;
 	ncontrollers--;
 
-	if (ctr->procent) {
+	if (ctr->procent)
 		remove_proc_entry(ctr->procfn, NULL);
-		ctr->procent = NULL;
-	}
-	capi_controller[ctr->cnr - 1] = NULL;
+
 	printk(KERN_NOTICE "kcapi: controller [%03d]: %s unregisteredn",
 	       ctr->cnr, ctr->name);
 
-	return 0;
+unlock_out:
+	mutex_unlock(&capi_controller_lock);
+
+	return err;
 }
 
 EXPORT_SYMBOL(detach_capi_ctr);
@@ -593,13 +614,21 @@ EXPORT_SYMBOL(unregister_capi_driver);
 
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
@@ -652,14 +681,16 @@ u16 capi20_register(struct capi20_appl *ap)
 
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
 		printk(KERN_DEBUG "kcapi: appl %d upn", applid);
@@ -692,14 +723,16 @@ u16 capi20_release(struct capi20_appl *ap)
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
@@ -738,6 +771,12 @@ u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
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
@@ -802,16 +841,24 @@ EXPORT_SYMBOL(capi20_put_message);
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
@@ -829,17 +876,24 @@ EXPORT_SYMBOL(capi20_get_manufacturer);
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
@@ -857,17 +911,24 @@ EXPORT_SYMBOL(capi20_get_version);
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
@@ -885,21 +946,53 @@ EXPORT_SYMBOL(capi20_get_serial);
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
+	int cnr = ctr->cnr;
+	int retval = 0;
+
+	while (ctr->state != state) {
+		mutex_unlock(&capi_controller_lock);
+
+		msleep_interruptible(100);	/* 0.1 sec */
+
+		mutex_lock(&capi_controller_lock);
+
+		if (signal_pending(current)) {
+			retval = -EINTR;
+			break;
+		}
+		if (ctr != get_capi_ctr_by_nr(cnr)) {
+			retval = -ESRCH;
+			break;
+		}
+	}
+	return retval;
+}
+
 #ifdef AVMB1_COMPAT
 static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 {
@@ -977,27 +1070,30 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
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
 			printk(KERN_DEBUG "kcapi: load: no load functionn");
-			capi_ctr_put(ctr);
-			return -ESRCH;
+			retval = -ESRCH;
+			goto load_unlock_out;
 		}
 
 		if (ldef.t4file.len <= 0) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: length of t4file is %d ?n", ldef.t4file.len);
-			capi_ctr_put(ctr);
-			return -EINVAL;
+			retval = -EINVAL;
+			goto load_unlock_out;
 		}
 		if (ldef.t4file.data == NULL) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: dataptr is 0n");
-			capi_ctr_put(ctr);
-			return -EINVAL;
+			retval = -EINVAL;
+			goto load_unlock_out;
 		}
 
 		ldata.firmware.user = 1;
@@ -1009,52 +1105,47 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 
 		if (ctr->state != CAPI_CTR_DETECTED) {
 			printk(KERN_INFO "kcapi: load: contr=%d not in detect staten", ldef.contr);
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
+		retval = wait_on_ctr_state(ctr, CAPI_CTR_RUNNING);
 
-			msleep_interruptible(100);	/* 0.1 sec */
-
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
@@ -1072,6 +1163,7 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 int capi20_manufacturer(unsigned int cmd, void __user *data)
 {
 	struct capi_ctr *ctr;
+	int retval;
 
 	switch (cmd) {
 #ifdef AVMB1_COMPAT
@@ -1089,14 +1181,20 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		if (copy_from_user(&fdef, data, sizeof(kcapi_flagdef)))
 			return -EFAULT;
 
+		mutex_lock(&capi_controller_lock);
+
 		ctr = get_capi_ctr_by_nr(fdef.contr);
-		if (!ctr)
-			return -ESRCH;
+		if (ctr) {
+			ctr->traceflag = fdef.flag;
+			printk(KERN_INFO "kcapi: contr [%03d] set trace=%dn",
+			       ctr->cnr, ctr->traceflag);
+			retval = 0;
+		} else
+			retval = -ESRCH;
+
+		mutex_unlock(&capi_controller_lock);
 
-		ctr->traceflag = fdef.flag;
-		printk(KERN_INFO "kcapi: contr [%03d] set trace=%dn",
-		       ctr->cnr, ctr->traceflag);
-		return 0;
+		return retval;
 	}
 	case KCAPI_CMD_ADDCARD:
 	{
@@ -1104,7 +1202,6 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		struct capi_driver *driver = NULL;
 		capicardparams cparams;
 		kcapi_carddef cdef;
-		int retval;
 
 		if ((retval = copy_from_user(&cdef, data, sizeof(cdef))))
 			return retval;
diff --git a/drivers/isdn/capi/kcapi.h b/drivers/isdn/capi/kcapi.h
index 07c5850..966c4b2 100644
--- a/drivers/isdn/capi/kcapi.h
+++ b/drivers/isdn/capi/kcapi.h
@@ -32,8 +32,10 @@ enum {
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
-- 
1.6.0.2

