From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Fri, 08 Oct 2010 06:45:30 +0200
Message-ID: <1286513130.6536.467.camel@edumazet-laptop>
References: <1286493453-21784-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57865 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab0JHEpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 00:45:36 -0400
Received: by wyb28 with SMTP id 28so764776wyb.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 21:45:35 -0700 (PDT)
In-Reply-To: <1286493453-21784-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 19:17 -0400, leitao@linux.vnet.ibm.com =
a
=C3=A9crit :
> Currently we set all skbs with CHECKSUM_UNNECESSARY, even
> those whose protocol we don't know. This patch just
> add the CHECKSUM_COMPLETE tag for non TCP/UDP packets.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/ehea/ehea_main.c |    9 ++++++++-
>  drivers/net/ehea/ehea_qmr.h  |    1 +
>  2 files changed, 9 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_mai=
n.c
> index 0471cae..45fd045 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -533,8 +533,15 @@ static inline void ehea_fill_skb(struct net_devi=
ce *dev,
>  	int length =3D cqe->num_bytes_transfered - 4;	/*remove CRC */
> =20
>  	skb_put(skb, length);
> -	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
>  	skb->protocol =3D eth_type_trans(skb, dev);
> +
> +	/* The packet was not an IPV4 packet so a complemented checksum was
> +	   calculated. The value is found in the Internet Checksum field. *=
/
> +	if (cqe->status & EHEA_CQE_BLIND_CKSUM) {
> +		skb->ip_summed =3D CHECKSUM_COMPLETE;
> +		skb->csum =3D csum_unfold(~cqe->inet_checksum_value);
> +	} else
> +		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
>  }
> =20

Hi Breno

Just to be clear : packets with wrong checksums are not given to upper
stack, so a tcpdump can not display them ? I am not sure many drivers d=
o
that.

(EHEA_CQE_STAT_ERR_TCP, EHEA_CQE_STAT_ERR_IP)

Thanks !


