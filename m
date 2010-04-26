From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 19:20:34 +0200
Message-ID: <1272302434.19143.76.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61413 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab0DZRUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 13:20:41 -0400
Received: by bwz19 with SMTP id 19so367369bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 10:20:39 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 22:54 -0700, Tom Herbert a =C3=A9crit :
> Add support to bnx2x to extract Toeplitz hash out of the receive desc=
riptor
> for use in skb->rxhash.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
> index 0819530..8bd2368 100644
> --- a/drivers/net/bnx2x.h
> +++ b/drivers/net/bnx2x.h
> @@ -1330,7 +1330,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u3=
2 reg, u32 expected, int ms,
>  		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY | \
>  		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY)
> =20
> -#define MULTI_FLAGS(bp) \
> +#define RSS_FLAGS(bp) \
>  		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
>  		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
>  		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 0c6dba2..613f727 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -1582,7 +1582,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *=
fp, int budget)
>  		struct sw_rx_bd *rx_buf =3D NULL;
>  		struct sk_buff *skb;
>  		union eth_rx_cqe *cqe;
> -		u8 cqe_fp_flags;
> +		u8 cqe_fp_flags, cqe_fp_status_flags;
>  		u16 len, pad;
> =20
>  		comp_ring_cons =3D RCQ_BD(sw_comp_cons);
> @@ -1598,6 +1598,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *=
fp, int budget)
> =20
>  		cqe =3D &fp->rx_comp_ring[comp_ring_cons];
>  		cqe_fp_flags =3D cqe->fast_path_cqe.type_error_flags;
> +		cqe_fp_status_flags =3D cqe->fast_path_cqe.status_flags;
> =20
>  		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
>  		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
> @@ -1727,6 +1728,12 @@ reuse_rx:
> =20
>  			skb->protocol =3D eth_type_trans(skb, bp->dev);
> =20
> +			if ((bp->dev->features & ETH_FLAG_RXHASH) &&
> +			    (cqe_fp_status_flags &
> +			     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
> +				skb->rxhash =3D le32_to_cpu(
> +				    cqe->fast_path_cqe.rss_hash_result);
> +
>  			skb->ip_summed =3D CHECKSUM_NONE;
>  			if (bp->rx_csum) {
>  				if (likely(BNX2X_RX_CSUM_OK(cqe)))
> @@ -5750,10 +5757,10 @@ static void bnx2x_init_internal_func(struct b=
nx2x *bp)
>  	u32 offset;
>  	u16 max_agg_size;
> =20
> -	if (is_multi(bp)) {
> -		tstorm_config.config_flags =3D MULTI_FLAGS(bp);
> +	tstorm_config.config_flags =3D RSS_FLAGS(bp);
> +
> +	if (is_multi(bp))
>  		tstorm_config.rss_result_mask =3D MULTI_MASK;
> -	}
> =20
>  	/* Enable TPA if needed */
>  	if (bp->flags & TPA_ENABLE_FLAG)
> @@ -6629,10 +6636,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
>  	bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);
> =20
>  	REG_WR(bp, SRC_REG_SOFT_RST, 1);
> -	for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D 4) {
> -		REG_WR(bp, i, 0xc0cac01a);
> -		/* TODO: replace with something meaningful */
> -	}
> +	for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D 4)
> +		REG_WR(bp, i, random32());
>  	bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
>  #ifdef BCM_CNIC
>  	REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
> @@ -11001,6 +11006,11 @@ static int bnx2x_set_flags(struct net_device=
 *dev, u32 data)
>  		changed =3D 1;
>  	}
> =20
> +	if (data & ETH_FLAG_RXHASH)
> +		dev->features |=3D NETIF_F_RXHASH;
> +	else
> +		dev->features &=3D ~NETIF_F_RXHASH;
> +
>  	if (changed && netif_running(dev)) {
>  		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
>  		rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
> --

Hi Tom

I tested this rxhash feature on my bnx2x card, using latest net-next-2.=
6
and appropriate ethtool

ethtool -k eth1 rxhash on

Then I used my pktgen script, to flood machine with flows with udp dst
port varying between 4000 and 4015.

Software generated rxhash is OK (16 different values).

But with bnx2x provided hash, all skb were hashed to same rxhash
value :(

What are the specs of this hardware hash ?
It seems to not care of udp source/destination ports.

Also, should'nt we feed same values for the seeds on different nics ?

for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D 4)
	REG_WR(bp, i, random32());

Thanks


