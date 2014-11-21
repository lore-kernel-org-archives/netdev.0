From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 2/4] igb: serialize access to the time sync interrupt registers.
Date: Fri, 21 Nov 2014 10:41:14 +0100
Message-ID: <8bf675043cb7f029c2cab11a6f0bd443e639c74d.1416562192.git.rcochran@linutronix.de>
References: <cover.1416562191.git.rcochran@linutronix.de>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>, Jian Yu <jian.yu@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:63568 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbaKUJlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 04:41:25 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so11424393wiw.8
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 01:41:23 -0800 (PST)
In-Reply-To: <cover.1416562191.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The time sync related interrupt registers may be manipulated from
different contexts. This patch protects the registers from being
asynchronously changed by the reset function.

Also, the patch removes a misleading comment. The reset function
is disabling a bunch of functions, not enabling them.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 794c139..d33252f 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -905,6 +905,7 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 void igb_ptp_reset(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned long flags;
 
 	if (!(adapter->flags & IGB_FLAG_PTP))
 		return;
@@ -912,6 +913,8 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	/* reset the tstamp_config */
 	igb_ptp_set_timestamp_mode(adapter, &adapter->tstamp_config);
 
+	spin_lock_irqsave(&adapter->tmreg_lock, flags);
+
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
 		/* Dial the nominal frequency. */
@@ -922,23 +925,24 @@ void igb_ptp_reset(struct igb_adapter *adapter)
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
1.7.10.4
