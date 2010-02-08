From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 18/41] CAPI: Switch NCCI list to standard doubly linked list
Date: Mon,  8 Feb 2010 21:12:22 +0100
Message-ID: <bae65a3aaf3ce9922f63145ffd0fc46768aac147.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:53702 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856Ab0BHUNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:06 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace open-coded NCCI list management with standard mechanisms.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   52 +++++++++++++++++----------------------------
 1 files changed, 20 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 8abec96..6704b2b 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -122,7 +122,7 @@ struct capiminor {
 static DEFINE_SPINLOCK(workaround_lock);
 
 struct capincci {
-	struct capincci *next;
+	struct list_head list;
 	u32		 ncci;
 	struct capidev	*cdev;
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
@@ -139,7 +139,7 @@ struct capidev {
 	struct sk_buff_head recvqueue;
 	wait_queue_head_t recvwait;
 
-	struct capincci *nccis;
+	struct list_head nccis;
 
 	struct mutex lock;
 };
@@ -356,7 +356,7 @@ static inline unsigned int capincci_minor_opencount(struct capincci *np)
 
 static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 {
-	struct capincci *np, **pp;
+	struct capincci *np;
 
 	np = kzalloc(sizeof(*np), GFP_KERNEL);
 	if (!np)
@@ -366,39 +366,31 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 
 	capincci_alloc_minor(cdev, np);
 
-	for (pp=&cdev->nccis; *pp; pp = &(*pp)->next)
-		;
-	*pp = np;
-        return np;
+	list_add_tail(&np->list, &cdev->nccis);
+
+	return np;
 }
 
 static void capincci_free(struct capidev *cdev, u32 ncci)
 {
-	struct capincci *np, **pp;
+	struct capincci *np, *tmp;
 
-	pp=&cdev->nccis;
-	while (*pp) {
-		np = *pp;
+	list_for_each_entry_safe(np, tmp, &cdev->nccis, list)
 		if (ncci == 0xffffffff || np->ncci == ncci) {
-			*pp = (*pp)->next;
 			capincci_free_minor(np);
+			list_del(&np->list);
 			kfree(np);
-			if (*pp == NULL) return;
-		} else {
-			pp = &(*pp)->next;
 		}
-	}
 }
 
 static struct capincci *capincci_find(struct capidev *cdev, u32 ncci)
 {
-	struct capincci *p;
+	struct capincci *np;
 
-	for (p=cdev->nccis; p ; p = p->next) {
-		if (p->ncci == ncci)
-			break;
-	}
-	return p;
+	list_for_each_entry(np, &cdev->nccis, list)
+		if (np->ncci == ncci)
+			return np;
+	return NULL;
 }
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
@@ -955,6 +947,7 @@ static int capi_open(struct inode *inode, struct file *file)
 	mutex_init(&cdev->lock);
 	skb_queue_head_init(&cdev->recvqueue);
 	init_waitqueue_head(&cdev->recvwait);
+	INIT_LIST_HEAD(&cdev->nccis);
 	file->private_data = cdev;
 
 	mutex_lock(&capidev_list_lock);
@@ -1427,19 +1420,14 @@ static const struct file_operations capi20_proc_fops = {
  */
 static int capi20ncci_proc_show(struct seq_file *m, void *v)
 {
-        struct capidev *cdev;
-        struct capincci *np;
-	struct list_head *l;
+	struct capidev *cdev;
+	struct capincci *np;
 
 	mutex_lock(&capidev_list_lock);
-	list_for_each(l, &capidev_list) {
-		cdev = list_entry(l, struct capidev, list);
+	list_for_each_entry(cdev, &capidev_list, list) {
 		mutex_lock(&cdev->lock);
-		for (np=cdev->nccis; np; np = np->next) {
-			seq_printf(m, "%d 0x%x\n",
-				       cdev->ap.applid,
-				       np->ncci);
-		}
+		list_for_each_entry(np, &cdev->nccis, list)
+			seq_printf(m, "%d 0x%x\n", cdev->ap.applid, np->ncci);
 		mutex_unlock(&cdev->lock);
 	}
 	mutex_unlock(&capidev_list_lock);
-- 
1.6.0.2

