From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] mv643xx_eth: Fix a DMA-API error handling warning
Date: Tue, 18 Jun 2013 19:33:28 +0200
Message-ID: <1371576808-21907-1-git-send-email-lkundrak@v3.sk>
Cc: Lubomir Rintel <lkundrak@v3.sk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We check the failure status just prior to unmap, since it would be too much of
a hassle to roll back commands we already started to enqueue if we handled it
just after the map.

This way we at least avoid a lockup on reclaim, the card presumably didn't
succeed DMA-ing to a bogus address anyway.

------------[ cut here ]------------
WARNING: at lib/dma-debug.c:933 check_unmap+0x75c/0x840()
mv643xx_eth_port mv643xx_eth_port.0: DMA-API: device driver failed to check map error[device address=0x000000001cc3f1c2] [size=90 bytes] [mapped as single]
Modules linked in:
 bnep bluetooth rfkill marvell mv643xx_eth mv_cesa leds_gpio uinput mmc_block sata_mv mvsdio mmc_core usb_storage
[<c000f838>] (unwind_backtrace+0x0/0x124) from [<c001bbec>] (warn_slowpath_common+0x54/0x6c)
[<c001bbec>] (warn_slowpath_common+0x54/0x6c) from [<c001bc9c>] (warn_slowpath_fmt+0x34/0x44)
[<c001bc9c>] (warn_slowpath_fmt+0x34/0x44) from [<c0281040>] (check_unmap+0x75c/0x840)
[<c0281040>] (check_unmap+0x75c/0x840) from [<c02811f0>] (debug_dma_unmap_page+0x64/0x70)
[<c02811f0>] (debug_dma_unmap_page+0x64/0x70) from [<bf068fc0>] (txq_reclaim+0x218/0x264 [mv643xx_eth])
[<bf068fc0>] (txq_reclaim+0x218/0x264 [mv643xx_eth]) from [<bf069854>] (mv643xx_eth_poll+0x2a8/0x6b8 [mv643xx_eth])
[<bf069854>] (mv643xx_eth_poll+0x2a8/0x6b8 [mv643xx_eth]) from [<c040e808>] (net_rx_action+0x9c/0x338)
[<c040e808>] (net_rx_action+0x9c/0x338) from [<c002483c>] (__do_softirq+0x16c/0x398)
[<c002483c>] (__do_softirq+0x16c/0x398) from [<c0024e40>] (irq_exit+0x5c/0xc0)
[<c0024e40>] (irq_exit+0x5c/0xc0) from [<c0009ba4>] (handle_IRQ+0x6c/0x8c)
[<c0009ba4>] (handle_IRQ+0x6c/0x8c) from [<c05167b8>] (__irq_svc+0x38/0x80)
[<c05167b8>] (__irq_svc+0x38/0x80) from [<c02629e4>] (memcpy+0x24/0x3a4)
---[ end trace 0c94555a37c67b61 ]---
Mapped at:
 [<c0281818>] debug_dma_map_page+0x48/0x11c
 [<bf068494>] mv643xx_eth_xmit+0x41c/0x5a8 [mv643xx_eth]
 [<c0410a6c>] dev_hard_start_xmit+0x308/0x6cc
 [<c042c720>] sch_direct_xmit+0x74/0x2d4
 [<c041148c>] dev_queue_xmit+0x4b8/0x8dc

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d1cbfb1..7e14c83 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -519,8 +519,13 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		if (rxq->rx_curr_desc == rxq->rx_ring_size)
 			rxq->rx_curr_desc = 0;
 
-		dma_unmap_single(mp->dev->dev.parent, rx_desc->buf_ptr,
-				 rx_desc->buf_size, DMA_FROM_DEVICE);
+		if (dma_mapping_error(mp->dev->dev.parent, rx_desc->buf_ptr)) {
+			dev_err(mp->dev->dev.parent,
+				"Receive buffer could not be mapped, skipping unmap.\n");
+		} else {
+			dma_unmap_single(mp->dev->dev.parent, rx_desc->buf_ptr,
+					 rx_desc->buf_size, DMA_FROM_DEVICE);
+		}
 		rxq->rx_desc_count--;
 		rx++;
 
@@ -902,12 +907,19 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			mp->dev->stats.tx_errors++;
 		}
 
-		if (cmd_sts & TX_FIRST_DESC) {
-			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
-					 desc->byte_cnt, DMA_TO_DEVICE);
+		if (dma_mapping_error(mp->dev->dev.parent, desc->buf_ptr)) {
+			dev_err(mp->dev->dev.parent,
+				"Transmit buffer could not be mapped, skipping unmap.\n");
 		} else {
-			dma_unmap_page(mp->dev->dev.parent, desc->buf_ptr,
-				       desc->byte_cnt, DMA_TO_DEVICE);
+			if (cmd_sts & TX_FIRST_DESC) {
+				dma_unmap_single(mp->dev->dev.parent,
+						desc->buf_ptr, desc->byte_cnt,
+						DMA_TO_DEVICE);
+			} else {
+				dma_unmap_page(mp->dev->dev.parent,
+						desc->buf_ptr, desc->byte_cnt,
+						DMA_TO_DEVICE);
+			}
 		}
 
 		dev_kfree_skb(skb);
-- 
1.7.1
