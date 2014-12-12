From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] rsi: fix memory leak in rsi_load_ta_instructions()
Date: Sat, 13 Dec 2014 00:43:55 +0300
Message-ID: <1418420635-23869-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Fariya Fatima <fariyaf@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Memory allocated by kmemdup() in rsi_load_ta_instructions() is leaked.
But duplication of firmware data here is useless,
so the patch removes kmemdup() at all.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
index 4834a9abc171..b6cc9ff47fc2 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
@@ -172,7 +172,6 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		(struct rsi_91x_sdiodev *)adapter->rsi_dev;
 	u32 len;
 	u32 num_blocks;
-	const u8 *fw;
 	const struct firmware *fw_entry = NULL;
 	u32 block_size = dev->tx_blk_size;
 	int status = 0;
@@ -201,7 +200,6 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 		return status;
 	}
 
-	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
 	len = fw_entry->size;
 
 	if (len % 4)
@@ -212,7 +210,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 	rsi_dbg(INIT_ZONE, "%s: Instruction size:%d\n", __func__, len);
 	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
 
-	status = rsi_copy_to_card(common, fw, len, num_blocks);
+	status = rsi_copy_to_card(common, fw_entry->data, len, num_blocks);
 	release_firmware(fw_entry);
 	return status;
 }
-- 
1.9.1
