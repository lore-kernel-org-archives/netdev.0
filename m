From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 18/31] CAPI: Switch NCCI list to standard doubly linked list
Date: Thu, 7 Jan 2010 21:52:22 +0100
Message-ID: <3f7722dc7070826b749e757676846f2dccfe4f14.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:39700 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965Ab0AVXYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:24:04 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace open-coded NCCI list management with standard mechanisms.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   47 ++++++++++++++++++---------------------------
 1 files changed, 19 insertions(+), 28 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 90a20fa..249ff13 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -121,7 +121,7 @@ struct capiminor {
 static DEFINE_SPINLOCK(workaround_lock);
 
 struct capincci {
-	struct capincci *next;
+	struct list_head list;
 	u32		 ncci;
 	struct capidev	*cdev;
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
@@ -138,7 +138,7 @@ struct capidev {
 	struct sk_buff_head recvqueue;
 	wait_queue_head_t recvwait;
 
-	struct capincci *nccis;
+	struct list_head nccis;
 
 	struct mutex lock;
 };
@@ -355,7 +355,7 @@ static inline unsigned int capincci_minor_opencount(struct capincci *np)
 
 static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 {
-	struct capincci *np, **pp;
+	struct capincci *np;
 
 	np = kzalloc(sizeof(*np), GFP_KERNEL);
 	if (!np)
@@ -365,39 +365,31 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 
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
@@ -954,6 +946,7 @@ static int capi_open(struct inode *inode, struct file *file)
 	mutex_init(&cdev->lock);
 	skb_queue_head_init(&cdev->recvqueue);
 	init_waitqueue_head(&cdev->recvwait);
+	INIT_LIST_HEAD(&cdev->nccis);
 	file->private_data = cdev;
 
 	mutex_lock(&capidev_list_lock);
@@ -1429,16 +1422,14 @@ endloop:
 static int proc_capincci_read_proc(char *page, char **start, off_t off,
                                        int count, int *eof, void *data)
 {
-        struct capidev *cdev;
-        struct capincci *np;
-	struct list_head *l;
+	struct capidev *cdev;
+	struct capincci *np;
 	int len = 0;
 
 	mutex_lock(&capidev_list_lock);
-	list_for_each(l, &capidev_list) {
-		cdev = list_entry(l, struct capidev, list);
+	list_for_each_entry(cdev, &capidev_list, list) {
 		mutex_lock(&cdev->lock);
-		for (np=cdev->nccis; np; np = np->next) {
+		list_for_each_entry(np, &cdev->nccis, list) {
 			len += sprintf(page+len, "%d 0x%xn",
 				       cdev->ap.applid,
 				       np->ncci);
-- 
1.6.0.2

