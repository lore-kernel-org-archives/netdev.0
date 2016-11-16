From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next v2 3/4] bpf, mlx5: drop priv->xdp_prog reference
 on netdev cleanup
Date: Wed, 16 Nov 2016 14:51:45 +0200
Message-ID: <CALzJLG9Rzds3H-wXnjCg=_2oGV-33TY714Hx0n+NyVsZzcBBfA@mail.gmail.com>
References: <cover.1479253024.git.daniel@iogearbox.net> <4617cac95e3ca1b608f5d0a55709b0534c168943.1479253024.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>, zhiyisun@gmail.com,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34401 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932155AbcKPMwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 07:52:07 -0500
Received: by mail-qt0-f193.google.com with SMTP id l20so11131643qta.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 04:52:07 -0800 (PST)
In-Reply-To: <4617cac95e3ca1b608f5d0a55709b0534c168943.1479253024.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 2:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> mlx5e_xdp_set() is currently the only place where we drop reference on the
> prog sitting in priv->xdp_prog when it's exchanged by a new one. We also
> need to make sure that we eventually release that reference, for example,
> in case the netdev is dismantled.
>
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index cf26672..60fe54c 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -3715,6 +3715,9 @@ static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
>
>         if (MLX5_CAP_GEN(mdev, vport_group_manager))
>                 mlx5_eswitch_unregister_vport_rep(esw, 0);
> +
> +       if (priv->xdp_prog)
> +               bpf_prog_put(priv->xdp_prog);
>  }
>

I thought that on unregister_netdev  ndo_xdp_set will be called with
NULL prog to cleanup. like any other resources (Vlans/mac_lists/
etc..), why xdp should be different ?
Anyway if this is the case, I am ok with this fix, you can even send
it to net (it looks like a serious leak).

Saeed.
