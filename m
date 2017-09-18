From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 18 Sep 2017 13:46:52 +0200
Message-ID: <20170918114652.GA13349@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:52639 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdIRLrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 07:47:12 -0400
Received: by mail-lf0-f54.google.com with SMTP id b127so241342lfe.9
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 04:47:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170918080214.yrejz67wwnp2pjzf@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 18, 2017 at 10:02:14AM +0200, Richard Cochran wrote:
> On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
> >  * Time-aware shaper (802.1Qbv):
>=20
> I just posted a working alternative showing how to handle 802.1Qbv and
> many other Ethernet field buses.

Yes, I saw them, grabbing them for testing now - thanks!

> >    The idea we are currently exploring is to add a "time-aware", priori=
ty based
> >    qdisc, that also exposes the Tx queues available and provides a mech=
anism for
> >    mapping priority <-> traffic class <-> Tx queues in a similar fashio=
n as
> >    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line wo=
uld be:
> >=20
> >    $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
> >      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
> > 	   queues 0 1 2 3                                              \
> >      	   sched-file gates.sched [base-time <interval>]               \
> >            [cycle-time <interval>] [extension-time <interval>]
> >=20
> >    <file> is multi-line, with each line being of the following format:
> >    <cmd> <gate mask> <interval in nanoseconds>
> >=20
> >    Qbv only defines one <cmd>: "S" for 'SetGates'
> >=20
> >    For example:
> >=20
> >    S 0x01 300
> >    S 0x03 500
> >=20
> >    This means that there are two intervals, the first will have the gate
> >    for traffic class 0 open for 300 nanoseconds, the second will have
> >    both traffic classes open for 500 nanoseconds.
>=20
> The idea of the schedule file will not work in practice.  Consider the
> fact that the application wants to deliver time critical data in a
> particular slot.  How can it find out a) what the time slots are and
> b) when the next slot is scheduled?  With this Qdisc, it cannot do
> this, AFAICT.  The admin might delete the file after configuring the
> Qdisc!
>=20
> Using the SO_TXTIME option, the application has total control over the
> scheduling.  The great advantages of this approach is that we can
> support any possible combination of periodic or aperiodic scheduling
> and we can support any priority scheme user space dreams up.

Using SO_TXTIME makes a lot of sense. TSN has a presentation_time, which=20
you can use to deduce the time it should be transmitted (Class A has a 2ms=
=20
latency guarantee, B has 50), but given how TSN uses the timestamp, it will=
=20
wrap every 4.3 seconds, using SO_TXTIME allows you to schedule transmission=
=20
at a much later time. It should also lessen the dependency on a specific=20
protocol, which is also good.

> For example, one can imaging running two or more loops that only
> occasionally collide.  When they do collide, which packet should be
> sent first?  Just let user space decide.

If 2 userspace apps send to the same Tx-queue with the same priority, would=
=20
it not make sense to just do FIFO? For all practical purposes, they have=20
the same importance (same SO_PRIORITY, same SO_TXTIME). If the priority=20
differs, then they would be directed to different queues, where one queue=
=20
will take presedence anyway.

How far into the future would it make sense to schedule packets anyway?

I'll have a look at the other series you just posted!

--=20
Henrik Austad

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlm/siwACgkQ6k5VT6v45llpIwCfVgyBAuQjlk52t9FYUSYbqJA3
l88AoKVe7Av3LcKgPoRrZCs7L/wuRAew
=ulaE
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
