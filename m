From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 30 Jan 2012 09:25:11 +0100
Message-ID: <CAHXqBFJ0OfX8TN9ZbyUAM5QbNB=CKFHCJXSWfhens2tMyMTxhw@mail.gmail.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
 <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1327910672.2891.12.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2012/1/30 Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> Le lundi 30 janvier 2012 =C3=A0 09:44 +0200, Or Gerlitz a =C3=A9crit =
:
>> On 1/30/2012 6:36 AM, Roland Dreier wrote:
>> > On Thu, Jan 26, 2012 at 6:43 AM, Or Gerlitz<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>=
 =C2=A0wrote:
>> >> The GRO flow makes a check in every layer to ensure the packets
>> >> are actually merged only if they match at all layers.
>> >>
>> >> The first GRO check, at L2 always fails for IPoIB, since it assum=
es
>> >> that all packets have 14 bytes of Ethernet link layer header. Usi=
ng the
>> >> IPoIB header will not help here either, since its only four bytes=
=2E To
>> >> overcome this, the skb mac header pointer is set to an area withi=
n the
>> >> packet IB GRH headroom, such that later, the L2 check done by GRO
>> >> succeeds and it can move to checks at the network and transport l=
ayers.
>> >
>> >> --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
>> >> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
>> >> @@ -286,10 +287,20 @@ static void ipoib_ib_handle_rx_wc(struct ne=
t_device *dev, struct ib_wc *wc)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->pkt_=
type =3D PACKET_MULTICAST;
>> >>
>> >> - =C2=A0 =C2=A0 =C2=A0 skb_pull(skb, IB_GRH_BYTES);
>> >> + =C2=A0 =C2=A0 =C2=A0 /*
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* GRO first does L2 compares (14 byt=
es). We must not let it start from
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* the IPoIB header as ten octets of =
the IP header, containing fields
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* which vary from packet to packet w=
ill cause non-merging of packets.
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* from the same TCP stream.
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> + =C2=A0 =C2=A0 =C2=A0 psgid =3D skb_pull(skb, offsetof(struct ib=
_grh, sgid));
>> >> + =C2=A0 =C2=A0 =C2=A0 /* if there's no GRH, that area could cont=
ain random data */
>> >> + =C2=A0 =C2=A0 =C2=A0 if (!(wc->wc_flags& =C2=A0IB_WC_GRH))
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(psgid, =
0, 16);
>> >> + =C2=A0 =C2=A0 =C2=A0 skb_reset_mac_header(skb);
>> >> + =C2=A0 =C2=A0 =C2=A0 skb_pull(skb, IB_GRH_BYTES - offsetof(stru=
ct ib_grh, sgid));
>> >>
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->protocol =3D ((struct ipoib_head=
er *) skb->data)->proto;
>> >> - =C2=A0 =C2=A0 =C2=A0 skb_reset_mac_header(skb);
>> >
>> > This seems like a really weird place to fix this. =C2=A0Wouldn't i=
t
>> > make more sense to fix the GRO check to handle non-ethernet L2 hea=
ders?
>>
>> Yes, we can do that as well. Herbert, Dave, would it be enough here,=
 to
>> skip the Ethernet header and vlan comparison for skbs whose associat=
ed
>> netdevice type isn't ARPHRD_ETHER? e.g something along the lines of:
>>
>> > diff --git a/net/core/dev.c b/net/core/dev.c
>> > index 115dee1..c529f5a 100644
>> > --- a/net/core/dev.c
>> > +++ b/net/core/dev.c
>> > @@ -3505,9 +3505,11 @@ __napi_gro_receive(struct napi_struct *napi=
,
>> > struct sk_buff *skb)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned l=
ong diffs;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 diffs =3D =
(unsigned long)p->dev ^ (unsigned long)skb->dev;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 diffs |=3D p->v=
lan_tci ^ skb->vlan_tci;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 diffs |=3D comp=
are_ether_header(skb_mac_header(p),
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 skb_gro_mac_header(skb));
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!diffs && p=
->dev->type =3D=3D ARPHRD_ETHER) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 diffs |=3D p->vlan_tci ^ skb->vlan_tci;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 diffs |=3D compare_ether_header(skb_mac_header(p),
>> > +
>> > skb_gro_mac_header(skb));
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NAPI_GRO_C=
B(p)->same_flow =3D !diffs;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NAPI_GRO_C=
B(p)->flush =3D 0;
>
> Hmm, do we really need to compare ether header, thats the question.
>
> IMHO, GRO could avoid this check, as legal trafic could be never merg=
ed
> (eg multipath)

This would allow injecting data to the connection by other host on the
same LAN. GRO does coalescing before any L3 anti-spoofing checks (eg.
rpfilter) are done, doesn't it?

Best Regards,
Micha=C5=82 Miros=C5=82aw
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
