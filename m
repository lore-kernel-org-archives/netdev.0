From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page recycling
Date: Thu, 9 Feb 2017 05:31:23 -0800
Message-ID: <CANn89iKUeBu2N2qwCzqNFdapK8LLE-8tCLEzCQT8y4aqyMzFmQ@mail.gmail.com>
References: <20170207030240.31357-1-edumazet@google.com> <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
 <029a2e2e-eb06-e452-e00e-56dc9c4f3a47@gmail.com> <1486569156.7793.79.camel@edumazet-glaptop3.roam.corp.google.com>
 <a536bb6d-3596-188e-bc99-548b02f8eb91@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:33094 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752307AbdBINbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:31:24 -0500
Received: by mail-it0-f54.google.com with SMTP id d9so40151386itc.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:31:24 -0800 (PST)
In-Reply-To: <a536bb6d-3596-188e-bc99-548b02f8eb91@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 4:00 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:

> Yes.

>
> It can be fixed with this:
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 6854a19087ed..d97ee69393f0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -94,8 +94,8 @@ static void mlx4_en_free_frag(const struct mlx4_en_priv
> *priv,
>                 dma_unmap_page(priv->ddev, frag->dma,
>                                PAGE_SIZE, priv->dma_dir);
>                 put_page(frag->page);
> -               frag->page = NULL;
>         }
> +       memset(frag, 0, sizeof(*frag));
>  }
>

Oh nice, and this is slow path (mlx4_en_free_frag() wont be called
anymore in fast path after my patches)

Thanks a lot Tariq for tracking this down.
