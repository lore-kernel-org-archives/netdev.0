From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: 8390 drivers (was: Re: Debian kernel 2.6.38-5)
Date: Mon, 9 May 2011 22:38:18 +0200
Message-ID: <BANLkTimG+3jqLiLaA_NVEpGg3LFtvK4bQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Thorsten Glaser <tg@mirbsd.de>, linux-m68k@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Christian T. Steigies" <cts@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49108 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab1EIUiU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 16:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2011 at 22:25, Christian T. Steigies <cts@debian.org> wr=
ote:
> On Mon, May 09, 2011 at 09:16:16AM +0200, Geert Uytterhoeven wrote:
>> On Mon, May 9, 2011 at 01:14, Finn Thain <fthain@telegraphics.com.au=
> wrote:
>> > On Sun, 8 May 2011, Christian T. Steigies wrote:
>> >> PS 2.6.28 did not boot: kernel too old. When was TLS introduced? =
I'll try to
>> >> apply the patch you mentioned in your other message.
>> >
>> > I sometimes test network cards with busybox. It can be built witho=
ut
>> > linking in glibc and doesn't need TLS.
>> >
>> >
>> >> [ =C2=A0130.870000] eth0: trigger_send() called with the transmit=
ter busy.
>> >> [ =C2=A0132.240000] ------------[ cut here ]------------
>> >> [ =C2=A0132.240000] WARNING: at net/sched/sch_generic.c:256 dev_w=
atchdog+0x1ac/0x1cc()
>> >> [ =C2=A0132.250000] NETDEV WATCHDOG: eth0 (): transmit queue 0 ti=
med out
>> >
>> > Looks a lot like this problem:
>> >
>> > http://patchwork.ozlabs.org/patch/27774/
>>
>> Yeah, that's a very likely culprit. Thx!
>
> I applied the following patch and it works! apt-get update that is, t=
here is
> no sshd on this freshly installed system yet...
>
> I also changed this line to have 4 underscores at the beginning:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ 0xec940559, "____alloc_ei_netdev" },

In which file is that?

> it does not show up in git diff, so I am not sure if this is a leftov=
er from
> a previous checkout, or if it is also needed. And if it is needed, if=
 it
> should be two underscores or four or none, and if so why or why not..=
=2E
> Looking at the other drivers, there does not seem to be a lot of cons=
istency?

=46rom this, I guess hydra and ne-h8300 are also affected, as they
include lib8390.c
theirselves and are linked with 8390.o?

> diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
> index b78a38d9..8c7c522 100644
> --- a/drivers/net/zorro8390.c
> +++ b/drivers/net/zorro8390.c
> @@ -126,7 +126,7 @@ static int __devinit zorro8390_init_one(struct zo=
rro_dev *z,
>
> =C2=A0 =C2=A0 board =3D z->resource.start;
> =C2=A0 =C2=A0 ioaddr =3D board+cards[i].offset;
> - =C2=A0 =C2=A0dev =3D alloc_ei_netdev();
> + =C2=A0 =C2=A0dev =3D ____alloc_ei_netdev(0);
> =C2=A0 =C2=A0 if (!dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM;
> =C2=A0 =C2=A0 if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_NAM=
E)) {
> @@ -146,15 +146,15 @@ static int __devinit zorro8390_init_one(struct =
zorro_dev *z,
> =C2=A0static const struct net_device_ops zorro8390_netdev_ops =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D zorro8390_open,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D zorro8390_close,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 ei_start_xmit,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 ei_tx_timeout,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0=3D ei_get_stats,
> - =C2=A0 =C2=A0 =C2=A0 .ndo_set_multicast_list =3D ei_set_multicast_l=
ist,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 __ei_start_xmit,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_tx_timeout =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 __ei_tx_timeout,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0=3D __ei_get_stats,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_set_multicast_list =3D __ei_set_multicast=
_list,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_validate_addr =C2=A0 =C2=A0 =C2=A0=3D=
 eth_validate_addr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_set_mac_address =C2=A0 =C2=A0=3D eth_=
mac_addr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_change_mtu =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D eth_change_mtu,
> =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
> - =C2=A0 =C2=A0 =C2=A0 .ndo_poll_controller =C2=A0 =C2=A0=3D ei_poll,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_poll_controller =C2=A0 =C2=A0=3D __ei_pol=
l,
> =C2=A0#endif
> =C2=A0};

And 8390.o can be removed from drivers/net/Makefile?

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
