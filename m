From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] igb: serialize access to the time sync interrupt registers
Date: Thu, 22 Jan 2015 18:37:03 -0800
Message-ID: <1421980631-1955-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557AbbAWChS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:18 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>

The time sync related interrupt registers may be manipulated from
different contexts. This patch protects the registers from being
asynchronously changed by the reset function.

Also, the patch removes a misleading comment. The reset function
is disabling a bunch of functions, not enabling them.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 5e7a4e3..8389bb4 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -900,6 +900,7 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 void igb_ptp_reset(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned long flags;
 
 	if (!(adapter->flags & IGB_FLAG_PTP))
 		return;
@@ -907,6 +908,8 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	/* reset the tstamp_config */
 	igb_ptp_set_timestamp_mode(adapter, &adapter->tstamp_config);
 
+	spin_lock_irqsave(&adapter->tmreg_lock, flags);
+
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
 		/* Dial the nominal frequency. */
@@ -917,23 +920,24 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	case e1000_i350:
 	case e1000_i210:
 	case e1000_i211:
-		/* Enable the timer functions and interrupts. */
 		wr32(E1000_TSAUXC, 0x0);
 		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
 		wr32(E1000_IMS, E1000_IMS_TS);
 		break;
 	default:
 		/* No work to do. */
-		return;
+		goto out;
 	}
 
 	/* Re-initialize the timer. */
 	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211)) {
 		struct timespec ts = ktime_to_timespec(ktime_get_real());
 
-		igb_ptp_settime_i210(&adapter->ptp_caps, &ts);
+		igb_ptp_write_i210(adapter, &ts);
 	} else {
 		timecounter_init(&adapter->tc, &adapter->cc,
 				 ktime_to_ns(ktime_get_real()));
 	}
+out:
+	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 }
-- 
1.9.3
