From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 4/4] net/mlx4_en: Add accelerated RFS support
Date: Thu, 19 Jul 2012 15:09:17 +0100
Message-ID: <1342706957.2617.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
	 <1342686832-21406-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <oren@mellanox.com>,
	<yevgenyp@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50104 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751020Ab2GSOJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 10:09:22 -0400
In-Reply-To: <1342686832-21406-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 11:33 +0300, Or Gerlitz wrote:
> From: Amir Vadai <amirv@mellanox.com>
> 
> Use RFS infrastructure and flow steering in HW to keep CPU
> affinity of rx interrupts and application per TCP stream.
> 
> A flow steering filter is added to the HW whenever the RFS
> ndo callback is invoked by core networking code.
> 
> Because the invocation takes place in interrupt context, the
> actual setup of HW is done using workqueue. Whenever new filter
> is added, the driver checks for expiry of existing filters.
> 
> Since there's window in time between the point where the core
> RFS code invoked the ndo callback, to the point where the HW
> is configured from the workqueue context, the 2nd, 3rd etc
> packets from that stream will cause the net core to invoke
> the callback again and again.

Yes, and this is true even when the filter can be reprogrammed
synchronously as there may be more packets for the redirected flow
already in the RX queue.  This is a result of fixing the bug you pointed
out earlier (commit 09994d1b09bd9b0046a4708fa50d2106610a4058).  We
should try to find a way of noting pending redirects without
reintroducing that bug.

> To prevent inefficient/double configuration of the HW, the filters
> are kept in a database which is indexed using hash function to enable
> fast access.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_cq.c     |    8 +-
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  316 ++++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    3 +
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   16 ++
>  4 files changed, 342 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> index 0ef6156..aa9c2f6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> @@ -77,6 +77,12 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
>  	struct mlx4_en_dev *mdev = priv->mdev;
>  	int err = 0;
>  	char name[25];
> +	struct cpu_rmap *rmap =
> +#ifdef CONFIG_RFS_ACCEL
> +		priv->dev->rx_cpu_rmap;
> +#else
> +		NULL;
> +#endif

You can write this slightly more cleanly using IS_ENABLED().

[...]
> +static struct mlx4_en_filter *
> +mlx4_en_filter_alloc(struct mlx4_en_priv *priv, int rxq_index, __be32 src_ip,
> +                    __be32 dst_ip, __be16 src_port, __be16 dst_port,
> +                    u32 flow_id)
> +{
[...]
> +       filter->id = priv->last_filter_id++;
[...]

You need to limit the filter IDs to be < RPS_NO_FILTER.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
