From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH net 2/3] net: mvpp2: fix buffers' DMA handling on RX path
Date: Thu,  3 Dec 2015 15:20:50 +0100
Message-ID: <1449152451-2939-3-git-send-email-mw@semihalf.com>
References: <1449152451-2939-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, nadavh@marvell.com,
	alior@marvell.com, mw@semihalf.com, jaz@semihalf.com,
	tn@semihalf.com, <stable@vger.kernel.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33374 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760175AbbLCOUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 09:20:31 -0500
Received: by lfaz4 with SMTP id z4so91517917lfa.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 06:20:29 -0800 (PST)
In-Reply-To: <1449152451-2939-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each allocated buffer, whose pointer is put into BM pool is DMA-mapped.
Hence it should be properly unmapped after usage or when removing buffers
from pool.

This commit fixes DMA handling on RX path by adding dma_unmap_single() in
mvpp2_rx() and in mvpp2_bufs_free(). The latter function's argument number
had to be increased for this purpose.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>

Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375
network unit")

Cc: <stable@vger.kernel.org> # v3.18+
---
 drivers/net/ethernet/marvell/mvpp2.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 95db519..eaef461 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3413,16 +3413,23 @@ static void mvpp2_bm_pool_bufsize_set(struct mvpp2 *priv,
 }
 
 /* Free all buffers from the pool */
-static void mvpp2_bm_bufs_free(struct mvpp2 *priv, struct mvpp2_bm_pool *bm_pool)
+static void mvpp2_bm_bufs_free(struct device *dev, struct mvpp2 *priv,
+			       struct mvpp2_bm_pool *bm_pool)
 {
 	int i;
 
 	for (i = 0; i < bm_pool->buf_num; i++) {
+		dma_addr_t buf_phys_addr;
 		u32 vaddr;
 
 		/* Get buffer virtual address (indirect access) */
-		mvpp2_read(priv, MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
+		buf_phys_addr = mvpp2_read(priv,
+					   MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
 		vaddr = mvpp2_read(priv, MVPP2_BM_VIRT_ALLOC_REG);
+
+		dma_unmap_single(dev, buf_phys_addr,
+				 bm_pool->buf_size, DMA_FROM_DEVICE);
+
 		if (!vaddr)
 			break;
 		dev_kfree_skb_any((struct sk_buff *)vaddr);
@@ -3439,7 +3446,7 @@ static int mvpp2_bm_pool_destroy(struct platform_device *pdev,
 {
 	u32 val;
 
-	mvpp2_bm_bufs_free(priv, bm_pool);
+	mvpp2_bm_bufs_free(&pdev->dev, priv, bm_pool);
 	if (bm_pool->buf_num) {
 		WARN(1, "cannot free all buffers in pool %d\n", bm_pool->id);
 		return 0;
@@ -3692,7 +3699,8 @@ mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 				   MVPP2_BM_LONG_BUF_NUM :
 				   MVPP2_BM_SHORT_BUF_NUM;
 		else
-			mvpp2_bm_bufs_free(port->priv, new_pool);
+			mvpp2_bm_bufs_free(port->dev->dev.parent,
+					   port->priv, new_pool);
 
 		new_pool->pkt_size = pkt_size;
 
@@ -3756,7 +3764,7 @@ static int mvpp2_bm_update_mtu(struct net_device *dev, int mtu)
 	int pkt_size = MVPP2_RX_PKT_SIZE(mtu);
 
 	/* Update BM pool with new buffer size */
-	mvpp2_bm_bufs_free(port->priv, port_pool);
+	mvpp2_bm_bufs_free(dev->dev.parent, port->priv, port_pool);
 	if (port_pool->buf_num) {
 		WARN(1, "cannot free all buffers in pool %d\n", port_pool->id);
 		return -EIO;
@@ -5136,6 +5144,9 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 
 		skb = (struct sk_buff *)rx_desc->buf_cookie;
 
+		dma_unmap_single(dev->dev.parent, rx_desc->buf_phys_addr,
+				 bm_pool->buf_size, DMA_FROM_DEVICE);
+
 		rcvd_pkts++;
 		rcvd_bytes += rx_bytes;
 		atomic_inc(&bm_pool->in_use);
-- 
1.8.3.1
