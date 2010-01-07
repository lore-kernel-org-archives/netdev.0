From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 08/31] CAPI: Rework capi_ctr_ready/down
Date: Thu, 7 Jan 2010 11:53:40 +0100
Message-ID: <55d269bad8849ac9b578b9229c3384aa0f71847e.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755745Ab0AVXW3@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This step prepares the application of proper controller locking: Push
all state changing work into the notify handler that are called by
capi_ctr_ready and capi_ctr_down, switch detach_capi_ctr to issue a
synchronous ctr_down. Also ensure that we do not go through any action
if the state did not change.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/kcapi.c |   95 +++++++++++++++++++++++---------------------
 1 files changed, 50 insertions(+), 45 deletions(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 476239f..3fcc95b 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -169,44 +169,74 @@ static void release_appl(struct capi_ctr *ctr, u16 applid)
 
 static void notify_up(u32 contr)
 {
-	struct capi_ctr *ctr = get_capi_ctr_by_nr(contr);
 	struct capi20_appl *ap;
+	struct capi_ctr *ctr;
 	u16 applid;
 
-	if (showcapimsgs & 1) {
+	if (showcapimsgs & 1)
 	        printk(KERN_DEBUG "kcapi: notify up contr %dn", contr);
-	}
-	if (!ctr) {
+
+	ctr = get_capi_ctr_by_nr(contr);
+	if (ctr) {
+		if (ctr->state == CAPI_CTR_RUNNING)
+			return;
+
+		ctr->state = CAPI_CTR_RUNNING;
+
+		for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
+			ap = get_capi_appl_by_nr(applid);
+			if (!ap || ap->release_in_progress)
+				continue;
+			register_appl(ctr, applid, &ap->rparam);
+			if (ap->callback && !ap->release_in_progress)
+				ap->callback(KCI_CONTRUP, contr,
+					     &ctr->profile);
+		}
+	} else
 		printk(KERN_WARNING "%s: invalid contr %dn", __func__, contr);
-		return;
-	}
-	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
-		ap = get_capi_appl_by_nr(applid);
-		if (!ap || ap->release_in_progress) continue;
-		register_appl(ctr, applid, &ap->rparam);
-		if (ap->callback && !ap->release_in_progress)
-			ap->callback(KCI_CONTRUP, contr, &ctr->profile);
-	}
 }
 
 /* -------- KCI_CONTRDOWN ------------------------------------- */
 
-static void notify_down(u32 contr)
+static void ctr_down(struct capi_ctr *ctr)
 {
 	struct capi20_appl *ap;
 	u16 applid;
 
-	if (showcapimsgs & 1) {
-        	printk(KERN_DEBUG "kcapi: notify down contr %dn", contr);
-	}
+	if (ctr->state == CAPI_CTR_DETECTED)
+		return;
+
+	ctr->state = CAPI_CTR_DETECTED;
+
+	memset(ctr->manu, 0, sizeof(ctr->manu));
+	memset(&ctr->version, 0, sizeof(ctr->version));
+	memset(&ctr->profile, 0, sizeof(ctr->profile));
+	memset(ctr->serial, 0, sizeof(ctr->serial));
 
 	for (applid = 1; applid <= CAPI_MAXAPPL; applid++) {
 		ap = get_capi_appl_by_nr(applid);
-		if (ap && ap->callback && !ap->release_in_progress)
-			ap->callback(KCI_CONTRDOWN, contr, NULL);
+		if (ap && !ap->release_in_progress) {
+			if (ap->callback)
+				ap->callback(KCI_CONTRDOWN, ctr->cnr, NULL);
+			capi_ctr_put(ctr);
+		}
 	}
 }
 
+static void notify_down(u32 contr)
+{
+	struct capi_ctr *ctr;
+
+	if (showcapimsgs & 1)
+		printk(KERN_DEBUG "kcapi: notify down contr %dn", contr);
+
+	ctr = get_capi_ctr_by_nr(contr);
+	if (ctr)
+		ctr_down(ctr);
+	else
+		printk(KERN_WARNING "%s: invalid contr %dn", __func__, contr);
+}
+
 static void notify_handler(struct work_struct *work)
 {
 	struct capi_notifier *np =
@@ -368,8 +398,6 @@ EXPORT_SYMBOL(capi_ctr_handle_message);
 
 void capi_ctr_ready(struct capi_ctr *ctr)
 {
-	ctr->state = CAPI_CTR_RUNNING;
-
 	printk(KERN_NOTICE "kcapi: controller [%03d] "%s" ready.n",
 	       ctr->cnr, ctr->name);
 
@@ -388,28 +416,6 @@ EXPORT_SYMBOL(capi_ctr_ready);
 
 void capi_ctr_down(struct capi_ctr *ctr)
 {
-	u16 appl;
-
-	DBG("");
-
-	if (ctr->state == CAPI_CTR_DETECTED)
-		return;
-
-	ctr->state = CAPI_CTR_DETECTED;
-
-	memset(ctr->manu, 0, sizeof(ctr->manu));
-	memset(&ctr->version, 0, sizeof(ctr->version));
-	memset(&ctr->profile, 0, sizeof(ctr->profile));
-	memset(ctr->serial, 0, sizeof(ctr->serial));
-
-	for (appl = 1; appl <= CAPI_MAXAPPL; appl++) {
-		struct capi20_appl *ap = get_capi_appl_by_nr(appl);
-		if (!ap || ap->release_in_progress)
-			continue;
-
-		capi_ctr_put(ctr);
-	}
-
 	printk(KERN_NOTICE "kcapi: controller [%03d] down.n", ctr->cnr);
 
 	notify_push(KCI_CONTRDOWN, ctr->cnr, 0, 0);
@@ -517,8 +523,7 @@ EXPORT_SYMBOL(attach_capi_ctr);
 
 int detach_capi_ctr(struct capi_ctr *ctr)
 {
-	if (ctr->state != CAPI_CTR_DETECTED)
-		capi_ctr_down(ctr);
+	ctr_down(ctr);
 
 	ncontrollers--;
 
-- 
1.6.0.2
