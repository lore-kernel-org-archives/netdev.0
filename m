From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 16:59:04 +0100
Message-ID: <1324483144.2301.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46025 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab1LUP7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 10:59:09 -0500
Received: by wgbdr13 with SMTP id dr13so14450454wgb.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 07:59:07 -0800 (PST)
In-Reply-To: <4EF1EC28.90008@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 15:24 +0100, Michal Simek a =C3=
=A9crit :
> Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 14:28 +0100, Michal Simek =
a =C3=A9crit :
> >=20
> >> ok. Can you provide me any background why size should be setup by
> >> size =3D SKB_WITH_OVERHEAD(ksize(data));
> >> and not to use size which is passed to kmalloc in __alloc_skb.
> >=20
> > Its all about memory accounting (based on skb->truesize)
> >=20
> > Prior to the patch, we could fool memory accounting because skbs cl=
aimed
> > to use less memory than what they really used.
> >=20
> > And crash machines eventually.
> >=20
> > Now memory accouting is fixed, we probably need to change some poin=
ts in
> > the kernel, where we previously accepted a small skb, but not a ver=
y
> > large one.
> >=20
> > Since "ping" probably uses SOCK_RAW sockets, I'll try this one :
> >=20
> > (We dont care of _this_ skb truesize, only on the count of previous=
ly
> > queued packets)
> >=20
> >=20
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 0da505c..a809a48 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -1631,8 +1631,7 @@ static int packet_rcv(struct sk_buff *skb, st=
ruct net_device *dev,
> >  	if (snaplen > res)
> >  		snaplen =3D res;
> > =20
> > -	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
> > -	    (unsigned)sk->sk_rcvbuf)
> > +	if (atomic_read(&sk->sk_rmem_alloc) >=3D (unsigned)sk->sk_rcvbuf)
> >  		goto drop_n_acct;
> > =20
> >  	if (skb_shared(skb)) {
> > @@ -1763,7 +1762,7 @@ static int tpacket_rcv(struct sk_buff *skb, s=
truct net_device *dev,
> >  	if (po->tp_version <=3D TPACKET_V2) {
> >  		if (macoff + snaplen > po->rx_ring.frame_size) {
> >  			if (po->copy_thresh &&
> > -				atomic_read(&sk->sk_rmem_alloc) + skb->truesize
> > +				atomic_read(&sk->sk_rmem_alloc)
> >  				< (unsigned)sk->sk_rcvbuf) {
> >  				if (skb_shared(skb)) {
> >  					copy_skb =3D skb_clone(skb, GFP_ATOMIC);
> >=20
> >=20
> >=20
> >=20
>=20
> It doesn't work too.
> It is possible to see this behavior on qemu. What about if I prepare =
you package with cross toolchain, rootfs
> and you can add debug message where you want?
>=20
> I have also tried ll_temac driver with ppc440 and behavior is the sam=
e.
>=20
> Max FRAME_SIZE pass to netdev_alloc_skb_ip_align is 7966. For this va=
lue ping works.
> (For ll_temac driver it is #define XTE_JUMBO_MTU 7948 from ll_temac.h=
)
>=20

I wonder if you applied/tested my patch correctly, since it really
should had help in your case  (allowing first received packet to be
queued, even if very big)

Given the way NIC drivers work (pre-allocating big buffers before
hardware fill frames in them), SO_RCVBUF limits are difficult to
respect.

We should allow at least one frame, even with a very small SO_RCVBUF
setting, or silently cap a minimum sane value.
