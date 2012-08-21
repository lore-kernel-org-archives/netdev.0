From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH -next v1] wireless: ath9k-htc: only load firmware in need
Date: Tue, 21 Aug 2012 16:04:27 +0800
Message-ID: <1345536267-9449-1-git-send-email-ming.lei@canonical.com>
Cc: netdev@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	ath9k-devel@lists.ath9k.org,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62310 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab2HUIEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 04:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not necessary to hold the firmware memory during the whole
driver lifetime, and obviously it does waste memory. Suppose there
are 4 ath9k-htc usb dongles working, kernel has to consume about
4*50KBytes RAM to cache firmware for all dongles. After applying the
patch, kernel only caches one single firmware image in RAM for
all ath9k-htc devices just during system suspend/resume cycle.

When system is ready for loading firmware, ath9k-htc can request
the loading from usersapce. During system resume, ath9k-htc still
can load the firmware which was cached in kernel memory before
system suspend.

Cc: ath9k-devel@lists.ath9k.org
Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
Cc: Jouni Malinen <jouni@qca.qualcomm.com>
Cc: Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>
Cc: Senthil Balasubramanian <senthilb@qca.qualcomm.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
v1:
	fix double free of firmware in failue path of
	ath9k_hif_usb_firmware_cb

This patch(just behaviour instead of build) depends on firmware
cache patch set which has entered -next tree already via driver core
tree.
---
 drivers/net/wireless/ath/ath9k/hif_usb.c |   33 ++++++++++++++++++++----------
 drivers/net/wireless/ath/ath9k/hif_usb.h |    4 +++-
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index aa327ad..ee6e50a 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -973,8 +973,8 @@ static void ath9k_hif_usb_dealloc_urbs(struct hif_device_usb *hif_dev)
 static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
 {
 	int transfer, err;
-	const void *data = hif_dev->firmware->data;
-	size_t len = hif_dev->firmware->size;
+	const void *data = hif_dev->fw_data;
+	size_t len = hif_dev->fw_size;
 	u32 addr = AR9271_FIRMWARE;
 	u8 *buf = kzalloc(4096, GFP_KERNEL);
 	u32 firm_offset;
@@ -1017,7 +1017,7 @@ static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
 		return -EIO;
 
 	dev_info(&hif_dev->udev->dev, "ath9k_htc: Transferred FW: %s, size: %ld\n",
-		 hif_dev->fw_name, (unsigned long) hif_dev->firmware->size);
+		 hif_dev->fw_name, (unsigned long) hif_dev->fw_size);
 
 	return 0;
 }
@@ -1099,11 +1099,11 @@ static void ath9k_hif_usb_firmware_cb(const struct firmware *fw, void *context)
 
 	hif_dev->htc_handle = ath9k_htc_hw_alloc(hif_dev, &hif_usb,
 						 &hif_dev->udev->dev);
-	if (hif_dev->htc_handle == NULL) {
-		goto err_fw;
-	}
+	if (hif_dev->htc_handle == NULL)
+		goto err_dev_alloc;
 
-	hif_dev->firmware = fw;
+	hif_dev->fw_data = fw->data;
+	hif_dev->fw_size = fw->size;
 
 	/* Proceed with initialization */
 
@@ -1121,6 +1121,8 @@ static void ath9k_hif_usb_firmware_cb(const struct firmware *fw, void *context)
 		goto err_htc_hw_init;
 	}
 
+	release_firmware(fw);
+	hif_dev->flags |= HIF_USB_READY;
 	complete(&hif_dev->fw_done);
 
 	return;
@@ -1129,8 +1131,8 @@ err_htc_hw_init:
 	ath9k_hif_usb_dev_deinit(hif_dev);
 err_dev_init:
 	ath9k_htc_hw_free(hif_dev->htc_handle);
+err_dev_alloc:
 	release_firmware(fw);
-	hif_dev->firmware = NULL;
 err_fw:
 	ath9k_hif_usb_firmware_fail(hif_dev);
 }
@@ -1277,11 +1279,10 @@ static void ath9k_hif_usb_disconnect(struct usb_interface *interface)
 
 	wait_for_completion(&hif_dev->fw_done);
 
-	if (hif_dev->firmware) {
+	if (hif_dev->flags & HIF_USB_READY) {
 		ath9k_htc_hw_deinit(hif_dev->htc_handle, unplugged);
 		ath9k_htc_hw_free(hif_dev->htc_handle);
 		ath9k_hif_usb_dev_deinit(hif_dev);
-		release_firmware(hif_dev->firmware);
 	}
 
 	usb_set_intfdata(interface, NULL);
@@ -1317,13 +1318,23 @@ static int ath9k_hif_usb_resume(struct usb_interface *interface)
 	struct hif_device_usb *hif_dev = usb_get_intfdata(interface);
 	struct htc_target *htc_handle = hif_dev->htc_handle;
 	int ret;
+	const struct firmware *fw;
 
 	ret = ath9k_hif_usb_alloc_urbs(hif_dev);
 	if (ret)
 		return ret;
 
-	if (hif_dev->firmware) {
+	if (hif_dev->flags & HIF_USB_READY) {
+		/* request cached firmware during suspend/resume cycle */
+		ret = request_firmware(&fw, hif_dev->fw_name,
+				       &hif_dev->udev->dev);
+		if (ret)
+			goto fail_resume;
+
+		hif_dev->fw_data = fw->data;
+		hif_dev->fw_size = fw->size;
 		ret = ath9k_hif_usb_download_fw(hif_dev);
+		release_firmware(fw);
 		if (ret)
 			goto fail_resume;
 	} else {
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.h b/drivers/net/wireless/ath/ath9k/hif_usb.h
index 487ff65..51496e7 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.h
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.h
@@ -85,12 +85,14 @@ struct cmd_buf {
 };
 
 #define HIF_USB_START BIT(0)
+#define HIF_USB_READY BIT(1)
 
 struct hif_device_usb {
 	struct usb_device *udev;
 	struct usb_interface *interface;
 	const struct usb_device_id *usb_device_id;
-	const struct firmware *firmware;
+	const void *fw_data;
+	size_t fw_size;
 	struct completion fw_done;
 	struct htc_target *htc_handle;
 	struct hif_usb_tx tx;
-- 
1.7.9.5
