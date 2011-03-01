From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 14:04:29 +0100
Message-ID: <1298984669.3284.99.camel@edumazet-laptop>
References: <1298910174.2941.585.camel@edumazet-laptop>
	 <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301115305.GA6984@gondor.apana.org.au>
	 <20110301123250.GA7368@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56404 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab1CANEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:04:35 -0500
Received: by fxm17 with SMTP id 17so4766203fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 05:04:34 -0800 (PST)
In-Reply-To: <20110301123250.GA7368@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 20:32 +0800, Herbert Xu a =C3=A9crit :
> On Tue, Mar 01, 2011 at 07:53:05PM +0800, Herbert Xu wrote:
> > On Tue, Mar 01, 2011 at 12:45:09PM +0100, Eric Dumazet wrote:
> > >
> > > CPU 11 handles all TX completions : Its a potential bottleneck.
> > >=20
> > > I might ressurect XPS patch ;)
> >=20
> > Actually this has been my gripe all along with our TX multiqueue
> > support.  We should not decide the queue based on the socket, but
> > on the current CPU.
> >=20
> > We already do the right thing for forwarded packets because there
> > is no socket to latch onto, we just need to fix it for locally
> > generated traffic.
> >=20
> > The odd packet reordering each time your scheduler decides to
> > migrate the process isn't a big deal IMHO.  If your scheduler
> > is constantly moving things you've got bigger problems to worry
> > about.
>=20
> If anybody wants to play here is a patch to do exactly that:
>=20
> net: Determine TX queue purely by current CPU
>=20
> Distributing packets generated on one CPU to multiple queues
> makes no sense.  Nor does putting packets from multiple CPUs
> into a single queue.
>=20
> While this may introduce packet reordering should the scheduler
> decide to migrate a thread, it isn't a big deal because migration
> is meant to be a rare event, and nothing will die as long as the
> ordering doesn't occur all the time.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ae6631..87bd20a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2164,22 +2164,12 @@ static u32 hashrnd __read_mostly;
>  u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff=
 *skb,
>  		  unsigned int num_tx_queues)
>  {
> -	u32 hash;
> +	u32 hash =3D raw_smp_processor_id();
> =20
> -	if (skb_rx_queue_recorded(skb)) {
> -		hash =3D skb_get_rx_queue(skb);
> -		while (unlikely(hash >=3D num_tx_queues))
> -			hash -=3D num_tx_queues;
> -		return hash;
> -	}
> +	while (unlikely(hash >=3D num_tx_queues))
> +		hash -=3D num_tx_queues;
> =20
> -	if (skb->sk && skb->sk->sk_hash)
> -		hash =3D skb->sk->sk_hash;
> -	else
> -		hash =3D (__force u16) skb->protocol ^ skb->rxhash;
> -	hash =3D jhash_1word(hash, hashrnd);
> -
> -	return (u16) (((u64) hash * num_tx_queues) >> 32);
> +	return hash;
>  }
>  EXPORT_SYMBOL(__skb_tx_hash);
> =20
> Cheers,

Well, some machines have 4096 cpus ;)



