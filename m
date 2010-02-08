From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 30/41] CAPI: Drop atomic ttyopencount
Date: Mon,  8 Feb 2010 21:12:34 +0100
Message-ID: <30ac44a5faf0f7135d822d601651f328a8b14775.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:37271 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab0BHUNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:13 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not needed, tty->count keeps track of this information. At this chance,
drop traces of ancient attempts to debug this logic via _DEBUG_REFCOUNT.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   30 ++++++++++--------------------
 1 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 0b264b4..867589a 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -45,7 +45,6 @@ MODULE_DESCRIPTION("CAPI4Linux: Userspace /dev/capi20 interface");
 MODULE_AUTHOR("Carsten Paeth");
 MODULE_LICENSE("GPL");
 
-#undef _DEBUG_REFCOUNT		/* alloc/free and open/close debug */
 #undef _DEBUG_TTYFUNCS		/* call to tty_driver */
 #undef _DEBUG_DATAFLOW		/* data flow */
 
@@ -97,7 +96,6 @@ struct capiminor {
 	int                ttyinstop;
 	int                ttyoutstop;
 	struct sk_buff    *ttyskb;
-	atomic_t           ttyopencount;
 
 	struct sk_buff_head inqueue;
 	int                 inbytes;
@@ -230,7 +228,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	mp->ap = ap;
 	mp->ncci = ncci;
 	mp->msgid = 0;
-	atomic_set(&mp->ttyopencount,0);
 	INIT_LIST_HEAD(&mp->ackqueue);
 	spin_lock_init(&mp->ackqlock);
 
@@ -350,8 +347,17 @@ static void capincci_free_minor(struct capincci *np)
 static inline unsigned int capincci_minor_opencount(struct capincci *np)
 {
 	struct capiminor *mp = np->minorp;
+	unsigned int count = 0;
+	struct tty_struct *tty;
 
-	return mp ? atomic_read(&mp->ttyopencount) : 0;
+	if (mp) {
+		tty = tty_port_tty_get(&mp->port);
+		if (tty) {
+			count = tty->count;
+			tty_kref_put(tty);
+		}
+	}
+	return count;
 }
 
 #else /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
@@ -1054,10 +1060,6 @@ static int capinc_tty_open(struct tty_struct *tty, struct file *filp)
 		return err;
 
 	spin_lock_irqsave(&workaround_lock, flags);
-	atomic_inc(&mp->ttyopencount);
-#ifdef _DEBUG_REFCOUNT
-	printk(KERN_DEBUG "capinc_tty_open ocount=%d\n", atomic_read(&mp->ttyopencount));
-#endif
 	handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
 	return 0;
@@ -1067,18 +1069,6 @@ static void capinc_tty_close(struct tty_struct *tty, struct file *filp)
 {
 	struct capiminor *mp = tty->driver_data;
 
-		if (atomic_dec_and_test(&mp->ttyopencount)) {
-#ifdef _DEBUG_REFCOUNT
-			printk(KERN_DEBUG "capinc_tty_close lastclose\n");
-#endif
-		}
-#ifdef _DEBUG_REFCOUNT
-		printk(KERN_DEBUG "capinc_tty_close ocount=%d\n", atomic_read(&mp->ttyopencount));
-#endif
-
-#ifdef _DEBUG_REFCOUNT
-	printk(KERN_DEBUG "capinc_tty_close\n");
-#endif
 	tty_port_close(&mp->port, tty, filp);
 }
 
-- 
1.6.0.2

