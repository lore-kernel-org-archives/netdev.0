From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 19/31] CAPI: Fix locking around glueing capiminor and capidev
Date: Fri, 8 Jan 2010 10:45:04 +0100
Message-ID: <c0d3d79e2e332a019926360f80cb4c893826cf71.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756175Ab0AVX0G@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CAPI user interface comes with two types of devices: /dev/capi20 is
a character device, instances are represented by capidev objects. Each
established network control connection triggers the creation of a TTY
device (/dev/capi/<ncci>), open instances are managed via capiminor
objects. capincci objects are representing the connections, and they
link the corresponding capiminor to its capidev. Unfortunately, the
lifetimes of an NCCI is not identical to that of a capiminor instance.
So we need proper locking to glue things and also unbind them again.

This patch fixes the totally broken attempts to achieve this via a
rwlock and some atomic counter. It converts the rwlock into a mutex and
applies it to all related critical sections (capinc_tty_open/close as
well as capiminor_alloc/release).

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   82 +++++++++++++++++++++++----------------------
 1 files changed, 42 insertions(+), 40 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 249ff13..b53cead 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -150,7 +150,7 @@ static LIST_HEAD(capidev_list);
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 
-static DEFINE_RWLOCK(capiminor_list_lock);
+static DEFINE_MUTEX(glue_lock);
 static LIST_HEAD(capiminor_list);
 
 /* -------- datahandles --------------------------------------------- */
@@ -214,7 +214,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 {
 	struct capiminor *mp, *p;
 	unsigned int minor = 0;
-	unsigned long flags;
 
 	mp = kzalloc(sizeof(*mp), GFP_KERNEL);
   	if (!mp) {
@@ -234,7 +233,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 
 	/* Allocate the least unused minor number.
 	 */
-	write_lock_irqsave(&capiminor_list_lock, flags);
 	if (list_empty(&capiminor_list))
 		list_add(&mp->list, &capiminor_list);
 	else {
@@ -249,7 +247,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 			list_add(&mp->list, p->list.prev);
 		}
 	}
-		write_unlock_irqrestore(&capiminor_list_lock, flags);
 
 	if (!(minor < capi_ttyminors)) {
 		printk(KERN_NOTICE "capi: out of minorsn");
@@ -262,36 +259,25 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 
 static void capiminor_free(struct capiminor *mp)
 {
-	unsigned long flags;
-
-	write_lock_irqsave(&capiminor_list_lock, flags);
 	list_del(&mp->list);
-	write_unlock_irqrestore(&capiminor_list_lock, flags);
 
 	kfree_skb(mp->ttyskb);
-	mp->ttyskb = NULL;
 	skb_queue_purge(&mp->inqueue);
 	skb_queue_purge(&mp->outqueue);
+
 	capiminor_del_all_ack(mp);
+
 	kfree(mp);
 }
 
 static struct capiminor *capiminor_find(unsigned int minor)
 {
-	struct list_head *l;
-	struct capiminor *p = NULL;
-
-	read_lock(&capiminor_list_lock);
-	list_for_each(l, &capiminor_list) {
-		p = list_entry(l, struct capiminor, list);
-		if (p->minor == minor)
-			break;
-	}
-	read_unlock(&capiminor_list_lock);
-	if (l == &capiminor_list)
-		return NULL;
+	struct capiminor *mp;
 
-	return p;
+	list_for_each_entry(mp, &capiminor_list, list)
+		if (mp->minor == minor)
+			return mp;
+	return NULL;
 }
 
 /* -------- struct capincci ----------------------------------------- */
@@ -303,6 +289,8 @@ static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 	if (!(cdev->userflags & CAPIFLAG_HIGHJACKING))
 		return;
 
+	mutex_lock(&glue_lock);
+
 	mp = np->minorp = capiminor_alloc(&cdev->ap, np->ncci);
 	if (mp) {
 		mp->nccip = np;
@@ -313,12 +301,17 @@ static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 			capifs_new_ncci(mp->minor,
 					MKDEV(capi_ttymajor, mp->minor));
 	}
+
+	mutex_unlock(&glue_lock);
 }
 
 static void capincci_free_minor(struct capincci *np)
 {
-	struct capiminor *mp = np->minorp;
+	struct capiminor *mp;
 
+	mutex_lock(&glue_lock);
+
+	mp = np->minorp;
 	if (mp) {
 		capifs_free_ncci(mp->capifs_dentry);
 		if (mp->tty) {
@@ -331,6 +324,8 @@ static void capincci_free_minor(struct capincci *np)
 			capiminor_free(mp);
 		}
 	}
+
+	mutex_unlock(&glue_lock);
 }
 
 static inline unsigned int capincci_minor_opencount(struct capincci *np)
@@ -992,13 +987,17 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 {
 	struct capiminor *mp;
 	unsigned long flags;
+	int err = 0;
 
-	if ((mp = capiminor_find(iminor(file->f_path.dentry->d_inode))) == NULL)
-		return -ENXIO;
-	if (mp->nccip == NULL)
-		return -ENXIO;
+	mutex_lock(&glue_lock);
 
-	tty->driver_data = (void *)mp;
+	mp = capiminor_find(iminor(file->f_path.dentry->d_inode));
+	if (!mp || !mp->nccip) {
+		err = -ENXIO;
+		goto unlock_out;
+	}
+
+	tty->driver_data = mp;
 
 	spin_lock_irqsave(&workaround_lock, flags);
 	if (atomic_read(&mp->ttyopencount) == 0)
@@ -1009,28 +1008,31 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 #endif
 	handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
-	return 0;
+
+unlock_out:
+	mutex_unlock(&glue_lock);
+	return err;
 }
 
 static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 {
-	struct capiminor *mp;
+	struct capiminor *mp = tty->driver_data;
 
-	mp = (struct capiminor *)tty->driver_data;
-	if (mp)	{
-		if (atomic_dec_and_test(&mp->ttyopencount)) {
+	mutex_lock(&glue_lock);
+
+	if (atomic_dec_and_test(&mp->ttyopencount)) {
 #ifdef _DEBUG_REFCOUNT
-			printk(KERN_DEBUG "capinc_tty_close lastclosen");
+		printk(KERN_DEBUG "capinc_tty_close lastclosen");
 #endif
-			tty->driver_data = NULL;
-			mp->tty = NULL;
-		}
+		mp->tty = NULL;
+	}
 #ifdef _DEBUG_REFCOUNT
 		printk(KERN_DEBUG "capinc_tty_close ocount=%dn", atomic_read(&mp->ttyopencount));
 #endif
-		if (mp->nccip == NULL)
-			capiminor_free(mp);
-	}
+	if (!mp->nccip)
+		capiminor_free(mp);
+
+	mutex_unlock(&glue_lock);
 
 #ifdef _DEBUG_REFCOUNT
 	printk(KERN_DEBUG "capinc_tty_closen");
-- 
1.6.0.2
