From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: Frequent spurious tx_timeouts for libertas
Date: Mon, 02 May 2011 21:47:39 +0100
Message-ID: <1304369259.2833.180.camel@localhost>
References: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg@mail.gmail.com>
	 <1304303082.2833.159.camel@localhost>
	 <BANLkTi=FT4v=Jvv5bQpUX15R87kPudKq=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=FT4v=Jvv5bQpUX15R87kPudKq=Q@mail.gmail.com>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-02 at 20:59 +0100, Daniel Drake wrote:
> On 2 May 2011 03:24, Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org> wrote:
> >> Also, while looking at this code, I spotted a bug in dev_watchdog():
> >>                               /*
> >>                                * old device drivers set dev->trans_start
> >>                                */
> >>                               trans_start = txq->trans_start ? : dev->trans_start;
> >>
> >> i.e. it is trying to figure out whether to read trans_start from txq
> >> or dev. In both cases, trans_start is updated based on the value of
> >> jiffies, which will occasionally be 0 (as it wraps around). Therefore
> >> this line of code will occasionally make the wrong decision.
> >
> > No, I don't think so.
> >
> > If only dev->trans_start is being updated then the watchdog reads that.
> > If both txq->trans_start and dev->trans_start are being updated then it
> > doesn't matter much which the watchdog reads.
> > If only txq->trans_start is being updated then dev->trans_start is
> > always set to 0, so when txq->trans_start is 0 the watchdog still gets
> > 0.
> 
> dev->trans_start is unconditionally initialized by dev_activate() in
> sch_generic.c:
> 
> 	if (need_watchdog) {
> 		dev->trans_start = jiffies;
> 		dev_watchdog_up(dev);
> 	}
> 
> so it is (usually) not 0.
[...]

You're right.  Seems like we have an incomplete compatibility hack that
can hurt drivers that are doing the right thing.

For those few single-queue drivers that need to update the transmit
time, perhaps we could add a dev_trans_update() as a wrapper for
txq_trans_update().  Then delete net_device::trans_start and change
dev_trans_start() to avoid using it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
