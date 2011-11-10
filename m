From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Thu, 10 Nov 2011 16:27:58 +0100
Message-ID: <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111109.163708.2156133928191684256.davem@davemloft.net>
	 <1320876183.3272.8.camel@edumazet-laptop>
	 <1320884940.5825.34.camel@edumazet-laptop>
	 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40429 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933707Ab1KJP2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 10:28:02 -0500
Received: by wyh15 with SMTP id 15so2821155wyh.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 07:28:01 -0800 (PST)
In-Reply-To: <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 17:05 +0200, Eilon Greenstein a =C3=A9=
crit :
> On Wed, 2011-11-09 at 16:29 -0800, Eric Dumazet wrote:
> > Le mercredi 09 novembre 2011 =C3=A0 23:03 +0100, Eric Dumazet a =C3=
=A9crit :
> >=20
> > > BTW, on my bnx2x adapter, even small UDP frames use more than PAG=
E_SIZE
> > > bytes :
> > >=20
> > > skb->truesize=3D4352 len=3D26 (payload only)
> > >=20
> >=20
> > > I wonder if we shouldnt increase SK_MEM_QUANTUM a bit to avoid
> > > ping/pong...
> > >=20
> > > -#define SK_MEM_QUANTUM ((int)PAGE_SIZE)
> > > +#define SK_MEM_QUANTUM ((int)PAGE_SIZE * 2)
> > >=20
> >=20
> > Following patch also helps a lot, even with only two cpus (one hand=
ling
> > device interrupts, one running the application thread)
> >=20
> > [PATCH net-next] bnx2x: reduce skb truesize by ~50%
> >=20
> > bnx2x uses following formula to compute its rx_buf_sz :
> >=20
> > dev->mtu + 2*L1_CACHE_BYTES + 14 + 8 + 8
> >=20
> > Then core network adds NET_SKB_PAD and SKB_DATA_ALIGN(sizeof(struct
> > skb_shared_info))
> >=20
> > Final allocated size for skb head on x86_64 (L1_CACHE_BYTES =3D 64,
> > MTU=3D1500) : 2112 bytes : SLUB/SLAB round this to 4096 bytes.
> >=20
> > Since skb truesize is then bigger than SK_MEM_QUANTUM, we have lot =
of
> > false sharing because of mem_reclaim in UDP stack.
> >=20
> > One possible way to half truesize is to lower the need by 64 bytes =
(2112
> > -> 2048 bytes)
> >=20
> > This way, skb->truesize is lower than SK_MEM_QUANTUM and we get bet=
ter
> > performance.
> >=20
> > (760.000 pps on a rx UDP monothread benchmark, instead of 720.000 p=
ps)
> >=20
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Eilon Greenstein <eilong@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |   11 ++++++++---
> >  1 file changed, 8 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x.h
> > index aec7212..ebbdc55 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> > @@ -1185,9 +1185,14 @@ struct bnx2x {
> >  #define ETH_MAX_PACKET_SIZE		1500
> >  #define ETH_MAX_JUMBO_PACKET_SIZE	9600
> > =20
> > -	/* Max supported alignment is 256 (8 shift) */
> > -#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
> > -					 L1_CACHE_SHIFT : 8)
> > +/* Max supported alignment is 256 (8 shift)
> > + * It should ideally be min(L1_CACHE_SHIFT, 8)
> > + * Choosing 5 (32 bytes) permits to get skb heads of 2048 bytes
> > + * instead of 4096 bytes.
> > + * With SLUB/SLAB allocators, data will be cache line aligned anyw=
ay.
> > + */
> > +#define BNX2X_RX_ALIGN_SHIFT		5
> > +
>=20
> Hi Eric,
>=20
> This can seriously hurt the PCI utilization. So in scenarios in which
> the PCI is the bottle neck, you will see performance degradation. We =
are
> looking at alternatives to reduce the allocation, but it is taking a
> while. Please hold off with this patch.

What do you mean exactly ?

This patch doesnt change skb->data alignment, its still 64 bytes
aligned. (cqe_fp->placement_offset =3D=3D 2). PCI utilization is the sa=
me.

Only SLOB could get a misalignement, but who uses SLOB for performance =
?

Alternative would be to check why hardware need 2*L1_CACHE_BYTES extra
room for alignment... Normaly it could be 1*L1_CACHE_BYTES ?

 	/* FW use 2 Cache lines Alignment for start packet and size  */
-#define BNX2X_FW_RX_ALIGN              (2 << BNX2X_RX_ALIGN_SHIFT)
+#define BNX2X_FW_RX_ALIGN              (1 << BNX2X_RX_ALIGN_SHIFT)
