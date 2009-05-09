From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 2/4] netxen: fix irq tear down and msix leak.
Date: Sat,  9 May 2009 01:02:28 -0700
Message-ID: <1241856150-4488-2-git-send-email-dhananjay@netxen.com>
References: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48112 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751521AbZEIICb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 04:02:31 -0400
In-Reply-To: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Fix the order of irq and hardware context teardown.
  Also synchronize the interrupt in dev close() before
  releasing tx buffers.

o Fix possible msi-x vector leak if available vectors are
  less than requested.

o Request multiple msix vectors only if hardware supports
  multiple rx queues.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   74 +++++++++++++++++++--------------
 1 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index edb4bcd..c61c1d1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -175,12 +175,6 @@ netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 	struct nx_host_sds_ring *sds_ring;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
-	if ((adapter->flags & NETXEN_NIC_MSIX_ENABLED) &&
-			adapter->rss_supported)
-		adapter->max_sds_rings = (num_online_cpus() >= 4) ? 4 : 2;
-	else
-		adapter->max_sds_rings = 1;
-
 	if (netxen_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
 		return 1;
 
@@ -216,8 +210,9 @@ netxen_napi_disable(struct netxen_adapter *adapter)
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-		netxen_nic_disable_int(sds_ring);
 		napi_disable(&sds_ring->napi);
+		netxen_nic_disable_int(sds_ring);
+		synchronize_irq(sds_ring->irq);
 	}
 }
 
@@ -407,11 +402,11 @@ static void netxen_set_msix_bit(struct pci_dev *pdev, int enable)
 	}
 }
 
-static void netxen_init_msix_entries(struct netxen_adapter *adapter)
+static void netxen_init_msix_entries(struct netxen_adapter *adapter, int count)
 {
 	int i;
 
-	for (i = 0; i < MSIX_ENTRIES_PER_ADAPTER; i++)
+	for (i = 0; i < count; i++)
 		adapter->msix_entries[i].entry = i;
 }
 
@@ -496,6 +491,15 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 {
 	struct netxen_legacy_intr_set *legacy_intrp;
 	struct pci_dev *pdev = adapter->pdev;
+	int err, num_msix;
+
+	if (adapter->rss_supported) {
+		num_msix = (num_online_cpus() >= MSIX_ENTRIES_PER_ADAPTER) ?
+			MSIX_ENTRIES_PER_ADAPTER : 2;
+	} else
+		num_msix = 1;
+
+	adapter->max_sds_rings = 1;
 
 	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
 
@@ -512,26 +516,35 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 
 	if (adapter->msix_supported) {
 
-		netxen_init_msix_entries(adapter);
-		if (pci_enable_msix(pdev, adapter->msix_entries,
-					MSIX_ENTRIES_PER_ADAPTER))
-			goto request_msi;
+		netxen_init_msix_entries(adapter, num_msix);
+		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
+		if (err == 0) {
+			adapter->flags |= NETXEN_NIC_MSIX_ENABLED;
+			netxen_set_msix_bit(pdev, 1);
 
-		adapter->flags |= NETXEN_NIC_MSIX_ENABLED;
-		netxen_set_msix_bit(pdev, 1);
-		dev_info(&pdev->dev, "using msi-x interrupts\n");
+			if (adapter->rss_supported)
+				adapter->max_sds_rings = num_msix;
 
-	} else {
-request_msi:
-		if (use_msi && !pci_enable_msi(pdev)) {
-			adapter->flags |= NETXEN_NIC_MSI_ENABLED;
-			adapter->msi_tgt_status =
-				msi_tgt_status[adapter->ahw.pci_func];
-			dev_info(&pdev->dev, "using msi interrupts\n");
-		} else
-			dev_info(&pdev->dev, "using legacy interrupts\n");
-		adapter->msix_entries[0].vector = pdev->irq;
+			dev_info(&pdev->dev, "using msi-x interrupts\n");
+			return;
+		}
+
+		if (err > 0)
+			pci_disable_msix(pdev);
+
+		/* fall through for msi */
 	}
+
+	if (use_msi && !pci_enable_msi(pdev)) {
+		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
+		adapter->msi_tgt_status =
+			msi_tgt_status[adapter->ahw.pci_func];
+		dev_info(&pdev->dev, "using msi interrupts\n");
+		return;
+	}
+
+	dev_info(&pdev->dev, "using legacy interrupts\n");
+	adapter->msix_entries[0].vector = pdev->irq;
 }
 
 static void
@@ -767,7 +780,7 @@ netxen_nic_request_irq(struct netxen_adapter *adapter)
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-		sprintf(sds_ring->name, "%16s[%d]", netdev->name, ring);
+		sprintf(sds_ring->name, "%s[%d]", netdev->name, ring);
 		err = request_irq(sds_ring->irq, handler,
 				  flags, sds_ring->name, sds_ring);
 		if (err)
@@ -830,8 +843,6 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-	smp_mb();
-	netxen_napi_disable(adapter);
 
 	if (adapter->stop_port)
 		adapter->stop_port(adapter);
@@ -839,6 +850,8 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_p3_free_mac_list(adapter);
 
+	netxen_napi_disable(adapter);
+
 	netxen_release_tx_buffers(adapter);
 
 	FLUSH_SCHEDULED_WORK();
@@ -917,10 +930,9 @@ err_out_free_sw:
 static void
 netxen_nic_detach(struct netxen_adapter *adapter)
 {
-	netxen_nic_free_irq(adapter);
-
 	netxen_release_rx_buffers(adapter);
 	netxen_free_hw_resources(adapter);
+	netxen_nic_free_irq(adapter);
 	netxen_free_sw_resources(adapter);
 
 	adapter->is_up = 0;
-- 
1.6.0.2

