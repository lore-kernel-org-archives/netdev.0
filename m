From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Wed, 07 Dec 2016 10:32:19 +0100
Message-ID: <5847D723.3020908@iogearbox.net>
References: <1481088714-54512-1-git-send-email-kafai@fb.com> <1481088714-54512-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59791 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbcLGJdP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:33:15 -0500
In-Reply-To: <1481088714-54512-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

On 12/07/2016 06:31 AM, Martin KaFai Lau wrote:
[...]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 49a81f1fc1d6..6261157f444e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2794,6 +2794,9 @@ static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
>   	case XDP_QUERY_PROG:
>   		xdp->prog_attached = mlx4_xdp_attached(dev);
>   		return 0;
> +	case XDP_QUERY_FEATURES:
> +		xdp->features = 0;
> +		return 0;
>   	default:
>   		return -EINVAL;
>   	}
[...]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 1ff5ea6e1221..786ad7c67215 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -30,6 +30,7 @@
>   #include <linux/delay.h>
>   #include <linux/atomic.h>
>   #include <linux/prefetch.h>
> +#include <linux/bitops.h>
>   #include <asm/cache.h>
>   #include <asm/byteorder.h>
>
> @@ -805,6 +806,13 @@ struct tc_to_netdev {
>   	bool egress_dev;
>   };
>
> +/* Driver must allow a XDP prog to extend header by
> + * up to XDP_PACKET_HEADROOM.  It must also fill out
> + * the data_hard_start value in struct xdp_buff
> + * before calling out the xdp_prog.
> + */
> +#define XDP_F_ADJUST_HEAD	BIT(0)
> +
>   /* These structures hold the attributes of xdp state that are being passed
>    * to the netdevice through the xdp op.
>    */
> @@ -821,6 +829,8 @@ enum xdp_netdev_command {
>   	 * return true if a program is currently attached and running.
>   	 */
>   	XDP_QUERY_PROG,
> +	/* Check what XDP features are supported by a device */
> +	XDP_QUERY_FEATURES,
>   };
>
>   struct netdev_xdp {
> @@ -830,6 +840,8 @@ struct netdev_xdp {
>   		struct bpf_prog *prog;
>   		/* XDP_QUERY_PROG */
>   		bool prog_attached;
> +		/* XDP_QUERY_FEATURES */
> +		u32 features;
>   	};
>   };
>
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bffb5253e778..90696f7e6b59 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6722,6 +6722,15 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>   		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
>   		if (IS_ERR(prog))
>   			return PTR_ERR(prog);
> +
> +		xdp.command = XDP_QUERY_FEATURES;
> +		err = ops->ndo_xdp(dev, &xdp);
> +		if (err)
> +			return err;
> +
> +		if (prog->xdp_adjust_head &&
> +		    !(xdp.features & XDP_F_ADJUST_HEAD))
> +			return -ENOTSUPP;
>   	}
>
>   	memset(&xdp, 0, sizeof(xdp));

I think this interface wrt feature flags is rather odd. Why can't this be
done the usual/expected way we already have today for drivers with NETIF_F_*
flags?

We have include/linux/netdev_features.h, there, we add all NETIF_F_XDP_*
feature flags that the device would then select during init, perhaps some of
them in future might depend on a certain setups, etc, calculating them in a
separate ndo_xdp() seems odd also in the sense that in-kernel users always
need to call ops->ndo_xdp() with XDP_QUERY_FEATURES instead of just simply
doing the test on dev->features & NETIF_F_XDP_* directly. This is global to
the device anyway and doesn't need to be stored somewhere in private data
area.

I see nothing wrong if this is exposed/made visible in the usual way through
ethtool -k as well. I guess at least that would be the expected way to query
for such driver capabilities.

Thanks,
Daniel
