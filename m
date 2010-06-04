From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: still having r8169 woes with XID 18000000
Date: Fri, 04 Jun 2010 23:24:59 +0300
Message-ID: <4C09611B.2090805@iki.fi>
References: <4C08ED47.1030800@iki.fi> <20100604123641.ED8154CD45@orbit.nwl.cc> <4C08F953.1050800@iki.fi> <20100604134351.7981F4CD45@orbit.nwl.cc> <4C09387F.1050403@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?ZnJhbsOnb2lzIHJvbWlldQ==?= <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:43824 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab0FDUZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 16:25:00 -0400
Received: by ewy23 with SMTP id 23so410599ewy.1
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 13:24:58 -0700 (PDT)
In-Reply-To: <4C09387F.1050403@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2010 08:31 PM, Timo Ter=C3=A4s wrote:
> On 06/04/2010 04:43 PM, Phil Sutter wrote:
>> On Fri, Jun 04, 2010 at 04:02:11PM +0300, Timo Ter=C3=A4s wrote:
>>>> Comparing r8169-6.013 with it's predecessor 6.012, you'll find a n=
ewly
>>>> enabled function rtl8169_phy_power_up() as well as some more invoc=
ations
>>>> of rtl8169_phy_power_down().
>>>>
>>>> This is probably the solution to these (at least in our case) very
>>>> sporadic, but highly annoying, problems. In fact, when our NIC did=
n't
>>>> detect any link, it needed a full power-cycle (no success with
>>>> reset-button), so almost not workaroundable.
>>>
> However, removing the specific phy config code
> (rtl8169scd_hw_phy_config) which was introduced by commit 2e955856ff
> seems to solve it. At least I was not able to reproduce the failure w=
ith
> 20-30 module reloads.

Ok, I figured that either the data the phy config writes is bad, or mdi=
o
io is failing, so I added some additional checks to mdio_write and
mdio_read. More loops (upto 2000 iterations) and debug print if it
ultimately failed. And it did!

At bootup I got this:

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:09.0: PCI->APIC IRQ transform: INT A -> IRQ 18
r8169 0000:00:09.0: no PCI Express capability
eth0: RTL8169sc/8110sc at 0xf835c000, 00:30:18:a6:2b:6c, XID 18000000 I=
RQ 18
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:0b.0: PCI->APIC IRQ transform: INT A -> IRQ 19
r8169 0000:00:0b.0: no PCI Express capability
eth1: RTL8169sc/8110sc at 0xf8360000, 00:30:18:a6:2b:6d, XID 18000000 I=
RQ 19
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:0c.0: PCI->APIC IRQ transform: INT A -> IRQ 16
r8169 0000:00:0c.0: no PCI Express capability
eth2: RTL8169sc/8110sc at 0xf8364000, 00:30:18:a6:2b:6e, XID 18000000 I=
RQ 16
r8169: mdio_write(f8364000, 0x00000003, 0000000a1) required 2000 cycles
r8169: mdio_write(f8364000, 0x00000000, 000001000) required 2000 cycles
r8169: mdio_write(f8364000, 0x00000000, 00000a0ff) required 2000 cycles
r8169: mdio_write(f8364000, 0x00000014, 00000fb54) required 2000 cycles

And eth2 was not working. Reloading the module gave a lot of other
mdio_write and mdio_read errors.

It seems to be pretty random when the errors occur, but that's the
reason why the NIC stops working: mdio_write() fails (one or more times=
)
at some crucial point of the board specific phy config code resulting i=
n
bad state.

Any ideas how to debug this further?

I guess next step is to compile the Realtek driver and see if that work=
s
right.

> One more curiosity: if i do a hard power reset, the NIC has green lin=
k
> indicator led after power up. When loading the kernel module it goes =
to
> orange/red. I wonder why the difference.

=46igured this. At startup it goes to 100mbit/s fixed mode. After modul=
e
load it gets 1gb/s. Setting it manually to 100mbit/s changes the color
back to green. So it's just a speed indicator.
