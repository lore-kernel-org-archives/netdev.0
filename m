From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be
 active
Date: Wed, 10 Apr 2013 08:18:57 -0500
Message-ID: <1365599937.28888.33.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <2328167.HJRXSHNhKT@linux-5eaq.site>
	 <1365598151.28888.25.camel@dcbw.foobar.com>
	 <17293717.QHaggPmODU@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750738Ab3DJNRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 09:17:55 -0400
In-Reply-To: <17293717.QHaggPmODU@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-10 at 15:06 +0200, Oliver Neukum wrote:
> On Wednesday 10 April 2013 07:49:11 Dan Williams wrote:
> > On Wed, 2013-04-10 at 09:23 +0200, Oliver Neukum wrote:
> > > On Tuesday 09 April 2013 18:02:27 Dan Williams wrote:
> 
> > > > +/* Submit the interrupt URB if it hasn't been submitted yet */
> > > > +static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
> > > > +					bool force)
> > > > +{
> > > > +	int ret = 0;
> > > > +	bool submit = false;
> > > > +
> > > > +	if (!dev->interrupt)
> > > > +		return 0;
> > > > +
> > > > +	mutex_lock(&dev->interrupt_mutex);
> > > > +
> > > > +	if (force) {
> > > 
> > > That design means that interrupt_count isn't accurate if force is used.
> > > That is extremely ugly.
> > 
> > True; the problem here is that the URB isn't always submitted when
> > suspend is used.  For example, in a normal driver that doesn't need the
> > URB submitted all the time, interrupt_count will be 0 while !IFF_UP.
> > Then if the system suspends, we can't decrement interrupt_count because
> > it's zero.
> 
> We don't need to. You ought to understand interrupt_count as
> valid only while the device is not suspended.

Ok, so at suspend we just drop the count to zero, force-kill the URB,
and then on resume it's not re-submitted again?  That seems odd, since
the usbnet driver handles submit/resubmit internally if the interface is
IFF_UP, but when the interface is !IFF_UP then sub-drivers would have to
track whether they submitted the urb or not, and then clear that on
suspend?  Having separate behavior for when the sub-driver starts the
URB and when usbnet does seems inconsistent and error-prone.

What approach would you suggest here?

> > Besides, if the system is suspended, no driver can call
> > usbnet_interrupt_start() or usbnet_interrupt_stop(), correct?  Suspend
> > is a special condition here and nothing that starts/stops the urbs will
> > ever run while the system is suspended.
> 
> Unfortunately there's also runtime power management.

Hmm, right.

> > > > +		/* Only submit now if the URB was previously submitted */
> > > > +		if (dev->interrupt_count)
> > > > +			submit = true;
> > > > +	} else if (++dev->interrupt_count == 1)
> > > > +		submit = true;
> > > > +
> > > > +	if (submit)
> > > > +		ret = usb_submit_urb(dev->interrupt, mem_flags);
> > > > +
> > > > +	dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
> > > > +		dev->interrupt_count);
> > > > +	mutex_unlock(&dev->interrupt_mutex);
> > > > +	return ret;
> > > > +}
> > > > +
> > > > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> > > > +{
> > > > +	/* Only drivers that implement a status hook should call this */
> > > > +	BUG_ON(dev->interrupt == NULL);
> > > > +
> > > > +	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags))
> > > > +		return -EINVAL;
> > > 
> > > This looks like a race condition.
> > 
> > True, I'll have to fix this.  But it looks like EVENT_DEV_ASLEEP is
> > protected by *either* rxq.lock (rx_submit) or txq.lock
> > (usbnet_start_xmit, usbnet_suspend, usbnet_resume).  That doesn't seem
> > right, actually...  shouldn't it be protected all by one lock, not two
> > different ones?
> 
> Yes.
> 
> > > > +	return __usbnet_status_start(dev, mem_flags, false);
> > > > +}
> > > > +EXPORT_SYMBOL_GPL(usbnet_status_start);
> > > > +
> > > > +/* Kill the interrupt URB if all submitters want it killed */
> > > > +static void __usbnet_status_stop(struct usbnet *dev, bool force)
> > > > +{
> > > > +	if (dev->interrupt) {
> > > > +		mutex_lock(&dev->interrupt_mutex);
> > > > +		if (!force)
> > > > +			BUG_ON(dev->interrupt_count == 0);
> 
> BTW: please unify this in case somebody compiles out BUG_ON

Can do.

> > > > +
> > > > +		if (force || --dev->interrupt_count == 0)
> > > > +			usb_kill_urb(dev->interrupt);
> > > 
> > > Why so complicated? If it may be on, kill it unconditionally.
> > 
> > This function isn't only called from suspend.  It's also called if the
> > sub-driver doesn't need the interrupt urb open anymore, because earlier
> > you indicated that we didn't want to unconditionally keep the URB open
> > if something didn't need it, because it's wasteful of resources.
> > 
> > So for example, sierra_net will call usbnet_status_start() at driver
> > init time, and then it could call usbnet_status_stop() when it has
> > received the RESTART indication about 2 seconds after driver init, all
> > before the interface is IFF_UP and before usbnet would ever have
> > submitted the URB.  However, if during that 2 seconds, somethign *does*
> > set the interface IFF_UP, you don't want sierra_net causing the urb to
> > be killed right underneath usbnet.  Hence the refcounting scheme here.
> > 
> > force is used only for suspend/resume specifically to ensure that the
> > URB is unconditionally killed at suspend time.
> 
> It is likely to be more elegant to drop force and have an unconditional kill
> in suspend.

See my questions above.  Then we'd have to have the sub-drivers
implement suspend/resume hooks so they'd be able to resubmit the
interrupt URB on resume, and the whole point of this patch was to handle
all that in usbnet.  The sub-drivers don't know what the core driver's
suspend/resume count is, because dev->suspend_count isn't exposed to
subdrivers, and thus they don't know whether the device is actually
suspended or not.

The core problem is this... the sub-driver submits the URB before
IFF_UP, and then at IFF_UP time usbnet wants to submit the driver.
Let's say later the sub-driver doesn't need its private interrupt URB
submission anymore, but it can't kill the URB because usbnet has
submitted it too.  Hence the refcounting.

Dan
