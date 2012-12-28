From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] forcedeth: Fix WARNINGS that result when DMA mapping is not checked
Date: Thu, 27 Dec 2012 21:25:41 -0600
Message-ID: <1356665141-4498-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linville@tuxdriver.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 3.8-rc1, the first call of pci_map_single() that is not checked
with a corresponding pci_dma_mapping_error() call results in a warning
with a splat as follows:

WARNING: at lib/dma-debug.c:933 check_unmap+0x480/0x950()
Hardware name: HP Pavilion dv2700 Notebook PC
forcedeth 0000:00:0a.0: DMA-API: device driver failed to check
 map error[device address=0x00000000b176e002] [size=90 bytes] [mapped as single]

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V1 => V2: Replaced dev_kfree_skb_any() calls with kfree_skb() in RX
	  Changed TX mapping errors to drop packet, update drop count
	  and return NETDEV_TX_OK
---

 drivers/net/ethernet/nvidia/forcedeth.c |   35 +++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 653487d..87fa591 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1821,6 +1821,11 @@ static int nv_alloc_rx(struct net_device *dev)
 							     skb->data,
 							     skb_tailroom(skb),
 							     PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(np->pci_dev,
+						  np->put_rx_ctx->dma)) {
+				kfree_skb(skb);
+				goto packet_dropped;
+			}
 			np->put_rx_ctx->dma_len = skb_tailroom(skb);
 			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
 			wmb();
@@ -1830,6 +1835,7 @@ static int nv_alloc_rx(struct net_device *dev)
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
+packet_dropped:
 			u64_stats_update_begin(&np->swstats_rx_syncp);
 			np->stat_rx_dropped++;
 			u64_stats_update_end(&np->swstats_rx_syncp);
@@ -1856,6 +1862,11 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 							     skb->data,
 							     skb_tailroom(skb),
 							     PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(np->pci_dev,
+						  np->put_rx_ctx->dma)) {
+				kfree_skb(skb);
+				goto packet_dropped;
+			}
 			np->put_rx_ctx->dma_len = skb_tailroom(skb);
 			np->put_rx.ex->bufhigh = cpu_to_le32(dma_high(np->put_rx_ctx->dma));
 			np->put_rx.ex->buflow = cpu_to_le32(dma_low(np->put_rx_ctx->dma));
@@ -1866,6 +1877,7 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
+packet_dropped:
 			u64_stats_update_begin(&np->swstats_rx_syncp);
 			np->stat_rx_dropped++;
 			u64_stats_update_end(&np->swstats_rx_syncp);
@@ -2217,6 +2229,15 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(np->pci_dev,
+					  np->put_tx_ctx->dma)) {
+			/* on DMA mapping error - drop the packet */
+			kfree_skb(skb);
+			u64_stats_update_begin(&np->swstats_tx_syncp);
+			np->stat_tx_dropped++;
+			u64_stats_update_end(&np->swstats_tx_syncp);
+			return NETDEV_TX_OK;
+		}
 		np->put_tx_ctx->dma_len = bcnt;
 		np->put_tx_ctx->dma_single = 1;
 		put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
@@ -2337,6 +2358,15 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(np->pci_dev,
+					  np->put_tx_ctx->dma)) {
+			/* on DMA mapping error - drop the packet */
+			kfree_skb(skb);
+			u64_stats_update_begin(&np->swstats_tx_syncp);
+			np->stat_tx_dropped++;
+			u64_stats_update_end(&np->swstats_tx_syncp);
+			return NETDEV_TX_OK;
+		}
 		np->put_tx_ctx->dma_len = bcnt;
 		np->put_tx_ctx->dma_single = 1;
 		put_tx->bufhigh = cpu_to_le32(dma_high(np->put_tx_ctx->dma));
@@ -5003,6 +5033,11 @@ static int nv_loopback_test(struct net_device *dev)
 	test_dma_addr = pci_map_single(np->pci_dev, tx_skb->data,
 				       skb_tailroom(tx_skb),
 				       PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(np->pci_dev,
+				  test_dma_addr)) {
+		dev_kfree_skb_any(tx_skb);
+		goto out;
+	}
 	pkt_data = skb_put(tx_skb, pkt_len);
 	for (i = 0; i < pkt_len; i++)
 		pkt_data[i] = (u8)(i & 0xff);
-- 
1.7.10.4
