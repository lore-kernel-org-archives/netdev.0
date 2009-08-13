From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: free napi resources during detach
Date: Thu, 13 Aug 2009 10:03:01 -0700
Message-ID: <1250182981-27594-3-git-send-email-dhananjay@netxen.com>
References: <1250182981-27594-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:27273 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1753359AbZHMRDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 13:03:02 -0400
In-Reply-To: <1250182981-27594-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Defer napi resouce allocation to device attach.

o Free napi resources and delete napi during detach.

This ensures right behavior across firmware reset.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |    7 -------
 drivers/net/netxen/netxen_nic_main.c |   32 ++++++++++++++++++++++++--------
 2 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 7acf204..5d3343e 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -184,13 +184,6 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 	kfree(recv_ctx->rds_rings);
 
 skip_rds:
-	if (recv_ctx->sds_rings == NULL)
-		goto skip_sds;
-
-	for(ring = 0; ring < adapter->max_sds_rings; ring++)
-		recv_ctx->sds_rings[ring].consumer = 0;
-
-skip_sds:
 	if (adapter->tx_ring == NULL)
 		return;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index d24e1cb..28f270f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -167,6 +167,8 @@ netxen_free_sds_rings(struct netxen_recv_context *recv_ctx)
 {
 	if (recv_ctx->sds_rings != NULL)
 		kfree(recv_ctx->sds_rings);
+
+	recv_ctx->sds_rings = NULL;
 }
 
 static int
@@ -189,6 +191,21 @@ netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 }
 
 static void
+netxen_napi_del(struct netxen_adapter *adapter)
+{
+	int ring;
+	struct nx_host_sds_ring *sds_ring;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		netif_napi_del(&sds_ring->napi);
+	}
+
+	netxen_free_sds_rings(&adapter->recv_ctx);
+}
+
+static void
 netxen_napi_enable(struct netxen_adapter *adapter)
 {
 	int ring;
@@ -889,10 +906,12 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	struct nx_host_tx_ring *tx_ring;
 
 	err = netxen_init_firmware(adapter);
-	if (err != 0) {
-		printk(KERN_ERR "Failed to init firmware\n");
-		return -EIO;
-	}
+	if (err)
+		return err;
+
+	err = netxen_napi_add(adapter, netdev);
+	if (err)
+		return err;
 
 	if (adapter->fw_major < 4)
 		adapter->max_rds_rings = 3;
@@ -956,6 +975,7 @@ netxen_nic_detach(struct netxen_adapter *adapter)
 	netxen_free_hw_resources(adapter);
 	netxen_release_rx_buffers(adapter);
 	netxen_nic_free_irq(adapter);
+	netxen_napi_del(adapter);
 	netxen_free_sw_resources(adapter);
 
 	adapter->is_up = 0;
@@ -1100,9 +1120,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	if (netxen_napi_add(adapter, netdev))
-		goto err_out_disable_msi;
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &netxen_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
@@ -1183,7 +1200,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		netxen_free_adapter_offload(adapter);
 
 	netxen_teardown_intr(adapter);
-	netxen_free_sds_rings(&adapter->recv_ctx);
 
 	netxen_cleanup_pci_map(adapter);
 
-- 
1.6.0.2

