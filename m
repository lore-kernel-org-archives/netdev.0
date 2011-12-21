From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 00:01:42 +0800
Message-ID: <1324483302.6471.3.camel@barry.pixelworks.com>
References: <4EF1B0D9.2010007@monstr.eu>
	 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B5BC.5020103@monstr.eu>
	 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B7E4.4010602@monstr.eu>
	 <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324465386.2728.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1BEA4.7080005@monstr.eu>
	 <1324466023.2728.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1C80B.4060701@monstr.eu>
	 <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1DF00.1090309@monstr.eu>
	 <1324474811.2728.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1EC28.90008@monstr.eu>
	 <1324481439.2301.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324482285.2301.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40082 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab1LUQCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 11:02:41 -0500
Received: by ggdk6 with SMTP id k6so5613905ggd.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 08:02:40 -0800 (PST)
In-Reply-To: <1324482285.2301.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 16:44 +0100, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 16:30 +0100, Eric Dumazet a =
=C3=A9crit :
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 15:24 +0100, Michal Simek =
a =C3=A9crit :
> > > Eric Dumazet wrote:
> > > > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 14:28 +0100, Michal Si=
mek a =C3=A9crit :
> > > >=20
> > > >> ok. Can you provide me any background why size should be setup=
 by
> > > >> size =3D SKB_WITH_OVERHEAD(ksize(data));
> > > >> and not to use size which is passed to kmalloc in __alloc_skb.
> > > >=20
> > > > Its all about memory accounting (based on skb->truesize)
> > > >=20
> > > > Prior to the patch, we could fool memory accounting because skb=
s claimed
> > > > to use less memory than what they really used.
> > > >=20
> > > > And crash machines eventually.
> > > >=20
> > > > Now memory accouting is fixed, we probably need to change some =
points in
> > > > the kernel, where we previously accepted a small skb, but not a=
 very
> > > > large one.
> > > >=20
> > > > Since "ping" probably uses SOCK_RAW sockets, I'll try this one =
:
> > > >=20
> > > > (We dont care of _this_ skb truesize, only on the count of prev=
iously
> > > > queued packets)
> > > >=20
> > > >=20
> > > > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > > > index 0da505c..a809a48 100644
> > > > --- a/net/packet/af_packet.c
> > > > +++ b/net/packet/af_packet.c
> > > > @@ -1631,8 +1631,7 @@ static int packet_rcv(struct sk_buff *skb=
, struct net_device *dev,
> > > >  	if (snaplen > res)
> > > >  		snaplen =3D res;
> > > > =20
> > > > -	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
> > > > -	    (unsigned)sk->sk_rcvbuf)
> > > > +	if (atomic_read(&sk->sk_rmem_alloc) >=3D (unsigned)sk->sk_rcv=
buf)
> > > >  		goto drop_n_acct;
> > > > =20
> > > >  	if (skb_shared(skb)) {
> > > > @@ -1763,7 +1762,7 @@ static int tpacket_rcv(struct sk_buff *sk=
b, struct net_device *dev,
> > > >  	if (po->tp_version <=3D TPACKET_V2) {
> > > >  		if (macoff + snaplen > po->rx_ring.frame_size) {
> > > >  			if (po->copy_thresh &&
> > > > -				atomic_read(&sk->sk_rmem_alloc) + skb->truesize
> > > > +				atomic_read(&sk->sk_rmem_alloc)
> > > >  				< (unsigned)sk->sk_rcvbuf) {
> > > >  				if (skb_shared(skb)) {
> > > >  					copy_skb =3D skb_clone(skb, GFP_ATOMIC);
> > > >=20
> > > >=20
> > > >=20
> > > >=20
> > >=20
> > > It doesn't work too.
> > > It is possible to see this behavior on qemu. What about if I prep=
are you package with cross toolchain, rootfs
> > > and you can add debug message where you want?
> > >=20
> > > I have also tried ll_temac driver with ppc440 and behavior is the=
 same.
> > >=20
> > > Max FRAME_SIZE pass to netdev_alloc_skb_ip_align is 7966. For thi=
s value ping works.
> > > (For ll_temac driver it is #define XTE_JUMBO_MTU 7948 from ll_tem=
ac.h)
> >=20
> > I did several tests with MTU 9000 on my machines and it works well.
> >=20
> > It seems my pings (iputils-sss20071127 or iputils-sss20101006) uses=
 a
> > big enough RCVBUF
> >=20
> > setsockopt(3, SOL_SOCKET, SO_RCVBUF, [65536], 4) =3D 0
> > getsockopt(3, SOL_SOCKET, SO_RCVBUF, [131072], [4]) =3D 0
> >=20
> > Could you check with "strace ping..." what is doing busybox ?
>=20
> I found it : Its too small for jumbo frames.
>=20
> setsockopt(3, SOL_SOCKET, SO_RCVBUF, [7280], 4) =3D 0
>=20
> networking/ping.c
>=20
>=20
>         /* set recv buf (needed if we can get lots of responses: floo=
d ping,
>          * broadcast ping etc) */
>         sockopt =3D (datalen * 2) + 7 * 1024; /* giving it a bit of e=
xtra room */
>         setsockopt(pingsock, SOL_SOCKET, SO_RCVBUF, &sockopt, sizeof(=
sockopt));
>=20
>=20
>=20
> --

Why receive buffer size MUST bigger than the jumbo frames size even if
the packet size is small?

> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
