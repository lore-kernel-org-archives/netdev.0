From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] igb: Fix possible panic caused by Rx traffic arrival while interface is down
Date: Tue, 21 May 2013 15:03:17 -0700
Message-ID: <1369173800-20326-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53264 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940Ab3EUWDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:32 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch reorders disabling napi and irqs during igb_down.
This is done to avoid possible panic's found in other Intel drivers
when Rx traffic arrives while interface is going down.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2c8f7e0..6a0c1b6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1667,10 +1667,13 @@ void igb_down(struct igb_adapter *adapter)
 	wrfl();
 	msleep(10);
 
-	for (i = 0; i < adapter->num_q_vectors; i++)
+	igb_irq_disable(adapter);
+
+	for (i = 0; i < adapter->num_q_vectors; i++) {
+		napi_synchronize(&(adapter->q_vector[i]->napi));
 		napi_disable(&(adapter->q_vector[i]->napi));
+	}
 
-	igb_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
-- 
1.7.11.7
