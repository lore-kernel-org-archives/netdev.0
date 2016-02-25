From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] mt7601u: do not free dma_buf when ivp allocation fails
Date: Thu, 25 Feb 2016 23:09:59 +0000
Message-ID: <1456441799-19266-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>, Kalle Valo <kvalo@codeaurora.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

If the allocation of ivp fails the error handling attempts to
free an uninitialized dma_buf; this data structure just contains
garbage on the stack, so the freeing will cause issues when the
urb, buf and dma fields are free'd. Fix this by not free'ing the
dma_buf if the ivp allocation fails.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/mediatek/mt7601u/mcu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mediatek/mt7601u/mcu.c b/drivers/net/wireless/mediatek/mt7601u/mcu.c
index fbb1986..70e4b5e 100644
--- a/drivers/net/wireless/mediatek/mt7601u/mcu.c
+++ b/drivers/net/wireless/mediatek/mt7601u/mcu.c
@@ -362,10 +362,10 @@ mt7601u_upload_firmware(struct mt7601u_dev *dev, const struct mt76_fw *fw)
 	int i, ret;
 
 	ivb = kmemdup(fw->ivb, sizeof(fw->ivb), GFP_KERNEL);
-	if (!ivb || mt7601u_usb_alloc_buf(dev, MCU_FW_URB_SIZE, &dma_buf)) {
-		ret = -ENOMEM;
+	if (!ivb)
+		return -ENOMEM;
+	if (mt7601u_usb_alloc_buf(dev, MCU_FW_URB_SIZE, &dma_buf))
 		goto error;
-	}
 
 	ilm_len = le32_to_cpu(fw->hdr.ilm_len) - sizeof(fw->ivb);
 	dev_dbg(dev->dev, "loading FW - ILM %u + IVB %zu\n",
-- 
2.7.0
