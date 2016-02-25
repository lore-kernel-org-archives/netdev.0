From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH][V3] mt7601u: do not free dma_buf when ivp allocation fails
Date: Thu, 25 Feb 2016 23:24:27 +0000
Message-ID: <1456442667-19751-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jakub Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

If the allocation of ivp fails the error handling attempts to
free an uninitialized dma_buf; this data structure just contains
garbage on the stack, so the freeing will cause issues when the
urb, buf and dma fields are free'd. Fix this by not free'ing the
dma_buf if the ivp allocation fails.

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/mediatek/mt7601u/mcu.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mediatek/mt7601u/mcu.c b/drivers/net/wireless/mediatek/mt7601u/mcu.c
index fbb1986..91c4b34 100644
--- a/drivers/net/wireless/mediatek/mt7601u/mcu.c
+++ b/drivers/net/wireless/mediatek/mt7601u/mcu.c
@@ -362,7 +362,9 @@ mt7601u_upload_firmware(struct mt7601u_dev *dev, const struct mt76_fw *fw)
 	int i, ret;
 
 	ivb = kmemdup(fw->ivb, sizeof(fw->ivb), GFP_KERNEL);
-	if (!ivb || mt7601u_usb_alloc_buf(dev, MCU_FW_URB_SIZE, &dma_buf)) {
+	if (!ivb)
+		return -ENOMEM;
+	if (mt7601u_usb_alloc_buf(dev, MCU_FW_URB_SIZE, &dma_buf)) {
 		ret = -ENOMEM;
 		goto error;
 	}
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
