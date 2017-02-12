From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 15:07:34 +0000
Message-ID: <BL2PR07MB2306751ABE3FC347E40302B18D460@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170212140202.GA1702@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0086.outbound.protection.outlook.com ([104.47.36.86]:33495
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751116AbdBLPHj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 10:07:39 -0500
In-Reply-To: <20170212140202.GA1702@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Your suggestion seems to:
> >   a. Assume that the required period should be in ns, not in
> >       16*ns units.
> >   b. mishandles the +8/-8 in the calculation.
> >   c. Doesn't seem to consider the upper bound on period.
>=20
> Duh, you would have to convert the result into the proper form for the HW
> register and add bounds checking.  I mean, that goes without saying.
> The important fact is that your algorithm it not optimal for ppm < 60.

Your algorithm ignores the HW limitation. Consider (ppb =3D=3D 1):=20
your logic would output N =3D=3D 7, *M =3D=3D 7000000000,
   Which has perfect accuracy [N / *M is 1 / 10^9].
But the solution for
   'period' * 16 + 8 =3D=3D 7 * 10^9
isn't a whole number, so this result doesn't really reflect the actual
approximation error since we couldn't configure it to HW.

The original would return val =3D=3D 1, period =3D=3D 62499999; While this
does have some error [val / (period * 16 + 8) is slightly bigger
than 1 / 10^9, error at 18[?] digit after dot], it's the best we can
configure for the HW.

One simple adjustment we could do is simply break from the loop
If 'diff =3D=3D 0'. At least for small PPB value this would be hit relative=
ly quickly.

> > One thing I still don't get is *why* we're trying to optimize this
> > area of the code -
>=20
> So you prefer using 21 64-bit divisions when using 8 produces better resu=
lts?

No. In an ideal world, I would have liked optimizing everything.
But in this world if I do find time to spend on optimizations=20
I rather do that for the stuff that matters. I.e., datapath.
