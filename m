From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 10:09:42 +0200
Message-ID: <1274256582.2766.5.camel@edumazet-laptop>
References: <20100519075721.GA23926@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44070 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab0ESIJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 04:09:45 -0400
Received: by fxm10 with SMTP id 10so2004010fxm.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 01:09:44 -0700 (PDT)
In-Reply-To: <20100519075721.GA23926@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 mai 2010 =C3=A0 17:57 +1000, Herbert Xu a =C3=A9crit :
> Hi:
>=20
> tun: Use netif_receive_skb instead of netif_rx
>=20
> First a bit of history as I recall, Dave can correct me where
> he recalls differently :)
>=20
> 1) There was netif_rx and everyone had to use that.
> 2) Everyone had to use that, including drivers/net/tun.c.
> 3) NAPI brings us netif_receive_skb.
> 4) About the same time people noticed that tun.c can cause wild
>    fluctuations in latency because of its use of netif_rx with IRQs
>    enabled.
> 5) netif_rx_ni was added to address this.
>=20

6) netif_rx() pro is that packet processing is done while stack usage i=
s
guaranteed to be low (from process_backlog, using a special softirq
stack, instead of current stack)

After your patch, tun will use more stack. Is it safe on all contexts ?

Another concern I have is about RPS.

netif_receive_skb() must be called from process_backlog() context, or
there is no guarantee the IPI will be sent if this skb is enqueued for
another cpu.

> However, netif_rx_ni
>  was really a bit of a roundabout way of
> injecting a packet if you think about it.  What ends up happening
> is that we always queue the packet into the backlog, and then
> immediately process it.  Which is what would happen if we simply
> called netif_receive_skb directly.
>=20
> So this patch just does the obvious thing and makes tun.c call
> netif_receive_skb, albeit through the netif_receive_skb_ni wrapper
> which does the necessary things for calling it in process context.
>=20
> Now apart from potential performance gains from eliminating
> unnecessary steps in the process, this has the benefit of keeping
> the process context for the packet processing.  This is needed
> by cgroups to shape network traffic based on the original process.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 4326520..0eed49f 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -667,7 +667,7 @@ static __inline__ ssize_t tun_get_user(struct tun=
_struct *tun,
>  		skb_shinfo(skb)->gso_segs =3D 0;
>  	}
> =20
> -	netif_rx_ni(skb);
> +	netif_receive_skb_ni(skb);
> =20
>  	tun->dev->stats.rx_packets++;
>  	tun->dev->stats.rx_bytes +=3D len;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index fa8b476..34bb405 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1562,6 +1562,18 @@ extern int		netif_rx(struct sk_buff *skb);
>  extern int		netif_rx_ni(struct sk_buff *skb);
>  #define HAVE_NETIF_RECEIVE_SKB 1
>  extern int		netif_receive_skb(struct sk_buff *skb);
> +
> +static inline int netif_receive_skb_ni(struct sk_buff *skb)
> +{
> +	int err;
> +
> +	local_bh_disable();
> +	err =3D netif_receive_skb(skb);
> +	local_bh_enable();
> +
> +	return err;
> +}
> +
>  extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
>  					struct sk_buff *skb);
>  extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff=
 *skb);
>=20
> Cheers,


