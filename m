From: Ethan Tuttle <ethan@ethantuttle.com>
Subject: mvneta: oops in __rcu_read_lock on mirabox
Date: Sat, 14 Sep 2013 18:05:32 -0700
Message-ID: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:53179 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756848Ab3IOBFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 21:05:34 -0400
Received: by mail-wg0-f45.google.com with SMTP id y10so2429008wgg.0
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 18:05:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I upgraded my mirabox from 3.11-rc4 to 3.11, I started seeing
oopses while receiving network traffic (see below).  Sending a flood
ping will trigger the oops within a few minutes.

The stack looks similar, but not identical to, the one reported
earlier by Jochen De Smet[1].  In my case the PC is always
__rcu_read_lock.

A git bisect found a878764 "Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net" to be the
first bad commit... interesting, because neither of the merge parents
produce the oops.  I rebased the net changes onto the other merge
parent and bisected that series, which identified 702821f "net: revert
8728c544a9c ("net: dev_pick_tx() fix")" as the first bad commit.
Indeed, reverting 702821f from 3.11 produces a kernel which stands up
to a ping flood for hours.

Each of the times I reproduced this, it was identified as "Unhandled
prefetch abort: unknown 25 (0x409) at 0xc0036ea0", except once when I
got "unknown 16 (0x400)".

I'm assuming this is an mvneta bug that was exposed by 702821f.
That's just a guess, and I don't have the skills to debug this any
further.  In any case, I figured the maintainers would want to know
about it.

Thanks much,

Ethan

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2013-September/196332.html

Unhandled prefetch abort: unknown 25 (0x409) at 0xc0036ea0
Internal error: : 409 [#1] PREEMPT SMP ARM
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-ARCH-00005-gecca798 #31
task: c074b140 ti: c0740000 task.ti: c0740000
PC is at __rcu_read_lock+0x1c/0x20
LR is at __netif_receive_skb_core+0x80/0x6fc
pc : [<c0036ea0>]    lr : [<c04528d4>]    psr: 60000113
sp : c0741de8  ip : 5232ad87  fp : ef181800
r10: c073ede4  r9 : c07494b8  r8 : ef181800
r7 : 00000000  r6 : 00000001  r5 : ee972b40  r4 : ee972b40
r3 : c074b140  r2 : 00000001  r1 : 00000042  r0 : 0000ffff
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 10c5387d  Table: 2e8cc019  DAC: 00000015
Process swapper/0 (pid: 0, stack limit = 0xc0740240)
Stack: (0xc0741de8 to 0xc0742000)
1de0:                   00000000 c0741e28 ee972b40 ee972b40 ef300c00 00000067
1e00: f014f000 ee972b40 ee972b40 ee972b40 ef300c00 00000067 f014f000 00000000
1e20: ef181800 c0455a70 b685321e 13236156 ee972b40 ee972b40 ef300c00 00000067
1e40: f014f000 00000003 ee972b40 c04562a8 00000000 ef181c80 f014fce0 c03bd688
1e60: 00000000 00000000 ef181ccc 00000001 00000001 00000001 c077e190 00000040
1e80: 00000100 00000000 ef181800 ef181c80 ef300c00 00000000 ef181ccc c03bd860
1ea0: 00000001 c076ebf8 c03bd7b0 ef181ccc c1363dc0 00000001 0000012c c1363dc8
1ec0: 00000040 c077d773 c07420c0 c0456018 c074208c 000044fe 0000000c 00000001
1ee0: c0742090 c0740000 0000000a 3f8bdf7c 00000000 00200000 00000101 c0024368
1f00: c077e190 c001bc60 00000000 0000000c 00000003 000044fd c02f91ac 00000017
1f20: 00000000 c0741f78 000003ff c07484c0 561f5811 00000000 00000000 c0024768
1f40: 00000017 c000e6c0 f0002870 c00579e4 c07a4440 c000851c c00579e4 60000013
1f60: ffffffff c0741fac c135f4c0 561f5811 00000000 c00118c0 c13629b0 00000000
1f80: 00000000 00000000 c0740000 c077dd00 c055cc88 c0735450 c135f4c0 561f5811
1fa0: 00000000 00000000 00000002 c0741fc0 c000e980 c00579e4 60000013 ffffffff
1fc0: c0740000 c0711a38 ffffffff ffffffff c0711544 00000000 00000000 c0735450
1fe0: 10c5387d c07484fc c073544c c074c290 00004059 00008074 00000000 00000000
[<c0036ea0>] (__rcu_read_lock+0x1c/0x20) from [<c04528d4>]
(__netif_receive_skb_core+0x80/0x6fc)
[<c04528d4>] (__netif_receive_skb_core+0x80/0x6fc) from [<c0455a70>]
(netif_receive_skb+0x60/0xb8)
[<c0455a70>] (netif_receive_skb+0x60/0xb8) from [<c04562a8>]
(napi_gro_receive+0x48/0x98)
[<c04562a8>] (napi_gro_receive+0x48/0x98) from [<c03bd688>]
(mvneta_rx+0x244/0x36c)
[<c03bd688>] (mvneta_rx+0x244/0x36c) from [<c03bd860>] (mvneta_poll+0xb0/0x15c)
[<c03bd860>] (mvneta_poll+0xb0/0x15c) from [<c0456018>]
(net_rx_action+0x70/0x170)
[<c0456018>] (net_rx_action+0x70/0x170) from [<c0024368>]
(__do_softirq+0xd4/0x1c8)
[<c0024368>] (__do_softirq+0xd4/0x1c8) from [<c0024768>] (irq_exit+0x74/0x88)
[<c0024768>] (irq_exit+0x74/0x88) from [<c000e6c0>] (handle_IRQ+0x68/0x8c)
[<c000e6c0>] (handle_IRQ+0x68/0x8c) from [<c000851c>]
(armada_370_xp_handle_irq+0x44/0xa4)
[<c000851c>] (armada_370_xp_handle_irq+0x44/0xa4) from [<c00118c0>]
(__irq_svc+0x40/0x70)
Exception stack(0xc0741f78 to 0xc0741fc0)
1f60:                                                       c13629b0 00000000
1f80: 00000000 00000000 c0740000 c077dd00 c055cc88 c0735450 c135f4c0 561f5811
1fa0: 00000000 00000000 00000002 c0741fc0 c000e980 c00579e4 60000013 ffffffff
[<c00118c0>] (__irq_svc+0x40/0x70) from [<c00579e4>]
(cpu_startup_entry+0xb0/0x114)
[<c00579e4>] (cpu_startup_entry+0xb0/0x114) from [<c0711a38>]
(start_kernel+0x2c8/0x324)
Code: e593300c e59321b4 e2822001 e58321b4 (e12fff1e)
---[ end trace 8f21018165664a9e ]---
Kernel panic - not syncing: Fatal exception in interrupt
