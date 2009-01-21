From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 9/9] bnx2x: annotate nvram dword reading/writing
Date: Tue, 20 Jan 2009 21:50:51 -0800
Message-ID: <1232517051.9701.27.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:23543 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbZAUFvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:51:02 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4192305wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:51:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe this exposed an endian bug as the shifting of
bytes from the data buffer was done in cpu-order, then
masked into a be32 and the combined value was then converted
to cpu-order, this does all the masking in be-byteorder and
passes a cpu-ordered value to the write routine.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_main.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5e5e008..d0b0f6e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8011,7 +8011,7 @@ static void bnx2x_disable_nvram_access(struct bnx2x *bp)
 			MCPR_NVM_ACCESS_ENABLE_WR_EN)));
 }
 
-static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
+static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
 				  u32 cmd_flags)
 {
 	int count, i, rc;
@@ -8047,8 +8047,7 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
 			/* we read nvram data in cpu order
 			 * but ethtool sees it as an array of bytes
 			 * converting to big-endian will do the work */
-			val = cpu_to_be32(val);
-			*ret_val = val;
+			*ret_val = cpu_to_be32(val);
 			rc = 0;
 			break;
 		}
@@ -8062,7 +8061,7 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 {
 	int rc;
 	u32 cmd_flags;
-	u32 val;
+	__be32 val;
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(BNX2X_MSG_NVM,
@@ -8181,7 +8180,7 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	int rc;
 	u32 cmd_flags;
 	u32 align_offset;
-	u32 val;
+	__be32 val;
 
 	if (offset + buf_size > bp->common.flash_size) {
 		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
@@ -8203,14 +8202,12 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	rc = bnx2x_nvram_read_dword(bp, align_offset, &val, cmd_flags);
 
 	if (rc == 0) {
-		val &= ~(0xff << BYTE_OFFSET(offset));
-		val |= (*data_buf << BYTE_OFFSET(offset));
-
 		/* nvram data is returned as an array of bytes
 		 * convert it back to cpu order */
-		val = be32_to_cpu(val);
+		val &= ~cpu_to_be32(0xff << (8 * (offset & 0x03)));
+		val |= cpu_to_be32(*data_buf << (8 * (offset & 0x03)));
 
-		rc = bnx2x_nvram_write_dword(bp, align_offset, val,
+		rc = bnx2x_nvram_write_dword(bp, align_offset, be32_to_cpu(val),
 					     cmd_flags);
 	}
 
-- 
1.6.1.249.g455e5

