From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 04/14] staging: panel: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:30 +0530
Message-ID: <1428492040-5581-5-git-send-email-sudipm.mukherjee@gmail.com>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, alsa-devel@alsa-project.org,
 linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org,
 linux-i2c@vger.kernel.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jean Delvare <jdelvare@suse.de>, Wolfram Sang <wsa@the-dreams.de>,
 Rodolfo Giometti <giometti@enneenne.com>,
 "James E.J. Bottomley" <JBottomley@parallels.com>,
 Mark Brown <broonie@kernel.org>, Willy Tarreau <willy@meta-x.org>,
 Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

now that we are monitoring the return value from attach, make the
required changes to return proper value from its attach function.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/staging/panel/panel.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/panel/panel.c b/drivers/staging/panel/panel.c
index ea54fb4..61f6961 100644
--- a/drivers/staging/panel/panel.c
+++ b/drivers/staging/panel/panel.c
@@ -2188,15 +2188,15 @@ static struct notifier_block panel_notifier = {
 	0
 };
 
-static void panel_attach(struct parport *port)
+static int panel_attach(struct parport *port)
 {
 	if (port->number != parport)
-		return;
+		return -ENODEV;
 
 	if (pprt) {
 		pr_err("%s: port->number=%d parport=%d, already registered!\n",
 		       __func__, port->number, parport);
-		return;
+		return -EALREADY;
 	}
 
 	pprt = parport_register_device(port, "panel", NULL, NULL,  /* pf, kf */
@@ -2206,7 +2206,7 @@ static void panel_attach(struct parport *port)
 	if (pprt == NULL) {
 		pr_err("%s: port->number=%d parport=%d, parport_register_device() failed\n",
 		       __func__, port->number, parport);
-		return;
+		return -ENODEV;
 	}
 
 	if (parport_claim(pprt)) {
@@ -2230,7 +2230,7 @@ static void panel_attach(struct parport *port)
 			goto err_lcd_unreg;
 	}
 	register_reboot_notifier(&panel_notifier);
-	return;
+	return 0;
 
 err_lcd_unreg:
 	if (lcd.enabled)
@@ -2238,6 +2238,7 @@ err_lcd_unreg:
 err_unreg_device:
 	parport_unregister_device(pprt);
 	pprt = NULL;
+	return -ENODEV;
 }
 
 static void panel_detach(struct parport *port)
-- 
1.8.1.2
