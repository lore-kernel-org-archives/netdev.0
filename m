From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Mon, 12 Mar 2007 19:11:20 +0000
Message-ID: <20070312191120.GA3085@sirena.org.uk>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk> <45F5502C.1000905@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:2393 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbXCLTLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 15:11:47 -0400
Content-Disposition: inline
In-Reply-To: <45F5502C.1000905@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 12, 2007 at 04:05:48PM +0300, Sergei Shtylyov wrote:
> Mark Brown wrote:

> >hands_off is stronger than that - it's used for sync with some of the
> >other code paths like suspend/resume and means "don't touch the chip".
> >I've added a new driver local flag instead.

>    I'm not sure it was worth it -- we already had __LINK_STATE_RX_SCHED...

It would be nice but as well as being a general layering violation it
could cause problems when trying to quiesce the hardware since
netif_poll_disable() sets this without actually scheduling the poll.

> >>  Yeah, it seems currently unjustified.  However IntrEnable would have=
=20
> >>  been an ultimate criterion on taking or ignoring an interrupt=20
> >>  otherwise...

>>>I guess the tradeoff depends on the probability
>>>of getting the isr called when NAPI is active for the device.

>    I mean I didn't understand why there's tradeoff and how it depends on=
=20
>    the probability...

Reading device registers means going over the PCI bus, which is
expensive.  Shadowing the interrupt mask state in the driver makes
the driver more complicated but means that we avoid synchronous PCI
accesses, reducing the number of cycles the CPU spends stalled doing
those.

The performance benefit from the extra code complexity depends on how
often we end up doing the extra read.  Since one of the things NAPI does
is provide some interrupt mitigation the extra work is most likely to be
noticable if some other device is generating interrupts that trigger the
natsemi interrupt handler.

> >Moving netdev_rx() would fix that one but there's some others too -
> >there's one in the timer routine if the chip crashes.  In the case you

>    Erm, sorry, I'm not seeing it -- could you "point with finger" please?=
=20
>    :-)

In netdev_timer() when the device is using PORT_TP if the DspCfg read
back from the chip differs from the one we think we programmed into it
then the driver thinks the PHY fell over.  It then goes through an init
sequence, including init_registers() which will reset IntrEnable among
other things.

> >describe above the consequences shouldn't be too bad since it tends to
> >only occur at high volume so further traffic will tend to occur and
> >cause things to recover - all the testing of that patch was done with
> >the bug present and no ill effects.

>    Oversized packets occur only at high volume? Is it some errata?

It's an errata - AN 1287 which you can get from the National web site.
It's not actually that chip that's getting oversided packets, what
happens is that the state machine which reads data off the wire gets
confused and eventually locks up.  Before locking up it will usually
report one or more oversided packets so this is a useful hint that we
should reset the recieve state machine in order to recover from this.

>    (If I only knew somebody else was working on that issue, it could have=
=20
> saved my cycles, sigh... but well, I should have said  that I was going t=
o=20
> recast the patch. :-)

Yeah, me too.  I'll submit this one once I've finished testing, then
audit other IntrStatus accesses.

> >-		       readl(ioaddr + IntrMask));
> >+	spin_lock_irqsave(&np->intr_lock, flags);

>    Yeah, I've suspected that we need to grab np->lock here... but does th=
at=20
> separate spinlock actually protect us from anything?

=2E..

> >+	/* We need to ensure that the ISR doesn't run between telling
> >+	 * NAPI we're done and enabling the interrupt. */
>=20
>    Why? :-O

This is to ensure that the interrupt handler can't run between us
marking that the poll has complete and reenabling the interrupt from the
chip.  That would mean that the chip would end up with interrupts from
the chip enabled while the poll is scheduled.

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRfWl1Q2erOLNe+68AQLAJQP+L2eXlujx1LdouCg68iMMQo7BGyP3eE0z
U6VhZ8sz/je6sq3oXpcygCz5acE1M/G/+B3063UFUtI9t9ppnEJBAIpHtdSfMWAw
si9ALI+M6E+xcWR1sirguka6RHEhgw98uQcb85UVgvPsCH9uVoy8PgvhGuhr7kM8
STc2EY/iU/M=
=0cBW
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
