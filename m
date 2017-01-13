From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net] mlx4: do not call napi_schedule() without care
Date: Fri, 13 Jan 2017 15:07:31 -0800
Message-ID: <CAKgT0UdgzU1BAjiKyMFeB+KOJbDSdbBS6KdHX2LZ_pWT3XiXjg@mail.gmail.com>
References: <1484325564.13165.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Erez Shitrit <erezsh@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35261 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdAMXHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:07:32 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so6567271ith.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 15:07:32 -0800 (PST)
In-Reply-To: <1484325564.13165.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 8:39 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Disable BH around the call to napi_schedule() to avoid following warning
>
> [   52.095499] NOHZ: local_softirq_pending 08
> [   52.421291] NOHZ: local_softirq_pending 08
> [   52.608313] NOHZ: local_softirq_pending 08
>
> Fixes: 8d59de8f7bb3 ("net/mlx4_en: Process all completions in RX rings after port goes up")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Erez Shitrit <erezsh@mellanox.com>
> Cc: Eugenia Emantayev <eugenia@mellanox.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 4910d9af19335d4b97d39760c163b41eecc26242..761f8b12399cab245abccc0f7d7f84fde742c14d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1748,8 +1748,11 @@ int mlx4_en_start_port(struct net_device *dev)
>         /* Process all completions if exist to prevent
>          * the queues freezing if they are full
>          */
> -       for (i = 0; i < priv->rx_ring_num; i++)
> +       for (i = 0; i < priv->rx_ring_num; i++) {
> +               local_bh_disable();
>                 napi_schedule(&priv->rx_cq[i]->napi);
> +               local_bh_enable();
> +       }

Couldn't you save yourself a ton of trouble by wrapping the loop
inside of the local_bh_disable/enable instead of wrapping them up
inside the loop?  It just seems like it might be more efficient to
schedule them and then process them as a block instead of doing it one
at a time.

- Alex
