From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] igb: restore PPS signal on igb_ptp_reset
Date: Thu, 22 Sep 2016 23:39:00 -0700
Message-ID: <1474612741-75681-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25937 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932633AbcIWGjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 02:39:06 -0400
In-Reply-To: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When a reset occurs, the PPS SYS_WRAP interrupt was not re-enabled which
resulted in disabling of the PPS signaling. Fix this by recording when
the interrupt is on and ensuring that we re-enable it every time we
reset.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h     | 1 +
 drivers/net/ethernet/intel/igb/igb_ptp.c | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 03fbe4b..d11093d 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -489,6 +489,7 @@ struct igb_adapter {
 	struct timecounter tc;
 	u32 tx_hwtstamp_timeouts;
 	u32 rx_hwtstamp_cleared;
+	bool pps_sys_wrap_on;
 
 	struct ptp_pin_desc sdp_config[IGB_N_SDP];
 	struct {
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 1dd14e1..a7895c4 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -591,6 +591,7 @@ static int igb_ptp_feature_enable_i210(struct ptp_clock_info *ptp,
 			tsim |= TSINTR_SYS_WRAP;
 		else
 			tsim &= ~TSINTR_SYS_WRAP;
+		igb->pps_sys_wrap_on = !!on;
 		wr32(E1000_TSIM, tsim);
 		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
 		return 0;
@@ -1235,7 +1236,9 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	case e1000_i211:
 		wr32(E1000_TSAUXC, 0x0);
 		wr32(E1000_TSSDP, 0x0);
-		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
+		wr32(E1000_TSIM,
+		     TSYNC_INTERRUPTS |
+		     (adapter->pps_sys_wrap_on ? TSINTR_SYS_WRAP : 0));
 		wr32(E1000_IMS, E1000_IMS_TS);
 		break;
 	default:
-- 
2.7.4
