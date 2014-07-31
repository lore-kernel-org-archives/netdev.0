From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 13/15] i40evf: don't leak queue vectors
Date: Wed, 30 Jul 2014 17:32:09 -0700
Message-ID: <1406766731-4209-14-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24422 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066AbaGaA2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:22 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Fix a memory leak. Driver was allocating memory for queue vectors on
init but not freeing them on shutdown. These need to be freed at two
different times: during module unload, and during reset recovery when
the driver cannot contact the PF driver and needs to give up.

Change-ID: I7c1d0157a776e960d4da432dfe309035aad7c670
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 2aca9cf..0c4f7baf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1542,6 +1542,7 @@ static void i40evf_reset_task(struct work_struct *work)
 		i40evf_free_misc_irq(adapter);
 		i40evf_reset_interrupt_capability(adapter);
 		i40evf_free_queues(adapter);
+		i40evf_free_q_vectors(adapter);
 		kfree(adapter->vf_res);
 		i40evf_shutdown_adminq(hw);
 		adapter->netdev->flags &= ~IFF_UP;
@@ -2429,6 +2430,7 @@ static void i40evf_remove(struct pci_dev *pdev)
 		i40evf_misc_irq_disable(adapter);
 		i40evf_free_misc_irq(adapter);
 		i40evf_reset_interrupt_capability(adapter);
+		i40evf_free_q_vectors(adapter);
 	}
 
 	if (adapter->watchdog_timer.function)
-- 
1.9.3
