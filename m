From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 10:31:31 +0800
Message-ID: <CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<21345916.cd7DzC6Ttz@linux-5eaq.site>
	<1365606080.28888.72.camel@dcbw.foobar.com>
	<7761183.G42DetJs5Z@linux-5eaq.site>
	<1365625850.22411.1.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365625850.22411.1.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 4:30 AM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Some drivers (sierra_net) need the status interrupt URB
> active even when the device is closed, because they receive
> custom indications from firmware.  Add functions to refcount
> the status interrupt URB submit/kill operation so that
> sub-drivers and the generic driver don't fight over whether
> the status interrupt URB is active or not.
>
> A sub-driver can call usbnet_status_start() at any time, but
> the URB is only submitted the first time the function is
> called.  Likewise, when the sub-driver is done with the URB,
> it calls usbnet_status_stop() but the URB is only killed when
> all users have stopped it.  The URB is still killed and
> re-submitted for suspend/resume, as before, with the same
> refcount it had at suspend.
>
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/usb/usbnet.c   | 79 ++++++++++++++++++++++++++++++++++++++++++----
>  include/linux/usb/usbnet.h |  5 +++
>  2 files changed, 77 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 51f3192..b71ce36 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -252,6 +252,70 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
>         return 0;
>  }
>
> +/* Submit the interrupt URB if not previously submitted, increasing refcount */
> +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)

'mem_flags' isn't needed any more since we can apply allocation
of GFP_NOIO automatically in resume path now, and you can always
use GFP_KERNEL safely. Considered that it is a API, please don't
introduce it.

After removing it, you can add

          Acked-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> +{
> +       int ret = 0;
> +
> +       WARN_ON_ONCE(dev->interrupt == NULL);
> +       if (dev->interrupt) {
> +               mutex_lock(&dev->interrupt_mutex);
> +
> +               if (++dev->interrupt_count == 1)
> +                       ret = usb_submit_urb(dev->interrupt, mem_flags);
> +
> +               dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
> +                       dev->interrupt_count);
> +               mutex_unlock(&dev->interrupt_mutex);
> +       }
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(usbnet_status_start);
> +
> +/* For resume; submit interrupt URB if previously submitted */
> +static int __usbnet_status_start_force(struct usbnet *dev, gfp_t mem_flags)
> +{
> +       int ret = 0;
> +
> +       mutex_lock(&dev->interrupt_mutex);
> +       if (dev->interrupt_count) {
> +               ret = usb_submit_urb(dev->interrupt, mem_flags);
> +               dev_dbg(&dev->udev->dev,
> +                       "submitted interrupt URB for resume\n");
> +       }
> +       mutex_unlock(&dev->interrupt_mutex);
> +       return ret;
> +}
> +
> +/* Kill the interrupt URB if all submitters want it killed */
> +void usbnet_status_stop(struct usbnet *dev)
> +{
> +       if (dev->interrupt) {
> +               mutex_lock(&dev->interrupt_mutex);
> +               WARN_ON(dev->interrupt_count == 0);
> +
> +               if (dev->interrupt_count && --dev->interrupt_count == 0)
> +                       usb_kill_urb(dev->interrupt);
> +
> +               dev_dbg(&dev->udev->dev,
> +                       "decremented interrupt URB count to %d\n",
> +                       dev->interrupt_count);
> +               mutex_unlock(&dev->interrupt_mutex);
> +       }
> +}
> +EXPORT_SYMBOL_GPL(usbnet_status_stop);
> +
> +/* For suspend; always kill interrupt URB */
> +static void __usbnet_status_stop_force(struct usbnet *dev)
> +{
> +       if (dev->interrupt) {
> +               mutex_lock(&dev->interrupt_mutex);
> +               usb_kill_urb(dev->interrupt);
> +               dev_dbg(&dev->udev->dev, "killed interrupt URB for suspend\n");
> +               mutex_unlock(&dev->interrupt_mutex);
> +       }
> +}

Looks it isn't a good practice to duplicate code in above four functions, but
it should be OK to merge first.

> +
>  /* Passes this packet up the stack, updating its accounting.
>   * Some link protocols batch packets, so their rx_fixup paths
>   * can return clones as well as just modify the original skb.
> @@ -725,7 +789,7 @@ int usbnet_stop (struct net_device *net)
>         if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
>                 usbnet_terminate_urbs(dev);
>
> -       usb_kill_urb(dev->interrupt);
> +       usbnet_status_stop(dev);
>
>         usbnet_purge_paused_rxq(dev);
>
> @@ -787,7 +851,7 @@ int usbnet_open (struct net_device *net)
>
>         /* start any status interrupt transfer */
>         if (dev->interrupt) {
> -               retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
> +               retval = usbnet_status_start(dev, GFP_KERNEL);
>                 if (retval < 0) {
>                         netif_err(dev, ifup, dev->net,
>                                   "intr submit %d\n", retval);
> @@ -1430,6 +1494,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>         dev->delay.data = (unsigned long) dev;
>         init_timer (&dev->delay);
>         mutex_init (&dev->phy_mutex);
> +       mutex_init(&dev->interrupt_mutex);
> +       dev->interrupt_count = 0;
>
>         dev->net = net;
>         strcpy (net->name, "usb%d");
> @@ -1565,7 +1631,7 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
>                  */
>                 netif_device_detach (dev->net);
>                 usbnet_terminate_urbs(dev);
> -               usb_kill_urb(dev->interrupt);
> +               __usbnet_status_stop_force(dev);
>
>                 /*
>                  * reattach so runtime management can use and
> @@ -1585,9 +1651,8 @@ int usbnet_resume (struct usb_interface *intf)
>         int                     retval;
>
>         if (!--dev->suspend_count) {
> -               /* resume interrupt URBs */
> -               if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
> -                       usb_submit_urb(dev->interrupt, GFP_NOIO);
> +               /* resume interrupt URB if it was previously submitted */
> +               __usbnet_status_start_force(dev, GFP_NOIO);
>
>                 spin_lock_irq(&dev->txq.lock);
>                 while ((res = usb_get_from_anchor(&dev->deferred))) {
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 0e5ac93..d71f44c 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -56,6 +56,8 @@ struct usbnet {
>         struct sk_buff_head     done;
>         struct sk_buff_head     rxq_pause;
>         struct urb              *interrupt;
> +       unsigned                interrupt_count;
> +       struct mutex            interrupt_mutex;
>         struct usb_anchor       deferred;
>         struct tasklet_struct   bh;
>
> @@ -246,4 +248,7 @@ extern int usbnet_nway_reset(struct net_device *net);
>
>  extern int usbnet_manage_power(struct usbnet *, int);
>
> +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags);
> +void usbnet_status_stop(struct usbnet *dev);
> +
>  #endif /* __LINUX_USB_USBNET_H */
> --
> 1.8.1.4
>
>


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
