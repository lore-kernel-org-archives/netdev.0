From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Thu, 05 Jan 2012 21:22:48 +0100
Message-ID: <1325794968.2748.6.camel@edumazet-laptop>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325791164.29084.8.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64938 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758287Ab2AEUW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 15:22:57 -0500
Received: by wibhm6 with SMTP id hm6so630286wib.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 12:22:56 -0800 (PST)
In-Reply-To: <1325791164.29084.8.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 19:19 +0000, Ian Campbell a =C3=A9crit =
:
> On Thu, 2012-01-05 at 17:46 +0000, Eric Dumazet wrote:
> > Le jeudi 05 janvier 2012 =C3=A0 17:13 +0000, Ian Campbell a =C3=A9c=
rit :
> > > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > > index da0c97f..b6de604 100644
> > > --- a/net/core/skbuff.c
> > > +++ b/net/core/skbuff.c
> > > @@ -189,8 +189,7 @@ struct sk_buff *__alloc_skb(unsigned int size=
, gfp_t gfp_mask,
> > >  	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
> > >  	 * Both skb->head and skb_shared_info are cache line aligned.
> > >  	 */
> > > -	size =3D SKB_DATA_ALIGN(size);
> > > -	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> > > +	size =3D SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
> > >  	data =3D kmalloc_node_track_caller(size, gfp_mask, node);
> > >  	if (!data)
> > >  		goto nodata;
> >=20
> > Unfortunately this makes the frequently use part of skb_shared_info=
 not
> > any more in a single cache line.
> >=20
> > This will slow down many operations like kfree_skb() of cold skbs (=
TX
> > completion for example)
>=20
> I've been toying with the following which moves the infrequently used
> destructor_arg field to the front. With 32 or 64 byte cache lines thi=
s
> is then the only field which ends up on a different cache line. With =
128
> byte cache lines it is all already on the same line.
>=20
> Does that alleviate your concern? If so I can clean it up and include=
 it
> in the series.
>=20
> Cheers,
> Ian.
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index cbc815c..533c2ea 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -249,6 +249,11 @@ struct ubuf_info {
>   * the end of the header data, ie. at skb->end.
>   */
>  struct skb_shared_info {
> +	/* Intermediate layers must ensure that destructor_arg
> +	 * remains valid until skb destructor */
> +	void *		destructor_arg;
> +
> +	/* Warning all fields from here until dataref are cleared in __allo=
c_skb() */
>  	unsigned char	nr_frags;
>  	__u8		tx_flags;
>  	unsigned short	gso_size;
> @@ -264,9 +269,6 @@ struct skb_shared_info {
>  	 */
>  	atomic_t	dataref;
> =20
> -	/* Intermediate layers must ensure that destructor_arg
> -	 * remains valid until skb destructor */
> -	void *		destructor_arg;
> =20
>  	/* must be last field, see pskb_expand_head() */
>  	skb_frag_t	frags[MAX_SKB_FRAGS];

Hmmm

Take a look at kfree_skb() and please list all skb_shared_info needed
fields, for a typical skb with nr_frags=3D 0 or 1.

If all fit in a single cache line, its ok.

If not, this adds a cache line miss in a critical path.

Also in transmit path, when an skb is queued by cpu X on qdisc, and
dequeued by another cpu Y to be delivered to device.
