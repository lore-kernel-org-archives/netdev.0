From: Mike Looijmans <mike.looijmans-Oq418RWZeHk@public.gmane.org>
Subject: [PATCH] rsi: Fix failure to load firmware after memory leak fix and fix the leak
Date: Mon, 27 Jul 2015 07:43:33 +0200
Message-ID: <1437975813-3285-1-git-send-email-mike.looijmans@topic.nl>
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mike Looijmans <mike.looijmans-Oq418RWZeHk@public.gmane.org>,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fixes commit eae79b4f3e82ca63a53478a161b190a0d38fe526 ("rsi: fix memory leak
in rsi_load_ta_instructions()") which stopped the driver from functioning.

Firmware data has been allocated using vmalloc(), resulting in memory
that cannot be used for DMA. Hence the firmware was first copied to a
buffer allocated with kmalloc() in the original code. This patch reverts
the commit and only calls "kfree()" to release the buffer after sending
the data. This fixes the memory leak without breaking the driver.

Add a comment to the kmemdup() calls to explain why this is done.

Tested on a Topic Miami-Florida board which contains the rsi SDIO chip.

Also added the same kfree() call to the USB glue driver. This was not
tested on actual hardware though, as I only have the SDIO version.

Signed-off-by: Mike Looijmans <mike.looijmans-Oq418RWZeHk@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 6 +++++-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c  | 2 ++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
index b6cc9ff..5c37a71 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
@@ -172,6 +172,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		(struct rsi_91x_sdiodev *)adapter->rsi_dev;
 	u32 len;
 	u32 num_blocks;
+	const u8 *fw;
 	const struct firmware *fw_entry = NULL;
 	u32 block_size = dev->tx_blk_size;
 	int status = 0;
@@ -200,6 +201,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		return status;
 	}
 
+	/* Copy firmware into DMA-accessible memory */
+	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
 	len = fw_entry->size;
 
 	if (len % 4)
@@ -210,7 +213,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 	rsi_dbg(INIT_ZONE, "%s: Instruction size:%d\n", __func__, len);
 	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
 
-	status = rsi_copy_to_card(common, fw_entry->data, len, num_blocks);
+	status = rsi_copy_to_card(common, fw, len, num_blocks);
+	kfree(fw);
 	release_firmware(fw_entry);
 	return status;
 }
diff --git a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
index 1106ce7..088e28e 100644
--- a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
@@ -146,6 +146,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		return status;
 	}
 
+	/* Copy firmware into DMA-accessible memory */
 	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
 	len = fw_entry->size;
 
@@ -158,6 +159,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
 
 	status = rsi_copy_to_card(common, fw, len, num_blocks);
+	kfree(fw);
 	release_firmware(fw_entry);
 	return status;
 }
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
