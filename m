From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] carl9170: fix leaks at failure path in carl9170_usb_probe()
Date: Fri, 27 Sep 2013 23:51:51 -0400
Message-ID: <1380340311-4630-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

carl9170_usb_probe() does not handle request_firmware_nowait() failure
that leads to several leaks in this case.
The patch adds all required deallocations.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/ath/carl9170/usb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 307bc0d..3c76de1 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -1076,8 +1076,14 @@ static int carl9170_usb_probe(struct usb_interface *intf,
 
 	carl9170_set_state(ar, CARL9170_STOPPED);
 
-	return request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
+	err = request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
 		&ar->udev->dev, GFP_KERNEL, ar, carl9170_usb_firmware_step2);
+	if (err) {
+		usb_put_dev(udev);
+		usb_put_dev(udev);
+		carl9170_free(ar);
+	}
+	return err;
 }
 
 static void carl9170_usb_disconnect(struct usb_interface *intf)
-- 
1.8.1.2
