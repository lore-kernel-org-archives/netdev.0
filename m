From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] igb: Free any held skb that should have been timestamped on remove
Date: Fri, 18 Jan 2013 07:04:46 -0800
Message-ID: <1358521487-28610-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35352 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756229Ab3ARPE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 10:04:58 -0500
In-Reply-To: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

To prevent a race condition where an skb has been saved to return the Tx
timestamp later and the driver is removed, add a check to determine if we
have an skb stored and, if so, free it.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Jacob Keller <Jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 2ec53d7..09f61a4 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -856,6 +856,10 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 	}
 
 	cancel_work_sync(&adapter->ptp_tx_work);
+	if (adapter->ptp_tx_skb) {
+		dev_kfree_skb_any(adapter->ptp_tx_skb);
+		adapter->ptp_tx_skb = NULL;
+	}
 
 	if (adapter->ptp_clock) {
 		ptp_clock_unregister(adapter->ptp_clock);
-- 
1.7.11.7
