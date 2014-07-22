From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] net/macb: add RX checksum offload feature
Date: Wed, 23 Jul 2014 00:58:28 +0200
Message-ID: <1406069908.3363.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
		 <f29965fee23dc0de99b388373017efeffa1aac10.1405689937.git.cyrille.pitchen@atmel.com>
	 <1405697784.10255.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53CE9109.9040407@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53CE9109.9040407@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-07-22 at 18:27 +0200, Cyrille Pitchen wrote:
> Le 18/07/2014 17:36, Eric Dumazet a =C3=A9crit :
> > On Fri, 2014-07-18 at 16:21 +0200, Cyrille Pitchen wrote:
> >> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> >> ---
> >>  drivers/net/ethernet/cadence/macb.c | 29 ++++++++++++++++++++++++=
++++-
> >>  drivers/net/ethernet/cadence/macb.h |  2 ++
> >>  2 files changed, 30 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/eth=
ernet/cadence/macb.c
> >> index 9bdcd1b..6acd6e2 100644
> >> --- a/drivers/net/ethernet/cadence/macb.c
> >> +++ b/drivers/net/ethernet/cadence/macb.c
> >> @@ -766,6 +766,8 @@ static int gem_rx(struct macb *bp, int budget)
> >> =20
> >>  		skb->protocol =3D eth_type_trans(skb, bp->dev);
> >>  		skb_checksum_none_assert(skb);
> >> +		if (bp->dev->features & NETIF_F_RXCSUM)
> >> +			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> >> =20
> >=20
> >=20
> > Really ?
> >=20
> > If this is what you meant, this deserves a big and fat comment.
> >=20
> >=20
> >=20
> Hi Eric,
>=20
> Isn't it the proper way to do? According to Cadence documentation
> about RX checksum offload:
> "If any of the checksums (IP, TCP or UDP) are verified incorrect by
> the GEM, the packet is discarded."
>=20
> If I understand, when RX checksum offload is enabled setting bit 24 o=
f
> the Network Configuration Register, the driver only receives RX frame=
s
> with correct checksum. Then it tells the kernel that there's no need
> to verify the checksum again in software. This is done setting
> skb->ip_summed to CHECKSUM_UNNECESSARY. Intel e1000 driver does the
> same in e1000_rx_checksum() function.
>=20
> Also bit 24 of the Network Configuration Register is updated by
> macb_open() and macb_set_features() so it always matches the state of
> NETIF_F_RXCSUM flag in dev->features, once the network interface is
> up. That's why I'd rather read from dev->features than read from
> register.
>=20
> Did I make a mistake? Is it the kind of comment you expect to be
> added?
>=20
> Regards,

Usually, frames are not discarded, and a bit is present in rx descripto=
r
to tell us if (TCP) checksum was validated by the NIC

We want tcpdump to get a copy of corrupted TCP frames, even if TCP stac=
k
drops them later.

If this NIC drops incorrect frames, I am afraid we cant use this RX
offload at all.
