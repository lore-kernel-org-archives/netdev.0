From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_en: Copy exact header to SKB linear part
Date: Mon, 28 Jul 2014 13:14:11 +0300
Message-ID: <1406542451-8857-3-git-send-email-amirv@mellanox.com>
References: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50037 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751811AbaG1KOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 06:14:37 -0400
In-Reply-To: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on patch from Eric Dumazet
When copy received packet header to the linear section of the SKB,
Copy the exact header (best effort) and not the max possible header,
using the new network helper function __net_get_headlen.
It will return the size of the header up to the latest known header.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 9c909d2..c4471f1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -588,6 +588,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		skb_copy_to_linear_data(skb, va, length);
 		skb->tail += length;
 	} else {
+		unsigned int hlen;
 		/* Move relevant fragments to skb */
 		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, frags,
 							skb, length);
@@ -597,16 +598,18 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		}
 		skb_shinfo(skb)->nr_frags = used_frags;
 
+		hlen = eth_frame_headlen(va, length);
+
 		/* Copy headers into the skb linear buffer */
-		memcpy(skb->data, va, HEADER_COPY_SIZE);
-		skb->tail += HEADER_COPY_SIZE;
+		memcpy(skb->data, va, hlen);
+		skb->tail += hlen;
 
 		/* Skip headers in first fragment */
-		skb_shinfo(skb)->frags[0].page_offset += HEADER_COPY_SIZE;
+		skb_shinfo(skb)->frags[0].page_offset += hlen;
 
 		/* Adjust size of first fragment */
-		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], HEADER_COPY_SIZE);
-		skb->data_len = length - HEADER_COPY_SIZE;
+		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hlen);
+		skb->data_len = length - hlen;
 	}
 	return skb;
 }
-- 
1.8.3.4
