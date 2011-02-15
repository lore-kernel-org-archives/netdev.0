From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: Support for managing RX indirection table
Date: Tue, 15 Feb 2011 17:35:22 +0100
Message-ID: <1297787722.3201.6.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64292 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab1BOQf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 11:35:28 -0500
Received: by gwj20 with SMTP id 20so160033gwj.19
        for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 08:35:28 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 f=C3=A9vrier 2011 =C3=A0 08:24 -0800, Tom Herbert a =C3=A9c=
rit :
> Support fetching and retrieving RX indirection table via ethtool.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/bnx2x/bnx2x.h         |    2 +
>  drivers/net/bnx2x/bnx2x_ethtool.c |   58 +++++++++++++++++++++++++++=
++++++++++
>  drivers/net/bnx2x/bnx2x_main.c    |   23 +++++++++++----
>  3 files changed, 77 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
> index 236d79a..bf16119 100644
> --- a/drivers/net/bnx2x/bnx2x.h
> +++ b/drivers/net/bnx2x/bnx2x.h
> @@ -1076,6 +1076,7 @@ struct bnx2x {
>  	int			num_queues;
>  	int			disable_tpa;
>  	int			int_mode;
> +	u32			rx_indir_table[128];
> =20
>  	struct tstorm_eth_mac_filter_config	mac_filters;
>  #define BNX2X_ACCEPT_NONE		0x0000
> @@ -1799,5 +1800,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u3=
2 reg, u32 expected, int ms,
>  BNX2X_EXTERN int load_count[2][3]; /* per path: 0-common, 1-port0, 2=
-port1 */
> =20
>  extern void bnx2x_set_ethtool_ops(struct net_device *netdev);
> +extern void bnx2x_push_indir_table(struct bnx2x *bp);
> =20
>  #endif /* bnx2x.h */
> diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bn=
x2x_ethtool.c
> index 816fef6..a99fee4 100644
> --- a/drivers/net/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/bnx2x/bnx2x_ethtool.c
> @@ -2134,6 +2134,61 @@ static int bnx2x_phys_id(struct net_device *de=
v, u32 data)
>  	return 0;
>  }
> =20
> +static int
> +bnx2x_get_rxnfc(struct net_device *dev,
> +		struct ethtool_rxnfc *info, void *rules __always_unused)
> +{
> +	struct bnx2x *bp =3D netdev_priv(dev);
> +
> +	switch (info->cmd) {
> +	case ETHTOOL_GRXRINGS:
> +		info->data =3D bp->num_queues - NONE_ETH_CONTEXT_USE;
> +		return 0;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static int bnx2x_get_rxfh_indir(struct net_device *dev,
> +				struct ethtool_rxfh_indir *indir)
> +{
> +	struct bnx2x *bp =3D netdev_priv(dev);
> +	size_t copy_size =3D
> +		min_t(size_t, indir->size, TSTORM_INDIRECTION_TABLE_SIZE);
> +
> +	if (bp->multi_mode =3D=3D ETH_RSS_MODE_DISABLED)
> +		return -ENOENT;
> +
> +	indir->size =3D TSTORM_INDIRECTION_TABLE_SIZE;
> +	memcpy(indir->ring_index, bp->rx_indir_table,
> +	       copy_size * sizeof(bp->rx_indir_table[0]));
> +	return 0;
> +}
> +
> +static int bnx2x_set_rxfh_indir(struct net_device *dev,
> +				const struct ethtool_rxfh_indir *indir)
> +{
> +	struct bnx2x *bp =3D netdev_priv(dev);
> +	size_t i;
> +
> +	if (bp->multi_mode =3D=3D ETH_RSS_MODE_DISABLED)
> +		return -ENOENT;
> +
> +	/* Validate size and indices */
> +	if (indir->size !=3D TSTORM_INDIRECTION_TABLE_SIZE)
> +		return -EINVAL;
> +	for (i =3D 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
> +		if (indir->ring_index[i] >=3D
> +		    bp->num_queues - NONE_ETH_CONTEXT_USE)

BNX2X_NUM_ETH_QUEUES(bp) instead of=20
(bp->num_queues - NONE_ETH_CONTEXT_USE)

> +			return -EINVAL;
> +
> +	memcpy(bp->rx_indir_table, indir->ring_index,
> +	       sizeof(bp->rx_indir_table));
> +	bnx2x_push_indir_table(bp);
> +	return 0;
> +}
> +
>  static const struct ethtool_ops bnx2x_ethtool_ops =3D {
>  	.get_settings		=3D bnx2x_get_settings,
>  	.set_settings		=3D bnx2x_set_settings,
> @@ -2170,6 +2225,9 @@ static const struct ethtool_ops bnx2x_ethtool_o=
ps =3D {
>  	.get_strings		=3D bnx2x_get_strings,
>  	.phys_id		=3D bnx2x_phys_id,
>  	.get_ethtool_stats	=3D bnx2x_get_ethtool_stats,
> +	.get_rxnfc		=3D bnx2x_get_rxnfc,
> +	.get_rxfh_indir		=3D bnx2x_get_rxfh_indir,
> +	.set_rxfh_indir		=3D bnx2x_set_rxfh_indir,
>  };
> =20
>  void bnx2x_set_ethtool_ops(struct net_device *netdev)
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x=
_main.c
> index c238c4d..b1a84d4 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -4254,7 +4254,7 @@ static void bnx2x_init_eq_ring(struct bnx2x *bp=
)
>  		min_t(int, MAX_SP_DESC_CNT - MAX_SPQ_PENDING, NUM_EQ_DESC) - 1);
>  }
> =20
> -static void bnx2x_init_ind_table(struct bnx2x *bp)
> +void bnx2x_push_indir_table(struct bnx2x *bp)
>  {
>  	int func =3D BP_FUNC(bp);
>  	int i;
> @@ -4262,13 +4262,24 @@ static void bnx2x_init_ind_table(struct bnx2x=
 *bp)
>  	if (bp->multi_mode =3D=3D ETH_RSS_MODE_DISABLED)
>  		return;
> =20
> -	DP(NETIF_MSG_IFUP,
> -	   "Initializing indirection table  multi_mode %d\n", bp->multi_mod=
e);
>  	for (i =3D 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
>  		REG_WR8(bp, BAR_TSTRORM_INTMEM +
>  			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
> -			bp->fp->cl_id + (i % (bp->num_queues -
> -				NONE_ETH_CONTEXT_USE)));

ditto

> +			bp->fp->cl_id + bp->rx_indir_table[i]);
> +}
> +
> +static void bnx2x_init_indir_table(struct bnx2x *bp)
> +{
> +	int i;
> +
> +	BUG_ON(ARRAY_SIZE(bp->rx_indir_table) <
> +	    TSTORM_INDIRECTION_TABLE_SIZE);
> +
> +	for (i =3D 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
> +		bp->rx_indir_table[i] =3D
> +		    (i % (bp->num_queues - NONE_ETH_CONTEXT_USE));

and here

> +
> +	bnx2x_push_indir_table(bp);
>  }
> =20
>  void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
> @@ -4496,7 +4507,7 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_=
code)
>  	bnx2x_init_eq_ring(bp);
>  	bnx2x_init_internal(bp, load_code);
>  	bnx2x_pf_init(bp);
> -	bnx2x_init_ind_table(bp);
> +	bnx2x_init_indir_table(bp);
>  	bnx2x_stats_init(bp);
> =20
>  	/* At this point, we are ready for interrupts */


