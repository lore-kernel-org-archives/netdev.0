From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] i40evf: protect against NULL msix_entries and q_vectors pointers
Date: Sat,  3 Dec 2016 01:19:26 -0800
Message-ID: <20161203091930.14268-15-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52572 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbcLCJU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:28 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Update the functions which free msix_entries and q_vectors so that they
are safe against NULL values. This allows calling code to not care
whether these have already been freed when disabling and freeing them.

Change-ID: I31bfd1c0da18023d971b618edc6fb049721f3298
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 420e545..ca85021 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -207,6 +207,9 @@ static void i40evf_misc_irq_disable(struct i40evf_adapter *adapter)
 {
 	struct i40e_hw *hw = &adapter->hw;
 
+	if (!adapter->msix_entries)
+		return;
+
 	wr32(hw, I40E_VFINT_DYN_CTL01, 0);
 
 	/* read flush */
@@ -654,6 +657,9 @@ static void i40evf_free_misc_irq(struct i40evf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	if (!adapter->msix_entries)
+		return;
+
 	free_irq(adapter->msix_entries[0].vector, netdev);
 }
 
@@ -1428,6 +1434,9 @@ static void i40evf_free_q_vectors(struct i40evf_adapter *adapter)
 	int q_idx, num_q_vectors;
 	int napi_vectors;
 
+	if (!adapter->q_vectors)
+		return;
+
 	num_q_vectors = adapter->num_msix_vectors - NONQ_VECS;
 	napi_vectors = adapter->num_active_queues;
 
@@ -1437,6 +1446,7 @@ static void i40evf_free_q_vectors(struct i40evf_adapter *adapter)
 			netif_napi_del(&q_vector->napi);
 	}
 	kfree(adapter->q_vectors);
+	adapter->q_vectors = NULL;
 }
 
 /**
@@ -2862,12 +2872,10 @@ static void i40evf_remove(struct pci_dev *pdev)
 		msleep(50);
 	}
 
-	if (adapter->msix_entries) {
-		i40evf_misc_irq_disable(adapter);
-		i40evf_free_misc_irq(adapter);
-		i40evf_reset_interrupt_capability(adapter);
-		i40evf_free_q_vectors(adapter);
-	}
+	i40evf_misc_irq_disable(adapter);
+	i40evf_free_misc_irq(adapter);
+	i40evf_reset_interrupt_capability(adapter);
+	i40evf_free_q_vectors(adapter);
 
 	if (adapter->watchdog_timer.function)
 		del_timer_sync(&adapter->watchdog_timer);
-- 
2.9.3
