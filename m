From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 06/10] netxen: allocate status rings dynamically
Date: Sun,  5 Apr 2009 23:27:56 -0700
Message-ID: <1238999280-8114-7-git-send-email-dhananjay@netxen.com>
References: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:50790 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752705AbZDFG2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 02:28:06 -0400
In-Reply-To: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reduces netxen_adapter footprint when rss (msi-x) is disabled.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   10 +++++-----
 drivers/net/netxen/netxen_nic_main.c |   26 +++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f4d7e2d..e0f329f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -762,7 +762,7 @@ struct netxen_recv_context {
 	u16 virt_port;
 
 	struct nx_host_rds_ring rds_rings[NUM_RCV_DESC_RINGS];
-	struct nx_host_sds_ring sds_rings[NUM_STS_DESC_RINGS];
+	struct nx_host_sds_ring *sds_rings;
 };
 
 /* New HW context creation */
@@ -1203,10 +1203,10 @@ struct netxen_adapter {
 
 	spinlock_t tx_clean_lock;
 
-	u32 num_txd;
-	u32 num_rxd;
-	u32 num_jumbo_rxd;
-	u32 num_lro_rxd;
+	u16 num_txd;
+	u16 num_rxd;
+	u16 num_jumbo_rxd;
+	u16 num_lro_rxd;
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9050d62..b1cec07 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -153,7 +153,24 @@ static inline void netxen_nic_enable_int(struct nx_host_sds_ring *sds_ring)
 				adapter->legacy_intr.tgt_mask_reg, 0xfbff);
 }
 
+static int
+netxen_alloc_sds_rings(struct netxen_recv_context *recv_ctx, int count)
+{
+	int size = sizeof(struct nx_host_sds_ring) * count;
+
+	recv_ctx->sds_rings = kzalloc(size, GFP_KERNEL);
+
+	return (recv_ctx->sds_rings == NULL);
+}
+
 static void
+netxen_free_sds_rings(struct netxen_recv_context *recv_ctx)
+{
+	if (recv_ctx->sds_rings != NULL)
+		kfree(recv_ctx->sds_rings);
+}
+
+static int
 netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	int ring;
@@ -165,11 +182,16 @@ netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 	else
 		adapter->max_sds_rings = 1;
 
+	if (netxen_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
+		return 1;
+
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		netif_napi_add(netdev, &sds_ring->napi,
 				netxen_nic_poll, NETXEN_NETDEV_WEIGHT);
 	}
+
+	return 0;
 }
 
 static void
@@ -1028,7 +1050,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	netxen_napi_add(adapter, netdev);
+	if (netxen_napi_add(adapter, netdev))
+		goto err_out_disable_msi;
 
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &netxen_watchdog;
@@ -1110,6 +1133,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		netxen_free_adapter_offload(adapter);
 
 	netxen_teardown_intr(adapter);
+	netxen_free_sds_rings(&adapter->recv_ctx);
 
 	netxen_cleanup_pci_map(adapter);
 
-- 
1.6.0.2

