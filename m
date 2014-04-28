From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40evf: fix panic on PF driver fail
Date: Mon, 28 Apr 2014 06:52:31 -0700
Message-ID: <1398693158-2815-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270AbaD1Nwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:46 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Fix a panic that would occur in the VF if the PF driver failed or was
removed from the host kernel. In this case, the VF driver calls
i40evf_close(), but this function does nothing because the driver is in
the resetting state. Because of this, the driver doesn't free its irqs
and causes a kernel panic when it tries to disable MSI-X.

Change-ID: If95644a89e554b4d7be0dca1b6add26f63047129
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index da6054c..d7abd0d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -25,6 +25,8 @@
 #include "i40e_prototype.h"
 static int i40evf_setup_all_tx_resources(struct i40evf_adapter *adapter);
 static int i40evf_setup_all_rx_resources(struct i40evf_adapter *adapter);
+static void i40evf_free_all_tx_resources(struct i40evf_adapter *adapter);
+static void i40evf_free_all_rx_resources(struct i40evf_adapter *adapter);
 static int i40evf_close(struct net_device *netdev);
 
 char i40evf_driver_name[] = "i40evf";
@@ -1534,9 +1536,13 @@ static void i40evf_reset_task(struct work_struct *work)
 			rstat_val);
 		adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
 
-		if (netif_running(adapter->netdev))
-			i40evf_close(adapter->netdev);
-
+		if (netif_running(adapter->netdev)) {
+			set_bit(__I40E_DOWN, &adapter->vsi.state);
+			i40evf_down(adapter);
+			i40evf_free_traffic_irqs(adapter);
+			i40evf_free_all_tx_resources(adapter);
+			i40evf_free_all_rx_resources(adapter);
+		}
 		i40evf_free_misc_irq(adapter);
 		i40evf_reset_interrupt_capability(adapter);
 		i40evf_free_queues(adapter);
-- 
1.9.0
