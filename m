From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000e driver - hang after 4 hours of uptime - finally bisected!
Date: Thu, 18 Jun 2015 15:34:23 -0700
Message-ID: <1434666863.3530.74.camel@intel.com>
References: <5284.1434646014@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vzdTLYjqfgQxVXoFod29"
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58154 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788AbbFRWeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 18:34:24 -0400
In-Reply-To: <5284.1434646014@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vzdTLYjqfgQxVXoFod29
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-18 at 12:46 -0400, Valdis Kletnieks wrote:
> (follow up to a report from last week - bisecting took a while as I could
> only do 1 or 2 tests an evening)
>=20
> My Dell Latitude E6530 crashes with a specific kernel lockup almost
> exactly 4 hours after boot if there isn't a cable connected to the
> Ethernet port:
>=20
> [14508.846327] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 0
> [14468.229720] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 0
> [14463.254791] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 0
> [14491.134413] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 1
> [14463.396593] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 2
> [14490.390223] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 1
> [14494.680591] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 0
> [14513.365378] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 1
> [14482.271716] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 3
> [14479.906820] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 0
>=20
> As far as I can tell, the timestamp jitter is just how long it takes me t=
o
> enter the cryptLUKS passphrase for the hard drive at boot...
>=20
> lspci tells me:
>=20
> lspci -vvv -s "00:19.0"
> 00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Co=
nnection (rev 04)
>         DeviceName:  Onboard LAN
>         Subsystem: Dell Device 0535
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 28
>         Region 0: Memory at f7700000 (32-bit, non-prefetchable) [size=3D1=
28K]
>         Region 1: Memory at f7739000 (32-bit, non-prefetchable) [size=3D4=
K]
>         Region 2: I/O ports at f040 [size=3D32]
>         Capabilities: [c8] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,=
D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME=
-
>         Capabilities: [d0] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
>                 Address: 00000000fee00318  Data: 0000
>         Capabilities: [e0] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: e1000e
>=20
>=20
> The traceback always looks like:
>=20
> [14479.906820] Kernel panic - not syncing: Watchdog detected hard LOCKUP =
on cpu 0
>=20
> [14479.906908] Call Trace:
> [14479.906914]  <NMI>  [<ffffffffba94db16>] dump_stack+0x50/0xa8
> [14479.906930]  [<ffffffffba948bb9>] panic+0xcd/0x1e4
> [14479.906940]  [<ffffffffba166a60>] ? perf_event_task_disable+0xc0/0xc0
> [14479.906952]  [<ffffffffba125d8b>] watchdog_overflow_callback+0x9b/0xa0
> [14479.906959]  [<ffffffffba16a684>] __perf_event_overflow+0xc4/0x1f0
> [14479.906968]  [<ffffffffba16b3a4>] perf_event_overflow+0x14/0x20
> [14479.906976]  [<ffffffffba022271>] intel_pmu_handle_irq+0x1e1/0x430
> [14479.906990]  [<ffffffffba01a0f6>] perf_event_nmi_handler+0x26/0x40
> [14479.906999]  [<ffffffffba0085b3>] nmi_handle+0x103/0x340
> [14479.907005]  [<ffffffffba0084b5>] ? nmi_handle+0x5/0x340
> [14479.907017]  [<ffffffffba008a53>] default_do_nmi+0xc3/0x120
> [14479.907032]  [<ffffffffba008b98>] do_nmi+0xe8/0x130
> [14479.907044]  [<ffffffffba95c9a8>] end_repeat_nmi+0x1e/0x2e
> [14479.907055]  [<ffffffffba529886>] ? e1000e_cyclecounter_read+0x16/0xc0
> [14479.907061]  [<ffffffffba529886>] ? e1000e_cyclecounter_read+0x16/0xc0
> [14479.907069]  [<ffffffffba529886>] ? e1000e_cyclecounter_read+0x16/0xc0
> [14479.907075]  <<EOE>>  [<ffffffffba0e9529>] timecounter_read+0x19/0x60
> [14479.907088]  [<ffffffffba53687e>] e1000e_phc_gettime+0x2e/0x60
> [14479.907098]  [<ffffffffba536a31>] e1000e_systim_overflow_work+0x31/0x7=
0
> [14479.907105]  [<ffffffffba07ad19>] process_one_work+0x3c9/0x980
> [14479.907115]  [<ffffffffba07ac62>] ? process_one_work+0x312/0x980
> [14479.907125]  [<ffffffffba07b348>] ? worker_thread+0x78/0x760
> [14479.907134]  [<ffffffffba07b59c>] worker_thread+0x2cc/0x760
> [14479.907144]  [<ffffffffba07b2d0>] ? process_one_work+0x980/0x980
> [14479.907154]  [<ffffffffba082a5e>] kthread+0xfe/0x120
> [14479.907163]  [<ffffffffba08ca50>] ? finish_task_switch+0x50/0x1c0
> [14479.907173]  [<ffffffffba082960>] ? kthread_create_on_node+0x270/0x270
> [14479.907179]  [<ffffffffba95ae4f>] ret_from_fork+0x3f/0x70
> [14479.907188]  [<ffffffffba082960>] ? kthread_create_on_node+0x270/0x270
> [14479.907243] Kernel Offset: 0x39000000 from 0xffffffff81000000 (relocat=
ion range: 0xffffffff80000000-0xffffffffbfffffff)
>=20
> Bisection tells me it's this commit:
>=20
> commit 83129b37ef35bb6a7f01c060129736a8db5d31c4
> Author: Yanir Lubetkin <yanirx.lubetkin@intel.com>
> Date:   Tue Jun 2 17:05:45 2015 +0300
>=20
>     e1000e: fix systim issues
>=20
>     Two issues involving systim were reported.
>     1. Clock is not running in the correct frequency
>     2. In some situations, systim values were not incremented linearly
>     This patch fixes the hardware clock configuration and the spurious
>     non-linear increment.

Thanks Valdis!  I will have Yanir look into it and hopefully we should
have a fix here soon for you to verify.

--=-vzdTLYjqfgQxVXoFod29
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVg0dvAAoJEOVv75VaS+3OdjwQAKYdluBvxhvN8t5aBg2/LMw3
6FOdsBD6f6PR4t9RmEziShM4Qs23ZhFgKcSjOX2lNvMcq+qBW4ZH4l6L1g7oGfSo
7oP/2LqSem2rHmjwwLHSXAvP/jZs/jkvNYehmG3D7Lwe9+CtFXE3j7lqr9uZhlJL
byeDyD7nESbMJvZGasvHcgE9JJosApQSUExTkWINTkEj2xMdyqErkH6KyMGIYB6B
wcbsILPrWRK9F9K4tgOGwztYfITO7eropxZt+Kuz6DRXOamJW/Fa+X0hguQRJBLi
t7V60NtMK+MLlGWE80z+DjSVAPnj4x+Xl7CCDCvU2x/1rho0ZqQGB0X4XeK3exOz
0XrMxBeogh87ftWlrTa8Sbe2RA/M7Rk6VUW5OEsATdOHhOgvUz4iqhHBSGDcdNU5
MeMTgmzyQ5R6G/RDkRKp2thCgElLlvx9MzRObN2LhOQfn5F1QKV9suginlhb1ZnJ
47oEidy/h0KKrxF/aeeJTd/iwWsmjs+hwvI82npyWOT09aL2x0f4q+gHkWr3D73r
Pdb6aCxKEzLeG5KwmW4rppSLsNsKMz8VwH2/SAMIpLB6xVUVvx4DBUfY713pV7Jp
JcqC8aKkDepltTvhsoNd6YCiLCqFa6y4nmhCb4UaQMHqOlAgpEbskDvYiItsxWqy
eQfpzCRmaXPWNnIEGxJm
=wWMM
-----END PGP SIGNATURE-----

--=-vzdTLYjqfgQxVXoFod29--
