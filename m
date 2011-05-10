From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: 8390 drivers (was: Re: Debian kernel 2.6.38-5)
Date: Tue, 10 May 2011 08:52:48 +0200
Message-ID: <BANLkTik27HjWOF0s5HRqgva5zYzQRis27Q@mail.gmail.com>
References: <BANLkTimG+3jqLiLaA_NVEpGg3LFtvK4bQQ@mail.gmail.com>
	<20110509213213.GA28675@chumley.earth.sol>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Finn Thain <fthain@telegraphics.com.au>,
	Thorsten Glaser <tg@mirbsd.de>, linux-m68k@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54334 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144Ab1EJGwv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 02:52:51 -0400
In-Reply-To: <20110509213213.GA28675@chumley.earth.sol>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2011 at 23:32, Christian T. Steigies <cts@debian.org> wr=
ote:
> On Mon, May 09, 2011 at 10:38:18PM +0200, Geert Uytterhoeven wrote:
>> On Mon, May 9, 2011 at 22:25, Christian T. Steigies <cts@debian.org>=
 wrote:
>> > On Mon, May 09, 2011 at 09:16:16AM +0200, Geert Uytterhoeven wrote=
:
>> >> On Mon, May 9, 2011 at 01:14, Finn Thain <fthain@telegraphics.com=
=2Eau> wrote:
>> >> > On Sun, 8 May 2011, Christian T. Steigies wrote:
>> >> >> PS 2.6.28 did not boot: kernel too old. When was TLS introduce=
d? I'll try to
>> >> >> apply the patch you mentioned in your other message.
>> >> >
>> >> > I sometimes test network cards with busybox. It can be built wi=
thout
>> >> > linking in glibc and doesn't need TLS.
>> >> >
>> >> >
>> >> >> [ =C2=A0130.870000] eth0: trigger_send() called with the trans=
mitter busy.
>> >> >> [ =C2=A0132.240000] ------------[ cut here ]------------
>> >> >> [ =C2=A0132.240000] WARNING: at net/sched/sch_generic.c:256 de=
v_watchdog+0x1ac/0x1cc()
>> >> >> [ =C2=A0132.250000] NETDEV WATCHDOG: eth0 (): transmit queue 0=
 timed out
>> >> >
>> >> > Looks a lot like this problem:
>> >> >
>> >> > http://patchwork.ozlabs.org/patch/27774/
>> >>
>> >> Yeah, that's a very likely culprit. Thx!
>> >
>> > I applied the following patch and it works! apt-get update that is=
, there is
>> > no sshd on this freshly installed system yet...
>> >
>> > I also changed this line to have 4 underscores at the beginning:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0{ 0xec940559, "____alloc_ei_netdev" },
>>
>> In which file is that?
>
> zorro8390.mod.c

That's a generated file, so you can ignore it.

>> > it does not show up in git diff, so I am not sure if this is a lef=
tover from
>> > a previous checkout, or if it is also needed. And if it is needed,=
 if it
>> > should be two underscores or four or none, and if so why or why no=
t...
>> > Looking at the other drivers, there does not seem to be a lot of c=
onsistency?
>>
>> From this, I guess hydra and ne-h8300 are also affected, as they
>> include lib8390.c
>> theirselves and are linked with 8390.o?
>>
>> > diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
>> > index b78a38d9..8c7c522 100644
>> > --- a/drivers/net/zorro8390.c
>> > +++ b/drivers/net/zorro8390.c
>> > @@ -126,7 +126,7 @@ static int __devinit zorro8390_init_one(struct=
 zorro_dev *z,
>> >
>> > =C2=A0 =C2=A0 board =3D z->resource.start;
>> > =C2=A0 =C2=A0 ioaddr =3D board+cards[i].offset;
>> > - =C2=A0 =C2=A0dev =3D alloc_ei_netdev();
>> > + =C2=A0 =C2=A0dev =3D ____alloc_ei_netdev(0);
>> > =C2=A0 =C2=A0 if (!dev)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;
>> > =C2=A0 =C2=A0 if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_=
NAME)) {
>> > @@ -146,15 +146,15 @@ static int __devinit zorro8390_init_one(stru=
ct zorro_dev *z,
>> > =C2=A0static const struct net_device_ops zorro8390_netdev_ops =3D =
{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =3D zorro8390_open,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =3D zorro8390_close,
>> > - =C2=A0 =C2=A0 =C2=A0 .ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D ei_start_xmit,
>> > - =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D ei_tx_timeout,
>> > - =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0=3D ei_get_stats,
>> > - =C2=A0 =C2=A0 =C2=A0 .ndo_set_multicast_list =3D ei_set_multicas=
t_list,
>> > + =C2=A0 =C2=A0 =C2=A0 .ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D __ei_start_xmit,
>> > + =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D __ei_tx_timeout,
>> > + =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0=3D __ei_get_stats,
>> > + =C2=A0 =C2=A0 =C2=A0 .ndo_set_multicast_list =3D __ei_set_multic=
ast_list,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_validate_addr =C2=A0 =C2=A0 =C2=A0=
=3D eth_validate_addr,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_set_mac_address =C2=A0 =C2=A0=3D e=
th_mac_addr,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_change_mtu =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =3D eth_change_mtu,
>> > =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
>> > - =C2=A0 =C2=A0 =C2=A0 .ndo_poll_controller =C2=A0 =C2=A0=3D ei_po=
ll,
>> > + =C2=A0 =C2=A0 =C2=A0 .ndo_poll_controller =C2=A0 =C2=A0=3D __ei_=
poll,
>> > =C2=A0#endif
>> > =C2=A0};
>>
>> And 8390.o can be removed from drivers/net/Makefile?
>
> I did not change that and it still works, modprobe zorro8390 did not =
load
> 8390. The speed is rather slow, though, 10kbit/sec seems to be the ma=
x
> speed. I have not been able to log in via ssh yet, maybe after it has
> finished downloading packages.

Yeah, speed depends on CPU type and motherboard/CPU interface.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
