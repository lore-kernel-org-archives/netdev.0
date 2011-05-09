From: "Christian T. Steigies" <cts@debian.org>
Subject: Re: 8390 drivers (was: Re: Debian kernel 2.6.38-5)
Date: Mon, 9 May 2011 23:32:13 +0200
Message-ID: <20110509213213.GA28675@chumley.earth.sol>
References: <BANLkTimG+3jqLiLaA_NVEpGg3LFtvK4bQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Thorsten Glaser <tg@mirbsd.de>, linux-m68k@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimG+3jqLiLaA_NVEpGg3LFtvK4bQQ@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 09, 2011 at 10:38:18PM +0200, Geert Uytterhoeven wrote:
> On Mon, May 9, 2011 at 22:25, Christian T. Steigies <cts@debian.org> =
wrote:
> > On Mon, May 09, 2011 at 09:16:16AM +0200, Geert Uytterhoeven wrote:
> >> On Mon, May 9, 2011 at 01:14, Finn Thain <fthain@telegraphics.com.=
au> wrote:
> >> > On Sun, 8 May 2011, Christian T. Steigies wrote:
> >> >> PS 2.6.28 did not boot: kernel too old. When was TLS introduced=
? I'll try to
> >> >> apply the patch you mentioned in your other message.
> >> >
> >> > I sometimes test network cards with busybox. It can be built wit=
hout
> >> > linking in glibc and doesn't need TLS.
> >> >
> >> >
> >> >> [ =A0130.870000] eth0: trigger_send() called with the transmitt=
er busy.
> >> >> [ =A0132.240000] ------------[ cut here ]------------
> >> >> [ =A0132.240000] WARNING: at net/sched/sch_generic.c:256 dev_wa=
tchdog+0x1ac/0x1cc()
> >> >> [ =A0132.250000] NETDEV WATCHDOG: eth0 (): transmit queue 0 tim=
ed out
> >> >
> >> > Looks a lot like this problem:
> >> >
> >> > http://patchwork.ozlabs.org/patch/27774/
> >>
> >> Yeah, that's a very likely culprit. Thx!
> >
> > I applied the following patch and it works! apt-get update that is,=
 there is
> > no sshd on this freshly installed system yet...
> >
> > I also changed this line to have 4 underscores at the beginning:
> >
> > =A0 =A0 =A0 =A0{ 0xec940559, "____alloc_ei_netdev" },
>=20
> In which file is that?

zorro8390.mod.c
=20
> > it does not show up in git diff, so I am not sure if this is a left=
over from
> > a previous checkout, or if it is also needed. And if it is needed, =
if it
> > should be two underscores or four or none, and if so why or why not=
=2E..
> > Looking at the other drivers, there does not seem to be a lot of co=
nsistency?
>=20
> From this, I guess hydra and ne-h8300 are also affected, as they
> include lib8390.c
> theirselves and are linked with 8390.o?
>=20
> > diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
> > index b78a38d9..8c7c522 100644
> > --- a/drivers/net/zorro8390.c
> > +++ b/drivers/net/zorro8390.c
> > @@ -126,7 +126,7 @@ static int __devinit zorro8390_init_one(struct =
zorro_dev *z,
> >
> > =A0 =A0 board =3D z->resource.start;
> > =A0 =A0 ioaddr =3D board+cards[i].offset;
> > - =A0 =A0dev =3D alloc_ei_netdev();
> > + =A0 =A0dev =3D ____alloc_ei_netdev(0);
> > =A0 =A0 if (!dev)
> > =A0 =A0 =A0 =A0return -ENOMEM;
> > =A0 =A0 if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_NAME)) =
{
> > @@ -146,15 +146,15 @@ static int __devinit zorro8390_init_one(struc=
t zorro_dev *z,
> > =A0static const struct net_device_ops zorro8390_netdev_ops =3D {
> > =A0 =A0 =A0 =A0.ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D zorro8390_=
open,
> > =A0 =A0 =A0 =A0.ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D zorro8390_=
close,
> > - =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D ei_start_xmit,
> > - =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D ei_tx_timeout,
> > - =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D ei_get_stats,
> > - =A0 =A0 =A0 .ndo_set_multicast_list =3D ei_set_multicast_list,
> > + =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D __ei_start_xmit,
> > + =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =A0 =A0 =3D __ei_tx_timeout,
> > + =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0 =A0 =A0=3D __ei_get_stats,
> > + =A0 =A0 =A0 .ndo_set_multicast_list =3D __ei_set_multicast_list,
> > =A0 =A0 =A0 =A0.ndo_validate_addr =A0 =A0 =A0=3D eth_validate_addr,
> > =A0 =A0 =A0 =A0.ndo_set_mac_address =A0 =A0=3D eth_mac_addr,
> > =A0 =A0 =A0 =A0.ndo_change_mtu =A0 =A0 =A0 =A0 =3D eth_change_mtu,
> > =A0#ifdef CONFIG_NET_POLL_CONTROLLER
> > - =A0 =A0 =A0 .ndo_poll_controller =A0 =A0=3D ei_poll,
> > + =A0 =A0 =A0 .ndo_poll_controller =A0 =A0=3D __ei_poll,
> > =A0#endif
> > =A0};
>=20
> And 8390.o can be removed from drivers/net/Makefile?

I did not change that and it still works, modprobe zorro8390 did not lo=
ad
8390. The speed is rather slow, though, 10kbit/sec seems to be the max
speed. I have not been able to log in via ssh yet, maybe after it has
finished downloading packages.

Christian
