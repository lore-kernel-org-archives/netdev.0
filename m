From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Enable diagnostic test for multiple Tx queues.
Date: Wed, 21 Aug 2013 11:24:12 -0400
Message-ID: <b5af44330151bfe93566fc823a6ae14daca0f597.1377122994.git.himanshu.madhani@qlogic.com>
References: <cover.1377122994.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36237 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752117Ab3HUPwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 11:52:45 -0400
In-Reply-To: <cover.1377122994.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Enable diagnostic test via ethtool and QConvergeConsole
  application when Multiple Tx queues are enabled on 82xx
  series adapters.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 23 +++++++++++++---------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |  3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 13 ++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  5 +++++
 6 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 101b538..45a5a2a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1990,6 +1990,7 @@ static inline void qlcnic_disable_int(struct qlcnic_host_sds_ring *sds_ring)
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
 
 	if (qlcnic_check_multi_tx(adapter) &&
+	    !adapter->ahw->diag_test &&
 	    (adapter->flags & QLCNIC_MSIX_ENABLED))
 		writel(0x1, sds_ring->crb_intr_mask);
 	else
@@ -2004,6 +2005,7 @@ static inline void qlcnic_enable_int(struct qlcnic_host_sds_ring *sds_ring)
 	struct qlcnic_adapter *adapter = sds_ring->adapter;
 
 	if (qlcnic_check_multi_tx(adapter) &&
+	    !adapter->ahw->diag_test &&
 	    (adapter->flags & QLCNIC_MSIX_ENABLED))
 		writel(0, sds_ring->crb_intr_mask);
 	else
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index b8d9750..2b68779 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -295,7 +295,8 @@ int qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 						| QLCNIC_CAP0_VALIDOFF);
 	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
 
-	if (qlcnic_check_multi_tx(adapter)) {
+	if (qlcnic_check_multi_tx(adapter) &&
+	    !adapter->ahw->diag_test) {
 		cap |= QLCNIC_CAP0_TX_MULTI;
 	} else {
 		temp_u16 = offsetof(struct qlcnic_hostrq_rx_ctx, msix_handler);
@@ -338,7 +339,8 @@ int qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		memset(sds_ring->desc_head, 0, STATUS_DESC_RINGSIZE(sds_ring));
 		prq_sds[i].host_phys_addr = cpu_to_le64(sds_ring->phys_addr);
 		prq_sds[i].ring_size = cpu_to_le32(sds_ring->num_desc);
-		if (qlcnic_check_multi_tx(adapter))
+		if (qlcnic_check_multi_tx(adapter) &&
+		    !adapter->ahw->diag_test)
 			prq_sds[i].msi_index = cpu_to_le16(ahw->intr_tbl[i].id);
 		else
 			prq_sds[i].msi_index = cpu_to_le16(i);
@@ -374,7 +376,7 @@ int qlcnic_82xx_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	for (i = 0; i < le16_to_cpu(prsp->num_sds_rings); i++) {
 		sds_ring = &recv_ctx->sds_rings[i];
 		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
-		if (qlcnic_check_multi_tx(adapter))
+		if (qlcnic_check_multi_tx(adapter) && !adapter->ahw->diag_test)
 			reg2 = ahw->intr_tbl[i].src;
 		else
 			reg2 = le32_to_cpu(prsp_sds[i].interrupt_crb);
@@ -464,13 +466,13 @@ int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
 
 	temp = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN |
 		QLCNIC_CAP0_LSO);
-	if (qlcnic_check_multi_tx(adapter))
+	if (qlcnic_check_multi_tx(adapter) && !adapter->ahw->diag_test)
 		temp |= QLCNIC_CAP0_TX_MULTI;
 
 	prq->capabilities[0] = cpu_to_le32(temp);
 
 	if (qlcnic_check_multi_tx(adapter) &&
-	    (adapter->max_drv_tx_rings > 1)) {
+	    !adapter->ahw->diag_test) {
 		temp_nsds_rings = adapter->max_sds_rings;
 		index = temp_nsds_rings + ring;
 		msix_id = ahw->intr_tbl[index].id;
@@ -506,6 +508,7 @@ int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
 		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
 		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 		if (qlcnic_check_multi_tx(adapter) &&
+		    !adapter->ahw->diag_test &&
 		    (adapter->flags & QLCNIC_MSIX_ENABLED)) {
 			index = adapter->max_sds_rings + ring;
 			intr_mask = ahw->intr_tbl[index].src;
@@ -681,13 +684,14 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *dev)
 
 err_out:
 	if (qlcnic_82xx_check(dev) && (dev->flags & QLCNIC_MSIX_ENABLED) &&
-	    qlcnic_check_multi_tx(dev))
-		qlcnic_82xx_config_intrpt(dev, 0);
+	    qlcnic_check_multi_tx(dev) && !dev->ahw->diag_test)
+			qlcnic_82xx_config_intrpt(dev, 0);
 
 	if (qlcnic_83xx_check(dev) && (dev->flags & QLCNIC_MSIX_ENABLED)) {
 		if (dev->ahw->diag_test != QLCNIC_LOOPBACK_TEST)
 			qlcnic_83xx_config_intrpt(dev, 0);
 	}
+
 	return err;
 }
 
@@ -703,8 +707,9 @@ void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
 
 		if (qlcnic_82xx_check(adapter) &&
 		    (adapter->flags & QLCNIC_MSIX_ENABLED) &&
-		    qlcnic_check_multi_tx(adapter))
-			qlcnic_82xx_config_intrpt(adapter, 0);
+		    qlcnic_check_multi_tx(adapter) &&
+		    !adapter->ahw->diag_test)
+				qlcnic_82xx_config_intrpt(adapter, 0);
 
 		if (qlcnic_83xx_check(adapter) &&
 		    (adapter->flags & QLCNIC_MSIX_ENABLED)) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 583dc2b..7b0c90e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -984,6 +984,7 @@ int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int max_drv_tx_rings = adapter->max_drv_tx_rings;
 	int max_sds_rings = adapter->max_sds_rings;
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -1043,6 +1044,7 @@ int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 
  clear_it:
 	adapter->max_sds_rings = max_sds_rings;
+	adapter->max_drv_tx_rings = max_drv_tx_rings;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	return ret;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 240b49f..66c26cf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -242,7 +242,8 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 		sds_ring->adapter = adapter;
 		sds_ring->num_desc = adapter->num_rxd;
 		if (qlcnic_82xx_check(adapter)) {
-			if (qlcnic_check_multi_tx(adapter))
+			if (qlcnic_check_multi_tx(adapter) &&
+			    !adapter->ahw->diag_test)
 				sds_ring->tx_ring = &adapter->tx_ring[ring];
 			else
 				sds_ring->tx_ring = &adapter->tx_ring[0];
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index f4b09f4..89f6dff 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -130,7 +130,8 @@ struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *,
 inline void qlcnic_enable_tx_intr(struct qlcnic_adapter *adapter,
 				  struct qlcnic_host_tx_ring *tx_ring)
 {
-	if (qlcnic_check_multi_tx(adapter))
+	if (qlcnic_check_multi_tx(adapter) &&
+	    !adapter->ahw->diag_test)
 		writel(0x0, tx_ring->crb_intr_mask);
 }
 
@@ -138,7 +139,8 @@ inline void qlcnic_enable_tx_intr(struct qlcnic_adapter *adapter,
 static inline void qlcnic_disable_tx_int(struct qlcnic_adapter *adapter,
 					 struct qlcnic_host_tx_ring *tx_ring)
 {
-	if (qlcnic_check_multi_tx(adapter))
+	if (qlcnic_check_multi_tx(adapter) &&
+	    !adapter->ahw->diag_test)
 		writel(1, tx_ring->crb_intr_mask);
 }
 
@@ -1466,6 +1468,7 @@ int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		if (qlcnic_check_multi_tx(adapter) &&
+		    !adapter->ahw->diag_test &&
 		    (adapter->max_drv_tx_rings > 1)) {
 			netif_napi_add(netdev, &sds_ring->napi, qlcnic_rx_poll,
 					QLCNIC_NETDEV_WEIGHT * 2);
@@ -1487,7 +1490,7 @@ int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 	}
 
-	if (qlcnic_check_multi_tx(adapter)) {
+	if (qlcnic_check_multi_tx(adapter) && !adapter->ahw->diag_test) {
 		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
 			tx_ring = &adapter->tx_ring[ring];
 			netif_napi_add(netdev, &tx_ring->napi, qlcnic_tx_poll,
@@ -1512,7 +1515,7 @@ void qlcnic_82xx_napi_del(struct qlcnic_adapter *adapter)
 
 	qlcnic_free_sds_rings(adapter->recv_ctx);
 
-	if (qlcnic_check_multi_tx(adapter)) {
+	if (qlcnic_check_multi_tx(adapter) && !adapter->ahw->diag_test) {
 		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
 			tx_ring = &adapter->tx_ring[ring];
 			netif_napi_del(&tx_ring->napi);
@@ -1540,6 +1543,7 @@ void qlcnic_82xx_napi_enable(struct qlcnic_adapter *adapter)
 
 	if (qlcnic_check_multi_tx(adapter) &&
 	    (adapter->flags & QLCNIC_MSIX_ENABLED) &&
+	    !adapter->ahw->diag_test &&
 	    (adapter->max_drv_tx_rings > 1)) {
 		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
 			tx_ring = &adapter->tx_ring[ring];
@@ -1567,6 +1571,7 @@ void qlcnic_82xx_napi_disable(struct qlcnic_adapter *adapter)
 	}
 
 	if ((adapter->flags & QLCNIC_MSIX_ENABLED) &&
+	    !adapter->ahw->diag_test &&
 	    qlcnic_check_multi_tx(adapter)) {
 		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
 			tx_ring = &adapter->tx_ring[ring];
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 94b3e82..25a858f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -581,6 +581,7 @@ int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 			} else {
 				adapter->ahw->num_msix = num_msix;
 				if (qlcnic_check_multi_tx(adapter) &&
+				    !adapter->ahw->diag_test &&
 				    (adapter->max_drv_tx_rings > 1))
 					max_sds_rings = num_msix - max_tx_rings;
 				else
@@ -697,6 +698,7 @@ int qlcnic_82xx_mq_intrpt(struct qlcnic_adapter *adapter, int op_type)
 	int err, i;
 
 	if (qlcnic_check_multi_tx(adapter) &&
+	    !ahw->diag_test &&
 	    (adapter->flags & QLCNIC_MSIX_ENABLED)) {
 		ahw->intr_tbl = vzalloc(ahw->num_msix *
 					sizeof(struct qlcnic_intrpt_config));
@@ -1752,6 +1754,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_host_sds_ring *sds_ring;
+	int max_tx_rings = adapter->max_drv_tx_rings;
 	int ring;
 
 	clear_bit(__QLCNIC_DEV_UP, &adapter->state);
@@ -1768,6 +1771,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 
 	adapter->ahw->diag_test = 0;
 	adapter->max_sds_rings = max_sds_rings;
+	adapter->max_drv_tx_rings = max_tx_rings;
 
 	if (qlcnic_attach(adapter))
 		goto out;
@@ -1836,6 +1840,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	adapter->max_sds_rings = 1;
 	adapter->ahw->diag_test = test;
 	adapter->ahw->linkup = 0;
+	adapter->max_drv_tx_rings = 1;
 
 	ret = qlcnic_attach(adapter);
 	if (ret) {
-- 
1.8.1.4
