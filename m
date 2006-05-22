From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.17 2/2] bnx2: Use kmalloc instead of array
Date: Mon, 22 May 2006 10:02:03 -0700
Message-ID: <1148317323.4780.117.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:27407 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751017AbWEVSly
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 14:41:54 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kmalloc() instead of a local array in bnx2_nvram_write().

Update version to 1.4.40.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 509f104..54161ae 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -55,8 +55,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4.39"
-#define DRV_MODULE_RELDATE	"March 22, 2006"
+#define DRV_MODULE_VERSION	"1.4.40"
+#define DRV_MODULE_RELDATE	"May 22, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -2945,7 +2945,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 		int buf_size)
 {
 	u32 written, offset32, len32;
-	u8 *buf, start[4], end[4];
+	u8 *buf, start[4], end[4], *flash_buffer = NULL;
 	int rc = 0;
 	int align_start, align_end;
 
@@ -2985,12 +2985,19 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 		memcpy(buf + align_start, data_buf, buf_size);
 	}
 
+	if (bp->flash_info->buffered == 0) {
+		flash_buffer = kmalloc(264, GFP_KERNEL);
+		if (flash_buffer == NULL) {
+			rc = -ENOMEM;
+			goto nvram_write_end;
+		}
+	}
+
 	written = 0;
 	while ((written < len32) && (rc == 0)) {
 		u32 page_start, page_end, data_start, data_end;
 		u32 addr, cmd_flags;
 		int i;
-		u8 flash_buffer[264];
 
 	        /* Find the page_start addr */
 		page_start = offset32 + written;
@@ -3109,6 +3116,9 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 	}
 
 nvram_write_end:
+	if (bp->flash_info->buffered == 0)
+		kfree(flash_buffer);
+
 	if (align_start || align_end)
 		kfree(buf);
 	return rc;


