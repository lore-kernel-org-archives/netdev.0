From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Fix UNDI driver unload
Date: Thu, 8 May 2014 12:34:31 +0300
Message-ID: <1399541671-740-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:42807 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753216AbaEHJeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 05:34:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 91ebb928b "bnx2x: Add support for Multi-Function UNDI" contains a bug
which prevent the emptying of the device's Rx buffers before reset.
As a result, on new boards it is likely HW will reach some fatal assertion
once its interfaces load after UNDI was previously loaded.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please apply this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b260913..86e2991 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10051,8 +10051,8 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
 #define BCM_5710_UNDI_FW_MF_MAJOR	(0x07)
 #define BCM_5710_UNDI_FW_MF_MINOR	(0x08)
 #define BCM_5710_UNDI_FW_MF_VERS	(0x05)
-#define BNX2X_PREV_UNDI_MF_PORT(p)	(0x1a150c + ((p) << 4))
-#define BNX2X_PREV_UNDI_MF_FUNC(f)	(0x1a184c + ((f) << 4))
+#define BNX2X_PREV_UNDI_MF_PORT(p) (BAR_TSTRORM_INTMEM + 0x150c + ((p) << 4))
+#define BNX2X_PREV_UNDI_MF_FUNC(f) (BAR_TSTRORM_INTMEM + 0x184c + ((f) << 4))
 static bool bnx2x_prev_unload_undi_fw_supports_mf(struct bnx2x *bp)
 {
 	u8 major, minor, version;
@@ -10352,6 +10352,7 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 	/* Reset should be performed after BRB is emptied */
 	if (reset_reg & MISC_REGISTERS_RESET_REG_1_RST_BRB1) {
 		u32 timer_count = 1000;
+		bool need_write = true;
 
 		/* Close the MAC Rx to prevent BRB from filling up */
 		bnx2x_prev_unload_close_mac(bp, &mac_vals);
@@ -10398,7 +10399,10 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 			 * cleaning methods - might be redundant but harmless.
 			 */
 			if (bnx2x_prev_unload_undi_fw_supports_mf(bp)) {
-				bnx2x_prev_unload_undi_mf(bp);
+				if (need_write) {
+					bnx2x_prev_unload_undi_mf(bp);
+					need_write = false;
+				}
 			} else if (prev_undi) {
 				/* If UNDI resides in memory,
 				 * manually increment it
-- 
1.8.1.4
