From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 07/27] net: mvpp2: simplify mvpp2_bm_bufs_add()
Date: Wed, 21 Dec 2016 12:16:14 +0100
Message-ID: <1482318994-23488-8-git-send-email-thomas.petazzoni@free-electrons.com>
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

The mvpp2_bm_bufs_add() currently creates a fake cookie by calling
mvpp2_bm_cookie_pool_set(), just to be able to call
mvpp2_pool_refill(). But all what mvpp2_pool_refill() does is extract
the pool ID from the cookie, and call mvpp2_bm_pool_put() with this ID.

Instead of doing this convoluted thing, just call mvpp2_bm_pool_put()
directly, since we have the BM pool ID.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 868ef4c..98edcb6 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3626,7 +3626,6 @@ static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 {
 	struct sk_buff *skb;
 	int i, buf_size, total_size;
-	u32 bm;
 	dma_addr_t phys_addr;
 
 	buf_size = MVPP2_RX_BUF_SIZE(bm_pool->pkt_size);
@@ -3640,13 +3639,12 @@ static int mvpp2_bm_bufs_add(struct mvpp2_port *port,
 		return 0;
 	}
 
-	bm = mvpp2_bm_cookie_pool_set(0, bm_pool->id);
 	for (i = 0; i < buf_num; i++) {
 		skb = mvpp2_skb_alloc(port, bm_pool, &phys_addr, GFP_KERNEL);
 		if (!skb)
 			break;
 
-		mvpp2_pool_refill(port, bm, (u32)phys_addr, (u32)skb);
+		mvpp2_bm_pool_put(port, bm_pool->id, (u32)phys_addr, (u32)skb);
 	}
 
 	/* Update BM driver with number of buffers added to pool */
-- 
2.7.4
