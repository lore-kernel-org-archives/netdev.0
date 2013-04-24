From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be
 active
Date: Wed, 24 Apr 2013 07:31:25 -0500
Message-ID: <1366806685.4265.3.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <5581442.KzM2iaDSQ0@linux-5eaq.site>
	 <CACVXFVP=DrbPinLt_rxYETmRYONt-MOsmhAv_O8EcrnpbVohMA@mail.gmail.com>
	 <1436202.ggQbKKzqIM@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>,
	Alan Stern <stern@rowland.harvard.edu>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab3DXM3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:29:51 -0400
In-Reply-To: <1436202.ggQbKKzqIM@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 10:25 +0200, Oliver Neukum wrote:
> On Thursday 18 April 2013 11:51:25 Ming Lei wrote:
> > On Wed, Apr 17, 2013 at 2:55 PM, Oliver Neukum <oliver@neukum.org> wrote:
> >
> > > If we have a function for starting a status URB we want to use it whenever
> > > it applies, that is also when we need to poll status for internal reason while
> > > an interface is up.
> > 
> > For other non-sierra usbnet devices, when an interface is up, the status URB
> > is scheduled in open() and needn't the API.
> 
> But that is the very point. This API is used from _within_ open.
> We cannot make every open() use GFP_NOIO
> 
> > > You don't need to understand it any more than you need to understand
> > > the rule for usb_submit_urb(). The rules are the very same. There is no
> > > special effort here.
> > 
> > No, there isn't one rule for the corner case here, and the corner case should
> > have existed in probe() or cancel queue with reset of all USB drivers, instead
> > of usbnet only.
> 
> The same rule applies to usb_submit_urb(), too.
>  
> > Also the rule 3 is a bit obscure, maybe not correct, at least there are much
> > GFP_KERNEL usages in kthread of usbnet. I am wondering if there are
> > other usbnet specific memflags rules except for 1 & 6.
> > 
> > Strictly speaking, the rule 5 isn't correct, since it might trigger the corner
> > case you mentioned, right?
> > 
> > I think we need to review the memflags part of usb_submit_urb() doc now.
> 
> Yes.
> 
> > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> > +{
> > +       int ret = 0;
> > +
> > +       WARN_ON_ONCE(dev->interrupt == NULL);
> > +       if (dev->interrupt) {
> > +               mutex_lock(&dev->interrupt_mutex);
> > 
> > ....
> > 
> > +}
> > 
> > Obviously, the API can't be called in atomic context, and putting runtime PM
> > inside is reasonable and correct.
> 
> Yes, but how is it relevant. What allows us to conclude that a driver does not want
> runtime PM while a status URB is running?
> 
> > > I meant block suspend in the sense of disallowing it. Which is very problematic.
> > > The CDC protocols generally support remote wakeup for status information,
> > > so we need to be able to sleep while status is running to accomodate devices
> > > which are intended to be always online.
> > 
> > At least now, for non-sierra drivers, it needn't the API to schedule status URB
> > which will be started in normal open() path, so won't power on device runtime
> > unnecessarily. That is what I say the API shouldn't be for a general usage, :-)
> 
> But many drivers, e.g. cdc-ether, cdc-ncm and cdc-mbim want to be able
> to runtime suspend while the device is open.

So how do we go forward from here...  I'm happy to update the patchset
with anything needed to get davem to apply it.  Have we decided to keep
the memflags for now, and thus should I just resubmit with a summary of
the discussion under the ---?

If for whatever reason we do find out the memflags aren't really needed,
they can always be removed later since this isn't userspace API.  But I
think they're useful at this point.

Dan
