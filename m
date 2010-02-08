From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 13/41] CAPI: Convert capidev_list_lock into a mutex
Date: Mon,  8 Feb 2010 21:12:17 +0100
Message-ID: <7f00bf8e4209c405aed5007d6057730608612701.1265659934.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:37064 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806Ab0BHUNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:05 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for anything "harder" here (specifically no need for
irqsave...). Also, make the list removal the first operation of
capidev_free to avoid dumping half-released devices via /proc.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 7d2ca6b..623412e 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -146,7 +146,7 @@ struct capidev {
 
 /* -------- global variables ---------------------------------------- */
 
-static DEFINE_RWLOCK(capidev_list_lock);
+static DEFINE_MUTEX(capidev_list_lock);
 static LIST_HEAD(capidev_list);
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
@@ -406,7 +406,6 @@ static struct capincci *capincci_find(struct capidev *cdev, u32 ncci)
 static struct capidev *capidev_alloc(void)
 {
 	struct capidev *cdev;
-	unsigned long flags;
 
 	cdev = kzalloc(sizeof(*cdev), GFP_KERNEL);
 	if (!cdev)
@@ -415,15 +414,19 @@ static struct capidev *capidev_alloc(void)
 	mutex_init(&cdev->ncci_list_mtx);
 	skb_queue_head_init(&cdev->recvqueue);
 	init_waitqueue_head(&cdev->recvwait);
-	write_lock_irqsave(&capidev_list_lock, flags);
+
+	mutex_lock(&capidev_list_lock);
 	list_add_tail(&cdev->list, &capidev_list);
-	write_unlock_irqrestore(&capidev_list_lock, flags);
+	mutex_unlock(&capidev_list_lock);
+
         return cdev;
 }
 
 static void capidev_free(struct capidev *cdev)
 {
-	unsigned long flags;
+	mutex_lock(&capidev_list_lock);
+	list_del(&cdev->list);
+	mutex_unlock(&capidev_list_lock);
 
 	if (cdev->ap.applid) {
 		capi20_release(&cdev->ap);
@@ -435,9 +438,6 @@ static void capidev_free(struct capidev *cdev)
 	capincci_free(cdev, 0xffffffff);
 	mutex_unlock(&cdev->ncci_list_mtx);
 
-	write_lock_irqsave(&capidev_list_lock, flags);
-	list_del(&cdev->list);
-	write_unlock_irqrestore(&capidev_list_lock, flags);
 	kfree(cdev);
 }
 
@@ -1431,7 +1431,7 @@ static int capi20_proc_show(struct seq_file *m, void *v)
         struct capidev *cdev;
 	struct list_head *l;
 
-	read_lock(&capidev_list_lock);
+	mutex_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
 		seq_printf(m, "0 %d %lu %lu %lu %lu\n",
@@ -1441,7 +1441,7 @@ static int capi20_proc_show(struct seq_file *m, void *v)
 			cdev->ap.nsentctlpkt,
 			cdev->ap.nsentdatapkt);
 	}
-	read_unlock(&capidev_list_lock);
+	mutex_unlock(&capidev_list_lock);
 	return 0;
 }
 
@@ -1468,7 +1468,7 @@ static int capi20ncci_proc_show(struct seq_file *m, void *v)
         struct capincci *np;
 	struct list_head *l;
 
-	read_lock(&capidev_list_lock);
+	mutex_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
 		for (np=cdev->nccis; np; np = np->next) {
@@ -1477,7 +1477,7 @@ static int capi20ncci_proc_show(struct seq_file *m, void *v)
 				       np->ncci);
 		}
 	}
-	read_unlock(&capidev_list_lock);
+	mutex_unlock(&capidev_list_lock);
 	return 0;
 }
 
-- 
1.6.0.2

