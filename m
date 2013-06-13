From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] orinoco_usb: fix memory leak in ezusb_access_ltv() when device disconnected
Date: Fri, 14 Jun 2013 00:26:11 +0400
Message-ID: <1371155171-15398-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If "device is disconnected" check occurs to be true in ezusb_access_ltv(),
it just return -ENODEV. But that means request_context is leaked since
there are no any references to it anymore.
The patch adds a call to ezusb_request_context_put() before return.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/orinoco/orinoco_usb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index 1f9cb55..bdfe637 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -881,7 +881,8 @@ static int ezusb_access_ltv(struct ezusb_priv *upriv,
 
 	if (!upriv->udev) {
 		dbg("Device disconnected");
-		return -ENODEV;
+		retval = -ENODEV;
+		goto exit;
 	}
 
 	if (upriv->read_urb->status != -EINPROGRESS)
-- 
1.8.1.2
