From: Patrick Schaaf <netdev@bof.de>
Subject: [PATCH] [BACKPORT] [3.14.56] bnx2x: Don't notify about scratchpad parities
Date: Thu, 05 Nov 2015 11:18:37 +0100
Message-ID: <2866398.tTChUFNQ37@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:34341 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031067AbbKEKSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 05:18:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Don't notify about scratchpad parities

This is a (trivial) "backport" of ad6afbe9578d1fa26680faf78c846bd8c00d1d6e to 
stable kernel 3.14.56.

Original commit message:

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

Signed-off-by: Patrick Schaaf <netdev@bof.de>
Tested-by: Patrick Schaaf <netdev@bof.de>

---

Related discussion + more info in http://marc.info/?l=linux-netdev&m=144663711626469

I experienced a production server network outage where over 1 million kernel 
messages were produced within 8 seconds. This change is supposed to suppress 
these messages.

I'm running the patched 3.14.56 on three production boxes now, and hope it 
helps should the original issue reoccur....

--- linux-3.14.56-vanilla/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h	
2015-10-27 01:46:24.000000000 +0100
+++ linux-3.14.56-eightball/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h	
2015-11-05 09:44:45.126824041 +0100
@@ -2401,10 +2401,13 @@
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
--- linux-3.14.56-vanilla/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	
2015-10-27 01:46:24.000000000 +0100
+++ linux-3.14.56-eightball/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	
2015-11-05 09:44:45.126824041 +0100
@@ -4631,9 +4631,7 @@
 				res |= true;
 				break;
 			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY:
-				if (print)
-					_print_next_block((*par_num)++,
-							  "MCP SCPAD");
+				(*par_num)++;
 				/* clear latched SCPAD PATIRY from MCP */
 				REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL,
 				       1UL << 10);
@@ -4695,6 +4693,7 @@
 	    (sig[3] & HW_PRTY_ASSERT_SET_3) ||
 	    (sig[4] & HW_PRTY_ASSERT_SET_4)) {
 		int par_num = 0;
+
 		DP(NETIF_MSG_HW, "Was parity error: HW block parity attention:\n"
 				 "[0]:0x%08x [1]:0x%08x [2]:0x%08x [3]:0x%08x [4]:0x%08x\n",
 			  sig[0] & HW_PRTY_ASSERT_SET_0,
@@ -4702,9 +4701,18 @@
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
