From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH 3/4] net: macb: Add hardware PTP support
Date: Tue, 2 May 2017 13:57:15 +0000
Message-ID: <BN3PR07MB2516757CB4EA7367F6623C06C9170@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
 <1492090763-15686-1-git-send-email-rafalo@cadence.com>
 <20170414182850.GB7751@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "Andrei.Pistirica@microchip.com" <Andrei.Pistirica@microchip.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170414182850.GB7751@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: 14 kwietnia 2017 20:29
> To: Rafal Ozieblo <rafalo@cadence.com>
> Cc: David Miller <davem@davemloft.net>; nicolas.ferre@atmel.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> harinikatakamlinux@gmail.com; harini.katakam@xilinx.com;
> Andrei.Pistirica@microchip.com
> Subject: Re: [PATCH 3/4] net: macb: Add hardware PTP support
>=20
> On Thu, Apr 13, 2017 at 02:39:23PM +0100, Rafal Ozieblo wrote:
(...)
> > +static int gem_tsu_get_time(struct macb *bp, struct timespec64 *ts)
> > +{
> > +	long first, second;
> > +	u32 secl, sech;
> > +	unsigned long flags;
> > +
> > +	if (!bp || !ts)
> > +		return -EINVAL;
>=20
> Useless test.
Sorry for me being too carefulness, I'll remove all tests.
>=20
(...)
> > +static int gem_ptp_gettime(struct ptp_clock_info *ptp, struct timespec=
64
> *ts)
> > +{
> > +	struct macb *bp =3D container_of(ptp, struct macb, ptp_clock_info);
> > +
> > +	if (!ptp || !ts)
> > +		return -EINVAL;
>=20
> Useles test.
>=20
> What is the point of this wrapper function anyhow?  Please remove it.
gem_ptp_gettime() is assigned in ptp_clock_info and it has to have=20
ptp_clock_info pointer as first parameter. gem_tsu_get_time() is used in
the source code but with macb pointer.
Do you want me to do something like:
gem_ptp_gettime(macb->ptp, ts);
and first would be getting macb pointer from ptp ?
struct macb *bp =3D container_of(ptp, struct macb, ptp_clock_info);
>=20
> > +
> > +	gem_tsu_get_time(bp, ts);
> > +	return 0;
> > +}
> > +
> > +static int gem_ptp_settime(struct ptp_clock_info *ptp,
> > +		const struct timespec64 *ts)
> > +{
> > +	struct macb *bp =3D container_of(ptp, struct macb, ptp_clock_info);
> > +
> > +	if (!ptp || !ts)
> > +		return -EINVAL;
>=20
> Another useless function.
ditto
>=20
> > +	gem_tsu_set_time(bp, ts);
> > +	return 0;
> > +}
> > +
> > +static int gem_ptp_enable(struct ptp_clock_info *ptp,
> > +			  struct ptp_clock_request *rq, int on)
> > +{
> > +	struct macb *bp =3D container_of(ptp, struct macb, ptp_clock_info);
> > +
> > +	if (!ptp || !rq)
> > +		return -EINVAL;
>=20
> Sigh.
>=20
> > +
> > +	switch (rq->type) {
> > +	case PTP_CLK_REQ_EXTTS:	/* Toggle TSU match interrupt */
> > +		if (on)
> > +			macb_writel(bp, IER, MACB_BIT(TCI));
>=20
> No locking to protect IER and IDE?
There is no need.
>=20
> > +		else
> > +			macb_writel(bp, IDR, MACB_BIT(TCI));
> > +		break;
> > +	case PTP_CLK_REQ_PEROUT: /* Toggle Periodic output */
> > +		return -EOPNOTSUPP;
> > +		/* break; */
> > +	case PTP_CLK_REQ_PPS:	/* Toggle TSU periodic (second)
> interrupt */
> > +		if (on)
> > +			macb_writel(bp, IER, MACB_BIT(SRI));
> > +		else
> > +			macb_writel(bp, IDR, MACB_BIT(SRI));
> > +		break;
> > +	default:
> > +		break;
> > +	}
> > +	return 0;
> > +}
> > +
(...)
> > --
> > 2.4.5
> >
>=20
> Thanks,
> Richard
