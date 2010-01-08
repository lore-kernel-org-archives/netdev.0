From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 20/31] CAPI: Drop atomic ttyopencount
Date: Fri, 8 Jan 2010 11:38:58 +0100
Message-ID: <136f269e37529d1e40fc54ef3da02facd7bda21a.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:49661 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab0AVX0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:26:07 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not needed, tty->count keeps track of this information. At this chance,
drop traces of ancient attempts to debug this logic via _DEBUG_REFCOUNT.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   31 +++----------------------------
 1 files changed, 3 insertions(+), 28 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index b53cead..7710a66 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -44,7 +44,6 @@ MODULE_DESCRIPTION("CAPI4Linux: Userspace /dev/capi20 interface");
 MODULE_AUTHOR("Carsten Paeth");
 MODULE_LICENSE("GPL");
 
-#undef _DEBUG_REFCOUNT		/* alloc/free and open/close debug */
 #undef _DEBUG_TTYFUNCS		/* call to tty_driver */
 #undef _DEBUG_DATAFLOW		/* data flow */
 
@@ -98,7 +97,6 @@ struct capiminor {
 	int                ttyinstop;
 	int                ttyoutstop;
 	struct sk_buff    *ttyskb;
-	atomic_t           ttyopencount;
 
 	struct sk_buff_head inqueue;
 	int                 inbytes;
@@ -224,7 +222,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	mp->ap = ap;
 	mp->ncci = ncci;
 	mp->msgid = 0;
-	atomic_set(&mp->ttyopencount,0);
 	INIT_LIST_HEAD(&mp->ackqueue);
 	spin_lock_init(&mp->ackqlock);
 
@@ -294,9 +291,6 @@ static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 	mp = np->minorp = capiminor_alloc(&cdev->ap, np->ncci);
 	if (mp) {
 		mp->nccip = np;
-#ifdef _DEBUG_REFCOUNT
-		printk(KERN_DEBUG "set mp->nccipn");
-#endif
 		mp->capifs_dentry =
 			capifs_new_ncci(mp->minor,
 					MKDEV(capi_ttymajor, mp->minor));
@@ -316,9 +310,6 @@ static void capincci_free_minor(struct capincci *np)
 		capifs_free_ncci(mp->capifs_dentry);
 		if (mp->tty) {
 			mp->nccip = NULL;
-#ifdef _DEBUG_REFCOUNT
-			printk(KERN_DEBUG "reset mp->nccipn");
-#endif
 			tty_hangup(mp->tty);
 		} else {
 			capiminor_free(mp);
@@ -332,7 +323,7 @@ static inline unsigned int capincci_minor_opencount(struct capincci *np)
 {
 	struct capiminor *mp = np->minorp;
 
-	return mp ? atomic_read(&mp->ttyopencount) : 0;
+	return (mp && mp->tty) ? mp->tty->count : 0;
 }
 
 #else /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
@@ -998,14 +989,9 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 	}
 
 	tty->driver_data = mp;
+	mp->tty = tty;
 
 	spin_lock_irqsave(&workaround_lock, flags);
-	if (atomic_read(&mp->ttyopencount) == 0)
-		mp->tty = tty;
-	atomic_inc(&mp->ttyopencount);
-#ifdef _DEBUG_REFCOUNT
-	printk(KERN_DEBUG "capinc_tty_open ocount=%dn", atomic_read(&mp->ttyopencount));
-#endif
 	handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
 
@@ -1020,23 +1006,12 @@ static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 
 	mutex_lock(&glue_lock);
 
-	if (atomic_dec_and_test(&mp->ttyopencount)) {
-#ifdef _DEBUG_REFCOUNT
-		printk(KERN_DEBUG "capinc_tty_close lastclosen");
-#endif
+	if (tty->count == 1)
 		mp->tty = NULL;
-	}
-#ifdef _DEBUG_REFCOUNT
-		printk(KERN_DEBUG "capinc_tty_close ocount=%dn", atomic_read(&mp->ttyopencount));
-#endif
 	if (!mp->nccip)
 		capiminor_free(mp);
 
 	mutex_unlock(&glue_lock);
-
-#ifdef _DEBUG_REFCOUNT
-	printk(KERN_DEBUG "capinc_tty_closen");
-#endif
 }
 
 static int capinc_tty_write(struct tty_struct * tty,
-- 
1.6.0.2

