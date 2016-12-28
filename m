From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 06/11] net: mvpp2: simplify mvpp2_bm_bufs_add()
Date: Wed, 28 Dec 2016 17:46:02 +0100
Message-ID: <1482943567-12483-7-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47556 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751838AbcL1QqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:46:25 -0500
In-Reply-To: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index bfa9f77..8174f40 100644
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
