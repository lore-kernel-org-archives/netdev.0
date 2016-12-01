From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 2/7] net: ethernet: ti: cpdma: fix desc re-queuing
Date: Thu, 1 Dec 2016 17:34:27 -0600
Message-ID: <20161201233432.6182-3-grygorii.strashko@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201233432.6182-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The currently processing cpdma descriptor with EOQ flag set may
contain two values in Next Descriptor Pointer field:
- valid pointer: means CPDMA missed addition of new desc in queue;
- null: no more descriptors in queue.
In the later case, it's not required to write to HDP register, but now
CPDMA does it.

Hence, add additional check for Next Descriptor Pointer != null in
cpdma_chan_process() function before writing in HDP register.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 0924014..379314f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -1152,7 +1152,7 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	chan->count--;
 	chan->stats.good_dequeue++;
 
-	if (status & CPDMA_DESC_EOQ) {
+	if ((status & CPDMA_DESC_EOQ) && chan->head) {
 		chan->stats.requeue++;
 		chan_write(chan, hdp, desc_phys(pool, chan->head));
 	}
-- 
2.10.1
