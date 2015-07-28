From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: [PATCH v2] rsi: Fix failure to load firmware after memory leak fix and fix the leak
Date: Tue, 28 Jul 2015 07:51:01 +0200
Message-ID: <1438062661-3173-1-git-send-email-mike.looijmans@topic.nl>
References: <1437975813-3285-1-git-send-email-mike.looijmans@topic.nl>
Cc: kvalo@codeaurora.org, khoroshilov@ispras.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Looijmans <mike.looijmans@topic.nl>,
	stable@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1437975813-3285-1-git-send-email-mike.looijmans@topic.nl>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes commit eae79b4f3e82 ("rsi: fix memory leak in rsi_load_ta_instructions()")
which stopped the driver from functioning.

Firmware data has been allocated using vmalloc(), resulting in memory
that cannot be used for DMA. Hence the firmware was first copied to a
buffer allocated with kmalloc() in the original code. This patch reverts
the commit and only calls "kfree()" to release the buffer after sending
the data. This fixes the memory leak without breaking the driver.

Add a comment to the kmemdup() calls to explain why this is done, and abort
if memory allocation fails.

Tested on a Topic Miami-Florida board which contains the rsi SDIO chip.

Also added the same kfree() call to the USB glue driver. This was not
tested on actual hardware though, as I only have the SDIO version.

Fixes: eae79b4f3e82 ("rsi: fix memory leak in rsi_load_ta_instructions()")
Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
Cc: stable@vger.kernel.org
---
v2: Add "Fixes:" header and abbreviate git hashes.
    Return -ENOMEM if kmemdup() fails.

 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 8 +++++++-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c  | 4 ++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
index b6cc9ff..1c6788a 100644
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
@@ -200,6 +201,10 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		return status;
 	}
 
+	/* Copy firmware into DMA-accessible memory */
+	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
+	if (!fw)
+		return -ENOMEM;
 	len = fw_entry->size;
 
 	if (len % 4)
@@ -210,7 +215,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 	rsi_dbg(INIT_ZONE, "%s: Instruction size:%d\n", __func__, len);
 	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
 
-	status = rsi_copy_to_card(common, fw_entry->data, len, num_blocks);
+	status = rsi_copy_to_card(common, fw, len, num_blocks);
+	kfree(fw);
 	release_firmware(fw_entry);
 	return status;
 }
diff --git a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
index 1106ce7..30c2cf7 100644
--- a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
@@ -146,7 +146,10 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		return status;
 	}
 
+	/* Copy firmware into DMA-accessible memory */
 	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
+	if (!fw)
+		return -ENOMEM;
 	len = fw_entry->size;
 
 	if (len % 4)
@@ -158,6 +161,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
 
 	status = rsi_copy_to_card(common, fw, len, num_blocks);
+	kfree(fw);
 	release_firmware(fw_entry);
 	return status;
 }
-- 
1.9.1
