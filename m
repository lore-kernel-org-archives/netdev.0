From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 03/14] i40evf: fix multiple crashes on remove
Date: Fri, 14 Feb 2014 14:57:57 -0800
Message-ID: <1392418688-23895-4-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61878 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173AbaBNXBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:20 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Depending upon the state of the driver, there are several potential
pitfalls on remove. Kill the watchdog task so rmmod doesn't hang.
Check the adapter->msix_entries field, not the num_msix_vectors field,
which is never cleared.

Change-ID: I0546048477f09fc19e481bd37efa30daae4faa88
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 75a2c6f..e0eb27d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -215,6 +215,9 @@ static void i40evf_irq_disable(struct i40evf_adapter *adapter)
 	int i;
 	struct i40e_hw *hw = &adapter->hw;
 
+	if (!adapter->msix_entries)
+		return;
+
 	for (i = 1; i < adapter->num_msix_vectors; i++) {
 		wr32(hw, I40E_VFINT_DYN_CTLN1(i - 1), 0);
 		synchronize_irq(adapter->msix_entries[i].vector);
@@ -2372,17 +2375,15 @@ static void i40evf_remove(struct pci_dev *pdev)
 	}
 	adapter->state = __I40EVF_REMOVE;
 
-	if (adapter->num_msix_vectors) {
+	if (adapter->msix_entries) {
 		i40evf_misc_irq_disable(adapter);
-		del_timer_sync(&adapter->watchdog_timer);
-
-		flush_scheduled_work();
-
 		i40evf_free_misc_irq(adapter);
-
 		i40evf_reset_interrupt_capability(adapter);
 	}
 
+	del_timer_sync(&adapter->watchdog_timer);
+	flush_scheduled_work();
+
 	if (hw->aq.asq.count)
 		i40evf_shutdown_adminq(hw);
 
-- 
1.8.5.GIT
