From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 net-next 5/6] drivers: net: xgene-v2: Add transmit and
 receive
Date: Tue,  7 Mar 2017 17:08:44 -0800
Message-ID: <1488935325-13603-6-git-send-email-isubramanian@apm.com>
References: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
 f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/ethernet/apm/xgene-v2/main.c   | 248 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene-v2/main.h   |   1 +
 6 files changed, 267 insertions(+), 1 deletion(-)
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
index c96b4cc..b16ef43 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.c
+++ b/drivers/net/ethernet/apm/xgene-v2/main.c
@@ -113,7 +113,7 @@ static int xge_refill_buffers(struct net_device *ndev, u32 nbuf)
 		raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, addr_lo) |
 					   SET_BITS(NEXT_DESC_ADDRH, addr_hi) |
 					   SET_BITS(PKT_ADDRH,
-						    dma_addr >> PKT_ADDRL_LEN));
+						    upper_32_bits(dma_addr)));
 
 		dma_wmb();
 		raw_desc->m0 = cpu_to_le64(SET_BITS(PKT_ADDRL, dma_addr) |
@@ -177,6 +177,194 @@ static void xge_free_irq(struct net_device *ndev)
 	devm_free_irq(dev, pdata->resources.irq, pdata);
 }
 
+static bool is_tx_slot_available(struct xge_raw_desc *raw_desc)
+{
+	if (GET_BITS(E, le64_to_cpu(raw_desc->m0)) &&
+	    (GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0)) == SLOT_EMPTY))
+		return true;
+
+	return false;
+}
+
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
+	if (!is_tx_slot_available(raw_desc)) {
+		netif_stop_queue(ndev);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Packet buffers should be 64B aligned */
+	pkt_buf = dma_zalloc_coherent(dev, XGENE_ENET_STD_MTU, &dma_addr,
+				      GFP_ATOMIC);
+	if (unlikely(!pkt_buf)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+	memcpy(pkt_buf, skb->data, len);
+
+	addr_hi = GET_BITS(NEXT_DESC_ADDRH, le64_to_cpu(raw_desc->m1));
+	addr_lo = GET_BITS(NEXT_DESC_ADDRL, le64_to_cpu(raw_desc->m1));
+	raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, addr_lo) |
+				   SET_BITS(NEXT_DESC_ADDRH, addr_hi) |
+				   SET_BITS(PKT_ADDRH,
+					    upper_32_bits(dma_addr)));
+
+	tx_ring->pkt_info[tail].skb = skb;
+	tx_ring->pkt_info[tail].dma_addr = dma_addr;
+	tx_ring->pkt_info[tail].pkt_buf = pkt_buf;
+
+	dma_wmb();
+
+	raw_desc->m0 = cpu_to_le64(SET_BITS(PKT_ADDRL, dma_addr) |
+				   SET_BITS(PKT_SIZE, len) |
+				   SET_BITS(E, 0));
+	skb_tx_timestamp(skb);
+	xge_wr_csr(pdata, DMATXCTRL, 1);
+
+	tx_ring->tail = (tail + 1) & (XGENE_ENET_NUM_DESC - 1);
+
+	return NETDEV_TX_OK;
+}
+
+static bool is_tx_hw_done(struct xge_raw_desc *raw_desc)
+{
+	if (GET_BITS(E, le64_to_cpu(raw_desc->m0)) &&
+	    !GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0)))
+		return true;
+
+	return false;
+}
+
+static void xge_txc_poll(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	struct xge_desc_ring *tx_ring;
+	struct xge_raw_desc *raw_desc;
+	dma_addr_t dma_addr;
+	struct sk_buff *skb;
+	void *pkt_buf;
+	u32 data;
+	u8 head;
+
+	tx_ring = pdata->tx_ring;
+	head = tx_ring->head;
+
+	data = xge_rd_csr(pdata, DMATXSTATUS);
+	if (!GET_BITS(TXPKTCOUNT, data))
+		return;
+
+	while (1) {
+		raw_desc = &tx_ring->raw_desc[head];
+
+		if (!is_tx_hw_done(raw_desc))
+			break;
+
+		dma_rmb();
+
+		skb = tx_ring->pkt_info[head].skb;
+		dma_addr = tx_ring->pkt_info[head].dma_addr;
+		pkt_buf = tx_ring->pkt_info[head].pkt_buf;
+		pdata->stats.tx_packets++;
+		pdata->stats.tx_bytes += skb->len;
+		dma_free_coherent(dev, XGENE_ENET_STD_MTU, pkt_buf, dma_addr);
+		dev_kfree_skb_any(skb);
+
+		/* clear pktstart address and pktsize */
+		raw_desc->m0 = cpu_to_le64(SET_BITS(E, 1) |
+					   SET_BITS(PKT_SIZE, SLOT_EMPTY));
+		xge_wr_csr(pdata, DMATXSTATUS, 1);
+
+		head = (head + 1) & (XGENE_ENET_NUM_DESC - 1);
+	}
+
+	if (netif_queue_stopped(ndev))
+		netif_wake_queue(ndev);
+
+	tx_ring->head = head;
+}
+
+static int xge_rx_poll(struct net_device *ndev, unsigned int budget)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	struct xge_desc_ring *rx_ring;
+	struct xge_raw_desc *raw_desc;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	int processed = 0;
+	u8 head, rx_error;
+	int i, ret;
+	u32 data;
+	u16 len;
+
+	rx_ring = pdata->rx_ring;
+	head = rx_ring->head;
+
+	data = xge_rd_csr(pdata, DMARXSTATUS);
+	if (!GET_BITS(RXPKTCOUNT, data))
+		return 0;
+
+	for (i = 0; i < budget; i++) {
+		raw_desc = &rx_ring->raw_desc[head];
+
+		if (GET_BITS(E, le64_to_cpu(raw_desc->m0)))
+			break;
+
+		dma_rmb();
+
+		skb = rx_ring->pkt_info[head].skb;
+		rx_ring->pkt_info[head].skb = NULL;
+		dma_addr = rx_ring->pkt_info[head].dma_addr;
+		len = GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0));
+		dma_unmap_single(dev, dma_addr, XGENE_ENET_STD_MTU,
+				 DMA_FROM_DEVICE);
+
+		rx_error = GET_BITS(D, le64_to_cpu(raw_desc->m2));
+		if (unlikely(rx_error)) {
+			pdata->stats.rx_errors++;
+			dev_kfree_skb_any(skb);
+			goto out;
+		}
+
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, ndev);
+
+		pdata->stats.rx_packets++;
+		pdata->stats.rx_bytes += len;
+		napi_gro_receive(&pdata->napi, skb);
+out:
+		ret = xge_refill_buffers(ndev, 1);
+		xge_wr_csr(pdata, DMARXSTATUS, 1);
+		xge_wr_csr(pdata, DMARXCTRL, 1);
+
+		if (ret)
+			break;
+
+		head = (head + 1) & (XGENE_ENET_NUM_DESC - 1);
+		processed++;
+	}
+
+	rx_ring->head = head;
+
+	return processed;
+}
+
 static void xge_delete_desc_ring(struct net_device *ndev,
 				 struct xge_desc_ring *ring)
 {
@@ -221,8 +409,10 @@ static void xge_delete_desc_rings(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
 
+	xge_txc_poll(ndev);
 	xge_delete_desc_ring(ndev, pdata->tx_ring);
 
+	xge_rx_poll(ndev, 64);
 	xge_free_buffers(ndev);
 	xge_delete_desc_ring(ndev, pdata->rx_ring);
 }
@@ -333,6 +523,25 @@ static int xge_close(struct net_device *ndev)
 	return 0;
 }
 
+static int xge_napi(struct napi_struct *napi, const int budget)
+{
+	struct net_device *ndev = napi->dev;
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	int processed;
+
+	pdata = netdev_priv(ndev);
+
+	xge_txc_poll(ndev);
+	processed = xge_rx_poll(ndev, budget);
+
+	if (processed < budget) {
+		napi_complete_done(napi, processed);
+		xge_intr_enable(pdata);
+	}
+
+	return processed;
+}
+
 static int xge_set_mac_addr(struct net_device *ndev, void *addr)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
@@ -347,6 +556,41 @@ static int xge_set_mac_addr(struct net_device *ndev, void *addr)
 	return 0;
 }
 
+static bool is_tx_pending(struct xge_raw_desc *raw_desc)
+{
+	if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)))
+		return true;
+
+	return false;
+}
+
+static void xge_free_pending_skb(struct net_device *ndev)
+{
+	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	struct xge_desc_ring *tx_ring;
+	struct xge_raw_desc *raw_desc;
+	dma_addr_t dma_addr;
+	struct sk_buff *skb;
+	void *pkt_buf;
+	int i;
+
+	tx_ring = pdata->tx_ring;
+
+	for (i = 0; i < XGENE_ENET_NUM_DESC; i++) {
+		raw_desc = &tx_ring->raw_desc[i];
+
+		if (!is_tx_pending(raw_desc))
+			continue;
+
+		skb = tx_ring->pkt_info[i].skb;
+		dma_addr = tx_ring->pkt_info[i].dma_addr;
+		pkt_buf = tx_ring->pkt_info[i].pkt_buf;
+		dma_free_coherent(dev, XGENE_ENET_STD_MTU, pkt_buf, dma_addr);
+		dev_kfree_skb_any(skb);
+	}
+}
+
 static void xge_timeout(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
@@ -389,11 +633,13 @@ static void xge_get_stats64(struct net_device *ndev,
 
 	storage->rx_packets += stats->rx_packets;
 	storage->rx_bytes += stats->rx_bytes;
+	storage->rx_errors += stats->rx_errors;
 }
 
 static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_open = xge_open,
 	.ndo_stop = xge_close,
+	.ndo_start_xmit = xge_start_xmit,
 	.ndo_set_mac_address = xge_set_mac_addr,
 	.ndo_tx_timeout = xge_timeout,
 	.ndo_get_stats64 = xge_get_stats64,
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.h b/drivers/net/ethernet/apm/xgene-v2/main.h
index a2f8712..ada7b0e 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.h
+++ b/drivers/net/ethernet/apm/xgene-v2/main.h
@@ -55,6 +55,7 @@ struct xge_stats {
 	u64 tx_bytes;
 	u64 rx_packets;
 	u64 rx_bytes;
+	u64 rx_errors;
 };
 
 /* ethernet private data */
-- 
1.9.1
