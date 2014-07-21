From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 4/6] net: mvpp2: Simplify BM pool buffers freeing
Date: Mon, 21 Jul 2014 13:48:14 -0300
Message-ID: <1405961296-5846-5-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>,
	David Miller <davem@davemloft.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55272 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932679AbaGUQtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 12:49:35 -0400
In-Reply-To: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all the users of mvpp2_bm_bufs_free() have been fixed, we can safely
clean the function prototype.

The function is always called to release all the buffers in a BM pool, and
the number of buffers freed is not needed. Therefore, we change the return
to a void, and remove the "num" parameter. This is a cosmetic change, to
make the code slightly cleaner.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 43d3391..b009eee 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3385,17 +3385,12 @@ static void mvpp2_bm_pool_bufsize_set(struct mvpp2 *priv,
 	mvpp2_write(priv, MVPP2_POOL_BUF_SIZE_REG(bm_pool->id), val);
 }
 
-/* Free "num" buffers from the pool */
-static int mvpp2_bm_bufs_free(struct mvpp2 *priv,
-			      struct mvpp2_bm_pool *bm_pool, int num)
+/* Free all buffers from the pool */
+static void mvpp2_bm_bufs_free(struct mvpp2 *priv, struct mvpp2_bm_pool *bm_pool)
 {
 	int i;
 
-	if (num >= bm_pool->buf_num)
-		/* Free all buffers from the pool */
-		num = bm_pool->buf_num;
-
-	for (i = 0; i < num; i++) {
+	for (i = 0; i < bm_pool->buf_num; i++) {
 		u32 vaddr;
 
 		/* Get buffer virtual adress (indirect access) */
@@ -3408,7 +3403,6 @@ static int mvpp2_bm_bufs_free(struct mvpp2 *priv,
 
 	/* Update BM driver with number of buffers removed from pool */
 	bm_pool->buf_num -= i;
-	return i;
 }
 
 /* Cleanup pool */
@@ -3416,10 +3410,9 @@ static int mvpp2_bm_pool_destroy(struct platform_device *pdev,
 				 struct mvpp2 *priv,
 				 struct mvpp2_bm_pool *bm_pool)
 {
-	int num;
 	u32 val;
 
-	num = mvpp2_bm_bufs_free(priv, bm_pool, bm_pool->buf_num);
+	mvpp2_bm_bufs_free(priv, bm_pool);
 	if (bm_pool->buf_num) {
 		WARN(1, "cannot free all buffers in pool %d\n", bm_pool->id);
 		return 0;
@@ -3675,7 +3668,7 @@ mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 				   MVPP2_BM_LONG_BUF_NUM :
 				   MVPP2_BM_SHORT_BUF_NUM;
 		else
-			mvpp2_bm_bufs_free(port->priv, new_pool, pkts_num);
+			mvpp2_bm_bufs_free(port->priv, new_pool);
 
 		new_pool->pkt_size = pkt_size;
 
@@ -3748,7 +3741,7 @@ static int mvpp2_bm_update_mtu(struct net_device *dev, int mtu)
 	int pkt_size = MVPP2_RX_PKT_SIZE(mtu);
 
 	/* Update BM pool with new buffer size */
-	mvpp2_bm_bufs_free(port->priv, port_pool, pkts_num);
+	mvpp2_bm_bufs_free(port->priv, port_pool);
 	if (port_pool->buf_num) {
 		WARN(1, "cannot free all buffers in pool %d\n", port_pool->id);
 		return -EIO;
-- 
2.0.1
