From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] e1000e: fix systim issues
Date: Wed,  3 Jun 2015 04:27:54 -0700
Message-ID: <1433330876-2658-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6485 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753662AbbFCL2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:07 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

Two issues involving systim were reported.
1. Clock is not running in the correct frequency
2. In some situations, systim values were not incremented linearly
This patch fixes the hardware clock configuration and the spurious
non-linear increment.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |  4 ++++
 drivers/net/ethernet/intel/e1000e/netdev.c | 37 +++++++++++++++++++++---------
 2 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index e78487a..7d8a45c 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -386,6 +386,10 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca);
 #define INCVALUE_SHIFT_25MHz	18
 #define INCPERIOD_25MHz		1
 
+#define INCVALUE_24MHz		125
+#define INCVALUE_SHIFT_24MHz	14
+#define INCPERIOD_24MHz		3
+
 /* Another drawback of scaling the incvalue by a large factor is the
  * 64-bit SYSTIM register overflows more quickly.  This is dealt with
  * by simply reading the clock before it overflows.
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 5f94fdf..b7035bc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3525,22 +3525,30 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca)
 	switch (hw->mac.type) {
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
-	case e1000_pch_spt:
-		/* On I217, I218 and I219, the clock frequency is 25MHz
-		 * or 96MHz as indicated by the System Clock Frequency
-		 * Indication
-		 */
-		if (((hw->mac.type != e1000_pch_lpt) &&
-		     (hw->mac.type != e1000_pch_spt)) ||
-		    (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI)) {
+		if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
 			/* Stable 96MHz frequency */
 			incperiod = INCPERIOD_96MHz;
 			incvalue = INCVALUE_96MHz;
 			shift = INCVALUE_SHIFT_96MHz;
 			adapter->cc.shift = shift + INCPERIOD_SHIFT_96MHz;
+		} else {
+			/* Stable 25MHz frequency */
+			incperiod = INCPERIOD_25MHz;
+			incvalue = INCVALUE_25MHz;
+			shift = INCVALUE_SHIFT_25MHz;
+			adapter->cc.shift = shift;
+		}
+		break;
+	case e1000_pch_spt:
+		if (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI) {
+			/* Stable 24MHz frequency */
+			incperiod = INCPERIOD_24MHz;
+			incvalue = INCVALUE_24MHz;
+			shift = INCVALUE_SHIFT_24MHz;
+			adapter->cc.shift = shift;
 			break;
 		}
-		/* fall-through */
+		return -EINVAL;
 	case e1000_82574:
 	case e1000_82583:
 		/* Stable 25MHz frequency */
@@ -4273,9 +4281,16 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
 	cycle_t systim, systim_next;
+	/* SYSTIMH latching upon SYSTIML read does not work well. To fix that
+	 * we don't want to allow overflow of SYSTIML and a change to SYSTIMH
+	 * to occur between reads, so if we read a vale close to overflow, we
+	 * wait for overflow to occur and read both registers when its safe.
+	 */
+	u32 systim_overflow_latch_fix = 0x3FFFFFFF;
 
-	/* latch SYSTIMH on read of SYSTIML */
-	systim = (cycle_t)er32(SYSTIML);
+	do {
+		systim = (cycle_t)er32(SYSTIML);
+	} while (systim > systim_overflow_latch_fix);
 	systim |= (cycle_t)er32(SYSTIMH) << 32;
 
 	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
-- 
2.1.0
