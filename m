From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 09/14] pps: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:35 +0530
Message-ID: <1428492040-5581-10-git-send-email-sudipm.mukherjee@gmail.com>
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
 drivers/pps/generators/pps_gen_parport.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/pps/generators/pps_gen_parport.c b/drivers/pps/generators/pps_gen_parport.c
index dcd39fb..499f410 100644
--- a/drivers/pps/generators/pps_gen_parport.c
+++ b/drivers/pps/generators/pps_gen_parport.c
@@ -190,18 +190,18 @@ static inline ktime_t next_intr_time(struct pps_generator_pp *dev)
 			dev->port_write_time + 3 * SAFETY_INTERVAL));
 }
 
-static void parport_attach(struct parport *port)
+static int parport_attach(struct parport *port)
 {
 	if (attached) {
 		/* we already have a port */
-		return;
+		return -EALREADY;
 	}
 
 	device.pardev = parport_register_device(port, KBUILD_MODNAME,
 			NULL, NULL, NULL, PARPORT_FLAG_EXCL, &device);
 	if (!device.pardev) {
 		pr_err("couldn't register with %s\n", port->name);
-		return;
+		return -ENODEV;
 	}
 
 	if (parport_claim_or_block(device.pardev) < 0) {
@@ -218,10 +218,11 @@ static void parport_attach(struct parport *port)
 	device.timer.function = hrtimer_event;
 	hrtimer_start(&device.timer, next_intr_time(&device), HRTIMER_MODE_ABS);
 
-	return;
+	return 0;
 
 err_unregister_dev:
 	parport_unregister_device(device.pardev);
+	return -ENODEV;
 }
 
 static void parport_detach(struct parport *port)
-- 
1.8.1.2
