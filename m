From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH] net/mlx4_en: Fix bpf_prog_add ref_cnt in mlx4
Date: Wed, 09 Nov 2016 10:05:31 +0100
Message-ID: <5822E6DB.40204@iogearbox.net>
References: <20161109073544.jbufjqn7y7oa6ptg@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bblanco-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Zhiyi Sun <zhiyisun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161109073544.jbufjqn7y7oa6ptg@ubuntu>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/09/2016 08:35 AM, Zhiyi Sun wrote:
> There are rx_ring_num queues. Each queue will load xdp prog. So
> bpf_prog_add() should add rx_ring_num to ref_cnt.
>
> Signed-off-by: Zhiyi Sun <zhiyisun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Your analysis looks incorrect to me. Please elaborate in more detail why
you think current code is buggy ...

Call path is dev_change_xdp_fd(), which does bpf_prog_get_type() on the
fd. This already takes a ref and only drops it in case of error. Thus
in mlx4_xdp_set(), you only need priv->rx_ring_num - 1 refs for the rest
of the rings, so that dropping refs from old_prog makes sure we release
it again. Looks correct to me (maybe a comment would have helped there).

>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 12c99a2..d25e150 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2650,7 +2650,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>   	 */
>   	if (priv->xdp_ring_num == xdp_ring_num) {
>   		if (prog) {
> -			prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> +			prog = bpf_prog_add(prog, priv->rx_ring_num);
>   			if (IS_ERR(prog))
>   				return PTR_ERR(prog);
>   		}
> @@ -2680,7 +2680,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>   	}
>
>   	if (prog) {
> -		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> +		prog = bpf_prog_add(prog, priv->rx_ring_num);
>   		if (IS_ERR(prog))
>   			return PTR_ERR(prog);
>   	}
>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
