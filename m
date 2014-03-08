From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] e1000e: PTP lock in e1000e_phc_adjustfreq
Date: Sat,  8 Mar 2014 01:25:27 -0800
Message-ID: <1394270741-29926-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbaCHJZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:44 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Add lock in e1000e_phc_adjfreq to prevent concurrent changes to TIMINCA
and SYSTIMH/L.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ptp.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 065f8c8..e24160d 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -47,6 +47,7 @@ static int e1000e_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 						     ptp_clock_info);
 	struct e1000_hw *hw = &adapter->hw;
 	bool neg_adj = false;
+	unsigned long flags;
 	u64 adjustment;
 	u32 timinca, incvalue;
 	s32 ret_val;
@@ -64,6 +65,8 @@ static int e1000e_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	if (ret_val)
 		return ret_val;
 
+	spin_lock_irqsave(&adapter->systim_lock, flags);
+
 	incvalue = timinca & E1000_TIMINCA_INCVALUE_MASK;
 
 	adjustment = incvalue;
@@ -77,6 +80,8 @@ static int e1000e_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 
 	ew32(TIMINCA, timinca);
 
+	spin_unlock_irqrestore(&adapter->systim_lock, flags);
+
 	return 0;
 }
 
-- 
1.8.3.1
