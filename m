From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] i40vf: don't stop me now
Date: Mon,  9 Mar 2015 10:55:36 -0700
Message-ID: <1425923742-4488-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49812 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753402AbbCIRzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:45 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If a reset occurs when the netdev is closed, the reset task will hang in
napi_disable, causing deadlocks and general grumpiness.

Check to make sure the device is actually running before stopping
everything. This allows the reset task to complete and have a real good
time.

Change-ID: Iaaea84acbcb9b3810c216b14c3326e4287b75b58
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f44911d..32d0a99 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1578,13 +1578,14 @@ continue_reset:
 	adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
 
 	i40evf_irq_disable(adapter);
-	i40evf_napi_disable_all(adapter);
-
-	netif_tx_disable(netdev);
 
-	netif_tx_stop_all_queues(netdev);
+	if (netif_running(adapter->netdev)) {
+		i40evf_napi_disable_all(adapter);
+		netif_tx_disable(netdev);
+		netif_tx_stop_all_queues(netdev);
+		netif_carrier_off(netdev);
+	}
 
-	netif_carrier_off(netdev);
 	adapter->state = __I40EVF_RESETTING;
 
 	/* kill and reinit the admin queue */
-- 
1.9.3
