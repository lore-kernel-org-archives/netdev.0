From: David Miller <davem@davemloft.net>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet
 receive)
Date: Wed, 09 May 2007 00:03:39 -0700 (PDT)
Message-ID: <20070509.000339.93384349.davem@davemloft.net>
References: <20070427031757.513f6ad7.billfink@mindspring.com>
	<Pine.LNX.4.64.0704271122230.28337@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705071310210.20970@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, akpm@osdl.org, jeff@garzik.org,
	billfink@mindspring.com, cebbert@redhat.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S969448AbXEIHDi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 03:03:38 -0400
In-Reply-To: <Pine.LNX.4.64.0705071310210.20970@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 7 May 2007 14:45:53 +0300 (EEST)

> I found out this shows up when 900fd17dd01d2c99dfd1ec0b53a860894a2673=
ee is=20
> included, kernels before that seem to work fine. The problem descript=
ion=20
> is in this same thread. I'm not going to repeat it here as it is vali=
d=20
> except for the fact that my original claim that it happens with anoth=
er=20
> hardware is false, please see it in here:
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D117758295411277&w=3D2
>=20
> Should these delays I see be considered as evindence of mmio not work=
ing=20
> with this card/model or could there be something else wrong somewhere=
?=20
> ...I can just disable it using global_use_mmio parameter, which remov=
es=20
> the problem in 2.6.20.7 (tested) but just in case somebody has more c=
lue=20
> than I do about this, I'm willing to do more testing...

One thing that MMIO changes a lot is timing.

The port I/O instructions on x86 have fixed timings so take the same
amount of time to execute regardless of the underlying bus
capabilities.

This could have been masking some issue in the driver or the hardware.

Port I/O also does not have any write posting issues like MMIO does.

In my opinion it can only cause trouble to start using MMIO on such
old chips when we've been using port I/O to access them for 5+ years.
:-)

Wait, it's timing, I see the bug.  There was a similar problem like
this in the Linux floppy driver some 6 years ago.

Look at issue_and_wait(), how it polls:

	iowrite16(cmd, ioaddr + EL3_CMD);
	for (i =3D 0; i < 2000; i++) {
		if (!(ioread16(ioaddr + EL3_STATUS) & CmdInProgress))
			return;
	}

That takes longer to run with port I/O than MMIO.  So I bet it
breaks out of the loop faster with MMIO and thus can trigger
this thing:

	/* OK, that didn't work.  Do it the slow way.  One second */
	for (i =3D 0; i < 100000; i++) {
		if (!(ioread16(ioaddr + EL3_STATUS) & CmdInProgress)) {
			if (vortex_debug > 1)
				printk(KERN_INFO "%s: command 0x%04x took %d usecs\n",
					   dev->name, cmd, i * 10);
			return;
		}
		udelay(10);
	}

and that's where your delays are coming from.

I would suggest adding some kind of (very small) fixed delay to the
first loop.

The rest of the driver should be audited for this kind of problem.

