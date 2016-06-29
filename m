From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] igb: introduce IGB_PTP_OVERFLOW_CHECK flag
Date: Wed, 29 Jun 2016 14:32:55 -0700
Message-ID: <1467235982-55437-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52759 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbcF2VdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:08 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Don't continue to use complex MAC type checks for handling various cases
where we have overflow check code. Make this code more obvious by
introducing a flag which is enabled for hardware that needs these
checks.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h     |  1 +
 drivers/net/ethernet/intel/igb/igb_ptp.c | 21 ++++++++-------------
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 1e18a9e..38daaab 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -477,6 +477,7 @@ struct igb_adapter {
 
 /* flags controlling PTP/1588 function */
 #define IGB_PTP_ENABLED		BIT(0)
+#define IGB_PTP_OVERFLOW_CHECK	BIT(1)
 
 #define IGB_FLAG_HAS_MSI		BIT(0)
 #define IGB_FLAG_DCA_ENABLED		BIT(1)
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 504102b..88d367d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -1067,6 +1067,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->cc.shift = IGB_82576_TSYNC_SHIFT;
 		/* Dial the nominal frequency. */
 		wr32(E1000_TIMINCA, INCPERIOD_82576 | INCVALUE_82576);
+		adapter->ptp_flags |= IGB_PTP_OVERFLOW_CHECK;
 		break;
 	case e1000_82580:
 	case e1000_i354:
@@ -1087,6 +1088,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->cc.shift = 0;
 		/* Enable the timer functions by clearing bit 31. */
 		wr32(E1000_TSAUXC, 0x0);
+		adapter->ptp_flags |= IGB_PTP_OVERFLOW_CHECK;
 		break;
 	case e1000_i210:
 	case e1000_i211:
@@ -1132,7 +1134,9 @@ void igb_ptp_init(struct igb_adapter *adapter)
 	} else {
 		timecounter_init(&adapter->tc, &adapter->cc,
 				 ktime_to_ns(ktime_get_real()));
+	}
 
+	if (adapter->ptp_flags & IGB_PTP_OVERFLOW_CHECK) {
 		INIT_DELAYED_WORK(&adapter->ptp_overflow_work,
 				  igb_ptp_overflow_check);
 
@@ -1169,20 +1173,11 @@ void igb_ptp_init(struct igb_adapter *adapter)
  **/
 void igb_ptp_stop(struct igb_adapter *adapter)
 {
-	switch (adapter->hw.mac.type) {
-	case e1000_82576:
-	case e1000_82580:
-	case e1000_i354:
-	case e1000_i350:
-		cancel_delayed_work_sync(&adapter->ptp_overflow_work);
-		break;
-	case e1000_i210:
-	case e1000_i211:
-		/* No delayed work to cancel. */
-		break;
-	default:
+	if (!(adapter->ptp_flags & IGB_PTP_ENABLED))
 		return;
-	}
+
+	if (adapter->ptp_flags & IGB_PTP_OVERFLOW_CHECK)
+		cancel_delayed_work_sync(&adapter->ptp_overflow_work);
 
 	cancel_work_sync(&adapter->ptp_tx_work);
 	if (adapter->ptp_tx_skb) {
-- 
2.5.5
