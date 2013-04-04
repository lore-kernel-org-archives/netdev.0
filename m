From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] igb: Use rx/tx_itr_setting when setting up initial value of itr
Date: Thu,  4 Apr 2013 04:37:57 -0700
Message-ID: <1365075480-20183-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29187 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758871Ab3DDLiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:24 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It turns out that the InterruptThrottleRate module parameter was only
having the effect of locking the ITR at the starting ITR value. This was
because the values stored in rx_itr_setting and tx_itr_setting were being
ignored when configuring the initial itr_val of the q_vector.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6043245..615daa4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1179,6 +1179,17 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	/* initialize pointer to rings */
 	ring = q_vector->ring;
 
+	/* intialize ITR */
+	if (rxr_count) {
+		/* rx or rx/tx vector */
+		if (!adapter->rx_itr_setting || adapter->rx_itr_setting > 3)
+			q_vector->itr_val = adapter->rx_itr_setting;
+	} else {
+		/* tx only vector */
+		if (!adapter->tx_itr_setting || adapter->tx_itr_setting > 3)
+			q_vector->itr_val = adapter->tx_itr_setting;
+	}
+
 	if (txr_count) {
 		/* assign generic ring traits */
 		ring->dev = &adapter->pdev->dev;
-- 
1.7.11.7
