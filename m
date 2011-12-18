From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6/addrconf_dad_failure printk() in interrupt context
Date: Sun, 18 Dec 2011 10:15:08 +0100
Message-ID: <1324199708.3323.71.camel@edumazet-laptop>
References: <201112180328.00422.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Wolfgang Denk <wd@denx.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Marek Vasut <marek.vasut@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38010 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab1LRJPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 04:15:14 -0500
Received: by werm1 with SMTP id m1so805167wer.19
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2011 01:15:13 -0800 (PST)
In-Reply-To: <201112180328.00422.marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 d=C3=A9cembre 2011 =C3=A0 03:28 +0100, Marek Vasut a =C3=
=A9crit :
> Hi,
>=20
> I just recently hit the following issue. I might actually be wrong wi=
th my=20
> conclusions so bear with me. The events that led to the issue:
>=20
> 1) Duplicate IPv6 address on the network
> 2) console driver that locks a mutex when printk() is called

This seems buggy : printk() might be called from irq, so muext_lock() i=
s
not allowed.

>=20
> The problem is the following backtrace:
>=20
> [    4.870000] eth0: IPv6 duplicate address XXXX::YYYY:ZZZZ:WWWW:0 de=
tected!
> [    4.870000] ------------[ cut here ]------------
> [    4.870000] WARNING: at kernel/mutex.c:198 mutex_lock_nested+0x284=
/0x2c0()
> [    4.870000] Modules linked in:
> [    4.870000] [<c0013ab8>] (unwind_backtrace+0x0/0xf0) from [<c001d9=
34>]=20
> (warn_slowpath_common+0x4c/0x64)
> [    4.870000] [<c001d934>] (warn_slowpath_common+0x4c/0x64) from [<c=
001d968>]=20
> (warn_slowpath_null+0x1c/0x24)
> [    4.870000] [<c001d968>] (warn_slowpath_null+0x1c/0x24) from [<c03=
3a4f4>]=20
> (mutex_lock_nested+0x284/0x2c0)
> [    4.870000] [<c033a4f4>] (mutex_lock_nested+0x284/0x2c0) from [<c0=
017d88>]=20
> (clk_enable+0x20/0x48)
> [    4.870000] [<c0017d88>] (clk_enable+0x20/0x48) from [<c01dfbf0>]=20
> (pl011_console_write+0x20/0x74)
> [    4.870000] [<c01dfbf0>] (pl011_console_write+0x20/0x74) from [<c0=
01da98>]=20
> (__call_console_drivers+0x7c/0x94)
> [    4.870000] [<c001da98>] (__call_console_drivers+0x7c/0x94) from [=
<c001df20>]=20
> (console_unlock+0xf8/0x244)
> [    4.870000] [<c001df20>] (console_unlock+0xf8/0x244) from [<c001e3=
08>]=20
> (vprintk+0x29c/0x484)
> [    4.870000] [<c001e308>] (vprintk+0x29c/0x484) from [<c03355a8>]=20
> (printk+0x20/0x30)
> [    4.870000] [<c03355a8>] (printk+0x20/0x30) from [<c02df600>]=20
> (addrconf_dad_failure+0x148/0x158)
> [    4.870000] [<c02df600>] (addrconf_dad_failure+0x148/0x158) from [=
<c02ebde0>]=20
> (ndisc_rcv+0xb38/0xdb0)
> [    4.870000] [<c02ebde0>] (ndisc_rcv+0xb38/0xdb0) from [<c02f1b28>]=
=20
> (icmpv6_rcv+0x6ec/0x9c4)
> [    4.870000] [<c02f1b28>] (icmpv6_rcv+0x6ec/0x9c4) from [<c02da9a4>=
]=20
> (ip6_input_finish+0x144/0x4e0)
> [    4.870000] [<c02da9a4>] (ip6_input_finish+0x144/0x4e0) from [<c02=
db424>]=20
> (ip6_mc_input+0xb8/0x154)
> [    4.870000] [<c02db424>] (ip6_mc_input+0xb8/0x154) from [<c02db12c=
>]=20
> (ipv6_rcv+0x300/0x53c)
> [    4.870000] [<c02db12c>] (ipv6_rcv+0x300/0x53c) from [<c0267b78>]=20
> (__netif_receive_skb+0x240/0x420)
> [    4.870000] [<c0267b78>] (__netif_receive_skb+0x240/0x420) from [<=
c0267de8>]=20
> (process_backlog+0x90/0x150)
> [    4.870000] [<c0267de8>] (process_backlog+0x90/0x150) from [<c026a=
5f8>]=20
> (net_rx_action+0xc0/0x264)
> [    4.870000] [<c026a5f8>] (net_rx_action+0xc0/0x264) from [<c0023cf=
c>]=20
> (__do_softirq+0xa8/0x214)
> [    4.870000] [<c0023cfc>] (__do_softirq+0xa8/0x214) from [<c00242c0=
>]=20
> (irq_exit+0x8c/0x94)
> [    4.870000] [<c00242c0>] (irq_exit+0x8c/0x94) from [<c000f6d0>]=20
> (handle_IRQ+0x34/0x84)
> [    4.870000] [<c000f6d0>] (handle_IRQ+0x34/0x84) from [<c000e5d8>]=20
> (__irq_usr+0x38/0x80)
> [    4.870000] ---[ end trace 32eab6a8dcdca9c0 ]---
>=20
> So basically what I see here is the following order of events:
>=20
> Packet received -> IRQ generated -> ipv6 packet received (still in in=
terrupt=20
> context ... why not in tasklet ... or am I wrong here ?) -> icmpv6 pa=
cket=20
> processing -> addrconf_dad_failure() called -> printk() called in the=
re ->=20
> mutex_lock() called in printk(), causing the warning.
>=20
> Can printk() be actually called in interrupt context?
>=20

Yes, it can be.

> What direction of solving this shall I take?
>=20

Send this to lkml, since its not a netdev issue, but a kernel one.

> Thanks in advance!
