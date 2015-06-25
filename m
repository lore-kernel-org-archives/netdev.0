From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 4/9] bnx2x: Don't notify about scratchpad parities
Date: Thu, 25 Jun 2015 15:19:24 +0300
Message-ID: <1435234769-5625-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Manish Chopra <Manish.Chopra@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41159 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751940AbbFYMUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:06 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@qlogic.com>

The scratchpad is a shared block between all functions of a given device.
Due to HW limitations, we can't properly close its parity notifications
to all functions on legal flows.
E.g., it's possible that while taking a register dump from one function
a parity error would be triggered on other functions.

Today driver doesn't consider this parity as a 'real' parity unless its
being accompanied by additional indications [which would happen in a real
parity scenario]; But it does print notifications for such events in the
system logs.

This eliminates such prints - in case of real parities driver would have
additional indications; But if this is the only signal user will not even
see a parity being logged in the system.

Signed-off-by: Manish Chopra <Manish.Chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 11 +++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 20 ++++++++++++++------
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 1f82a04..8466c6c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2408,10 +2408,13 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 				 AEU_INPUTS_ATTN_BITS_IGU_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR)
 
-#define HW_PRTY_ASSERT_SET_3 (AEU_INPUTS_ATTN_BITS_MCP_LATCHED_ROM_PARITY | \
-		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_RX_PARITY | \
-		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY | \
-		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY)
+#define HW_PRTY_ASSERT_SET_3_WITHOUT_SCPAD \
+		(AEU_INPUTS_ATTN_BITS_MCP_LATCHED_ROM_PARITY | \
+		 AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_RX_PARITY | \
+		 AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY)
+
+#define HW_PRTY_ASSERT_SET_3 (HW_PRTY_ASSERT_SET_3_WITHOUT_SCPAD | \
+			      AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY)
 
 #define HW_PRTY_ASSERT_SET_4 (AEU_INPUTS_ATTN_BITS_PGLUE_PARITY_ERROR | \
 			      AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index bf5f5df..9628595 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4863,9 +4863,7 @@ static bool bnx2x_check_blocks_with_parity3(struct bnx2x *bp, u32 sig,
 				res = true;
 				break;
 			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY:
-				if (print)
-					_print_next_block((*par_num)++,
-							  "MCP SCPAD");
+				(*par_num)++;
 				/* clear latched SCPAD PATIRY from MCP */
 				REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL,
 				       1UL << 10);
@@ -4927,6 +4925,7 @@ static bool bnx2x_parity_attn(struct bnx2x *bp, bool *global, bool print,
 	    (sig[3] & HW_PRTY_ASSERT_SET_3) ||
 	    (sig[4] & HW_PRTY_ASSERT_SET_4)) {
 		int par_num = 0;
+
 		DP(NETIF_MSG_HW, "Was parity error: HW block parity attention:\n"
 				 "[0]:0x%08x [1]:0x%08x [2]:0x%08x [3]:0x%08x [4]:0x%08x\n",
 			  sig[0] & HW_PRTY_ASSERT_SET_0,
@@ -4934,9 +4933,18 @@ static bool bnx2x_parity_attn(struct bnx2x *bp, bool *global, bool print,
 			  sig[2] & HW_PRTY_ASSERT_SET_2,
 			  sig[3] & HW_PRTY_ASSERT_SET_3,
 			  sig[4] & HW_PRTY_ASSERT_SET_4);
-		if (print)
-			netdev_err(bp->dev,
-				   "Parity errors detected in blocks: ");
+		if (print) {
+			if (((sig[0] & HW_PRTY_ASSERT_SET_0) ||
+			     (sig[1] & HW_PRTY_ASSERT_SET_1) ||
+			     (sig[2] & HW_PRTY_ASSERT_SET_2) ||
+			     (sig[4] & HW_PRTY_ASSERT_SET_4)) ||
+			     (sig[3] & HW_PRTY_ASSERT_SET_3_WITHOUT_SCPAD)) {
+				netdev_err(bp->dev,
+					   "Parity errors detected in blocks: ");
+			} else {
+				print = false;
+			}
+		}
 		res |= bnx2x_check_blocks_with_parity0(bp,
 			sig[0] & HW_PRTY_ASSERT_SET_0, &par_num, print);
 		res |= bnx2x_check_blocks_with_parity1(bp,
-- 
1.9.3
