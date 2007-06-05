From: "Michael Chan" <mchan@broadcom.com>
Subject: [1/5][BNX2]: Fix netdev watchdog on 5708.
Date: Mon, 04 Jun 2007 17:00:03 -0700
Message-ID: <1181001603.5275.12.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3355 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754233AbXFDXQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:16:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix netdev watchdog on 5708.

There's a bug in the driver that only initializes half of the context
memory on the 5708.  Surprisingly, this works most of the time except
for some occasional netdev watchdogs when sending a lot of 64-byte
packets.  The fix is to add the missing code to initialize the 2nd
halves of all context memory.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 88b33c6..5d69e5b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1811,6 +1811,7 @@ bnx2_init_context(struct bnx2 *bp)
 	vcid = 96;
 	while (vcid) {
 		u32 vcid_addr, pcid_addr, offset;
+		int i;
 
 		vcid--;
 
@@ -1831,16 +1832,20 @@ bnx2_init_context(struct bnx2 *bp)
 			pcid_addr = vcid_addr;
 		}
 
-		REG_WR(bp, BNX2_CTX_VIRT_ADDR, 0x00);
-		REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
+		for (i = 0; i < (CTX_SIZE / PHY_CTX_SIZE); i++) {
+			vcid_addr += (i << PHY_CTX_SHIFT);
+			pcid_addr += (i << PHY_CTX_SHIFT);
 
-		/* Zero out the context. */
-		for (offset = 0; offset < PHY_CTX_SIZE; offset += 4) {
-			CTX_WR(bp, 0x00, offset, 0);
-		}
+			REG_WR(bp, BNX2_CTX_VIRT_ADDR, 0x00);
+			REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
 
-		REG_WR(bp, BNX2_CTX_VIRT_ADDR, vcid_addr);
-		REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
+			/* Zero out the context. */
+			for (offset = 0; offset < PHY_CTX_SIZE; offset += 4)
+				CTX_WR(bp, 0x00, offset, 0);
+
+			REG_WR(bp, BNX2_CTX_VIRT_ADDR, vcid_addr);
+			REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
+		}
 	}
 }
 


