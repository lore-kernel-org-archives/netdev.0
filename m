From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 9/11] bnx2x: Rework power state handling
 code
Date: Mon, 19 Apr 2010 14:14:49 +0300
Message-ID: <1271675689.6900.281.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2305 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566Ab0DSLOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 07:14:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move "don't shut down the power" logic into bnx2x_set_power_state() to make the code cleaner.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d311476..2eb9a3b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -12017,6 +12017,14 @@ static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 		break;
 
 	case PCI_D3hot:
+		/* If there are other clients above don't
+		   shut down the power */
+		if (atomic_read(&bp->pdev->enable_cnt) != 1)
+			return 0;
+		/* Don't shut down the power for emulation and FPGA */
+		if (CHIP_REV_IS_SLOW(bp))
+			return 0;
+
 		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
 		pmcsr |= 3;
 
@@ -12629,9 +12637,7 @@ static int bnx2x_close(struct net_device *dev)
 
 	/* Unload the driver, release IRQs */
 	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
-	if (atomic_read(&bp->pdev->enable_cnt) == 1)
-		if (!CHIP_REV_IS_SLOW(bp))
-			bnx2x_set_power_state(bp, PCI_D3hot);
+	bnx2x_set_power_state(bp, PCI_D3hot);
 
 	return 0;
 }
-- 
1.6.3.3




