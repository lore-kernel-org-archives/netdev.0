From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Wed, 7 Jul 2010 12:17:31 -0700
Message-ID: <AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FBFB@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FD52@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:31834 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756351Ab0GGTRk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 15:17:40 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o67JHbmR008677
	for <netdev@vger.kernel.org>; Wed, 7 Jul 2010 12:17:39 -0700
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by hpaq6.eem.corp.google.com with ESMTP id o67JHZ2G021167
	for <netdev@vger.kernel.org>; Wed, 7 Jul 2010 12:17:36 -0700
Received: by pxi3 with SMTP id 3so1396543pxi.25
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 12:17:35 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FD52@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 6, 2010 at 12:16 AM, Vladislav Zolotarov <vladz@broadcom.co=
m> wrote:
> Let me rephrase: the part of your patch below enables RSS flow in our=
 FW even if there is only one HW queue and I wonder why?
> To refresh:
> =A0 =A0 =A0 =A01) FW won't provide Toeplitz hash on CQE if RSS is not=
 enabled.
> =A0 =A0 =A0 =A02) There can be one HW queue in only 2 cases:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- There is only one CPU in the system.=
 In that case I wonder if u have anything to do with Toeplitz hash on t=
he skb at all.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- User has explicitly requested 1 HW q=
ueue with module parameter (num_queues=3D1). In that case if u r going =
to use the RSS hash on the skb means that u r actually going to do SW R=
SS instead of HW RSS, which sounds strange to me.

It might not be so strange.  Previously, we has hit a firmware bug in
bnx2x that was make multi-queue not perform well under some loads, so
we had disabled it for a while... it is a valid configuration we have
used.

>
> So, Herbert, could u, pls., explain, what was your original idea abou=
t these code lines?
>

It is to enable the device to provide the RSS hash in RX descriptor.
The hash severs two purposes now, it's used internally in the device
to perform RSS table lookup and also value in RX descriptor.  The
latter does not require multi-queue.  Strictly speaking, on a single
processor system without multqueue, it would be true that enabling the
RX hash on bnx2x is currently superfluous (notwithstanding some other
use of the hash might be implemented).

> Thanks,
> vlad
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org] On
>> Behalf Of Vladislav Zolotarov
>> Sent: Sunday, July 04, 2010 7:36 PM
>> To: Tom Herbert
>> Cc: netdev@vger.kernel.org
>> Subject: RE: [PATCH] bnx2x: add support for receive hashing
>>
>> Tom, could u, pls., explain what did u mean by taking the (RSS) flag=
s
>> configuration out of RSS "if"? To recall "if(is_multi(bp))" is true =
iff RSS
>> is enabled.
>>
>> Thanks,
>> vlad
>>
>> > @@ -5750,10 +5757,10 @@ static void bnx2x_init_internal_func(struc=
t bnx2x
>> > *bp)
>> > =A0 =A0 u32 offset;
>> > =A0 =A0 u16 max_agg_size;
>> >
>> > - =A0 if (is_multi(bp)) {
>> > - =A0 =A0 =A0 =A0 =A0 tstorm_config.config_flags =3D MULTI_FLAGS(b=
p);
>> > + =A0 tstorm_config.config_flags =3D RSS_FLAGS(bp);
>> > +
>> > + =A0 if (is_multi(bp))
>> > =A0 =A0 =A0 =A0 =A0 =A0 tstorm_config.rss_result_mask =3D MULTI_MA=
SK;
>> > - =A0 }
>> >
>> > =A0 =A0 /* Enable TPA if needed */
>> > =A0 =A0 if (bp->flags & TPA_ENABLE_FLAG)
>>
>>
>> > -----Original Message-----
>> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kerne=
l.org] On
>> > Behalf Of Tom Herbert
>> > Sent: Friday, April 23, 2010 8:54 AM
>> > To: davem@davemloft.net; netdev@vger.kernel.org
>> > Subject: [PATCH] bnx2x: add support for receive hashing
>> >
>> > Add support to bnx2x to extract Toeplitz hash out of the receive d=
escriptor
>> > for use in skb->rxhash.
>> >
>> > Signed-off-by: Tom Herbert <therbert@google.com>
>> > ---
>> > diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
>> > index 0819530..8bd2368 100644
>> > --- a/drivers/net/bnx2x.h
>> > +++ b/drivers/net/bnx2x.h
>> > @@ -1330,7 +1330,7 @@ static inline u32 reg_poll(struct bnx2x *bp,=
 u32 reg,
>> > u32 expected, int ms,
>> > =A0 =A0 =A0 =A0 =A0 =A0 AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PA=
RITY | \
>> > =A0 =A0 =A0 =A0 =A0 =A0 AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PAR=
ITY)
>> >
>> > -#define MULTI_FLAGS(bp) \
>> > +#define RSS_FLAGS(bp) \
>> > =A0 =A0 =A0 =A0 =A0 =A0 (TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV=
4_CAPABILITY | \
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_I=
PV4_TCP_CAPABILITY | \
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_I=
PV6_CAPABILITY | \
>> > diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
>> > index 0c6dba2..613f727 100644
>> > --- a/drivers/net/bnx2x_main.c
>> > +++ b/drivers/net/bnx2x_main.c
>> > @@ -1582,7 +1582,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpat=
h *fp,
>> int
>> > budget)
>> > =A0 =A0 =A0 =A0 =A0 =A0 struct sw_rx_bd *rx_buf =3D NULL;
>> > =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
>> > =A0 =A0 =A0 =A0 =A0 =A0 union eth_rx_cqe *cqe;
>> > - =A0 =A0 =A0 =A0 =A0 u8 cqe_fp_flags;
>> > + =A0 =A0 =A0 =A0 =A0 u8 cqe_fp_flags, cqe_fp_status_flags;
>> > =A0 =A0 =A0 =A0 =A0 =A0 u16 len, pad;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 comp_ring_cons =3D RCQ_BD(sw_comp_cons);
>> > @@ -1598,6 +1598,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpat=
h *fp,
>> int
>> > budget)
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 cqe =3D &fp->rx_comp_ring[comp_ring_cons];
>> > =A0 =A0 =A0 =A0 =A0 =A0 cqe_fp_flags =3D cqe->fast_path_cqe.type_e=
rror_flags;
>> > + =A0 =A0 =A0 =A0 =A0 cqe_fp_status_flags =3D cqe->fast_path_cqe.s=
tatus_flags;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 DP(NETIF_MSG_RX_STATUS, "CQE type %x =A0er=
r %x =A0status %x"
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0queue %x =A0vlan %x =A0len %u\=
n", CQE_TYPE(cqe_fp_flags),
>> > @@ -1727,6 +1728,12 @@ reuse_rx:
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D eth_type=
_trans(skb, bp->dev);
>> >
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((bp->dev->features & ETH=
_FLAG_RXHASH) &&
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (cqe_fp_status_flags=
 &
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ETH_FAST_PATH_RX_=
CQE_RSS_HASH_FLG))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->rxhash =
=3D le32_to_cpu(
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cqe-=
>fast_path_cqe.rss_hash_result);
>> > +
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->ip_summed =3D CHECKSU=
M_NONE;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bp->rx_csum) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely=
(BNX2X_RX_CSUM_OK(cqe)))
>> > @@ -5750,10 +5757,10 @@ static void bnx2x_init_internal_func(struc=
t bnx2x
>> > *bp)
>> > =A0 =A0 u32 offset;
>> > =A0 =A0 u16 max_agg_size;
>> >
>> > - =A0 if (is_multi(bp)) {
>> > - =A0 =A0 =A0 =A0 =A0 tstorm_config.config_flags =3D MULTI_FLAGS(b=
p);
>> > + =A0 tstorm_config.config_flags =3D RSS_FLAGS(bp);
>> > +
>> > + =A0 if (is_multi(bp))
>> > =A0 =A0 =A0 =A0 =A0 =A0 tstorm_config.rss_result_mask =3D MULTI_MA=
SK;
>> > - =A0 }
>> >
>> > =A0 =A0 /* Enable TPA if needed */
>> > =A0 =A0 if (bp->flags & TPA_ENABLE_FLAG)
>> > @@ -6629,10 +6636,8 @@ static int bnx2x_init_common(struct bnx2x *=
bp)
>> > =A0 =A0 bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);
>> >
>> > =A0 =A0 REG_WR(bp, SRC_REG_SOFT_RST, 1);
>> > - =A0 for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D=
 4) {
>> > - =A0 =A0 =A0 =A0 =A0 REG_WR(bp, i, 0xc0cac01a);
>> > - =A0 =A0 =A0 =A0 =A0 /* TODO: replace with something meaningful *=
/
>> > - =A0 }
>> > + =A0 for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D=
 4)
>> > + =A0 =A0 =A0 =A0 =A0 REG_WR(bp, i, random32());
>> > =A0 =A0 bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
>> > =A0#ifdef BCM_CNIC
>> > =A0 =A0 REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
>> > @@ -11001,6 +11006,11 @@ static int bnx2x_set_flags(struct net_dev=
ice *dev,
>> > u32 data)
>> > =A0 =A0 =A0 =A0 =A0 =A0 changed =3D 1;
>> > =A0 =A0 }
>> >
>> > + =A0 if (data & ETH_FLAG_RXHASH)
>> > + =A0 =A0 =A0 =A0 =A0 dev->features |=3D NETIF_F_RXHASH;
>> > + =A0 else
>> > + =A0 =A0 =A0 =A0 =A0 dev->features &=3D ~NETIF_F_RXHASH;
>> > +
>> > =A0 =A0 if (changed && netif_running(dev)) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 bnx2x_nic_unload(bp, UNLOAD_NORMAL);
>> > =A0 =A0 =A0 =A0 =A0 =A0 rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
>
