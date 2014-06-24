From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH 1/3] mmc: vub300: use request_firmware_direct() for pseudo code
Date: Tue, 24 Jun 2014 15:39:41 -0700
Message-ID: <1403649583-12707-2-git-send-email-mcgrof@do-not-panic.com>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, "Luis R. Rodriguez" <mcgrof@suse.com>,
	Tony Olech <tony.olech@elandigitalsystems.com>,
	linux-mmc@vger.kernel.org, linux-usb@vger.kernel.org
To: tiwai@suse.de, chunkeey@googlemail.com, leedom@chelsio.com,
	cocci@systeme.lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

vub300 uses the request_firmware() API for downloading
pseudo code twice and if this fails its not considered fatal.
Avoid letting the request linger 60 seconds because of udev if
one of the requests fails by explicitly skipping the udev helper.

This was found with the following SmPL patch.

@ firmware_not_critical @
expression cf;
expression config_file;
expression dev;
int ret;
identifier l;
statement S;
@@

-	ret = request_firmware(&cf, config_file, dev);
+	ret = request_firmware_direct(&cf, config_file, dev);
	if (ret < 0) {
		... when != goto l;
		    when != return ret;
		    when any
	} else {
		...
		release_firmware(cf);
		...
	}

Cc: Tony Olech <tony.olech@elandigitalsystems.com>
Cc: linux-mmc@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: Takashi Iwai <tiwai@suse.de>
Cc: cocci@systeme.lip6.fr
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/mmc/host/vub300.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/mmc/host/vub300.c b/drivers/mmc/host/vub300.c
index 4262296..15eeaff 100644
--- a/drivers/mmc/host/vub300.c
+++ b/drivers/mmc/host/vub300.c
@@ -1378,11 +1378,12 @@ static void download_offload_pseudocode(struct vub300_mmc_host *vub300)
 	snprintf(vub300->vub_name + l, sizeof(vub300->vub_name) - l, ".bin");
 	dev_info(&vub300->udev->dev, "requesting offload firmware %s\n",
 		 vub300->vub_name);
-	retval = request_firmware(&fw, vub300->vub_name, &card->dev);
+	retval = request_firmware_direct(&fw, vub300->vub_name, &card->dev);
 	if (retval < 0) {
 		strncpy(vub300->vub_name, "vub_default.bin",
 			sizeof(vub300->vub_name));
-		retval = request_firmware(&fw, vub300->vub_name, &card->dev);
+		retval = request_firmware_direct(&fw, vub300->vub_name,
+						 &card->dev);
 		if (retval < 0) {
 			strncpy(vub300->vub_name,
 				"no SDIO offload firmware found",
-- 
2.0.0
