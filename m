From: Aisheng.Dong <b29396@freescale.com>
Subject: [PATCH 1/1] net/fec: do not pass NULL dev to DMA API
Date: Sat, 2 Apr 2011 14:39:51 +0800
Message-ID: <1301726391-7431-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Fec will crash when DMABOUNCE is enabled.
Unable to handle kernel NULL pointer dereference at virtual address 000000bc
pgd = 80004000
[000000bc] *pgd=00000000
Internal error: Oops: 5 [#1] PREEMPT
last sysfs file:
Modules linked in:
CPU: 0    Not tainted  (2.6.35.3-00845-g204c152-dirty #112)
PC is at dma_map_single+0x2c/0x2a0
LR is at fec_enet_interrupt+0x1d4/0x450

The reason is DMA API of dmabounce needs the dev passed in is not NULL.

Here we'd always pass in a struct device if there is one available
for using DMA API to improve the code robustness sicne it may not
always work when passing a NULL dev.

Signed-off-by: Aisheng.Dong <b29396@freescale.com>
---
 drivers/net/fec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index cd0282d..89a2ba4 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -527,7 +527,7 @@ fec_enet_rx(struct net_device *dev)
 		dev->stats.rx_bytes += pkt_len;
 		data = (__u8*)__va(bdp->cbd_bufaddr);
 
-	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
+		dma_unmap_single(&dev->dev, bdp->cbd_bufaddr, bdp->cbd_datlen,
         			DMA_FROM_DEVICE);
 
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
@@ -552,7 +552,7 @@ fec_enet_rx(struct net_device *dev)
 			netif_rx(skb);
 		}
 
-        	bdp->cbd_bufaddr = dma_map_single(NULL, data, bdp->cbd_datlen,
+		bdp->cbd_bufaddr = dma_map_single(&dev->dev, data, bdp->cbd_datlen,
 			DMA_FROM_DEVICE);
 rx_processing_done:
 		/* Clear the status flags for this buffer */
-- 
1.7.0.4
