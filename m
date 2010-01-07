From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 13/31] CAPI: Convert capidev_list_lock into a mutex
Date: Thu, 7 Jan 2010 19:16:09 +0100
Message-ID: <47fe27053f07474cb77dc0a53c8f3417d5ea2a7e.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756051Ab0AVXXd@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need for anything "harder" here (specifically no need for
irqsave...). Also, make the list removal the first operation of
capidev_free to avoid dumping half-released devices via /proc.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index fa18971..2af6c05 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -145,7 +145,7 @@ struct capidev {
 
 /* -------- global variables ---------------------------------------- */
 
-static DEFINE_RWLOCK(capidev_list_lock);
+static DEFINE_MUTEX(capidev_list_lock);
 static LIST_HEAD(capidev_list);
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
@@ -405,7 +405,6 @@ static struct capincci *capincci_find(struct capidev *cdev, u32 ncci)
 static struct capidev *capidev_alloc(void)
 {
 	struct capidev *cdev;
-	unsigned long flags;
 
 	cdev = kzalloc(sizeof(*cdev), GFP_KERNEL);
 	if (!cdev)
@@ -414,15 +413,19 @@ static struct capidev *capidev_alloc(void)
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
@@ -434,9 +437,6 @@ static void capidev_free(struct capidev *cdev)
 	capincci_free(cdev, 0xffffffff);
 	mutex_unlock(&cdev->ncci_list_mtx);
 
-	write_lock_irqsave(&capidev_list_lock, flags);
-	list_del(&cdev->list);
-	write_unlock_irqrestore(&capidev_list_lock, flags);
 	kfree(cdev);
 }
 
@@ -1432,7 +1432,7 @@ static int proc_capidev_read_proc(char *page, char **start, off_t off,
 	struct list_head *l;
 	int len = 0;
 
-	read_lock(&capidev_list_lock);
+	mutex_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
 		len += sprintf(page+len, "0 %d %lu %lu %lu %lun",
@@ -1451,7 +1451,7 @@ static int proc_capidev_read_proc(char *page, char **start, off_t off,
 	}
 
 endloop:
-	read_unlock(&capidev_list_lock);
+	mutex_unlock(&capidev_list_lock);
 	if (len < count)
 		*eof = 1;
 	if (len > count) len = count;
@@ -1471,7 +1471,7 @@ static int proc_capincci_read_proc(char *page, char **start, off_t off,
 	struct list_head *l;
 	int len = 0;
 
-	read_lock(&capidev_list_lock);
+	mutex_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
 		for (np=cdev->nccis; np; np = np->next) {
@@ -1488,7 +1488,7 @@ static int proc_capincci_read_proc(char *page, char **start, off_t off,
 		}
 	}
 endloop:
-	read_unlock(&capidev_list_lock);
+	mutex_unlock(&capidev_list_lock);
 	*start = page+off;
 	if (len < count)
 		*eof = 1;
-- 
1.6.0.2
