From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 14/14] char: lp: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:40 +0530
Message-ID: <1428492040-5581-15-git-send-email-sudipm.mukherjee@gmail.com>
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
 drivers/char/lp.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/char/lp.c b/drivers/char/lp.c
index c4094c4..6988480 100644
--- a/drivers/char/lp.c
+++ b/drivers/char/lp.c
@@ -900,34 +900,40 @@ static int lp_register(int nr, struct parport *port)
 	return 0;
 }
 
-static void lp_attach (struct parport *port)
+static int lp_attach(struct parport *port)
 {
 	unsigned int i;
+	int ret = -ENODEV;
 
 	switch (parport_nr[0]) {
 	case LP_PARPORT_UNSPEC:
 	case LP_PARPORT_AUTO:
 		if (parport_nr[0] == LP_PARPORT_AUTO &&
 		    port->probe_info[0].class != PARPORT_CLASS_PRINTER)
-			return;
+			return ret;
 		if (lp_count == LP_NO) {
 			printk(KERN_INFO "lp: ignoring parallel port (max. %d)\n",LP_NO);
-			return;
+			return ret;
 		}
-		if (!lp_register(lp_count, port))
+		if (!lp_register(lp_count, port)) {
 			lp_count++;
+			ret = 0;
+		}
 		break;
 
 	default:
 		for (i = 0; i < LP_NO; i++) {
 			if (port->number == parport_nr[i]) {
-				if (!lp_register(i, port))
+				if (!lp_register(i, port)) {
 					lp_count++;
+					ret = 0;
+				}
 				break;
 			}
 		}
 		break;
 	}
+	return ret;
 }
 
 static void lp_detach (struct parport *port)
-- 
1.8.1.2
