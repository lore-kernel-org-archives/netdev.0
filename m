From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be
 active
Date: Wed, 10 Apr 2013 07:49:11 -0500
Message-ID: <1365598151.28888.25.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1364832288.3059.12.camel@dcbw.foobar.com>
	 <1365548547.23372.2.camel@dcbw.foobar.com>
	 <2328167.HJRXSHNhKT@linux-5eaq.site>
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
In-Reply-To: <2328167.HJRXSHNhKT-7ztolUikljGernLeA6q8OA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-04-10 at 09:23 +0200, Oliver Neukum wrote:
> On Tuesday 09 April 2013 18:02:27 Dan Williams wrote:
> > Some drivers (sierra_net) need the status interrupt URB
> > active even when the device is closed, because they receive
> > custom indications from firmware.  Add functions to refcount
> > the status interrupt URB submit/kill operation so that
> > sub-drivers and the generic driver don't fight over whether
> > the status interrupt URB is active or not.
> > 
> > A sub-driver can call usbnet_status_start() at any time, but
> > the URB is only submitted the first time the function is
> > called.  Likewise, when the sub-driver is done with the URB,
> > it calls usbnet_status_stop() but the URB is only killed when
> > all users have stopped it.  The URB is still killed and
> > re-submitted for suspend/resume, as before, with the same
> > refcount it had at suspend.
> > 
> > Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/usb/usbnet.c   | 79 ++++++++++++++++++++++++++++++++++++++++++----
> >  include/linux/usb/usbnet.h |  5 +++
> >  2 files changed, 77 insertions(+), 7 deletions(-)
> > 
> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> > index 51f3192..e8b363a 100644
> > --- a/drivers/net/usb/usbnet.c
> > +++ b/drivers/net/usb/usbnet.c
> > @@ -42,7 +42,7 @@
> >  #include <linux/workqueue.h>
> >  #include <linux/mii.h>
> >  #include <linux/usb.h>
> > -#include <linux/usb/usbnet.h>
> > +#include "usbnet.h"
> >  #include <linux/slab.h>
> >  #include <linux/kernel.h>
> >  #include <linux/pm_runtime.h>
> > @@ -252,6 +252,70 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
> >  	return 0;
> >  }
> >  
> > +/* Submit the interrupt URB if it hasn't been submitted yet */
> > +static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
> > +					bool force)
> > +{
> > +	int ret = 0;
> > +	bool submit = false;
> > +
> > +	if (!dev->interrupt)
> > +		return 0;
> > +
> > +	mutex_lock(&dev->interrupt_mutex);
> > +
> > +	if (force) {
> 
> That design means that interrupt_count isn't accurate if force is used.
> That is extremely ugly.

True; the problem here is that the URB isn't always submitted when
suspend is used.  For example, in a normal driver that doesn't need the
URB submitted all the time, interrupt_count will be 0 while !IFF_UP.
Then if the system suspends, we can't decrement interrupt_count because
it's zero.

Besides, if the system is suspended, no driver can call
usbnet_interrupt_start() or usbnet_interrupt_stop(), correct?  Suspend
is a special condition here and nothing that starts/stops the urbs will
ever run while the system is suspended.

> > +		/* Only submit now if the URB was previously submitted */
> > +		if (dev->interrupt_count)
> > +			submit = true;
> > +	} else if (++dev->interrupt_count == 1)
> > +		submit = true;
> > +
> > +	if (submit)
> > +		ret = usb_submit_urb(dev->interrupt, mem_flags);
> > +
> > +	dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
> > +		dev->interrupt_count);
> > +	mutex_unlock(&dev->interrupt_mutex);
> > +	return ret;
> > +}
> > +
> > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> > +{
> > +	/* Only drivers that implement a status hook should call this */
> > +	BUG_ON(dev->interrupt == NULL);
> > +
> > +	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags))
> > +		return -EINVAL;
> 
> This looks like a race condition.

True, I'll have to fix this.  But it looks like EVENT_DEV_ASLEEP is
protected by *either* rxq.lock (rx_submit) or txq.lock
(usbnet_start_xmit, usbnet_suspend, usbnet_resume).  That doesn't seem
right, actually...  shouldn't it be protected all by one lock, not two
different ones?

> > +	return __usbnet_status_start(dev, mem_flags, false);
> > +}
> > +EXPORT_SYMBOL_GPL(usbnet_status_start);
> > +
> > +/* Kill the interrupt URB if all submitters want it killed */
> > +static void __usbnet_status_stop(struct usbnet *dev, bool force)
> > +{
> > +	if (dev->interrupt) {
> > +		mutex_lock(&dev->interrupt_mutex);
> > +		if (!force)
> > +			BUG_ON(dev->interrupt_count == 0);
> > +
> > +		if (force || --dev->interrupt_count == 0)
> > +			usb_kill_urb(dev->interrupt);
> 
> Why so complicated? If it may be on, kill it unconditionally.

This function isn't only called from suspend.  It's also called if the
sub-driver doesn't need the interrupt urb open anymore, because earlier
you indicated that we didn't want to unconditionally keep the URB open
if something didn't need it, because it's wasteful of resources.

So for example, sierra_net will call usbnet_status_start() at driver
init time, and then it could call usbnet_status_stop() when it has
received the RESTART indication about 2 seconds after driver init, all
before the interface is IFF_UP and before usbnet would ever have
submitted the URB.  However, if during that 2 seconds, somethign *does*
set the interface IFF_UP, you don't want sierra_net causing the urb to
be killed right underneath usbnet.  Hence the refcounting scheme here.

force is used only for suspend/resume specifically to ensure that the
URB is unconditionally killed at suspend time.

Dan

> > +
> > +		dev_dbg(&dev->udev->dev,
> > +			"decremented interrupt URB count to %d\n",
> > +			dev->interrupt_count);
> > +		mutex_unlock(&dev->interrupt_mutex);
> > +	}
> > +}
> > +
> 
> 	Regards
> 		Oliver
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
