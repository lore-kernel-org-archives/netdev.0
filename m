From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Thu, 28 Jun 2012 10:55:34 +0200
Message-ID: <87hatvdddl.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206251410.13454.oliver@neukum.org>
	<CACVXFVO5x9pePZekJPnywr7czXG_3_xCRj-rXEgf2KSQXnmPbA@mail.gmail.com>
	<201206281035.19964.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206281035.19964.oneukum-l3A5Bk7waGM@public.gmane.org> (Oliver Neukum's message of
	"Thu, 28 Jun 2012 10:35:19 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:

> Am Dienstag, 26. Juni 2012, 09:23:19 schrieb Ming Lei:
>> On Mon, Jun 25, 2012 at 8:10 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> w=
rote:
>
>> > At this point a minidriver must not follow the intfdata pointer,
>> > because the interface may again be probed. So if here a minidriver
>>=20
>> IMO, probe is serialized strictly with driver unbind since both the =
parent
>> lock and its own device lock have been held, so the probe may only b=
e
>> started after driver unbinding is completed.
>
> Yes, but if you have a driver which claims multiple interfaces and us=
es
> a subdriver, then you will have cases of intfdate being NULL before
> disconnect() finishes.

This is true regardless of subdriver, isn't it?  The subdriver issue is
special because it makes this a potentional problem even with a single
interface.

>> > still uses intfdata, locking will be needed. We want to catch thos=
e
>> > casees.
>>=20
>> Suppose infdata is used here somewhere, it is surely a bug because
>> the usbnet instance pointed by intfdata will be freed soon.
>
> Of course. That is the point.
>
>> So looks putting the set to NULL after driver_info->unbind is good,
>> doesn't it?
>
> Again, of course. We could drop it (but not the check for NULL in usb=
net).
> It is a debugging aid.=20
>
>> >        usb_kill_urb(dev->interrupt);
>> >        usb_free_urb(dev->interrupt);
>> >
>> >        free_netdev(net);
>> >        usb_put_dev (xdev);
>> > }
>> >
>> >> > Sure, it is a debugging aid. It has the drawback that minidrive=
rs have
>> >> > to be able to deal with intfdata being NULL. That is not hard t=
o do.
>> >>
>> >> The check isn't needed if the set to NULL is put after  driver_in=
fo->unbind
>> >> in usbnet_disconnect.
>> >
>> > True, but we don't catch bugs.
>>=20
>> If the check is added, the bugs may be hided, and no stack will be
>> dumped, :-)
>
> That is also true.
>
> Bj=C3=B8rn,
>
> do you use subdrivers with cdc-ether?

No, and I don't think it should ever be added there.  It would add
complexity to the driver, and IMHO we really don't want that for the
generic cdc-ether. Better adding a new minidriver if the need to export
some other CDC embedded protocol to userspace shows up.

But given that all other embedded protocol examples I've seen are so
simple that they've been implemented inside their repective minidrivers
(sierra_net, hso, rndis_host), I don't think it's likely that any new
need for the cdc-wdm subdriver will show up soon.  I could of course be
completely wrong, as usual.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
