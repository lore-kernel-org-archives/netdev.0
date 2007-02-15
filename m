From: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Subject: [BUG?/SCHED] netem and tbf seem to busy wait with some clock sources
Date: Thu, 15 Feb 2007 16:40:07 +0100
Message-ID: <20070215154007.GB25685@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vds456.sivit.org ([80.248.208.235]:58828 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966037AbXBOQSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 11:18:21 -0500
Received: from lucas by xanadu.blop.info with local (Exim 4.63)
	(envelope-from <lucas.nussbaum@imag.fr>)
	id 1HHiiN-0006tO-94
	for netdev@vger.kernel.org; Thu, 15 Feb 2007 16:40:07 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

While experimenting with netem and tbf, I ran into some strange results.

Experimental setup:
tc qdisc add dev eth2 root netem delay 10ms
Linux 2.6.20-rc6 ; HZ=3D250

I measured the latency using a modified "ping" implementation, to allow
for high frequency measurement (one measure every 0.1ms). I compared the
results using different clock sources.

See http://www-id.imag.fr/~nussbaum/sched/clk-latency.png

The results with CLK_JIFFIES are the ones I expected: one clearly sees
the influence of HZ, with latency varying around 10ms +/- (1/2)*(1000/HZ).

On the other hand, the results with CLK_GETTIMEOFDAY or CLK_CPU don't
seem to be bound to the HZ setting. Looking at the source, I suspect
that netem is actually sort of busy-waiting, by re-setting the timer to
the old value.

I instrumented netem_dequeue to confirm this (see [1]), and
PSCHED_US2JIFFIE(delay)) returns 0, causing the timer to be rescheduled
at the same jiffie. I could see netem_dequeue being called up to 150
times during a jiffie (at HZ=3D250).

So, my question is: Is this the expected behaviour ? Wouldn't it be
better to set the timer to jiffies + 1 if the delay is 0 ? Or to send
the packet immediately if the delay is 0, instead of waiting ?

I got similar results with tbf (frames being spaced "too well", instead
of bursting).

[1] http://www-id.imag.fr/~nussbaum/sched/netem_dequeue.diff

Thank you,
--=20
| Lucas Nussbaum                        PhD student |
| lucas.nussbaum@imag.fr        LIG / Projet MESCAL |
| jabber: lucas@nussbaum.fr    +33 (0)6 64 71 41 65 |
| homepage:        http://www-id.imag.fr/~nussbaum/ |

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFF1H7X2hliNwI7P08RApLBAKCQpxuYN9wrKJTIsXc8KRvqjlbXAACdEoBc
/PVEfd9CiBB27WJwzOLh5b8=
=z8aK
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
