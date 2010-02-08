From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 14/41] CAPI: Clean up capi_open/release
Date: Mon,  8 Feb 2010 21:12:18 +0100
Message-ID: <4d410220c1c4e9da2c7fcfe113a3dadbf586ffbe.1265659934.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:53677 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab0BHUNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:05 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fold capidev_alloc and capidev_free into capi_open and capi_release -
there are no other users. Someone pushed a lock_kernel into capi_open.
Drop it, we don't need it. Also remove the useless test from open that
checks for private_data == NULL.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   93 +++++++++++++++++-----------------------------
 1 files changed, 34 insertions(+), 59 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 623412e..9d7c369 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -401,46 +401,6 @@ static struct capincci *capincci_find(struct capidev *cdev, u32 ncci)
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
 
@@ -991,30 +951,45 @@ capi_ioctl(struct inode *inode, struct file *file,
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

