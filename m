From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 21/31] CAPI: Remove useless checks for tty->driver_data or hung up state
Date: Fri, 8 Jan 2010 12:00:23 +0100
Message-ID: <c9ce6c91b2b475a59d338a4e97620d704ccf6fb6.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:49666 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755414Ab0AVX0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:26:07 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove more desperate attempts to fix races in the original code: As
long as the TTY is open, its driver_data cannot become NULL. And we
already call tty_hangup to signal the end of a connection, no need to
check for mp->nccip in addition.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   80 ++++++++++++----------------------------------
 1 files changed, 21 insertions(+), 59 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 7710a66..77faa4e 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1017,7 +1017,7 @@ static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 static int capinc_tty_write(struct tty_struct * tty,
 			    const unsigned char *buf, int count)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 	unsigned long flags;
 
@@ -1025,13 +1025,6 @@ static int capinc_tty_write(struct tty_struct * tty,
 	printk(KERN_DEBUG "capinc_tty_write(count=%d)n", count);
 #endif
 
-	if (!mp || !mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_write: mp or mp->ncci NULLn");
-#endif
-		return 0;
-	}
-
 	spin_lock_irqsave(&workaround_lock, flags);
 	skb = mp->ttyskb;
 	if (skb) {
@@ -1060,7 +1053,7 @@ static int capinc_tty_write(struct tty_struct * tty,
 
 static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 	unsigned long flags;
 	int ret = 1;
@@ -1069,13 +1062,6 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	printk(KERN_DEBUG "capinc_put_char(%u)n", ch);
 #endif
 
-	if (!mp || !mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_put_char: mp or mp->ncci NULLn");
-#endif
-		return 0;
-	}
-
 	spin_lock_irqsave(&workaround_lock, flags);
 	skb = mp->ttyskb;
 	if (skb) {
@@ -1104,7 +1090,7 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 
 static void capinc_tty_flush_chars(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	struct sk_buff *skb;
 	unsigned long flags;
 
@@ -1112,13 +1098,6 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 	printk(KERN_DEBUG "capinc_tty_flush_charsn");
 #endif
 
-	if (!mp || !mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_flush_chars: mp or mp->ncci NULLn");
-#endif
-		return;
-	}
-
 	spin_lock_irqsave(&workaround_lock, flags);
 	skb = mp->ttyskb;
 	if (skb) {
@@ -1133,14 +1112,9 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 
 static int capinc_tty_write_room(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	int room;
-	if (!mp || !mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_write_room: mp or mp->ncci NULLn");
-#endif
-		return 0;
-	}
+
 	room = CAPINC_MAX_SENDQUEUE-skb_queue_len(&mp->outqueue);
 	room *= CAPI_MAX_BLKSIZE;
 #ifdef _DEBUG_TTYFUNCS
@@ -1151,13 +1125,8 @@ static int capinc_tty_write_room(struct tty_struct *tty)
 
 static int capinc_tty_chars_in_buffer(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
-	if (!mp || !mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_chars_in_buffer: mp or mp->ncci NULLn");
-#endif
-		return 0;
-	}
+	struct capiminor *mp = tty->driver_data;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_chars_in_buffer = %d nack=%d sq=%d rq=%dn",
 			mp->outbytes, mp->nack,
@@ -1188,53 +1157,46 @@ static void capinc_tty_set_termios(struct tty_struct *tty, struct ktermios * old
 
 static void capinc_tty_throttle(struct tty_struct * tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_throttlen");
 #endif
-	if (mp)
-		mp->ttyinstop = 1;
+	mp->ttyinstop = 1;
 }
 
 static void capinc_tty_unthrottle(struct tty_struct * tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	unsigned long flags;
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_unthrottlen");
 #endif
-	if (mp) {
-		spin_lock_irqsave(&workaround_lock, flags);
-		mp->ttyinstop = 0;
-		handle_minor_recv(mp);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-	}
+	spin_lock_irqsave(&workaround_lock, flags);
+	mp->ttyinstop = 0;
+	handle_minor_recv(mp);
+	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
 static void capinc_tty_stop(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_stopn");
 #endif
-	if (mp) {
-		mp->ttyoutstop = 1;
-	}
+	mp->ttyoutstop = 1;
 }
 
 static void capinc_tty_start(struct tty_struct *tty)
 {
-	struct capiminor *mp = (struct capiminor *)tty->driver_data;
+	struct capiminor *mp = tty->driver_data;
 	unsigned long flags;
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_startn");
 #endif
-	if (mp) {
-		spin_lock_irqsave(&workaround_lock, flags);
-		mp->ttyoutstop = 0;
-		(void)handle_minor_send(mp);
-		spin_unlock_irqrestore(&workaround_lock, flags);
-	}
+	spin_lock_irqsave(&workaround_lock, flags);
+	mp->ttyoutstop = 0;
+	(void)handle_minor_send(mp);
+	spin_unlock_irqrestore(&workaround_lock, flags);
 }
 
 static void capinc_tty_hangup(struct tty_struct *tty)
-- 
1.6.0.2

