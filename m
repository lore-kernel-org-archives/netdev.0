From: Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
Subject: [PATCH] rsi: Fix possible leak when loading firmware
Date: Fri, 21 Aug 2015 23:14:26 +0200
Message-ID: <1440191666-5104-1-git-send-email-cengelma@gmx.at>
Cc: khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, mike.looijmans-Oq418RWZeHk@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 5d5cd85ff441 ("rsi: Fix failure to load firmware after memory
leak fix and fix the leak") also added a check on the allocation of
DMA-accessible memory that may directly return. In that case the
already allocated firmware data is leaked. Make sure the data is
always freed correctly. Detected by Coverity CID 1316519.

Signed-off-by: Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
---
Compile tested only.
---
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 8 ++++++--
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c  | 8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
index 1c6788aecc62..40d72312f3df 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
@@ -203,8 +203,10 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 
 	/* Copy firmware into DMA-accessible memory */
 	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
-	if (!fw)
-		return -ENOMEM;
+	if (!fw) {
+		status = -ENOMEM;
+		goto out;
+	}
 	len = fw_entry->size;
 
 	if (len % 4)
@@ -217,6 +219,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 
 	status = rsi_copy_to_card(common, fw, len, num_blocks);
 	kfree(fw);
+
+out:
 	release_firmware(fw_entry);
 	return status;
 }
diff --git a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
index 30c2cf7fa93b..de4900862836 100644
--- a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
@@ -148,8 +148,10 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 
 	/* Copy firmware into DMA-accessible memory */
 	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
-	if (!fw)
-		return -ENOMEM;
+	if (!fw) {
+		status = -ENOMEM;
+		goto out;
+	}
 	len = fw_entry->size;
 
 	if (len % 4)
@@ -162,6 +164,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
 
 	status = rsi_copy_to_card(common, fw, len, num_blocks);
 	kfree(fw);
+
+out:
 	release_firmware(fw_entry);
 	return status;
 }
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
