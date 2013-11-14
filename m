From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net:fec: fix WARNING caused by lack of calls to dma_mapping_error()
Date: Thu, 14 Nov 2013 09:30:31 +0800
Message-ID: <1384392631-2059-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0185.outbound.messaging.microsoft.com ([213.199.154.185]:10743
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150Ab3KNBwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 20:52:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver fails to check the results of DMA mapping and results in
the following warning: (with kernel config "CONFIG_DMA_API_DEBUG" enable)

------------[ cut here ]------------
WARNING: at lib/dma-debug.c:937 check_unmap+0x43c/0x7d8()
fec 2188000.ethernet: DMA-API: device driver failed to check map
error[device address=0x00000000383a8040] [size=2048 bytes] [mapped as single]

Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.17-16827-g9cdb0ba-dirty #188
[<80013c4c>] (unwind_backtrace+0x0/0xf8) from [<80011704>] (show_stack+0x10/0x14)
[<80011704>] (show_stack+0x10/0x14) from [<80025614>] (warn_slowpath_common+0x4c/0x6c)
[<80025614>] (warn_slowpath_common+0x4c/0x6c) from [<800256c8>] (warn_slowpath_fmt+0x30/0x40)
[<800256c8>] (warn_slowpath_fmt+0x30/0x40) from [<8026bfdc>] (check_unmap+0x43c/0x7d8)
[<8026bfdc>] (check_unmap+0x43c/0x7d8) from [<8026c584>] (debug_dma_unmap_page+0x6c/0x78)
[<8026c584>] (debug_dma_unmap_page+0x6c/0x78) from [<8038049c>] (fec_enet_rx_napi+0x254/0x8a8)
[<8038049c>] (fec_enet_rx_napi+0x254/0x8a8) from [<804dc8c0>] (net_rx_action+0x94/0x160)
[<804dc8c0>] (net_rx_action+0x94/0x160) from [<8002c758>] (__do_softirq+0xe8/0x1d0)
[<8002c758>] (__do_softirq+0xe8/0x1d0) from [<8002c8e8>] (do_softirq+0x4c/0x58)
[<8002c8e8>] (do_softirq+0x4c/0x58) from [<8002cb50>] (irq_exit+0x90/0xc8)
[<8002cb50>] (irq_exit+0x90/0xc8) from [<8000ea88>] (handle_IRQ+0x3c/0x94)
[<8000ea88>] (handle_IRQ+0x3c/0x94) from [<8000855c>] (gic_handle_irq+0x28/0x5c)
[<8000855c>] (gic_handle_irq+0x28/0x5c) from [<8000de00>] (__irq_svc+0x40/0x50)
Exception stack(0x815a5f38 to 0x815a5f80)
5f20:                                                       815a5f80 3b9aca00
5f40: 0fe52383 00000002 0dd8950e 00000002 81e7b080 00000000 00000000 815ac4d8
5f60: 806032ec 00000000 00000017 815a5f80 80059028 8041fc4c 60000013 ffffffff
[<8000de00>] (__irq_svc+0x40/0x50) from [<8041fc4c>] (cpuidle_enter_state+0x50/0xf0)
[<8041fc4c>] (cpuidle_enter_state+0x50/0xf0) from [<8041fd94>] (cpuidle_idle_call+0xa8/0x14c)
[<8041fd94>] (cpuidle_idle_call+0xa8/0x14c) from [<8000edac>] (arch_cpu_idle+0x10/0x4c)
[<8000edac>] (arch_cpu_idle+0x10/0x4c) from [<800582f8>] (cpu_startup_entry+0x60/0x130)
[<800582f8>] (cpu_startup_entry+0x60/0x130) from [<80bc7a48>] (start_kernel+0x2d0/0x328)
[<80bc7a48>] (start_kernel+0x2d0/0x328) from [<10008074>] (0x10008074)
---[ end trace c6edec32436e0042 ]---

Because dma-debug add new interfaces to debug dma mapping errors, pls refer
to: http://lwn.net/Articles/516640/

After dma mapping, it must call dma_mapping_error() to check mapping error,
otherwise the map_err_type alway is MAP_ERR_NOT_CHECKED, check_unmap() define
the mapping is not checked and dump the error msg. So,add dma_mapping_error()
checking to fix the WARNING

And RX DMA buffers are used repeatedly and the driver copies it into an skb,
fec_enet_rx() should not map or unmap, use dma_sync_single_for_cpu()/dma_sync_single_for_device()
instead of dma_map_single()/dma_unmap_single().

There have another potential issue:  fec_enet_rx() passes the DMA address to __va().
Physical and DMA addresses are *not* the same thing. They may differ if the device
is behind an IOMMU or bounce buffering was required, or just because there is a fixed
offset between the device and host physical addresses. Also fix it in this patch.

=============================================
V2: add net_ratelimit() to limit map err message.
    use dma_sync_single_for_cpu() instead of dma_map_single().
    fix the issue that pass DMA addresses to __va() to get virture address.
V1: initial send
=============================================

Signed-off-by: Fugang Duan <B38611@freescale.com>
Reviewed-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c |   31 +++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2793b9..4cbebf3 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -386,7 +386,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	 */
 	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
 			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
-
+	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+		bdp->cbd_bufaddr = 0;
+		fep->tx_skbuff[index] = NULL;
+		dev_kfree_skb_any(skb);
+		if (net_ratelimit())
+			netdev_err(ndev, "Tx DMA memory map failed\n");
+		return NETDEV_TX_OK;
+	}
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
@@ -861,6 +868,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	struct	bufdesc_ex *ebdp = NULL;
 	bool	vlan_packet_rcvd = false;
 	u16	vlan_tag;
+	int	index = 0;
 
 #ifdef CONFIG_M532x
 	flush_cache_all();
@@ -916,10 +924,15 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		ndev->stats.rx_packets++;
 		pkt_len = bdp->cbd_datlen;
 		ndev->stats.rx_bytes += pkt_len;
-		data = (__u8*)__va(bdp->cbd_bufaddr);
 
-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
+		if (fep->bufdesc_ex)
+			index = (struct bufdesc_ex *)bdp -
+				(struct bufdesc_ex *)fep->rx_bd_base;
+		else
+			index = bdp - fep->rx_bd_base;
+		data = fep->rx_skbuff[index]->data;
+		dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
+					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, pkt_len);
@@ -999,8 +1012,8 @@ fec_enet_rx(struct net_device *ndev, int budget)
 			napi_gro_receive(&fep->napi, skb);
 		}
 
-		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
-				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
+		dma_sync_single_for_device(&fep->pdev->dev, bdp->cbd_bufaddr,
+					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 rx_processing_done:
 		/* Clear the status flags for this buffer */
 		status &= ~BD_ENET_RX_STATS;
@@ -1719,6 +1732,12 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+			fec_enet_free_buffers(ndev);
+			if (net_ratelimit())
+				netdev_err(ndev, "Rx DMA memory map failed\n");
+			return -ENOMEM;
+		}
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 
 		if (fep->bufdesc_ex) {
-- 
1.7.2.rc3
