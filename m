From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 5/7] mlx4: use napi_alloc_skb API to get SKB bulk
 allocations
Date: Fri, 04 Mar 2016 14:02:05 +0100
Message-ID: <20160304130205.32651.4079.stgit@firesoul>
References: <20160304130054.32651.51776.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbcCDNCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 08:02:10 -0500
In-Reply-To: <20160304130054.32651.51776.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Activate the bulk alloc API, simply by changing mlx4 from using
netdev_alloc_skb() to using napi_alloc_skb().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 41440b2b20a3..d867060ea676 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -583,14 +583,15 @@ fail:
 static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 				      struct mlx4_en_rx_desc *rx_desc,
 				      struct mlx4_en_rx_alloc *frags,
-				      unsigned int length)
+				      unsigned int length,
+				      struct napi_struct *napi)
 {
 	struct sk_buff *skb;
 	void *va;
 	int used_frags;
 	dma_addr_t dma;
 
-	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
+	skb = napi_alloc_skb(napi, SMALL_PACKET_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
 		return NULL;
@@ -938,7 +939,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		}
 
 		/* GRO not possible, complete processing here */
-		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
+		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length, &cq->napi);
 		if (!skb) {
 			priv->stats.rx_dropped++;
 			goto next;
