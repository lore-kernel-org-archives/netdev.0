From: Wolfgang Walter <linux@stwm.de>
Subject: Re: GRE with GRO very slow when forwarding starting with 3.14.24
Date: Tue, 25 Nov 2014 17:55:42 +0100
Message-ID: <3312348.sHuoVf2bjb@h2o.as.studentenwerk.mhn.de>
References: <2340533.MickblD7NF@h2o.as.studentenwerk.mhn.de> <1416847696.17888.64.camel@edumazet-glaptop2.roam.corp.google.com> <CA+mtBx9SOr5RH7S63S28YbgxR8EwjgfS_dUkS2A4D1W3NzazHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:43983 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752295AbaKYQzp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 11:55:45 -0500
In-Reply-To: <CA+mtBx9SOr5RH7S63S28YbgxR8EwjgfS_dUkS2A4D1W3NzazHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 24. November 2014, 10:16:26 schrieb Tom Herbert:
> On Mon, Nov 24, 2014 at 8:48 AM, Eric Dumazet <eric.dumazet@gmail.com=
>=20
wrote:
> > On Mon, 2014-11-24 at 17:13 +0100, Wolfgang Walter wrote:
> > > Hello,
> > >=20
> > > starting with 3.14.24 GRE with GRO on is very slow. To be more sp=
ecific:
> > >=20
> > > yyyy <--> GRO_endpoint <-_> .... <--> |eth0<->GRO-endpoint | eth1=
 |<->
> > > xxxx
> > >=20
> > > routing (IPv4) between xxxx and yyyy is very slow when GRO is ena=
bled on
> > > eth0 and/or eth1 starting with stable kernel 3.14.24
> > >=20
> > > Regards,
> >=20
> > tcpdump might help, but I presume GSO is no longer working properly=
 on
> > egress.
>=20
> Inner mac header is probably not being set in GRO->GSO GRE path.
> Please try this also:


Thanks, this patch fixes the problem.


>=20
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index bb5947b..51973dd 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -247,6 +247,9 @@ static int gre_gro_complete(struct sk_buff *skb, =
int
> nhoff) err =3D ptype->callbacks.gro_complete(skb, nhoff + grehlen);
>=20
>         rcu_read_unlock();
> +
> +       skb_set_inner_mac_header(skb, nhoff + grehlen);
> +
>         return err;
>  }
>=20
> > Can you try to revert :
> >=20
> > commit abe640984aa492652232b65d3579361cf6d461f5
> > Author: Tom Herbert <therbert@google.com>
> > Date:   Thu Oct 30 08:40:56 2014 -0700
> >=20
> >     gre: Use inner mac length when computing tunnel length
> >    =20
> >     [ Upstream commit 14051f0452a2c26a3f4791e6ad6a435e8f1945ff ]
> >    =20
> >     Currently, skb_inner_network_header is used but this does not a=
ccount
> >     for Ethernet header for ETH_P_TEB. Use skb_inner_mac_header whi=
ch
> >     handles TEB and also should work with IP encapsulation in which=
 case
> >     inner mac and inner network headers are the same.
> >    =20
> >     Tested: Ran TCP_STREAM over GRE, worked as expected.
> >    =20
> >     Signed-off-by: Tom Herbert <therbert@google.com>
> >     Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >     Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> >=20
> > diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> > index 2d24f293f977..8c8493ea6b1c 100644
> > --- a/net/ipv4/gre_offload.c
> > +++ b/net/ipv4/gre_offload.c
> > @@ -50,7 +50,7 @@ static struct sk_buff *gre_gso_segment(struct sk_=
buff
> > *skb,>=20
> >         greh =3D (struct gre_base_hdr *)skb_transport_header(skb);
> >=20
> > -       ghl =3D skb_inner_network_header(skb) - skb_transport_heade=
r(skb);
> > +       ghl =3D skb_inner_mac_header(skb) - skb_transport_header(sk=
b);
> >=20
> >         if (unlikely(ghl < sizeof(*greh)))
> >        =20
> >                 goto out;

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
