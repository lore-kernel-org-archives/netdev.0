From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: only pull headers into skb head
Date: Fri, 05 Sep 2014 18:29:45 -0700
Message-ID: <1409966985.11872.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47334 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbaIFB3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 21:29:48 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so23406928pab.15
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 18:29:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use the new fancy eth_get_headlen() to pull exactly the headers
into skb->head.

This speeds up GRE traffic (or more generally tunneled traffuc),
as GRO can aggregate up to 17 MSS per GRO packet instead of 8.

(Pulling too much data was forcing GRO to keep 2 frags per MSS)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b7da466a20d8..14686b6f4bc5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -588,6 +588,8 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		skb_copy_to_linear_data(skb, va, length);
 		skb->tail += length;
 	} else {
+		unsigned int pull_len;
+
 		/* Move relevant fragments to skb */
 		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, frags,
 							skb, length);
@@ -597,16 +599,17 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		}
 		skb_shinfo(skb)->nr_frags = used_frags;
 
+		pull_len = eth_get_headlen(va, SMALL_PACKET_SIZE);
 		/* Copy headers into the skb linear buffer */
-		memcpy(skb->data, va, HEADER_COPY_SIZE);
-		skb->tail += HEADER_COPY_SIZE;
+		memcpy(skb->data, va, pull_len);
+		skb->tail += pull_len;
 
 		/* Skip headers in first fragment */
-		skb_shinfo(skb)->frags[0].page_offset += HEADER_COPY_SIZE;
+		skb_shinfo(skb)->frags[0].page_offset += pull_len;
 
 		/* Adjust size of first fragment */
-		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], HEADER_COPY_SIZE);
-		skb->data_len = length - HEADER_COPY_SIZE;
+		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], pull_len);
+		skb->data_len = length - pull_len;
 	}
 	return skb;
 }
