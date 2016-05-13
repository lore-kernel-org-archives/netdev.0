From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] e1000e: e1000e_cyclecounter_read(): do overflow check only if needed
Date: Fri, 13 May 2016 16:43:48 -0700
Message-ID: <1463183035-31888-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13874 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932193AbcEMXoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:44:01 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>

SYSTIMH:SYSTIML registers are incremented by 24-bit value TIMINCA[23..0]

er32(SYSTIML) are probably moderately expensive (they are pci bus reads).
Can we avoid one of them? Yes, we can.

If the SYSTIML value we see is smaller than 0xff000000, the overflow
into SYSTIMH would require at least two increments.

We do two reads, er32(SYSTIML) and er32(SYSTIMH), in this order.

Even if one increment happens between them, the overflow into SYSTIMH
is impossible, and we can avoid doing another er32(SYSTIML) read
and overflow check.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 02c64bc..0d3c00d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4275,7 +4275,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	struct e1000_adapter *adapter = container_of(cc, struct e1000_adapter,
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 systimel_1, systimel_2, systimeh;
+	u32 systimel, systimeh;
 	cycle_t systim, systim_next;
 	/* SYSTIMH latching upon SYSTIML read does not work well.
 	 * This means that if SYSTIML overflows after we read it but before
@@ -4283,21 +4283,21 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	 * will experience a huge non linear increment in the systime value
 	 * to fix that we test for overflow and if true, we re-read systime.
 	 */
-	systimel_1 = er32(SYSTIML);
+	systimel = er32(SYSTIML);
 	systimeh = er32(SYSTIMH);
-	systimel_2 = er32(SYSTIML);
-	/* Check for overflow. If there was no overflow, use the values */
-	if (systimel_1 <= systimel_2) {
-		systim = (cycle_t)systimel_1;
-		systim |= (cycle_t)systimeh << 32;
-	} else {
-		/* There was an overflow, read again SYSTIMH, and use
-		 * systimel_2
-		 */
-		systimeh = er32(SYSTIMH);
-		systim = (cycle_t)systimel_2;
-		systim |= (cycle_t)systimeh << 32;
+	/* Is systimel is so large that overflow is possible? */
+	if (systimel >= (u32)0xffffffff - E1000_TIMINCA_INCVALUE_MASK) {
+		u32 systimel_2 = er32(SYSTIML);
+		if (systimel > systimel_2) {
+			/* There was an overflow, read again SYSTIMH, and use
+			 * systimel_2
+			 */
+			systimeh = er32(SYSTIMH);
+			systimel = systimel_2;
+		}
 	}
+	systim = (cycle_t)systimel;
+	systim |= (cycle_t)systimeh << 32;
 
 	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
 		u64 time_delta, rem, temp;
-- 
2.5.5
