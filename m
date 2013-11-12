From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net:fec: fix WARNING caused by lack of calls to dma_mapping_error()
Date: Tue, 12 Nov 2013 10:54:49 +0800
Message-ID: <1384224889-8316-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:36067
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754234Ab3KLDQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 22:16:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable CONFIG_HAVE_DMA_API_DEBUG, the kernel dump warning:

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
the mapping is not checked and dump the error msg.

So, and dma_mapping_error() checking to fix the WARNING.

Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b2793b9..d93cb0c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -386,7 +386,11 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	 */
 	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
 			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
-
+	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+		bdp->cbd_bufaddr = 0;
+		netdev_err(ndev, "Tx DMA memory map failed\n");
+		return NETDEV_TX_OK;
+	}
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
@@ -1001,6 +1005,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
 				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
+		/* here dma mapping shouldn't be error, just avoid kernel dump */
+		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr))
+			netdev_err(ndev, "Rx DMA memory map failed\n");
 rx_processing_done:
 		/* Clear the status flags for this buffer */
 		status &= ~BD_ENET_RX_STATS;
@@ -1719,6 +1726,11 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+			fec_enet_free_buffers(ndev);
+			netdev_err(ndev, "Rx DMA memory map failed\n");
+			return -ENOMEM;
+		}
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 
 		if (fep->bufdesc_ex) {
-- 
1.7.2.rc3
