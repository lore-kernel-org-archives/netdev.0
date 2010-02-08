From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 23/41] CAPI: Use kref on capiminor
Date: Mon,  8 Feb 2010 21:12:27 +0100
Message-ID: <dd97f250aec5139ce55bb88f41822f2fe76ee4e9.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:43278 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914Ab0BHUNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:09 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Install a reference counter for capiminor objects. Acquire it when
obtaining a capiminor from the array during capinc_tty_open, drop it
when closing the tty again. Another reference is held for the hook-up
with capincci.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   37 ++++++++++++++++++++++++++++---------
 1 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index b1de0cb..732cdb5 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -83,6 +83,8 @@ struct datahandle_queue {
 };
 
 struct capiminor {
+	struct kref kref;
+
 	struct capincci  *nccip;
 	unsigned int      minor;
 	struct dentry *capifs_dentry;
@@ -223,6 +225,8 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 		return NULL;
 	}
 
+	kref_init(&mp->kref);
+
 	mp->ap = ap;
 	mp->ncci = ncci;
 	mp->msgid = 0;
@@ -265,18 +269,11 @@ err_out1:
 	return NULL;
 }
 
-static void capiminor_free(struct capiminor *mp)
+static void capiminor_destroy(struct kref *kref)
 {
-	unsigned long flags;
-
-	tty_unregister_device(capinc_tty_driver, mp->minor);
-
-	write_lock_irqsave(&capiminors_lock, flags);
-	capiminors[mp->minor] = NULL;
-	write_unlock_irqrestore(&capiminors_lock, flags);
+	struct capiminor *mp = container_of(kref, struct capiminor, kref);
 
 	kfree_skb(mp->ttyskb);
-	mp->ttyskb = NULL;
 	skb_queue_purge(&mp->inqueue);
 	skb_queue_purge(&mp->outqueue);
 	capiminor_del_all_ack(mp);
@@ -289,11 +286,31 @@ static struct capiminor *capiminor_get(unsigned int minor)
 
 	read_lock(&capiminors_lock);
 	mp = capiminors[minor];
+	if (mp)
+		kref_get(&mp->kref);
 	read_unlock(&capiminors_lock);
 
 	return mp;
 }
 
+static inline void capiminor_put(struct capiminor *mp)
+{
+	kref_put(&mp->kref, capiminor_destroy);
+}
+
+static void capiminor_free(struct capiminor *mp)
+{
+	unsigned long flags;
+
+	tty_unregister_device(capinc_tty_driver, mp->minor);
+
+	write_lock_irqsave(&capiminors_lock, flags);
+	capiminors[mp->minor] = NULL;
+	write_unlock_irqrestore(&capiminors_lock, flags);
+
+	capiminor_put(mp);
+}
+
 /* -------- struct capincci ----------------------------------------- */
 
 static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
@@ -1029,6 +1046,8 @@ static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 #endif
 		if (mp->nccip == NULL)
 			capiminor_free(mp);
+
+		capiminor_put(mp);
 	}
 
 #ifdef _DEBUG_REFCOUNT
-- 
1.6.0.2

