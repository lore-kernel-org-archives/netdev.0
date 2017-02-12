From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 11:27:16 +0000
Message-ID: <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0044.outbound.protection.outlook.com ([104.47.38.44]:53036
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751137AbdBLL1U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 06:27:20 -0500
In-Reply-To: <20170211111638.GA6564@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sat, Feb 11, 2017 at 09:58:10AM +0100, Richard Cochran wrote:
> > If I am not mistaken, then you can skip the cases val=3D=3D2 and val=3D=
=3D3,
> > because they are equivalent to val=3D=3D4 and 6.
>=20
> I took a stab at this, and you can see the result, below.  My version has
> lower average error than yours in the interval 1 < ppb < 60000, and it us=
es
> only 8 64-bit divisions.  Outside of that interval, your version has lowe=
r error.
>=20
> So, at the very least, you should introduce a threshold and use this
> algorithm for adjustments under 60 ppm.  Better yet, find a way to use fe=
wer
> divisions for adjustments greater and 60 ppm...
>=20
> Thanks,
> Richard
>=20
> ---
> #include <stdint.h>
>=20
> #define TEN9		(1000000000UL)
>=20
> unsigned int calc_min_integer(uint64_t ppb, uint64_t *M) {
> 	uint64_t err, m, min, n, N, p2, reg;
>=20
> 	min =3D TEN9;
> 	for (n =3D 4; n <=3D 7; n++) {
> 		m =3D n * TEN9;
> 		m =3D (m + ppb/2) / ppb;
>=20
> 		/*truncate to HW resolution*/
> 		reg =3D (m + 8) / 16;
> 		m =3D reg * 16;
>=20
> 		p2 =3D (n * TEN9 + m/2) / m;
>=20
> 		err =3D ppb > p2 ? ppb - p2 : p2 - ppb;
>=20
> 		if (min >=3D err) {
> 			min =3D err;
> 			N =3D n;
> 			*M =3D m;
> 		}
> 	}
> 	return N;
> }

Richard, there are quite a bit of inaccuracies in the calculation here.
I think it's best I'll clarify some things about the used algorithm -

Given a fraction represented by (ppb / 10^9), the purpose of
the loop is to best approximate it by a (val / ((16 * period) + 8)
fraction, where val belongs to {0,..,7} and period to {0,...,0xffffff}.
We'd need 'val' and 'period' from the calculation to configure the HW.

The '+8' is not some sort of rounding correction, but rather part
of the required configuration.
Notice that if we wouldn't have needed it, we could have
reduced some of the iterations [since (val / 16 * period) can be
reduced for powers of two]. But given that we do, skipping those
iteration would cause us to lose accuracy.

Your suggestion seems to:
  a. Assume that the required period should be in ns, not in
      16*ns units.
  b. mishandles the +8/-8 in the calculation.
  c. Doesn't seem to consider the upper bound on period.
In addition, the rounding-up via ppb is likely to harm accuracy for
higher ppb values.

One thing I still don't get is *why* we're trying to optimize this
area of the code -
I ran a variant of the original code in a loop [on requiring 24
divisions per Call] on various PPB values, and managed close
to 1M/s [single CPU, 64bit, 2.50GHz].

Given that the real use-case is somewhere between 1-16/second,
why do we treat it as if its performance is crucial?

Thanks,
Yuval
