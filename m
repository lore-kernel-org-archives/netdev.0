From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 2/4] net: calxedaxgmac: fix hang on rx refill
Date: Mon,  9 Jul 2012 19:16:08 -0500
Message-ID: <1341879370-23385-3-git-send-email-robherring2@gmail.com>
References: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Fix intermittent hangs in xgmac_rx_refill. If a ring buffer entry already
had an skb allocated, then xgmac_rx_refill would get stuck in a loop. This
can happen on a rx error when we just leave the skb allocated to the entry.

[ 7884.510000] INFO: rcu_preempt detected stall on CPU 0 (t=727315 jiffies)
[ 7884.510000] [<c0010a59>] (unwind_backtrace+0x1/0x98) from [<c006fd93>] (__rcu_pending+0x11b/0x2c4)
[ 7884.510000] [<c006fd93>] (__rcu_pending+0x11b/0x2c4) from [<c0070b95>] (rcu_check_callbacks+0xed/0x1a8)
[ 7884.510000] [<c0070b95>] (rcu_check_callbacks+0xed/0x1a8) from [<c0036abb>] (update_process_times+0x2b/0x48)
[ 7884.510000] [<c0036abb>] (update_process_times+0x2b/0x48) from [<c004e8fd>] (tick_sched_timer+0x51/0x94)
[ 7884.510000] [<c004e8fd>] (tick_sched_timer+0x51/0x94) from [<c0045527>] (__run_hrtimer+0x4f/0x1e8)
[ 7884.510000] [<c0045527>] (__run_hrtimer+0x4f/0x1e8) from [<c0046003>] (hrtimer_interrupt+0xd7/0x1e4)
[ 7884.510000] [<c0046003>] (hrtimer_interrupt+0xd7/0x1e4) from [<c00101d3>] (twd_handler+0x17/0x24)
[ 7884.510000] [<c00101d3>] (twd_handler+0x17/0x24) from [<c006be39>] (handle_percpu_devid_irq+0x59/0x114)
[ 7884.510000] [<c006be39>] (handle_percpu_devid_irq+0x59/0x114) from [<c0069aab>] (generic_handle_irq+0x17/0x2c)
[ 7884.510000] [<c0069aab>] (generic_handle_irq+0x17/0x2c) from [<c000cc8d>] (handle_IRQ+0x35/0x7c)
[ 7884.510000] [<c000cc8d>] (handle_IRQ+0x35/0x7c) from [<c033b153>] (__irq_svc+0x33/0xb8)
[ 7884.510000] [<c033b153>] (__irq_svc+0x33/0xb8) from [<c0244b06>] (xgmac_rx_refill+0x3a/0x140)
[ 7884.510000] [<c0244b06>] (xgmac_rx_refill+0x3a/0x140) from [<c02458ed>] (xgmac_poll+0x265/0x3bc)
[ 7884.510000] [<c02458ed>] (xgmac_poll+0x265/0x3bc) from [<c029fcbf>] (net_rx_action+0xc3/0x200)
[ 7884.510000] [<c029fcbf>] (net_rx_action+0xc3/0x200) from [<c0030cab>] (__do_softirq+0xa3/0x1bc)

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |   27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index c4fd2e3..3ca1d79 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -671,26 +671,23 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
 
 		p = priv->dma_rx + entry;
 
-		if (priv->rx_skbuff[entry] != NULL)
-			continue;
-
-		skb = __skb_dequeue(&priv->rx_recycle);
-		if (skb == NULL)
-			skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
-		if (unlikely(skb == NULL))
-			break;
-
-		priv->rx_skbuff[entry] = skb;
-		paddr = dma_map_single(priv->device, skb->data,
-					 priv->dma_buf_sz, DMA_FROM_DEVICE);
-		desc_set_buf_addr(p, paddr, priv->dma_buf_sz);
+		if (priv->rx_skbuff[entry] == NULL) {
+			skb = __skb_dequeue(&priv->rx_recycle);
+			if (skb == NULL)
+				skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
+			if (unlikely(skb == NULL))
+				break;
+
+			priv->rx_skbuff[entry] = skb;
+			paddr = dma_map_single(priv->device, skb->data,
+					       priv->dma_buf_sz, DMA_FROM_DEVICE);
+			desc_set_buf_addr(p, paddr, priv->dma_buf_sz);
+		}
 
 		netdev_dbg(priv->dev, "rx ring: head %d, tail %d\n",
 			priv->rx_head, priv->rx_tail);
 
 		priv->rx_head = dma_ring_incr(priv->rx_head, DMA_RX_RING_SZ);
-		/* Ensure descriptor is in memory before handing to h/w */
-		wmb();
 		desc_set_rx_owner(p);
 	}
 }
-- 
1.7.9.5
