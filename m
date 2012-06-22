From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sat, 23 Jun 2012 00:52:05 +0800
Message-ID: <CACVXFVNCAsM5NihpAFLU5rGo5ynr3=XU5gw7nM5Fi2mrrX+hKA@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
	<87mx3vlayl.fsf@nemi.mork.no>
	<CACVXFVOQ3Uh50iJxboD-7=+J55MAW8Wjt3iY0WahauO2PrxT4w@mail.gmail.com>
	<877guzl3qz.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877guzl3qz.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 23, 2012 at 12:18 AM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Yes, intfdata is per interface, but in the case of cdc_ether (and
> probably other similar minidrivers) there are two interfaces pointing=
 to
> the *same* usbnet private data.

Yes, the priv pointers of both interface points to the usbnet instance,=
 but
the same pointer is stored into two places.

>
> What about the situation where disconnect is called simultaneously fo=
r
> both interfaces? Or can't that happen? If it can, then we'll do

It can't happen because both parent lock and its lock need to be held i=
n
hotplug situation or unbind situation.

>
> =A0driver->disconnect(intf1) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0driver->d=
isconnect(intf2)
> =A0 =A0 dev =3D usb_get_intfdata(intf1) =A0 =A0 =A0 =A0 =A0 dev =3D u=
sb_get_intfdata(intf2)
> =A0 =A0 dev->driver_info->unbind() =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->dr=
iver_info->unbind()
> =A0 =A0 net =3D dev->net =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0net =3D dev->net
> =A0 =A0 free_netdev(net) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0free_netdev(dev->net)
>
> where "dev" and "net" will be pointing to the same private data and
> netdevice.

Suppose driver->disconnect(intf1) is called first, .ubind() inside
=2Edisconnect will clear intfdata of another interface(intf2) and call
usb_driver_release_interface(intf2), which will cause .disconnect(intf2=
)
called, but it will return immediately.

>
> I assume that is what the code above is trying to protect against. =A0=
But

I don't see the protection in the code, :-)

> I could be wrong. =A0That has happened before, believe it or not :-)

Could you provide a link or commit about it?


Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
