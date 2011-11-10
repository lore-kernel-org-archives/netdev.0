From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Thu, 10 Nov 2011 18:27:03 +0200
Message-ID: <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1320673364.3020.21.camel@bwh-desktop>
 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111109.163708.2156133928191684256.davem@davemloft.net>
 <1320876183.3272.8.camel@edumazet-laptop>
 <1320884940.5825.34.camel@edumazet-laptop>
 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Received: from mms3.broadcom.com ([216.31.210.19]:1668 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932822Ab1KJQ1T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 11:27:19 -0500
In-Reply-To: <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-10 at 07:27 -0800, Eric Dumazet wrote:
> Le jeudi 10 novembre 2011 =C3=A0 17:05 +0200, Eilon Greenstein a =C3=A9=
crit :
> > > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > > @@ -1185,9 +1185,14 @@ struct bnx2x {
> > >  #define ETH_MAX_PACKET_SIZE		1500
> > >  #define ETH_MAX_JUMBO_PACKET_SIZE	9600
> > > =20
> > > -	/* Max supported alignment is 256 (8 shift) */
> > > -#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
> > > -					 L1_CACHE_SHIFT : 8)
> > > +/* Max supported alignment is 256 (8 shift)
> > > + * It should ideally be min(L1_CACHE_SHIFT, 8)
> > > + * Choosing 5 (32 bytes) permits to get skb heads of 2048 bytes
> > > + * instead of 4096 bytes.
> > > + * With SLUB/SLAB allocators, data will be cache line aligned an=
yway.
> > > + */
> > > +#define BNX2X_RX_ALIGN_SHIFT		5
> > > +
> >=20
> > Hi Eric,
> >=20
> > This can seriously hurt the PCI utilization. So in scenarios in whi=
ch
> > the PCI is the bottle neck, you will see performance degradation. W=
e are
> > looking at alternatives to reduce the allocation, but it is taking =
a
> > while. Please hold off with this patch.
>=20
> What do you mean exactly ?
>=20
> This patch doesnt change skb->data alignment, its still 64 bytes
> aligned. (cqe_fp->placement_offset =3D=3D 2). PCI utilization is the =
same.
>=20
> Only SLOB could get a misalignement, but who uses SLOB for performanc=
e ?

Obviously you are right... But the FW is configured to the wrong
alignment and that will affect the end alignment (padding) which is
significant in small packets scenarios where the PCI is the bottle neck=
=2E

> Alternative would be to check why hardware need 2*L1_CACHE_BYTES extr=
a
> room for alignment... Normaly it could be 1*L1_CACHE_BYTES ?

Again - you are a mind reader :) This is what we are looking into right
now. The problem is that `if` the buffer is not aligned (SLOB) we can
overstep the allocated boundaries by configuring the FW to align.

>  	/* FW use 2 Cache lines Alignment for start packet and size  */
> -#define BNX2X_FW_RX_ALIGN              (2 << BNX2X_RX_ALIGN_SHIFT)
> +#define BNX2X_FW_RX_ALIGN              (1 << BNX2X_RX_ALIGN_SHIFT)
>=20
>=20
>=20
>=20
