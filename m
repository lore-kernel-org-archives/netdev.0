From: "Narnakaje, Snehaprabha" <nsnehaprabha@ti.com>
Subject: [patch 2.6.28-rc8-davinci-git] dm355: dm9000
Date: Mon, 26 Jan 2009 16:36:50 -0600
Message-ID: <7A436F7769CA33409C6B44B358BFFF0CFC0384D1@dlee02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59959 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbZAZWgy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 17:36:54 -0500
Received: from dlep95.itg.ti.com ([157.170.170.107])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id n0QManmG019779
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 16:36:54 -0600
Received: from dlee73.ent.ti.com (localhost [127.0.0.1])
	by dlep95.itg.ti.com (8.13.8/8.13.8) with ESMTP id n0QMan4Z020210
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 16:36:49 -0600 (CST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am having an issue with the dm9000 driver on a DaVinci DM355 based pl=
atform.

I configure dm9000 to get an IP address through dhcp and then mount via=
 NFS. I get the following dump, just after getting an IP Address and tr=
ying to connect to the NFS server.

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x188/0x2a0()
NETDEV WATCHDOG: eth0 (dm9000): transmit timed out
Modules linked in:
[<c002c890>] (dump_stack+0x0/0x14) from [<c003b81c>] (warn_slowpath+0x6=
4/0x80)
[<c003b7b8>] (warn_slowpath+0x0/0x80) from [<c01bf934>] (dev_watchdog+0=
x188/0x2a0)
 r3:c6c81800 r2:c02af9a4
 r6:c02ce000 r5:c6c81800 r4:c030d710
[<c01bf7ac>] (dev_watchdog+0x0/0x2a0) from [<c00459b4>] (run_timer_soft=
irq+0x1bc/0x278)
[<c00457f8>] (run_timer_softirq+0x0/0x278) from [<c0040a44>] (__do_soft=
irq+0x74/0x110)
[<c00409d0>] (__do_softirq+0x0/0x110) from [<c0040e74>] (irq_exit+0x50/=
0xa0)
[<c0040e24>] (irq_exit+0x0/0xa0) from [<c0028068>] (__exception_text_st=
art+0x68/0x84)
 r4:00000020
[<c0028000>] (__exception_text_start+0x0/0x84) from [<c0028a28>] (__irq=
_svc+0x48/0x88)
Exception stack(0xc02cff40 to 0xc02cff88)
ff40: 00000000 0005317f 0005217f 60000013 c0029e80 c02ce000 c02d1e44 c0=
029e80
ff60: c02e82a4 41069265 80020e54 c02cff94 600000d3 c02cff88 c0029ec4 c0=
029ed0
ff80: 60000013 ffffffff
 r5:fec48000 r4:ffffffff
[<c0029e80>] (default_idle+0x0/0x58) from [<c0029d4c>] (cpu_idle+0x58/0=
x98)
[<c0029cf4>] (cpu_idle+0x0/0x98) from [<c022cb9c>] (rest_init+0x68/0x7c=
)
 r8:80020ef0 r7:c02d1cd8 r6:c0022f0c r5:c02e7e4c r4:c02fd180
[<c022cb34>] (rest_init+0x0/0x7c) from [<c00089f0>] (start_kernel+0x260=
/0x2c0)
[<c0008790>] (start_kernel+0x0/0x2c0) from [<80008034>] (0x80008034)
 r5:c02e8354 r4:00053175
---[ end trace a0edb9581ce81991 ]---


As per the details below, this happens only if I use spinlock/spinunloc=
k sequence in dm9000_start_xmit(). If I change this to dm9000 specific =
disable/enable interrupts, I do see the above dump and platform comes u=
p fine with NFS.

Any ideas?

Thanks a lot,
Sneha


-----Original Message-----
=46rom: davinci-linux-open-source-bounces+nsnehaprabha=3Dti.com@linux.d=
avincidsp.com [mailto:davinci-linux-open-source-bounces+nsnehaprabha=3D=
ti.com@linux.davincidsp.com] On Behalf Of Narnakaje, Snehaprabha
Sent: Tuesday, January 20, 2009 7:38 PM
To: Kevin Hilman; David Brownell
Cc: davinci-linux-open-source@linux.davincidsp.com
Subject: RE: [patch 2.6.28-rc8-davinci-git] dm355: mmc0 works for pio

David, Kevin,

Here is an update on the DM9000 issue.

I spent some time on debugging DM9000 issue - "tx timeout and a kernel =
crash".

In the current version of dm9000 driver (1.3), the hard_start_xmit API =
for DM9000 - dm9000_start_xmiit() uses spin_lock_irqsave(&db->lock, fla=
gs); to disable the interrupts, before accessing/setting DM9000 TX regi=
sters. It also calls spin_unlock_irqrestore(&db->lock, flags); after in=
itiating a tx.=20

In an older version of the dm9000.c (1.2 from kernel 2.6.18 to 2.6.22) =
we just disabled dm9000 rx/tx interrupts by writing to the dm9000 regis=
ter and enabled them after initiating the tx.

It does look like, dm9000 stopped receiving the tx interrupts (at least=
 dm9000_interrupt is not getting called for tx completion) and thus we =
starting seeing tx timeout from the netdev.

I can get NFS working, if I change the spin_lock/spin_unlock function c=
alls to dm9000 specific rx/tx interrupt disable/enable functions.

I believe, dm9000 specific rx/tx interrupt functions were replaced by t=
he spin_lock/spin_unlock functions to a fix a hang problem under heavy =
load.

I will continue to debug this further, wanted to see, if you have any i=
nputs in this area.

I did not see this issue being reported on the netdev kernel.org mailin=
g list, so not sure, if there is a DM355 specific irq initialization we=
 have missed.

Thanks
Sneha

> -----Original Message-----
> From: davinci-linux-open-source-bounces@linux.davincidsp.com
> [mailto:davinci-linux-open-source-bounces@linux.davincidsp.com] On Be=
half
> Of Kevin Hilman
> Sent: Friday, December 19, 2008 11:01 AM
> To: David Brownell
> Cc: davinci-linux-open-source@linux.davincidsp.com
> Subject: Re: [patch 2.6.28-rc8-davinci-git] dm355: mmc0 works for pio
>=20
> David Brownell <david-b@pacbell.net> writes:
>=20
> > On Thursday 18 December 2008, Kevin Hilman wrote:
> >> Strange. =A0I get NETDEV WATCHDOG timeouts whether I try to mount =
over
> >> NFS, or whether I simply ssh from a MMC rootfs to linux box. =A0Th=
is is
> >> with current davinci git head. =A0Have I missed any of your patche=
s?
> >
> > Nothing related to the dm9000 or AEMIF, it seems.  Does using
> >
> >   CONFIG_DM9000_FORCE_SIMPLE_PHY_POLL=3Dy
> >
> > change things?
> >
>=20
> Nope.
>=20
> Kevin
>=20
>=20
>=20
>=20
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-sourc=
e
_______________________________________________
Davinci-linux-open-source mailing list
Davinci-linux-open-source@linux.davincidsp.com
http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
