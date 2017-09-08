From: Henrik Austad <henrik@austad.us>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Fri, 8 Sep 2017 08:06:23 +0200
Message-ID: <20170908060623.GC9064@sisyphus.home.austad.us>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170907053411.GA6580@sisyphus.home.austad.us>
 <1504814332.2117.3.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="lCAWRPmW1mITcIfM"
Cc: "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "Sanchez-Palencia, Jesus" <jesus.sanchez-palencia@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Guedes, Andre" <andre.guedes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:32839 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbdIHGGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 02:06:49 -0400
Received: by mail-lf0-f47.google.com with SMTP id c80so3443929lfh.0
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 23:06:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504814332.2117.3.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lCAWRPmW1mITcIfM
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 07, 2017 at 07:58:53PM +0000, Guedes, Andre wrote:
> Hi Henrik,
>=20
> Thanks for your feedback! I'll address some of your comments below.
>=20
> On Thu, 2017-09-07 at 07:34 +0200, Henrik Austad wrote:
> > > As for the shapers config interface:
> > >=20
> > > =A0* CBS (802.1Qav)
> > >=20
> > > =A0=A0=A0This patchset is proposing a new qdisc called 'cbs'. Its 'tc=
' cmd line
> > > is:
> > > =A0=A0=A0$ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M=
 sendslope S
> > > \
> > > =A0=A0=A0=A0=A0idleslope I
> >=20
> > So this confuses me a bit, why specify sendSlope?
> >=20
> > =A0=A0=A0=A0sendSlope =3D portTransmitRate - idleSlope
> >=20
> > and portTransmitRate is the speed of the MAC (which you get from the=A0
> > driver). Adding sendSlope here is just redundant I think.
>=20
> Yes, this was something we've spent quite a few time discussing before th=
is RFC
> series. After reading the Annex L from 802.1Q-2014 (operation of CBS algo=
rithm)
> so many times, we've came up with the rationale explained below.
>=20
> The rationale here is that sendSlope is just another parameter from CBS
> algorithm like idleSlope, hiCredit and loCredit. As such,=A0its calculati=
on
> should be done at the same "layer" as the others parameters (in this case=
, user
> space) in order to keep consistency. Moreover, in this design, the driver=
 layer
> is dead simple: all the device driver=A0has to do is applying CBS paramet=
ers to
> hardware. Having any CBS parameter calculation in the driver layer means =
all
> device drivers must implement that calculation.

Ok, that actually makes a lot of sense, and anything that keeps this kind=
=20
of arithmetic outside the kernel is a good thing!

Thanks for the clarification!

> > Also, does this mean that when you create the qdisc, you have locked th=
e=A0
> > bandwidth for the scheduler? Meaning, if I later want to add another=A0
> > stream that requires more bandwidth, I have to close all active streams=
,=A0
> > reconfigure the qdisc and then restart?
>=20
> If we want to reserve more bandwidth to "accommodate" a new stream, we do=
n't
> need to close all active streams. All we have to do is changing the CBS q=
disc
> and pass the new CBS parameters. Here is what the command-line would look=
 like:
>=20
> $ tc qdisc change dev enp0s4 parent 8001:5 cbs locredit -1470 hicredit 30
> sendslope -980000 idleslope 20000
>=20
> No application/stream is interrupted while new CBS parameters are applied.

Ah, good.

> > > =A0=A0=A0Note that the parameters for this qdisc are the ones defined=
 by the
> > > =A0=A0=A0802.1Q-2014 spec, so no hardware specific functionality is e=
xposed here.
> >=20
> > You do need to know if the link is brought up as 100 or 1000 though - w=
hich=A0
> > the driver already knows.
>=20
> User space knows that information via ethtool or /sys.

Fair point.

> > > Testing this RFC
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > >=20
> > > For testing the patches of this RFC only, you can refer to the sample=
s and
> > > helper script being added to samples/tsn/ and the use the 'mqprio' qd=
isc to
> > > setup the priorities to Tx queues mapping, together with the 'cbs' qd=
isc to
> > > configure the HW shaper of the i210 controller:
> >=20
> > I will test it, feedback will be provided soon! :)
>=20
> That's great! Please let us know if you find any issue and thanks for you
> support.
>=20
> > > 8) You can also run a Talker for class B (prio 2 here)
> > > $ ./talker -i enp3s0 -p 2
> > >=20
> > > =A0* The bandwidth displayed on the listener output now should increa=
se to
> > > very
> > > =A0=A0=A0close to the one configured for class A + class B.
> >=20
> > Because you grab both class A *and* B, or because B will eat what A doe=
s=A0
> > not use?
>=20
> Because the listener application grabs both class A and B traffic.

Right, got it.

Thanks for the feedback, I'm getting really excited about this! :D

--=20
Henrik Austad

--lCAWRPmW1mITcIfM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyM18ACgkQ6k5VT6v45ln2sgCgt76e+u5SSB+xVVyyyhfY5qrP
OCAAoJfGSWyljyfRwmfcWKj9gdpHxLvy
=f767
-----END PGP SIGNATURE-----

--lCAWRPmW1mITcIfM--
