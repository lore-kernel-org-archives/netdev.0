From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx5e: Support adding ingress tc rule
 when egress device flag is set
Date: Wed, 30 Nov 2016 08:36:23 -0800
Message-ID: <583F0007.3090507@gmail.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
 <1480516895-29545-9-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36246 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755563AbcK3Qgj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:36:39 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so1782006pgx.3
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:36:39 -0800 (PST)
In-Reply-To: <1480516895-29545-9-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-30 06:41 AM, Hadar Hen Zion wrote:
> When ndo_setup_tc is called with an egress_dev flag set, it means that
> the ndo call was executed on the mirred action (egress) device and not
> on the ingress device.
> 
> In order to support this kind of ndo_setup_tc call, and insert the
> correct decap rule to the hardware, the uplink device on the same eswitch
> should be found.
> 
> Currently, we use this resolution between the mirred device and the
> uplink on the same eswitch to offload vxlan shared device decap rules.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> ---

Hi Hadar,

I started to dig through these patches and the last series here,

   Re: [PATCH net-next 00/13] Mellanox 100G SRIOV offloads tunnel_key
set/release

Can you explain how these two are related? I'm guessing in that first
series the actual redirect action to a tunnel device was being ignore?

Does this series clean up that bit of software/hardware alignment.

Thanks,
John


>  drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
> index 0868677..8503788 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
> @@ -289,6 +289,14 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
>  	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
>  		return -EOPNOTSUPP;
>  
> +	if (tc->egress_dev) {
> +		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
> +		struct net_device *uplink_dev = mlx5_eswitch_get_uplink_netdev(esw);
> +
> +		return uplink_dev->netdev_ops->ndo_setup_tc(uplink_dev, handle,
> +							    proto, tc);
> +	}
> +
>  	switch (tc->type) {
>  	case TC_SETUP_CLSFLOWER:
>  		switch (tc->cls_flower->command) {
> 
