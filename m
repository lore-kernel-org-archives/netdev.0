From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 4/7] net: netcp: add error check to netcp_allocate_rx_buf()
Date: Wed, 23 Sep 2015 13:37:08 -0400
Message-ID: <1443029831-22035-5-git-send-email-m-karicheri2@ti.com>
References: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, if netcp_allocate_rx_buf() fails due no descriptors
in the rx free descriptor queue, inside the netcp_rxpool_refill() function
the iterative loop to fill buffers doesn't terminate right away. So modify
the netcp_allocate_rx_buf() to return an error code and use it break the
loop when there is error.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index cf693de..97e2629 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -801,7 +801,7 @@ static void netcp_rxpool_free(struct netcp_intf *netcp)
 	netcp->rx_pool = NULL;
 }
 
-static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
+static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 {
 	struct knav_dma_desc *hwdesc;
 	unsigned int buf_len, dma_sz;
@@ -815,7 +815,7 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	hwdesc = knav_pool_desc_get(netcp->rx_pool);
 	if (IS_ERR_OR_NULL(hwdesc)) {
 		dev_dbg(netcp->ndev_dev, "out of rx pool desc\n");
-		return;
+		return -ENOMEM;
 	}
 
 	if (likely(fdq == 0)) {
@@ -867,25 +867,26 @@ static void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 	knav_pool_desc_map(netcp->rx_pool, hwdesc, sizeof(*hwdesc), &dma,
 			   &dma_sz);
 	knav_queue_push(netcp->rx_fdq[fdq], dma, sizeof(*hwdesc), 0);
-	return;
+	return 0;
 
 fail:
 	knav_pool_desc_put(netcp->rx_pool, hwdesc);
+	return -ENOMEM;
 }
 
 /* Refill Rx FDQ with descriptors & attached buffers */
 static void netcp_rxpool_refill(struct netcp_intf *netcp)
 {
 	u32 fdq_deficit[KNAV_DMA_FDQ_PER_CHAN] = {0};
-	int i;
+	int i, ret = 0;
 
 	/* Calculate the FDQ deficit and refill */
 	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN && netcp->rx_fdq[i]; i++) {
 		fdq_deficit[i] = netcp->rx_queue_depths[i] -
 				 knav_queue_get_count(netcp->rx_fdq[i]);
 
-		while (fdq_deficit[i]--)
-			netcp_allocate_rx_buf(netcp, i);
+		while (fdq_deficit[i]-- && !ret)
+			ret = netcp_allocate_rx_buf(netcp, i);
 	} /* end for fdqs */
 }
 
-- 
1.9.1
