From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 7/8] net/mlx5e: Count GSO packets correctly
Date: Tue, 21 Mar 2017 09:15:19 -0700
Message-ID: <1490112919.16816.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
         <20170321135919.25018-8-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Gal Pressman <galp@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33711 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932698AbdCUQPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:15:22 -0400
Received: by mail-pf0-f195.google.com with SMTP id p189so17126799pfp.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 09:15:21 -0700 (PDT)
In-Reply-To: <20170321135919.25018-8-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-21 at 15:59 +0200, Saeed Mahameed wrote:
> From: Gal Pressman <galp@mellanox.com>
> 
> TX packets statistics ('tx_packets' counter) used to count GSO packets
> as one, even though it contains multiple segments.
> This patch will increment the counter by the number of segments, and
> align the driver with the behavior of other drivers in the stack.
> 
> Note that no information is lost in this patch due to 'tx_tso_packets'
> counter existence.

> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Cc: kernel-team@fb.com
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
> index f193128bac4b..57f5e2d7ebd1 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
> @@ -274,15 +274,18 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
>  			sq->stats.tso_bytes += skb->len - ihs;
>  		}
>  
> +		sq->stats.packets += skb_shinfo(skb)->gso_segs;
>  		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;

This reminds me that mlx4 does not trust gso_segs yet, not sure why.


diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e0c5ffb3e3a6607456e1f191b0b8c8becfc71219..3ba89bc43d74d8c023776079bcd0bbadd70fb5c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -978,8 +978,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		ring->tso_packets++;
 
-		i = ((skb->len - lso_header_size) / shinfo->gso_size) +
-			!!((skb->len - lso_header_size) % shinfo->gso_size);
+		i = shinfo->gso_segs;
 		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
 		ring->packets += i;
 	} else {
