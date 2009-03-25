From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 20:18:50 +0100
Message-ID: <20090325191850.GA2928@ami.dom.local>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net> <49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com> <49CA7AD7.8040401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:61412 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZCYTTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 15:19:05 -0400
Received: by ti-out-0910.google.com with SMTP id i7so101177tid.23
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 12:19:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49CA7AD7.8040401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 07:41:27PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > David Miller wrote, On 03/25/2009 08:17 AM:
> >=20
> >> From: Eric Dumazet <dada1@cosmosbay.com>
> >> Date: Wed, 25 Mar 2009 08:13:30 +0100
> >>
> >>> If done in dev_hard_start_xmit(), skb could be requeued (because =
of
> >>> NETDEV_TX_BUSY).  Then if requeued, maybe at this time, dst being
> >>> NULL is not a problem ?
> >> Usually it should be OK because the packet schedulers have
> >> a sort-of one-behind state that allows them to reinsert
> >> the SKB into their queue datastructures without reclassifying.
> >=20
> >=20
> > Actually, since David has dumped requeuing there is no reinserting;
> > this last one "requeued" skb is buffered at the top in q->gso_skb
> > and waiting for better times.
>=20
> Yes indeed, this is what I thought too, thanks Jarek.

Alas I'm a bit concerned with virtual devs, e.g. now I'm looking at
xmits in macvlan and pppoe. Maybe this patch should exclude them?

Jarek P.

>=20
> I tested following patch today on my machine, but obviously could not=
 try=20
> all possible quirks :)
>=20
> [PATCH] net: release dst entry in dev_hard_start_xmit()
>=20
> One point of contention in high network loads is the dst_release() pe=
rformed
> when a transmited skb is freed. This is because NIC tx completion cal=
ls skb free
> long after original call to dev_queue_xmit(skb).
>=20
> CPU cache is cold and the atomic op in dst_release() stalls. On SMP, =
this is
> quite visible if one CPU is 100% handling softirqs for a network devi=
ce,
> since dst_clone() is done by other cpus, involving cache line ping po=
ngs.
>=20
> I believe we can release dst in dev_hard_start_xmit(), while cpu cach=
e is hot, since
> caller of dev_queue_xmit() had to hold a reference on dst right befor=
e. This reduce
> work to be done by softirq handler, and decrease cache misses.
>=20
> I also believe only pktgen can call dev_queue_xmit() with skb which h=
ave
> a skb->users !=3D 1. But pkthen skbs have a NULL dst entry.
>=20
> I added a WARN_ON_ONCE() to catch other cases, and not release skb->d=
st
> if skb->users !=3D 1
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e3fe5c7..a622db6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1664,6 +1664,26 @@ static int dev_gso_segment(struct sk_buff *skb=
)
>  	return 0;
>  }
> =20
> +
> +/*
> + * Release dst while its refcnt is likely hot in CPU cache, instead
> + * of waiting NIC tx completion.
> + * We inline dst_release() code for performance reason
> + */
> +static void release_skb_dst(struct sk_buff *skb)
> +{
> +	if (likely(skb->dst)) {
> +		if (!WARN_ON_ONCE(atomic_read(&skb->users) !=3D 1)) {
> +			int newrefcnt;
> +
> +			smp_mb__before_atomic_dec();
> +			newrefcnt =3D atomic_dec_return(&skb->dst->__refcnt);
> +			WARN_ON(newrefcnt < 0);
> +			skb->dst =3D NULL;
> +		}
> +	}
> +}
> +
>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			struct netdev_queue *txq)
>  {
> @@ -1681,6 +1701,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
>  				goto gso;
>  		}
> =20
> +		release_skb_dst(skb);
>  		return ops->ndo_start_xmit(skb, dev);
>  	}
> =20
> @@ -1691,6 +1712,7 @@ gso:
> =20
>  		skb->next =3D nskb->next;
>  		nskb->next =3D NULL;
> +		release_skb_dst(nskb);
>  		rc =3D ops->ndo_start_xmit(nskb, dev);
>  		if (unlikely(rc)) {
>  			nskb->next =3D skb->next;
>=20
