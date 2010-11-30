From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Tue, 30 Nov 2010 09:37:20 -0500
Message-ID: <20101130143720.GA6017@hmsreliant.think-freely.org>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
 <1291126341.2904.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36772 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab0K3Ohb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 09:37:31 -0500
Content-Disposition: inline
In-Reply-To: <1291126341.2904.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 03:12:21PM +0100, Eric Dumazet wrote:
> Le mardi 30 novembre 2010 =E0 21:56 +0800, Changli Gao a =E9crit :
> > The following commit causes the pgv->buffer may point to the memory
> > returned by vmalloc(). And we can't use virt_to_page() for the vmal=
loc
> > address.
> >=20
> > This patch introduces a new inline function pgv_to_page(), which ca=
lls
> > vmalloc_to_page() for the vmalloc address, and virt_to_page() for t=
he
> > __get_free_pages address.
> >=20
> >     commit 0e3125c755445664f00ad036e4fc2cd32fd52877
> >     Author: Neil Horman <nhorman@tuxdriver.com>
> >     Date:   Tue Nov 16 10:26:47 2010 -0800
> >=20
> >     packet: Enhance AF_PACKET implementation to not require high or=
der contiguous memory allocation (v4)
> >=20
>=20
> nice catch.
>=20
Ouch, yes, thanks.

> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > ---
> >  net/packet/af_packet.c |   21 ++++++++++++++-------
> >  1 file changed, 14 insertions(+), 7 deletions(-)
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 422705d..0171b20 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -224,6 +224,13 @@ struct packet_skb_cb {
> > =20
> >  #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb=
))
> > =20
> > +static inline struct page *pgv_to_page(void *addr)
> > +{
> > +	if (is_vmalloc_addr(addr))
> > +		return vmalloc_to_page(addr);
>=20
> Hmm, I am wondering if calling vmalloc_to_page(addr) several times fo=
r
> each packet is not too expensive ? I believe it is.
>=20
> What about caching "struct page *" pointer somewhere ?
>=20
> Then later we have :
>=20
> > -		p_start =3D virt_to_page(h.raw);
> > -		p_end =3D virt_to_page(h_end);
> > +		p_start =3D pgv_to_page(h.raw);
> > +		p_end =3D pgv_to_page(h_end);
> >  		while (p_start <=3D p_end) {
> >  			flush_dcache_page(p_start);
> >  			p_start++;
>=20
> This was OK before Neil patch... after vmalloc(), assumption that
> p_start can be incremented is completely wrong.
>=20
> To fix this, we need something else than your patch.
>=20
Off the top of my head, I would think that pgv_to_page could be prototy=
ped such
that it could accept addr, offset and struct page ** arguments.  That w=
ay we can
track the current page that we're mapped to, lowering the number of cal=
ls to
vmalloc_to_page, and we can still use an increment like we do above (as=
 long as
its wrapped in a subsequent call to pgv_to_page)
Neil

>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
