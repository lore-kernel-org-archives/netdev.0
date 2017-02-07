From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page
 recycling
Date: Tue, 07 Feb 2017 08:26:23 -0800
Message-ID: <1486484783.7793.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170207030240.31357-1-edumazet@google.com>
         <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
         <1486483592.7793.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
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
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36805 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755282AbdBGQ0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:26:25 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so12518689pgf.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:26:25 -0800 (PST)
In-Reply-To: <1486483592.7793.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 08:06 -0800, Eric Dumazet wrote:

>  		/*
>  		 * make sure we read the CQE after we read the ownership bit
>  		 */
>  		dma_rmb();
> +		prefetch(frags[0].page);

Note that I would like to instead do a prefetch(frags[1].page)

So I will probably change how ring->rx_info is allocated

wasting all that space and forcing vmalloc() is silly :

tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
                                sizeof(struct mlx4_en_rx_alloc));
ring->rx_info = vzalloc_node(tmp, node);

In most cases, using exactly 12 bytes per slot would allow better
packing. Only one cpu is using this area, no need to force strange
alignments, for the sake of avoiding a multiply !
