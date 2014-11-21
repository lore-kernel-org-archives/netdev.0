From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 3/4] igb: enable internal PPS for the i210.
Date: Fri, 21 Nov 2014 10:41:15 +0100
Message-ID: <56ad8ac5f82fef2c1696ece1de31cfc25185980a.1416562192.git.rcochran@linutronix.de>
References: <cover.1416562191.git.rcochran@linutronix.de>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>, Jian Yu <jian.yu@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:60112 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611AbaKUJl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 04:41:26 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so2104720wiv.2
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 01:41:25 -0800 (PST)
In-Reply-To: <cover.1416562191.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i210 device can produce an interrupt on the full second. This
patch allows using this interrupt to generate an internal PPS event
for adjusting the kernel system time.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   18 +++++++++++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c  |   32 +++++++++++++++++++++++++++--
 2 files changed, 45 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7183a56..5fe6e17 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5386,14 +5386,26 @@ void igb_update_stats(struct igb_adapter *adapter,
 static void igb_tsync_interrupt(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 tsicr = rd32(E1000_TSICR);
+	struct ptp_clock_event event;
+	u32 ack = 0, tsicr = rd32(E1000_TSICR);
+
+	if (tsicr & TSINTR_SYS_WRAP) {
+		event.type = PTP_CLOCK_PPS;
+		if (adapter->ptp_caps.pps)
+			ptp_clock_event(adapter->ptp_clock, &event);
+		else
+			dev_err(&adapter->pdev->dev, "unexpected SYS WRAP");
+		ack |= TSINTR_SYS_WRAP;
+	}
 
 	if (tsicr & E1000_TSICR_TXTS) {
-		/* acknowledge the interrupt */
-		wr32(E1000_TSICR, E1000_TSICR_TXTS);
 		/* retrieve hardware timestamp */
 		schedule_work(&adapter->ptp_tx_work);
+		ack |= E1000_TSICR_TXTS;
 	}
+
+	/* acknowledge the interrupts */
+	wr32(E1000_TSICR, ack);
 }
 
 static irqreturn_t igb_msix_other(int irq, void *data)
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index d33252f..526f4a6 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -360,6 +360,34 @@ static int igb_ptp_settime_i210(struct ptp_clock_info *ptp,
 	return 0;
 }
 
+static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
+				       struct ptp_clock_request *rq, int on)
+{
+	struct igb_adapter *igb =
+		container_of(ptp, struct igb_adapter, ptp_caps);
+	struct e1000_hw *hw = &igb->hw;
+	unsigned long flags;
+	u32 tsim;
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_PPS:
+		spin_lock_irqsave(&igb->tmreg_lock, flags);
+		tsim = rd32(E1000_TSIM);
+		if (on)
+			tsim |= TSINTR_SYS_WRAP;
+		else
+			tsim &= ~TSINTR_SYS_WRAP;
+		wr32(E1000_TSIM, tsim);
+		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+		return 0;
+
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
 static int igb_ptp_feature_enable(struct ptp_clock_info *ptp,
 				  struct ptp_clock_request *rq, int on)
 {
@@ -802,12 +830,12 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.owner = THIS_MODULE;
 		adapter->ptp_caps.max_adj = 62499999;
 		adapter->ptp_caps.n_ext_ts = 0;
-		adapter->ptp_caps.pps = 0;
+		adapter->ptp_caps.pps = 1;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82580;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_i210;
 		adapter->ptp_caps.gettime = igb_ptp_gettime_i210;
 		adapter->ptp_caps.settime = igb_ptp_settime_i210;
-		adapter->ptp_caps.enable = igb_ptp_feature_enable;
+		adapter->ptp_caps.enable = igb_ptp_feature_enable_i210;
 		/* Enable the timer functions by clearing bit 31. */
 		wr32(E1000_TSAUXC, 0x0);
 		break;
-- 
1.7.10.4
