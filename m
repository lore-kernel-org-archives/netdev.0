From: =?iso-8859-1?q?Hans-J=FCrgen_Koch?= <hjk@linutronix.de>
Subject: Re: [PATCH] Fix a lock problem in generic phy code
Date: Fri, 31 Aug 2007 18:29:15 +0200
Message-ID: <200708311829.15568.hjk@linutronix.de>
References: <200708311430.09590.hjk@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	afleming@freescale.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:34030 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756144AbXHaQ3S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 12:29:18 -0400
In-Reply-To: <200708311430.09590.hjk@linutronix.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag 31 August 2007 schrieb Hans-J=FCrgen Koch:
> Lock debugging finds a problem in phy.c and phy_device.c,
> this patch fixes it. Tested on an AT91SAM9263-EK board,
> kernel 2.6.23-rc4.

=46YI, here's the log message without that patch:

[    3.420000] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    3.420000] [ INFO: inconsistent lock state ]
[    3.420000] 2.6.23-rc3-mm1 #21
[    3.420000] ---------------------------------
[    3.420000] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
[    3.420000] swapper/1 [HC0[0]:SC1[1]:HE1:SE0] takes:
[    3.420000]  (&dev->lock){-+..}, at: [<c017da1c>] phy_timer+0x1c/0x4=
c8
[    3.420000] {softirq-on-W} state was registered at:
[    3.420000]   [<c006021c>] lock_acquire+0x94/0xac
[    3.420000]   [<c026423c>] _spin_lock+0x40/0x50
[    3.420000]   [<c017e2b4>] phy_probe+0x40/0x88
[    3.420000]   [<c017e60c>] phy_attach+0xc8/0xfc
[    3.420000]   [<c017e6c4>] phy_connect+0x1c/0x58
[    3.420000]   [<c017fc44>] macb_probe+0x4fc/0x5bc
[    3.420000]   [<c0177b44>] platform_drv_probe+0x20/0x24
[    3.420000]   [<c0176210>] driver_probe_device+0xb0/0x1bc
[    3.420000]   [<c01764dc>] __driver_attach+0xe4/0xe8
[    3.420000]   [<c017550c>] bus_for_each_dev+0x54/0x80
[    3.420000]   [<c0176074>] driver_attach+0x20/0x28
[    3.420000]   [<c01758d4>] bus_add_driver+0x84/0x1e0
[    3.420000]   [<c0176708>] driver_register+0x54/0x90
[    3.420000]   [<c0177de0>] platform_driver_register+0x6c/0x88
[    3.420000]   [<c00167ec>] macb_init+0x14/0x1c
[    3.420000]   [<c00087e4>] kernel_init+0x9c/0x2b4
[    3.420000]   [<c0040338>] do_exit+0x0/0x8e8
[    3.420000] irq event stamp: 115025
[    3.420000] hardirqs last  enabled at (115025): [<c0264958>] _spin_u=
nlock_irq+0x30/0x60
[    3.420000] hardirqs last disabled at (115024): [<c02642c8>] _spin_l=
ock_irq+0x28/0x60
[    3.420000] softirqs last  enabled at (114999): [<c0042910>] __do_so=
ftirq+0xfc/0x12c
[    3.420000] softirqs last disabled at (115022): [<c0042ee8>] irq_exi=
t+0x68/0x7c
[    3.420000]
[    3.420000] other info that might help us debug this:
[    3.420000] no locks held by swapper/1.
[    3.420000]
[    3.420000] stack backtrace:
[    3.420000] [<c0028af4>] (dump_stack+0x0/0x14) from [<c005d8e4>] (pr=
int_usage_bug+0x120/0x150)
[    3.420000] [<c005d7c4>] (print_usage_bug+0x0/0x150) from [<c005e5e8=
>] (mark_lock+0x574/0x6bc)
[    3.420000] [<c005e074>] (mark_lock+0x0/0x6bc) from [<c005f4c0>] (__=
lock_acquire+0x4d0/0x1198)
[    3.420000] [<c005eff0>] (__lock_acquire+0x0/0x1198) from [<c006021c=
>] (lock_acquire+0x94/0xac)
[    3.420000] [<c0060188>] (lock_acquire+0x0/0xac) from [<c026423c>] (=
_spin_lock+0x40/0x50)
[    3.420000] [<c02641fc>] (_spin_lock+0x0/0x50) from [<c017da1c>] (ph=
y_timer+0x1c/0x4c8)
[    3.420000]  r5:c098a800 r4:00000104
[    3.420000] [<c017da00>] (phy_timer+0x0/0x4c8) from [<c0046ee4>] (ru=
n_timer_softirq+0x1a0/0x218)
[    3.420000]  r7:c081ddd0 r6:c0331e80 r5:c098aa50 r4:00000104
[    3.420000] [<c0046d44>] (run_timer_softirq+0x0/0x218) from [<c00428=
a8>] (__do_softirq+0x94/0x12c)
[    3.420000] [<c0042814>] (__do_softirq+0x0/0x12c) from [<c0042ee8>] =
(irq_exit+0x68/0x7c)
[    3.420000] [<c0042e80>] (irq_exit+0x0/0x7c) from [<c0023060>] (__ex=
ception_text_start+0x60/0x74)
[    3.420000]  r4:00000001
[    3.420000] [<c0023000>] (__exception_text_start+0x0/0x74) from [<c0=
023b28>] (__irq_svc+0x48/0x74)
[    3.420000] Exception stack(0xc081de70 to 0xc081deb8)
[    3.420000] de60:                                     c030b2a8 c081a=
800 60000013 c081c000
[    3.420000] de80: c032db40 c081dee0 c032d758 c081dece 00000012 c030b=
398 00000034 c081df2c
[    3.420000] dea0: c081deb8 c081deb8 c003d6f0 c003d6f8 60000013 fffff=
fff
[    3.420000]  r7:00000003 r6:00000001 r5:fefff000 r4:ffffffff
[    3.420000] [<c003d494>] (vprintk+0x0/0x474) from [<c003d930>] (prin=
tk+0x28/0x30)
[    3.420000] [<c003d908>] (printk+0x0/0x30) from [<c01d3558>] (sock_r=
egister+0x64/0x84)
[    3.420000]  r3:00000001 r2:00000002 r1:00000001 r0:c02e4c88
[    3.420000] [<c01d34f4>] (sock_register+0x0/0x84) from [<c001b7bc>] =
(af_unix_init+0x40/0x88)
[    3.420000]  r5:00000000 r4:00000000
[    3.420000] [<c001b77c>] (af_unix_init+0x0/0x88) from [<c00087e4>] (=
kernel_init+0x9c/0x2b4)
[    3.420000]  r4:00000000
[    3.420000] [<c0008748>] (kernel_init+0x0/0x2b4) from [<c0040338>] (=
do_exit+0x0/0x8e8)
