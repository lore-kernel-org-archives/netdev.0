From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 24/41] CAPI: Establish install/cleanup handlers for capiminor TTYs
Date: Mon,  8 Feb 2010 21:12:28 +0100
Message-ID: <292702a39a9383fcd6f98ff594415da35c1b7680.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:53809 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916Ab0BHUNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:10 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly associate/disassociate a capiminor object with its TTY via the
install/cleanup handlers instead of trying to guess first open and last
close.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   42 ++++++++++++++++++++++++++++--------------
 1 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 732cdb5..3e4997a 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1005,16 +1005,34 @@ static const struct file_operations capi_fops =
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 /* -------- tty_operations for capincci ----------------------------- */
 
-static int capinc_tty_open(struct tty_struct * tty, struct file * file)
+static int
+capinc_tty_install(struct tty_driver *driver, struct tty_struct *tty)
 {
-	struct capiminor *mp;
-	unsigned long flags;
+	int idx = tty->index;
+	struct capiminor *mp = capiminor_get(idx);
+	int ret = tty_init_termios(tty);
+
+	if (ret == 0) {
+		tty_driver_kref_get(driver);
+		tty->count++;
+		tty->driver_data = mp;
+		driver->ttys[idx] = tty;
+	} else
+		capiminor_put(mp);
+	return ret;
+}
 
-	mp = capiminor_get(iminor(file->f_path.dentry->d_inode));
-	if (mp->nccip == NULL)
-		return -ENXIO;
+static void capinc_tty_cleanup(struct tty_struct *tty)
+{
+	struct capiminor *mp = tty->driver_data;
+	tty->driver_data = NULL;
+	capiminor_put(mp);
+}
 
-	tty->driver_data = (void *)mp;
+static int capinc_tty_open(struct tty_struct * tty, struct file * file)
+{
+	struct capiminor *mp = tty->driver_data;
+	unsigned long flags;
 
 	spin_lock_irqsave(&workaround_lock, flags);
 	if (atomic_read(&mp->ttyopencount) == 0)
@@ -1030,15 +1048,12 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 
 static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 {
-	struct capiminor *mp;
+	struct capiminor *mp = tty->driver_data;
 
-	mp = (struct capiminor *)tty->driver_data;
-	if (mp)	{
 		if (atomic_dec_and_test(&mp->ttyopencount)) {
 #ifdef _DEBUG_REFCOUNT
 			printk(KERN_DEBUG "capinc_tty_close lastclose\n");
 #endif
-			tty->driver_data = NULL;
 			mp->tty = NULL;
 		}
 #ifdef _DEBUG_REFCOUNT
@@ -1047,9 +1062,6 @@ static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 		if (mp->nccip == NULL)
 			capiminor_free(mp);
 
-		capiminor_put(mp);
-	}
-
 #ifdef _DEBUG_REFCOUNT
 	printk(KERN_DEBUG "capinc_tty_close\n");
 #endif
@@ -1333,6 +1345,8 @@ static const struct tty_operations capinc_ops = {
 	.flush_buffer = capinc_tty_flush_buffer,
 	.set_ldisc = capinc_tty_set_ldisc,
 	.send_xchar = capinc_tty_send_xchar,
+	.install = capinc_tty_install,
+	.cleanup = capinc_tty_cleanup,
 };
 
 static int __init capinc_tty_init(void)
-- 
1.6.0.2

