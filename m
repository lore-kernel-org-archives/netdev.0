From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 15:29:24 +0200
Message-ID: <1542762.9EJvNHlBNo@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <17293717.QHaggPmODU@linux-5eaq.site> <1365599937.28888.33.camel@dcbw.foobar.com>
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
Received: from smtp-out002.kontent.com ([81.88.40.216]:38547 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab3DJN2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 09:28:38 -0400
In-Reply-To: <1365599937.28888.33.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 April 2013 08:18:57 Dan Williams wrote:
> On Wed, 2013-04-10 at 15:06 +0200, Oliver Neukum wrote:
> > On Wednesday 10 April 2013 07:49:11 Dan Williams wrote:
> > > On Wed, 2013-04-10 at 09:23 +0200, Oliver Neukum wrote:
> > > > On Tuesday 09 April 2013 18:02:27 Dan Williams wrote:
> > 
> > > > > +/* Submit the interrupt URB if it hasn't been submitted yet */
> > > > > +static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
> > > > > +					bool force)
> > > > > +{
> > > > > +	int ret = 0;
> > > > > +	bool submit = false;
> > > > > +
> > > > > +	if (!dev->interrupt)
> > > > > +		return 0;
> > > > > +
> > > > > +	mutex_lock(&dev->interrupt_mutex);
> > > > > +
> > > > > +	if (force) {
> > > > 
> > > > That design means that interrupt_count isn't accurate if force is used.
> > > > That is extremely ugly.
> > > 
> > > True; the problem here is that the URB isn't always submitted when
> > > suspend is used.  For example, in a normal driver that doesn't need the
> > > URB submitted all the time, interrupt_count will be 0 while !IFF_UP.
> > > Then if the system suspends, we can't decrement interrupt_count because
> > > it's zero.
> > 
> > We don't need to. You ought to understand interrupt_count as
> > valid only while the device is not suspended.
> 
> Ok, so at suspend we just drop the count to zero, force-kill the URB,

No, at suspend() ignore interrupt_count. Just kill.

> and then on resume it's not re-submitted again?  That seems odd, since

On resume() evaluate interrupt_count.

> the usbnet driver handles submit/resubmit internally if the interface is
> IFF_UP, but when the interface is !IFF_UP then sub-drivers would have to
> track whether they submitted the urb or not, and then clear that on
> suspend?  Having separate behavior for when the sub-driver starts the
> URB and when usbnet does seems inconsistent and error-prone.
> 
> What approach would you suggest here?

Religiously use interrupt_count. With one exception.
The start/stop helpers are good. Just don't use them at suspend().

[..]
> See my questions above.  Then we'd have to have the sub-drivers
> implement suspend/resume hooks so they'd be able to resubmit the
> interrupt URB on resume, and the whole point of this patch was to handle
> all that in usbnet.  The sub-drivers don't know what the core driver's
> suspend/resume count is, because dev->suspend_count isn't exposed to
> subdrivers, and thus they don't know whether the device is actually
> suspended or not.
> 
> The core problem is this... the sub-driver submits the URB before
> IFF_UP, and then at IFF_UP time usbnet wants to submit the driver.
> Let's say later the sub-driver doesn't need its private interrupt URB
> submission anymore, but it can't kill the URB because usbnet has
> submitted it too.  Hence the refcounting.

The refcounting is very good. Just don't mess around with "force"

	Regards
		Oliver
