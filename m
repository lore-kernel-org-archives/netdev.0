From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Tue, 26 Jun 2012 15:23:19 +0800
Message-ID: <CACVXFVO5x9pePZekJPnywr7czXG_3_xCRj-rXEgf2KSQXnmPbA@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206250815.39466.oliver@neukum.org>
	<CACVXFVNUv6w5OjSZdQDbcLEPpDU5vO_Nmarm+fAfh0RkkL_hdg@mail.gmail.com>
	<201206251410.13454.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:32943 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757100Ab2FZHXU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:23:20 -0400
In-Reply-To: <201206251410.13454.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 25, 2012 at 8:10 PM, Oliver Neukum <oliver@neukum.org> wrot=
e:
> Am Montag, 25. Juni 2012, 09:15:21 schrieb Ming Lei:
>> Any locking isn't needed if the set to NULL is put after
>> driver_info->unbind, =A0since ->unbind will call subdriver->disconne=
ct,
>> which will hold the open/disconnect lock of wdm_mutex.
>
> True for cdc_wdm. But usbnet needs to work well for everything.

Suppose there are other usbnet drivers which may have this kind of
subdriver, and they have to take one lock to avoid open/disconnect
race, there are only two ways to do it:

          - the lock is held before calling usbnet_disconnect
          - the lock is held inside driver_info->unbind

So putting the set to NULL after driver_info->unbind should work
for the both two ways above.

Also we can document the usage in comments.

>
>> > We can move to after unregister_netdev()
>> > I am unhappy with it going after unbind.
>> >
>>
>> Could you let us know the reason? I think it may let the
>> patch not necessary.
>
> Very well. This is the code:
>
> =A0void usbnet_disconnect (struct usb_interface *intf)
> {
> =A0 =A0 =A0 =A0struct usbnet =A0 =A0 =A0 =A0 =A0 *dev;
> =A0 =A0 =A0 =A0struct usb_device =A0 =A0 =A0 *xdev;
> =A0 =A0 =A0 =A0struct net_device =A0 =A0 =A0 *net;
>
> =A0 =A0 =A0 =A0dev =3D usb_get_intfdata(intf);
> =A0 =A0 =A0 =A0usb_set_intfdata(intf, NULL);
> =A0 =A0 =A0 =A0if (!dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> This code needs to check for NULL (cdc_ether and similar drivers)
> It is cleaner that if we need to check for NULL we also set to NULL.
> But that is no good reason to keep it if there's real trouble
>
> =A0 =A0 =A0 =A0xdev =3D interface_to_usbdev (intf);
>
> =A0 =A0 =A0 =A0netif_info(dev, probe, dev->net, "unregister '%s' usb-=
%s-%s, %s\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 intf->dev.driver->name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xdev->bus->bus_name, xdev->devpat=
h,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->driver_info->description);
>
> =A0 =A0 =A0 =A0net =3D dev->net;
> =A0 =A0 =A0 =A0unregister_netdev (net);
>
> Here intfdata is NULL.
>
> =A0 =A0 =A0 =A0cancel_work_sync(&dev->kevent);
>
> =A0 =A0 =A0 =A0if (dev->driver_info->unbind)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->driver_info->unbind (dev, intf);
>
> At this point a minidriver must not follow the intfdata pointer,
> because the interface may again be probed. So if here a minidriver

IMO, probe is serialized strictly with driver unbind since both the par=
ent
lock and its own device lock have been held, so the probe may only be
started after driver unbinding is completed.

> still uses intfdata, locking will be needed. We want to catch those
> casees.

Suppose infdata is used here somewhere, it is surely a bug because
the usbnet instance pointed by intfdata will be freed soon.

So looks putting the set to NULL after driver_info->unbind is good,
doesn't it?

>
> =A0 =A0 =A0 =A0usb_kill_urb(dev->interrupt);
> =A0 =A0 =A0 =A0usb_free_urb(dev->interrupt);
>
> =A0 =A0 =A0 =A0free_netdev(net);
> =A0 =A0 =A0 =A0usb_put_dev (xdev);
> }
>
>> > Sure, it is a debugging aid. It has the drawback that minidrivers =
have
>> > to be able to deal with intfdata being NULL. That is not hard to d=
o.
>>
>> The check isn't needed if the set to NULL is put after =A0driver_inf=
o->unbind
>> in usbnet_disconnect.
>
> True, but we don't catch bugs.

If the check is added, the bugs may be hided, and no stack will be
dumped, :-)


Thanks,
--=20
Ming Lei
