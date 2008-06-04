From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Wed, 4 Jun 2008 09:23:11 +0200
Message-ID: <20080604072311.GA32491@elte.hu>
References: <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu> <20080531060947.GA26441@elte.hu> <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi> <20080531125428.GA22111@elte.hu> <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi> <20080531163501.GB22607@elte.hu> <20080603094057.GA29480@elte.hu> <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Patrick McManus <mcmanus@ducksong.com>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:36883 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbYFDHXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 03:23:39 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> > > i'll queue up your reverts for testing in -tip.
> >=20
> > update: your 3 reverts in tip/out-of-tree [commit dad98991c] defini=
tely=20
> > fixed the hangs!
>=20
> ...It wasn't exactly out-of-tree, Evgeniy fixed a problem that was=20
> found in "TCP_DEFER_ACCEPT updates - process as established", perhaps=
=20
> it just wasn't in your testing tree yet.

out of the -tip tree :-) The -tip tree has 75+ topic branches at the=20
moment, but TCP topics are not in its scope - so any TCP change is "out=
=20
of tree" for the -tip tree.

People got confused in the past when they saw similar test patches show=
=20
up in sched.git and x86.git before, so we wanted to make it very clear=20
in -tip (with is the successor of sched.git, x86.git and a couple of=20
other git trees) that these are commits we dont want to push anywhere.=20

Commits in tip/out-of-tree dont get propagated into the tip/auto-*-next=
=20
topic branches that linux-next and -mm picks up, they are purely a=20
courtesy to help the testing/fixing of bugs in subsystems that are=20
maintained in other git trees.

See attached below the current shortlog of the tip/out-of-tree topic=20
branch - it contains changes all around the tree for various things tha=
t=20
we triggered in -tip and are not yet upstream or are in flight somewher=
e=20
in another git tree.

> > Here is the testing i did:
> >=20
> > first i ran about 500+ successful iterations on the affected=20
> > testboxes with your revert patch applied, on multiple systems.
>=20
> Are you sure this is enough to conclude the results? Seems quite smal=
l=20
> number to me to rule out luck. Especially considering that it was som=
e=20
> amount of time in the tree already until you noticed it for the first=
=20
> time.

a full day of testing on a testsystem with 500 random kernel builds and=
=20
bootups (the kernel build done on the testsystem utilizing distcc and=20
make -j100, so it's rather heavy and parallel TCP traffic per iteration=
)=20
with no hang, compared to the same system with your reverts not applied=
=20
that hung after an hour with 20-30 iterations.

And that count increased to 1000 successful test iterations since=20
yesterday.

So i think yes, it seems rather conclusive, given the circumstances ;-)=
=20

These random kernel boots found many 'impossible to trigger' bugs and=20
races in the past. The reason for its race finding capability is the=20
timing randomness of the resulting random kernel image: the delays=20
caused by random combination of debugging facilities, build variants,=20
kernel subsystem variants we have. This -tip qa method - as a=20
side-effect of its coverage testing - simulates timing variantions that=
=20
are otherwise only observable via hardware variations.

I.e. this is not the same kernel booted up a 1000 times - that would be=
=20
a very narrow test. This is 1000 _different_ kernels built and booted=20
up. Each kernel having subtly different timings and ordering. And it's=20
more than just externally injected random kernel: the test-system itsel=
f=20
builds its "next version" (and uses the network for that as well), so=20
it's a self-hosting recursive random test in essence.

This method is also amazingly good at finding compiler/linker trouble:=20
it found 3-4 real gcc bugs so far. (For example i triggered an ancient=20
bug in gcc 4.0.2 just yesterday. For the record, the testsystem with th=
e=20
TCP hang utilizes gcc-4.2.2.)

> > so i hereby conclude that your revert works :) I've repeated the=20
> > commit below that resolves this nasty regression.
>=20
> ...I couldn't immediately find anything obviously wrong with those=20
> changes but the patch below might be worth of a try (without the=20
> revert of course). If it ever spits out that WARN_ON for you, we were=
=20
> playing with fire too much and it's better to return on the safe side=
=20
> there...

i'll queue it up for testing, but no promises about speedy action here =
-=20
the test cycle is really long with this bug.

	Ingo

------{ tip/out-of-tree shortlog: }----------->

Alexander van Heukelum (1):
      uml: cleanup: use def_bool in Kconfig files

Bjorn Helgaas (1):
      PNPACPI: use _CRS IRQ descriptor length for _SRS

Ilpo J=E4rvinen (1):
      tcp: revert DEFER_ACCEPT modifications

Ingo Molnar (7):
      video/dvb: fix MEDIA_TUNER && FW_LOADER build error
      dvb: input layer dependencies fixes
      drivers/media/video build fix for modular builds
      drivers/watchdog/geodewdt.c: build fix
      USB: fix build bug in USB_ISIGHTFW
      acpi-acpi_numa_init-build-fix
      acpi: fix drivers/acpi/glue.c build error

Michael Krufky (1):
      dib7000p: fix dib7000p_attach when !CONFIG_DVB_DIB7000P

Russ Anderson (1):
      acpi: fix boot breakage on Altix

Yinghai Lu (2):
      net: use numa_node in net_devcice->dev instead of parent
      ide: use dev_to_node instead of pcibus_to_node

