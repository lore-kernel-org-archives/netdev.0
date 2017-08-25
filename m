From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] tg3: Be drop monitor friendly
Date: Thu, 24 Aug 2017 17:47:11 -0700
Message-ID: <20170825004711.19793-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@gmail.com,
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
tigon3_dma_hwbug_workaround() and tg3_tso_bug() both need to allocate a
new SKB that is suitable to workaround HW bugs, and finally
tg3_free_rings() is doing ring cleanup. Use dev_consume_skb_any() for
these 3 locations to be SKB drop monitor friendly.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- also included tg3_tso_bug() as indicated by Michael

 drivers/net/ethernet/broadcom/tg3.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d600c41fb1dc..af33dc15c55f 100644
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
@@ -7882,7 +7882,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 	} while (segs);
 
 tg3_tso_bug_end:
-	dev_kfree_skb_any(skb);
+	dev_consume_skb_any(skb);
 
 	return NETDEV_TX_OK;
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
