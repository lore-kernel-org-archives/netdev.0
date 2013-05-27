From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/4] igb: refactor and simplify time sync interrupt handling
Date: Mon, 27 May 2013 11:21:42 +0200
Message-ID: <e81791002acaf082ace4ec7bb1fa24ab6633fd49.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	<e1000-devel@lists.sourceforge.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:32944 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203Ab3E0JVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 05:21:53 -0400
Received: by mail-ee0-f43.google.com with SMTP id d41so3863367eek.30
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 02:21:52 -0700 (PDT)
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code that handles the time sync interrupt is repeated in three
different places. This patch refactors the identical code blocks into
a single helper function. Also, reading the TSICR register already
acknowledges the time sync interrupts, and so there is no need to
write that register at all.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   47 +++++++++++------------------
 1 file changed, 17 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..d25a965 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5035,6 +5035,17 @@ void igb_update_stats(struct igb_adapter *adapter,
 	}
 }
 
+static void igb_tsync_interrupt(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 tsicr = rd32(E1000_TSICR);
+
+	if (tsicr & E1000_TSICR_TXTS) {
+		/* retrieve hardware timestamp */
+		schedule_work(&adapter->ptp_tx_work);
+	}
+}
+
 static irqreturn_t igb_msix_other(int irq, void *data)
 {
 	struct igb_adapter *adapter = data;
@@ -5066,16 +5077,8 @@ static irqreturn_t igb_msix_other(int irq, void *data)
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
 
@@ -5850,16 +5853,8 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
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
 
@@ -5904,16 +5899,8 @@ static irqreturn_t igb_intr(int irq, void *data)
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
