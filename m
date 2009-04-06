From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 02/10] netxen: refactor netxen_adapter
Date: Sun,  5 Apr 2009 23:27:52 -0700
Message-ID: <1238999280-8114-3-git-send-email-dhananjay@netxen.com>
References: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:50779 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752452AbZDFG2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 02:28:05 -0400
In-Reply-To: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rearrange members to align them at right offset.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   80 ++++++++++++++++-----------------
 drivers/net/netxen/netxen_nic_ctx.c  |    7 ---
 drivers/net/netxen/netxen_nic_main.c |   11 -----
 3 files changed, 39 insertions(+), 59 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 184eb6f..1165f53 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -700,14 +700,13 @@ struct netxen_hardware_context {
 
 	u8 cut_through;
 	u8 revision_id;
+	u8 pci_func;
+	u8 linkup;
 	u16 port_type;
-	int board_type;
-	u32 linkup;
+	u16 board_type;
 	/* Address of cmd ring in Phantom */
 	struct cmd_desc_type0 *cmd_desc_head;
 	dma_addr_t cmd_desc_phys_addr;
-	struct netxen_adapter *adapter;
-	int pci_func;
 };
 
 #define MINIMUM_ETHERNET_FRAME_SIZE	64	/* With FCS */
@@ -1146,61 +1145,52 @@ struct netxen_adapter {
 
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	int pci_using_dac;
-	struct net_device_stats net_stats;
-	int mtu;
-	int portnum;
-	u8 physical_port;
-	u16 tx_context_id;
-
-	uint8_t		mc_enabled;
-	uint8_t		max_mc_count;
 	nx_mac_list_t	*mac_list;
 
-	struct netxen_legacy_intr_set legacy_intr;
-
-	struct work_struct watchdog_task;
-	struct timer_list watchdog_timer;
-	struct work_struct  tx_timeout_task;
-
 	u32 curr_window;
 	u32 crb_win;
 	rwlock_t adapter_lock;
 
+	spinlock_t tx_clean_lock;
 	u32 cmd_producer;
-	__le32 *cmd_consumer;
 	u32 last_cmd_consumer;
 	u32 crb_addr_cmd_producer;
 	u32 crb_addr_cmd_consumer;
-	spinlock_t tx_clean_lock;
+	__le32 *cmd_consumer;
 
 	u32 num_txd;
 	u32 num_rxd;
 	u32 num_jumbo_rxd;
 	u32 num_lro_rxd;
 
-	int max_rds_rings;
-	int max_sds_rings;
+	u8 max_rds_rings;
+	u8 max_sds_rings;
+	u8 driver_mismatch;
+	u8 msix_supported;
+	u8 rx_csum;
+	u8 pci_using_dac;
+	u8 portnum;
+	u8 physical_port;
+
+	u8 mc_enabled;
+	u8 max_mc_count;
+	u16 tx_context_id;
+	u16 mtu;
+	u16 is_up;
+	u16 link_speed;
+	u16 link_duplex;
+	u16 link_autoneg;
+	u16 resv1;
 
+	u32 resv2;
 	u32 flags;
 	u32 irq;
-	int driver_mismatch;
 	u32 temp;
-
 	u32 fw_major;
 	u32 fw_version;
 
-	int msix_supported;
-	struct msix_entry msix_entries[MSIX_ENTRIES_PER_ADAPTER];
-
 	struct netxen_adapter_stats stats;
 
-	u16 link_speed;
-	u16 link_duplex;
-	u16 state;
-	u16 link_autoneg;
-	int rx_csum;
-
 	struct netxen_cmd_buffer *cmd_buf_arr;	/* Command buffers for xmit */
 
 	/*
@@ -1209,15 +1199,9 @@ struct netxen_adapter {
 	 */
 	struct netxen_recv_context recv_ctx;
 
-	int is_up;
-	struct netxen_dummy_dma dummy_dma;
-	nx_nic_intr_coalesce_t coal;
-
 	/* Context interface shared between card and host */
 	struct netxen_ring_ctx *ctx_desc;
 	dma_addr_t ctx_desc_phys_addr;
-	int intr_scheme;
-	int msi_mode;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
@@ -1238,7 +1222,21 @@ struct netxen_adapter {
 	u32 (*pci_read_normalize)(struct netxen_adapter *, u64);
 	unsigned long (*pci_set_window)(struct netxen_adapter *,
 			unsigned long long);
-};				/* netxen_adapter structure */
+
+	struct netxen_legacy_intr_set legacy_intr;
+
+	struct msix_entry msix_entries[MSIX_ENTRIES_PER_ADAPTER];
+
+	struct netxen_dummy_dma dummy_dma;
+
+	struct work_struct watchdog_task;
+	struct timer_list watchdog_timer;
+	struct work_struct  tx_timeout_task;
+
+	struct net_device_stats net_stats;
+
+	nx_nic_intr_coalesce_t coal;
+};
 
 /*
  * NetXen dma watchdog control structure
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 9234473..73f6deb 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -624,9 +624,6 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 
 
 	if (adapter->fw_major >= 4) {
-		adapter->intr_scheme = INTR_SCHEME_PERPORT;
-		adapter->msi_mode = MSI_MODE_MULTIFUNC;
-
 		err = nx_fw_cmd_create_rx_ctx(adapter);
 		if (err)
 			goto err_out_free;
@@ -638,10 +635,6 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		sds_ring->crb_sts_consumer =
 			recv_crb_registers[adapter->portnum].crb_sts_consumer;
 
-		adapter->intr_scheme = adapter->pci_read_normalize(adapter,
-				CRB_NIC_CAPABILITIES_FW);
-		adapter->msi_mode = adapter->pci_read_normalize(adapter,
-				CRB_NIC_MSI_MODE_FW);
 		recv_ctx->sds_rings[0].crb_intr_mask =
 				sw_int_mask[adapter->portnum];
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9b7a292..b94216b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -462,8 +462,6 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
-	adapter->intr_scheme = -1;
-	adapter->msi_mode = -1;
 
 	if (adapter->ahw.revision_id >= NX_P3_B0)
 		legacy_intrp = &legacy_intr[adapter->ahw.pci_func];
@@ -726,15 +724,6 @@ netxen_nic_request_irq(struct netxen_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
-	if ((adapter->msi_mode != MSI_MODE_MULTIFUNC) ||
-		(adapter->intr_scheme != INTR_SCHEME_PERPORT)) {
-		printk(KERN_ERR "%s: Firmware interrupt scheme is "
-				"incompatible with driver\n",
-				netdev->name);
-		adapter->driver_mismatch = 1;
-		return -EINVAL;
-	}
-
 	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
 		handler = netxen_msix_intr;
 	else if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
-- 
1.6.0.2

