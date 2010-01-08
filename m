From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 26/31] CAPI: Fix locking around capiminor's output queue
Date: Fri, 8 Jan 2010 13:43:21 +0100
Message-ID: <2e632da3aa0e6b6cc6a5bcf84709c885b1c607b0.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:50173 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170Ab0AVX1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:27:11 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce outlock as a spin lock that protects capiminor's outqueue,
outbytes and outskb (formerly known as ttyskb). outlock can be acquired
from soft-IRQ context via capinc_write, so make it bh-safe.

This finally removes the last reason for keeping the workaround lock
around (which was incomplete and partly broken anyway).

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |  119 +++++++++++++++++++++++++---------------------
 1 files changed, 65 insertions(+), 54 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 40468ac..32a6f04 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -97,11 +97,13 @@ struct capiminor {
 	struct mutex		ttylock;
 	int			ttyinstop;
 	int			ttyoutstop;
-	struct sk_buff    *ttyskb;
 
-	struct sk_buff_head inqueue;
-	struct sk_buff_head outqueue;
-	int                 outbytes;
+	struct sk_buff_head	inqueue;
+
+	struct sk_buff_head	outqueue;
+	int			outbytes;
+	struct sk_buff		*outskb;
+	spinlock_t		outlock;
 
 	/* transmit path */
 	struct list_head ackqueue;
@@ -109,15 +111,6 @@ struct capiminor {
 	spinlock_t ackqlock;
 };
 
-/* FIXME: The following lock is a sledgehammer-workaround to a
- * locking issue with the capiminor (and maybe other) data structure(s).
- * Access to this data is done in a racy way and crashes the machine with
- * a FritzCard DSL driver; sooner or later. This is a workaround
- * which trades scalability vs stability, so it doesn't crash the kernel anymore.
- * The correct (and scalable) fix for the issue seems to require
- * an API change to the drivers... . */
-static DEFINE_SPINLOCK(workaround_lock);
-
 struct capincci {
 	struct list_head list;
 	u32		 ncci;
@@ -226,6 +219,7 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 
 	skb_queue_head_init(&mp->inqueue);
 	skb_queue_head_init(&mp->outqueue);
+	spin_lock_init(&mp->outlock);
 
 	mutex_init(&mp->ttylock);
 
@@ -259,7 +253,7 @@ static void capiminor_free(struct capiminor *mp)
 {
 	list_del(&mp->list);
 
-	kfree_skb(mp->ttyskb);
+	kfree_skb(mp->outskb);
 	skb_queue_purge(&mp->inqueue);
 	skb_queue_purge(&mp->outqueue);
 
@@ -503,9 +497,18 @@ static int handle_minor_send(struct capiminor *mp)
 		return 0;
 	}
 
-	while ((skb = skb_dequeue(&mp->outqueue)) != NULL) {
-		datahandle = atomic_inc_return(&mp->datahandle);
+	while (1) {
+		spin_lock_bh(&mp->outlock);
+		skb = __skb_dequeue(&mp->outqueue);
+		if (!skb) {
+			spin_unlock_bh(&mp->outlock);
+			break;
+		}
 		len = (u16)skb->len;
+		mp->outbytes -= len;
+		spin_unlock_bh(&mp->outlock);
+
+		datahandle = atomic_inc_return(&mp->datahandle);
 		skb_push(skb, CAPI_DATA_B3_REQ_LEN);
 		memset(skb->data, 0, CAPI_DATA_B3_REQ_LEN);
 		capimsg_setu16(skb->data, 0, CAPI_DATA_B3_REQ_LEN);
@@ -521,13 +524,17 @@ static int handle_minor_send(struct capiminor *mp)
 
 		if (capiminor_add_ack(mp, datahandle) < 0) {
 			skb_pull(skb, CAPI_DATA_B3_REQ_LEN);
-			skb_queue_head(&mp->outqueue, skb);
+
+			spin_lock_bh(&mp->outlock);
+			__skb_queue_head(&mp->outqueue, skb);
+			mp->outbytes += len;
+			spin_unlock_bh(&mp->outlock);
+
 			return count;
 		}
 		errcode = capi20_put_message(mp->ap, skb);
 		if (errcode == CAPI_NOERROR) {
 			count++;
-			mp->outbytes -= len;
 #ifdef _DEBUG_DATAFLOW
 			printk(KERN_DEBUG "capi: DATA_B3_REQ %u len=%un",
 							datahandle, len);
@@ -538,13 +545,17 @@ static int handle_minor_send(struct capiminor *mp)
 
 		if (errcode == CAPI_SENDQUEUEFULL) {
 			skb_pull(skb, CAPI_DATA_B3_REQ_LEN);
-			skb_queue_head(&mp->outqueue, skb);
+
+			spin_lock_bh(&mp->outlock);
+			__skb_queue_head(&mp->outqueue, skb);
+			mp->outbytes += len;
+			spin_unlock_bh(&mp->outlock);
+
 			break;
 		}
 
 		/* ups, drop packet */
 		printk(KERN_ERR "capi: put_message = %xn", errcode);
-		mp->outbytes -= len;
 		kfree_skb(skb);
 	}
 	return count;
@@ -561,7 +572,6 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	u16 datahandle;
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 	struct capincci *np;
-	unsigned long flags;
 
 	mutex_lock(&cdev->lock);
 
@@ -573,7 +583,6 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	if (CAPIMSG_CMD(skb->data) == CAPI_CONNECT_B3_IND)
 		capincci_alloc(cdev, CAPIMSG_NCCI(skb->data));
 
-	spin_lock_irqsave(&workaround_lock, flags);
 	if (CAPIMSG_COMMAND(skb->data) != CAPI_DATA_B3) {
 		skb_queue_tail(&cdev->recvqueue, skb);
 		wake_up_interruptible(&cdev->recvwait);
@@ -634,7 +643,6 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 
 unlock_out:
-	spin_unlock_irqrestore(&workaround_lock, flags);
 	mutex_unlock(&cdev->lock);
 }
 
@@ -989,7 +997,6 @@ static const struct file_operations capi_fops =
 static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 {
 	struct capiminor *mp;
-	unsigned long flags;
 	int err = 0;
 
 	mutex_lock(&glue_lock);
@@ -1003,9 +1010,7 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 	tty->driver_data = mp;
 	mp->tty = tty;
 
-	spin_lock_irqsave(&workaround_lock, flags);
 	handle_minor_recv(mp);
-	spin_unlock_irqrestore(&workaround_lock, flags);
 
 unlock_out:
 	mutex_unlock(&glue_lock);
@@ -1035,71 +1040,78 @@ static int capinc_tty_write(struct tty_struct * tty,
 {
 	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
-	unsigned long flags;
 
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_write(count=%d)n", count);
 #endif
 
-	spin_lock_irqsave(&workaround_lock, flags);
-	skb = mp->ttyskb;
+	spin_lock_bh(&mp->outlock);
+	skb = mp->outskb;
 	if (skb) {
-		mp->ttyskb = NULL;
-		skb_queue_tail(&mp->outqueue, skb);
+		mp->outskb = NULL;
+		__skb_queue_tail(&mp->outqueue, skb);
 		mp->outbytes += skb->len;
 	}
 
 	skb = alloc_skb(CAPI_DATA_B3_REQ_LEN+count, GFP_ATOMIC);
 	if (!skb) {
 		printk(KERN_ERR "capinc_tty_write: alloc_skb failedn");
-		spin_unlock_irqrestore(&workaround_lock, flags);
+		spin_unlock_bh(&mp->outlock);
 		return -ENOMEM;
 	}
 
 	skb_reserve(skb, CAPI_DATA_B3_REQ_LEN);
 	memcpy(skb_put(skb, count), buf, count);
 
-	skb_queue_tail(&mp->outqueue, skb);
+	__skb_queue_tail(&mp->outqueue, skb);
 	mp->outbytes += skb->len;
+	spin_unlock_bh(&mp->outlock);
+
 	(void)handle_minor_send(mp);
-	spin_unlock_irqrestore(&workaround_lock, flags);
+
 	return count;
 }
 
 static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 {
 	struct capiminor *mp = tty->driver_data;
+	bool invoke_send = false;
 	struct sk_buff *skb;
-	unsigned long flags;
 	int ret = 1;
 
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_put_char(%u)n", ch);
 #endif
 
-	spin_lock_irqsave(&workaround_lock, flags);
-	skb = mp->ttyskb;
+	spin_lock_bh(&mp->outlock);
+	skb = mp->outskb;
 	if (skb) {
 		if (skb_tailroom(skb) > 0) {
 			*(skb_put(skb, 1)) = ch;
-			spin_unlock_irqrestore(&workaround_lock, flags);
-			return 1;
+			goto unlock_out;
 		}
-		mp->ttyskb = NULL;
-		skb_queue_tail(&mp->outqueue, skb);
+		mp->outskb = NULL;
+		__skb_queue_tail(&mp->outqueue, skb);
 		mp->outbytes += skb->len;
-		(void)handle_minor_send(mp);
+		invoke_send = true;
 	}
+
 	skb = alloc_skb(CAPI_DATA_B3_REQ_LEN+CAPI_MAX_BLKSIZE, GFP_ATOMIC);
 	if (skb) {
 		skb_reserve(skb, CAPI_DATA_B3_REQ_LEN);
 		*(skb_put(skb, 1)) = ch;
-		mp->ttyskb = skb;
+		mp->outskb = skb;
 	} else {
 		printk(KERN_ERR "capinc_put_char: char %u lostn", ch);
 		ret = 0;
 	}
-	spin_unlock_irqrestore(&workaround_lock, flags);
+
+unlock_out:
+	spin_unlock_bh(&mp->outlock);
+
+	if (invoke_send)
+		(void)handle_minor_send(mp);
+
 	return ret;
 }
 
@@ -1107,21 +1119,22 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
-	unsigned long flags;
 
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_flush_charsn");
 #endif
 
-	spin_lock_irqsave(&workaround_lock, flags);
-	skb = mp->ttyskb;
+	spin_lock_bh(&mp->outlock);
+	skb = mp->outskb;
 	if (skb) {
-		mp->ttyskb = NULL;
-		skb_queue_tail(&mp->outqueue, skb);
+		mp->outskb = NULL;
+		__skb_queue_tail(&mp->outqueue, skb);
 		mp->outbytes += skb->len;
+		spin_unlock_bh(&mp->outlock);
+
 		(void)handle_minor_send(mp);
-	}
-	spin_unlock_irqrestore(&workaround_lock, flags);
+	} else
+		spin_unlock_bh(&mp->outlock);
 
 	handle_minor_recv(mp);
 }
@@ -1203,14 +1216,12 @@ static void capinc_tty_stop(struct tty_struct *tty)
 static void capinc_tty_start(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
-	unsigned long flags;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_startn");
 #endif
-	spin_lock_irqsave(&workaround_lock, flags);
 	mp->ttyoutstop = 0;
 	(void)handle_minor_send(mp);
-	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
 static void capinc_tty_hangup(struct tty_struct *tty)
-- 
1.6.0.2

