From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 1/8] net/macb: only probe queues once and use stored values
Date: Tue, 31 Mar 2015 15:01:59 +0200
Message-ID: <1427806926-18887-2-git-send-email-nicolas.ferre@atmel.com>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<michal.simek@xilinx.com>, <punnaia@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When merging at91_ether and macb driver during 421d9df0628b (net/macb: merge
at91_ether driver into macb driver) the probe function has been split. The code
dealing with initialization of queues is now moved in macb_init() which needs
information computed in the parent macb_probe() function.
So, add the queue_mask information to the private structure and use it when
needed in macb_init().

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Acked-by: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---

Changes in v2:
- address Cyrille comment about exit condition of queue configuration loop

 drivers/net/ethernet/cadence/macb.c | 7 +++----
 drivers/net/ethernet/cadence/macb.h | 1 +
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a0a04b3638e6..ac1f18142f7e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2180,7 +2180,7 @@ static void macb_probe_queues(void __iomem *mem,
 static int macb_init(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
-	unsigned int hw_q, queue_mask, q, num_queues;
+	unsigned int hw_q, q;
 	struct macb *bp = netdev_priv(dev);
 	struct macb_queue *queue;
 	int err;
@@ -2226,10 +2226,8 @@ static int macb_init(struct platform_device *pdev)
 	 * register mapping but we don't want to test the queue index then
 	 * compute the corresponding register offset at run time.
 	 */
-	macb_probe_queues(bp->regs, &queue_mask, &num_queues);
-
 	for (hw_q = 0, q = 0; hw_q < MACB_MAX_QUEUES; ++hw_q) {
-		if (!(queue_mask & (1 << hw_q)))
+		if (!(bp->queue_mask & (1 << hw_q)))
 			continue;
 
 		queue = &bp->queues[q];
@@ -2715,6 +2713,7 @@ static int macb_probe(struct platform_device *pdev)
 	bp->dev = dev;
 	bp->regs = mem;
 	bp->num_queues = num_queues;
+	bp->queue_mask = queue_mask;
 	spin_lock_init(&bp->lock);
 
 	platform_set_drvdata(pdev, dev);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index bc6e35c40822..0b6afac91bfe 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -785,6 +785,7 @@ struct macb {
 	size_t			rx_buffer_size;
 
 	unsigned int		num_queues;
+	unsigned int		queue_mask;
 	struct macb_queue	queues[MACB_MAX_QUEUES];
 
 	spinlock_t		lock;
-- 
2.1.3
