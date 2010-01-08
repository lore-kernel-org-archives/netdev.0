From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 22/31] CAPI: Rework tty locking in RX and TX path of capiminor
Date: Fri, 8 Jan 2010 14:38:02 +0100
Message-ID: <6eeb441ec0ddbac9916d0b4cd7195895b8e9c291.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:33270 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194Ab0AVX0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:26:07 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a mutex called ttylock to make handle_recv_skb atomic /wrt
parallel invocations as well as capinc_tty_close clearing the tty_struct
reference. Also avoid re-queuing skbs unless the error detected in
handle_recv_skb is expected to be recoverable such as lacking memory, a
full CAPI queue, or a full TTY input buffer.

As we expect to be in thread context in handle_recv_skb, we must neither
call this function from potenially atomic capinc_tty_write nor while
holding the workaround_lock. For the same reason, we do not need to
allocate skbs atomically in gen_data_b3_resp_for.

The ttylock is also used to avoid waking up a non-existent TTY in
capi_recv_message.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   90 ++++++++++++++++++++++++++++------------------
 1 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 77faa4e..e880639 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -93,9 +93,10 @@ struct capiminor {
 	u16		 datahandle;
 	u16		 msgid;
 
-	struct tty_struct *tty;
-	int                ttyinstop;
-	int                ttyoutstop;
+	struct tty_struct	*tty;
+	struct mutex		ttylock;
+	int			ttyinstop;
+	int			ttyoutstop;
 	struct sk_buff    *ttyskb;
 
 	struct sk_buff_head inqueue;
@@ -228,6 +229,8 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	skb_queue_head_init(&mp->inqueue);
 	skb_queue_head_init(&mp->outqueue);
 
+	mutex_init(&mp->ttylock);
+
 	/* Allocate the least unused minor number.
 	 */
 	if (list_empty(&capiminor_list))
@@ -385,7 +388,7 @@ static struct sk_buff *
 gen_data_b3_resp_for(struct capiminor *mp, struct sk_buff *skb)
 {
 	struct sk_buff *nskb;
-	nskb = alloc_skb(CAPI_DATA_B3_RESP_LEN, GFP_ATOMIC);
+	nskb = alloc_skb(CAPI_DATA_B3_RESP_LEN, GFP_KERNEL);
 	if (nskb) {
 		u16 datahandle = CAPIMSG_U16(skb->data,CAPIMSG_BASELEN+4+4+2);
 		unsigned char *s = skb_put(nskb, CAPI_DATA_B3_RESP_LEN);
@@ -406,61 +409,74 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 	int datalen;
 	u16 errcode, datahandle;
 	struct tty_ldisc *ld;
-	
-	datalen = skb->len - CAPIMSG_LEN(skb->data);
-	if (mp->tty == NULL)
-	{
+	int ret = -1;
+
+	mutex_lock(&mp->ttylock);
+
+	if (!mp->tty) {
 #ifdef _DEBUG_DATAFLOW
 		printk(KERN_DEBUG "capi: currently no receivern");
 #endif
+		mutex_unlock(&mp->ttylock);
 		return -1;
 	}
 	
 	ld = tty_ldisc_ref(mp->tty);
-	if (ld == NULL)
-		return -1;
-	if (ld->ops->receive_buf == NULL) {
+	if (!ld || !ld->ops->receive_buf) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
-		printk(KERN_DEBUG "capi: ldisc has no receive_buf functionn");
+		printk(KERN_DEBUG "capi: no ldisc or receive_buf functionn");
 #endif
-		goto bad;
+		ret = 0;
+		goto drop;
 	}
 	if (mp->ttyinstop) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: recv tty throttledn");
 #endif
-		goto bad;
+		goto keep;
 	}
+
+	datalen = skb->len - CAPIMSG_LEN(skb->data);
 	if (mp->tty->receive_room < datalen) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: no room in ttyn");
 #endif
-		goto bad;
+		goto keep;
 	}
-	if ((nskb = gen_data_b3_resp_for(mp, skb)) == NULL) {
+
+	nskb = gen_data_b3_resp_for(mp, skb);
+	if (!nskb) {
 		printk(KERN_ERR "capi: gen_data_b3_resp failedn");
-		goto bad;
+		goto keep;
 	}
+
 	datahandle = CAPIMSG_U16(skb->data,CAPIMSG_BASELEN+4);
+
 	errcode = capi20_put_message(mp->ap, nskb);
-	if (errcode != CAPI_NOERROR) {
+
+	if (errcode == CAPI_NOERROR) {
+		skb_pull(skb, CAPIMSG_LEN(skb->data));
+#ifdef _DEBUG_DATAFLOW
+		printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldiscn",
+					datahandle, skb->len);
+#endif
+		ld->ops->receive_buf(mp->tty, skb->data, NULL, skb->len);
+	} else {
 		printk(KERN_ERR "capi: send DATA_B3_RESP failed=%xn",
 				errcode);
 		kfree_skb(nskb);
-		goto bad;
+
+		if (errcode == CAPI_SENDQUEUEFULL)
+			goto keep;
 	}
-	(void)skb_pull(skb, CAPIMSG_LEN(skb->data));
-#ifdef _DEBUG_DATAFLOW
-	printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldiscn",
-				datahandle, skb->len);
-#endif
-	ld->ops->receive_buf(mp->tty, skb->data, NULL, skb->len);
+	ret = 0;
+
+drop:
 	kfree_skb(skb);
+keep:
 	tty_ldisc_deref(ld);
-	return 0;
-bad:
-	tty_ldisc_deref(ld);
-	return -1;
+	mutex_unlock(&mp->ttylock);
+	return ret;
 }
 
 static void handle_minor_recv(struct capiminor *mp)
@@ -610,8 +626,10 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 #endif
 		kfree_skb(skb);
 		(void)capiminor_del_ack(mp, datahandle);
+		mutex_lock(&mp->ttylock);
 		if (mp->tty)
 			tty_wakeup(mp->tty);
+		mutex_unlock(&mp->ttylock);
 		(void)handle_minor_send(mp);
 
 	} else {
@@ -1006,8 +1024,12 @@ static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 
 	mutex_lock(&glue_lock);
 
-	if (tty->count == 1)
+	if (tty->count == 1) {
+		mutex_lock(&mp->ttylock);
 		mp->tty = NULL;
+		mutex_unlock(&mp->ttylock);
+	}
+
 	if (!mp->nccip)
 		capiminor_free(mp);
 
@@ -1046,7 +1068,6 @@ static int capinc_tty_write(struct tty_struct * tty,
 	skb_queue_tail(&mp->outqueue, skb);
 	mp->outbytes += skb->len;
 	(void)handle_minor_send(mp);
-	(void)handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
 	return count;
 }
@@ -1106,8 +1127,9 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 		mp->outbytes += skb->len;
 		(void)handle_minor_send(mp);
 	}
-	(void)handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
+
+	handle_minor_recv(mp);
 }
 
 static int capinc_tty_write_room(struct tty_struct *tty)
@@ -1167,14 +1189,12 @@ static void capinc_tty_throttle(struct tty_struct * tty)
 static void capinc_tty_unthrottle(struct tty_struct * tty)
 {
 	struct capiminor *mp = tty->driver_data;
-	unsigned long flags;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_unthrottlen");
 #endif
-	spin_lock_irqsave(&workaround_lock, flags);
 	mp->ttyinstop = 0;
 	handle_minor_recv(mp);
-	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
 static void capinc_tty_stop(struct tty_struct *tty)
-- 
1.6.0.2

