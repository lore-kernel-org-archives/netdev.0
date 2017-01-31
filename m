From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 5/6] drivers: net: xgene-v2: Add transmit and receive
Date: Tue, 31 Jan 2017 11:03:20 -0800
Message-ID: <1485889401-13909-6-git-send-email-isubramanian@apm.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34559 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751820AbdAaTFS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 14:05:18 -0500
Received: by mail-pf0-f179.google.com with SMTP id e4so109482008pfg.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 11:03:28 -0800 (PST)
In-Reply-To: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds,
    - Transmit
    - Transmit completion poll
    - Receive poll
    - NAPI handler

and enables the driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/Kconfig           |   1 +
 drivers/net/ethernet/apm/Makefile          |   1 +
 drivers/net/ethernet/apm/xgene-v2/Kconfig  |  11 ++
 drivers/net/ethernet/apm/xgene-v2/Makefile |   6 +
 drivers/net/ethernet/apm/xgene-v2/main.c   | 200 ++++++++++++++++++++++++++++-
 5 files changed, 218 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/Makefile

diff --git a/drivers/net/ethernet/apm/Kconfig b/drivers/net/ethernet/apm/Kconfig
index ec63d70..59efe5b 100644
--- a/drivers/net/ethernet/apm/Kconfig
+++ b/drivers/net/ethernet/apm/Kconfig
@@ -1 +1,2 @@
 source "drivers/net/ethernet/apm/xgene/Kconfig"
+source "drivers/net/ethernet/apm/xgene-v2/Kconfig"
diff --git a/drivers/net/ethernet/apm/Makefile b/drivers/net/ethernet/apm/Makefile
index 65ce32a..946b2a4 100644
--- a/drivers/net/ethernet/apm/Makefile
+++ b/drivers/net/ethernet/apm/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_NET_XGENE) += xgene/
+obj-$(CONFIG_NET_XGENE_V2) += xgene-v2/
diff --git a/drivers/net/ethernet/apm/xgene-v2/Kconfig b/drivers/net/ethernet/apm/xgene-v2/Kconfig
new file mode 100644
index 0000000..1205861
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/Kconfig
@@ -0,0 +1,11 @@
+config NET_XGENE_V2
+	tristate "APM X-Gene SoC Ethernet-v2 Driver"
+	depends on HAS_DMA
+	depends on ARCH_XGENE || COMPILE_TEST
+	help
+	  This is the Ethernet driver for the on-chip ethernet interface
+	  which uses a linked list of DMA descriptor architecture (v2) for
+	  APM X-Gene SoCs.
+
+	  To compile this driver as a module, choose M here. This module will
+	  be called xgene-enet-v2.
diff --git a/drivers/net/ethernet/apm/xgene-v2/Makefile b/drivers/net/ethernet/apm/xgene-v2/Makefile
new file mode 100644
index 0000000..735309c
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for APM X-Gene Ethernet v2 driver
+#
+
+xgene-enet-v2-objs := main.o mac.o enet.o ring.o
+obj-$(CONFIG_NET_XGENE_V2) += xgene-enet-v2.o
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.c b/drivers/net/ethernet/apm/xgene-v2/main.c
index 3881f27..fc90298 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.c
+++ b/drivers/net/ethernet/apm/xgene-v2/main.c
@@ -164,9 +164,11 @@ static int xge_refill_buffers(struct net_device *ndev, u32 nbuf)
 		dma_wmb();
 		raw_desc->m0 = cpu_to_le64(SET_BITS(PKT_ADDRL, dma_addr) |
 					   SET_BITS(E, 1));
+
 		ring->skbs[tail] = skb;
 		tail = (tail + 1) & slots;
 	}
+	xge_wr_csr(pdata, DMARXCTRL, 1);
 
 	ring->tail = tail;
 
@@ -278,13 +280,14 @@ static int xge_open(struct net_device *ndev)
 	struct xge_pdata *pdata = netdev_priv(ndev);
 	int ret;
 
+	napi_enable(&pdata->napi);
+
 	ret = xge_request_irq(ndev);
 	if (ret)
 		return ret;
 
 	xge_intr_enable(pdata);
 
-	xge_wr_csr(pdata, DMARXCTRL, 1);
 	xge_mac_enable(pdata);
 	netif_start_queue(ndev);
 
@@ -298,11 +301,204 @@ static int xge_close(struct net_device *ndev)
 	netif_stop_queue(ndev);
 	xge_mac_disable(pdata);
 
+	xge_intr_disable(pdata);
 	xge_free_irq(ndev);
+	napi_disable(&pdata->napi);
 
 	return 0;
 }
 
+static netdev_tx_t xge_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	static dma_addr_t dma_addr;
+	struct xge_desc_ring *tx_ring;
+	struct xge_raw_desc *raw_desc;
+	u64 addr_lo, addr_hi;
+	void *pkt_buf;
+	u8 tail;
+	u16 len;
+
+	tx_ring = pdata->tx_ring;
+	tail = tx_ring->tail;
+	len = skb_headlen(skb);
+	raw_desc = &tx_ring->raw_desc[tail];
+
+	/* Tx descriptor not available */
+	if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)) ||
+	    GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0)))
+		return NETDEV_TX_BUSY;
+
+	/* Packet buffers should be 64B aligned */
+	pkt_buf = dma_alloc_coherent(dev, XGENE_ENET_STD_MTU, &dma_addr,
+				     GFP_ATOMIC);
+	if (unlikely(!pkt_buf))
+		goto out;
+
+	memcpy(pkt_buf, skb->data, len);
+
+	addr_hi = GET_BITS(NEXT_DESC_ADDRH, le64_to_cpu(raw_desc->m1));
+	addr_lo = GET_BITS(NEXT_DESC_ADDRL, le64_to_cpu(raw_desc->m1));
+	raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, addr_lo) |
+				   SET_BITS(NEXT_DESC_ADDRH, addr_hi) |
+				   SET_BITS(PKT_ADDRH,
+					    dma_addr >> PKT_ADDRL_LEN));
+
+	dma_wmb();
+
+	raw_desc->m0 = cpu_to_le64(SET_BITS(PKT_ADDRL, dma_addr) |
+				   SET_BITS(PKT_SIZE, len) |
+				   SET_BITS(E, 0));
+
+	skb_tx_timestamp(skb);
+	xge_wr_csr(pdata, DMATXCTRL, 1);
+
+	pdata->stats.tx_packets++;
+	pdata->stats.tx_bytes += skb->len;
+
+	tx_ring->skbs[tail] = skb;
+	tx_ring->pkt_bufs[tail] = pkt_buf;
+	tx_ring->tail = (tail + 1) & (XGENE_ENET_NUM_DESC - 1);
+
+out:
+	dev_kfree_skb_any(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static void xge_txc_poll(struct net_device *ndev, unsigned int budget)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	struct xge_desc_ring *tx_ring;
+	struct xge_raw_desc *raw_desc;
+	u64 addr_lo, addr_hi;
+	dma_addr_t dma_addr;
+	void *pkt_buf;
+	bool pktsent;
+	u32 data;
+	u8 head;
+	int i;
+
+	tx_ring = pdata->tx_ring;
+	head = tx_ring->head;
+
+	data = xge_rd_csr(pdata, DMATXSTATUS);
+	pktsent = data & TX_PKT_SENT;
+	if (unlikely(!pktsent))
+		return;
+
+	for (i = 0; i < budget; i++) {
+		raw_desc = &tx_ring->raw_desc[head];
+
+		if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)))
+			break;
+
+		dma_rmb();
+
+		addr_hi = GET_BITS(PKT_ADDRH, le64_to_cpu(raw_desc->m1));
+		addr_lo = GET_BITS(PKT_ADDRL, le64_to_cpu(raw_desc->m0));
+		dma_addr = (addr_hi << PKT_ADDRL_LEN) | addr_lo;
+
+		pkt_buf = tx_ring->pkt_bufs[head];
+
+		/* clear pktstart address and pktsize */
+		raw_desc->m0 = cpu_to_le64(SET_BITS(E, 1) |
+					   SET_BITS(PKT_SIZE, 0));
+		xge_wr_csr(pdata, DMATXSTATUS, 1);
+
+		dma_free_coherent(dev, XGENE_ENET_STD_MTU, pkt_buf, dma_addr);
+
+		head = (head + 1) & (XGENE_ENET_NUM_DESC - 1);
+	}
+
+	tx_ring->head = head;
+}
+
+static int xge_rx_poll(struct net_device *ndev, unsigned int budget)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	dma_addr_t addr_hi, addr_lo, dma_addr;
+	struct xge_desc_ring *rx_ring;
+	struct xge_raw_desc *raw_desc;
+	struct sk_buff *skb;
+	int i, npkts, ret = 0;
+	bool pktrcvd;
+	u32 data;
+	u8 head;
+	u16 len;
+
+	rx_ring = pdata->rx_ring;
+	head = rx_ring->head;
+
+	data = xge_rd_csr(pdata, DMARXSTATUS);
+	pktrcvd = data & RXSTATUS_RXPKTRCVD;
+
+	if (unlikely(!pktrcvd))
+		return 0;
+
+	npkts = 0;
+	for (i = 0; i < budget; i++) {
+		raw_desc = &rx_ring->raw_desc[head];
+
+		if (GET_BITS(E, le64_to_cpu(raw_desc->m0)))
+			break;
+
+		dma_rmb();
+
+		addr_hi = GET_BITS(PKT_ADDRH, le64_to_cpu(raw_desc->m1));
+		addr_lo = GET_BITS(PKT_ADDRL, le64_to_cpu(raw_desc->m0));
+		dma_addr = (addr_hi << PKT_ADDRL_LEN) | addr_lo;
+		len = GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0));
+
+		dma_unmap_single(dev, dma_addr, XGENE_ENET_STD_MTU,
+				 DMA_FROM_DEVICE);
+
+		skb = rx_ring->skbs[head];
+		skb_put(skb, len);
+
+		skb->protocol = eth_type_trans(skb, ndev);
+
+		pdata->stats.rx_packets++;
+		pdata->stats.rx_bytes += len;
+		napi_gro_receive(&pdata->napi, skb);
+		npkts++;
+
+		ret = xge_refill_buffers(ndev, 1);
+		xge_wr_csr(pdata, DMARXSTATUS, 1);
+
+		if (ret)
+			break;
+
+		head = (head + 1) & (XGENE_ENET_NUM_DESC - 1);
+	}
+
+	rx_ring->head = head;
+
+	return npkts;
+}
+
+static int xge_napi(struct napi_struct *napi, const int budget)
+{
+	struct net_device *ndev = napi->dev;
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	int processed;
+
+	pdata = netdev_priv(ndev);
+
+	xge_txc_poll(ndev, budget);
+	processed = xge_rx_poll(ndev, budget);
+
+	if (processed < budget) {
+		napi_complete(napi);
+		xge_intr_enable(pdata);
+	}
+
+	return processed;
+}
+
 static int xge_set_mac_addr(struct net_device *ndev, void *addr)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
@@ -345,6 +541,7 @@ static void xge_get_stats64(struct net_device *ndev,
 static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_open = xge_open,
 	.ndo_stop = xge_close,
+	.ndo_start_xmit = xge_start_xmit,
 	.ndo_set_mac_address = xge_set_mac_addr,
 	.ndo_tx_timeout = xge_timeout,
 	.ndo_get_stats64 = xge_get_stats64,
@@ -388,6 +585,7 @@ static int xge_probe(struct platform_device *pdev)
 	if (ret)
 		goto err;
 
+	netif_napi_add(ndev, &pdata->napi, xge_napi, NAPI_POLL_WEIGHT);
 	ret = register_netdev(ndev);
 	if (ret) {
 		netdev_err(ndev, "Failed to register netdev\n");
-- 
1.9.1
