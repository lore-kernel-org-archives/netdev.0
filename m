From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 20/41] CAPI: Clean up capinc_tty_init/exit
Date: Mon,  8 Feb 2010 21:12:24 +0100
Message-ID: <5d527d17d635af5578d3e64b698bee4a8dd1450c.1265659935.git.jan.kiszka@web.de>
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

Return proper error code if tty_register_driver fails. In contrast,
tty_unregister_driver cannot practically fail, so drop that error
handling. Finally, mark capinc_tty_init/exit with __init/__exit.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 46f85ae..c22b349 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1307,10 +1307,11 @@ static const struct tty_operations capinc_ops = {
 	.send_xchar = capinc_tty_send_xchar,
 };
 
-static int capinc_tty_init(void)
+static int __init capinc_tty_init(void)
 {
 	struct tty_driver *drv;
-	
+	int err;
+
 	if (capi_ttyminors > CAPINC_MAX_PORTS)
 		capi_ttyminors = CAPINC_MAX_PORTS;
 	if (capi_ttyminors <= 0)
@@ -1340,23 +1341,22 @@ static int capinc_tty_init(void)
 	drv->init_termios.c_lflag = 0;
 	drv->flags = TTY_DRIVER_REAL_RAW|TTY_DRIVER_RESET_TERMIOS;
 	tty_set_operations(drv, &capinc_ops);
-	if (tty_register_driver(drv)) {
+
+	err = tty_register_driver(drv);
+	if (err) {
 		put_tty_driver(drv);
 		kfree(capiminors);
 		printk(KERN_ERR "Couldn't register capi_nc driver\n");
-		return -1;
+		return err;
 	}
 	capinc_tty_driver = drv;
 	return 0;
 }
 
-static void capinc_tty_exit(void)
+static void __exit capinc_tty_exit(void)
 {
-	struct tty_driver *drv = capinc_tty_driver;
-	int retval;
-	if ((retval = tty_unregister_driver(drv)))
-		printk(KERN_ERR "capi: failed to unregister capi_nc driver (%d)\n", retval);
-	put_tty_driver(drv);
+	tty_unregister_driver(capinc_tty_driver);
+	put_tty_driver(capinc_tty_driver);
 	kfree(capiminors);
 }
 
-- 
1.6.0.2
