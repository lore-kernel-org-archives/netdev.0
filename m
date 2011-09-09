From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH v3] libertas: prioritize usb8388_olpc.bin firmware on OLPC
 machines
Date: Thu, 8 Sep 2011 17:35:17 -0700
Message-ID: <20110908173517.5b8c90be@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dsd@laptop.org, cjb@laptop.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Normally, the v9 firmware will be loaded if it's available.  However, on
OLPC XO-1 machines, the olpc-specific firmware supports extra functionality.
This makes the libertas driver attempt to load the custom firmware first
if the machine is an OLPC machine; if that fails (or it's not an OLPC
machine), fall back to attempting to load the other firmwares.

usb8388_olpc.bin is currently found in the linux-firmware repository.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
v3: changed firmware path to include libertas/ subdirectory.

Since the last submission (v2), usb8388_olpc.bin has found its way into
wireless-firmware.  It'd be nice to get this into the next merge window.

 drivers/net/wireless/libertas/if_usb.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index b5acc39..94f8f3e 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -973,6 +973,23 @@ static const struct {
 	{ MODEL_8682, "libertas/usb8682.bin" }
 };
 
+#ifdef CONFIG_OLPC
+
+static int try_olpc_fw(struct if_usb_card *cardp)
+{
+	int retval = -ENOENT;
+
+	/* try the OLPC firmware first; fall back to fw_table list */
+	if (machine_is_olpc() && cardp->model == MODEL_8388)
+		retval = request_firmware(&cardp->fw,
+				"libertas/usb8388_olpc.bin", &cardp->udev->dev);
+	return retval;
+}
+
+#else
+static int try_olpc_fw(struct if_usb_card *cardp) { return -ENOENT; }
+#endif /* !CONFIG_OLPC */
+
 static int get_fw(struct if_usb_card *cardp, const char *fwname)
 {
 	int i;
@@ -981,6 +998,10 @@ static int get_fw(struct if_usb_card *cardp, const char *fwname)
 	if (fwname)
 		return request_firmware(&cardp->fw, fwname, &cardp->udev->dev);
 
+	/* Handle OLPC firmware */
+	if (try_olpc_fw(cardp) == 0)
+		return 0;
+
 	/* Otherwise search for firmware to use */
 	for (i = 0; i < ARRAY_SIZE(fw_table); i++) {
 		if (fw_table[i].model != cardp->model)
-- 
1.7.2.5
