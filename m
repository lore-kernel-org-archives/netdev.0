From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 06/41] CAPI: Call a controller 'controller', not 'card'
Date: Mon,  8 Feb 2010 21:12:10 +0100
Message-ID: <2cfa15a9dc84f87b85a7f882dae9219a6ba490a9.1265659933.git.jan.kiszka@web.de>
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

At least for our internal use, fix the misnomers that refer to a CAPI
controller as 'card'. No functional changes.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c      |  320 +++++++++++++++++++++-------------------
 drivers/isdn/capi/kcapi.h      |    8 +-
 drivers/isdn/capi/kcapi_proc.c |   17 +-
 include/linux/isdn/capilli.h   |    2 +-
 4 files changed, 178 insertions(+), 169 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index ef564ee..f37c13b 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -67,24 +67,24 @@ static DEFINE_RWLOCK(application_lock);
 static DEFINE_MUTEX(controller_mutex);
 
 struct capi20_appl *capi_applications[CAPI_MAXAPPL];
-struct capi_ctr *capi_cards[CAPI_MAXCONTR];
+struct capi_ctr *capi_controller[CAPI_MAXCONTR];
 
-static int ncards;
+static int ncontrollers;
 
 /* -------- controller ref counting -------------------------------------- */
 
 static inline struct capi_ctr *
-capi_ctr_get(struct capi_ctr *card)
+capi_ctr_get(struct capi_ctr *ctr)
 {
-	if (!try_module_get(card->owner))
+	if (!try_module_get(ctr->owner))
 		return NULL;
-	return card;
+	return ctr;
 }
 
 static inline void
-capi_ctr_put(struct capi_ctr *card)
+capi_ctr_put(struct capi_ctr *ctr)
 {
-	module_put(card->owner);
+	module_put(ctr->owner);
 }
 
 /* ------------------------------------------------------------- */
@@ -94,7 +94,7 @@ static inline struct capi_ctr *get_capi_ctr_by_nr(u16 contr)
 	if (contr - 1 >= CAPI_MAXCONTR)
 		return NULL;
 
-	return capi_cards[contr - 1];
+	return capi_controller[contr - 1];
 }
 
 static inline struct capi20_appl *get_capi_appl_by_nr(u16 applid)
@@ -144,46 +144,48 @@ static inline int capi_subcmd_valid(u8 subcmd)
 
 /* ------------------------------------------------------------ */
 
-static void register_appl(struct capi_ctr *card, u16 applid, capi_register_params *rparam)
+static void
+register_appl(struct capi_ctr *ctr, u16 applid, capi_register_params *rparam)
 {
-	card = capi_ctr_get(card);
+	ctr = capi_ctr_get(ctr);
 
-	if (card)
-		card->register_appl(card, applid, rparam);
+	if (ctr)
+		ctr->register_appl(ctr, applid, rparam);
 	else
-		printk(KERN_WARNING "%s: cannot get card resources\n", __func__);
+		printk(KERN_WARNING "%s: cannot get controller resources\n",
+		       __func__);
 }
 
 
-static void release_appl(struct capi_ctr *card, u16 applid)
+static void release_appl(struct capi_ctr *ctr, u16 applid)
 {
 	DBG("applid %#x", applid);
 	
-	card->release_appl(card, applid);
-	capi_ctr_put(card);
+	ctr->release_appl(ctr, applid);
+	capi_ctr_put(ctr);
 }
 
 /* -------- KCI_CONTRUP --------------------------------------- */
 
 static void notify_up(u32 contr)
 {
-	struct capi_ctr *card = get_capi_ctr_by_nr(contr);
+	struct capi_ctr *ctr = get_capi_ctr_by_nr(contr);
 	struct capi20_appl *ap;
 	u16 applid;
 
 	if (showcapimsgs & 1) {
 	        printk(KERN_DEBUG "kcapi: notify up contr %d\n", contr);
 	}
-	if (!card) {
+	if (!ctr) {
 		printk(KERN_WARNING "%s: invalid contr %d\n", __func__, contr);
 		return;
 	}
 	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
 		ap = get_capi_appl_by_nr(applid);
 		if (!ap || ap->release_in_progress) continue;
-		register_appl(card, applid, &ap->rparam);
+		register_appl(ctr, applid, &ap->rparam);
 		if (ap->callback && !ap->release_in_progress)
-			ap->callback(KCI_CONTRUP, contr, &card->profile);
+			ap->callback(KCI_CONTRUP, contr, &ctr->profile);
 	}
 }
 
@@ -269,14 +271,15 @@ static void recv_handler(struct work_struct *work)
 
 /**
  * capi_ctr_handle_message() - handle incoming CAPI message
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  * @appl:	application ID.
  * @skb:	message.
  *
  * Called by hardware driver to pass a CAPI message to the application.
  */
 
-void capi_ctr_handle_message(struct capi_ctr * card, u16 appl, struct sk_buff *skb)
+void capi_ctr_handle_message(struct capi_ctr *ctr, u16 appl,
+			     struct sk_buff *skb)
 {
 	struct capi20_appl *ap;
 	int showctl = 0;
@@ -284,43 +287,45 @@ void capi_ctr_handle_message(struct capi_ctr * card, u16 appl, struct sk_buff *s
 	unsigned long flags;
 	_cdebbuf *cdb;
 
-	if (card->cardstate != CARD_RUNNING) {
+	if (ctr->state != CAPI_CTR_RUNNING) {
 		cdb = capi_message2str(skb->data);
 		if (cdb) {
 			printk(KERN_INFO "kcapi: controller [%03d] not active, got: %s",
-				card->cnr, cdb->buf);
+				ctr->cnr, cdb->buf);
 			cdebbuf_free(cdb);
 		} else
 			printk(KERN_INFO "kcapi: controller [%03d] not active, cannot trace\n",
-				card->cnr);
+				ctr->cnr);
 		goto error;
 	}
 
 	cmd = CAPIMSG_COMMAND(skb->data);
         subcmd = CAPIMSG_SUBCOMMAND(skb->data);
 	if (cmd == CAPI_DATA_B3 && subcmd == CAPI_IND) {
-		card->nrecvdatapkt++;
-	        if (card->traceflag > 2) showctl |= 2;
+		ctr->nrecvdatapkt++;
+		if (ctr->traceflag > 2)
+			showctl |= 2;
 	} else {
-		card->nrecvctlpkt++;
-	        if (card->traceflag) showctl |= 2;
+		ctr->nrecvctlpkt++;
+		if (ctr->traceflag)
+			showctl |= 2;
 	}
-	showctl |= (card->traceflag & 1);
+	showctl |= (ctr->traceflag & 1);
 	if (showctl & 2) {
 		if (showctl & 1) {
 			printk(KERN_DEBUG "kcapi: got [%03d] id#%d %s len=%u\n",
-			       card->cnr, CAPIMSG_APPID(skb->data),
+			       ctr->cnr, CAPIMSG_APPID(skb->data),
 			       capi_cmd2str(cmd, subcmd),
 			       CAPIMSG_LEN(skb->data));
 		} else {
 			cdb = capi_message2str(skb->data);
 			if (cdb) {
 				printk(KERN_DEBUG "kcapi: got [%03d] %s\n",
-					card->cnr, cdb->buf);
+					ctr->cnr, cdb->buf);
 				cdebbuf_free(cdb);
 			} else
 				printk(KERN_DEBUG "kcapi: got [%03d] id#%d %s len=%u, cannot trace\n",
-					card->cnr, CAPIMSG_APPID(skb->data),
+					ctr->cnr, CAPIMSG_APPID(skb->data),
 					capi_cmd2str(cmd, subcmd),
 					CAPIMSG_LEN(skb->data));
 		}
@@ -356,74 +361,75 @@ EXPORT_SYMBOL(capi_ctr_handle_message);
 
 /**
  * capi_ctr_ready() - signal CAPI controller ready
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to signal that the controller is up and running.
  */
 
-void capi_ctr_ready(struct capi_ctr * card)
+void capi_ctr_ready(struct capi_ctr *ctr)
 {
-	card->cardstate = CARD_RUNNING;
+	ctr->state = CAPI_CTR_RUNNING;
 
-        printk(KERN_NOTICE "kcapi: card [%03d] \"%s\" ready.\n",
-	       card->cnr, card->name);
+	printk(KERN_NOTICE "kcapi: controller [%03d] \"%s\" ready.\n",
+	       ctr->cnr, ctr->name);
 
-	notify_push(KCI_CONTRUP, card->cnr, 0, 0);
+	notify_push(KCI_CONTRUP, ctr->cnr, 0, 0);
 }
 
 EXPORT_SYMBOL(capi_ctr_ready);
 
 /**
  * capi_ctr_down() - signal CAPI controller not ready
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to signal that the controller is down and
  * unavailable for use.
  */
 
-void capi_ctr_down(struct capi_ctr * card)
+void capi_ctr_down(struct capi_ctr *ctr)
 {
 	u16 appl;
 
 	DBG("");
 
-        if (card->cardstate == CARD_DETECTED)
+	if (ctr->state == CAPI_CTR_DETECTED)
 		return;
 
-        card->cardstate = CARD_DETECTED;
+	ctr->state = CAPI_CTR_DETECTED;
 
-	memset(card->manu, 0, sizeof(card->manu));
-	memset(&card->version, 0, sizeof(card->version));
-	memset(&card->profile, 0, sizeof(card->profile));
-	memset(card->serial, 0, sizeof(card->serial));
+	memset(ctr->manu, 0, sizeof(ctr->manu));
+	memset(&ctr->version, 0, sizeof(ctr->version));
+	memset(&ctr->profile, 0, sizeof(ctr->profile));
+	memset(ctr->serial, 0, sizeof(ctr->serial));
 
 	for (appl = 1; appl <= CAPI_MAXAPPL; appl++) {
 		struct capi20_appl *ap = get_capi_appl_by_nr(appl);
 		if (!ap || ap->release_in_progress)
 			continue;
 
-		capi_ctr_put(card);
+		capi_ctr_put(ctr);
 	}
 
-	printk(KERN_NOTICE "kcapi: card [%03d] down.\n", card->cnr);
+	printk(KERN_NOTICE "kcapi: controller [%03d] down.\n", ctr->cnr);
 
-	notify_push(KCI_CONTRDOWN, card->cnr, 0, 0);
+	notify_push(KCI_CONTRDOWN, ctr->cnr, 0, 0);
 }
 
 EXPORT_SYMBOL(capi_ctr_down);
 
 /**
  * capi_ctr_suspend_output() - suspend controller
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to stop data flow.
  */
 
-void capi_ctr_suspend_output(struct capi_ctr *card)
+void capi_ctr_suspend_output(struct capi_ctr *ctr)
 {
-	if (!card->blocked) {
-		printk(KERN_DEBUG "kcapi: card [%03d] suspend\n", card->cnr);
-		card->blocked = 1;
+	if (!ctr->blocked) {
+		printk(KERN_DEBUG "kcapi: controller [%03d] suspend\n",
+		       ctr->cnr);
+		ctr->blocked = 1;
 	}
 }
 
@@ -431,16 +437,17 @@ EXPORT_SYMBOL(capi_ctr_suspend_output);
 
 /**
  * capi_ctr_resume_output() - resume controller
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to resume data flow.
  */
 
-void capi_ctr_resume_output(struct capi_ctr *card)
+void capi_ctr_resume_output(struct capi_ctr *ctr)
 {
-	if (card->blocked) {
-		printk(KERN_DEBUG "kcapi: card [%03d] resume\n", card->cnr);
-		card->blocked = 0;
+	if (ctr->blocked) {
+		printk(KERN_DEBUG "kcapi: controller [%03d] resumed\n",
+		       ctr->cnr);
+		ctr->blocked = 0;
 	}
 }
 
@@ -450,21 +457,20 @@ EXPORT_SYMBOL(capi_ctr_resume_output);
 
 /**
  * attach_capi_ctr() - register CAPI controller
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to register a controller with the CAPI subsystem.
  * Return value: 0 on success, error code < 0 on error
  */
 
-int
-attach_capi_ctr(struct capi_ctr *card)
+int attach_capi_ctr(struct capi_ctr *ctr)
 {
 	int i;
 
 	mutex_lock(&controller_mutex);
 
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
-		if (capi_cards[i] == NULL)
+		if (!capi_controller[i])
 			break;
 	}
 	if (i == CAPI_MAXCONTR) {
@@ -472,25 +478,25 @@ attach_capi_ctr(struct capi_ctr *card)
 		printk(KERN_ERR "kcapi: out of controller slots\n");
 	   	return -EBUSY;
 	}
-	capi_cards[i] = card;
+	capi_controller[i] = ctr;
 
 	mutex_unlock(&controller_mutex);
 
-	card->nrecvctlpkt = 0;
-	card->nrecvdatapkt = 0;
-	card->nsentctlpkt = 0;
-	card->nsentdatapkt = 0;
-	card->cnr = i + 1;
-	card->cardstate = CARD_DETECTED;
-	card->blocked = 0;
-	card->traceflag = showcapimsgs;
-
-	sprintf(card->procfn, "capi/controllers/%d", card->cnr);
-	card->procent = proc_create_data(card->procfn, 0, NULL, card->proc_fops, card);
-
-	ncards++;
-	printk(KERN_NOTICE "kcapi: Controller [%03d]: %s attached\n",
-			card->cnr, card->name);
+	ctr->nrecvctlpkt = 0;
+	ctr->nrecvdatapkt = 0;
+	ctr->nsentctlpkt = 0;
+	ctr->nsentdatapkt = 0;
+	ctr->cnr = i + 1;
+	ctr->state = CAPI_CTR_DETECTED;
+	ctr->blocked = 0;
+	ctr->traceflag = showcapimsgs;
+
+	sprintf(ctr->procfn, "capi/controllers/%d", ctr->cnr);
+	ctr->procent = proc_create_data(ctr->procfn, 0, NULL, ctr->proc_fops, ctr);
+
+	ncontrollers++;
+	printk(KERN_NOTICE "kcapi: controller [%03d]: %s attached\n",
+			ctr->cnr, ctr->name);
 	return 0;
 }
 
@@ -498,27 +504,27 @@ EXPORT_SYMBOL(attach_capi_ctr);
 
 /**
  * detach_capi_ctr() - unregister CAPI controller
- * @card:	controller descriptor structure.
+ * @ctr:	controller descriptor structure.
  *
  * Called by hardware driver to remove the registration of a controller
  * with the CAPI subsystem.
  * Return value: 0 on success, error code < 0 on error
  */
 
-int detach_capi_ctr(struct capi_ctr *card)
+int detach_capi_ctr(struct capi_ctr *ctr)
 {
-        if (card->cardstate != CARD_DETECTED)
-		capi_ctr_down(card);
+	if (ctr->state != CAPI_CTR_DETECTED)
+		capi_ctr_down(ctr);
 
-	ncards--;
+	ncontrollers--;
 
-	if (card->procent) {
-	   remove_proc_entry(card->procfn, NULL);
-	   card->procent = NULL;
+	if (ctr->procent) {
+		remove_proc_entry(ctr->procfn, NULL);
+		ctr->procent = NULL;
 	}
-	capi_cards[card->cnr - 1] = NULL;
-	printk(KERN_NOTICE "kcapi: Controller [%03d]: %s unregistered\n",
-			card->cnr, card->name);
+	capi_controller[ctr->cnr - 1] = NULL;
+	printk(KERN_NOTICE "kcapi: controller [%03d]: %s unregistered\n",
+	       ctr->cnr, ctr->name);
 
 	return 0;
 }
@@ -576,7 +582,8 @@ u16 capi20_isinstalled(void)
 {
 	int i;
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
-		if (capi_cards[i] && capi_cards[i]->cardstate == CARD_RUNNING)
+		if (capi_controller[i] &&
+		    capi_controller[i]->state == CAPI_CTR_RUNNING)
 			return CAPI_NOERROR;
 	}
 	return CAPI_REGNOTINSTALLED;
@@ -635,9 +642,10 @@ u16 capi20_register(struct capi20_appl *ap)
 	
 	mutex_lock(&controller_mutex);
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
-		if (!capi_cards[i] || capi_cards[i]->cardstate != CARD_RUNNING)
+		if (!capi_controller[i] ||
+		    capi_controller[i]->state != CAPI_CTR_RUNNING)
 			continue;
-		register_appl(capi_cards[i], applid, &ap->rparam);
+		register_appl(capi_controller[i], applid, &ap->rparam);
 	}
 	mutex_unlock(&controller_mutex);
 
@@ -674,9 +682,10 @@ u16 capi20_release(struct capi20_appl *ap)
 
 	mutex_lock(&controller_mutex);
 	for (i = 0; i < CAPI_MAXCONTR; i++) {
-		if (!capi_cards[i] || capi_cards[i]->cardstate != CARD_RUNNING)
+		if (!capi_controller[i] ||
+		    capi_controller[i]->state != CAPI_CTR_RUNNING)
 			continue;
-		release_appl(capi_cards[i], ap->applid);
+		release_appl(capi_controller[i], ap->applid);
 	}
 	mutex_unlock(&controller_mutex);
 
@@ -703,13 +712,13 @@ EXPORT_SYMBOL(capi20_release);
 
 u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 {
-	struct capi_ctr *card;
+	struct capi_ctr *ctr;
 	int showctl = 0;
 	u8 cmd, subcmd;
 
 	DBG("applid %#x", ap->applid);
  
-	if (ncards == 0)
+	if (ncontrollers == 0)
 		return CAPI_REGNOTINSTALLED;
 	if ((ap->applid == 0) || ap->release_in_progress)
 		return CAPI_ILLAPPNR;
@@ -717,28 +726,30 @@ u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 	    || !capi_cmd_valid(CAPIMSG_COMMAND(skb->data))
 	    || !capi_subcmd_valid(CAPIMSG_SUBCOMMAND(skb->data)))
 		return CAPI_ILLCMDORSUBCMDORMSGTOSMALL;
-	card = get_capi_ctr_by_nr(CAPIMSG_CONTROLLER(skb->data));
-	if (!card || card->cardstate != CARD_RUNNING) {
-		card = get_capi_ctr_by_nr(1); // XXX why?
-	        if (!card || card->cardstate != CARD_RUNNING) 
+	ctr = get_capi_ctr_by_nr(CAPIMSG_CONTROLLER(skb->data));
+	if (!ctr || ctr->state != CAPI_CTR_RUNNING) {
+		ctr = get_capi_ctr_by_nr(1); /* XXX why? */
+		if (!ctr || ctr->state != CAPI_CTR_RUNNING)
 			return CAPI_REGNOTINSTALLED;
 	}
-	if (card->blocked)
+	if (ctr->blocked)
 		return CAPI_SENDQUEUEFULL;
 
 	cmd = CAPIMSG_COMMAND(skb->data);
         subcmd = CAPIMSG_SUBCOMMAND(skb->data);
 
 	if (cmd == CAPI_DATA_B3 && subcmd== CAPI_REQ) {
-		card->nsentdatapkt++;
+		ctr->nsentdatapkt++;
 		ap->nsentdatapkt++;
-	        if (card->traceflag > 2) showctl |= 2;
+		if (ctr->traceflag > 2)
+			showctl |= 2;
 	} else {
-		card->nsentctlpkt++;
+		ctr->nsentctlpkt++;
 		ap->nsentctlpkt++;
-	        if (card->traceflag) showctl |= 2;
+		if (ctr->traceflag)
+			showctl |= 2;
 	}
-	showctl |= (card->traceflag & 1);
+	showctl |= (ctr->traceflag & 1);
 	if (showctl & 2) {
 		if (showctl & 1) {
 			printk(KERN_DEBUG "kcapi: put [%03d] id#%d %s len=%u\n",
@@ -761,7 +772,7 @@ u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 					CAPIMSG_LEN(skb->data));
 		}
 	}
-	return card->send_message(card, skb);
+	return ctr->send_message(ctr, skb);
 }
 
 EXPORT_SYMBOL(capi20_put_message);
@@ -778,16 +789,16 @@ EXPORT_SYMBOL(capi20_put_message);
 
 u16 capi20_get_manufacturer(u32 contr, u8 *buf)
 {
-	struct capi_ctr *card;
+	struct capi_ctr *ctr;
 
 	if (contr == 0) {
 		strlcpy(buf, capi_manufakturer, CAPI_MANUFACTURER_LEN);
 		return CAPI_NOERROR;
 	}
-	card = get_capi_ctr_by_nr(contr);
-	if (!card || card->cardstate != CARD_RUNNING) 
+	ctr = get_capi_ctr_by_nr(contr);
+	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
 		return CAPI_REGNOTINSTALLED;
-	strlcpy(buf, card->manu, CAPI_MANUFACTURER_LEN);
+	strlcpy(buf, ctr->manu, CAPI_MANUFACTURER_LEN);
 	return CAPI_NOERROR;
 }
 
@@ -805,17 +816,17 @@ EXPORT_SYMBOL(capi20_get_manufacturer);
 
 u16 capi20_get_version(u32 contr, struct capi_version *verp)
 {
-	struct capi_ctr *card;
+	struct capi_ctr *ctr;
 
 	if (contr == 0) {
 		*verp = driver_version;
 		return CAPI_NOERROR;
 	}
-	card = get_capi_ctr_by_nr(contr);
-	if (!card || card->cardstate != CARD_RUNNING) 
+	ctr = get_capi_ctr_by_nr(contr);
+	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
 		return CAPI_REGNOTINSTALLED;
 
-	memcpy((void *) verp, &card->version, sizeof(capi_version));
+	memcpy(verp, &ctr->version, sizeof(capi_version));
 	return CAPI_NOERROR;
 }
 
@@ -833,17 +844,17 @@ EXPORT_SYMBOL(capi20_get_version);
 
 u16 capi20_get_serial(u32 contr, u8 *serial)
 {
-	struct capi_ctr *card;
+	struct capi_ctr *ctr;
 
 	if (contr == 0) {
 		strlcpy(serial, driver_serial, CAPI_SERIAL_LEN);
 		return CAPI_NOERROR;
 	}
-	card = get_capi_ctr_by_nr(contr);
-	if (!card || card->cardstate != CARD_RUNNING) 
+	ctr = get_capi_ctr_by_nr(contr);
+	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
 		return CAPI_REGNOTINSTALLED;
 
-	strlcpy((void *) serial, card->serial, CAPI_SERIAL_LEN);
+	strlcpy(serial, ctr->serial, CAPI_SERIAL_LEN);
 	return CAPI_NOERROR;
 }
 
@@ -861,18 +872,17 @@ EXPORT_SYMBOL(capi20_get_serial);
 
 u16 capi20_get_profile(u32 contr, struct capi_profile *profp)
 {
-	struct capi_ctr *card;
+	struct capi_ctr *ctr;
 
 	if (contr == 0) {
-		profp->ncontroller = ncards;
+		profp->ncontroller = ncontrollers;
 		return CAPI_NOERROR;
 	}
-	card = get_capi_ctr_by_nr(contr);
-	if (!card || card->cardstate != CARD_RUNNING) 
+	ctr = get_capi_ctr_by_nr(contr);
+	if (!ctr || ctr->state != CAPI_CTR_RUNNING)
 		return CAPI_REGNOTINSTALLED;
 
-	memcpy((void *) profp, &card->profile,
-			sizeof(struct capi_profile));
+	memcpy(profp, &ctr->profile, sizeof(struct capi_profile));
 	return CAPI_NOERROR;
 }
 
@@ -885,7 +895,7 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 	avmb1_extcarddef cdef;
 	avmb1_resetdef rdef;
 	capicardparams cparams;
-	struct capi_ctr *card;
+	struct capi_ctr *ctr;
 	struct capi_driver *driver = NULL;
 	capiloaddata ldata;
 	struct list_head *l;
@@ -958,26 +968,26 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 					   sizeof(avmb1_loadandconfigdef)))
 				return -EFAULT;
 		}
-		card = get_capi_ctr_by_nr(ldef.contr);
-		if (!card)
+		ctr = get_capi_ctr_by_nr(ldef.contr);
+		if (!ctr)
 			return -EINVAL;
-		card = capi_ctr_get(card);
-		if (!card)
+		ctr = capi_ctr_get(ctr);
+		if (!ctr)
 			return -ESRCH;
-		if (card->load_firmware == NULL) {
+		if (ctr->load_firmware == NULL) {
 			printk(KERN_DEBUG "kcapi: load: no load function\n");
-			capi_ctr_put(card);
+			capi_ctr_put(ctr);
 			return -ESRCH;
 		}
 
 		if (ldef.t4file.len <= 0) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: length of t4file is %d ?\n", ldef.t4file.len);
-			capi_ctr_put(card);
+			capi_ctr_put(ctr);
 			return -EINVAL;
 		}
 		if (ldef.t4file.data == NULL) {
 			printk(KERN_DEBUG "kcapi: load: invalid parameter: dataptr is 0\n");
-			capi_ctr_put(card);
+			capi_ctr_put(ctr);
 			return -EINVAL;
 		}
 
@@ -988,46 +998,46 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 		ldata.configuration.data = ldef.t4config.data;
 		ldata.configuration.len = ldef.t4config.len;
 
-		if (card->cardstate != CARD_DETECTED) {
+		if (ctr->state != CAPI_CTR_DETECTED) {
 			printk(KERN_INFO "kcapi: load: contr=%d not in detect state\n", ldef.contr);
-			capi_ctr_put(card);
+			capi_ctr_put(ctr);
 			return -EBUSY;
 		}
-		card->cardstate = CARD_LOADING;
+		ctr->state = CAPI_CTR_LOADING;
 
-		retval = card->load_firmware(card, &ldata);
+		retval = ctr->load_firmware(ctr, &ldata);
 
 		if (retval) {
-			card->cardstate = CARD_DETECTED;
-			capi_ctr_put(card);
+			ctr->state = CAPI_CTR_DETECTED;
+			capi_ctr_put(ctr);
 			return retval;
 		}
 
-		while (card->cardstate != CARD_RUNNING) {
+		while (ctr->state != CAPI_CTR_RUNNING) {
 
 			msleep_interruptible(100);	/* 0.1 sec */
 
 			if (signal_pending(current)) {
-				capi_ctr_put(card);
+				capi_ctr_put(ctr);
 				return -EINTR;
 			}
 		}
-		capi_ctr_put(card);
+		capi_ctr_put(ctr);
 		return 0;
 
 	case AVMB1_RESETCARD:
 		if (copy_from_user(&rdef, data, sizeof(avmb1_resetdef)))
 			return -EFAULT;
-		card = get_capi_ctr_by_nr(rdef.contr);
-		if (!card)
+		ctr = get_capi_ctr_by_nr(rdef.contr);
+		if (!ctr)
 			return -ESRCH;
 
-		if (card->cardstate == CARD_DETECTED)
+		if (ctr->state == CAPI_CTR_DETECTED)
 			return 0;
 
-		card->reset_ctr(card);
+		ctr->reset_ctr(ctr);
 
-		while (card->cardstate > CARD_DETECTED) {
+		while (ctr->state > CAPI_CTR_DETECTED) {
 
 			msleep_interruptible(100);	/* 0.1 sec */
 
@@ -1052,7 +1062,7 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 
 int capi20_manufacturer(unsigned int cmd, void __user *data)
 {
-        struct capi_ctr *card;
+	struct capi_ctr *ctr;
 
 	switch (cmd) {
 #ifdef AVMB1_COMPAT
@@ -1070,13 +1080,13 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		if (copy_from_user(&fdef, data, sizeof(kcapi_flagdef)))
 			return -EFAULT;
 
-		card = get_capi_ctr_by_nr(fdef.contr);
-		if (!card)
+		ctr = get_capi_ctr_by_nr(fdef.contr);
+		if (!ctr)
 			return -ESRCH;
 
-		card->traceflag = fdef.flag;
+		ctr->traceflag = fdef.flag;
 		printk(KERN_INFO "kcapi: contr [%03d] set trace=%d\n",
-			card->cnr, card->traceflag);
+		       ctr->cnr, ctr->traceflag);
 		return 0;
 	}
 	case KCAPI_CMD_ADDCARD:
diff --git a/drivers/isdn/capi/kcapi.h b/drivers/isdn/capi/kcapi.h
index 244711f..f62c53b 100644
--- a/drivers/isdn/capi/kcapi.h
+++ b/drivers/isdn/capi/kcapi.h
@@ -24,16 +24,16 @@ printk(KERN_DEBUG "%s: " format "\n" , __func__ , ## arg); \
 #endif
 
 enum {
-	CARD_DETECTED = 1,
-	CARD_LOADING  =	2,
-	CARD_RUNNING  = 3,
+	CAPI_CTR_DETECTED = 1,
+	CAPI_CTR_LOADING  = 2,
+	CAPI_CTR_RUNNING  = 3,
 };
 
 extern struct list_head capi_drivers;
 extern rwlock_t capi_drivers_list_lock;
 
 extern struct capi20_appl *capi_applications[CAPI_MAXAPPL];
-extern struct capi_ctr *capi_cards[CAPI_MAXCONTR];
+extern struct capi_ctr *capi_controller[CAPI_MAXCONTR];
 
 #ifdef CONFIG_PROC_FS
 
diff --git a/drivers/isdn/capi/kcapi_proc.c b/drivers/isdn/capi/kcapi_proc.c
index 09d4db7..59fd16a 100644
--- a/drivers/isdn/capi/kcapi_proc.c
+++ b/drivers/isdn/capi/kcapi_proc.c
@@ -15,13 +15,12 @@
 #include <linux/seq_file.h>
 #include <linux/init.h>
 
-static char *
-cardstate2str(unsigned short cardstate)
+static char *state2str(unsigned short state)
 {
-	switch (cardstate) {
-	case CARD_DETECTED:	return "detected";
-	case CARD_LOADING:	return "loading";
-	case CARD_RUNNING:	return "running";
+	switch (state) {
+	case CAPI_CTR_DETECTED:	return "detected";
+	case CAPI_CTR_LOADING:	return "loading";
+	case CAPI_CTR_RUNNING:	return "running";
 	default:	        return "???";
 	}
 }
@@ -38,7 +37,7 @@ cardstate2str(unsigned short cardstate)
 static void *controller_start(struct seq_file *seq, loff_t *pos)
 {
 	if (*pos < CAPI_MAXCONTR)
-		return &capi_cards[*pos];
+		return &capi_controller[*pos];
 
 	return NULL;
 }
@@ -47,7 +46,7 @@ static void *controller_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	++*pos;
 	if (*pos < CAPI_MAXCONTR)
-		return &capi_cards[*pos];
+		return &capi_controller[*pos];
 
 	return NULL;
 }
@@ -65,7 +64,7 @@ static int controller_show(struct seq_file *seq, void *v)
 
 	seq_printf(seq, "%d %-10s %-8s %-16s %s\n",
 		   ctr->cnr, ctr->driver_name,
-		   cardstate2str(ctr->cardstate),
+		   state2str(ctr->state),
 		   ctr->name,
 		   ctr->procinfo ?  ctr->procinfo(ctr) : "");
 
diff --git a/include/linux/isdn/capilli.h b/include/linux/isdn/capilli.h
index d3e5e9d..856f38e 100644
--- a/include/linux/isdn/capilli.h
+++ b/include/linux/isdn/capilli.h
@@ -66,7 +66,7 @@ struct capi_ctr {
 	unsigned long nsentdatapkt;
 
 	int cnr;				/* controller number */
-	volatile unsigned short cardstate;	/* controller state */
+	volatile unsigned short state;		/* controller state */
 	volatile int blocked;			/* output blocked */
 	int traceflag;				/* capi trace */
 
-- 
1.6.0.2
