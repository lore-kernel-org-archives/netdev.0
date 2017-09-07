From: "Guedes, Andre" <andre.guedes@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 19:58:53 +0000
Message-ID: <1504814332.2117.3.camel@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
         <20170907053411.GA6580@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=sha-1;
        protocol="application/x-pkcs7-signature"; boundary="=-1rnfjAUYd1UlqsS39X5Z"
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "Sanchez-Palencia, Jesus" <jesus.sanchez-palencia@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "henrik@austad.us" <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:13372 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755885AbdIGT64 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 15:58:56 -0400
In-Reply-To: <20170907053411.GA6580@sisyphus.home.austad.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-1rnfjAUYd1UlqsS39X5Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Henrik,

Thanks for your feedback! I'll address some of your comments below.

On Thu, 2017-09-07 at 07:34 +0200, Henrik Austad wrote:
> > As for the shapers config interface:
> >=20
> > =C2=A0* CBS (802.1Qav)
> >=20
> > =C2=A0=C2=A0=C2=A0This patchset is proposing a new qdisc called 'cbs'. =
Its 'tc' cmd line
> > is:
> > =C2=A0=C2=A0=C2=A0$ tc qdisc add dev IFACE parent ID cbs locredit N hic=
redit M sendslope S
> > \
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0idleslope I
>=20
> So this confuses me a bit, why specify sendSlope?
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0sendSlope =3D portTransmitRate - idleSlope
>=20
> and portTransmitRate is the speed of the MAC (which you get from the=C2=
=A0
> driver). Adding sendSlope here is just redundant I think.

Yes, this was something we've spent quite a few time discussing before this=
 RFC
series. After reading the Annex L from 802.1Q-2014 (operation of CBS algori=
thm)
so many times, we've came up with the rationale explained below.

The rationale here is that sendSlope is just another parameter from CBS
algorithm like idleSlope, hiCredit and loCredit. As such,=C2=A0its calculat=
ion
should be done at the same "layer" as the others parameters (in this case, =
user
space) in order to keep consistency. Moreover, in this design, the driver l=
ayer
is dead simple: all the device driver=C2=A0has to do is applying CBS parame=
ters to
hardware. Having any CBS parameter calculation in the driver layer means al=
l
device drivers must implement that calculation.

> Also, does this mean that when you create the qdisc, you have locked the=
=C2=A0
> bandwidth for the scheduler? Meaning, if I later want to add another=C2=
=A0
> stream that requires more bandwidth, I have to close all active streams,=
=C2=A0
> reconfigure the qdisc and then restart?

If we want to reserve more bandwidth to "accommodate" a new stream, we don'=
t
need to close all active streams. All we have to do is changing the CBS qdi=
sc
and pass the new CBS parameters. Here is what the command-line would look l=
ike:

$ tc qdisc change dev enp0s4 parent 8001:5 cbs locredit -1470 hicredit 30
sendslope -980000 idleslope 20000

No application/stream is interrupted while new CBS parameters are applied.

> > =C2=A0=C2=A0=C2=A0Note that the parameters for this qdisc are the ones =
defined by the
> > =C2=A0=C2=A0=C2=A0802.1Q-2014 spec, so no hardware specific functionali=
ty is exposed here.
>=20
> You do need to know if the link is brought up as 100 or 1000 though - whi=
ch=C2=A0
> the driver already knows.

User space knows that information via ethtool or /sys.

> > Testing this RFC
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > For testing the patches of this RFC only, you can refer to the samples =
and
> > helper script being added to samples/tsn/ and the use the 'mqprio' qdis=
c to
> > setup the priorities to Tx queues mapping, together with the 'cbs' qdis=
c to
> > configure the HW shaper of the i210 controller:
>=20
> I will test it, feedback will be provided soon! :)

That's great! Please let us know if you find any issue and thanks for you
support.

> > 8) You can also run a Talker for class B (prio 2 here)
> > $ ./talker -i enp3s0 -p 2
> >=20
> > =C2=A0* The bandwidth displayed on the listener output now should incre=
ase to
> > very
> > =C2=A0=C2=A0=C2=A0close to the one configured for class A + class B.
>=20
> Because you grab both class A *and* B, or because B will eat what A does=
=C2=A0
> not use?

Because the listener application grabs both class A and B traffic.

Regards,

Andre
--=-1rnfjAUYd1UlqsS39X5Z
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
UizwODL0ejWFvIsCUeYSP2hojKPWo+Rd3xqVimkMF4BtboMY1QcGgHrUz+39T0ykiwIDAQABo4IC
LzCCAiswHQYDVR0OBBYEFGx9NuU31zGSN+jD/sIvs5oY7S+3MB8GA1UdIwQYMBaAFB5pKrTcKP5H
GE4hCz+8rBEv8Jj1MGUGA1UdHwReMFwwWqBYoFaGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9z
aXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNy
bDCBnwYIKwYBBQUHAQEEgZIwgY8waQYIKwYBBQUHMAKGXWh0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDRBLmNydDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuaW50ZWwuY29tLzALBgNVHQ8E
BAMCB4AwPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlngd69
OZXwQwIBZAIBCTAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3FQoE
HDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwSQYDVR0RBEIwQKAmBgorBgEEAYI3FAIDoBgM
FmFuZHJlLmd1ZWRlc0BpbnRlbC5jb22BFmFuZHJlLmd1ZWRlc0BpbnRlbC5jb20wDQYJKoZIhvcN
AQEFBQADggEBAE+EXag/N5PkW1uXsayWx3r4MzYFcznK3N1UG/6qR+UUB/PD4tbgU5M+IoP9gOp+
hzTOxM1PWxhyD24upEzuinkJ3BknENUeFZEaWnYQi306SMzJP3CzEiWogQ2/+JJXYb2vvQjeKEaq
mFdqshHJ7uFxdjmCYHlxmZte2oBC6DbaKeHcHyFxe0xxuaTwOQE3OoJNVcxpN2xK9rbnoe2a/oeg
LLn91PvxSNgjH0QC/TeY5kf5Pif4RAKi9ZsI6OwPhEpFhZbTJISCwmgdGcK/mVGyVtBaXciOboVJ
EwrCLsa+eAhbGn4F4MwTumo6oyzZa2SkenXS5M7chmcL0FvJ6F4xggIXMIICEwIBATCBkDB5MQsw
CQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQKExFJ
bnRlbCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBD
QSA0QQITMwAAi3Vjd570fy3HwgAAAACLdTAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqG
SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcwOTA3MTk1ODUyWjAjBgkqhkiG9w0BCQQxFgQUa3uH
EMFz06cYF25wPni6vaqaKgQwDQYJKoZIhvcNAQEBBQAEggEABAHPPPWfDRbYk9J7rLeHOQyRUXJe
t36VrkNKMrNaTomt3uX2eTs3TbQKdxGOhOhoO/KaCiAoJpkw4KBCZTYi6QcLMSz/n8Qv6N03xtHj
/RhcyB5dCtUTPjYlaESbzkXxUccrQ3nTyufJ7WJPLveYs28adlLMkgiCTqGOZEF4QsGmWpH0YbCG
kpYFweMkFEC8tOju23O+6/nyzMTjAxtTjW4x99qi5kkDf6D4qFLROzVSCFbZELUYp7ebqmT5umFs
v9ua8r0mJ0t5DdGWcg5dz2Oy2Yr6QHKEP9RPfXRvwcRs816PHYM/e+1FWNzScYB22z7hTSnTl34S
nNPtTmLn0gAAAAAAAA==


--=-1rnfjAUYd1UlqsS39X5Z--
