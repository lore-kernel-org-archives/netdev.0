From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_en: Copy exact header to SKB linear part
Date: Thu,  8 May 2014 15:50:34 +0300
Message-ID: <1399553434-25617-3-git-send-email-amirv@mellanox.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54057 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754530AbaEHMuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 08:50:54 -0400
In-Reply-To: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

When copy received packet header to the linear section of the SKB,
Copy the exact header (best effort) and not the max possible header,
using the new network helper function __net_get_headlen.
It will return the size of the header up to the latest known header.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index ba049ae..e8b1787 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -566,6 +566,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	void *va;
 	int used_frags;
 	dma_addr_t dma;
+	int hdrlen;
 
 	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
 	if (!skb) {
@@ -598,15 +599,16 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		skb_shinfo(skb)->nr_frags = used_frags;
 
 		/* Copy headers into the skb linear buffer */
-		memcpy(skb->data, va, HEADER_COPY_SIZE);
-		skb->tail += HEADER_COPY_SIZE;
+		hdrlen = __net_get_headlen(va, SMALL_PACKET_SIZE);
+		memcpy(skb->data, va, ALIGN(hdrlen, sizeof(long)));
+		skb->tail += hdrlen;
 
 		/* Skip headers in first fragment */
-		skb_shinfo(skb)->frags[0].page_offset += HEADER_COPY_SIZE;
+		skb_shinfo(skb)->frags[0].page_offset += hdrlen;
 
 		/* Adjust size of first fragment */
-		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], HEADER_COPY_SIZE);
-		skb->data_len = length - HEADER_COPY_SIZE;
+		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hdrlen);
+		skb->data_len = length - hdrlen;
 	}
 	return skb;
 }
-- 
1.8.3.4
