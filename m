From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] i40evf: resequence close operations
Date: Fri, 27 Mar 2015 03:02:49 -0700
Message-ID: <1427450573-13945-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13066 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbbC0KDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:03:10 -0400
In-Reply-To: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Call the netdev carrier off and TX disable functions first, before other
shutdown operations. This stops the stack from hitting us with
transmits while we're shutting down. Additionally, disable NAPI before
disabling interrupts, or the interrupt might get re-enabled
inappropriately. Finally, remove the call to netif_tx_stop_all_queues,
as it is redundant - the call to netif_tx_disable already did the same
thing.

Change-ID: I8b2dd25231b82817746cc256234a5eeeb4abaccc
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index da901f4..b08efaf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -971,8 +971,10 @@ void i40evf_down(struct i40evf_adapter *adapter)
 				&adapter->crit_section))
 		usleep_range(500, 1000);
 
-	i40evf_irq_disable(adapter);
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
 	i40evf_napi_disable_all(adapter);
+	i40evf_irq_disable(adapter);
 
 	/* remove all MAC filters */
 	list_for_each_entry(f, &adapter->mac_filter_list, list) {
@@ -995,13 +997,7 @@ void i40evf_down(struct i40evf_adapter *adapter)
 		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 		adapter->aq_required |= I40EVF_FLAG_AQ_DISABLE_QUEUES;
 	}
-	netif_tx_disable(netdev);
 
-	netif_tx_stop_all_queues(netdev);
-
-	msleep(20);
-
-	netif_carrier_off(netdev);
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 }
 
-- 
1.9.3
