From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mt7601u: do not free dma_buf when ivp allocation fails
Date: Thu, 25 Feb 2016 22:28:59 +0000
Message-ID: <1456439339-18458-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>, Kalle Valo <kvalo@codeaurora.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40862 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbcBYW3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:29:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

If the allocation of ivp fails the error handling attempts to
free an uninitialized dma_buf; this data structure just contains
garbage on the stack, so the freeing will cause issues when the
urb, buf and dma fields are cleaned. Fix this by handling the
ivp check and

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/mediatek/mt7601u/mcu.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/mediatek/mt7601u/mcu.c b/drivers/net/wireless/mediatek/mt7601u/mcu.c
index fbb1986..06ac657 100644
--- a/drivers/net/wireless/mediatek/mt7601u/mcu.c
+++ b/drivers/net/wireless/mediatek/mt7601u/mcu.c
@@ -359,13 +359,13 @@ mt7601u_upload_firmware(struct mt7601u_dev *dev, const struct mt76_fw *fw)
 	struct mt7601u_dma_buf dma_buf;
 	void *ivb;
 	u32 ilm_len, dlm_len;
-	int i, ret;
+	int i, ret = -ENOMEM;
 
 	ivb = kmemdup(fw->ivb, sizeof(fw->ivb), GFP_KERNEL);
-	if (!ivb || mt7601u_usb_alloc_buf(dev, MCU_FW_URB_SIZE, &dma_buf)) {
-		ret = -ENOMEM;
+	if (!ivb)
+		goto error_ivb;
+	if (mt7601u_usb_alloc_buf(dev, MCU_FW_URB_SIZE, &dma_buf))
 		goto error;
-	}
 
 	ilm_len = le32_to_cpu(fw->hdr.ilm_len) - sizeof(fw->ivb);
 	dev_dbg(dev->dev, "loading FW - ILM %u + IVB %zu\n",
@@ -396,8 +396,9 @@ mt7601u_upload_firmware(struct mt7601u_dev *dev, const struct mt76_fw *fw)
 
 	dev_dbg(dev->dev, "Firmware running!\n");
 error:
-	kfree(ivb);
 	mt7601u_usb_free_buf(dev, &dma_buf);
+error_ivb:
+	kfree(ivb);
 
 	return ret;
 }
-- 
2.7.0
