From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2 3/4]: Fix bug in bnx2_nvram_write().
Date: Mon, 08 Jan 2007 15:56:48 -0800
Message-ID: <1168300608.4430.9.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3466 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161176AbXAHXKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 18:10:01 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix bug in bnx2_nvram_write().

The bug was a bogus pointer being passed to kfree().  The pointer was
incremented in the write loop and then passed to kfree().

The fix is to use align_buf to save the original address.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e325f93..08a77a3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3083,7 +3083,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 		int buf_size)
 {
 	u32 written, offset32, len32;
-	u8 *buf, start[4], end[4], *flash_buffer = NULL;
+	u8 *buf, start[4], end[4], *align_buf = NULL, *flash_buffer = NULL;
 	int rc = 0;
 	int align_start, align_end;
 
@@ -3111,16 +3111,17 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 	}
 
 	if (align_start || align_end) {
-		buf = kmalloc(len32, GFP_KERNEL);
-		if (buf == NULL)
+		align_buf = kmalloc(len32, GFP_KERNEL);
+		if (align_buf == NULL)
 			return -ENOMEM;
 		if (align_start) {
-			memcpy(buf, start, 4);
+			memcpy(align_buf, start, 4);
 		}
 		if (align_end) {
-			memcpy(buf + len32 - 4, end, 4);
+			memcpy(align_buf + len32 - 4, end, 4);
 		}
-		memcpy(buf + align_start, data_buf, buf_size);
+		memcpy(align_buf + align_start, data_buf, buf_size);
+		buf = align_buf;
 	}
 
 	if (bp->flash_info->buffered == 0) {
@@ -3254,11 +3255,8 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 	}
 
 nvram_write_end:
-	if (bp->flash_info->buffered == 0)
-		kfree(flash_buffer);
-
-	if (align_start || align_end)
-		kfree(buf);
+	kfree(flash_buffer);
+	kfree(align_buf);
 	return rc;
 }
 


