From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] e1000e: 82574/82583 TimeSync errata for SYSTIM read
Date: Tue, 27 May 2014 02:12:25 -0700
Message-ID: <1401181951-31358-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaE0JMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:43 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Due to a synchronization error, the value read from SYSTIML/SYSTIMH
might be incorrect.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |  2 ++
 drivers/net/ethernet/intel/e1000e/netdev.c | 27 ++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index e27e609..63bde99 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -391,6 +391,8 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca);
  * 25MHz	46-bit	2^46 / 10^9 / 3600 = 19.55 hours
  */
 #define E1000_SYSTIM_OVERFLOW_PERIOD	(HZ * 60 * 60 * 4)
+#define E1000_MAX_82574_SYSTIM_REREADS	50
+#define E1000_82574_SYSTIM_EPSILON	(1ULL << 35ULL)
 
 /* hardware capability, feature, and workaround flags */
 #define FLAG_HAS_AMT                      (1 << 0)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6084e6b..95cf482 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4099,12 +4099,37 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	struct e1000_adapter *adapter = container_of(cc, struct e1000_adapter,
 						     cc);
 	struct e1000_hw *hw = &adapter->hw;
-	cycle_t systim;
+	cycle_t systim, systim_next;
 
 	/* latch SYSTIMH on read of SYSTIML */
 	systim = (cycle_t)er32(SYSTIML);
 	systim |= (cycle_t)er32(SYSTIMH) << 32;
 
+	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
+		u64 incvalue, time_delta, rem, temp;
+		int i;
+
+		/* errata for 82574/82583 possible bad bits read from SYSTIMH/L
+		 * check to see that the time is incrementing at a reasonable
+		 * rate and is a multiple of incvalue
+		 */
+		incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
+		for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
+			/* latch SYSTIMH on read of SYSTIML */
+			systim_next = (cycle_t)er32(SYSTIML);
+			systim_next |= (cycle_t)er32(SYSTIMH) << 32;
+
+			time_delta = systim_next - systim;
+			temp = time_delta;
+			rem = do_div(temp, incvalue);
+
+			systim = systim_next;
+
+			if ((time_delta < E1000_82574_SYSTIM_EPSILON) &&
+			    (rem == 0))
+				break;
+		}
+	}
 	return systim;
 }
 
-- 
1.9.3
