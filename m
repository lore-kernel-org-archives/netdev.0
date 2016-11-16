From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next v2 2/4] bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
Date: Wed, 16 Nov 2016 14:25:15 +0200
Message-ID: <CALzJLG_r9tujvSVysMXLSO8cRR6zHaHfmacmGq-hCqg5Ou7w_w@mail.gmail.com>
References: <cover.1479253024.git.daniel@iogearbox.net> <0899adb6ace97b7e7f94b04dd11a0e55270d2b54.1479253024.git.daniel@iogearbox.net>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35248 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbcKPMZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 07:25:37 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so10610655wme.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 04:25:37 -0800 (PST)
In-Reply-To: <0899adb6ace97b7e7f94b04dd11a0e55270d2b54.1479253024.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 2:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> There are multiple issues in mlx5e_xdp_set():
>
> 1) The batched bpf_prog_add() is currently not checked for errors! When
>    doing so, it should be done at an earlier point in time to makes sure
>    that we cannot fail anymore at the time we want to set the program for
>    each channel. This only means that we have to undo the bpf_prog_add()
>    in case we return due to required reset.
>
> 2) When swapping the priv->xdp_prog, then no extra reference count must be
>    taken since we got that from call path via dev_change_xdp_fd() already.
>    Otherwise, we'd never be able to free the program. Also, bpf_prog_add()
>    without checking the return code could fail.
>
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 25 ++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index ab0c336..cf26672 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -3142,6 +3142,17 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
>                 goto unlock;
>         }
>
> +       if (prog) {
> +               /* num_channels is invariant here, so we can take the
> +                * batched reference right upfront.
> +                */
> +               prog = bpf_prog_add(prog, priv->params.num_channels);
> +               if (IS_ERR(prog)) {
> +                       err = PTR_ERR(prog);
> +                       goto unlock;
> +               }
> +       }
> +

With this approach you will end up taking a ref count twice per RQ! on
the first time xdp_set is called i.e (old_prog = NULL, prog != NULL).
One ref will be taken per RQ/Channel from the above code, and since
reset will be TRUE mlx5e_open_locked will be called and another ref
count will be taken on mlx5e_create_rq.

The issue here is that we have two places for ref count accounting,
xdp_set and  mlx5e_create_rq. Having ref-count updates in
mlx5e_create_rq is essential for num_channels configuration changes
(mlx5e_set_ringparam).

Our previous approach made sure that only one path will do the ref
counting (mlx5e_open_locked vs. mlx5e_xdp_set batch ref update when
reset == false).

We have two options:
1. remove ref count updates from mlx5e_create_rq and only do batch
updates in mlx5e_set_ringparam and mlx5e_xdp_set, the only two places
num_channels/priv->xdp_prog could change.
2. Keep the current approach and make sure to not update the ref count
twice, you can batch update only if (!reset && was_open) otherwise you
can rely on mlx5e_open_locked to take the num_channels ref count for
you.

Personally I prefer option 2, since we will keep the current logic
which will allow configuration updates such as (mlx5e_set_ringparam)
to not worry about ref counting since it will be done in the reset
flow.

Basically we want on xdp_set
   -bpf_prog_add(prog, 1) // one ref for the device.
   - if not going to reset bpf_prog_add(prog, num_channels) //batch update
   - old_prog = xchg(&priv->xdp_prog, prog);
   - if going to reset then reset . // reset will handle ref-counting
per channel.
   - bpf_prog_put(old_prog) // put one ref for the device.
   - if (!reset) bpf_prog_put(old_prog, num_channels)  // if we didn't
reset, we need to release ref count on old_prog ourselves

Saeed.
