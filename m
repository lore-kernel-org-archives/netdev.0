From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCN net-next-2.6] drivers/net: use vzalloc()
Date: Mon, 22 Nov 2010 11:15:06 +0100
Message-ID: <1290420906.2811.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60746 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab0KVKPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 05:15:11 -0500
Received: by fxm13 with SMTP id 13so2447433fxm.19
        for <netdev@vger.kernel.org>; Mon, 22 Nov 2010 02:15:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use vzalloc() and vzalloc_node() in net drivers

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
People, I hope you dont mind if I make a single patch, and dont Cc all
maintainers, for such trivial change.

 drivers/net/bnx2.c                   |    9 +------
 drivers/net/cxgb3/cxgb3_offload.c    |    6 +---
 drivers/net/cxgb4/cxgb4_main.c       |    6 +---
 drivers/net/e1000/e1000_main.c       |    6 +---
 drivers/net/e1000e/netdev.c          |    6 +---
 drivers/net/ehea/ehea_main.c         |    4 ---
 drivers/net/igb/igb_main.c           |    6 +---
 drivers/net/igbvf/netdev.c           |    6 +---
 drivers/net/ixgb/ixgb_main.c         |    6 +---
 drivers/net/ixgbe/ixgbe_main.c       |   10 +++-----
 drivers/net/ixgbevf/ixgbevf_main.c   |    6 +---
 drivers/net/netxen/netxen_nic_init.c |    6 +---
 drivers/net/pch_gbe/pch_gbe_main.c   |    6 +---
 drivers/net/pptp.c                   |    3 --
 drivers/net/qlcnic/qlcnic_init.c     |    6 +---
 drivers/net/sfc/filter.c             |    3 --
 drivers/net/vxge/vxge-config.c       |   31 ++++++-------------------
 17 files changed, 39 insertions(+), 87 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 062600b..0de196d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -766,13 +766,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 		int j;
 
 		rxr->rx_buf_ring =
-			vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
+			vzalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
 		if (rxr->rx_buf_ring == NULL)
 			return -ENOMEM;
 
-		memset(rxr->rx_buf_ring, 0,
-		       SW_RXBD_RING_SIZE * bp->rx_max_ring);
-
 		for (j = 0; j < bp->rx_max_ring; j++) {
 			rxr->rx_desc_ring[j] =
 				dma_alloc_coherent(&bp->pdev->dev,
@@ -785,13 +782,11 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 		}
 
 		if (bp->rx_pg_ring_size) {
-			rxr->rx_pg_ring = vmalloc(SW_RXPG_RING_SIZE *
+			rxr->rx_pg_ring = vzalloc(SW_RXPG_RING_SIZE *
 						  bp->rx_max_pg_ring);
 			if (rxr->rx_pg_ring == NULL)
 				return -ENOMEM;
 
-			memset(rxr->rx_pg_ring, 0, SW_RXPG_RING_SIZE *
-			       bp->rx_max_pg_ring);
 		}
 
 		for (j = 0; j < bp->rx_max_pg_ring; j++) {
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index bcf0753..ef02aa6 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1164,12 +1164,10 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
  */
 void *cxgb_alloc_mem(unsigned long size)
 {
-	void *p = kmalloc(size, GFP_KERNEL);
+	void *p = kzalloc(size, GFP_KERNEL);
 
 	if (!p)
-		p = vmalloc(size);
-	if (p)
-		memset(p, 0, size);
+		p = vzalloc(size);
 	return p;
 }
 
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index f50bc98..848f89d 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -868,12 +868,10 @@ out:	release_firmware(fw);
  */
 void *t4_alloc_mem(size_t size)
 {
-	void *p = kmalloc(size, GFP_KERNEL);
+	void *p = kzalloc(size, GFP_KERNEL);
 
 	if (!p)
-		p = vmalloc(size);
-	if (p)
-		memset(p, 0, size);
+		p = vzalloc(size);
 	return p;
 }
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4686c39..dcb7f82 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1425,13 +1425,12 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	int size;
 
 	size = sizeof(struct e1000_buffer) * txdr->count;
-	txdr->buffer_info = vmalloc(size);
+	txdr->buffer_info = vzalloc(size);
 	if (!txdr->buffer_info) {
 		e_err(probe, "Unable to allocate memory for the Tx descriptor "
 		      "ring\n");
 		return -ENOMEM;
 	}
-	memset(txdr->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 
@@ -1621,13 +1620,12 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	int size, desc_len;
 
 	size = sizeof(struct e1000_buffer) * rxdr->count;
-	rxdr->buffer_info = vmalloc(size);
+	rxdr->buffer_info = vzalloc(size);
 	if (!rxdr->buffer_info) {
 		e_err(probe, "Unable to allocate memory for the Rx descriptor "
 		      "ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->buffer_info, 0, size);
 
 	desc_len = sizeof(struct e1000_rx_desc);
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 9b3f0a9..0adcb79 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2059,10 +2059,9 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 	int err = -ENOMEM, size;
 
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info)
 		goto err;
-	memset(tx_ring->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc);
@@ -2095,10 +2094,9 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 	int i, size, desc_len, err = -ENOMEM;
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info)
 		goto err;
-	memset(rx_ring->buffer_info, 0, size);
 
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 182b2a7..a84c389 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1496,12 +1496,10 @@ static int ehea_init_q_skba(struct ehea_q_skb_arr *q_skba, int max_q_entries)
 {
 	int arr_size = sizeof(void *) * max_q_entries;
 
-	q_skba->arr = vmalloc(arr_size);
+	q_skba->arr = vzalloc(arr_size);
 	if (!q_skba->arr)
 		return -ENOMEM;
 
-	memset(q_skba->arr, 0, arr_size);
-
 	q_skba->len = max_q_entries;
 	q_skba->index = 0;
 	q_skba->os_skbs = 0;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 892d196..67ea262 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2436,10 +2436,9 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 	int size;
 
 	size = sizeof(struct igb_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info)
 		goto err;
-	memset(tx_ring->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
@@ -2587,10 +2586,9 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 	int size, desc_len;
 
 	size = sizeof(struct igb_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info)
 		goto err;
-	memset(rx_ring->buffer_info, 0, size);
 
 	desc_len = sizeof(union e1000_adv_rx_desc);
 
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 4c998b7..8dbde23 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -430,10 +430,9 @@ int igbvf_setup_tx_resources(struct igbvf_adapter *adapter,
 	int size;
 
 	size = sizeof(struct igbvf_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info)
 		goto err;
-	memset(tx_ring->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
@@ -470,10 +469,9 @@ int igbvf_setup_rx_resources(struct igbvf_adapter *adapter,
 	int size, desc_len;
 
 	size = sizeof(struct igbvf_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info)
 		goto err;
-	memset(rx_ring->buffer_info, 0, size);
 
 	desc_len = sizeof(union e1000_adv_rx_desc);
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index caa8192..211a169 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -669,13 +669,12 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
-	txdr->buffer_info = vmalloc(size);
+	txdr->buffer_info = vzalloc(size);
 	if (!txdr->buffer_info) {
 		netif_err(adapter, probe, adapter->netdev,
 			  "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
 	}
-	memset(txdr->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 
@@ -759,13 +758,12 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
-	rxdr->buffer_info = vmalloc(size);
+	rxdr->buffer_info = vzalloc(size);
 	if (!rxdr->buffer_info) {
 		netif_err(adapter, probe, adapter->netdev,
 			  "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5409af3..4249b51 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5181,12 +5181,11 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vmalloc_node(size, tx_ring->numa_node);
+	tx_ring->tx_buffer_info = vzalloc_node(size, tx_ring->numa_node);
 	if (!tx_ring->tx_buffer_info)
-		tx_ring->tx_buffer_info = vmalloc(size);
+		tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
-	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
@@ -5246,12 +5245,11 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vmalloc_node(size, rx_ring->numa_node);
+	rx_ring->rx_buffer_info = vzalloc_node(size, rx_ring->numa_node);
 	if (!rx_ring->rx_buffer_info)
-		rx_ring->rx_buffer_info = vmalloc(size);
+		rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info)
 		goto err;
-	memset(rx_ring->rx_buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 5b8063c..2216a3c 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2489,10 +2489,9 @@ int ixgbevf_setup_tx_resources(struct ixgbevf_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbevf_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vmalloc(size);
+	tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
-	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
@@ -2556,14 +2555,13 @@ int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbevf_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vmalloc(size);
+	rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info) {
 		hw_dbg(&adapter->hw,
 		       "Unable to vmalloc buffer memory for "
 		       "the receive descriptor ring\n");
 		goto alloc_failed;
 	}
-	memset(rx_ring->rx_buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 95fe552..f946de2 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -214,13 +214,12 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	tx_ring->num_desc = adapter->num_txd;
 	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
 
-	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
+	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate cmd buffer ring\n",
 		       netdev->name);
 		goto err_out;
 	}
-	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
@@ -280,7 +279,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 
 		}
 		rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
-			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
+			vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			printk(KERN_ERR "%s: Failed to allocate "
 				"rx buffer ring %d\n",
@@ -288,7 +287,6 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			/* free whatever was already allocated */
 			goto err_out;
 		}
-		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 472056b..afb7506 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1523,12 +1523,11 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 	int desNo;
 
 	size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
-	tx_ring->buffer_info = vmalloc(size);
+	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info) {
 		pr_err("Unable to allocate memory for the buffer infomation\n");
 		return -ENOMEM;
 	}
-	memset(tx_ring->buffer_info, 0, size);
 
 	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
 
@@ -1573,12 +1572,11 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 	int desNo;
 
 	size = (int)sizeof(struct pch_gbe_buffer) * rx_ring->count;
-	rx_ring->buffer_info = vmalloc(size);
+	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info) {
 		pr_err("Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rx_ring->buffer_info, 0, size);
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
 	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index ccbc913..7556a92 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -673,8 +673,7 @@ static int __init pptp_init_module(void)
 	int err = 0;
 	pr_info("PPTP driver version " PPTP_DRIVER_VERSION "\n");
 
-	callid_sock = __vmalloc((MAX_CALLID + 1) * sizeof(void *),
-		GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+	callid_sock = vzalloc((MAX_CALLID + 1) * sizeof(void *));
 	if (!callid_sock) {
 		pr_err("PPTP: cann't allocate memory\n");
 		return -ENOMEM;
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 0d180c6..3f97018 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -236,12 +236,11 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	tx_ring->num_desc = adapter->num_txd;
 	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
 
-	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
+	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
 		dev_err(&netdev->dev, "failed to allocate cmd buffer ring\n");
 		goto err_out;
 	}
-	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
@@ -276,13 +275,12 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 			break;
 		}
 		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
-			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
+			vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			dev_err(&netdev->dev, "Failed to allocate "
 				"rx buffer ring %d\n", ring);
 			goto err_out;
 		}
-		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 52cb608..44500b5 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -428,10 +428,9 @@ int efx_probe_filters(struct efx_nic *efx)
 					     GFP_KERNEL);
 		if (!table->used_bitmap)
 			goto fail;
-		table->spec = vmalloc(table->size * sizeof(*table->spec));
+		table->spec = vzalloc(table->size * sizeof(*table->spec));
 		if (!table->spec)
 			goto fail;
-		memset(table->spec, 0, table->size * sizeof(*table->spec));
 	}
 
 	return 0;
diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 409c2e6..44d3ddd 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -1220,13 +1220,12 @@ vxge_hw_device_initialize(
 		goto exit;
 
 	hldev = (struct __vxge_hw_device *)
-			vmalloc(sizeof(struct __vxge_hw_device));
+			vzalloc(sizeof(struct __vxge_hw_device));
 	if (hldev == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto exit;
 	}
 
-	memset(hldev, 0, sizeof(struct __vxge_hw_device));
 	hldev->magic = VXGE_HW_DEVICE_MAGIC;
 
 	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_ALL);
@@ -2064,15 +2063,12 @@ __vxge_hw_mempool_grow(struct vxge_hw_mempool *mempool, u32 num_allocate,
 		 * allocate new memblock and its private part at once.
 		 * This helps to minimize memory usage a lot. */
 		mempool->memblocks_priv_arr[i] =
-				vmalloc(mempool->items_priv_size * n_items);
+				vzalloc(mempool->items_priv_size * n_items);
 		if (mempool->memblocks_priv_arr[i] == NULL) {
 			status = VXGE_HW_ERR_OUT_OF_MEMORY;
 			goto exit;
 		}
 
-		memset(mempool->memblocks_priv_arr[i], 0,
-			     mempool->items_priv_size * n_items);
-
 		/* allocate DMA-capable memblock */
 		mempool->memblocks_arr[i] =
 			__vxge_hw_blockpool_malloc(mempool->devh,
@@ -2145,12 +2141,11 @@ __vxge_hw_mempool_create(
 	}
 
 	mempool = (struct vxge_hw_mempool *)
-			vmalloc(sizeof(struct vxge_hw_mempool));
+			vzalloc(sizeof(struct vxge_hw_mempool));
 	if (mempool == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto exit;
 	}
-	memset(mempool, 0, sizeof(struct vxge_hw_mempool));
 
 	mempool->devh			= devh;
 	mempool->memblock_size		= memblock_size;
@@ -2170,31 +2165,27 @@ __vxge_hw_mempool_create(
 
 	/* allocate array of memblocks */
 	mempool->memblocks_arr =
-		(void **) vmalloc(sizeof(void *) * mempool->memblocks_max);
+		(void **) vzalloc(sizeof(void *) * mempool->memblocks_max);
 	if (mempool->memblocks_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->memblocks_arr, 0,
-		sizeof(void *) * mempool->memblocks_max);
 
 	/* allocate array of private parts of items per memblocks */
 	mempool->memblocks_priv_arr =
-		(void **) vmalloc(sizeof(void *) * mempool->memblocks_max);
+		(void **) vzalloc(sizeof(void *) * mempool->memblocks_max);
 	if (mempool->memblocks_priv_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->memblocks_priv_arr, 0,
-		    sizeof(void *) * mempool->memblocks_max);
 
 	/* allocate array of memblocks DMA objects */
 	mempool->memblocks_dma_arr = (struct vxge_hw_mempool_dma *)
-		vmalloc(sizeof(struct vxge_hw_mempool_dma) *
+		vzalloc(sizeof(struct vxge_hw_mempool_dma) *
 			mempool->memblocks_max);
 
 	if (mempool->memblocks_dma_arr == NULL) {
@@ -2203,20 +2194,16 @@ __vxge_hw_mempool_create(
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->memblocks_dma_arr, 0,
-			sizeof(struct vxge_hw_mempool_dma) *
-			mempool->memblocks_max);
 
 	/* allocate hash array of items */
 	mempool->items_arr =
-		(void **) vmalloc(sizeof(void *) * mempool->items_max);
+		(void **) vzalloc(sizeof(void *) * mempool->items_max);
 	if (mempool->items_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->items_arr, 0, sizeof(void *) * mempool->items_max);
 
 	/* calculate initial number of memblocks */
 	memblocks_to_allocate = (mempool->items_initial +
@@ -4272,14 +4259,12 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
 		goto vpath_open_exit1;
 
 	vp = (struct __vxge_hw_vpath_handle *)
-		vmalloc(sizeof(struct __vxge_hw_vpath_handle));
+		vzalloc(sizeof(struct __vxge_hw_vpath_handle));
 	if (vp == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto vpath_open_exit2;
 	}
 
-	memset(vp, 0, sizeof(struct __vxge_hw_vpath_handle));
-
 	vp->vpath = vpath;
 
 	if (vpath->vp_config->fifo.enable == VXGE_HW_FIFO_ENABLE) {


