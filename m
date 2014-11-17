From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/4] igb: refactor time sync interrupt handling
Date: Tue, 18 Nov 2014 00:06:22 +0100
Message-ID: <da1c3df5841c4aae59e5eda739b7786ff46e3248.1416265321.git.richardcochran@gmail.com>
References: <cover.1416265321.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:62687 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbaKQXGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 18:06:32 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so10788451wiw.16
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 15:06:31 -0800 (PST)
In-Reply-To: <cover.1416265321.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code that handles the time sync interrupt is repeated in three
different places. This patch refactors the identical code blocks into
a single helper function.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   49 +++++++++++------------------
 1 file changed, 19 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b0e12e7..7183a56 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5383,6 +5383,19 @@ void igb_update_stats(struct igb_adapter *adapter,
 	}
 }
 
+static void igb_tsync_interrupt(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 tsicr = rd32(E1000_TSICR);
+
+	if (tsicr & E1000_TSICR_TXTS) {
+		/* acknowledge the interrupt */
+		wr32(E1000_TSICR, E1000_TSICR_TXTS);
+		/* retrieve hardware timestamp */
+		schedule_work(&adapter->ptp_tx_work);
+	}
+}
+
 static irqreturn_t igb_msix_other(int irq, void *data)
 {
 	struct igb_adapter *adapter = data;
@@ -5414,16 +5427,8 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (icr & E1000_ICR_TS) {
-		u32 tsicr = rd32(E1000_TSICR);
-
-		if (tsicr & E1000_TSICR_TXTS) {
-			/* acknowledge the interrupt */
-			wr32(E1000_TSICR, E1000_TSICR_TXTS);
-			/* retrieve hardware timestamp */
-			schedule_work(&adapter->ptp_tx_work);
-		}
-	}
+	if (icr & E1000_ICR_TS)
+		igb_tsync_interrupt(adapter);
 
 	wr32(E1000_EIMS, adapter->eims_other);
 
@@ -6202,16 +6207,8 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (icr & E1000_ICR_TS) {
-		u32 tsicr = rd32(E1000_TSICR);
-
-		if (tsicr & E1000_TSICR_TXTS) {
-			/* acknowledge the interrupt */
-			wr32(E1000_TSICR, E1000_TSICR_TXTS);
-			/* retrieve hardware timestamp */
-			schedule_work(&adapter->ptp_tx_work);
-		}
-	}
+	if (icr & E1000_ICR_TS)
+		igb_tsync_interrupt(adapter);
 
 	napi_schedule(&q_vector->napi);
 
@@ -6256,16 +6253,8 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (icr & E1000_ICR_TS) {
-		u32 tsicr = rd32(E1000_TSICR);
-
-		if (tsicr & E1000_TSICR_TXTS) {
-			/* acknowledge the interrupt */
-			wr32(E1000_TSICR, E1000_TSICR_TXTS);
-			/* retrieve hardware timestamp */
-			schedule_work(&adapter->ptp_tx_work);
-		}
-	}
+	if (icr & E1000_ICR_TS)
+		igb_tsync_interrupt(adapter);
 
 	napi_schedule(&q_vector->napi);
 
-- 
1.7.10.4
