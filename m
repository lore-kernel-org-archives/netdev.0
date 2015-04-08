From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 11/14] net: plip: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:37 +0530
Message-ID: <1428492040-5581-12-git-send-email-sudipm.mukherjee@gmail.com>
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
also return the proper error code in module_init.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/plip/plip.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 040b897..6706bc3 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -1243,7 +1243,7 @@ plip_searchfor(int list[], int a)
 
 /* plip_attach() is called (by the parport code) when a port is
  * available to use. */
-static void plip_attach (struct parport *port)
+static int plip_attach(struct parport *port)
 {
 	static int unit;
 	struct net_device *dev;
@@ -1254,13 +1254,13 @@ static void plip_attach (struct parport *port)
 	    plip_searchfor(parport, port->number)) {
 		if (unit == PLIP_MAX) {
 			printk(KERN_ERR "plip: too many devices\n");
-			return;
+			return -EINVAL;
 		}
 
 		sprintf(name, "plip%d", unit);
 		dev = alloc_etherdev(sizeof(struct net_local));
 		if (!dev)
-			return;
+			return -ENOMEM;
 
 		strcpy(dev->name, name);
 
@@ -1300,12 +1300,13 @@ static void plip_attach (struct parport *port)
 					 dev->name, dev->base_addr);
 		dev_plip[unit++] = dev;
 	}
-	return;
+	return 0;
 
 err_parport_unregister:
 	parport_unregister_device(nl->pardev);
 err_free_dev:
 	free_netdev(dev);
+	return -ENODEV;
 }
 
 /* plip_detach() is called (by the parport code) when a port is
@@ -1379,6 +1380,8 @@ __setup("plip=", plip_setup);
 
 static int __init plip_init (void)
 {
+	int err;
+
 	if (parport[0] == -2)
 		return 0;
 
@@ -1387,9 +1390,10 @@ static int __init plip_init (void)
 		timid = 0;
 	}
 
-	if (parport_register_driver (&plip_driver)) {
+	err = parport_register_driver(&plip_driver);
+	if (err) {
 		printk (KERN_WARNING "plip: couldn't register driver\n");
-		return 1;
+		return err;
 	}
 
 	return 0;
-- 
1.8.1.2
