From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 28/41] CAPI: Drop obsolete nccip from capiminor struct
Date: Mon,  8 Feb 2010 21:12:32 +0100
Message-ID: <5b17c4497189636fb9f9e2790d6ae0763600134e.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nccip in capiminor used to serve as an indicator that the NCCI was
close. But we don't need this, we issue a hangup on capincci_free_minor.
So drop this legacy.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   44 +-------------------------------------------
 1 files changed, 1 insertions(+), 43 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index b382ede..cf5e996 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -85,7 +85,6 @@ struct datahandle_queue {
 struct capiminor {
 	struct kref kref;
 
-	struct capincci  *nccip;
 	unsigned int      minor;
 	struct dentry *capifs_dentry;
 
@@ -328,10 +327,6 @@ static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 
 	mp = np->minorp = capiminor_alloc(&cdev->ap, np->ncci);
 	if (mp) {
-		mp->nccip = np;
-#ifdef _DEBUG_REFCOUNT
-		printk(KERN_DEBUG "set mp->nccip\n");
-#endif
 		device = MKDEV(capinc_tty_driver->major, mp->minor);
 		mp->capifs_dentry = capifs_new_ncci(mp->minor, device);
 	}
@@ -347,10 +342,6 @@ static void capincci_free_minor(struct capincci *np)
 
 		tty = tty_port_tty_get(&mp->port);
 		if (tty) {
-			mp->nccip = NULL;
-#ifdef _DEBUG_REFCOUNT
-			printk(KERN_DEBUG "reset mp->nccip\n");
-#endif
 			tty_vhangup(tty);
 			tty_kref_put(tty);
 		}
@@ -1094,7 +1085,7 @@ static void capinc_tty_close(struct tty_struct *tty, struct file *filp)
 	tty_port_close(&mp->port, tty, filp);
 }
 
-static int capinc_tty_write(struct tty_struct * tty,
+static int capinc_tty_write(struct tty_struct *tty,
 			    const unsigned char *buf, int count)
 {
 	struct capiminor *mp = tty->driver_data;
@@ -1105,13 +1096,6 @@ static int capinc_tty_write(struct tty_struct * tty,
 	printk(KERN_DEBUG "capinc_tty_write(count=%d)\n", count);
 #endif
 
-	if (!mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_write: mp or mp->ncci NULL\n");
-#endif
-		return 0;
-	}
-
 	spin_lock_irqsave(&workaround_lock, flags);
 	skb = mp->ttyskb;
 	if (skb) {
@@ -1149,13 +1133,6 @@ static int capinc_tty_put_char(struct tty_struct *tty, unsigned char ch)
 	printk(KERN_DEBUG "capinc_put_char(%u)\n", ch);
 #endif
 
-	if (!mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_put_char: mp or mp->ncci NULL\n");
-#endif
-		return 0;
-	}
-
 	spin_lock_irqsave(&workaround_lock, flags);
 	skb = mp->ttyskb;
 	if (skb) {
@@ -1192,13 +1169,6 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 	printk(KERN_DEBUG "capinc_tty_flush_chars\n");
 #endif
 
-	if (!mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_flush_chars: mp or mp->ncci NULL\n");
-#endif
-		return;
-	}
-
 	spin_lock_irqsave(&workaround_lock, flags);
 	skb = mp->ttyskb;
 	if (skb) {
@@ -1216,12 +1186,6 @@ static int capinc_tty_write_room(struct tty_struct *tty)
 	struct capiminor *mp = tty->driver_data;
 	int room;
 
-	if (!mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_write_room: mp or mp->ncci NULL\n");
-#endif
-		return 0;
-	}
 	room = CAPINC_MAX_SENDQUEUE-skb_queue_len(&mp->outqueue);
 	room *= CAPI_MAX_BLKSIZE;
 #ifdef _DEBUG_TTYFUNCS
@@ -1234,12 +1198,6 @@ static int capinc_tty_chars_in_buffer(struct tty_struct *tty)
 {
 	struct capiminor *mp = tty->driver_data;
 
-	if (!mp->nccip) {
-#ifdef _DEBUG_TTYFUNCS
-		printk(KERN_DEBUG "capinc_tty_chars_in_buffer: mp or mp->ncci NULL\n");
-#endif
-		return 0;
-	}
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_chars_in_buffer = %d nack=%d sq=%d rq=%d\n",
 			mp->outbytes, mp->nack,
-- 
1.6.0.2
