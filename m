From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] e1000e: Fix tight loop implementation of systime read algorithm
Date: Wed,  5 Aug 2015 16:52:14 -0700
Message-ID: <1438818735-38115-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55534 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753923AbbHEXwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:24 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

Change the algorithm. Read systimel twice and check for overflow.
If there was no overflow, use the first value.
If there was an overflow, read systimeh again and use the second
systimel value.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 31 ++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 24b7269..96a8166 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4280,18 +4280,29 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	struct e1000_adapter *adapter = container_of(cc, struct e1000_adapter,
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 systimel_1, systimel_2, systimeh;
 	cycle_t systim, systim_next;
-	/* SYSTIMH latching upon SYSTIML read does not work well. To fix that
-	 * we don't want to allow overflow of SYSTIML and a change to SYSTIMH
-	 * to occur between reads, so if we read a vale close to overflow, we
-	 * wait for overflow to occur and read both registers when its safe.
+	/* SYSTIMH latching upon SYSTIML read does not work well.
+	 * This means that if SYSTIML overflows after we read it but before
+	 * we read SYSTIMH, the value of SYSTIMH has been incremented and we
+	 * will experience a huge non linear increment in the systime value
+	 * to fix that we test for overflow and if true, we re-read systime.
 	 */
-	u32 systim_overflow_latch_fix = 0x3FFFFFFF;
-
-	do {
-		systim = (cycle_t)er32(SYSTIML);
-	} while (systim > systim_overflow_latch_fix);
-	systim |= (cycle_t)er32(SYSTIMH) << 32;
+	systimel_1 = er32(SYSTIML);
+	systimeh = er32(SYSTIMH);
+	systimel_2 = er32(SYSTIML);
+	/* Check for overflow. If there was no overflow, use the values */
+	if (systimel_1 < systimel_2) {
+		systim = (cycle_t)systimel_1;
+		systim |= (cycle_t)systimeh << 32;
+	} else {
+		/* There was an overflow, read again SYSTIMH, and use
+		 * systimel_2
+		 */
+		systimeh = er32(SYSTIMH);
+		systim = (cycle_t)systimel_2;
+		systim |= (cycle_t)systimeh << 32;
+	}
 
 	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
 		u64 incvalue, time_delta, rem, temp;
-- 
2.4.3
