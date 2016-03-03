From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 3 Mar 2016 11:36:01 +1100
Message-ID: <20160303113601.6abeef0c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:48755 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754945AbcCCAgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 19:36:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c

between commit:

  b081da5ee186 ("net/mlx5e: Add rx/tx bytes software counters")

from the net tree and commits:

  9879515895ff ("net/mlx5e: Add TX stateless offloads for tunneling")
  89db09eb5979 ("net/mlx5e: Add TX inner packet counters")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index bb4eeeb007de,c34f4f3e9537..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@@ -199,15 -203,21 +204,20 @@@ static netdev_tx_t mlx5e_sq_xmit(struc
  	}
  
  	if (skb_is_gso(skb)) {
- 		u32 payload_len;
- 
  		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
  		opcode       = MLX5_OPCODE_LSO;
- 		ihs          = skb_transport_offset(skb) + tcp_hdrlen(skb);
- 		payload_len  = skb->len - ihs;
+ 
+ 		if (skb->encapsulation) {
+ 			ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
+ 			sq->stats.tso_inner_packets++;
+ 			sq->stats.tso_inner_bytes += skb->len - ihs;
+ 		} else {
+ 			ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
+ 			sq->stats.tso_packets++;
+ 			sq->stats.tso_bytes += skb->len - ihs;
+ 		}
+ 
 -		wi->num_bytes = skb->len +
 -				(skb_shinfo(skb)->gso_segs - 1) * ihs;
 +		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
- 		sq->stats.tso_packets++;
- 		sq->stats.tso_bytes += payload_len;
  	} else {
  		bf = sq->bf_budget &&
  		     !skb->xmit_more &&
