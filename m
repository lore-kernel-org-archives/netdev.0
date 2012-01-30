From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Mon, 30 Jan 2012 09:04:32 +0100
Message-ID: <1327910672.2891.12.camel@edumazet-laptop>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
	 <4F264A6C.3070706@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F264A6C.3070706-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le lundi 30 janvier 2012 =C3=A0 09:44 +0200, Or Gerlitz a =C3=A9crit :
> On 1/30/2012 6:36 AM, Roland Dreier wrote:
> > On Thu, Jan 26, 2012 at 6:43 AM, Or Gerlitz<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> =
 wrote:
> >> The GRO flow makes a check in every layer to ensure the packets
> >> are actually merged only if they match at all layers.
> >>
> >> The first GRO check, at L2 always fails for IPoIB, since it assume=
s
> >> that all packets have 14 bytes of Ethernet link layer header. Usin=
g the
> >> IPoIB header will not help here either, since its only four bytes.=
 To
> >> overcome this, the skb mac header pointer is set to an area within=
 the
> >> packet IB GRH headroom, such that later, the L2 check done by GRO
> >> succeeds and it can move to checks at the network and transport la=
yers.
> >
> >> --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> >> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> >> @@ -286,10 +287,20 @@ static void ipoib_ib_handle_rx_wc(struct net=
_device *dev, struct ib_wc *wc)
> >>         else
> >>                 skb->pkt_type =3D PACKET_MULTICAST;
> >>
> >> -       skb_pull(skb, IB_GRH_BYTES);
> >> +       /*
> >> +        * GRO first does L2 compares (14 bytes). We must not let =
it start from
> >> +        * the IPoIB header as ten octets of the IP header, contai=
ning fields
> >> +        * which vary from packet to packet will cause non-merging=
 of packets.
> >> +        * from the same TCP stream.
> >> +        */
> >> +       psgid =3D skb_pull(skb, offsetof(struct ib_grh, sgid));
> >> +       /* if there's no GRH, that area could contain random data =
*/
> >> +       if (!(wc->wc_flags&  IB_WC_GRH))
> >> +               memset(psgid, 0, 16);
> >> +       skb_reset_mac_header(skb);
> >> +       skb_pull(skb, IB_GRH_BYTES - offsetof(struct ib_grh, sgid)=
);
> >>
> >>         skb->protocol =3D ((struct ipoib_header *) skb->data)->pro=
to;
> >> -       skb_reset_mac_header(skb);
> >
> > This seems like a really weird place to fix this.  Wouldn't it
> > make more sense to fix the GRO check to handle non-ethernet L2 head=
ers?
>=20
> Yes, we can do that as well. Herbert, Dave, would it be enough here, =
to=20
> skip the Ethernet header and vlan comparison for skbs whose associate=
d=20
> netdevice type isn't ARPHRD_ETHER? e.g something along the lines of:
>=20
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 115dee1..c529f5a 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3505,9 +3505,11 @@ __napi_gro_receive(struct napi_struct *napi,=
=20
> > struct sk_buff *skb)
> >                 unsigned long diffs;
> >
> >                 diffs =3D (unsigned long)p->dev ^ (unsigned long)sk=
b->dev;
> > -               diffs |=3D p->vlan_tci ^ skb->vlan_tci;
> > -               diffs |=3D compare_ether_header(skb_mac_header(p),
> > -                                             skb_gro_mac_header(sk=
b));
> > +               if (!diffs && p->dev->type =3D=3D ARPHRD_ETHER) {
> > +                       diffs |=3D p->vlan_tci ^ skb->vlan_tci;
> > +                       diffs |=3D compare_ether_header(skb_mac_hea=
der(p),
> > +                                                    =20
> > skb_gro_mac_header(skb));
> > +               }
> >                 NAPI_GRO_CB(p)->same_flow =3D !diffs;
> >                 NAPI_GRO_CB(p)->flush =3D 0;

Hmm, do we really need to compare ether header, thats the question.

IMHO, GRO could avoid this check, as legal trafic could be never merged
(eg multipath)





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
