From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 14/31] CAPI: Clean up capi_open/release
Date: Thu, 7 Jan 2010 19:24:41 +0100
Message-ID: <903e38a0f1178ce30a5ba1e4e571278f8e7f2bf3.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755868Ab0AVXWd@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fold capidev_alloc and capidev_free into capi_open and capi_release -
there are no other users. Someone pushed a lock_kernel into capi_open.
Drop it, we don't need it. Also remove the useless test from open that
checks for private_data == NULL.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   93 +++++++++++++++++-----------------------------
 1 files changed, 34 insertions(+), 59 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 2af6c05..2af81c8 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -400,46 +400,6 @@ static struct capincci *capincci_find(struct capidev *cdev, u32 ncci)
 	return p;
 }
 
-/* -------- struct capidev ------------------------------------------ */
-
-static struct capidev *capidev_alloc(void)
-{
-	struct capidev *cdev;
-
-	cdev = kzalloc(sizeof(*cdev), GFP_KERNEL);
-	if (!cdev)
-		return NULL;
-
-	mutex_init(&cdev->ncci_list_mtx);
-	skb_queue_head_init(&cdev->recvqueue);
-	init_waitqueue_head(&cdev->recvwait);
-
-	mutex_lock(&capidev_list_lock);
-	list_add_tail(&cdev->list, &capidev_list);
-	mutex_unlock(&capidev_list_lock);
-
-        return cdev;
-}
-
-static void capidev_free(struct capidev *cdev)
-{
-	mutex_lock(&capidev_list_lock);
-	list_del(&cdev->list);
-	mutex_unlock(&capidev_list_lock);
-
-	if (cdev->ap.applid) {
-		capi20_release(&cdev->ap);
-		cdev->ap.applid = 0;
-	}
-	skb_queue_purge(&cdev->recvqueue);
-
-	mutex_lock(&cdev->ncci_list_mtx);
-	capincci_free(cdev, 0xffffffff);
-	mutex_unlock(&cdev->ncci_list_mtx);
-
-	kfree(cdev);
-}
-
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 /* -------- handle data queue --------------------------------------- */
 
@@ -990,30 +950,45 @@ capi_ioctl(struct inode *inode, struct file *file,
 	return -EINVAL;
 }
 
-static int
-capi_open(struct inode *inode, struct file *file)
+static int capi_open(struct inode *inode, struct file *file)
 {
-	int ret;
-	
-	lock_kernel();
-	if (file->private_data)
-		ret = -EEXIST;
-	else if ((file->private_data = capidev_alloc()) == NULL)
-		ret = -ENOMEM;
-	else
-		ret = nonseekable_open(inode, file);
-	unlock_kernel();
-	return ret;
+	struct capidev *cdev;
+
+	cdev = kzalloc(sizeof(*cdev), GFP_KERNEL);
+	if (!cdev)
+		return -ENOMEM;
+
+	mutex_init(&cdev->ncci_list_mtx);
+	skb_queue_head_init(&cdev->recvqueue);
+	init_waitqueue_head(&cdev->recvwait);
+	file->private_data = cdev;
+
+	mutex_lock(&capidev_list_lock);
+	list_add_tail(&cdev->list, &capidev_list);
+	mutex_unlock(&capidev_list_lock);
+
+	return nonseekable_open(inode, file);
 }
 
-static int
-capi_release(struct inode *inode, struct file *file)
+static int capi_release(struct inode *inode, struct file *file)
 {
-	struct capidev *cdev = (struct capidev *)file->private_data;
+	struct capidev *cdev = file->private_data;
 
-	capidev_free(cdev);
-	file->private_data = NULL;
-	
+	mutex_lock(&capidev_list_lock);
+	list_del(&cdev->list);
+	mutex_unlock(&capidev_list_lock);
+
+	if (cdev->ap.applid) {
+		capi20_release(&cdev->ap);
+		cdev->ap.applid = 0;
+	}
+	skb_queue_purge(&cdev->recvqueue);
+
+	mutex_lock(&cdev->ncci_list_mtx);
+	capincci_free(cdev, 0xffffffff);
+	mutex_unlock(&cdev->ncci_list_mtx);
+
+	kfree(cdev);
 	return 0;
 }
 
-- 
1.6.0.2
