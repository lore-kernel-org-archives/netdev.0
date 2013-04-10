From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be
 active
Date: Wed, 10 Apr 2013 08:54:43 -0500
Message-ID: <1365602083.28888.40.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <17293717.QHaggPmODU@linux-5eaq.site>
	 <1365599937.28888.33.camel@dcbw.foobar.com>
	 <1542762.9EJvNHlBNo@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1542762.9EJvNHlBNo-7ztolUikljGernLeA6q8OA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-04-10 at 15:29 +0200, Oliver Neukum wrote:
> On Wednesday 10 April 2013 08:18:57 Dan Williams wrote:
> > On Wed, 2013-04-10 at 15:06 +0200, Oliver Neukum wrote:
> > > On Wednesday 10 April 2013 07:49:11 Dan Williams wrote:
> > > > On Wed, 2013-04-10 at 09:23 +0200, Oliver Neukum wrote:
> > > > > On Tuesday 09 April 2013 18:02:27 Dan Williams wrote:
> > > 
> > > > > > +/* Submit the interrupt URB if it hasn't been submitted yet */
> > > > > > +static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
> > > > > > +					bool force)
> > > > > > +{
> > > > > > +	int ret = 0;
> > > > > > +	bool submit = false;
> > > > > > +
> > > > > > +	if (!dev->interrupt)
> > > > > > +		return 0;
> > > > > > +
> > > > > > +	mutex_lock(&dev->interrupt_mutex);
> > > > > > +
> > > > > > +	if (force) {
> > > > > 
> > > > > That design means that interrupt_count isn't accurate if force is used.
> > > > > That is extremely ugly.
> > > > 
> > > > True; the problem here is that the URB isn't always submitted when
> > > > suspend is used.  For example, in a normal driver that doesn't need the
> > > > URB submitted all the time, interrupt_count will be 0 while !IFF_UP.
> > > > Then if the system suspends, we can't decrement interrupt_count because
> > > > it's zero.
> > > 
> > > We don't need to. You ought to understand interrupt_count as
> > > valid only while the device is not suspended.
> > 
> > Ok, so at suspend we just drop the count to zero, force-kill the URB,
> 
> No, at suspend() ignore interrupt_count. Just kill.

Isn't that what the code already does?  The suspend handler sets force
to true, which always kills the URB at suspend time.

> > and then on resume it's not re-submitted again?  That seems odd, since
> 
> On resume() evaluate interrupt_count.

Because suspend/resume doesn't touch interrupt_count (due to the problem
that interrupt_count may be 0 at suspend time if the URB is not yet
submitted), we need a flag to know whether or not to increment the
count, and that's what force is there to do.

> > the usbnet driver handles submit/resubmit internally if the interface is
> > IFF_UP, but when the interface is !IFF_UP then sub-drivers would have to
> > track whether they submitted the urb or not, and then clear that on
> > suspend?  Having separate behavior for when the sub-driver starts the
> > URB and when usbnet does seems inconsistent and error-prone.
> > 
> > What approach would you suggest here?
> 
> Religiously use interrupt_count. With one exception.
> The start/stop helpers are good. Just don't use them at suspend().

So open-code the killing at suspend()?  That's what I had in a previous
patch, but Ming suggested I use the helpers instead to make things
cleaner.  So I did.  Should I revert to the old behavior?

> [..]
> > See my questions above.  Then we'd have to have the sub-drivers
> > implement suspend/resume hooks so they'd be able to resubmit the
> > interrupt URB on resume, and the whole point of this patch was to handle
> > all that in usbnet.  The sub-drivers don't know what the core driver's
> > suspend/resume count is, because dev->suspend_count isn't exposed to
> > subdrivers, and thus they don't know whether the device is actually
> > suspended or not.
> > 
> > The core problem is this... the sub-driver submits the URB before
> > IFF_UP, and then at IFF_UP time usbnet wants to submit the driver.
> > Let's say later the sub-driver doesn't need its private interrupt URB
> > submission anymore, but it can't kill the URB because usbnet has
> > submitted it too.  Hence the refcounting.
> 
> The refcounting is very good. Just don't mess around with "force"

That's easy to do if the helpers aren't used for suspend/resume, which
is what I had previously in my v2 patches until Ming suggested that I
use the helpers there.  I can go back to that approach if you'd like, it
is a bit less complicated at the expense of sprinkling the interrupt urb
submit/kill code around more widely.

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
