From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Sat, 13 Dec 2008 09:56:59 +1100
Message-ID: <20081212225659.GB11636@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au> <1229120724.3051.61.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33854 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752562AbYLLW5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 17:57:04 -0500
Content-Disposition: inline
In-Reply-To: <1229120724.3051.61.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 10:25:24PM +0000, Ben Hutchings wrote:
> On Fri, 2008-12-12 at 16:31 +1100, Herbert Xu wrote:
> > Whenever the skb is merged into an existing entry, the gro_receive
> > function should set NAPI_GRO_CB(skb)->same_flow.  Note that if an s=
kb
> > merely matches an existing entry but can't be merged with it, then
> > this shouldn't be set.
>=20
> So why not call this field "merged"?

Because when it's used on held skb's it indicates whether the new
skb can be of the same flow or not.

> > +int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb=
)
> > +{
> > +	struct sk_buff **pp;
> > +	struct packet_type *ptype;
> > +	__be16 type =3D skb->protocol;
> > +	struct list_head *head =3D &ptype_base[ntohs(type) & PTYPE_HASH_M=
ASK];
>=20
> Are you intending for the VLAN driver to call napi_gro_receive()?  If
> not, =EF=BB=BFI think this should treat VLAN tags as part of the MAC =
header.
> Not every NIC separates them out!

Yes the idea is to look at the VLAN+Ethernet header in future.

> > +		for (p =3D napi->gro_list; p; p =3D p->next) {
> > +			count++;
> > +			NAPI_GRO_CB(p)->same_flow =3D
> > +				p->mac_len =3D=3D mac_len &&
> > +				!memcmp(skb_mac_header(p), skb_mac_header(skb),
> > +					mac_len);
> > +			NAPI_GRO_CB(p)->flush =3D 0;
>=20
> Is this assignment to flush really necessary?  Surely any skb on the
> gro_list with flush =3D=3D 1 gets removed before the next call to
> napi_gro_receive()?

Yes it is necessary.  Only the one with flushing !=3D 0 and is of the
same flow as the new skb will be removed.

> The inet_lro code accepts either skbs or pages and the sfc driver tak=
es
> advantage of this: so long as most packets can be coalesced by LRO, i=
t's
> cheaper to allocate page buffers in advance and then attach them to s=
kbs
> during LRO.  I think you should support the use of page buffers.
> Obviously it adds complexity but there's a real performance benefit.
> (Alternately you could work out how to make skb allocation cheaper, a=
nd
> everyone would be happy!)

This is something which I will look at in future.  The top priority
right now is to get bridging to work with GRO.

> Shouldn't the list already be empty at this point?

It should be.  However, if your driver is buggy and forgets to
call napi_complete (or calls __napi_complete without napi_gro_flush)
then we'll need this.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
