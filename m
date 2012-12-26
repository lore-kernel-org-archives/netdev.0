From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT] forcedeth: Fix 'device driver failed to check map
 error' warnings
Date: Wed, 26 Dec 2012 14:45:50 -0600
Message-ID: <50db61fe.u8zB6nsB1I7ajQXN%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 3.8-rc1, there are WARNINGS that the driver is not checking for
DMA mapping errors. The warnings start with

------------[ cut here ]------------
WARNING: at lib/dma-debug.c:933 check_unmap+0x480/0x950()
Hardware name: HP Pavilion dv2700 Notebook PC
forcedeth 0000:00:0a.0: DMA-API: device driver failed to check
 map error[device address=0x00000000b176e002] [size=90 bytes] [mapped as single]

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Please check that the error returns are correctly done.

Thanks,

Larry
---

Index: wireless-testing-new/drivers/net/ethernet/nvidia/forcedeth.c
===================================================================
--- wireless-testing-new.orig/drivers/net/ethernet/nvidia/forcedeth.c
+++ wireless-testing-new/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1821,6 +1821,11 @@ static int nv_alloc_rx(struct net_device
 							     skb->data,
 							     skb_tailroom(skb),
 							     PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(np->pci_dev,
+						  np->put_rx_ctx->dma)) {
+				dev_kfree_skb_any(skb);
+				goto packet_dropped;
+			}
 			np->put_rx_ctx->dma_len = skb_tailroom(skb);
 			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
 			wmb();
@@ -1830,6 +1835,7 @@ static int nv_alloc_rx(struct net_device
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
+packet_dropped:
 			u64_stats_update_begin(&np->swstats_rx_syncp);
 			np->stat_rx_dropped++;
 			u64_stats_update_end(&np->swstats_rx_syncp);
@@ -1856,6 +1862,11 @@ static int nv_alloc_rx_optimized(struct
 							     skb->data,
 							     skb_tailroom(skb),
 							     PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(np->pci_dev,
+						  np->put_rx_ctx->dma)) {
+				dev_kfree_skb_any(skb);
+				goto packet_dropped;
+			}
 			np->put_rx_ctx->dma_len = skb_tailroom(skb);
 			np->put_rx.ex->bufhigh = cpu_to_le32(dma_high(np->put_rx_ctx->dma));
 			np->put_rx.ex->buflow = cpu_to_le32(dma_low(np->put_rx_ctx->dma));
@@ -1866,6 +1877,7 @@ static int nv_alloc_rx_optimized(struct
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
+packet_dropped:
 			u64_stats_update_begin(&np->swstats_rx_syncp);
 			np->stat_rx_dropped++;
 			u64_stats_update_end(&np->swstats_rx_syncp);
@@ -2217,6 +2229,9 @@ static netdev_tx_t nv_start_xmit(struct
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(np->pci_dev,
+					  np->put_tx_ctx->dma))
+			return NETDEV_TX_BUSY;
 		np->put_tx_ctx->dma_len = bcnt;
 		np->put_tx_ctx->dma_single = 1;
 		put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
@@ -2337,6 +2352,9 @@ static netdev_tx_t nv_start_xmit_optimiz
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(np->pci_dev,
+					  np->put_tx_ctx->dma))
+			return NETDEV_TX_BUSY;
 		np->put_tx_ctx->dma_len = bcnt;
 		np->put_tx_ctx->dma_single = 1;
 		put_tx->bufhigh = cpu_to_le32(dma_high(np->put_tx_ctx->dma));
@@ -5003,6 +5021,11 @@ static int nv_loopback_test(struct net_d
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
