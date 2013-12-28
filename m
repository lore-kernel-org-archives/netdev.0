From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 11/20] net: packetengines: slight
 optimization of addr
Date: Sat, 28 Dec 2013 09:23:00 -0800
Message-ID: <1388251380.24123.15.camel@joe-AO722>
References: <52BE6D0D.9050301@huawei.com>
	 <52BED8ED.2040908@cogentembedded.com> <52BEEBD5.1040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BEEBD5.1040301@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-12-28 at 23:18 +0800, Ding Tianhong wrote:
> =E4=BA=8E 2013/12/28 21:58, Sergei Shtylyov =E5=86=99=E9=81=93:
> > Hello.
> >=20
> > On 28-12-2013 10:17, Ding Tianhong wrote:
> >=20
> >> Use possibly more efficient ether_addr_equal
> >> to instead of memcmp.
> >=20
> >> Cc: "David S. Miller" <davem@davemloft.net>
> >> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> >> ---
> >>   drivers/net/ethernet/packetengines/yellowfin.c |   12 ++++++----=
--
> >>   1 files changed, 6 insertions(+), 6 deletions(-)
> >=20
> >> diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/driv=
ers/net/ethernet/packetengines/yellowfin.c
> >> index d28593b..b83ac0e 100644
> >> --- a/drivers/net/ethernet/packetengines/yellowfin.c
> >> +++ b/drivers/net/ethernet/packetengines/yellowfin.c
> >> @@ -1097,12 +1097,12 @@ static int yellowfin_rx(struct net_device =
*dev)
> >>               if (status2 & 0x80) dev->stats.rx_dropped++;
> >>   #ifdef YF_PROTOTYPE        /* Support for prototype hardware err=
ata. */
> >>           } else if ((yp->flags & HasMACAddrBug)  &&
> >> -            memcmp(le32_to_cpu(yp->rx_ring_dma +
> >> -                entry*sizeof(struct yellowfin_desc)),
> >> -                dev->dev_addr, 6) !=3D 0 &&
> >> -            memcmp(le32_to_cpu(yp->rx_ring_dma +
> >> -                entry*sizeof(struct yellowfin_desc)),
> >> -                "\377\377\377\377\377\377", 6) !=3D 0) {
> >> +            !ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
> >> +                              entry * sizeof(struct yellowfin_des=
c)),
> >> +                              dev->dev_addr) &&
> >=20
> >    Previous line was aligned correctly, the above line should start=
 under le32_to_cpu.
> >=20
> >> +            !ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
> >> +                              entry * sizeof(struct yellowfin_des=
c)),
> >=20
> >    Start the continuation lines under 'yp', please.
> >=20
> >> +                              "\377\377\377\377\377\377")) {
> >=20
> >    This line should start under le32_to_cpu.
> >=20
> > WBR, Sergei
> >=20
>=20
> Hi sergei:
> you mean this way?
> 	!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
> 				      entry * sizeof(struct yellowfin_desc)),
> 			  dev->dev_addr) &&
>=20
> 	!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
> 				      entry * sizeof(struct yellowfin_desc)),
> 			  "\377\377\377\377\377\377")) {

Does this really matter?
Does anyone have a packetengine NIC anymore?

\377 octal is 0xff, so this is matching a broadcast address.
is_broadcast_ether_addr(addr) would be appropriate.

So would using a temporary address.

u8 *addr =3D (u8 *)(unsigned long)le32_to_cpu(etc)

but the whole thing looks very suspect as an le32
value could not be added to correctly on a
big-endian arch anyway.

My guess is this was tested only on an x86 and
it should be:

	u8 *addr =3D (u8 *)(unsigned long)(le32_to_cpu(yp->rx_ring_dma) +
					 entry * sizeof(struct yellowfin_desc));

It maybe better just to leave these two alone.
