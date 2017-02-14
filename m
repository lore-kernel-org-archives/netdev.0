From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 16:57:35 -0800
Message-ID: <1487033855.8227.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170213195858.5215-1-edumazet@google.com>
         <20170213195858.5215-9-edumazet@google.com>
         <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
         <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
         <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
         <CANn89iJfLu8ai1SDGDt5aowAGibdxumDA89Y44f6SjTTt+sGBg@mail.gmail.com>
         <CAKgT0UdgnKzJ8PJFPfvJiOSZQ3E3Sw5nWjyrROuERv0=-dxmxQ@mail.gmail.com>
         <CANn89iLgUsPDL0wbuHk5RaehzJ+TRLQ=WkVBMTB65scrEjO3Ug@mail.gmail.com>
         <CAKgT0Uex--jLtBtJ+wp8wmkZuUfTu7ktYTvBF9623Ztm_NrGxw@mail.gmail.com>
         <CANn89iJ+kn4ycP2HV_um5JUfPWpX9KJ0KFtXyx3562c=kCBYyQ@mail.gmail.com>
         <CAKgT0Uf-JhOn+OOyjO8GH5SepA68j36eSY2m-buWJ5AH_82o2g@mail.gmail.com>
         <1487033175.8227.37.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35367 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdBNA5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 19:57:38 -0500
Received: by mail-it0-f68.google.com with SMTP id 203so1695661ith.2
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 16:57:37 -0800 (PST)
In-Reply-To: <1487033175.8227.37.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Alex, be assured that I implemented the full thing, of course.

Patch was :

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index aa074e57ce06fb2842fa1faabd156c3cd2fe10f5..0ae1b544668d26c24044dbdefdd9b12253596ff9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -68,6 +68,7 @@ static int mlx4_alloc_page(struct mlx4_en_priv *priv,
        frag->page = page;
        frag->dma = dma;
        frag->page_offset = priv->rx_headroom;
+       frag->pagecnt_bias = 1;
        return 0;
 }
 
@@ -97,7 +98,7 @@ static void mlx4_en_free_frag(const struct mlx4_en_priv *priv,
        if (frag->page) {
                dma_unmap_page(priv->ddev, frag->dma,
                               PAGE_SIZE, priv->dma_dir);
-               __free_page(frag->page);
+               __page_frag_cache_drain(frag->page, frag->pagecnt_bias);
        }
        /* We need to clear all fields, otherwise a change of priv->log_rx_info
         * could lead to see garbage later in frag->page.
@@ -470,6 +471,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 {
        const struct mlx4_en_frag_info *frag_info = priv->frag_info;
        unsigned int truesize = 0;
+       unsigned int pagecnt_bias;
        int nr, frag_size;
        struct page *page;
        dma_addr_t dma;
@@ -491,9 +493,10 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
                                     frag_size);
 
                truesize += frag_info->frag_stride;
+               pagecnt_bias = frags->pagecnt_bias--;
                if (frag_info->frag_stride == PAGE_SIZE / 2) {
                        frags->page_offset ^= PAGE_SIZE / 2;
-                       release = page_count(page) != 1 ||
+                       release = page_count(page) != pagecnt_bias ||
                                  page_is_pfmemalloc(page) ||
                                  page_to_nid(page) != numa_mem_id();
                } else {
@@ -504,9 +507,13 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
                }
                if (release) {
                        dma_unmap_page(priv->ddev, dma, PAGE_SIZE, priv->dma_dir);
+                       __page_frag_cache_drain(page, --pagecnt_bias);
                        frags->page = NULL;
                } else {
-                       page_ref_inc(page);
+                       if (pagecnt_bias == 1) {
+                               page_ref_add(page, USHRT_MAX);
+                               frags->pagecnt_bias = USHRT_MAX;
+                       }
                }
 
                nr++;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 52f157cea7765ad6907c59aead357a158848b38d..0de5933fd56bda3db15b4aa33d2366eff98f4154 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -252,7 +252,12 @@ struct mlx4_en_tx_desc {
 struct mlx4_en_rx_alloc {
        struct page     *page;
        dma_addr_t      dma;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
        u32             page_offset;
+#else
+       u16             page_offset;
+#endif
+       u16 pagecnt_bias;
 };
 
 #define MLX4_EN_CACHE_SIZE (2 * NAPI_POLL_WEIGHT)
