From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] bnx2: Fix reset bug on 5709
Date: Wed, 24 Nov 2010 15:48:54 -0800
Message-ID: <1290642535-20293-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4569 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367Ab0KYAox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 19:44:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <waie@broadcom.com>

The 5709 chip requires the BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE bit to be
cleared and polling for pending DMAs to complete before chip reset.
Without this step, we've seen NMIs during repeated resets of the chip.

Signed-off-by: Eddie Wai <waie@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   29 ++++++++++++++++++++++-------
 drivers/net/bnx2.h |    2 ++
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 062600b..83af01d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4645,13 +4645,28 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 	/* Wait for the current PCI transaction to complete before
 	 * issuing a reset. */
-	REG_WR(bp, BNX2_MISC_ENABLE_CLR_BITS,
-	       BNX2_MISC_ENABLE_CLR_BITS_TX_DMA_ENABLE |
-	       BNX2_MISC_ENABLE_CLR_BITS_DMA_ENGINE_ENABLE |
-	       BNX2_MISC_ENABLE_CLR_BITS_RX_DMA_ENABLE |
-	       BNX2_MISC_ENABLE_CLR_BITS_HOST_COALESCE_ENABLE);
-	val = REG_RD(bp, BNX2_MISC_ENABLE_CLR_BITS);
-	udelay(5);
+	if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
+	    (CHIP_NUM(bp) == CHIP_NUM_5708)) {
+		REG_WR(bp, BNX2_MISC_ENABLE_CLR_BITS,
+		       BNX2_MISC_ENABLE_CLR_BITS_TX_DMA_ENABLE |
+		       BNX2_MISC_ENABLE_CLR_BITS_DMA_ENGINE_ENABLE |
+		       BNX2_MISC_ENABLE_CLR_BITS_RX_DMA_ENABLE |
+		       BNX2_MISC_ENABLE_CLR_BITS_HOST_COALESCE_ENABLE);
+		val = REG_RD(bp, BNX2_MISC_ENABLE_CLR_BITS);
+		udelay(5);
+	} else {  /* 5709 */
+		val = REG_RD(bp, BNX2_MISC_NEW_CORE_CTL);
+		val &= ~BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE;
+		REG_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
+		val = REG_RD(bp, BNX2_MISC_NEW_CORE_CTL);
+
+		for (i = 0; i < 100; i++) {
+			msleep(1);
+			val = REG_RD(bp, BNX2_PCICFG_DEVICE_CONTROL);
+			if (!(val & BNX2_PCICFG_DEVICE_STATUS_NO_PEND))
+				break;
+		}
+	}
 
 	/* Wait for the firmware to tell us it is ok to issue a reset. */
 	bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT0 | reset_code, 1, 1);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index bf4c342..5488a2e 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -461,6 +461,8 @@ struct l2_fhdr {
 #define BNX2_PCICFG_MAILBOX_QUEUE_ADDR			0x00000090
 #define BNX2_PCICFG_MAILBOX_QUEUE_DATA			0x00000094
 
+#define BNX2_PCICFG_DEVICE_CONTROL			0x000000b4
+#define BNX2_PCICFG_DEVICE_STATUS_NO_PEND		 ((1L<<5)<<16)
 
 /*
  *  pci_reg definition
-- 
1.6.4.GIT


