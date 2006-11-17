From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 10/17][BNX2]: Add 5709 reset and runtime code.
Date: Thu, 16 Nov 2006 19:05:53 -0800
Message-ID: <1163732753.6658.36.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:61962 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1424922AbWKQCN0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:13:26 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 5709 reset and runtime code.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index baad015..52fe620 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3247,31 +3247,44 @@ bnx2_reset_chip(struct bnx2 *bp, u32 res
 	 * before we issue a reset. */
 	val = REG_RD(bp, BNX2_MISC_ID);
 
-	val = BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
-	      BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
-	      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		REG_WR(bp, BNX2_MISC_COMMAND, BNX2_MISC_COMMAND_SW_RESET);
+		REG_RD(bp, BNX2_MISC_COMMAND);
+		udelay(5);
 
-	/* Chip reset. */
-	REG_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
+		val = BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
+		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
 
-	if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5706_A1))
-		msleep(15);
+		pci_write_config_dword(bp->pdev, BNX2_PCICFG_MISC_CONFIG, val);
 
-	/* Reset takes approximate 30 usec */
-	for (i = 0; i < 10; i++) {
-		val = REG_RD(bp, BNX2_PCICFG_MISC_CONFIG);
-		if ((val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
-			    BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) == 0) {
-			break;
+	} else {
+		val = BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
+		      BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
+		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
+
+		/* Chip reset. */
+		REG_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
+
+		if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
+		    (CHIP_ID(bp) == CHIP_ID_5706_A1)) {
+			current->state = TASK_UNINTERRUPTIBLE;
+			schedule_timeout(HZ / 50);
 		}
-		udelay(10);
-	}
 
-	if (val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
-		   BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) {
-		printk(KERN_ERR PFX "Chip reset did not complete\n");
-		return -EBUSY;
+		/* Reset takes approximate 30 usec */
+		for (i = 0; i < 10; i++) {
+			val = REG_RD(bp, BNX2_PCICFG_MISC_CONFIG);
+			if ((val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
+				    BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) == 0)
+				break;
+			udelay(10);
+		}
+
+		if (val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
+			   BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) {
+			printk(KERN_ERR PFX "Chip reset did not complete\n");
+			return -EBUSY;
+		}
 	}
 
 	/* Make sure byte swapping is properly configured. */
@@ -3976,8 +3989,8 @@ bnx2_run_loopback(struct bnx2 *bp, int l
 	bp->tx_prod = NEXT_TX_BD(bp->tx_prod);
 	bp->tx_prod_bseq += pkt_size;
 
-	REG_WR16(bp, MB_TX_CID_ADDR + BNX2_L2CTX_TX_HOST_BIDX, bp->tx_prod);
-	REG_WR(bp, MB_TX_CID_ADDR + BNX2_L2CTX_TX_HOST_BSEQ, bp->tx_prod_bseq);
+	REG_WR16(bp, bp->tx_bidx_addr, bp->tx_prod);
+	REG_WR(bp, bp->tx_bseq_addr, bp->tx_prod_bseq);
 
 	udelay(100);
 
@@ -4529,8 +4542,8 @@ bnx2_start_xmit(struct sk_buff *skb, str
 	prod = NEXT_TX_BD(prod);
 	bp->tx_prod_bseq += skb->len;
 
-	REG_WR16(bp, MB_TX_CID_ADDR + BNX2_L2CTX_TX_HOST_BIDX, prod);
-	REG_WR(bp, MB_TX_CID_ADDR + BNX2_L2CTX_TX_HOST_BSEQ, bp->tx_prod_bseq);
+	REG_WR16(bp, bp->tx_bidx_addr, prod);
+	REG_WR(bp, bp->tx_bseq_addr, bp->tx_prod_bseq);
 
 	mmiowb();
 


