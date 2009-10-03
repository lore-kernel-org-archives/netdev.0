From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC] isdn/capi: fix up CAPI subsystem workaround locking a bit
Date: Sat,  3 Oct 2009 14:06:57 +0200 (CEST)
Message-ID: <20091003120657.2228911186C@xenon.ts.pxnet.com>
Cc: Michael Buesch <mb@bu3sch.de>, Carsten Paeth <calle@calle.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	Armin Schindler <armin@melware.de>,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755642AbZJCMH1@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move calls to handle_minor_send() and handle_minor_recv() out of
the sections locked by workaround_lock.
- handle_minor_send() may call another CAPI function via the card
  driver, deadlocking by trying to take workaround_lock again.
- handle_minor_recv() calls the receive_buf method of the active
  line discipline which may sleep.

This fixes Bugzilla entries 11687 and 14305 but may reenlarge the
window of vulnerability for the races that were not-quite-fixed by
commit 053b47ff249b9e0a634dae807f81465205e7c228. To avoid one
specific race, read the mp->tty member of the capiminor structure
only once in handle_recv_skb().

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
I wasn't able to get any information on the nature of the problem fixed
by commit 053b47ff249b9e0a634dae807f81465205e7c228 from its author, nor
did my search of the LKML archives yield anything on it, so I went for
a minimally invasive approach. It works on my test machine, but a
complete overhaul of locking in capi.ko would of course be better.

 drivers/isdn/capi/capi.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 65bf91e..f348df2 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -452,18 +452,19 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 	struct sk_buff *nskb;
 	int datalen;
 	u16 errcode, datahandle;
+	struct tty_struct *tty;
 	struct tty_ldisc *ld;
 	
 	datalen = skb->len - CAPIMSG_LEN(skb->data);
-	if (mp->tty == NULL)
-	{
+	tty = mp->tty;
+	if (tty == NULL) {
 #ifdef _DEBUG_DATAFLOW
 		printk(KERN_DEBUG "capi: currently no receiver\n");
 #endif
 		return -1;
 	}
 	
-	ld = tty_ldisc_ref(mp->tty);
+	ld = tty_ldisc_ref(tty);
 	if (ld == NULL)
 		return -1;
 	if (ld->ops->receive_buf == NULL) {
@@ -478,7 +479,7 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 #endif
 		goto bad;
 	}
-	if (mp->tty->receive_room < datalen) {
+	if (tty->receive_room < datalen) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: no room in tty\n");
 #endif
@@ -501,7 +502,7 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 	printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldisc\n",
 				datahandle, skb->len);
 #endif
-	ld->ops->receive_buf(mp->tty, skb->data, NULL, skb->len);
+	ld->ops->receive_buf(tty, skb->data, NULL, skb->len);
 	kfree_skb(skb);
 	tty_ldisc_deref(ld);
 	return 0;
@@ -653,7 +654,9 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 #endif
 		skb_queue_tail(&mp->inqueue, skb);
 		mp->inbytes += skb->len;
+		spin_unlock_irqrestore(&workaround_lock, flags);
 		handle_minor_recv(mp);
+		return;
 
 	} else if (CAPIMSG_SUBCOMMAND(skb->data) == CAPI_CONF) {
 
@@ -667,7 +670,9 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 		(void)capiminor_del_ack(mp, datahandle);
 		if (mp->tty)
 			tty_wakeup(mp->tty);
-		(void)handle_minor_send(mp);
+		spin_unlock_irqrestore(&workaround_lock, flags);
+		handle_minor_send(mp);
+		return;
 
 	} else {
 		/* ups, let capi application handle it :-) */
@@ -1042,8 +1047,8 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 #ifdef _DEBUG_REFCOUNT
 	printk(KERN_DEBUG "capinc_tty_open ocount=%d\n", atomic_read(&mp->ttyopencount));
 #endif
-	handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
+	handle_minor_recv(mp);
 	return 0;
 }
 
@@ -1110,9 +1115,9 @@ static int capinc_tty_write(struct tty_struct * tty,
 
 	skb_queue_tail(&mp->outqueue, skb);
 	mp->outbytes += skb->len;
-	(void)handle_minor_send(mp);
-	(void)handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
+	handle_minor_send(mp);
+	handle_minor_recv(mp);
 	return count;
 }
 
@@ -1145,7 +1150,6 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 		mp->ttyskb = NULL;
 		skb_queue_tail(&mp->outqueue, skb);
 		mp->outbytes += skb->len;
-		(void)handle_minor_send(mp);
 	}
 	skb = alloc_skb(CAPI_DATA_B3_REQ_LEN+CAPI_MAX_BLKSIZE, GFP_ATOMIC);
 	if (skb) {
@@ -1157,6 +1161,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 		ret = 0;
 	}
 	spin_unlock_irqrestore(&workaround_lock, flags);
+	handle_minor_send(mp);
 	return ret;
 }
 
@@ -1183,10 +1188,10 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 		mp->ttyskb = NULL;
 		skb_queue_tail(&mp->outqueue, skb);
 		mp->outbytes += skb->len;
-		(void)handle_minor_send(mp);
 	}
-	(void)handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
+	handle_minor_send(mp);
+	handle_minor_recv(mp);
 }
 
 static int capinc_tty_write_room(struct tty_struct *tty)
@@ -1264,8 +1269,8 @@ static void capinc_tty_unthrottle(struct tty_struct * tty)
 	if (mp) {
 		spin_lock_irqsave(&workaround_lock, flags);
 		mp->ttyinstop = 0;
-		handle_minor_recv(mp);
 		spin_unlock_irqrestore(&workaround_lock, flags);
+		handle_minor_recv(mp);
 	}
 }
 
@@ -1290,8 +1295,8 @@ static void capinc_tty_start(struct tty_struct *tty)
 	if (mp) {
 		spin_lock_irqsave(&workaround_lock, flags);
 		mp->ttyoutstop = 0;
-		(void)handle_minor_send(mp);
 		spin_unlock_irqrestore(&workaround_lock, flags);
+		handle_minor_send(mp);
 	}
 }
 
-- 
1.6.2.1.214.ge986c
