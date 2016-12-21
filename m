From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 06/27] net: mvpp2: drop useless fields in
 mvpp2_bm_pool and related code
Date: Wed, 21 Dec 2016 12:16:13 +0100
Message-ID: <1482318994-23488-7-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Jason Cooper <jason@lakedaemon.net>, Hanna Hawa <hannah@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This commit drops dead code from the mvpp2 driver. The 'in_use' and
'in_use_thresh' fields of 'struct mvpp2_bm_pool' are
incremented/decremented/initialized in various places. But they are only
used in one place:

       if (is_recycle &&
           (atomic_read(&bm_pool->in_use) < bm_pool->in_use_thresh))
               return 0;

However 'is_recycle', passed as argument to mvpp2_rx_refill() is always
false. So in fact, this code is never reached, and the 'is_recycle'
argument is useless. So let's drop this code.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index fe854b3..868ef4c 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -930,10 +930,6 @@ struct mvpp2_bm_pool {
 
 	/* Ports using BM pool */
 	u32 port_map;
-
-	/* Occupied buffers indicator */
-	atomic_t in_use;
-	int in_use_thresh;
 };
 
 struct mvpp2_buff_hdr {
@@ -3399,7 +3395,6 @@ static int mvpp2_bm_pool_create(struct platform_device *pdev,
 	bm_pool->size = size;
 	bm_pool->pkt_size = 0;
 	bm_pool->buf_num = 0;
-	atomic_set(&bm_pool->in_use, 0);
 
 	return 0;
 }
@@ -3656,7 +3651,6 @@ static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 
 	/* Update BM driver with number of buffers added to pool */
 	bm_pool->buf_num += i;
-	bm_pool->in_use_thresh = bm_pool->buf_num / 4;
 
 	netdev_dbg(port->dev,
 		   "%s pool %d: pkt_size=%4d, buf_size=%4d, total_size=%4d\n",
@@ -4997,23 +4991,18 @@ static void mvpp2_rx_csum(struct mvpp2_port *port, u32 status,
 
 /* Reuse skb if possible, or allocate a new skb and add it to BM pool */
 static int mvpp2_rx_refill(struct mvpp2_port *port,
-			   struct mvpp2_bm_pool *bm_pool,
-			   u32 bm, int is_recycle)
+			   struct mvpp2_bm_pool *bm_pool, u32 bm)
 {
 	struct sk_buff *skb;
 	dma_addr_t phys_addr;
 
-	if (is_recycle &&
-	    (atomic_read(&bm_pool->in_use) < bm_pool->in_use_thresh))
-		return 0;
-
 	/* No recycle or too many buffers are in use, so allocate a new skb */
 	skb = mvpp2_skb_alloc(port, bm_pool, &phys_addr, GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
 
 	mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)skb);
-	atomic_dec(&bm_pool->in_use);
+
 	return 0;
 }
 
@@ -5139,7 +5128,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 
 		skb = (struct sk_buff *)rx_desc->buf_cookie;
 
-		err = mvpp2_rx_refill(port, bm_pool, bm, 0);
+		err = mvpp2_rx_refill(port, bm_pool, bm);
 		if (err) {
 			netdev_err(port->dev, "failed to refill BM pools\n");
 			goto err_drop_frame;
@@ -5150,7 +5139,6 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 
 		rcvd_pkts++;
 		rcvd_bytes += rx_bytes;
-		atomic_inc(&bm_pool->in_use);
 
 		skb_reserve(skb, MVPP2_MH_SIZE);
 		skb_put(skb, rx_bytes);
-- 
2.7.4
