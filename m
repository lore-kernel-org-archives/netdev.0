From: "Michael Chan" <mchan@broadcom.com>
Subject: [2/4][BNX2]: Add delay before reading firmware version.
Date: Mon, 16 Jul 2007 13:07:32 -0700
Message-ID: <1184616452.17688.19.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4610 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877AbXGPTOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 15:14:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add delay before reading firmware version.

The management firmware may still be loading during bnx2_init_one()
because of the D3hot -> D0 transition and the firmware version may
not be available without waiting a bit.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 311c859..28399d8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4143,10 +4143,6 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	REG_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_EVENTS);
 
-	if (REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE) &
-	    BNX2_PORT_FEATURE_ASF_ENABLED)
-		bp->flags |= ASF_ENABLE_FLAG;
-
 	/* Initialize the receive filter. */
 	bnx2_set_rx_mode(bp->dev);
 
@@ -6645,6 +6641,18 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		if (i != 2)
 			bp->fw_version[j++] = '.';
 	}
+	if (REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE) &
+	    BNX2_PORT_FEATURE_ASF_ENABLED) {
+		bp->flags |= ASF_ENABLE_FLAG;
+
+		for (i = 0; i < 30; i++) {
+			reg = REG_RD_IND(bp, bp->shmem_base +
+					     BNX2_BC_STATE_CONDITION);
+			if (reg & BNX2_CONDITION_MFW_RUN_MASK)
+				break;
+			msleep(10);
+		}
+	}
 	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_BC_STATE_CONDITION);
 	reg &= BNX2_CONDITION_MFW_RUN_MASK;
 	if (reg != BNX2_CONDITION_MFW_RUN_UNKNOWN &&


