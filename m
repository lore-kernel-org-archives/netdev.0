From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 14:10:13 +0200
Message-ID: <201206251410.13454.oliver@neukum.org>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no> <201206250815.39466.oliver@neukum.org> <CACVXFVNUv6w5OjSZdQDbcLEPpDU5vO_Nmarm+fAfh0RkkL_hdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-1?q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?iso-8859-1?q?Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNUv6w5OjSZdQDbcLEPpDU5vO_Nmarm+fAfh0RkkL_hdg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 25. Juni 2012, 09:15:21 schrieb Ming Lei:
> On Mon, Jun 25, 2012 at 2:15 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
> > Am Montag, 25. Juni 2012, 05:37:20 schrieb Ming Lei:
> 
> >> The current problem is caused by the set to NULL without any
> >> protection or sync mechanism on it, and it is really a bug.
> >
> > Minidrivers can test for NULL.
> > That may not be enough and locking may be needed.
> 
> Any locking isn't needed if the set to NULL is put after
> driver_info->unbind,  since ->unbind will call subdriver->disconnect,
> which will hold the open/disconnect lock of wdm_mutex.

True for cdc_wdm. But usbnet needs to work well for everything.

> > We can move to after unregister_netdev()
> > I am unhappy with it going after unbind.
> >
> 
> Could you let us know the reason? I think it may let the
> patch not necessary.

Very well. This is the code:

 void usbnet_disconnect (struct usb_interface *intf)
{
        struct usbnet           *dev;
        struct usb_device       *xdev;
        struct net_device       *net;

        dev = usb_get_intfdata(intf);
        usb_set_intfdata(intf, NULL);
        if (!dev)
                return;

This code needs to check for NULL (cdc_ether and similar drivers)
It is cleaner that if we need to check for NULL we also set to NULL.
But that is no good reason to keep it if there's real trouble 

        xdev = interface_to_usbdev (intf);

        netif_info(dev, probe, dev->net, "unregister '%s' usb-%s-%s, %s\n",
                   intf->dev.driver->name,
                   xdev->bus->bus_name, xdev->devpath,
                   dev->driver_info->description);

        net = dev->net;
        unregister_netdev (net);

Here intfdata is NULL.

        cancel_work_sync(&dev->kevent);

        if (dev->driver_info->unbind)
                dev->driver_info->unbind (dev, intf);

At this point a minidriver must not follow the intfdata pointer,
because the interface may again be probed. So if here a minidriver
still uses intfdata, locking will be needed. We want to catch those
casees.

        usb_kill_urb(dev->interrupt);
        usb_free_urb(dev->interrupt);

        free_netdev(net);
        usb_put_dev (xdev);
}

> > Sure, it is a debugging aid. It has the drawback that minidrivers have
> > to be able to deal with intfdata being NULL. That is not hard to do.
> 
> The check isn't needed if the set to NULL is put after  driver_info->unbind
> in usbnet_disconnect.

True, but we don't catch bugs. 

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
