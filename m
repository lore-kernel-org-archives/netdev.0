From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Tue, 14 Mar 2017 07:21:27 -0700
Message-ID: <1489501287.28631.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170313173432.GA31333@ast-mbp.thefacebook.com>
         <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
         <20170313183121.GA36306@ast-mbp.thefacebook.com>
         <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
         <20170313202300.GA52396@ast-mbp.thefacebook.com>
         <CANn89iK6+1KMuxv11TqvfNd2cWRPjWDNkFnO00uC15GMQfqs-g@mail.gmail.com>
         <20170313232137.GA77943@ast-mbp.thefacebook.com>
         <CANn89iL3ODh0xf=+P0gSYN-mGwACeeCO+OwtJzK5JEtOtMdPuw@mail.gmail.com>
         <20170313234050.GA82263@ast-mbp.thefacebook.com>
         <1489453331.28631.102.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170314045730.GA5211@ast-mbp.thefacebook.com>
         <CANn89i+y3ZSfb+3+W=0-5uGJ=gm0tr2sY033ZFmL2Xc4X6__eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36739 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdCNOVv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 10:21:51 -0400
Received: by mail-pg0-f66.google.com with SMTP id m5so450089pgk.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 07:21:41 -0700 (PDT)
In-Reply-To: <CANn89i+y3ZSfb+3+W=0-5uGJ=gm0tr2sY033ZFmL2Xc4X6__eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-14 at 06:34 -0700, Eric Dumazet wrote:

> So I will leave this to Mellanox for XDP tests and upstreaming this,
> and will stop arguing with you, this is going nowhere.

Tariq, I will send a v2, including these changes (plus the missing
include of yesterday)

One is to make sure high order allocations remove __GFP_DIRECT_RECLAIM

The other is changing mlx4_en_recover_from_oom() to increase by 
one rx_alloc_order instead of plain reset to rx_pref_alloc_order

Please test XDP and tell me if you find any issues ?
Thanks !

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a71554649c25383bb765fa8220bc9cd490247aee..cc41f2f145541b469b52e7014659d5fdbb7dac68 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -60,8 +60,10 @@ static struct page *mlx4_alloc_page(struct mlx4_en_priv *priv,
        if (unlikely(!ring->pre_allocated_count)) {
                unsigned int order = READ_ONCE(ring->rx_alloc_order);
 
-               page = __alloc_pages_node(node, gfp | __GFP_NOMEMALLOC |
-                                               __GFP_NOWARN | __GFP_NORETRY,
+               page = __alloc_pages_node(node, (gfp & ~__GFP_DIRECT_RECLAIM) |
+                                               __GFP_NOMEMALLOC |
+                                               __GFP_NOWARN |
+                                               __GFP_NORETRY,
                                          order);
                if (page) {
                        split_page(page, order);
@@ -412,12 +414,13 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 }
 
 /* Under memory pressure, each ring->rx_alloc_order might be lowered
- * to very small values. Periodically reset it to initial value for
+ * to very small values. Periodically increase t to initial value for
  * optimal allocations, in case stress is over.
  */
 void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
 {
        struct mlx4_en_rx_ring *ring;
+       unsigned int order;
        int ring_ind;
 
        if (!priv->port_up)
@@ -425,7 +428,9 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
 
        for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
                ring = priv->rx_ring[ring_ind];
-               WRITE_ONCE(ring->rx_alloc_order, ring->rx_pref_alloc_order);
+               order = min_t(unsigned int, ring->rx_alloc_order + 1,
+                             ring->rx_pref_alloc_order);
+               WRITE_ONCE(ring->rx_alloc_order, order);
        }
 }
 
