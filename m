From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Tue, 19 Sep 2017 15:14:43 +0200
Message-ID: <20170919131443.GA28667@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost>
 <87k20vip3f.fsf@intel.com>
 <20170919052244.77umdxuze53t6j22@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:55274 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdISNPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 09:15:03 -0400
Received: by mail-lf0-f52.google.com with SMTP id k23so3631575lfi.11
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 06:15:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170919052244.77umdxuze53t6j22@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, Sep 19, 2017 at 07:22:44AM +0200, Richard Cochran wrote:
> On Mon, Sep 18, 2017 at 04:06:28PM -0700, Vinicius Costa Gomes wrote:
> > That's the point, the application does not need to know that, and asking
> > that would be stupid.
>=20
> On the contrary, this information is essential to the application.
> Probably you have never seen an actual Ethernet field bus in
> operation?  In any case, you are missing the point.
>=20
> > (And that's another nice point of how 802.1Qbv works, applications do
> > not need to be changed to use it, and I think we should work to achieve
> > this on the Linux side)
>=20
> Once you start to care about real time performance, then you need to
> consider the applications.  This is industrial control, not streaming
> your tunes from your ipod.

Do not underestimate the need for media over TSN. I fully see your point of=
=20
real-time systems, but they are not the only valid use-cases for TSN.

> > That being said, that only works for kinds of traffic that maps well to
> > this configuration in advance model, which is the model that the IEEE
> > (see 802.1Qcc) and the AVNU Alliance[1] are pushing for.
>=20
> Again, you are missing the point of what they aiming for.  I have
> looked at a number of production systems, and in each case the
> developers want total control over the transmission, in order to
> reduce latency to an absolute minimum.  Typically the data to be sent
> are available only microseconds before the transmission deadline.
>=20
> Consider OpenAVB on github that people are already using.  Take a look
> at simple_talker.c and explain how "applications do not need to be
> changed to use it."

I do not think simple-talker was everintended to be how users of AVB should=
=20
be implemented, but as a demonstration of what the protocol could do.

ALSA/V4L2 should supply some interface to this so that you can attach=20
media-applications to it without the application itself having to be "TSN=
=20
aware".

> > [1]
> > http://avnu.org/theory-of-operation-for-tsn-enabled-industrial-systems/
>=20
> Did you even read this?
>=20
>     [page 24]
>=20
>     As described in section 2, some industrial control systems require
>     predictable, very low latency and cycle-to-cycle variation to meet
>     hard real-time application requirements. In these systems,
>     multiple distributed controllers commonly synchronize their
>     sensor/actuator operations with other controllers by scheduling
>     these operations in time, typically using a repeating control
>     cycle.
>     ...
>     The gate control mechanism is itself a time-aware PTP application
>     operating within a bridge or end station port.
>=20
> It is an application, not a "god box."
>
> > In short, I see a per-packet transmission time and a per-queue schedule
> > as solutions to different problems.
>=20
> Well, I can agree with that.  For some non real-time applications,
> bandwidth shaping is enough, and your Qdisc idea is sufficient.  For
> the really challenging TSN targets (industrial control, automotive),
> your idea of an opaque schedule file won't fly.

Would it make sense to adapt the proposed Qdisc here as well as the=20
back-o-the-napkin idea in the other thread to to a per-socket queue for=20
each priority and then sort those sockets based on SO_TXTIME?

TSN operates on a per-StreamID basis, and that should map fairly well to a=
=20
per-socket approach I think (let us just assume that an application that=20
sends TSN traffic will open up a separate socket for each stream.

This should allow a userspace application that is _very_ aware of its=20
timing constraints to send frames exactly when it needs to as you have=20
SO_TXTIME available. It would also let applications that basically want a=
=20
fine-grained rate control (audio and video comes to mind) to use the same=
=20
qdisc.

For those sockets that do not support SO_TXTIME, but still map to a=20
priority handled by sch_cbs (or whatever it'll end up being called) you can=
=20
set the transmit-time to be the time of the last skb in the queue + an=20
delta which will give you the correct rate (TSN operates on observation=20
intervals which you can specify via tc when you create the queues).

Then you can have, as you propose in your other series, a hrtimer that is=
=20
being called when the next SO_TXTIME enters, grab a skb and move it to the=
=20
hw-queue. This should also allow you to keep a sorted per-socket queue=20
should an application send frames in the wrong order, without having to=20
rearrange descriptors for the DMA machinery.

If this makes sense, I am more than happy to give it a stab and see how it=
=20
goes.

-Henrik

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnBGEMACgkQ6k5VT6v45llROwCgvQliZHqpLrPBzSm8iG0kLURY
7B4AoJjMJ/ZbLOFEFNktHllmdteUKLEH
=W0tW
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--
