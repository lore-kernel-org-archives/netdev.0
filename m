From: Arseny Solokha <asolokha@kb.kras.ru>
Subject: [PATCH 1/2] gianfar: handle map error in gfar_new_rxbdp()
Date: Fri,  5 Dec 2014 17:37:53 +0700
Message-ID: <1417775874-17775-2-git-send-email-asolokha@kb.kras.ru>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arseny Solokha <asolokha@kb.kras.ru>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arseny Solokha <asolokha@kb.kras.ru>

When DMA-API debugging is enabled in the kernel, it spews the following
upon upping the link:

fsl-gianfar ffe25000.ethernet: DMA-API: device driver failed to check map error[device address=0x0000000005f41012] [size=90 bytes] [map-
WARNING: at lib/dma-debug.c:1135
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G           O   3.18.0-rc7 #1
task: ee06f080 ti: effde000 task.ti: ee0b2000
NIP: c01d7c1c LR: c01d7c1c CTR: 00000000
REGS: effdfd40 TRAP: 0700   Tainted: G           O    (3.18.0-rc7)
MSR: 00021000 <CE,ME>  CR: 42804442  XER: 00000000

GPR00: c01d7c1c effdfdf0 ee06f080 00000097 00000001 c0066dd8 00000000 00000001
GPR08: 00000000 00000000 effde000 0000029e 00000000 00000000 c55fa740 ee0d6818
GPR16: r00000600 c5a6a9c0 ee0d6830 ee0d6850 ffff8100 00000008 00000000 c5bbc800
GPR24: c0730000 00029000 c0d0b828 c072c394 effdfe48 c075baec c0d0f020 ee308300
NIP [c01d7c1c] check_unmap+0x5b4/0xae4
LR [c01d7c1c] check_unmap+0x5b4/0xae4
Call Trace:
[effdfdf0] [c01d7c1c] check_unmap+0x5b4/0xae4 (unreliable)
[effdfe40] [c01d81c4] debug_dma_unmap_page+0x78/0x8c
[effdfec0] [c028b270] gfar_clean_rx_ring+0x114/0x4c0
[effdff30] [c028b814] gfar_poll_rx_sq+0x3c/0xa4
[effdff50] [c030c388] net_rx_action+0x130/0x1ac
[effdff80] [c00319e0] __do_softirq+0x134/0x240
[effdffe0] [c0031dd0] irq_exit+0xa4/0xc8
[effdfff0] [c000e01c] call_do_irq+0x24/0x3c
[ee0b3e60] [c0004a04] do_IRQ+0x8c/0x108
[ee0b3e80] [c0010068] ret_from_except+0x0/0x18
--- interrupt: 501 at arch_cpu_idle+0x24/0x5c
    LR = arch_cpu_idle+0x24/0x5c
[ee0b3f40] [c007d2e4] rcu_idle_enter+0xc8/0xcc (unreliable)
[ee0b3f50] [c006587c] cpu_startup_entry+0x1d4/0x29c
[ee0b3fa0] [c00111cc] start_secondary+0x364/0x478
[ee0b3ff0] [c000217c] __secondary_start+0x7c/0xc8
Instruction dump:
394adb30 80fc0018 811c001c 3c60c04f 5529103a 7cca482e 38639e60 813c0020
815c0024 90c10008 4cc63182 48240b01 <0fe00000> 3c60c04f 3863971c 4cc63182
---[ end trace 3eb7bf62ba1b80f8 ]---
oMapped at:
 [<c02887cc>] gfar_new_rxbdp.isra.4+0x120/0x16c
 [<c0288968>] gfar_init_bds+0x150/0x1b0
 [<c028a800>] startup_gfar+0x334/0x3d8
 [<c028ac64>] gfar_enet_open+0x2b8/0x460
 [<c03100c0>] __dev_open+0xdc/0x150

And the underlying code indeed doesn't perform the check.

Signed-off-by: Arseny Solokha <asolokha@kb.kras.ru>
---
 drivers/net/ethernet/freescale/gianfar.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4fdf0aa..f34ca55 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -117,8 +117,8 @@ static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
-static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-			   struct sk_buff *skb);
+static int gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
+			  struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -214,6 +214,8 @@ static int gfar_init_bds(struct net_device *ndev)
 				gfar_init_rxbdp(rx_queue, rxbdp,
 						rxbdp->bufPtr);
 			} else {
+				int ret;
+
 				skb = gfar_new_skb(ndev);
 				if (!skb) {
 					netdev_err(ndev, "Can't allocate RX buffers\n");
@@ -221,7 +223,11 @@ static int gfar_init_bds(struct net_device *ndev)
 				}
 				rx_queue->rx_skbuff[j] = skb;
 
-				gfar_new_rxbdp(rx_queue, rxbdp, skb);
+				ret = gfar_new_rxbdp(rx_queue, rxbdp, skb);
+				if (ret) {
+					netdev_err(ndev, "Buffer mapping error\n");
+					return ret;
+				}
 			}
 
 			rxbdp++;
@@ -2606,8 +2612,8 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	netdev_tx_completed_queue(txq, howmany, bytes_sent);
 }
 
-static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-			   struct sk_buff *skb)
+static int gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
+			  struct sk_buff *skb)
 {
 	struct net_device *dev = rx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
@@ -2615,7 +2621,12 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 
 	buf = dma_map_single(priv->dev, skb->data,
 			     priv->rx_buffer_size, DMA_FROM_DEVICE);
+	if (dma_mapping_error(priv->dev, buf))
+		return -EFAULT;
+
 	gfar_init_rxbdp(rx_queue, bdp, buf);
+
+	return 0;
 }
 
 static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
@@ -2805,6 +2816,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		struct sk_buff *newskb;
+		int rxbdpret;
 
 		rmb();
 
@@ -2854,7 +2866,15 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		rx_queue->rx_skbuff[rx_queue->skb_currx] = newskb;
 
 		/* Setup the new bdp */
-		gfar_new_rxbdp(rx_queue, bdp, newskb);
+		rxbdpret = gfar_new_rxbdp(rx_queue, bdp, newskb);
+		if (unlikely(rxbdpret)) {
+			/* We drop the frame if we failed to map a new DMA
+			 * buffer
+			 */
+			count_errors(bdp->status, dev);
+			dev_kfree_skb(newskb);
+			continue;
+		}
 
 		/* Update to the next pointer */
 		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
-- 
2.2.0
