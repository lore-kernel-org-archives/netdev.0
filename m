From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 21/41] CAPI: Dynamically register minor devices
Date: Mon,  8 Feb 2010 21:12:25 +0100
Message-ID: <f3f9552b2ecafdc240cf951a06c2bf83f5e6a1c4.1265659935.git.jan.kiszka@web.de>
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

Register capiminors dynamically with the TTY core so that udev can make
them show up as the NCCIs appear or disappear. This removes the need to
check if the capiminor requested in capinc_tty_open actually exists.

And this completely obsoletes capifs which will be scheduled for removal
in a later patch.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   35 ++++++++++++++++++++++++-----------
 1 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index c22b349..901b79b 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -153,6 +153,8 @@ static LIST_HEAD(capidev_list);
 static DEFINE_RWLOCK(capiminors_lock);
 static struct capiminor **capiminors;
 
+static struct tty_driver *capinc_tty_driver;
+
 /* -------- datahandles --------------------------------------------- */
 
 static int capiminor_add_ack(struct capiminor *mp, u16 datahandle)
@@ -213,6 +215,7 @@ static void capiminor_del_all_ack(struct capiminor *mp)
 static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 {
 	struct capiminor *mp;
+	struct device *dev;
 	unsigned int minor;
 	unsigned long flags;
 
@@ -243,19 +246,33 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 
 	if (minor == capi_ttyminors) {
 		printk(KERN_NOTICE "capi: out of minors\n");
-		kfree(mp);
-		return NULL;
+		goto err_out1;
 	}
 
 	mp->minor = minor;
 
+	dev = tty_register_device(capinc_tty_driver, minor, NULL);
+	if (IS_ERR(dev))
+		goto err_out2;
+
 	return mp;
+
+err_out2:
+	write_lock_irqsave(&capiminors_lock, flags);
+	capiminors[minor] = NULL;
+	write_unlock_irqrestore(&capiminors_lock, flags);
+
+err_out1:
+	kfree(mp);
+	return NULL;
 }
 
 static void capiminor_free(struct capiminor *mp)
 {
 	unsigned long flags;
 
+	tty_unregister_device(capinc_tty_driver, mp->minor);
+
 	write_lock_irqsave(&capiminors_lock, flags);
 	capiminors[mp->minor] = NULL;
 	write_unlock_irqrestore(&capiminors_lock, flags);
@@ -268,13 +285,10 @@ static void capiminor_free(struct capiminor *mp)
 	kfree(mp);
 }
 
-static struct capiminor *capiminor_find(unsigned int minor)
+static struct capiminor *capiminor_get(unsigned int minor)
 {
 	struct capiminor *mp;
 
-	if (minor >= capi_ttyminors)
-		return NULL;
-
 	read_lock(&capiminors_lock);
 	mp = capiminors[minor];
 	read_unlock(&capiminors_lock);
@@ -981,8 +995,7 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 	struct capiminor *mp;
 	unsigned long flags;
 
-	if ((mp = capiminor_find(iminor(file->f_path.dentry->d_inode))) == NULL)
-		return -ENXIO;
+	mp = capiminor_get(iminor(file->f_path.dentry->d_inode));
 	if (mp->nccip == NULL)
 		return -ENXIO;
 
@@ -1284,8 +1297,6 @@ static void capinc_tty_send_xchar(struct tty_struct *tty, char ch)
 #endif
 }
 
-static struct tty_driver *capinc_tty_driver;
-
 static const struct tty_operations capinc_ops = {
 	.open = capinc_tty_open,
 	.close = capinc_tty_close,
@@ -1339,7 +1350,9 @@ static int __init capinc_tty_init(void)
 	drv->init_termios.c_oflag = OPOST | ONLCR;
 	drv->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL | CLOCAL;
 	drv->init_termios.c_lflag = 0;
-	drv->flags = TTY_DRIVER_REAL_RAW|TTY_DRIVER_RESET_TERMIOS;
+	drv->flags =
+		TTY_DRIVER_REAL_RAW | TTY_DRIVER_RESET_TERMIOS |
+		TTY_DRIVER_DYNAMIC_DEV;
 	tty_set_operations(drv, &capinc_ops);
 
 	err = tty_register_driver(drv);
-- 
1.6.0.2
