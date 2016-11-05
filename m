From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbevf: Handle previously-freed msix_entries
Date: Sat,  5 Nov 2016 00:54:21 -0700
Message-ID: <1478332461-43147-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:65478 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753944AbcKEHy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:28 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The msix_entries memory can be freed by a previous suspend or
remove, so don't crash on close when it isn't there. Also only
clear the interrupts when the interface is up, because there
aren't any when it is not up.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d2775f0..d316f50 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1498,6 +1498,9 @@ static void ixgbevf_free_irq(struct ixgbevf_adapter *adapter)
 {
 	int i, q_vectors;
 
+	if (!adapter->msix_entries)
+		return;
+
 	q_vectors = adapter->num_msix_vectors;
 	i = q_vectors - 1;
 
@@ -2552,6 +2555,9 @@ static void ixgbevf_free_q_vectors(struct ixgbevf_adapter *adapter)
  **/
 static void ixgbevf_reset_interrupt_capability(struct ixgbevf_adapter *adapter)
 {
+	if (!adapter->msix_entries)
+		return;
+
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
@@ -3794,11 +3800,10 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 		ixgbevf_free_irq(adapter);
 		ixgbevf_free_all_tx_resources(adapter);
 		ixgbevf_free_all_rx_resources(adapter);
+		ixgbevf_clear_interrupt_scheme(adapter);
 		rtnl_unlock();
 	}
 
-	ixgbevf_clear_interrupt_scheme(adapter);
-
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
 	if (retval)
-- 
2.7.4
