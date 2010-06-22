From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 4/8] qlcnic: release device resources during interface down
Date: Tue, 22 Jun 2010 06:19:01 -0700
Message-ID: <1277212745-26857-5-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34560 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754757Ab0FVNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:07 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Previously we were allocating device resources during probe and
release them during remove.
Now alloc during interface up and release in interface down.
This helps in device performance, as it doesn't need to keep
track of inactive resources.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    4 ++
 drivers/net/qlcnic/qlcnic_ctx.c     |   50 ++++++++++++++++++++---------
 drivers/net/qlcnic/qlcnic_ethtool.c |    7 +++-
 drivers/net/qlcnic/qlcnic_hw.c      |    4 +-
 drivers/net/qlcnic/qlcnic_init.c    |   26 +++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c    |   60 ++++++++++++++++++++++++----------
 6 files changed, 114 insertions(+), 37 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 588b9a9..5c7d474 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1124,6 +1124,10 @@ void __iomem *qlcnic_get_ioaddr(struct qlcnic_adapter *, u32);
 int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter);
 void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter);
 
+int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter);
+void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter);
+
+void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter);
 void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter);
 void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
 
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 7c96c8e..be341c1 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -180,6 +180,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	for (i = 0; i < nrds_rings; i++) {
 
 		rds_ring = &recv_ctx->rds_rings[i];
+		rds_ring->producer = 0;
 
 		prq_rds[i].host_phys_addr = cpu_to_le64(rds_ring->phys_addr);
 		prq_rds[i].ring_size = cpu_to_le32(rds_ring->num_desc);
@@ -193,6 +194,8 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	for (i = 0; i < nsds_rings; i++) {
 
 		sds_ring = &recv_ctx->sds_rings[i];
+		sds_ring->consumer = 0;
+		memset(sds_ring->desc_head, 0, STATUS_DESC_RINGSIZE(sds_ring));
 
 		prq_sds[i].host_phys_addr = cpu_to_le64(sds_ring->phys_addr);
 		prq_sds[i].ring_size = cpu_to_le32(sds_ring->num_desc);
@@ -293,6 +296,11 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
 	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
 
+	/* reset host resources */
+	tx_ring->producer = 0;
+	tx_ring->sw_consumer = 0;
+	*(tx_ring->hw_consumer) = 0;
+
 	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
 	rq_addr = pci_alloc_consistent(adapter->pdev,
 		rq_size, &rq_phys_addr);
@@ -476,15 +484,6 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 		sds_ring->desc_head = (struct status_desc *)addr;
 	}
 
-
-	err = qlcnic_fw_cmd_create_rx_ctx(adapter);
-	if (err)
-		goto err_out_free;
-	err = qlcnic_fw_cmd_create_tx_ctx(adapter);
-	if (err)
-		goto err_out_free;
-
-	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 	return 0;
 
 err_out_free:
@@ -492,15 +491,27 @@ err_out_free:
 	return err;
 }
 
-void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
+
+int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
-	int ring;
+	int err;
+
+	err = qlcnic_fw_cmd_create_rx_ctx(adapter);
+	if (err)
+		return err;
 
+	err = qlcnic_fw_cmd_create_tx_ctx(adapter);
+	if (err) {
+		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
+		return err;
+	}
+
+	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
+	return 0;
+}
 
+void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
+{
 	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
 		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
 		qlcnic_fw_cmd_destroy_tx_ctx(adapter);
@@ -508,6 +519,15 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 		/* Allow dma queues to drain after context reset */
 		msleep(20);
 	}
+}
+
+void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+	int ring;
 
 	recv_ctx = &adapter->recv_ctx;
 
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index a4f1120..d4e803e 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -348,7 +348,7 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	for (i = 0; diag_registers[i] != -1; i++)
 		regs_buff[i] = QLCRD32(adapter, diag_registers[i]);
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
 
 	regs_buff[i++] = 0xFFEFCDAB; /* Marker btw regs and ring count*/
@@ -833,6 +833,9 @@ static int qlcnic_blink_led(struct net_device *dev, u32 val)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int ret;
 
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
+		return -EIO;
+
 	ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
 	if (ret) {
 		dev_err(&adapter->pdev->dev,
@@ -904,7 +907,7 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return -EINVAL;
 
 	/*
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index ad12425..e08c8b0 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -327,7 +327,7 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 
 	i = 0;
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
 		return -EIO;
 
 	tx_ring = adapter->tx_ring;
@@ -431,7 +431,7 @@ void qlcnic_set_multi(struct net_device *netdev)
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 	u32 mode = VPORT_MISS_MODE_DROP;
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
 		return;
 
 	qlcnic_nic_add_mac(adapter, adapter->mac_addr);
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index d19d012..6678127 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -125,6 +125,32 @@ void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter)
 	}
 }
 
+void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_rx_buffer *rx_buf;
+	int i, ring;
+
+	recv_ctx = &adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+
+		spin_lock(&rds_ring->lock);
+
+		INIT_LIST_HEAD(&rds_ring->free_list);
+
+		rx_buf = rds_ring->rx_buf_arr;
+		for (i = 0; i < rds_ring->num_desc; i++) {
+			list_add_tail(&rx_buf->list,
+					&rds_ring->free_list);
+			rx_buf++;
+		}
+
+		spin_unlock(&rds_ring->lock);
+	}
+}
+
 void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_cmd_buffer *cmd_buf;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 9658b18..38d8fe0 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -346,7 +346,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
-	if (netif_running(netdev)) {
+	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_detach(netdev);
 		qlcnic_napi_disable(adapter);
 	}
@@ -355,7 +355,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	qlcnic_set_multi(adapter->netdev);
 
-	if (netif_running(netdev)) {
+	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_attach(netdev);
 		qlcnic_napi_enable(adapter);
 	}
@@ -877,9 +877,23 @@ qlcnic_init_coalesce_defaults(struct qlcnic_adapter *adapter)
 static int
 __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
+	int ring;
+	struct qlcnic_host_rds_ring *rds_ring;
+
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return -EIO;
 
+	if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+		return 0;
+
+	if (qlcnic_fw_create_ctx(adapter))
+		return -EIO;
+
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &adapter->recv_ctx.rds_rings[ring];
+		qlcnic_post_rx_buffers(adapter, ring, rds_ring);
+	}
+
 	qlcnic_set_multi(netdev);
 	qlcnic_fw_cmd_set_mtu(adapter, netdev->mtu);
 
@@ -936,6 +950,9 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_napi_disable(adapter);
 
+	qlcnic_fw_destroy_ctx(adapter);
+
+	qlcnic_reset_rx_buffers_list(adapter);
 	qlcnic_release_tx_buffers(adapter);
 	spin_unlock(&adapter->tx_clean_lock);
 }
@@ -957,13 +974,11 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	int err, ring;
-	struct qlcnic_host_rds_ring *rds_ring;
+	int err;
 
 	if (adapter->is_up == QLCNIC_ADAPTER_UP_MAGIC)
 		return 0;
 
-
 	err = qlcnic_napi_add(adapter, netdev);
 	if (err)
 		return err;
@@ -971,7 +986,7 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 	err = qlcnic_alloc_sw_resources(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "Error in setting sw resources\n");
-		return err;
+		goto err_out_napi_del;
 	}
 
 	err = qlcnic_alloc_hw_resources(adapter);
@@ -980,16 +995,10 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 		goto err_out_free_sw;
 	}
 
-
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &adapter->recv_ctx.rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, ring, rds_ring);
-	}
-
 	err = qlcnic_request_irq(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "failed to setup interrupt\n");
-		goto err_out_free_rxbuf;
+		goto err_out_free_hw;
 	}
 
 	qlcnic_init_coalesce_defaults(adapter);
@@ -999,11 +1008,12 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
 	return 0;
 
-err_out_free_rxbuf:
-	qlcnic_release_rx_buffers(adapter);
+err_out_free_hw:
 	qlcnic_free_hw_resources(adapter);
 err_out_free_sw:
 	qlcnic_free_sw_resources(adapter);
+err_out_napi_del:
+	qlcnic_napi_del(adapter);
 	return err;
 }
 
@@ -1038,6 +1048,8 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 		}
 	}
 
+	qlcnic_fw_destroy_ctx(adapter);
+
 	qlcnic_detach(adapter);
 
 	adapter->diag_test = 0;
@@ -1056,6 +1068,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_rds_ring *rds_ring;
 	int ring;
 	int ret;
 
@@ -1075,6 +1088,17 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 		return ret;
 	}
 
+	ret = qlcnic_fw_create_ctx(adapter);
+	if (ret) {
+		qlcnic_detach(adapter);
+		return ret;
+	}
+
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &adapter->recv_ctx.rds_rings[ring];
+		qlcnic_post_rx_buffers(adapter, ring, rds_ring);
+	}
+
 	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx.sds_rings[ring];
@@ -2636,7 +2660,7 @@ qlcnic_store_bridged_mode(struct device *dev,
 	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG))
 		goto err_out;
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto err_out;
 
 	if (strict_strtoul(buf, 2, &new))
@@ -2944,7 +2968,7 @@ recheck:
 	if (!adapter)
 		goto done;
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto done;
 
 	qlcnic_config_indev_addr(dev, event);
@@ -2980,7 +3004,7 @@ recheck:
 	if (!adapter)
 		goto done;
 
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto done;
 
 	switch (event) {
-- 
1.6.0.2

