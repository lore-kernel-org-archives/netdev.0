From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/4] net: macb: Add hardware PTP support
Date: Wed, 3 May 2017 11:43:04 +0200
Message-ID: <20170503094304.GD2340@localhost.localdomain>
References: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
 <1492090763-15686-1-git-send-email-rafalo@cadence.com>
 <20170414182850.GB7751@localhost.localdomain>
 <BN3PR07MB2516757CB4EA7367F6623C06C9170@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org" <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
        "Andrei.Pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org" <Andrei.Pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
To: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BN3PR07MB2516757CB4EA7367F6623C06C9170-EldUQEzkDQfxGZiqM5fOI+FPX92sqiQdvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 02, 2017 at 01:57:15PM +0000, Rafal Ozieblo wrote:
> > What is the point of this wrapper function anyhow?  Please remove it.
> gem_ptp_gettime() is assigned in ptp_clock_info and it has to have 
> ptp_clock_info pointer as first parameter. gem_tsu_get_time() is used in
> the source code but with macb pointer.
> Do you want me to do something like:
> gem_ptp_gettime(macb->ptp, ts);
> and first would be getting macb pointer from ptp ?
> struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);

Yes.  Unless your sub-function is used in more than one place, then it
is wasteful and confusing to wrap the functionality for no apparent
reason.

> > > +	switch (rq->type) {
> > > +	case PTP_CLK_REQ_EXTTS:	/* Toggle TSU match interrupt */
> > > +		if (on)
> > > +			macb_writel(bp, IER, MACB_BIT(TCI));
> > 
> > No locking to protect IER and IDE?
> There is no need.

But what happens when the PTP_CLK_REQ_EXTTS and PTP_CLK_REQ_PPS ioctls
are called at the same time?

You need to ensure that IDR is consistent.  If the bits are write
only, then you should comment this fact.

> > > +		else
> > > +			macb_writel(bp, IDR, MACB_BIT(TCI));
> > > +		break;
> > > +	case PTP_CLK_REQ_PEROUT: /* Toggle Periodic output */
> > > +		return -EOPNOTSUPP;
> > > +		/* break; */
> > > +	case PTP_CLK_REQ_PPS:	/* Toggle TSU periodic (second)
> > interrupt */
> > > +		if (on)
> > > +			macb_writel(bp, IER, MACB_BIT(SRI));
> > > +		else
> > > +			macb_writel(bp, IDR, MACB_BIT(SRI));
> > > +		break;
> > > +	default:
> > > +		break;
> > > +	}
> > > +	return 0;
> > > +}

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
