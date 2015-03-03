From: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] ath9k_htc: avoid memcpy when downloading firmware
Date: Tue,  3 Mar 2015 12:24:03 +0800
Message-ID: <1425356643-2707-1-git-send-email-fred.chou.nd@gmail.com>
Cc: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

The temporary buffer to hold firmware data is not really needed,
and memcpy can be avoided by using data pointer instead.

Signed-off-by: Fred Chou <fred.chou.nd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ath/ath9k/hif_usb.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 10c02f5..0bc35a8 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -986,30 +986,22 @@ static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
 	const void *data = hif_dev->fw_data;
 	size_t len = hif_dev->fw_size;
 	u32 addr = AR9271_FIRMWARE;
-	u8 *buf = kzalloc(4096, GFP_KERNEL);
 	u32 firm_offset;
 
-	if (!buf)
-		return -ENOMEM;
-
 	while (len) {
 		transfer = min_t(size_t, len, 4096);
-		memcpy(buf, data, transfer);
 
 		err = usb_control_msg(hif_dev->udev,
 				      usb_sndctrlpipe(hif_dev->udev, 0),
 				      FIRMWARE_DOWNLOAD, 0x40 | USB_DIR_OUT,
-				      addr >> 8, 0, buf, transfer, HZ);
-		if (err < 0) {
-			kfree(buf);
+				      addr >> 8, 0, data, transfer, HZ);
+		if (err < 0)
 			return err;
-		}
 
 		len -= transfer;
 		data += transfer;
 		addr += transfer;
 	}
-	kfree(buf);
 
 	if (IS_AR7010_DEVICE(hif_dev->usb_device_id->driver_info))
 		firm_offset = AR7010_FIRMWARE_TEXT;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
