From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] tg3: Be drop monitor friendly
Date: Thu, 24 Aug 2017 16:25:30 -0700
Message-ID: <20170824232530.16728-1-f.fainelli@gmail.com>
Cc: edumazet@gmail.com, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tg3_tx() does the normal packet TX completion,
tigon3_dma_hwbug_workaround() needs to allocate a new SKB that is
suitable for the DMA hardware bug, and finally tg3_free_rings() is doing
ring cleanup. Use dev_consume_skb_any() for these 3 locations to be SKB
drop monitor friendly.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d600c41fb1dc..8b8da7e32e24 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6587,7 +6587,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		pkts_compl++;
 		bytes_compl += skb->len;
 
-		dev_kfree_skb_any(skb);
+		dev_consume_skb_any(skb);
 
 		if (unlikely(tx_bug)) {
 			tg3_tx_recover(tp);
@@ -7829,7 +7829,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 		}
 	}
 
-	dev_kfree_skb_any(skb);
+	dev_consume_skb_any(skb);
 	*pskb = new_skb;
 	return ret;
 }
@@ -8543,7 +8543,7 @@ static void tg3_free_rings(struct tg3 *tp)
 			tg3_tx_skb_unmap(tnapi, i,
 					 skb_shinfo(skb)->nr_frags - 1);
 
-			dev_kfree_skb_any(skb);
+			dev_consume_skb_any(skb);
 		}
 		netdev_tx_reset_queue(netdev_get_tx_queue(tp->dev, j));
 	}
-- 
2.9.3
