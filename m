From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2: Support for byte queue limits
Date: Tue, 29 Nov 2011 22:53:05 +0100
Message-ID: <1322603585.2596.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53700 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1K2VxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 16:53:10 -0500
Received: by eeuu47 with SMTP id u47so1353122eeu.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 13:53:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to bnx2 to use byte queue limits.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d573169..787e175 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2810,6 +2810,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	u16 hw_cons, sw_cons, sw_ring_cons;
 	int tx_pkt = 0, index;
+	unsigned int tx_bytes = 0;
 	struct netdev_queue *txq;
 
 	index = (bnapi - bp->bnx2_napi);
@@ -2864,6 +2865,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		sw_cons = NEXT_TX_BD(sw_cons);
 
+		tx_bytes += skb->len;
 		dev_kfree_skb(skb);
 		tx_pkt++;
 		if (tx_pkt == budget)
@@ -2873,6 +2875,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	}
 
+	netdev_tx_completed_queue(txq, tx_pkt, tx_bytes);
 	txr->hw_tx_cons = hw_cons;
 	txr->tx_cons = sw_cons;
 
@@ -5393,6 +5396,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			}
 			dev_kfree_skb(skb);
 		}
+		netdev_tx_reset_queue(netdev_get_tx_queue(bp->dev, i));
 	}
 }
 
@@ -6546,6 +6550,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	txbd->tx_bd_vlan_tag_flags |= TX_BD_FLAGS_END;
 
+	netdev_tx_sent_queue(txq, skb->len);
+
 	prod = NEXT_TX_BD(prod);
 	txr->tx_prod_bseq += skb->len;
 
