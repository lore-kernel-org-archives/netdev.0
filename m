From: Yossi Kuperman <yossiku@mellanox.com>
Subject: RE: [PATCH net 1/2] xfrm6: Fix IPv6 payload_len in
 xfrm6_transport_finish
Date: Wed, 21 Jun 2017 20:38:13 +0000
Message-ID: <AM4PR0501MB227460BDE5F2C9A370E13B80C4DA0@AM4PR0501MB2274.eurprd05.prod.outlook.com>
References: <1497861201-30262-1-git-send-email-yossiku@mellanox.com>
 <20170621053725.GP2631@secunet.com>
 <AM4PR0501MB22743B34120802DA21BCE59BC4DA0@AM4PR0501MB2274.eurprd05.prod.outlook.com>
 <20170621113806.GR2631@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0046.outbound.protection.outlook.com ([104.47.1.46]:26880
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751108AbdFUUiR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 16:38:17 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Yossi Kuperman
> Sent: Wednesday, June 21, 2017 7:00 PM
> To: 'Steffen Klassert' <steffen.klassert@secunet.com>
> Cc: netdev@vger.kernel.org; Herbert Xu <herbert@gondor.apana.org.au>;
> Yevgeny Kliteynik <kliteyn@mellanox.com>; Boris Pismenny
> <borisp@mellanox.com>; Ilan Tayari <ilant@mellanox.com>
> Subject: RE: [PATCH net 1/2] xfrm6: Fix IPv6 payload_len in
> xfrm6_transport_finish
>=20
>=20
>=20
> > -----Original Message-----
> > From: Steffen Klassert [mailto:steffen.klassert@secunet.com]
> > Sent: Wednesday, June 21, 2017 2:38 PM
> > To: Yossi Kuperman <yossiku@mellanox.com>
> > Cc: netdev@vger.kernel.org; Herbert Xu <herbert@gondor.apana.org.au>;
> > Yevgeny Kliteynik <kliteyn@mellanox.com>; Boris Pismenny
> > <borisp@mellanox.com>; Ilan Tayari <ilant@mellanox.com>
> > Subject: Re: [PATCH net 1/2] xfrm6: Fix IPv6 payload_len in
> > xfrm6_transport_finish
> >
> > On Wed, Jun 21, 2017 at 11:24:05AM +0000, Yossi Kuperman wrote:
> > >
> > >
> > > > -----Original Message-----
> > > > From: Steffen Klassert [mailto:steffen.klassert@secunet.com]
> > > > Sent: Wednesday, June 21, 2017 8:37 AM
> > > > To: Yossi Kuperman <yossiku@mellanox.com>
> > > > Cc: netdev@vger.kernel.org; Herbert Xu
> > > > <herbert@gondor.apana.org.au>; Yevgeny Kliteynik
> > > > <kliteyn@mellanox.com>; Boris Pismenny <borisp@mellanox.com>;
> Ilan
> > > > Tayari <ilant@mellanox.com>
> > > > Subject: Re: [PATCH net 1/2] xfrm6: Fix IPv6 payload_len in
> > > > xfrm6_transport_finish
> > > >
> > > > On Mon, Jun 19, 2017 at 11:33:20AM +0300, yossiku@mellanox.com
> > wrote:
> > > > > From: Yossi Kuperman <yossiku@mellanox.com>
> > > > >
> > > > > IPv6 payload length indicates the size of the payload, including
> > > > > any extension headers. In xfrm6_transport_finish,
> > > > > ipv6_hdr(skb)->payload_len is set to the payload size only,
> > > > > regardless of the presence of any extension headers.
> > > > >
> > > > > After ESP GRO transport mode decapsulation, ipv6_rcv trims the
> > > > > packet according to the wrong payload_len, thus corrupting the
> packet.
> > > > >
> > > > > Set payload_len to account for extension headers as well.
> > > > >
> > > > > Fixes: 716062fd4c2f ("[IPSEC]: Merge most of the input path")
> > > > > Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
> > > > > ---
> > > > >  net/ipv6/xfrm6_input.c | 2 +-
> > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > >
> > > > > diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
> > > > > index
> > > > > 08a807b..3ef5d91 100644
> > > > > --- a/net/ipv6/xfrm6_input.c
> > > > > +++ b/net/ipv6/xfrm6_input.c
> > > > > @@ -43,8 +43,8 @@ int xfrm6_transport_finish(struct sk_buff
> > > > > *skb, int
> > > > async)
> > > > >  		return 1;
> > > > >  #endif
> > > > >
> > > > > -	ipv6_hdr(skb)->payload_len =3D htons(skb->len);
> > > > >  	__skb_push(skb, skb->data - skb_network_header(skb));
> > > > > +	ipv6_hdr(skb)->payload_len =3D htons(skb->len - sizeof(struct
> > > > > +ipv6hdr));
> > > >
> > > > You mentioned that the bug happens with ESP GRO. Does this bug
> > > > also happen in the standard codepath? If not, you might better
> > > > move the above line into the 'if' section below.
> > > >
> > >
> > > Yes, it happens only with ESP GRO.
> >
> > In this case your Fixes tag is wrong.

The bug is there nonetheless, it just doesn't seem to affect anything.
I guess no one was looking inside the IP header thereafter. =20

Should I use this instead: 7785bba299a8 ("esp: Add a software GRO codepath"=
)?

> >
> > > Normally, ipv6_rcv happens first which trims the packet correctly
> > > and then
> > comes xfrm6_transport_finish.
> > > Now, with ESP GRO introduced, xfrm6_transport_finish, which comes
> > > first, modifies the packet's payload_len, and followed by a call to
> > > ipv6_rcv
> > which trims it wrongly.
> > >
> > > If I understand you right, you suggest to move the new line under the=
 "if"
> > section and restore the removed line?
> >
> > I just want to make sure that the standard codepath works with this can=
ge.
> > Did you test this with the standard codepath too?
>=20
> Sure, it works when GRO is disabled (esp6_offload is not loaded).
> Tested: ping, iperf (TCP stream) and injected manually created packets wi=
th
> extension headers.
