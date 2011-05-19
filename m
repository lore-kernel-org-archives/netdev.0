From: David Miller <davem@davemloft.net>
Subject: [PATCH] isdn: capi: Use pr_debug() instead of ifdefs.
Date: Thu, 19 May 2011 18:20:49 -0400 (EDT)
Message-ID: <20110519.182049.284494284250756089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216Ab1ESWUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:20:51 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMKnUQ026970
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:20:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I was investigating some warnings that spew because of the
_DEBUG_FOO ifdef'ery in here.

Instead of adding more ifdefs to fix that warning, let's use
pr_debug() and get rid of these CPP checks altogether.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/capi/capi.c |  115 +++++++++++++---------------------------------
 1 files changed, 32 insertions(+), 83 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index bea1009..e44933d 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -42,9 +42,6 @@ MODULE_DESCRIPTION("CAPI4Linux: Userspace /dev/capi20 interface");
 MODULE_AUTHOR("Carsten Paeth");
 MODULE_LICENSE("GPL");
 
-#undef _DEBUG_TTYFUNCS		/* call to tty_driver */
-#undef _DEBUG_DATAFLOW		/* data flow */
-
 /* -------- driver information -------------------------------------- */
 
 static DEFINE_MUTEX(capi_mutex);
@@ -418,9 +415,7 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 
 	tty = tty_port_tty_get(&mp->port);
 	if (!tty) {
-#ifdef _DEBUG_DATAFLOW
-		printk(KERN_DEBUG "capi: currently no receiver\n");
-#endif
+		pr_debug("capi: currently no receiver\n");
 		return -1;
 	}
 	
@@ -433,23 +428,17 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 	}
 
 	if (ld->ops->receive_buf == NULL) {
-#if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
-		printk(KERN_DEBUG "capi: ldisc has no receive_buf function\n");
-#endif
+		pr_debug("capi: ldisc has no receive_buf function\n");
 		/* fatal error, do not requeue */
 		goto free_skb;
 	}
 	if (mp->ttyinstop) {
-#if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
-		printk(KERN_DEBUG "capi: recv tty throttled\n");
-#endif
+		pr_debug("capi: recv tty throttled\n");
 		goto deref_ldisc;
 	}
 
 	if (tty->receive_room < datalen) {
-#if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
-		printk(KERN_DEBUG "capi: no room in tty\n");
-#endif
+		pr_debug("capi: no room in tty\n");
 		goto deref_ldisc;
 	}
 
@@ -465,10 +454,8 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 
 	if (errcode == CAPI_NOERROR) {
 		skb_pull(skb, CAPIMSG_LEN(skb->data));
-#ifdef _DEBUG_DATAFLOW
-		printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldisc\n",
-					datahandle, skb->len);
-#endif
+		pr_debug("capi: DATA_B3_RESP %u len=%d => ldisc\n",
+			 datahandle, skb->len);
 		ld->ops->receive_buf(tty, skb->data, NULL, skb->len);
 	} else {
 		printk(KERN_ERR "capi: send DATA_B3_RESP failed=%x\n",
@@ -515,9 +502,7 @@ static void handle_minor_send(struct capiminor *mp)
 		return;
 
 	if (mp->ttyoutstop) {
-#if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
-		printk(KERN_DEBUG "capi: send: tty stopped\n");
-#endif
+		pr_debug("capi: send: tty stopped\n");
 		tty_kref_put(tty);
 		return;
 	}
@@ -559,10 +544,8 @@ static void handle_minor_send(struct capiminor *mp)
 		}
 		errcode = capi20_put_message(mp->ap, skb);
 		if (errcode == CAPI_NOERROR) {
-#ifdef _DEBUG_DATAFLOW
-			printk(KERN_DEBUG "capi: DATA_B3_REQ %u len=%u\n",
-							datahandle, len);
-#endif
+			pr_debug("capi: DATA_B3_REQ %u len=%u\n",
+				 datahandle, len);
 			continue;
 		}
 		capiminor_del_ack(mp, datahandle);
@@ -636,10 +619,8 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	}
 	if (CAPIMSG_SUBCOMMAND(skb->data) == CAPI_IND) {
 		datahandle = CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+4+2);
-#ifdef _DEBUG_DATAFLOW
-		printk(KERN_DEBUG "capi_signal: DATA_B3_IND %u len=%d\n",
-				datahandle, skb->len-CAPIMSG_LEN(skb->data));
-#endif
+		pr_debug("capi_signal: DATA_B3_IND %u len=%d\n",
+			 datahandle, skb->len-CAPIMSG_LEN(skb->data));
 		skb_queue_tail(&mp->inqueue, skb);
 
 		handle_minor_recv(mp);
@@ -647,11 +628,9 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 	} else if (CAPIMSG_SUBCOMMAND(skb->data) == CAPI_CONF) {
 
 		datahandle = CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4);
-#ifdef _DEBUG_DATAFLOW
-		printk(KERN_DEBUG "capi_signal: DATA_B3_CONF %u 0x%x\n",
-				datahandle,
-				CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+2));
-#endif
+		pr_debug("capi_signal: DATA_B3_CONF %u 0x%x\n",
+			 datahandle,
+			 CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+2));
 		kfree_skb(skb);
 		capiminor_del_ack(mp, datahandle);
 		tty = tty_port_tty_get(&mp->port);
@@ -1081,9 +1060,7 @@ static int capinc_tty_write(struct tty_struct *tty,
 	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_write(count=%d)\n", count);
-#endif
+	pr_debug("capinc_tty_write(count=%d)\n", count);
 
 	spin_lock_bh(&mp->outlock);
 	skb = mp->outskb;
@@ -1119,9 +1096,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	struct sk_buff *skb;
 	int ret = 1;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_put_char(%u)\n", ch);
-#endif
+	pr_debug("capinc_put_char(%u)\n", ch);
 
 	spin_lock_bh(&mp->outlock);
 	skb = mp->outskb;
@@ -1160,9 +1135,7 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_flush_chars\n");
-#endif
+	pr_debug("capinc_tty_flush_chars\n");
 
 	spin_lock_bh(&mp->outlock);
 	skb = mp->outskb;
@@ -1186,9 +1159,7 @@ static int capinc_tty_write_room(struct tty_struct *tty)
 
 	room = CAPINC_MAX_SENDQUEUE-skb_queue_len(&mp->outqueue);
 	room *= CAPI_MAX_BLKSIZE;
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_write_room = %d\n", room);
-#endif
+	pr_debug("capinc_tty_write_room = %d\n", room);
 	return room;
 }
 
@@ -1196,12 +1167,10 @@ static int capinc_tty_chars_in_buffer(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_chars_in_buffer = %d nack=%d sq=%d rq=%d\n",
-			mp->outbytes, mp->nack,
-			skb_queue_len(&mp->outqueue),
-			skb_queue_len(&mp->inqueue));
-#endif
+	pr_debug("capinc_tty_chars_in_buffer = %d nack=%d sq=%d rq=%d\n",
+		 mp->outbytes, mp->nack,
+		 skb_queue_len(&mp->outqueue),
+		 skb_queue_len(&mp->inqueue));
 	return mp->outbytes;
 }
 
@@ -1213,17 +1182,13 @@ static int capinc_tty_ioctl(struct tty_struct *tty,
 
 static void capinc_tty_set_termios(struct tty_struct *tty, struct ktermios * old)
 {
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_set_termios\n");
-#endif
+	pr_debug("capinc_tty_set_termios\n");
 }
 
 static void capinc_tty_throttle(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_throttle\n");
-#endif
+	pr_debug("capinc_tty_throttle\n");
 	mp->ttyinstop = 1;
 }
 
@@ -1231,9 +1196,7 @@ static void capinc_tty_unthrottle(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_unthrottle\n");
-#endif
+	pr_debug("capinc_tty_unthrottle\n");
 	mp->ttyinstop = 0;
 	handle_minor_recv(mp);
 }
@@ -1242,9 +1205,7 @@ static void capinc_tty_stop(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_stop\n");
-#endif
+	pr_debug("capinc_tty_stop\n");
 	mp->ttyoutstop = 1;
 }
 
@@ -1252,9 +1213,7 @@ static void capinc_tty_start(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_start\n");
-#endif
+	pr_debug("capinc_tty_start\n");
 	mp->ttyoutstop = 0;
 	handle_minor_send(mp);
 }
@@ -1263,39 +1222,29 @@ static void capinc_tty_hangup(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_hangup\n");
-#endif
+	pr_debug("capinc_tty_hangup\n");
 	tty_port_hangup(&mp->port);
 }
 
 static int capinc_tty_break_ctl(struct tty_struct *tty, int state)
 {
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_break_ctl(%d)\n", state);
-#endif
+	pr_debug("capinc_tty_break_ctl(%d)\n", state);
 	return 0;
 }
 
 static void capinc_tty_flush_buffer(struct tty_struct *tty)
 {
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_flush_buffer\n");
-#endif
+	pr_debug("capinc_tty_flush_buffer\n");
 }
 
 static void capinc_tty_set_ldisc(struct tty_struct *tty)
 {
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_set_ldisc\n");
-#endif
+	pr_debug("capinc_tty_set_ldisc\n");
 }
 
 static void capinc_tty_send_xchar(struct tty_struct *tty, char ch)
 {
-#ifdef _DEBUG_TTYFUNCS
-	printk(KERN_DEBUG "capinc_tty_send_xchar(%d)\n", ch);
-#endif
+	pr_debug("capinc_tty_send_xchar(%d)\n", ch);
 }
 
 static const struct tty_operations capinc_ops = {
-- 
1.7.4.4

