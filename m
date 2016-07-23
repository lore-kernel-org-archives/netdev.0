From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 1/2] e1000e: factor out systim sanitization
Date: Sat, 23 Jul 2016 12:44:33 -0400
Message-ID: <1469292274-59237-2-git-send-email-jarod@redhat.com>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
 <1469292274-59237-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469292274-59237-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is prepatory work for an expanding list of adapter families that have
occasional ~10 hour clock jumps when being used for PTP. Factor out the
sanitization function and convert to a switch statement, rather than using
an if.

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 71 ++++++++++++++++++------------
 1 file changed, 44 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 41f32c0..955b294 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4303,6 +4303,42 @@ void e1000e_reinit_locked(struct e1000_adapter *adapter)
 }
 
 /**
+ * e1000e_sanitize_systim - sanitize raw cycle counter reads
+ * @hw: pointer to the HW structure
+ * @systim: cycle_t value read, sanitized and returned
+ *
+ * Errata for 82574/82583 possible bad bits read from SYSTIMH/L:
+ * check to see that the time is incrementing at a reasonable
+ * rate and is a multiple of incvalue.
+ **/
+static cycle_t e1000e_sanitize_systim(struct e1000_hw *hw, cycle_t systim)
+{
+	u64 time_delta, rem, temp;
+	cycle_t systim_next;
+	u32 incvalue;
+	int i;
+
+	incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
+	for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
+		/* latch SYSTIMH on read of SYSTIML */
+		systim_next = (cycle_t)er32(SYSTIML);
+		systim_next |= (cycle_t)er32(SYSTIMH) << 32;
+
+		time_delta = systim_next - systim;
+		temp = time_delta;
+		/* VMWare users have seen incvalue of zero, don't div / 0 */
+		rem = incvalue ? do_div(temp, incvalue) : (time_delta != 0);
+
+		systim = systim_next;
+
+		if ((time_delta < E1000_82574_SYSTIM_EPSILON) && (rem == 0))
+			break;
+	}
+
+	return systim;
+}
+
+/**
  * e1000e_cyclecounter_read - read raw cycle counter (used by time counter)
  * @cc: cyclecounter structure
  **/
@@ -4312,7 +4348,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 systimel, systimeh;
-	cycle_t systim, systim_next;
+	cycle_t systim;
 	/* SYSTIMH latching upon SYSTIML read does not work well.
 	 * This means that if SYSTIML overflows after we read it but before
 	 * we read SYSTIMH, the value of SYSTIMH has been incremented and we
@@ -4335,32 +4371,13 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	systim = (cycle_t)systimel;
 	systim |= (cycle_t)systimeh << 32;
 
-	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
-		u64 time_delta, rem, temp;
-		u32 incvalue;
-		int i;
-
-		/* errata for 82574/82583 possible bad bits read from SYSTIMH/L
-		 * check to see that the time is incrementing at a reasonable
-		 * rate and is a multiple of incvalue
-		 */
-		incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
-		for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
-			/* latch SYSTIMH on read of SYSTIML */
-			systim_next = (cycle_t)er32(SYSTIML);
-			systim_next |= (cycle_t)er32(SYSTIMH) << 32;
-
-			time_delta = systim_next - systim;
-			temp = time_delta;
-			/* VMWare users have seen incvalue of zero, don't div / 0 */
-			rem = incvalue ? do_div(temp, incvalue) : (time_delta != 0);
-
-			systim = systim_next;
-
-			if ((time_delta < E1000_82574_SYSTIM_EPSILON) &&
-			    (rem == 0))
-				break;
-		}
+	switch (hw->mac.type) {
+	case e1000_82574:
+	case e1000_82583:
+		systim = e1000e_sanitize_systim(hw, systim);
+		break;
+	default:
+		break;
 	}
 	return systim;
 }
-- 
1.8.3.1
