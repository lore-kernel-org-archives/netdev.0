From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 10:34:35 -0700
Message-ID: <20170313173432.GA31333@ast-mbp.thefacebook.com>
References: <20170313005848.7076-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35246 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdCMRek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 13:34:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id 67so19669852pfg.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 10:34:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170313005848.7076-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 05:58:47PM -0700, Eric Dumazet wrote:
> @@ -767,10 +814,30 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  			case XDP_PASS:
>  				break;
>  			case XDP_TX:
> +				/* Make sure we have one page ready to replace this one */
> +				npage = NULL;
> +				if (!ring->page_cache.index) {
> +					npage = mlx4_alloc_page(priv, ring,
> +								&ndma, numa_mem_id(),
> +								GFP_ATOMIC | __GFP_MEMALLOC);

did you test this with xdp2 test ?
under what conditions it allocates ?
It looks dangerous from security point of view to do allocations here.
Can it be exploited by an attacker?
we use xdp for ddos and lb and this is fast path.
If 1 out of 100s XDP_TX packets hit this allocation we will have serious
perf regression.
In general I dont think it's a good idea to penalize x86 in favor of powerpc.
Can you #ifdef this new code somehow? so we won't have these concerns on x86?
