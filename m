From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] igb: refactor time sync interrupt handling
Date: Thu, 22 Jan 2015 18:37:02 -0800
Message-ID: <1421980631-1955-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbbAWChS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:18 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>

The code that handles the time sync interrupt is repeated in three
different places. This patch refactors the identical code blocks into
a single helper function.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 49 ++++++++++++-------------------
 1 file changed, 19 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d1480f3..135ac5c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5384,6 +5384,19 @@ void igb_update_stats(struct igb_adapter *adapter,
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
@@ -5415,16 +5428,8 @@ static irqreturn_t igb_msix_other(int irq, void *data)
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
 
@@ -6203,16 +6208,8 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
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
 
@@ -6257,16 +6254,8 @@ static irqreturn_t igb_intr(int irq, void *data)
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
1.9.3
