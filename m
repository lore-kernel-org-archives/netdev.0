From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2 v3] usbnet: allow status interrupt URB to always be
 active
Date: Mon, 01 Apr 2013 11:04:48 -0500
Message-ID: <1364832288.3059.12.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <1364488207.1877.20.camel@dcbw.foobar.com>
	 <CACVXFVMBAzTYZKiE_uSTqr_yB4f7c5_PSnK=LBP6=oWdWwYHfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVMBAzTYZKiE_uSTqr_yB4f7c5_PSnK=LBP6=oWdWwYHfg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-03-30 at 22:11 +0800, Ming Lei wrote:
> On Fri, Mar 29, 2013 at 12:30 AM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >
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
> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> > index 51f3192..6431a03 100644
> > --- a/drivers/net/usb/usbnet.c
> > +++ b/drivers/net/usb/usbnet.c
> > @@ -252,6 +252,43 @@ static int init_status (struct usbnet *dev, struct
> usb_interface *intf)
> >         return 0;
> >  }
> >
> > +/* Submit the interrupt URB if it hasn't been submitted yet */
> > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> > +{
> > +       int ret = 0;
> > +
> > +       /* Only drivers that implement a status hook should call this */
> > +       BUG_ON(dev->interrupt == NULL);
> 
> It isn't worth BUG_ON() and returning 0 simply should be OK.

The code is attempting to ensure that modules never, ever call
usbnet_status_start() unless they implement the "status" subdriver hook
which actually handles the interrupt URB messages.  If they don't
implement the hook, that means the driver is doing nothing special with
the interrupt URB, and thus it shouldn't be calling these functions.

> > +
> > +       if (test_bit (EVENT_DEV_ASLEEP, &dev->flags))
> > +               return -EINVAL;
> > +
> > +       mutex_lock (&dev->interrupt_mutex);
> > +       if (++dev->interrupt_count == 1)
> > +               ret = usb_submit_urb (dev->interrupt, mem_flags);
> > +       dev_dbg(&dev->udev->dev, "incremented interrupt URB count to
> %d\n",
> > +               dev->interrupt_count);
> > +       mutex_unlock (&dev->interrupt_mutex);
> > +       return ret;
> > +}
> > +EXPORT_SYMBOL_GPL(usbnet_status_start);
> > +
> > +/* Kill the interrupt URB if all submitters want it killed */
> > +void usbnet_status_stop(struct usbnet *dev)
> > +{
> > +       if (dev->interrupt) {
> > +               mutex_lock (&dev->interrupt_mutex);
> > +               BUG_ON(dev->interrupt_count == 0);
> > +               if (dev->interrupt_count && --dev->interrupt_count == 0)
> 
> Check on dev->interrupt_count isn't necessary.

Fixed.

> > +                       usb_kill_urb(dev->interrupt);
> > +               dev_dbg(&dev->udev->dev,
> > +                       "decremented interrupt URB count to %d\n",
> > +                       dev->interrupt_count);
> > +               mutex_unlock (&dev->interrupt_mutex);
> > +       }
> > +}
> > +EXPORT_SYMBOL_GPL(usbnet_status_stop);
> > +
> >  /* Passes this packet up the stack, updating its accounting.
> >   * Some link protocols batch packets, so their rx_fixup paths
> >   * can return clones as well as just modify the original skb.
> > @@ -725,7 +762,7 @@ int usbnet_stop (struct net_device *net)
> >         if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
> >                 usbnet_terminate_urbs(dev);
> >
> > -       usb_kill_urb(dev->interrupt);
> > +       usbnet_status_stop(dev);
> >
> >         usbnet_purge_paused_rxq(dev);
> >
> > @@ -787,7 +824,7 @@ int usbnet_open (struct net_device *net)
> >
> >         /* start any status interrupt transfer */
> >         if (dev->interrupt) {
> > -               retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
> > +               retval = usbnet_status_start(dev, GFP_KERNEL);
> >                 if (retval < 0) {
> >                         netif_err(dev, ifup, dev->net,
> >                                   "intr submit %d\n", retval);
> > @@ -1430,6 +1467,8 @@ usbnet_probe (struct usb_interface *udev, const
> struct usb_device_id *prod)
> >         dev->delay.data = (unsigned long) dev;
> >         init_timer (&dev->delay);
> >         mutex_init (&dev->phy_mutex);
> > +       mutex_init (&dev->interrupt_mutex);
> > +       dev->interrupt_count = 0;
> >
> >         dev->net = net;
> >         strcpy (net->name, "usb%d");
> > @@ -1585,9 +1624,13 @@ int usbnet_resume (struct usb_interface *intf)
> >         int                     retval;
> >
> >         if (!--dev->suspend_count) {
> > -               /* resume interrupt URBs */
> > -               if (dev->interrupt && test_bit(EVENT_DEV_OPEN,
> &dev->flags))
> > -                       usb_submit_urb(dev->interrupt, GFP_NOIO);
> > +               /* resume interrupt URBs if they were submitted at
> suspend */
> > +               if (dev->interrupt) {
> > +                       mutex_lock (&dev->interrupt_mutex);
> > +                       if (dev->interrupt_count)
> > +                               usb_submit_urb(dev->interrupt, GFP_NOIO);
> > +                       mutex_unlock (&dev->interrupt_mutex);
> > +               }
> 
> Given the introduced usbnet_status_start/usbnet_status_sop, it is
> better to apply them with one extra 'force' parameter in suspend()
> and resume() too.

Except that I'd rather the 'force' parameter never leak out of usbnet.c,
since that's the only place it should ever be used.  Instead, I'll
create an internal _usbnet_status_start()/_usbnet_status_stop() function
that has these parameters, while the public ones just call these with
'false'.  Sound OK?

Thanks,
Dan

> >
> >                 spin_lock_irq(&dev->txq.lock);
> >                 while ((res = usb_get_from_anchor(&dev->deferred))) {
> > diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> > index 0e5ac93..d71f44c 100644
> > --- a/include/linux/usb/usbnet.h
> > +++ b/include/linux/usb/usbnet.h
> > @@ -56,6 +56,8 @@ struct usbnet {
> >         struct sk_buff_head     done;
> >         struct sk_buff_head     rxq_pause;
> >         struct urb              *interrupt;
> > +       unsigned                interrupt_count;
> > +       struct mutex            interrupt_mutex;
> >         struct usb_anchor       deferred;
> >         struct tasklet_struct   bh;
> >
> > @@ -246,4 +248,7 @@ extern int usbnet_nway_reset(struct net_device *net);
> >
> >  extern int usbnet_manage_power(struct usbnet *, int);
> >
> > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags);
> > +void usbnet_status_stop(struct usbnet *dev);
> > +
> >  #endif /* __LINUX_USB_USBNET_H */
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Thanks,
> --
> Ming Lei


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
