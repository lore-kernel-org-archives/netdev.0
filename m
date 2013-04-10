From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 15:06:58 +0200
Message-ID: <17293717.QHaggPmODU@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <2328167.HJRXSHNhKT@linux-5eaq.site> <1365598151.28888.25.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:59901 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935044Ab3DJNGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 09:06:13 -0400
In-Reply-To: <1365598151.28888.25.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 April 2013 07:49:11 Dan Williams wrote:
> On Wed, 2013-04-10 at 09:23 +0200, Oliver Neukum wrote:
> > On Tuesday 09 April 2013 18:02:27 Dan Williams wrote:

> > > +/* Submit the interrupt URB if it hasn't been submitted yet */
> > > +static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
> > > +					bool force)
> > > +{
> > > +	int ret = 0;
> > > +	bool submit = false;
> > > +
> > > +	if (!dev->interrupt)
> > > +		return 0;
> > > +
> > > +	mutex_lock(&dev->interrupt_mutex);
> > > +
> > > +	if (force) {
> > 
> > That design means that interrupt_count isn't accurate if force is used.
> > That is extremely ugly.
> 
> True; the problem here is that the URB isn't always submitted when
> suspend is used.  For example, in a normal driver that doesn't need the
> URB submitted all the time, interrupt_count will be 0 while !IFF_UP.
> Then if the system suspends, we can't decrement interrupt_count because
> it's zero.

We don't need to. You ought to understand interrupt_count as
valid only while the device is not suspended.

> Besides, if the system is suspended, no driver can call
> usbnet_interrupt_start() or usbnet_interrupt_stop(), correct?  Suspend
> is a special condition here and nothing that starts/stops the urbs will
> ever run while the system is suspended.

Unfortunately there's also runtime power management.

> > > +		/* Only submit now if the URB was previously submitted */
> > > +		if (dev->interrupt_count)
> > > +			submit = true;
> > > +	} else if (++dev->interrupt_count == 1)
> > > +		submit = true;
> > > +
> > > +	if (submit)
> > > +		ret = usb_submit_urb(dev->interrupt, mem_flags);
> > > +
> > > +	dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
> > > +		dev->interrupt_count);
> > > +	mutex_unlock(&dev->interrupt_mutex);
> > > +	return ret;
> > > +}
> > > +
> > > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> > > +{
> > > +	/* Only drivers that implement a status hook should call this */
> > > +	BUG_ON(dev->interrupt == NULL);
> > > +
> > > +	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags))
> > > +		return -EINVAL;
> > 
> > This looks like a race condition.
> 
> True, I'll have to fix this.  But it looks like EVENT_DEV_ASLEEP is
> protected by *either* rxq.lock (rx_submit) or txq.lock
> (usbnet_start_xmit, usbnet_suspend, usbnet_resume).  That doesn't seem
> right, actually...  shouldn't it be protected all by one lock, not two
> different ones?

Yes.

> > > +	return __usbnet_status_start(dev, mem_flags, false);
> > > +}
> > > +EXPORT_SYMBOL_GPL(usbnet_status_start);
> > > +
> > > +/* Kill the interrupt URB if all submitters want it killed */
> > > +static void __usbnet_status_stop(struct usbnet *dev, bool force)
> > > +{
> > > +	if (dev->interrupt) {
> > > +		mutex_lock(&dev->interrupt_mutex);
> > > +		if (!force)
> > > +			BUG_ON(dev->interrupt_count == 0);

BTW: please unify this in case somebody compiles out BUG_ON

> > > +
> > > +		if (force || --dev->interrupt_count == 0)
> > > +			usb_kill_urb(dev->interrupt);
> > 
> > Why so complicated? If it may be on, kill it unconditionally.
> 
> This function isn't only called from suspend.  It's also called if the
> sub-driver doesn't need the interrupt urb open anymore, because earlier
> you indicated that we didn't want to unconditionally keep the URB open
> if something didn't need it, because it's wasteful of resources.
> 
> So for example, sierra_net will call usbnet_status_start() at driver
> init time, and then it could call usbnet_status_stop() when it has
> received the RESTART indication about 2 seconds after driver init, all
> before the interface is IFF_UP and before usbnet would ever have
> submitted the URB.  However, if during that 2 seconds, somethign *does*
> set the interface IFF_UP, you don't want sierra_net causing the urb to
> be killed right underneath usbnet.  Hence the refcounting scheme here.
> 
> force is used only for suspend/resume specifically to ensure that the
> URB is unconditionally killed at suspend time.

It is likely to be more elegant to drop force and have an unconditional kill
in suspend.

	Regards
		Oliver
