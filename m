From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 19/41] CAPI: Switch capiminor list to array
Date: Mon,  8 Feb 2010 21:12:23 +0100
Message-ID: <2a5d0a1e03b34cce72714b3e8934af0ec961b70d.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:53712 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861Ab0BHUNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:07 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a plain array of pointers simplifies the management of capiminors.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   75 +++++++++++++++++++++------------------------
 1 files changed, 35 insertions(+), 40 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 6704b2b..46f85ae 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -85,7 +85,6 @@ struct datahandle_queue {
 };
 
 struct capiminor {
-	struct list_head list;
 	struct capincci  *nccip;
 	unsigned int      minor;
 	struct dentry *capifs_dentry;
@@ -151,8 +150,8 @@ static LIST_HEAD(capidev_list);
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 
-static DEFINE_RWLOCK(capiminor_list_lock);
-static LIST_HEAD(capiminor_list);
+static DEFINE_RWLOCK(capiminors_lock);
+static struct capiminor **capiminors;
 
 /* -------- datahandles --------------------------------------------- */
 
@@ -213,8 +212,8 @@ static void capiminor_del_all_ack(struct capiminor *mp)
 
 static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 {
-	struct capiminor *mp, *p;
-	unsigned int minor = 0;
+	struct capiminor *mp;
+	unsigned int minor;
 	unsigned long flags;
 
 	mp = kzalloc(sizeof(*mp), GFP_KERNEL);
@@ -233,31 +232,23 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	skb_queue_head_init(&mp->inqueue);
 	skb_queue_head_init(&mp->outqueue);
 
-	/* Allocate the least unused minor number.
-	 */
-	write_lock_irqsave(&capiminor_list_lock, flags);
-	if (list_empty(&capiminor_list))
-		list_add(&mp->list, &capiminor_list);
-	else {
-		list_for_each_entry(p, &capiminor_list, list) {
-			if (p->minor > minor)
-				break;
-			minor++;
-		}
-		
-		if (minor < capi_ttyminors) {
-			mp->minor = minor;
-			list_add(&mp->list, p->list.prev);
+	/* Allocate the least unused minor number. */
+	write_lock_irqsave(&capiminors_lock, flags);
+	for (minor = 0; minor < capi_ttyminors; minor++)
+		if (!capiminors[minor]) {
+			capiminors[minor] = mp;
+			break;
 		}
-	}
-		write_unlock_irqrestore(&capiminor_list_lock, flags);
+	write_unlock_irqrestore(&capiminors_lock, flags);
 
-	if (!(minor < capi_ttyminors)) {
+	if (minor == capi_ttyminors) {
 		printk(KERN_NOTICE "capi: out of minors\n");
-			kfree(mp);
+		kfree(mp);
 		return NULL;
 	}
 
+	mp->minor = minor;
+
 	return mp;
 }
 
@@ -265,9 +256,9 @@ static void capiminor_free(struct capiminor *mp)
 {
 	unsigned long flags;
 
-	write_lock_irqsave(&capiminor_list_lock, flags);
-	list_del(&mp->list);
-	write_unlock_irqrestore(&capiminor_list_lock, flags);
+	write_lock_irqsave(&capiminors_lock, flags);
+	capiminors[mp->minor] = NULL;
+	write_unlock_irqrestore(&capiminors_lock, flags);
 
 	kfree_skb(mp->ttyskb);
 	mp->ttyskb = NULL;
@@ -279,20 +270,16 @@ static void capiminor_free(struct capiminor *mp)
 
 static struct capiminor *capiminor_find(unsigned int minor)
 {
-	struct list_head *l;
-	struct capiminor *p = NULL;
+	struct capiminor *mp;
 
-	read_lock(&capiminor_list_lock);
-	list_for_each(l, &capiminor_list) {
-		p = list_entry(l, struct capiminor, list);
-		if (p->minor == minor)
-			break;
-	}
-	read_unlock(&capiminor_list_lock);
-	if (l == &capiminor_list)
+	if (minor >= capi_ttyminors)
 		return NULL;
 
-	return p;
+	read_lock(&capiminors_lock);
+	mp = capiminors[minor];
+	read_unlock(&capiminors_lock);
+
+	return mp;
 }
 
 /* -------- struct capincci ----------------------------------------- */
@@ -1329,10 +1316,16 @@ static int capinc_tty_init(void)
 	if (capi_ttyminors <= 0)
 		capi_ttyminors = CAPINC_NR_PORTS;
 
-	drv = alloc_tty_driver(capi_ttyminors);
-	if (!drv)
+	capiminors = kzalloc(sizeof(struct capi_minor *) * capi_ttyminors,
+			     GFP_KERNEL);
+	if (!capiminors)
 		return -ENOMEM;
 
+	drv = alloc_tty_driver(capi_ttyminors);
+	if (!drv) {
+		kfree(capiminors);
+		return -ENOMEM;
+	}
 	drv->owner = THIS_MODULE;
 	drv->driver_name = "capi_nc";
 	drv->name = "capi";
@@ -1349,6 +1342,7 @@ static int capinc_tty_init(void)
 	tty_set_operations(drv, &capinc_ops);
 	if (tty_register_driver(drv)) {
 		put_tty_driver(drv);
+		kfree(capiminors);
 		printk(KERN_ERR "Couldn't register capi_nc driver\n");
 		return -1;
 	}
@@ -1363,6 +1357,7 @@ static void capinc_tty_exit(void)
 	if ((retval = tty_unregister_driver(drv)))
 		printk(KERN_ERR "capi: failed to unregister capi_nc driver (%d)\n", retval);
 	put_tty_driver(drv);
+	kfree(capiminors);
 }
 
 #else /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
-- 
1.6.0.2

