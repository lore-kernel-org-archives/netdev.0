From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH 3/3] e1000e: e1000e_cyclecounter_read(): do overflow check only if needed
Date: Tue, 19 Apr 2016 14:34:46 +0200
Message-ID: <1461069286-31946-3-git-send-email-dvlasenk@redhat.com>
References: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Shannon Nelson <shannon.nelson@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: John Ronciak <john.ronciak@intel.com>
CC: Mitch Williams <mitch.a.williams@intel.com>
CC: David S. Miller <davem@davemloft.net>
CC: LKML <linux-kernel@vger.kernel.org>
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 99d0e6e..6f17f89 100644
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
1.8.1.4
