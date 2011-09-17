From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: cleanup some register reads
Date: Fri, 16 Sep 2011 19:15:50 -0700
Message-ID: <1316225752-1709-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com,
	Jonathan Lynch <jonathan.lynch@thenowfactory.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42810 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932223Ab1IQCQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:16:01 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Remove duplicate inc of hwstats->ruc
Introduce separate loops for 8 and 16 register reads.
Consolidate mac checks under one case.
Make sure registers are cleared on read.

Reported-by: Jonathan Lynch <jonathan.lynch@thenowfactory.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
CC: Jonathan Lynch <jonathan.lynch@thenowfactory.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   30 +++++++++++++++++-------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a4103ef..1e72c00 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5463,20 +5463,21 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	netdev->stats.tx_packets = packets;
 
 	hwstats->crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
+
+	/* 8 register reads */
 	for (i = 0; i < 8; i++) {
 		/* for packet buffers not used, the register should read 0 */
 		mpc = IXGBE_READ_REG(hw, IXGBE_MPC(i));
 		missed_rx += mpc;
 		hwstats->mpc[i] += mpc;
 		total_mpc += hwstats->mpc[i];
-		if (hw->mac.type == ixgbe_mac_82598EB)
-			hwstats->rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
-		hwstats->qptc[i] += IXGBE_READ_REG(hw, IXGBE_QPTC(i));
-		hwstats->qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
-		hwstats->qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
-		hwstats->qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
+		hwstats->pxontxc[i] += IXGBE_READ_REG(hw, IXGBE_PXONTXC(i));
+		hwstats->pxofftxc[i] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(i));
 		switch (hw->mac.type) {
 		case ixgbe_mac_82598EB:
+			hwstats->rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+			hwstats->qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
+			hwstats->qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
 			hwstats->pxonrxc[i] +=
 				IXGBE_READ_REG(hw, IXGBE_PXONRXC(i));
 			break;
@@ -5488,9 +5489,21 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		default:
 			break;
 		}
-		hwstats->pxontxc[i] += IXGBE_READ_REG(hw, IXGBE_PXONTXC(i));
-		hwstats->pxofftxc[i] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(i));
 	}
+
+	/*16 register reads */
+	for (i = 0; i < 16; i++) {
+		hwstats->qptc[i] += IXGBE_READ_REG(hw, IXGBE_QPTC(i));
+		hwstats->qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
+		if ((hw->mac.type == ixgbe_mac_82599EB) ||
+		    (hw->mac.type == ixgbe_mac_X540)) {
+			hwstats->qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC_L(i));
+			IXGBE_READ_REG(hw, IXGBE_QBTC_H(i)); /* to clear */
+			hwstats->qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC_L(i));
+			IXGBE_READ_REG(hw, IXGBE_QBRC_H(i)); /* to clear */
+		}
+	}
+
 	hwstats->gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
 	/* work around hardware counting issue */
 	hwstats->gprc -= missed_rx;
@@ -5550,7 +5563,6 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	hwstats->lxontxc += lxon;
 	lxoff = IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
 	hwstats->lxofftxc += lxoff;
-	hwstats->ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
 	hwstats->gptc += IXGBE_READ_REG(hw, IXGBE_GPTC);
 	hwstats->mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
 	/*
-- 
1.7.6
