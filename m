From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page recycling
Date: Mon, 13 Feb 2017 11:33:16 -0800
Message-ID: <CANn89iK9qQMsZ8imx5m2+yp5F0MhsnYruhpA1g6VFgqz3RHUqA@mail.gmail.com>
References: <20170209135838.16487-1-edumazet@google.com> <9b098a3d-aec0-4085-2cd5-ea3819927071@mellanox.com>
 <b7f2d119-3c84-b911-eeb4-880427299213@mellanox.com> <CANn89iJdVbQ2WNK=6pj65J=aBGOn8pXZvpDud_Dy9yFje30mjQ@mail.gmail.com>
 <5efe33e3-8009-683b-b913-1b97dce3fac2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:32967 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdBMTdS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 14:33:18 -0500
Received: by mail-io0-f176.google.com with SMTP id v96so77888816ioi.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 11:33:17 -0800 (PST)
In-Reply-To: <5efe33e3-8009-683b-b913-1b97dce3fac2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 12:50 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>

>
> MTU is changed from 1500 to 500, with VLAN configured.

Thanks, I now see what is happening.

mlx4_en_free_rx_buf() needs to clean whole rx_info buffer, not the
part between ring->cons & ring->prod,
otherwise we still could see garbage later.

I will include in v3 the appropriate fix.

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 31e3f92b45f47f10055552f0cfe2f21c22a2b4d0..0810039fcd739e9e355965fe6e87b5907d2913e8
100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -230,12 +230,12 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
               ring->cons, ring->prod);

        /* Unmap and free Rx buffers */
-       while (!mlx4_en_is_ring_empty(ring)) {
-               index = ring->cons & ring->size_mask;
+       for (index = 0; index < ring->size; index++) {
                en_dbg(DRV, priv, "Processing descriptor:%d\n", index);
                mlx4_en_free_rx_desc(priv, ring, index);
-               ++ring->cons;
        }
+       ring->cons = 0;
+       ring->prod = 0;
 }
