From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 14/14] i40evf: Fixed guest OS panic when removing vf driver
Date: Fri,  1 Aug 2014 13:27:15 -0700
Message-ID: <1406924835-31550-15-git-send-email-aaron.f.brown@intel.com>
References: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Cc: Serey Kong <serey.kong@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60887 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756254AbaHAUXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 16:23:31 -0400
In-Reply-To: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serey Kong <serey.kong@intel.com>

Removing VF driver during device still in reset caused guest OS panic.

in the i40evf_remove(), we're trying to clean mac_filter_list which has
not been initialized since the device is still stuck at the reset.
The change is to initialize the filter_list before setting any task.

Change-ID: I8b59df7384416c7e6f2d264b598f447e1c2c92b0
Signed-off-by: Serey Kong <serey.kong@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e5679d8..ab15f4d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2137,8 +2137,6 @@ static void i40evf_init_task(struct work_struct *work)
 	ether_addr_copy(netdev->dev_addr, adapter->hw.mac.addr);
 	ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 
-	INIT_LIST_HEAD(&adapter->mac_filter_list);
-	INIT_LIST_HEAD(&adapter->vlan_filter_list);
 	f = kzalloc(sizeof(*f), GFP_ATOMIC);
 	if (NULL == f)
 		goto err_sw_init;
@@ -2320,6 +2318,9 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->bus.device = PCI_SLOT(pdev->devfn);
 	hw->bus.func = PCI_FUNC(pdev->devfn);
 
+	INIT_LIST_HEAD(&adapter->mac_filter_list);
+	INIT_LIST_HEAD(&adapter->vlan_filter_list);
+
 	INIT_WORK(&adapter->reset_task, i40evf_reset_task);
 	INIT_WORK(&adapter->adminq_task, i40evf_adminq_task);
 	INIT_WORK(&adapter->watchdog_task, i40evf_watchdog_task);
-- 
1.9.3
