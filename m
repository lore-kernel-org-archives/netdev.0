From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.21-rc5] bnx2: fix buffer overrun in
 bnx2_nvram_write
Date: Thu, 29 Mar 2007 17:27:00 -0800
Message-ID: <1175218020.7911.22.camel@dell>
References: <A6ACA33CD952BB47867438765C49F4F302370DF9@G3W0071.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Cureington, Tony" <tony.cureington@hp.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1994 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934387AbXC3AnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 20:43:07 -0400
In-Reply-To: <A6ACA33CD952BB47867438765C49F4F302370DF9@G3W0071.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-29 at 22:47 +0000, Cureington, Tony wrote:
> A buffer overrun issue exists in the bnx2_nvram_write function.

Tony, thanks for the patch.  The alignment logic is indeed still broken
despite trying to fix it before.  I think the following patch is better
in fixing the alignment logic.  I agree with you about moving the code
to erase the page, and that part of your patch is preserved.

[BNX2]: Fix nvram write logic.

The nvram dword alignment logic was broken when writing less than 4
bytes on a non-aligned offset.  It was missing logic to round the
length to 4 bytes.

The page erase code is also moved so that it is only called when
using non-buffered flash for better code clarity.

Update version to 1.5.7.

Based on initial patch from Tony Cureington <tony.cureington@hp.com>.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d43fe28..0b7aded 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.6"
-#define DRV_MODULE_RELDATE	"March 28, 2007"
+#define DRV_MODULE_VERSION	"1.5.7"
+#define DRV_MODULE_RELDATE	"March 29, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -3099,20 +3099,18 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 
 	if ((align_start = (offset32 & 3))) {
 		offset32 &= ~3;
-		len32 += (4 - align_start);
+		len32 += align_start;
+		if (len32 < 4)
+			len32 = 4;
 		if ((rc = bnx2_nvram_read(bp, offset32, start, 4)))
 			return rc;
 	}
 
 	if (len32 & 3) {
-	       	if ((len32 > 4) || !align_start) {
-			align_end = 4 - (len32 & 3);
-			len32 += align_end;
-			if ((rc = bnx2_nvram_read(bp, offset32 + len32 - 4,
-				end, 4))) {
-				return rc;
-			}
-		}
+		align_end = 4 - (len32 & 3);
+		len32 += align_end;
+		if ((rc = bnx2_nvram_read(bp, offset32 + len32 - 4, end, 4)))
+			return rc;
 	}
 
 	if (align_start || align_end) {
@@ -3187,17 +3185,17 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 		if ((rc = bnx2_enable_nvram_write(bp)) != 0)
 			goto nvram_write_end;
 
-		/* Erase the page */
-		if ((rc = bnx2_nvram_erase_page(bp, page_start)) != 0)
-			goto nvram_write_end;
-
-		/* Re-enable the write again for the actual write */
-		bnx2_enable_nvram_write(bp);
-
 		/* Loop to write back the buffer data from page_start to
 		 * data_start */
 		i = 0;
 		if (bp->flash_info->buffered == 0) {
+			/* Erase the page */
+			if ((rc = bnx2_nvram_erase_page(bp, page_start)) != 0)
+				goto nvram_write_end;
+
+			/* Re-enable the write again for the actual write */
+			bnx2_enable_nvram_write(bp);
+
 			for (addr = page_start; addr < data_start;
 				addr += 4, i += 4) {
 


