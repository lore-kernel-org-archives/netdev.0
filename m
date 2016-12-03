From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/18] i40evf: check for msix_entries null dereference
Date: Sat,  3 Dec 2016 01:19:23 -0800
Message-ID: <20161203091930.14268-12-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18542 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751668AbcLCJUm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:42 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

It is possible for msix_entries to be freed by a previous suspend/remove
before a VF is closed.  This patch fixes the issue by checking for NULL
before dereferencing msix_entries and returning early in the case where
it is NULL within the i40evf_close code path.  Without this patch it is
possible to trigger a kernel panic through NULL dereference.

Change-ID: I92a2746e82533a889e25f91578eac9abd0388ae2
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f04ac36..420e545 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -631,6 +631,9 @@ static void i40evf_free_traffic_irqs(struct i40evf_adapter *adapter)
 {
 	int vector, irq_num, q_vectors;
 
+	if (!adapter->msix_entries)
+		return;
+
 	q_vectors = adapter->num_msix_vectors - NONQ_VECS;
 
 	for (vector = 0; vector < q_vectors; vector++) {
@@ -1443,6 +1446,9 @@ static void i40evf_free_q_vectors(struct i40evf_adapter *adapter)
  **/
 void i40evf_reset_interrupt_capability(struct i40evf_adapter *adapter)
 {
+	if (!adapter->msix_entries)
+		return;
+
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
 	adapter->msix_entries = NULL;
-- 
2.9.3
