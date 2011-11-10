From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Thu, 10 Nov 2011 17:45:12 +0100
Message-ID: <1320943512.10042.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111109.163708.2156133928191684256.davem@davemloft.net>
	 <1320876183.3272.8.camel@edumazet-laptop>
	 <1320884940.5825.34.camel@edumazet-laptop>
	 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64530 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab1KJQpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 11:45:16 -0500
Received: by wwh12 with SMTP id 12so2656192wwh.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 08:45:15 -0800 (PST)
In-Reply-To: <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 18:27 +0200, Eilon Greenstein a =C3=A9=
crit :
> On Thu, 2011-11-10 at 07:27 -0800, Eric Dumazet wrote:
> > Le jeudi 10 novembre 2011 =C3=A0 17:05 +0200, Eilon Greenstein a =C3=
=A9crit :
> > > > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > > > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > > > @@ -1185,9 +1185,14 @@ struct bnx2x {
> > > >  #define ETH_MAX_PACKET_SIZE		1500
> > > >  #define ETH_MAX_JUMBO_PACKET_SIZE	9600
> > > > =20
> > > > -	/* Max supported alignment is 256 (8 shift) */
> > > > -#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
> > > > -					 L1_CACHE_SHIFT : 8)
> > > > +/* Max supported alignment is 256 (8 shift)
> > > > + * It should ideally be min(L1_CACHE_SHIFT, 8)
> > > > + * Choosing 5 (32 bytes) permits to get skb heads of 2048 byte=
s
> > > > + * instead of 4096 bytes.
> > > > + * With SLUB/SLAB allocators, data will be cache line aligned =
anyway.
> > > > + */
> > > > +#define BNX2X_RX_ALIGN_SHIFT		5
> > > > +
> > >=20
> > > Hi Eric,
> > >=20
> > > This can seriously hurt the PCI utilization. So in scenarios in w=
hich
> > > the PCI is the bottle neck, you will see performance degradation.=
 We are
> > > looking at alternatives to reduce the allocation, but it is takin=
g a
> > > while. Please hold off with this patch.
> >=20
> > What do you mean exactly ?
> >=20
> > This patch doesnt change skb->data alignment, its still 64 bytes
> > aligned. (cqe_fp->placement_offset =3D=3D 2). PCI utilization is th=
e same.
> >=20
> > Only SLOB could get a misalignement, but who uses SLOB for performa=
nce ?
>=20
> Obviously you are right... But the FW is configured to the wrong
> alignment and that will affect the end alignment (padding) which is
> significant in small packets scenarios where the PCI is the bottle ne=
ck.

Yes, I fully understand.

>=20
> > Alternative would be to check why hardware need 2*L1_CACHE_BYTES ex=
tra
> > room for alignment... Normaly it could be 1*L1_CACHE_BYTES ?
>=20
> Again - you are a mind reader :) This is what we are looking into rig=
ht
> now. The problem is that `if` the buffer is not aligned (SLOB) we can
> overstep the allocated boundaries by configuring the FW to align.
>=20
> >  	/* FW use 2 Cache lines Alignment for start packet and size  */
> > -#define BNX2X_FW_RX_ALIGN              (2 << BNX2X_RX_ALIGN_SHIFT)
> > +#define BNX2X_FW_RX_ALIGN              (1 << BNX2X_RX_ALIGN_SHIFT)
> >=20
> >=20

I did a SLOB test (and my patch included as well)

skb->len=3D66 pad=3D26 wkb->data=3D0xffff8801194da048 truesize=3D2304

So skb->data + pad -> 0xffff8801194da062 : So a 32bytes alignement + 2
bytes to align IP header. (BTW we dont really need it, NET_IP_ALIGN is
now 0 on most x86 platforms ?)

In the end, we get 98 bytes of 'skb reserve', and also 64 bytes of extr=
a
headroom _after_ the end of full frame.

In my understanding, hardware alignement should be between 0 and 63, no=
t
0 and 127.

So maybe only BNX2X_FW_RX_ALIGN is twice the needed amount.
