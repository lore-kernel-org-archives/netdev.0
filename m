From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Sun, 13 Nov 2011 20:53:39 +0200
Message-ID: <1321210419.3101.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1320673364.3020.21.camel@bwh-desktop>
 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111109.163708.2156133928191684256.davem@davemloft.net>
 <1320876183.3272.8.camel@edumazet-laptop>
 <1320884940.5825.34.camel@edumazet-laptop>
 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
 <1320943512.10042.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4886 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071Ab1KMSxu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 13:53:50 -0500
In-Reply-To: <1320943512.10042.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-10 at 08:45 -0800, Eric Dumazet wrote:
> Le jeudi 10 novembre 2011 =C3=A0 18:27 +0200, Eilon Greenstein a =C3=A9=
crit :
> > On Thu, 2011-11-10 at 07:27 -0800, Eric Dumazet wrote:
> > > Le jeudi 10 novembre 2011 =C3=A0 17:05 +0200, Eilon Greenstein a =
=C3=A9crit :
> > > > > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > > > > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > > > > @@ -1185,9 +1185,14 @@ struct bnx2x {
> > > > >  #define ETH_MAX_PACKET_SIZE		1500
> > > > >  #define ETH_MAX_JUMBO_PACKET_SIZE	9600
> > > > > =20
> > > > > -	/* Max supported alignment is 256 (8 shift) */
> > > > > -#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
> > > > > -					 L1_CACHE_SHIFT : 8)
> > > > > +/* Max supported alignment is 256 (8 shift)
> > > > > + * It should ideally be min(L1_CACHE_SHIFT, 8)
> > > > > + * Choosing 5 (32 bytes) permits to get skb heads of 2048 by=
tes
> > > > > + * instead of 4096 bytes.
> > > > > + * With SLUB/SLAB allocators, data will be cache line aligne=
d anyway.
> > > > > + */
> > > > > +#define BNX2X_RX_ALIGN_SHIFT		5
> > > > > +
> > > >=20
> > > > Hi Eric,
> > > >=20
> > > > This can seriously hurt the PCI utilization. So in scenarios in=
 which
> > > > the PCI is the bottle neck, you will see performance degradatio=
n. We are
> > > > looking at alternatives to reduce the allocation, but it is tak=
ing a
> > > > while. Please hold off with this patch.
> > >=20
> > > What do you mean exactly ?
> > >=20
> > > This patch doesnt change skb->data alignment, its still 64 bytes
> > > aligned. (cqe_fp->placement_offset =3D=3D 2). PCI utilization is =
the same.
> > >=20
> > > Only SLOB could get a misalignement, but who uses SLOB for perfor=
mance ?
> >=20
> > Obviously you are right... But the FW is configured to the wrong
> > alignment and that will affect the end alignment (padding) which is
> > significant in small packets scenarios where the PCI is the bottle =
neck.
>=20
> Yes, I fully understand.
>=20
> >=20
> > > Alternative would be to check why hardware need 2*L1_CACHE_BYTES =
extra
> > > room for alignment... Normaly it could be 1*L1_CACHE_BYTES ?
> >=20
> > Again - you are a mind reader :) This is what we are looking into r=
ight
> > now. The problem is that `if` the buffer is not aligned (SLOB) we c=
an
> > overstep the allocated boundaries by configuring the FW to align.
> >=20
> > >  	/* FW use 2 Cache lines Alignment for start packet and size  */
> > > -#define BNX2X_FW_RX_ALIGN              (2 << BNX2X_RX_ALIGN_SHIF=
T)
> > > +#define BNX2X_FW_RX_ALIGN              (1 << BNX2X_RX_ALIGN_SHIF=
T)
> > >=20
> > >=20
>=20
> I did a SLOB test (and my patch included as well)
>=20
> skb->len=3D66 pad=3D26 wkb->data=3D0xffff8801194da048 truesize=3D2304
>=20
> So skb->data + pad -> 0xffff8801194da062 : So a 32bytes alignement + =
2
> bytes to align IP header. (BTW we dont really need it, NET_IP_ALIGN i=
s
> now 0 on most x86 platforms ?)
>=20
> In the end, we get 98 bytes of 'skb reserve', and also 64 bytes of ex=
tra
> headroom _after_ the end of full frame.
>=20
> In my understanding, hardware alignement should be between 0 and 63, =
not
> 0 and 127.

I=E2=80=99m not sure I=E2=80=99m following the math over here. Assuming=
 L1 is 64 bytes,
we need up to 63 bytes to align the start address (assuming SLOB is
being used) and additional (up to) 63 bytes at the end. That can sum up
to 126 bytes  am I missing something?

> So maybe only BNX2X_FW_RX_ALIGN is twice the needed amount.

I agree that it does not make much sense to optimize for SLOB - after
checking with our FW expert, it seems that we can change the FW to have
two different configuration flags  for start address alignment and end
packet padding. This way, we can only set the end packet padding and ad=
d
only 64 bytes. The only down side is that the FW team is pre occupied s=
o
this new FW will be ready for submission only in about a month.

Thanks,
Eilon
