From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 15/31] CAPI: Rework locking of capidev members
Date: Thu, 7 Jan 2010 20:12:28 +0100
Message-ID: <ec05b0d8c1cc68fd1132ac8e4d08421b3491cb8a.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756093Ab0AVXYW@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename 'ncci_list_mtx' to 'lock', expressing that it now protects a
larger set of capidev members: the NCCI list, ap.applid (ie. the
registration of the application), and modifications of userflags.

We do not need to protect each and every check for ap.applid because,
once an application is registered, it will stay for the whole lifetime
of the device.

Also, there is no need to apply the capidev mutex during release (if
there could be concurrent users, we would crash them anyway by freeing
the device at the end of capi_release).

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |  187 ++++++++++++++++++++++-----------------------
 1 files changed, 91 insertions(+), 96 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 2af81c8..e7830b7 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -140,7 +140,7 @@ struct capidev {
 
 	struct capincci *nccis;
 
-	struct mutex ncci_list_mtx;
+	struct mutex lock;
 };
 
 /* -------- global variables ---------------------------------------- */
@@ -573,38 +573,31 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	u16 datahandle;
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 	struct capincci *np;
-	u32 ncci;
 	unsigned long flags;
 
+	mutex_lock(&cdev->lock);
+
 	if (CAPIMSG_CMD(skb->data) == CAPI_CONNECT_B3_CONF) {
 		u16 info = CAPIMSG_U16(skb->data, 12); // Info field
-		if ((info & 0xff00) == 0) {
-			mutex_lock(&cdev->ncci_list_mtx);
+		if ((info & 0xff00) == 0)
 			capincci_alloc(cdev, CAPIMSG_NCCI(skb->data));
-			mutex_unlock(&cdev->ncci_list_mtx);
-		}
 	}
-	if (CAPIMSG_CMD(skb->data) == CAPI_CONNECT_B3_IND) {
-		mutex_lock(&cdev->ncci_list_mtx);
+	if (CAPIMSG_CMD(skb->data) == CAPI_CONNECT_B3_IND)
 		capincci_alloc(cdev, CAPIMSG_NCCI(skb->data));
-		mutex_unlock(&cdev->ncci_list_mtx);
-	}
+
 	spin_lock_irqsave(&workaround_lock, flags);
 	if (CAPIMSG_COMMAND(skb->data) != CAPI_DATA_B3) {
 		skb_queue_tail(&cdev->recvqueue, skb);
 		wake_up_interruptible(&cdev->recvwait);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-		return;
+		goto unlock_out;
 	}
-	ncci = CAPIMSG_CONTROL(skb->data);
-	for (np = cdev->nccis; np && np->ncci != ncci; np = np->next)
-		;
+
+	np = capincci_find(cdev, CAPIMSG_CONTROL(skb->data));
 	if (!np) {
 		printk(KERN_ERR "BUG: capi_signal: ncci not foundn");
 		skb_queue_tail(&cdev->recvqueue, skb);
 		wake_up_interruptible(&cdev->recvwait);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-		return;
+		goto unlock_out;
 	}
 
 #ifndef CONFIG_ISDN_CAPI_MIDDLEWARE
@@ -617,8 +610,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	if (!mp) {
 		skb_queue_tail(&cdev->recvqueue, skb);
 		wake_up_interruptible(&cdev->recvwait);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-		return;
+		goto unlock_out;
 	}
 	if (CAPIMSG_SUBCOMMAND(skb->data) == CAPI_IND) {
 		datahandle = CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+4+2);
@@ -651,7 +643,9 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	}
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
+unlock_out:
 	spin_unlock_irqrestore(&workaround_lock, flags);
+	mutex_unlock(&cdev->lock);
 }
 
 /* -------- file_operations for capidev ----------------------------- */
@@ -729,9 +723,9 @@ capi_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos
 	CAPIMSG_SETAPPID(skb->data, cdev->ap.applid);
 
 	if (CAPIMSG_CMD(skb->data) == CAPI_DISCONNECT_B3_RESP) {
-		mutex_lock(&cdev->ncci_list_mtx);
+		mutex_lock(&cdev->lock);
 		capincci_free(cdev, CAPIMSG_NCCI(skb->data));
-		mutex_unlock(&cdev->ncci_list_mtx);
+		mutex_unlock(&cdev->lock);
 	}
 
 	cdev->errcode = capi20_put_message(&cdev->ap, skb);
@@ -764,30 +758,35 @@ capi_ioctl(struct inode *inode, struct file *file,
 	   unsigned int cmd, unsigned long arg)
 {
 	struct capidev *cdev = file->private_data;
-	struct capi20_appl *ap = &cdev->ap;
 	capi_ioctl_struct data;
 	int retval = -EINVAL;
 	void __user *argp = (void __user *)arg;
 
 	switch (cmd) {
 	case CAPI_REGISTER:
-		{
-			if (ap->applid)
-				return -EEXIST;
+		mutex_lock(&cdev->lock);
 
-			if (copy_from_user(&cdev->ap.rparam, argp,
-					   sizeof(struct capi_register_params)))
-				return -EFAULT;
-			
-			cdev->ap.private = cdev;
-			cdev->ap.recv_message = capi_recv_message;
-			cdev->errcode = capi20_register(ap);
-			if (cdev->errcode) {
-				ap->applid = 0;
-				return -EIO;
-			}
+		if (cdev->ap.applid) {
+			retval = -EEXIST;
+			goto register_out;
 		}
-		return (int)ap->applid;
+		if (copy_from_user(&cdev->ap.rparam, argp,
+				   sizeof(struct capi_register_params))) {
+			retval = -EFAULT;
+			goto register_out;
+		}
+		cdev->ap.private = cdev;
+		cdev->ap.recv_message = capi_recv_message;
+		cdev->errcode = capi20_register(&cdev->ap);
+		retval = (int)cdev->ap.applid;
+		if (cdev->errcode) {
+			cdev->ap.applid = 0;
+			retval = -EIO;
+		}
+
+register_out:
+		mutex_unlock(&cdev->lock);
+		return retval;
 
 	case CAPI_GET_VERSION:
 		{
@@ -886,68 +885,67 @@ capi_ioctl(struct inode *inode, struct file *file,
 		return 0;
 
 	case CAPI_SET_FLAGS:
-	case CAPI_CLR_FLAGS:
-		{
-			unsigned userflags;
-			if (copy_from_user(&userflags, argp,
-					   sizeof(userflags)))
-				return -EFAULT;
-			if (cmd == CAPI_SET_FLAGS)
-				cdev->userflags |= userflags;
-			else
-				cdev->userflags &= ~userflags;
-		}
-		return 0;
+	case CAPI_CLR_FLAGS: {
+		unsigned userflags;
+
+		if (copy_from_user(&userflags, argp, sizeof(userflags)))
+			return -EFAULT;
 
+		mutex_lock(&cdev->lock);
+		if (cmd == CAPI_SET_FLAGS)
+			cdev->userflags |= userflags;
+		else
+			cdev->userflags &= ~userflags;
+		mutex_unlock(&cdev->lock);
+		return 0;
+	}
 	case CAPI_GET_FLAGS:
 		if (copy_to_user(argp, &cdev->userflags,
 				 sizeof(cdev->userflags)))
 			return -EFAULT;
 		return 0;
 
-	case CAPI_NCCI_OPENCOUNT:
-		{
-			struct capincci *nccip;
-			unsigned ncci;
-			int count = 0;
-			if (copy_from_user(&ncci, argp, sizeof(ncci)))
-				return -EFAULT;
+	case CAPI_NCCI_OPENCOUNT: {
+		struct capincci *nccip;
+		unsigned ncci;
+		int count = 0;
 
-			mutex_lock(&cdev->ncci_list_mtx);
-			if ((nccip = capincci_find(cdev, (u32) ncci)) == NULL) {
-				mutex_unlock(&cdev->ncci_list_mtx);
-				return 0;
-			}
-			count += capincci_minor_opencount(nccip);
-			mutex_unlock(&cdev->ncci_list_mtx);
-			return count;
-		}
-		return 0;
+		if (copy_from_user(&ncci, argp, sizeof(ncci)))
+			return -EFAULT;
+
+		mutex_lock(&cdev->lock);
+		nccip = capincci_find(cdev, (u32)ncci);
+		if (nccip)
+			count = capincci_minor_opencount(nccip);
+		mutex_unlock(&cdev->lock);
+		return count;
+	}
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-	case CAPI_NCCI_GETUNIT:
-		{
-			struct capincci *nccip;
-			struct capiminor *mp;
-			unsigned ncci;
-			int unit = 0;
-			if (copy_from_user(&ncci, argp,
-					   sizeof(ncci)))
-				return -EFAULT;
-			mutex_lock(&cdev->ncci_list_mtx);
-			nccip = capincci_find(cdev, (u32) ncci);
-			if (!nccip || (mp = nccip->minorp) == NULL) {
-				mutex_unlock(&cdev->ncci_list_mtx);
-				return -ESRCH;
-			}
-			unit = mp->minor;
-			mutex_unlock(&cdev->ncci_list_mtx);
-			return unit;
+	case CAPI_NCCI_GETUNIT: {
+		struct capincci *nccip;
+		struct capiminor *mp;
+		unsigned ncci;
+		int unit = -ESRCH;
+
+		if (copy_from_user(&ncci, argp, sizeof(ncci)))
+			return -EFAULT;
+
+		mutex_lock(&cdev->lock);
+		nccip = capincci_find(cdev, (u32)ncci);
+		if (nccip) {
+			mp = nccip->minorp;
+			if (mp)
+				unit = mp->minor;
 		}
-		return 0;
+		mutex_unlock(&cdev->lock);
+		return unit;
+	}
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+
+	default:
+		return -EINVAL;
 	}
-	return -EINVAL;
 }
 
 static int capi_open(struct inode *inode, struct file *file)
@@ -958,7 +956,7 @@ static int capi_open(struct inode *inode, struct file *file)
 	if (!cdev)
 		return -ENOMEM;
 
-	mutex_init(&cdev->ncci_list_mtx);
+	mutex_init(&cdev->lock);
 	skb_queue_head_init(&cdev->recvqueue);
 	init_waitqueue_head(&cdev->recvwait);
 	file->private_data = cdev;
@@ -978,15 +976,10 @@ static int capi_release(struct inode *inode, struct file *file)
 	list_del(&cdev->list);
 	mutex_unlock(&capidev_list_lock);
 
-	if (cdev->ap.applid) {
+	if (cdev->ap.applid)
 		capi20_release(&cdev->ap);
-		cdev->ap.applid = 0;
-	}
 	skb_queue_purge(&cdev->recvqueue);
-
-	mutex_lock(&cdev->ncci_list_mtx);
 	capincci_free(cdev, 0xffffffff);
-	mutex_unlock(&cdev->ncci_list_mtx);
 
 	kfree(cdev);
 	return 0;
@@ -1449,6 +1442,7 @@ static int proc_capincci_read_proc(char *page, char **start, off_t off,
 	mutex_lock(&capidev_list_lock);
 	list_for_each(l, &capidev_list) {
 		cdev = list_entry(l, struct capidev, list);
+		mutex_lock(&cdev->lock);
 		for (np=cdev->nccis; np; np = np->next) {
 			len += sprintf(page+len, "%d 0x%xn",
 				       cdev->ap.applid,
@@ -1456,11 +1450,12 @@ static int proc_capincci_read_proc(char *page, char **start, off_t off,
 			if (len <= off) {
 				off -= len;
 				len = 0;
-			} else {
-				if (len-off > count)
-					goto endloop;
+			} else if (len-off > count) {
+				mutex_unlock(&cdev->lock);
+				goto endloop;
 			}
 		}
+		mutex_unlock(&cdev->lock);
 	}
 endloop:
 	mutex_unlock(&capidev_list_lock);
-- 
1.6.0.2
