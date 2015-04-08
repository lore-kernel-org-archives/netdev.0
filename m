From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 03/14] ALSA: mts64: return proper error values from attach
Date: Wed,  8 Apr 2015 16:50:29 +0530
Message-ID: <1428492040-5581-4-git-send-email-sudipm.mukherjee@gmail.com>
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
 sound/drivers/mts64.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/sound/drivers/mts64.c b/sound/drivers/mts64.c
index 2a008a9..fb6223e 100644
--- a/sound/drivers/mts64.c
+++ b/sound/drivers/mts64.c
@@ -874,32 +874,35 @@ static int snd_mts64_probe_port(struct parport *p)
 	return res;
 }
 
-static void snd_mts64_attach(struct parport *p)
+static int snd_mts64_attach(struct parport *p)
 {
 	struct platform_device *device;
+	int ret;
 
 	device = platform_device_alloc(PLATFORM_DRIVER, device_count);
 	if (!device)
-		return;
+		return -ENOMEM;
 
 	/* Temporary assignment to forward the parport */
 	platform_set_drvdata(device, p);
 
-	if (platform_device_add(device) < 0) {
+	ret = platform_device_add(device);
+	if (ret < 0) {
 		platform_device_put(device);
-		return;
+		return ret;
 	}
 
 	/* Since we dont get the return value of probe
 	 * We need to check if device probing succeeded or not */
 	if (!platform_get_drvdata(device)) {
 		platform_device_unregister(device);
-		return;
+		return -ENODEV;
 	}
 
 	/* register device in global table */
 	platform_devices[device_count] = device;
 	device_count++;
+	return 0;
 }
 
 static void snd_mts64_detach(struct parport *p)
-- 
1.8.1.2
