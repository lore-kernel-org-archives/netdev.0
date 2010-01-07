From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 12/31] CAPI: Reduce #ifdef mess around CONFIG_ISDN_CAPI_MIDDLEWARE
Date: Thu, 7 Jan 2010 18:42:30 +0100
Message-ID: <9d967c4e5e95cddfa68353360d076a1f73adf883.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756173Ab0AVXYn@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the code a bit more readable be providing stub functions for the
!CONFIG_ISDN_CAPI_MIDDLEWARE case. Though a few lines are moved around,
this comes with no functional changes.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |  150 +++++++++++++++++++++++++--------------------
 1 files changed, 83 insertions(+), 67 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index c456f61..fa18971 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -23,14 +23,10 @@
 #include <linux/smp_lock.h>
 #include <linux/timer.h>
 #include <linux/wait.h>
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 #include <linux/tty.h>
-#ifdef CONFIG_PPP
 #include <linux/netdevice.h>
 #include <linux/ppp_defs.h>
 #include <linux/if_ppp.h>
-#endif /* CONFIG_PPP */
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 #include <linux/skbuff.h>
 #include <linux/proc_fs.h>
 #include <linux/poll.h>
@@ -55,17 +51,17 @@ MODULE_LICENSE("GPL");
 /* -------- driver information -------------------------------------- */
 
 static struct class *capi_class;
-
 static int capi_major = 68;		/* allocated */
+
+module_param_named(major, capi_major, uint, 0);
+
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-#define CAPINC_NR_PORTS	32
+#define CAPINC_NR_PORTS		32
 #define CAPINC_MAX_PORTS	256
+
 static int capi_ttymajor = 191;
 static int capi_ttyminors = CAPINC_NR_PORTS;
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
-module_param_named(major, capi_major, uint, 0);
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 module_param_named(ttymajor, capi_ttymajor, uint, 0);
 module_param_named(ttyminors, capi_ttyminors, uint, 0);
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
@@ -80,7 +76,6 @@ module_param_named(ttyminors, capi_ttyminors, uint, 0);
 
 struct capidev;
 struct capincci;
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 struct capiminor;
 
 struct datahandle_queue {
@@ -115,7 +110,6 @@ struct capiminor {
 	int nack;
 	spinlock_t ackqlock;
 };
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
 /* FIXME: The following lock is a sledgehammer-workaround to a
  * locking issue with the capiminor (and maybe other) data structure(s).
@@ -155,14 +149,13 @@ static DEFINE_RWLOCK(capidev_list_lock);
 static LIST_HEAD(capidev_list);
 
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
+
 static DEFINE_RWLOCK(capiminor_list_lock);
 static LIST_HEAD(capiminor_list);
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 /* -------- datahandles --------------------------------------------- */
 
-static int capincci_add_ack(struct capiminor *mp, u16 datahandle)
+static int capiminor_add_ack(struct capiminor *mp, u16 datahandle)
 {
 	struct datahandle_queue *n;
 	unsigned long flags;
@@ -300,26 +293,17 @@ static struct capiminor *capiminor_find(unsigned int minor)
 
 	return p;
 }
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
 /* -------- struct capincci ----------------------------------------- */
 
-static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
+static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 {
-	struct capincci *np, **pp;
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-	struct capiminor *mp = NULL;
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+	struct capiminor *mp;
 
-	np = kzalloc(sizeof(*np), GFP_ATOMIC);
-	if (!np)
-		return NULL;
-	np->ncci = ncci;
-	np->cdev = cdev;
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-	mp = NULL;
-	if (cdev->userflags & CAPIFLAG_HIGHJACKING)
-		mp = np->minorp = capiminor_alloc(&cdev->ap, ncci);
+	if (!(cdev->userflags & CAPIFLAG_HIGHJACKING))
+		return;
+
+	mp = np->minorp = capiminor_alloc(&cdev->ap, np->ncci);
 	if (mp) {
 		mp->nccip = np;
 #ifdef _DEBUG_REFCOUNT
@@ -329,7 +313,58 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 			capifs_new_ncci(mp->minor,
 					MKDEV(capi_ttymajor, mp->minor));
 	}
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+}
+
+static void capincci_free_minor(struct capincci *np)
+{
+	struct capiminor *mp = np->minorp;
+
+	if (mp) {
+		capifs_free_ncci(mp->capifs_dentry);
+		if (mp->tty) {
+			mp->nccip = NULL;
+#ifdef _DEBUG_REFCOUNT
+			printk(KERN_DEBUG "reset mp->nccipn");
+#endif
+			tty_hangup(mp->tty);
+		} else {
+			capiminor_free(mp);
+		}
+	}
+}
+
+static inline unsigned int capincci_minor_opencount(struct capincci *np)
+{
+	struct capiminor *mp = np->minorp;
+
+	return mp ? atomic_read(&mp->ttyopencount) : 0;
+}
+
+#else /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
+
+static inline void
+capincci_alloc_minor(struct capidev *cdev, struct capincci *np) { }
+static inline void capincci_free_minor(struct capincci *np) { }
+
+static inline unsigned int capincci_minor_opencount(struct capincci *np)
+{
+	return 0;
+}
+
+#endif /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
+
+static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
+{
+	struct capincci *np, **pp;
+
+	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	if (!np)
+		return NULL;
+	np->ncci = ncci;
+	np->cdev = cdev;
+
+	capincci_alloc_minor(cdev, np);
+
 	for (pp=&cdev->nccis; *pp; pp = &(*pp)->next)
 		;
 	*pp = np;
@@ -339,29 +374,13 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 static void capincci_free(struct capidev *cdev, u32 ncci)
 {
 	struct capincci *np, **pp;
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-	struct capiminor *mp;
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
 	pp=&cdev->nccis;
 	while (*pp) {
 		np = *pp;
 		if (ncci == 0xffffffff || np->ncci == ncci) {
 			*pp = (*pp)->next;
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-			if ((mp = np->minorp) != NULL) {
-				capifs_free_ncci(mp->capifs_dentry);
-				if (mp->tty) {
-					mp->nccip = NULL;
-#ifdef _DEBUG_REFCOUNT
-					printk(KERN_DEBUG "reset mp->nccipn");
-#endif
-					tty_hangup(mp->tty);
-				} else {
-					capiminor_free(mp);
-				}
-			}
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+			capincci_free_minor(np);
 			kfree(np);
 			if (*pp == NULL) return;
 		} else {
@@ -551,7 +570,7 @@ static int handle_minor_send(struct capiminor *mp)
 		capimsg_setu16(skb->data, 18, datahandle);
 		capimsg_setu16(skb->data, 20, 0);	/* Flags */
 
-		if (capincci_add_ack(mp, datahandle) < 0) {
+		if (capiminor_add_ack(mp, datahandle) < 0) {
 			skb_pull(skb, CAPI_DATA_B3_REQ_LEN);
 			skb_queue_head(&mp->outqueue, skb);
 			return count;
@@ -627,10 +646,13 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 		spin_unlock_irqrestore(&workaround_lock, flags);
 		return;
 	}
+
 #ifndef CONFIG_ISDN_CAPI_MIDDLEWARE
 	skb_queue_tail(&cdev->recvqueue, skb);
 	wake_up_interruptible(&cdev->recvwait);
+
 #else /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+
 	mp = np->minorp;
 	if (!mp) {
 		skb_queue_tail(&cdev->recvqueue, skb);
@@ -638,10 +660,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 		spin_unlock_irqrestore(&workaround_lock, flags);
 		return;
 	}
-
-
 	if (CAPIMSG_SUBCOMMAND(skb->data) == CAPI_IND) {
-		
 		datahandle = CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+4+2);
 #ifdef _DEBUG_DATAFLOW
 		printk(KERN_DEBUG "capi_signal: DATA_B3_IND %u len=%dn",
@@ -671,6 +690,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 		wake_up_interruptible(&cdev->recvwait);
 	}
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+
 	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
@@ -928,9 +948,6 @@ capi_ioctl(struct inode *inode, struct file *file,
 	case CAPI_NCCI_OPENCOUNT:
 		{
 			struct capincci *nccip;
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-			struct capiminor *mp;
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 			unsigned ncci;
 			int count = 0;
 			if (copy_from_user(&ncci, argp, sizeof(ncci)))
@@ -941,11 +958,7 @@ capi_ioctl(struct inode *inode, struct file *file,
 				mutex_unlock(&cdev->ncci_list_mtx);
 				return 0;
 			}
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
-			if ((mp = nccip->minorp) != NULL) {
-				count += atomic_read(&mp->ttyopencount);
-			}
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+			count += capincci_minor_opencount(nccip);
 			mutex_unlock(&cdev->ncci_list_mtx);
 			return count;
 		}
@@ -1395,7 +1408,16 @@ static void capinc_tty_exit(void)
 	put_tty_driver(drv);
 }
 
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
+#else /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
+
+static inline int capinc_tty_init(void)
+{
+	return 0;
+}
+
+static inline void capinc_tty_exit(void) { }
+
+#endif /* !CONFIG_ISDN_CAPI_MIDDLEWARE */
 
 /* -------- /proc functions ----------------------------------------- */
 
@@ -1534,23 +1556,19 @@ static int __init capi_init(void)
 
 	device_create(capi_class, NULL, MKDEV(capi_major, 0), NULL, "capi");
 
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 	if (capinc_tty_init() < 0) {
 		device_destroy(capi_class, MKDEV(capi_major, 0));
 		class_destroy(capi_class);
 		unregister_chrdev(capi_major, "capi20");
 		return -ENOMEM;
 	}
-#endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
 	proc_init();
 
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 #if defined(CONFIG_ISDN_CAPI_CAPIFS) || defined(CONFIG_ISDN_CAPI_CAPIFS_MODULE)
         compileinfo = " (middleware+capifs)";
-#else
+#elif defined(CONFIG_ISDN_CAPI_MIDDLEWARE)
         compileinfo = " (no capifs)";
-#endif
 #else
         compileinfo = " (no middleware)";
 #endif
@@ -1568,9 +1586,7 @@ static void __exit capi_exit(void)
 	class_destroy(capi_class);
 	unregister_chrdev(capi_major, "capi20");
 
-#ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 	capinc_tty_exit();
-#endif
 }
 
 module_init(capi_init);
-- 
1.6.0.2
