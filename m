From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 1/4] igb: refactor time sync interrupt handling
Date: Fri, 21 Nov 2014 10:41:13 +0100
Message-ID: <902603409eef76e3a0314e87e4a65097b977908b.1416562192.git.rcochran@linutronix.de>
References: <cover.1416562191.git.rcochran@linutronix.de>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>, Jian Yu <jian.yu@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:41415 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754845AbaKUJlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 04:41:22 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so8197084wiv.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 01:41:21 -0800 (PST)
In-Reply-To: <cover.1416562191.git.rcochran@linutronix.de>
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
