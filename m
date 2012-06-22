From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Fri, 22 Jun 2012 18:18:12 +0200
Message-ID: <877guzl3qz.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
	<87mx3vlayl.fsf@nemi.mork.no>
	<CACVXFVOQ3Uh50iJxboD-7=+J55MAW8Wjt3iY0WahauO2PrxT4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOQ3Uh50iJxboD-7=+J55MAW8Wjt3iY0WahauO2PrxT4w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Fri, 22 Jun 2012 23:09:36 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Looks I understand the problem incorrectly, your problem is
> that qmi_wwan_cdc_wdm_manage_power is called from
> wdm_open, not from usbnet_open. It is a problem crossing
> 2 class drivers.

That's correct.  Trying to use two drivers at once will necessarily lea=
d
to the situation where one drivers shutdown is called from the other
drivers shutdown.  And the fact that one of the drivers is a usbnet
minidriver complicates this a bit.

But I believe most of it should be OK now.  I tried my best to let the
two drivers share as little as possible.  The only shared state is in
the power management code, which have to access the active/idle state o=
f
both drivers.

>>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>>> index e92c057..2eb9e1e 100644
>>> --- a/drivers/net/usb/usbnet.c
>>> +++ b/drivers/net/usb/usbnet.c
>>> @@ -1286,7 +1286,6 @@ void usbnet_disconnect (struct usb_interface =
*intf)
>>> =C2=A0 =C2=A0 =C2=A0 struct net_device =C2=A0 =C2=A0 =C2=A0 *net;
>>>
>>> =C2=A0 =C2=A0 =C2=A0 dev =3D usb_get_intfdata(intf);
>>> - =C2=A0 =C2=A0 usb_set_intfdata(intf, NULL);
>>> =C2=A0 =C2=A0 =C2=A0 if (!dev)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>
>> I believe that call is there to prevent disconnect from running twic=
e
>> for the common two-interface CDC ethernet model, like e.g. cdc_ether=
=2E
>
> No, intfdata is per interface, and .unbind will clear it for each int=
erface.


Yes, intfdata is per interface, but in the case of cdc_ether (and
probably other similar minidrivers) there are two interfaces pointing t=
o
the *same* usbnet private data.

What about the situation where disconnect is called simultaneously for
both interfaces? Or can't that happen? If it can, then we'll do

 driver->disconnect(intf1)                driver->disconnect(intf2)
     dev =3D usb_get_intfdata(intf1)           dev =3D usb_get_intfdata=
(intf2)
     dev->driver_info->unbind()              dev->driver_info->unbind()
     net =3D dev->net                          net =3D dev->net
     free_netdev(net)                        free_netdev(dev->net)

where "dev" and "net" will be pointing to the same private data and
netdevice.

I assume that is what the code above is trying to protect against.  But
I could be wrong.  That has happened before, believe it or not :-)


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
